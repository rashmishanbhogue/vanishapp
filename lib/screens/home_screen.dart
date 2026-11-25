// home_screen.dart

import 'package:flutter/material.dart';

import '../models/paper_theme.dart';
import '../utils/app_constants.dart';
import '../widgets/paper_surface.dart';
import '../widgets/paper_toolbar.dart';
import '../widgets/rich_text_editor.dart';
import '../widgets/word_count.dart';
import '../widgets/vanish_button.dart';

import '../animations/paper_flutter_animation.dart';
import '../animations/burn_animation.dart';
import '../animations/gone_animation.dart';
import '../animations/let_go_animation.dart';
import '../animations/throw_animation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final RichTextEditorController editorController = RichTextEditorController();

  final FocusNode editorFocusNode = FocusNode();

  int selectedColourIndex = 0;
  int phraseIndex = 0;

  String? activeAnimation;

  bool get isVanishing => activeAnimation != null;

  int get wordCount {
    final text = editorController.text.trim();

    if (text.isEmpty) return 0;

    return text.split(RegExp(r'\s+')).length;
  }

  PaperTheme get selectedPaperTheme =>
      AppConstants.paperThemes[selectedColourIndex];

  @override
  void initState() {
    super.initState();
    editorController.addListener(handleEditorUpdate);
  }

  void handleEditorUpdate() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    editorController.removeListener(handleEditorUpdate);
    editorController.dispose();
    editorFocusNode.dispose();
    super.dispose();
  }

  void changeColour(int index) {
    if (isVanishing) return;

    setState(() {
      selectedColourIndex = index;
    });
  }

  void applyFormat(TextFormat format) {
    if (isVanishing) return;

    editorController.toggleFormat(format);
    editorFocusNode.requestFocus();
  }

  void vanish() {
    if (wordCount == 0 || isVanishing) return;

    final currentPhrase = AppConstants.vanishPhrases[phraseIndex];

    FocusScope.of(context).unfocus();

    setState(() {
      activeAnimation = currentPhrase;
    });
  }

  void onVanishCompleted() {
    if (!mounted) return;

    setState(() {
      editorController.clear();
      activeAnimation = null;
      phraseIndex = (phraseIndex + 1) % AppConstants.vanishPhrases.length;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      editorFocusNode.requestFocus();
    });
  }

  Widget buildAnimatedPaper(Widget paper) {
    if (activeAnimation == null) {
      return PaperFlutterAnimation(child: paper);
    }

    switch (activeAnimation) {
      case 'let it go':
        return LetGoAnimation(
          key: const ValueKey('letGo'),
          text: editorController.text,
          onCompleted: onVanishCompleted,
          child: paper,
        );

      case 'throw it away':
        return ThrowAnimation(
          key: const ValueKey('throw'),
          onCompleted: onVanishCompleted,
          child: paper,
        );

      case 'burn it':
        return BurnAnimation(
          key: const ValueKey('burn'),
          onCompleted: onVanishCompleted,
          child: paper,
        );

      case 'gone.':
        return GoneAnimation(
          key: const ValueKey('gone'),
          onCompleted: onVanishCompleted,
          child: paper,
        );

      default:
        return paper;
    }
  }

  @override
  Widget build(BuildContext context) {
    final paper = PaperSurface(
      color: selectedPaperTheme.colour,
      child: Column(
        children: [
          PaperToolbar(
            controller: editorController,
            themes: AppConstants.paperThemes,
            selectedColourIndex: selectedColourIndex,
            onColourChanged: changeColour,
            onFormat: applyFormat,
            enabled: !isVanishing,
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: RichTextEditor(
                controller: editorController,
                focusNode: editorFocusNode,
                enabled: !isVanishing,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.75,
                  color: activeAnimation == 'let it go'
                      ? Colors.transparent
                      : AppConstants.paperText,
                ),
                decoration: const InputDecoration(
                  hintText: "write anything. it won't last.",
                  hintStyle: TextStyle(
                    color: AppConstants.paperHint,
                    fontStyle: FontStyle.italic,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                WordCount(count: wordCount),

                VanishButton(
                  phrase: AppConstants.vanishPhrases[phraseIndex],
                  enabled: wordCount > 0 && !isVanishing,
                  onPressed: vanish,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AppConstants.appBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardHeight =
                constraints.maxHeight < AppConstants.paperMaxHeight
                ? constraints.maxHeight
                : AppConstants.paperMaxHeight;

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppConstants.paperMaxWidth,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: cardHeight,
                    child: buildAnimatedPaper(paper),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
