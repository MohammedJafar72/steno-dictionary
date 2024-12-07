import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../common_methods.dart';

// Wrapper class for mutable reference
class MutableBool {
  bool value;
  MutableBool(this.value);
}

Future<bool?> saveImage(context, capturedImagePath, txtEditingController) async {
  final directory = await getApplicationDocumentsDirectory();
  final imageStoringPath = "${directory.parent.path}/images";
  final File imageFilePath = File(capturedImagePath!);
  MutableBool dbOpResult = MutableBool(false);

  try {
    await Directory(imageStoringPath).create(recursive: true);
    final String newImagePath = '$imageStoringPath/${txtEditingController.text}.png';
    await imageFilePath.copy(newImagePath);

    // Pass dbOpResult to the saveDataInBox method to modify its value
    await saveDataInBox(context, newImagePath, txtEditingController, dbOpResult);

    return dbOpResult.value; // Return the updated value
  } catch (e) {
    showSnackBar(context, "There is an error saving your image. \n $e");
    return dbOpResult.value; // Return the default/failure value
  }
}

Future<void> saveDataInBox(
  BuildContext context,
  String newImagePath,
  TextEditingController txtEditingController,
  MutableBool dbOpResult,
) async {
  try {
    final Box dataBox = Hive.box('sdData');
    await dataBox.add({
      'text': txtEditingController.text,
      'imagePath': newImagePath,
    });

    dbOpResult.value = true;
  } catch (e) {
    dbOpResult.value = false; // Indicate failure
    showSnackBar(context, "Data is not saved in Database. \n $e");
  }
}

Future<void> deleteAllData(Box sdData) async {
  await sdData.clear();
}

// final Box sdDataBox = Hive.box('sdData');
  // var entries = sdDataBox.values.toList();
  //
  // if (entries.isNotEmpty) {
  //   for (var entry in entries) {
  //     print('Text: ${entry['text']}, Image Path: ${entry['imagePath']}');
  //   }
  // } else {
  //   print('No entries found in sdData box.');
  // }