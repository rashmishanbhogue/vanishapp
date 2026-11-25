// word_count.dart

import 'package:flutter/material.dart';

class WordCount extends StatelessWidget {
  final int count;

  const WordCount({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$count ${count == 1 ? 'word' : 'words'}',
      style: const TextStyle(fontSize: 11, color: Color(0x42000000)),
    );
  }
}
