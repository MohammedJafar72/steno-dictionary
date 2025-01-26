import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void showSnackBar(BuildContext context, String? text) {
  text = text != '' ? text : "No picture found. Try capturing one using camera.";
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text!),
      duration: const Duration(seconds: 4),
    ),
  );
}

Future<bool?> showConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Confirmation",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "Are you sure you want to clear the image?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                  ),
                  child: const Text(
                    "No",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  child: const Text(
                    "Yes",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Future<Object?> openCamera(BuildContext context) async {
  // Navigate to the camera screen
  final capturedImagePath = await Navigator.pushNamed(context, '/takePicture');

  return capturedImagePath;
}

Future<bool> requestStoragePermission() async {
  if (await Permission.manageExternalStorage.isGranted) {
    return true;
  } else {
    await Permission.manageExternalStorage.request();
    return await Permission.manageExternalStorage.isGranted;
  }
}

Future<String> getImagesStoragePath() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final imageStoringPath = "${directory.parent.path}/images";
    await Directory(imageStoringPath).create(recursive: true);

    return imageStoringPath;
  } catch (e) {
    return 'Image storage path not found \n $e';
  }
}
