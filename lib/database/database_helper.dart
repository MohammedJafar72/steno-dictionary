import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import '../common_methods.dart';

// Wrapper class for mutable reference
class MutableBool {
  bool value;
  MutableBool(this.value);
}

class DatabaseHelper {
  // Singleton implementation
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  DatabaseHelper._privateConstructor();

  // Hive box instance
  Box? _box;

  /// Opens the Hive box if not already opened
  Future<Box> openBox() async {
    _box ??= await Hive.openBox('sdData');
    return _box!;
  }

  Future<bool?> saveImage(context, capturedImagePath, txtEditingController) async {
    // final directory = await getApplicationDocumentsDirectory();
    // final imageStoringPath = "${directory.parent.path}/images";
    final String imageStoringPath = await getImagesStoragePath();
    final File imageFilePath = File(capturedImagePath!);
    MutableBool dbOpResult = MutableBool(false);

    try {
      
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
      final String newText = txtEditingController.text;

      // Check for duplicates
      final bool isDuplicate = await isTextAlreadyInBox(newText);

      if (isDuplicate) {
        showSnackBar(context, "This text already exists in the dictionary");
        return;
      }

      await dataBox.add({
        'text': newText,
        'imagePath': newImagePath,
      });

      dbOpResult.value = true;
    } catch (e) {
      dbOpResult.value = false;
      showSnackBar(context, "Data is not saved in Database. \n $e");
    }
  }

  Map<dynamic, dynamic> getAllData(BuildContext context) {
    openBox();
    if (_box == null) {
      showSnackBar(context, "Unable to access data.");
    }
    return _box!.toMap();
  }

  Future<String> clearBox() async {
    try {
      // check that the _box variable has data inside it or not
      if (_box == null) await openBox();

      // check that the box has entries or not?
      if (_box!.isEmpty) {
        return 'There is no data present';
      }

      await _box!.clear();
      return 'Data deleted successfully';
    } catch (e) {
      return 'There was a problem while deleting your data';
    }
  }

  /// Checks if a given text already exists in the Hive box.
  ///
  /// Returns `true` if the text exists, `false` otherwise.
  Future<bool> isTextAlreadyInBox(String textToCheck) async {
    try {
      final Box dataBox = Hive.box('sdData');
      // Check if any entry in the box has the same 'text'
      return dataBox.values
          .whereType<Map<String, dynamic>>()
          .any((entry) => entry['text'] == textToCheck);
    } catch (e) {
      // Handle errors gracefully
      print("Error while checking for duplicate text: $e");
      return false;
    }
  }

}
