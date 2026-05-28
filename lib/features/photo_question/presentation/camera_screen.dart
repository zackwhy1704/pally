import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';

const _kDark = Color(0xFF0F0A1A);
const _kScanTopFraction = 0.20;
const _kScanBottomFraction = 0.82;

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
  bool _showTips = false;

  @override
  void initState() {
    super.initState();
    _scanAnim =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _initCamera();
    _autoShowTipsIfFirstTime();
  }

  Future<void> _autoShowTipsIfFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getInt('ocr_tips_shown') ?? 0;
    if (shown < 1) {
      await Future.delayed(const Duration(milliseconds: 900));
      if (mounted) {
        await prefs.setInt('ocr_tips_shown', 1);
        setState(() => _showTips = true);
      }
    }
  }

  void _openTips() {
    if (!_showTips) setState(() => _showTips = true);
  }

  void _closeTips() {
    if (_showTips) setState(() => _showTips = false);
  }

  Future<void> _closeCamera() async {
    if (_controller != null && _controller!.value.isInitialized) {
      await _controller!.dispose();
      _controller = null;
    }
    if (mounted) context.pop(null);
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) await _closeCamera();
      return;
    }
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) await _closeCamera();
        return;
      }
      final selected = _isFront
          ? cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => cameras.first)
          : cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => cameras.first);

      _controller?.dispose();
      _controller = CameraController(selected, ResolutionPreset.high,
          enableAudio: false, imageFormatGroup: ImageFormatGroup.jpeg);
      await _controller!.initialize();
      if (mounted) setState(() => _isInitialised = true);
    } catch (_) {
      if (mounted) await _closeCamera();
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
      if (mounted) context.pop(xFile.path);
    } catch (_) {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _pickGallery() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null && mounted) context.pop(img.path);
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    setState(() => _isFlashOn = !_isFlashOn);
    await _controller!
        .setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
  }

  @override
  Widget build(BuildContext context) {
    // Guard: show plain black until controller is ready so the Stack has
    // something to render. CameraPreview crashes on an uninitialised controller.
    if (!_isInitialised || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.teal),
        ),
      );
    }

    final screenH = MediaQuery.of(context).size.height;
    final scanTop = screenH * _kScanTopFraction;
    final scanRange = screenH * (_kScanBottomFraction - _kScanTopFraction);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _closeCamera();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
        body: Stack(
          // StackFit.expand gives CameraPreview the tight bounded size it needs.
          fit: StackFit.expand,
          children: [
            // ── LAYER 1: Camera feed ─────────────────────────────────────
            // Must be the FIRST child and a direct Stack child — no wrappers.
            CameraPreview(_controller!),

            // ── LAYER 2: Viewfinder brackets ─────────────────────────────
            // Positioned.fill is the direct Stack child; IgnorePointer goes
            // INSIDE so the Positioned data is seen by the Stack's layout.
            const Positioned.fill(
              child: IgnorePointer(child: _ViewfinderBrackets()),
            ),

            // ── LAYER 3: Animated scan line ───────────────────────────────
            // Positioned is a DIRECT Stack child. Transform.translate handles
            // the animation — no nested Positioned inside AnimatedBuilder.
            Positioned(
              top: scanTop,
              left: 48,
              right: 48,
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _scanAnim,
                  builder: (_, __) => Transform.translate(
                    offset: Offset(0, _scanAnim.value * scanRange),
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
                  ),
                ),
              ),
            ),

            // ── LAYER 4: Instruction banner ───────────────────────────────
            // Positioned direct Stack child; IgnorePointer wraps the content.
            if (!_showTips)
              Positioned(
                bottom: screenH * 0.27,
                left: 40,
                right: 40,
                child: const IgnorePointer(child: _InstructionBanner()),
              ),

            // ── LAYER 5: Bottom controls ──────────────────────────────────
            if (!_showTips)
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

            // ── LAYER 6: Tips sheet (conditional — only in tree when open) ─
            // No controller needed. DSS is removed from tree on close, so it
            // cannot intercept touches when invisible.
            if (_showTips)
              NotificationListener<DraggableScrollableNotification>(
                onNotification: (n) {
                  if (n.extent < 0.05) _closeTips();
                  return true;
                },
                child: DraggableScrollableSheet(
                  initialChildSize: 0.62,
                  minChildSize: 0.0,
                  maxChildSize: 0.65,
                  snap: true,
                  snapSizes: const [0.0, 0.62],
                  builder: (_, scrollCtrl) => _TipsSheet(
                    scrollController: scrollCtrl,
                    onClose: _closeTips,
                  ),
                ),
              ),

            // ── LAYER 7: Top nav bar — always last = highest z-order ──────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _TopBar(
                isFlashOn: _isFlashOn,
                showTips: _showTips,
                onClose: _closeCamera,
                onFlashToggle: _toggleFlash,
                onTipsTap: _showTips ? _closeTips : _openTips,
              ),
            ),
          ],
        ),
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

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.isFlashOn,
    required this.showTips,
    required this.onClose,
    required this.onFlashToggle,
    required this.onTipsTap,
  });

  final bool isFlashOn;
  final bool showTips;
  final VoidCallback onClose;
  final VoidCallback onFlashToggle;
  final VoidCallback onTipsTap;

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
          // ✕ Close
          IconButton(
            icon: const Icon(Icons.close_rounded,
                color: Colors.white, size: 28),
            onPressed: onClose,
          ),
          const Spacer(),
          // Tips toggle pill
          GestureDetector(
            onTap: onTipsTap,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: showTips
                    ? Colors.white.withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(showTips ? '✕' : '?',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(width: 4),
                  Text(showTips ? 'Close' : 'Tips',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Flash toggle
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

// ── Tips sheet ────────────────────────────────────────────────────────────────

class _TipsSheet extends StatelessWidget {
  const _TipsSheet({
    required this.scrollController,
    required this.onClose,
  });

  final ScrollController scrollController;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kDark.withValues(alpha: 0.97),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Center(
            child: Container(
              width: 54,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('📷 Tips for best results',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Nunito')),
          const SizedBox(height: 4),
          Text('Better photo = better answers from your tutor',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 10,
                  fontFamily: 'Nunito')),
          const SizedBox(height: 16),
          const _TipRow(
              emoji: '☀️',
              label: 'Bright light',
              sub: 'No shadows across the text'),
          const _TipRow(
              emoji: '🤚',
              label: 'Hold still',
              sub: 'Wait for the image to focus'),
          const _TipRow(
              emoji: '📄',
              label: 'Fill the frame',
              sub: 'Bring the page edge-to-edge'),
          const _TipRow(
              emoji: '📐',
              label: 'Keep it straight',
              sub: 'Flat page, not tilted or curved'),
          const SizedBox(height: 12),
          Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.12)),
          const SizedBox(height: 12),
          Text('What Mochi reads:',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Nunito')),
          const SizedBox(height: 8),
          const Wrap(spacing: 6, runSpacing: 6, children: [
            _ContentChip(label: 'Printed text ✓', color: AppColors.green),
            _ContentChip(
                label: 'Clear numbers ✓', color: AppColors.green),
            _ContentChip(
                label: 'Neat handwriting ✓', color: AppColors.teal),
          ]),
          const SizedBox(height: 8),
          const Wrap(spacing: 6, runSpacing: 6, children: [
            _ContentChip(label: 'Diagrams ⚠️', color: AppColors.amber),
            _ContentChip(label: 'Symbols ⚠️', color: AppColors.amber),
            _ContentChip(label: 'Charts ✕', color: AppColors.coral),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: onClose,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Got it, close tips',
                  style: TextStyle(fontFamily: 'Nunito', fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow(
      {required this.emoji, required this.label, required this.sub});
  final String emoji;
  final String label;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.green, width: 1.5),
            ),
            child: const Center(
              child: Text('✓',
                  style: TextStyle(
                      color: AppColors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 10),
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Nunito')),
                Text(sub,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 9,
                        fontFamily: 'Nunito')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentChip extends StatelessWidget {
  const _ContentChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Center(
        child: Text(label,
            style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                fontFamily: 'Nunito')),
      ),
    );
  }
}

// ── Viewfinder brackets ───────────────────────────────────────────────────────
// All positions are fractional — adapts to any screen size.

class _ViewfinderBrackets extends StatelessWidget {
  const _ViewfinderBrackets();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _BracketPainter());
}

class _BracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final gapX = size.width * 0.12;
    final lenX = size.width * 0.09;
    final top = size.height * _kScanTopFraction;
    final bottom = size.height * _kScanBottomFraction;

    // Top-left
    canvas.drawLine(Offset(gapX, top), Offset(gapX + lenX, top), paint);
    canvas.drawLine(Offset(gapX, top), Offset(gapX, top + lenX), paint);
    // Top-right
    canvas.drawLine(Offset(size.width - gapX, top),
        Offset(size.width - gapX - lenX, top), paint);
    canvas.drawLine(Offset(size.width - gapX, top),
        Offset(size.width - gapX, top + lenX), paint);
    // Bottom-left
    canvas.drawLine(Offset(gapX, bottom), Offset(gapX + lenX, bottom), paint);
    canvas.drawLine(Offset(gapX, bottom), Offset(gapX, bottom - lenX), paint);
    // Bottom-right
    canvas.drawLine(Offset(size.width - gapX, bottom),
        Offset(size.width - gapX - lenX, bottom), paint);
    canvas.drawLine(Offset(size.width - gapX, bottom),
        Offset(size.width - gapX, bottom - lenX), paint);
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
          // Gallery
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
          // Shutter
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
                border: Border.all(color: AppColors.teal, width: 4),
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
          // Flip
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
