import 'package:flutter/material.dart';

Future<void> showOkDialog({
  required BuildContext context,
  required String title,
  required String message,
  VoidCallback? onOkPressed,
  VoidCallback? onCancelPressed,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message, style: const TextStyle(fontSize: 16.0, color: Colors.white)),
        actions: [
          TextButton(
            style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.black45)),
            onPressed: () {
              Navigator.of(context).pop();
              if (onOkPressed != null) {
                onOkPressed();
              }
            },
            child: const Text('Okay', style: TextStyle(fontSize: 17)),
          ),
          TextButton(
            style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.black45)),
            onPressed: () {
              Navigator.of(context).pop();
              if (onCancelPressed != null) {
                onCancelPressed();
              }
            },
            child: const Text('Cancel', style: TextStyle(fontSize: 17)),
          ),
        ],
      );
    },
  );
}
