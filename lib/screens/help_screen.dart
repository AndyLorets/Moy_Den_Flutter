import 'package:flutter/material.dart';
import '../constants/strings.dart';

// Экран справки — статичный
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Справка')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          _Section(title: HelpTexts.rootTitle, children: [
            _RBox(text: HelpTexts.rootBody),
            _RGold(text: HelpTexts.rootGold),
          ]),
          const Divider(height: 32),
          _Section(title: HelpTexts.fearsTitle, children: [
            _RH2(text: HelpTexts.fear1Title),
            _RFact(text: HelpTexts.fear1Fact),
            _RBox(text: HelpTexts.fear1Help),
            _RH2(text: HelpTexts.fear2Title),
            _RFact(text: HelpTexts.fear2Fact),
            _RH2(text: HelpTexts.fear3Title),
            _RDanger(text: HelpTexts.fear3Danger),
          ]),
          const Divider(height: 32),
          _Section(title: HelpTexts.techniquesTitle, children: [
            _RH2(text: HelpTexts.factVsInterpTitle),
            _RBox(text: HelpTexts.factVsInterpBody),
            _RH2(text: HelpTexts.groundingTitle),
            _RBox(text: HelpTexts.groundingBody),
            _RH2(text: HelpTexts.panicTitle),
            ...HelpTexts.panicSteps.asMap().entries.map(
                  (e) => _RStep(n: e.key + 1, text: e.value),
                ),
          ]),
          const Divider(height: 32),
          _Section(title: HelpTexts.mindsetTitle, children: [
            _RH2(text: HelpTexts.actionFirst),
            _RBox(text: HelpTexts.actionFirstBody),
            _RH2(text: HelpTexts.oneSkipRule),
            _RGold(text: HelpTexts.oneSkipBody),
            _RH2(text: HelpTexts.jungTitle),
            _RBox(text: HelpTexts.jungBody),
            _RItalic(text: HelpTexts.jungNote),
            _RH2(text: HelpTexts.franklTitle),
            _RItalic(text: HelpTexts.franklQuote),
          ]),
        ],
      ),
    );
  }
}

// ── Вспомогательные виджеты справки ─────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 10),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _RH2 extends StatelessWidget {
  final String text;
  const _RH2({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _RBox extends StatelessWidget {
  final String text;
  const _RBox({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(height: 1.7),
      ),
    );
  }
}

class _RFact extends StatelessWidget {
  final String text;
  const _RFact({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.fromLTRB(13, 10, 13, 10),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        border: Border(left: BorderSide(color: Colors.green.shade600, width: 3)),
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
      ),
      child: Text(text, style: theme.textTheme.bodySmall?.copyWith(height: 1.65)),
    );
  }
}

class _RDanger extends StatelessWidget {
  final String text;
  const _RDanger({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.fromLTRB(13, 10, 13, 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
        border: Border(left: BorderSide(color: theme.colorScheme.error, width: 3)),
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
      ),
      child: Text(text, style: theme.textTheme.bodySmall?.copyWith(height: 1.65)),
    );
  }
}

class _RGold extends StatelessWidget {
  final String text;
  const _RGold({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.fromLTRB(13, 10, 13, 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.4),
        border: Border(left: BorderSide(color: theme.colorScheme.tertiary, width: 3)),
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
      ),
      child: Text(text, style: theme.textTheme.bodySmall?.copyWith(height: 1.65)),
    );
  }
}

class _RStep extends StatelessWidget {
  final int n;
  final String text;
  const _RStep({required this.n, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$n',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: theme.textTheme.bodySmall?.copyWith(height: 1.65)),
          ),
        ],
      ),
    );
  }
}

class _RItalic extends StatelessWidget {
  final String text;
  const _RItalic({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontStyle: FontStyle.italic,
          height: 1.7,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
