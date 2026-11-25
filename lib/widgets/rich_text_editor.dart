// rich_text_editor.dart

import 'package:flutter/material.dart';

enum TextFormat { bold, italic, underline }

class RichTextEditorController extends TextEditingController {
  RichTextEditorController({String? initialText}) : super(text: initialText) {
    characterStyles = List<TextStyle>.filled(text.length, const TextStyle());

    previousText = text;
    addListener(handleValueChange);
  }

  late List<TextStyle> characterStyles;
  late String previousText;

  TextStyle typingStyle = const TextStyle();

  void handleValueChange() {
    if (text == previousText) return;

    final oldText = previousText;
    final newText = text;
    final oldStyles = characterStyles;

    int prefixLength = 0;

    while (prefixLength < oldText.length &&
        prefixLength < newText.length &&
        oldText[prefixLength] == newText[prefixLength]) {
      prefixLength++;
    }

    int suffixLength = 0;

    while (suffixLength < oldText.length - prefixLength &&
        suffixLength < newText.length - prefixLength &&
        oldText[oldText.length - 1 - suffixLength] ==
            newText[newText.length - 1 - suffixLength]) {
      suffixLength++;
    }

    final updatedStyles = List<TextStyle>.filled(
      newText.length,
      const TextStyle(),
    );

    // Preserve formatting before the edited section.
    for (int index = 0; index < prefixLength; index++) {
      if (index < oldStyles.length) {
        updatedStyles[index] = oldStyles[index];
      }
    }

    // Apply the current typing style to newly inserted characters.
    final insertedEnd = newText.length - suffixLength;

    for (int index = prefixLength; index < insertedEnd; index++) {
      updatedStyles[index] = typingStyle;
    }

    // Preserve formatting after the edited section.
    for (int index = 0; index < suffixLength; index++) {
      final oldIndex = oldText.length - suffixLength + index;
      final newIndex = newText.length - suffixLength + index;

      if (oldIndex < oldStyles.length) {
        updatedStyles[newIndex] = oldStyles[oldIndex];
      }
    }

    characterStyles = updatedStyles;
    previousText = newText;
  }

  void toggleFormat(TextFormat format) {
    final currentSelection = selection;

    final isActive = isFormatActive(format);
    final enableFormat = !isActive;

    // Toggle the typing style as well.
    switch (format) {
      case TextFormat.bold:
        typingStyle = typingStyle.copyWith(
          fontWeight: enableFormat ? FontWeight.bold : FontWeight.normal,
        );
        break;

      case TextFormat.italic:
        typingStyle = typingStyle.copyWith(
          fontStyle: enableFormat ? FontStyle.italic : FontStyle.normal,
        );
        break;

      case TextFormat.underline:
        typingStyle = typingStyle.copyWith(
          decoration: enableFormat
              ? TextDecoration.underline
              : TextDecoration.none,
        );
        break;
    }

    // If there is selected text, format that selection too.
    if (currentSelection.isValid && !currentSelection.isCollapsed) {
      final start = currentSelection.start.clamp(0, text.length);
      final end = currentSelection.end.clamp(0, text.length);

      for (int index = start; index < end; index++) {
        final currentStyle = characterStyles[index];

        switch (format) {
          case TextFormat.bold:
            characterStyles[index] = currentStyle.copyWith(
              fontWeight: enableFormat ? FontWeight.bold : FontWeight.normal,
            );
            break;

          case TextFormat.italic:
            characterStyles[index] = currentStyle.copyWith(
              fontStyle: enableFormat ? FontStyle.italic : FontStyle.normal,
            );
            break;

          case TextFormat.underline:
            characterStyles[index] = currentStyle.copyWith(
              decoration: enableFormat
                  ? TextDecoration.underline
                  : TextDecoration.none,
            );
            break;
        }
      }
    }

    notifyListeners();
  }

  bool isFormatActive(TextFormat format) {
    final currentSelection = selection;

    // With no selection, show the current typing style.
    if (!currentSelection.isValid || currentSelection.isCollapsed) {
      return switch (format) {
        TextFormat.bold => typingStyle.fontWeight == FontWeight.bold,
        TextFormat.italic => typingStyle.fontStyle == FontStyle.italic,
        TextFormat.underline =>
          typingStyle.decoration == TextDecoration.underline,
      };
    }

    final start = currentSelection.start.clamp(0, text.length);
    final end = currentSelection.end.clamp(0, text.length);

    if (start >= end) return false;

    for (int index = start; index < end; index++) {
      final currentStyle = characterStyles[index];

      final active = switch (format) {
        TextFormat.bold => currentStyle.fontWeight == FontWeight.bold,
        TextFormat.italic => currentStyle.fontStyle == FontStyle.italic,
        TextFormat.underline =>
          currentStyle.decoration == TextDecoration.underline,
      };

      if (!active) return false;
    }

    return true;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (text.isEmpty) {
      return TextSpan(style: style, text: '');
    }

    final spans = <InlineSpan>[];
    int runStart = 0;

    while (runStart < text.length) {
      final currentStyle = characterStyles[runStart];
      int runEnd = runStart + 1;

      while (runEnd < text.length && characterStyles[runEnd] == currentStyle) {
        runEnd++;
      }

      spans.add(
        TextSpan(
          text: text.substring(runStart, runEnd),
          style: style?.merge(currentStyle) ?? currentStyle,
        ),
      );

      runStart = runEnd;
    }

    return TextSpan(children: spans, style: style);
  }

  @override
  void dispose() {
    removeListener(handleValueChange);
    super.dispose();
  }
}

class RichTextEditor extends StatelessWidget {
  final RichTextEditorController controller;
  final FocusNode focusNode;
  final bool enabled;
  final TextStyle style;
  final InputDecoration decoration;
  final ValueChanged<String>? onChanged;

  const RichTextEditor({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.style,
    required this.decoration,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      maxLines: null,
      expands: true,
      textAlignVertical: TextAlignVertical.top,
      keyboardType: TextInputType.multiline,
      style: style,
      decoration: decoration,
      onChanged: onChanged,
    );
  }
}
