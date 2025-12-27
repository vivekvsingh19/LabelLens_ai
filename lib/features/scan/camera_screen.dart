import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:labelsafe_ai/core/theme/app_theme.dart';
import 'package:labelsafe_ai/core/services/gemini_service.dart';
import 'package:labelsafe_ai/core/providers/ui_providers.dart';

class CameraScreen extends ConsumerStatefulWidget {
  final String scanType;
  const CameraScreen({super.key, required this.scanType});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  CameraController? _controller;
  bool _isReady = false;
  bool _isImageCaptured = false;
  File? _imageFile;
  Uint8List? _webImageBytes; // For web platform
  XFile? _pickedFile; // Store XFile for web
  bool _isAnalyzing = false;
  final GeminiService _geminiService = GeminiService();
  final ImagePicker _imagePicker = ImagePicker();

  // Focus indicator
  Offset? _focusPoint;
  bool _showFocusIndicator = false;

  // Analysis Loading State
  Timer? _loadingTimer;
  int _loadingMessageIndex = 0;
  final List<String> _loadingMessages = [
    "Scanning label for ingredients...",
    "Identifying additives & preservatives...",
    "Checking against EU & WHO standards...",
    "Detecting hidden sugars & allergens...",
    "Calculating safety score...",
    "Finalizing report...",
  ];

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // On web, skip camera init - use image picker only
      setState(() => _isReady = true);
    } else {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    if (kIsWeb) return; // Camera not supported on web

    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    // Explicitly use the back camera
    final backCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      backCamera,
      ResolutionPreset.high, // High resolution is sufficient and more stable
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      // Enable continuous autofocus for scanning
      if (_controller!.value.isInitialized) {
        await _controller!.setFocusMode(FocusMode.auto);
      }
      if (mounted) {
        setState(() => _isReady = true);
      }
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  Future<void> _onTapFocus(TapDownDetails details) async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isImageCaptured) return;

    final screenSize = MediaQuery.of(context).size;
    final tapPosition = details.localPosition;

    // Show focus indicator
    setState(() {
      _focusPoint = tapPosition;
      _showFocusIndicator = true;
    });

    try {
      // Set focus point (normalized 0-1)
      final focusPoint = Offset(
        tapPosition.dx / screenSize.width,
        tapPosition.dy / screenSize.height,
      );

      await _controller!.setFocusPoint(focusPoint);
      await _controller!.setFocusMode(FocusMode.auto);

      // Also set exposure point for better results
      try {
        await _controller!.setExposurePoint(focusPoint);
      } catch (_) {}

      // Hide focus indicator after animation
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() => _showFocusIndicator = false);
        }
      });

      // Reset to continuous focus after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _controller!.value.isInitialized && !_isImageCaptured) {
          _controller!.setFocusPoint(null);
          _controller!.setFocusMode(FocusMode.auto);
        }
      });
    } catch (e) {
      debugPrint("Focus Error: $e");
      setState(() => _showFocusIndicator = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _loadingTimer?.cancel();
    super.dispose();
  }

  void _startLoadingAnimation() {
    setState(() {
      _isAnalyzing = true;
      _loadingMessageIndex = 0;
    });

    _loadingTimer?.cancel();
    _loadingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _loadingMessageIndex =
              (_loadingMessageIndex + 1) % _loadingMessages.length;
        });
      }
    });
  }

  void _stopLoadingAnimation() {
    _loadingTimer?.cancel();
    if (mounted) {
      setState(() => _isAnalyzing = false);
    }
  }

  void _onCapture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isAnalyzing) return;

    try {
      final XFile photo = await _controller!.takePicture();
      setState(() {
        _imageFile = File(photo.path);
        _isImageCaptured = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Capture Error: $e')),
      );
    }
  }

  void _onRetake() async {
    // Reset state first
    setState(() {
      _isImageCaptured = false;
      _imageFile = null;
      _webImageBytes = null;
      _pickedFile = null;
      _isAnalyzing = false;
    });

    // Just reset focus without reinitializing camera (avoids flash)
    if (!kIsWeb && _controller != null && _controller!.value.isInitialized) {
      try {
        await _controller!.setFocusPoint(null);
        await _controller!.setFocusMode(FocusMode.auto);
      } catch (e) {
        debugPrint("Focus reset error: $e");
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        _pickedFile = pickedFile;
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImageBytes = bytes;
            _isImageCaptured = true;
          });
        } else {
          setState(() {
            _imageFile = File(pickedFile.path);
            _isImageCaptured = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _captureFromWebCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        _pickedFile = pickedFile;
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
          _isImageCaptured = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: $e')),
        );
      }
    }
  }

  void _analyzeCapturedImage() async {
    if (_imageFile == null && _pickedFile == null) return;

    try {
      _startLoadingAnimation();

      final analysis = kIsWeb
          ? await _geminiService.analyzeProductImageFromBytes(
              _webImageBytes!, widget.scanType)
          : await _geminiService.analyzeProductImage(
              _imageFile!, widget.scanType);

      if (mounted) {
        if (analysis != null) {
          // Check for incomplete ingredients
          if (!analysis.isIngredientsListComplete) {
            _stopLoadingAnimation();

            final shouldContinue = await showDialog<bool>(
              context: context,
              barrierColor: Colors.black.withValues(alpha: 0.6),
              builder: (ctx) => Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.all(20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.cautionColor.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.scanLine,
                                color: AppTheme.cautionColor, size: 32),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Incomplete Scan Detected",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "The AI detected that the ingredient list might be cut off. For accurate results, please scan the full list.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text("RETAKE SCAN",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn()
                  .scale(duration: 300.ms, curve: Curves.easeOutBack),
            );

            if (shouldContinue != true) {
              _onRetake();
              return;
            }

            _startLoadingAnimation();
          }

          // Save to local history
          await ref.read(analysisRepositoryProvider).saveAnalysis(analysis);
          // Refresh history provider
          ref.invalidate(scanHistoryProvider);

          if (mounted) {
            context.pushReplacement(
                '/result/${Uri.encodeComponent(widget.scanType)}',
                extra: analysis);
          }
        } else {
          _stopLoadingAnimation();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Analysis failed. Ensure the image is clear and try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _stopLoadingAnimation();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator(color: Colors.white)));
    }

    // Web platform UI
    if (kIsWeb) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (!_isImageCaptured)
              _buildWebCameraPlaceholder()
            else if (_webImageBytes != null)
              Image.memory(
                _webImageBytes!,
                fit: BoxFit.cover,
              ),
            if (!_isImageCaptured) _buildScanningLine(),
            if (_isAnalyzing) _buildAnalyzingUI(),
            _buildBackBtn(),
            if (!_isAnalyzing)
              _isImageCaptured
                  ? _buildSelectionControls()
                  : _buildWebCaptureBtn(),
          ],
        ),
      );
    }

    // Native platform UI
    if (_controller == null) {
      return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator(color: Colors.white)));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (!_isImageCaptured)
            GestureDetector(
              onTapDown: _onTapFocus,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.previewSize!.height,
                  height: _controller!.value.previewSize!.width,
                  child: CameraPreview(_controller!),
                ),
              ),
            )
          else
            Image.file(
              _imageFile!,
              fit: BoxFit.cover,
            ),
          if (!_isImageCaptured) _buildScanningLine(),
          if (_showFocusIndicator && _focusPoint != null)
            _buildFocusIndicator(),
          if (_isAnalyzing) _buildAnalyzingUI(),
          _buildBackBtn(),
          if (!_isAnalyzing)
            _isImageCaptured ? _buildSelectionControls() : _buildCaptureBtn(),
        ],
      ),
    );
  }

  Widget _buildFocusIndicator() {
    return Positioned(
      left: _focusPoint!.dx - 30,
      top: _focusPoint!.dy - 30,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      )
          .animate()
          .scale(
              begin: const Offset(1.5, 1.5),
              end: const Offset(1, 1),
              duration: 200.ms)
          .fadeOut(delay: 500.ms, duration: 300.ms),
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
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Scanner Icon
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.accentPrimary.withValues(alpha: 0.1),
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.5, 1.5),
                    duration: 1.5.seconds),
                const Icon(LucideIcons.scanLine,
                        color: AppTheme.accentPrimary, size: 48)
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(duration: 2.seconds, color: Colors.white),
              ],
            ),
            const SizedBox(height: 40),

            // Dynamic Loading Text
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                              begin: const Offset(0, 0.5), end: Offset.zero)
                          .animate(animation),
                      child: child,
                    ));
              },
              child: Text(
                _loadingMessages[_loadingMessageIndex],
                key: ValueKey<int>(_loadingMessageIndex),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Please wait while AI analyzes the product...',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebCameraPlaceholder() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.camera,
                color: Colors.white54,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'TAP CAMERA OR GALLERY\nTO SCAN PRODUCT',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebCaptureBtn() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Gallery Button
              GestureDetector(
                onTap: _pickImageFromGallery,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      LucideIcons.image,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 200.ms)
                  .scale(curve: Curves.easeOutBack),
              const SizedBox(width: 32),
              // Camera Button
              GestureDetector(
                onTap: _captureFromWebCamera,
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
                      child: const Icon(
                        LucideIcons.camera,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ).animate().scale(curve: Curves.easeOutBack),
              const SizedBox(width: 96), // Balance
            ],
          ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Upload from Gallery Button
              GestureDetector(
                onTap: _pickImageFromGallery,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      LucideIcons.image,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 200.ms)
                  .scale(curve: Curves.easeOutBack),
              const SizedBox(width: 32),
              // Capture Button
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
              const SizedBox(width: 88), // Balance the row
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionControls() {
    return Positioned(
      bottom: 60,
      left: 24,
      right: 24,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: const Text('IS THE TEXT CLEAR AND READABLE?',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2)),
          ).animate().fadeIn().slideY(begin: 0.2, end: 0),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _onRetake,
                  icon: const Icon(LucideIcons.refreshCw, size: 20),
                  label: const Text('RETAKE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white12,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _analyzeCapturedImage,
                  icon: const Icon(LucideIcons.zap, size: 20),
                  label: const Text('ANALYZE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentPrimary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
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
