import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class OutlineImageFrame extends StatelessWidget {
  final String? capturedImagePath;
  final String placeholderText;

  const OutlineImageFrame({
    super.key,
    this.capturedImagePath,
    this.placeholderText = 'Click the camera icon to capture an image',
  });

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      color: Colors.white54,
      strokeWidth: 3,
      dashPattern: const [
        6
      ],
      borderType: BorderType.RRect,
      radius: const Radius.circular(5),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.width * 9 / 16,
          width: MediaQuery.of(context).size.width,
          child: capturedImagePath == null
              ? Center(
                  child: Opacity(
                    opacity: 0.5,
                    child: Text(
                      placeholderText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 17,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.file(
                    File(capturedImagePath!),
                    fit: BoxFit.cover,
                  ),
                ),
        ),
      ),
    );
  }
}
