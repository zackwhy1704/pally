import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  late AnimationController _scanAnim;
  bool _isInitialised = false;
  bool _isFront = false;
  bool _isFlashOn = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _scanAnim =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _initCamera();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        context.pop(null);
      }
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          context.pop(null);
        }
        return;
      }

      final selected = _isFront
          ? cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => cameras.first,
            )
          : cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => cameras.first,
            );

      _controller?.dispose();
      _controller = CameraController(
        selected,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      if (mounted) {
        setState(() => _isInitialised = true);
      }
    } catch (_) {
      if (mounted) {
        context.pop(null);
      }
    }
  }

  Future<void> _capture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing) {
      return;
    }
    setState(() => _isCapturing = true);
    try {
      final xFile = await _controller!.takePicture();
      if (mounted) {
        context.pop(xFile.path);
      }
    } catch (_) {
      setState(() => _isCapturing = false);
    }
  }

  Future<void> _pickGallery() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null && mounted) {
      context.pop(img.path);
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    setState(() => _isFlashOn = !_isFlashOn);
    await _controller!.setFlashMode(
      _isFlashOn ? FlashMode.torch : FlashMode.off,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          if (_isInitialised && _controller != null)
            CameraPreview(_controller!)
          else
            const Center(
              child: CircularProgressIndicator(color: AppColors.teal),
            ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _TopBar(
              isFlashOn: _isFlashOn,
              onClose: () => context.pop(null),
              onFlashToggle: _toggleFlash,
            ),
          ),

          // Viewfinder brackets
          const Positioned.fill(child: _ViewfinderBrackets()),

          // Animated scan line
          if (_isInitialised)
            AnimatedBuilder(
              animation: _scanAnim,
              builder: (ctx, _) {
                const top = 160.0;
                const bottom = 560.0;
                return Positioned(
                  left: 48,
                  right: 48,
                  top: top + (_scanAnim.value * (bottom - top)),
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.transparent,
                        AppColors.teal.withValues(alpha: 0.8),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                );
              },
            ),

          // Instruction label
          const Positioned(
            bottom: 220,
            left: 40,
            right: 40,
            child: _InstructionBanner(),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomControls(
              isCapturing: _isCapturing,
              onCapture: _capture,
              onFlip: () {
                setState(() {
                  _isFront = !_isFront;
                  _isInitialised = false;
                });
                _initCamera();
              },
              onGallery: _pickGallery,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scanAnim.dispose();
    _controller?.dispose();
    super.dispose();
  }
}

// ── Top bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.isFlashOn,
    required this.onClose,
    required this.onFlashToggle,
  });

  final bool isFlashOn;
  final VoidCallback onClose;
  final VoidCallback onFlashToggle;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(top: top + 8, left: 8, right: 8, bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.6),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon:
                const Icon(Icons.close_rounded, color: Colors.white, size: 28),
            onPressed: onClose,
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: isFlashOn ? AppColors.amber : Colors.white,
              size: 28,
            ),
            onPressed: onFlashToggle,
          ),
        ],
      ),
    );
  }
}

// ── Viewfinder brackets ───────────────────────────────────────────────────────

class _ViewfinderBrackets extends StatelessWidget {
  const _ViewfinderBrackets();

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _BracketPainter());
}

class _BracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const gap = 48.0;
    const len = 36.0;
    const top = 160.0;
    const bottom = 560.0;

    // Top-left
    canvas.drawLine(
        const Offset(gap, top), const Offset(gap + len, top), paint);
    canvas.drawLine(
        const Offset(gap, top), const Offset(gap, top + len), paint);
    // Top-right
    canvas.drawLine(Offset(size.width - gap, top),
        Offset(size.width - gap - len, top), paint);
    canvas.drawLine(Offset(size.width - gap, top),
        Offset(size.width - gap, top + len), paint);
    // Bottom-left
    canvas.drawLine(
        const Offset(gap, bottom), const Offset(gap + len, bottom), paint);
    canvas.drawLine(
        const Offset(gap, bottom), const Offset(gap, bottom - len), paint);
    // Bottom-right
    canvas.drawLine(Offset(size.width - gap, bottom),
        Offset(size.width - gap - len, bottom), paint);
    canvas.drawLine(Offset(size.width - gap, bottom),
        Offset(size.width - gap, bottom - len), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Instruction banner ────────────────────────────────────────────────────────

class _InstructionBanner extends StatelessWidget {
  const _InstructionBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '📚 Point at your homework question',
        style: AppTextStyles.bodySmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ── Bottom controls ───────────────────────────────────────────────────────────

class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.isCapturing,
    required this.onCapture,
    required this.onFlip,
    required this.onGallery,
  });

  final bool isCapturing;
  final VoidCallback onCapture;
  final VoidCallback onFlip;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.only(bottom: bottom + 24, top: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Gallery button
          GestureDetector(
            onTap: onGallery,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white30),
              ),
              child: const Icon(Icons.photo_library_rounded,
                  color: Colors.white, size: 28),
            ),
          ),

          // Shutter button
          GestureDetector(
            onTap: isCapturing ? null : onCapture,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: isCapturing
                    ? AppColors.teal.withValues(alpha: 0.6)
                    : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.teal,
                  width: 4,
                ),
              ),
              child: isCapturing
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : Container(
                      margin: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.teal,
                        shape: BoxShape.circle,
                      ),
                    ),
            ),
          ),

          // Flip camera button
          GestureDetector(
            onTap: onFlip,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white30),
              ),
              child: const Icon(Icons.flip_camera_ios_rounded,
                  color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}
