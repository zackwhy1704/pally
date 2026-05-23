import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';

class PallyLoadingSpinner extends StatelessWidget {
  const PallyLoadingSpinner({super.key, this.size = 36});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(
          color: AppColors.purple,
          strokeWidth: 3,
        ),
      ),
    );
  }
}
