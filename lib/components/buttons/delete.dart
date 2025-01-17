import 'package:ajedrez/components/communications/api.dart';
import 'package:flutter/material.dart';
import '../visual/screen_size.dart';

TextButton deleteButton(BuildContext context, String text, bool exit) {
  return TextButton(
    onPressed: () {
      if (exit) {
        apiDeleteUser();
        Navigator.pop(context);
      }
      Navigator.pop(context);
    },
    child: Container(
      width: defaultWidth * 0.15,
      padding: const EdgeInsets.symmetric(vertical: 12.5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    ),
  );
}
