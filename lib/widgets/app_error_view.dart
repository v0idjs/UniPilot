import 'package:flutter/material.dart';

/// Visible error state with a retry action.
///
/// Used wherever a stream or load can fail so failures never render as a
/// blank area or an endless spinner.
class AppErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const AppErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.error_outline, size: 48, color: colors.error),
        const SizedBox(height: 12),
        Text(
          message,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: onRetry,
          child: const Text('Retry'),
        ),
      ]),
    );
  }
}
