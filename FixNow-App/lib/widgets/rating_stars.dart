import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.rating, this.size = 16});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = rating >= i + 1;
        final half = !filled && rating > i && rating < i + 1;
        return Icon(
          half ? Icons.star_half_rounded : (filled ? Icons.star_rounded : Icons.star_outline_rounded),
          size: size,
          color: (filled || half) ? AppColors.rating : AppColors.border,
        );
      }),
    );
  }
}

class RatingInput extends StatelessWidget {
  const RatingInput({super.key, required this.rating, required this.onChanged, this.size = 40});

  final double rating;
  final ValueChanged<double> onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final filled = rating >= i + 1;
        return IconButton(
          onPressed: () => onChanged((i + 1).toDouble()),
          icon: Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            color: AppColors.rating,
            size: size,
          ),
        );
      }),
    );
  }
}
