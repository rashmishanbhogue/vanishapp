// colour_palette.dart

import 'package:flutter/material.dart';

import '../models/paper_theme.dart';

class ColourPalette extends StatelessWidget {
  final List<PaperTheme> themes;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool enabled;

  const ColourPalette({
    super.key,
    required this.themes,
    required this.selectedIndex,
    required this.onSelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(themes.length, (index) {
        final theme = themes[index];

        return GestureDetector(
          onTap: enabled ? () => onSelected(index) : null,
          child: Container(
            margin: const EdgeInsets.only(left: 5),
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              color: theme.dotColour,
              shape: BoxShape.circle,
              border: Border.all(
                color: selectedIndex == index
                    ? const Color(0x61000000)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
          ),
        );
      }),
    );
  }
}
