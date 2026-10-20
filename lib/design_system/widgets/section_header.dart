import 'package:flutter/material.dart';

import '../tokens.dart';

/// A section title, announced as a heading, with an optional trailing action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
    child: Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(title, style: AppType.cardTitle),
          ),
        ),
        ?trailing,
      ],
    ),
  );
}
