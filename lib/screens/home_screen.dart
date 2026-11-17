// home_screen.dart

import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final TextEditingController editorController = TextEditingController();
  final FocusNode editorFocusNode = FocusNode();

  final List<Map<String, dynamic>> paperColours = [
    {
      'name': 'yellow',
      'colour': const Color(0xFFFEF9C3),
      'dot': const Color(0xFFFEF08A),
    },
    {
      'name': 'pink',
      'colour': const Color(0xFFFCE7F3),
      'dot': const Color(0xFFFBCFE8),
    },
    {
      'name': 'green',
      'colour': const Color(0xFFDCFCE7),
      'dot': const Color(0xFFBBF7D0),
    },
    {
      'name': 'blue',
      'colour': const Color(0xFFDBEAFE),
      'dot': const Color(0xFFBFDBFE),
    },
    {
      'name': 'cream',
      'colour': const Color(0xFFFAF8F5),
      'dot': const Color(0xFFE8E0D0),
    },
  ];

  final List<String> vanishPhrases = [
    'let it go',
    'throw it away',
    'burn it',
    'gone.',
  ];

  int selectedColourIndex = 0;
  int phraseIndex = 0;

  int get wordCount {
    final text = editorController.text.trim();

    if (text.isEmpty) return 0;

    return text.split(RegExp(r'\s+')).length;
  }

  @override
  void dispose() {
    editorController.dispose();
    editorFocusNode.dispose();
    super.dispose();
  }

  void changeColour(int index) {
    setState(() {
      selectedColourIndex = index;
    });
  }

  void vanish() {
    if (wordCount == 0) return;

    // animation implementation -- later
    setState(() {
      editorController.clear();
      phraseIndex = (phraseIndex + 1) % vanishPhrases.length;
    });

    editorFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final paperColour = paperColours[selectedColourIndex]['colour'] as Color;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            decoration: BoxDecoration(
              color: paperColour,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // toolbar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: Row(
                    children: [
                      // close indicator
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF5F57),
                          shape: BoxShape.circle,
                        ),
                      ),

                      const SizedBox(width: 6),

                      // minimise indicator
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFBD2E),
                          shape: BoxShape.circle,
                        ),
                      ),

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

                      // formatting placeholders
                      formatButton('B', FontWeight.bold),
                      const SizedBox(width: 4),
                      formatButton('I', FontStyle.italic),
                      const SizedBox(width: 4),
                      formatButton('U', TextDecoration.underline),
                      const SizedBox(width: 8),

                      // colour palette
                      Row(
                        children: List.generate(paperColours.length, (index) {
                          final colour = paperColours[index]['dot'] as Color;

                          return GestureDetector(
                            onTap: () => changeColour(index),
                            child: Container(
                              margin: const EdgeInsets.only(left: 5),
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                color: colour,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selectedColourIndex == index
                                      ? const Color(0x61000000)
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                // writing area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                    child: TextField(
                      controller: editorController,
                      focusNode: editorFocusNode,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      keyboardType: TextInputType.multiline,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.75,
                        color: Color(0xB8000000),
                      ),
                      decoration: const InputDecoration(
                        hintText: "write anything. it won't last.",
                        hintStyle: TextStyle(
                          color: Color(0x38000000),
                          fontStyle: FontStyle.italic,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (_) {
                        setState(() {});
                      },
                    ),
                  ),
                ),

                // bottom bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$wordCount ${wordCount == 1 ? 'word' : 'words'}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0x42000000),
                        ),
                      ),

                      ElevatedButton(
                        onPressed: wordCount == 0 ? null : vanish,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0x12000000),
                          foregroundColor: const Color(0x73000000),
                          disabledBackgroundColor: const Color(0x08000000),
                          disabledForegroundColor: const Color(0x38000000),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          vanishPhrases[phraseIndex],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget formatButton(String label, dynamic style) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0x0F000000),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: const Color(0x6B000000),
          fontWeight: style is FontWeight ? style : FontWeight.normal,
          fontStyle: style is FontStyle ? style : FontStyle.normal,
          decoration: style is TextDecoration ? style : TextDecoration.none,
        ),
      ),
    );
  }
}
