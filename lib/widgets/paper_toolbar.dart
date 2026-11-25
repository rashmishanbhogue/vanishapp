// paper_toolbar.dart

import 'package:flutter/material.dart';

import '../models/paper_theme.dart';
import 'colour_palette.dart';
import 'rich_text_editor.dart';

class PaperToolbar extends StatelessWidget {
  final RichTextEditorController controller;
  final List<PaperTheme> themes;
  final int selectedColourIndex;
  final ValueChanged<int> onColourChanged;
  final ValueChanged<TextFormat> onFormat;
  final bool enabled;

  const PaperToolbar({
    super.key,
    required this.controller,
    required this.themes,
    required this.selectedColourIndex,
    required this.onColourChanged,
    required this.onFormat,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: [
          const Expanded(
            child: Center(
              child: Text(
                'vanish',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                  color: Color(0x4D000000),
                ),
              ),
            ),
          ),
          formatButton('B', TextFormat.bold),
          const SizedBox(width: 4),
          formatButton('I', TextFormat.italic),
          const SizedBox(width: 4),
          formatButton('U', TextFormat.underline),
          const SizedBox(width: 8),
          ColourPalette(
            themes: themes,
            selectedIndex: selectedColourIndex,
            onSelected: onColourChanged,
            enabled: enabled,
          ),
        ],
      ),
    );
  }

  Widget formatButton(String label, TextFormat format) {
    final isActive = controller.isFormatActive(format);

    return GestureDetector(
      onTap: enabled ? () => onFormat(format) : null,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isActive ? const Color(0x26000000) : const Color(0x0F000000),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? const Color(0x42000000) : Colors.transparent,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: const Color(0x6B000000),
            fontWeight: format == TextFormat.bold
                ? FontWeight.bold
                : FontWeight.normal,
            fontStyle: format == TextFormat.italic
                ? FontStyle.italic
                : FontStyle.normal,
            decoration: format == TextFormat.underline
                ? TextDecoration.underline
                : TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
