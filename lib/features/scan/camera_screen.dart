import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CameraScreen extends StatefulWidget {
  final String scanType;
  const CameraScreen({super.key, required this.scanType});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isReady = false;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(cameras[0], ResolutionPreset.high);
    await _controller!.initialize();
    if (mounted) {
      setState(() => _isReady = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onCapture() async {
    setState(() => _isAnalyzing = true);
    // Simulate high-tech AI analysis
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      context.pushReplacement('/result/${widget.scanType}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || _controller == null) {
      return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator(color: Colors.white)));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),
          _buildOverlay(),
          if (_isAnalyzing) _buildAnalyzingUI(),
          _buildBackBtn(),
          if (!_isAnalyzing) _buildCaptureBtn(),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: ShapeDecoration(
        shape: _ScannerOverlayShape(),
      ),
    );
  }

  Widget _buildAnalyzingUI() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.scan, color: Colors.white, size: 80)
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 2.seconds)
              .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.1, 1.1),
                  duration: 1.seconds,
                  curve: Curves.easeInOut),
          const SizedBox(height: 32),
          const Text(
            'Analyzing Ingredients...',
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
          ).animate().fadeIn(),
          const SizedBox(height: 8),
          const Text(
            'Cross-referencing global health standards',
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildBackBtn() {
    return Positioned(
      top: 60,
      left: 20,
      child: IconButton(
        icon:
            const Icon(LucideIcons.chevronLeft, color: Colors.white, size: 32),
        onPressed: () => context.pop(),
      ),
    );
  }

  Widget _buildCaptureBtn() {
    return Positioned(
      bottom: 60,
      left: 0,
      right: 0,
      child: Column(
        children: [
          const Text(
            'Center the ingredient label',
            style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600),
          )
              .animate(onPlay: (c) => c.repeat())
              .fadeIn(duration: 1.seconds)
              .then()
              .fadeOut(duration: 1.seconds),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _onCapture,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ).animate().scale(curve: Curves.easeOutBack),
        ],
      ),
    );
  }
}

class _ScannerOverlayShape extends ShapeBorder {
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRect(rect);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final boxWidth = width * 0.85;
    final boxHeight = height * 0.35;
    final left = (width - boxWidth) / 2;
    final top = (height - boxHeight) / 2;
    final boxRect = Rect.fromLTWH(left, top, boxWidth, boxHeight);

    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawPath(
      Path.combine(PathOperation.difference, Path()..addRect(rect),
          Path()..addRect(boxRect)),
      paint,
    );

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    const cornerSize = 30.0;
    final path = Path()
      ..moveTo(left, top + cornerSize)
      ..lineTo(left, top)
      ..lineTo(left + cornerSize, top)
      ..moveTo(left + boxWidth - cornerSize, top)
      ..lineTo(left + boxWidth, top)
      ..lineTo(left + boxWidth, top + cornerSize)
      ..moveTo(left + boxWidth, top + boxHeight - cornerSize)
      ..lineTo(left + boxWidth, top + boxHeight)
      ..lineTo(left + boxWidth - cornerSize, top + boxHeight)
      ..moveTo(left + cornerSize, top + boxHeight)
      ..lineTo(left, top + boxHeight)
      ..lineTo(left, top + boxHeight - cornerSize);

    canvas.drawPath(path, borderPaint);
  }

  @override
  ShapeBorder scale(double t) => this;
}
