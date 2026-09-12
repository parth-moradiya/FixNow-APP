import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Friendly, non-technical error display used wherever a Firebase stream
/// or future fails (e.g. permission denied, offline) instead of showing
/// a blank screen or raw exception text.
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, this.message = "Something went wrong. Please try again."});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// Converts a raw exception into a short, user-friendly sentence for
/// SnackBars and inline errors.
String friendlyErrorMessage(Object error) {
  final text = error.toString().toLowerCase();
  if (text.contains('permission') || text.contains('denied')) {
    return "You don't have permission to do that right now.";
  }
  if (text.contains('network') || text.contains('socket') || text.contains('failed host lookup')) {
    return 'No internet connection. Please check your network and try again.';
  }
  return 'Something went wrong. Please try again.';
}
