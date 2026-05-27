import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/ui/painters/character_painter.dart';
import 'package:pally/core/ui/pally_button.dart';
import 'package:pally/shared/models/mochi_character.dart';

class NameStep extends StatefulWidget {
  const NameStep({
    super.key,
    required this.name,
    required this.selectedCharacter,
    required this.onNameChanged,
    required this.onNext,
  });

  final String name;
  final MochiCharacter? selectedCharacter;
  final ValueChanged<String> onNameChanged;
  final VoidCallback? onNext;

  @override
  State<NameStep> createState() => _NameStepState();
}

class _NameStepState extends State<NameStep> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.selectedCharacter != null)
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: widget.selectedCharacter!.bgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: CharacterWidget(
                            character: widget.selectedCharacter!,
                            size: 72,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Give your tutor a name',
                      style: AppTextStyles.heading1),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'What would you like to call your tutor?',
                    style:
                        AppTextStyles.body.copyWith(color: AppColors.text2),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _controller,
                    onChanged: widget.onNameChanged,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Robo, Prof. Felix…',
                      prefixIcon:
                          Icon(Icons.edit_outlined, color: AppColors.text3),
                    ),
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
          PallyButton(
            label: 'Next',
            onPressed: widget.onNext,
            fullWidth: true,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 4),
        ],
      ),
    );
  }
}
