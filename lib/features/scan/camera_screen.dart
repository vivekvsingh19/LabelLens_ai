import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:labelsafe_ai/core/theme/app_theme.dart';

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
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.previewSize!.height,
              height: _controller!.value.previewSize!.width,
              child: CameraPreview(_controller!),
            ),
          ),
          _buildScanningLine(),
          if (_isAnalyzing) _buildAnalyzingUI(),
          _buildBackBtn(),
          if (!_isAnalyzing) _buildCaptureBtn(),
        ],
      ),
    );
  }

  Widget _buildScanningLine() {
    return Stack(
      children: [
        Container(
          height: double.infinity,
          width: double.infinity,
          color: AppTheme.accentPrimary.withValues(alpha: 0.02),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn(duration: 2.seconds),
        const _ModernScannerBar(),
        const _ScannerCorners(),
      ],
    );
  }

  Widget _buildAnalyzingUI() {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
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
            'SCAN THE LABEL',
            style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                letterSpacing: 2,
                fontWeight: FontWeight.w900),
          )
              .animate(onPlay: (c) => c.repeat())
              .fadeIn(duration: 1.seconds)
              .then()
              .fadeOut(duration: 1.seconds),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _onCapture,
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5), width: 2),
              ),
              child: Center(
                child: Container(
                  width: 68,
                  height: 68,
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

class _ModernScannerBar extends StatelessWidget {
  const _ModernScannerBar();

  @override
  Widget build(BuildContext context) {
    return Container().animate(onPlay: (c) => c.repeat()).custom(
          duration: 4.seconds,
          builder: (context, value, child) {
            final screenHeight = MediaQuery.of(context).size.height;
            final topPos = screenHeight * value;
            return Stack(
              children: [
                Positioned(
                  top: topPos - 100,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppTheme.accentPrimary.withValues(alpha: 0.15),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 2,
                        width: double.infinity,
                        color: AppTheme.accentPrimary.withValues(alpha: 0.8),
                      ),
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppTheme.accentPrimary.withValues(alpha: 0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
  }
}

class _ScannerCorners extends StatelessWidget {
  const _ScannerCorners();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Stack(
        children: [
          _buildCorner(Alignment.topLeft, 0),
          _buildCorner(Alignment.topRight, 1),
          _buildCorner(Alignment.bottomRight, 2),
          _buildCorner(Alignment.bottomLeft, 3),
        ],
      ),
    );
  }

  Widget _buildCorner(Alignment alignment, int quarterTurns) {
    return Align(
      alignment: alignment,
      child: RotatedBox(
        quarterTurns: quarterTurns,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.4), width: 3),
              left: BorderSide(
                  color: Colors.white.withValues(alpha: 0.4), width: 3),
            ),
          ),
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
        begin: const Offset(1, 1),
        end: const Offset(1.1, 1.1),
        duration: 2.seconds);
  }
}
