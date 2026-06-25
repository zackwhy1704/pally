import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/app/router.dart';
import 'package:pally/features/join/data/join_code.dart';
import 'package:pally/features/join/data/join_resolve_service.dart';
import 'package:pally/features/join/presentation/join_controller.dart';

/// Inbound Join surface: enter or scan a code someone gave you. Two ways in
/// (manual + QR), one destination, and ALWAYS a named confirmation before any
/// join — scanning is reflexive, so the confirmation is what stops a student
/// silently joining the wrong class or attaching the wrong adult.
class JoinScreen extends ConsumerStatefulWidget {
  const JoinScreen({super.key});

  @override
  ConsumerState<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends ConsumerState<JoinScreen> {
  final TextEditingController _controller = TextEditingController();
  MobileScannerController? _scanController;
  bool _scanning = false;
  bool _busy = false;
  bool _scanHandled = false; // one code per scan session

  @override
  void dispose() {
    _controller.dispose();
    _scanController?.dispose();
    super.dispose();
  }

  void _startScan() {
    setState(() {
      _scanHandled = false;
      _scanController = MobileScannerController();
      _scanning = true;
    });
  }

  void _stopScan() {
    _scanController?.dispose();
    _scanController = null;
    if (mounted) setState(() => _scanning = false);
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanHandled) return;
    final raw = capture.barcodes.isEmpty ? null : capture.barcodes.first.rawValue;
    if (raw == null || raw.trim().isEmpty) return;
    _scanHandled = true;
    _stopScan();
    _handleRaw(raw);
  }

  Future<void> _submitManual() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      PallyToast.error(context, 'Enter a code first');
      return;
    }
    await _handleRaw(text);
  }

  Future<void> _handleRaw(String raw) async {
    if (_busy) return;
    final parsed = JoinCode.parse(raw);
    if (parsed == null) {
      PallyToast.error(context, "That doesn't look like a valid code");
      return;
    }

    // Parent-claim keeps its own claim screen + named confirmation.
    if (parsed.kind == JoinKind.parentClaim) {
      const FamilyClaimRoute().push(context);
      return;
    }

    final controller = ref.read(joinControllerProvider.notifier);

    setState(() => _busy = true);
    final ResolvedCode? resolved = await controller.resolve(parsed.code);
    if (!mounted) return;
    setState(() => _busy = false);

    final confirmed = await _confirm(parsed, resolved);
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    final type = resolved?.type ?? _typeFromKind(parsed.kind);
    String? error;
    if (type == 'GROUP') {
      error = await controller.joinGroup(parsed.code);
    } else if (type == 'CLASS') {
      error = await controller.joinClass(parsed.code);
    } else {
      // Truly unknown bare code: try class, then group.
      error = await controller.joinClass(parsed.code);
      if (error != null) error = await controller.joinGroup(parsed.code);
    }
    if (!mounted) return;
    setState(() => _busy = false);

    if (error == null) {
      PallyToast.success(context, 'Joined ${resolved?.name ?? 'successfully'} 🎉');
      context.pop();
    } else {
      PallyToast.error(context, error);
    }
  }

  String _typeFromKind(JoinKind kind) {
    switch (kind) {
      case JoinKind.classroom:
        return 'CLASS';
      case JoinKind.group:
        return 'GROUP';
      default:
        return 'UNKNOWN';
    }
  }

  Future<bool?> _confirm(JoinCode parsed, ResolvedCode? resolved) {
    final String title;
    final String? subtitle;
    if (resolved != null && resolved.type == 'CLASS') {
      title = 'Join ${resolved.name}?';
      subtitle = resolved.context; // centre name
    } else if (resolved != null && resolved.type == 'GROUP') {
      title = 'Join study group ${resolved.name}?';
      subtitle = null;
    } else {
      // Unresolved — confirm by the code itself, never silently join.
      title = 'Join with code ${parsed.code}?';
      subtitle = "We couldn't look this up — double-check it's the right code.";
    }

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: AppTextStyles.title.copyWith(color: AppColors.text1)),
        content: subtitle == null
            ? null
            : Text(subtitle, style: AppTextStyles.body.copyWith(color: AppColors.text2)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: AppTextStyles.body.copyWith(color: AppColors.text2)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Join', style: AppTextStyles.body.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.text1,
        title: Text('Join', style: AppTextStyles.title.copyWith(color: AppColors.text1)),
      ),
      body: _scanning ? _buildScanner() : _buildManual(),
    );
  }

  Widget _buildManual() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Enter or scan a code',
                style: AppTextStyles.heading1.copyWith(color: AppColors.text1)),
            const SizedBox(height: AppSpacing.sm),
            Text('Got a class or study-group code? Type it in, or scan its QR.',
                style: AppTextStyles.body.copyWith(color: AppColors.text2)),
            const SizedBox(height: AppSpacing.xl),
            TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.characters,
              autocorrect: false,
              inputFormatters: [UpperCaseFormatter()],
              style: AppTextStyles.title.copyWith(color: AppColors.text1, letterSpacing: 2),
              decoration: InputDecoration(
                hintText: 'e.g. 5K7Q2X',
                hintStyle: AppTextStyles.title.copyWith(color: AppColors.text3, letterSpacing: 2),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.md),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.purple, width: 2),
                ),
              ),
              onSubmitted: (_) => _submitManual(),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _busy ? null : _submitManual,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _busy
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Join',
                        style: AppTextStyles.body
                            .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(children: [
              const Expanded(child: Divider(color: AppColors.outline)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text('or', style: AppTextStyles.label.copyWith(color: AppColors.text3)),
              ),
              const Expanded(child: Divider(color: AppColors.outline)),
            ]),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _busy ? null : _startScan,
                icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.purple),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.purple,
                  side: const BorderSide(color: AppColors.purple, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                label: Text('Scan QR',
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.purple, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanner() {
    return Stack(
      children: [
        MobileScanner(controller: _scanController, onDetect: _onDetect),
        // Aiming frame
        Center(
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Point at a class or group QR',
                        style: AppTextStyles.body.copyWith(color: Colors.white)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: _stopScan,
                    child: Text('Enter code manually',
                        style: AppTextStyles.body
                            .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Forces typed codes to upper-case so they match server normalisation.
class UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
