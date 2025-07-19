import 'package:flutter/material.dart';

class MessageHelper {
  static void show(BuildContext context, String message) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
