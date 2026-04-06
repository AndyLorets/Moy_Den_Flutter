import 'package:flutter/material.dart';

// Показывает bottom sheet с подсказкой
void showTipSheet(BuildContext context, {required String title, required String body}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _TipSheet(title: title, body: body),
  );
}

class _TipSheet extends StatelessWidget {
  final String title;
  final String body;
  const _TipSheet({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20, 20, 20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.tertiary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Text(body, style: theme.textTheme.bodyMedium?.copyWith(height: 1.6)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
