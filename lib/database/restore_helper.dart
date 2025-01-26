import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:steno_dictionary/common_methods.dart';
import 'package:steno_dictionary/database/backup_helper.dart';
import 'package:steno_dictionary/database/database_helper.dart';

class MutableBool {
  bool value;

  MutableBool(this.value);
}

class RestoreHelper {
  static final RestoreHelper backupHelperInstance =
      RestoreHelper._privateConstructor();

  RestoreHelper._privateConstructor();

  final dbHelper = DatabaseHelper.instance;

  Future<String> restoreHiveData(BuildContext context) async {
    MutableBool dbOpResult = MutableBool(false);

    try {
      bool hasPermissions = await requestStoragePermission();
      if (!hasPermissions) {
        return "Storage permission denied";
      }

      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        return "Please choose the folder where you previously saved your backup data";
      }

      // find .json file in the selected directory
      final Directory dataDirectory = Directory(selectedDirectory);
      final List<FileSystemEntity> allFiles = dataDirectory.listSync();
      List<File> jsonFiles = [];

      for (var file in allFiles) {
        if (file is File && file.path.endsWith('.json')) {
          jsonFiles.add(file); // Add the .json file to the list
        }
      }

      if (jsonFiles.isEmpty) {
        return 'No data found. You either didn\'t back up your data or selected the wrong folder.';
      } else if (jsonFiles.length == 1) {
        try {
          // Read the content of the JSON file
          String jsonContent = await jsonFiles[0].readAsString();

          jsonContent = jsonContent.trim();
          if ((jsonContent.startsWith('"') && jsonContent.endsWith('"')) ||
              (jsonContent.startsWith("'") && jsonContent.endsWith("'"))) {
            jsonContent = jsonContent.substring(1, jsonContent.length - 1);
          }
          jsonContent = jsonContent.replaceAll(r'\"', '"');

          final Map<String, dynamic> decodedJson = jsonDecode(jsonContent);

          final box = await dbHelper.openBox();

          // Step 1: Get the existing data texts
          final Set<String> existingTexts = box.values
              .whereType<Map<String, dynamic>>()
              .map((entry) => entry['text'] as String)
              .toSet();

          // Step 2: Restore only new data
          for (final key in decodedJson.keys.toList()
            ..sort((a, b) => int.parse(a).compareTo(int.parse(b)))) {
            final dynamic value = decodedJson[key];

            if (value is Map<String, dynamic>) {
              final String text = value['text'] ?? '';

              // Check if the text already exists in the Hive box
              final bool isDuplicate = await dbHelper.isTextAlreadyInBox(text);

              if (!isDuplicate) {
                await box.add(value); // Add only unique entries to the Hive box
              } else {
                print("Duplicate entry skipped: $text");
              }
            }
          }


          // for (final key in decodedJson.keys.toList()
          //   ..sort((a, b) => int.parse(a).compareTo(int.parse(b)))) {
          //   final dynamic value = decodedJson[key];
          //   if (value is Map<String, dynamic>) {
          //     final String text = value['text'] ?? '';
          //     if (!existingTexts.contains(text)) {
          //       await box.add(value); // Add only new entries to the Hive box
          //     }
          //   }
          // }

          //
          // for (final key in decodedJson.keys.toList()
          //   ..sort((a, b) => int.parse(a).compareTo(int.parse(b)))) {
          //   final dynamic value =
          //       decodedJson[key]; // Extract the JSON object for the current key
          //   if (value is Map<String, dynamic>) {
          //     // Add only the JSON object (nested map) to the Hive box
          //     await box.add(value);
          //   }
          // }

          bool result = await restoreImages(dbOpResult, selectedDirectory);

          if (result) {
            return 'Data successfully restored from backup.';
          } else {
            return 'Data restoration partially completed.';
          }
        } catch (e) {
          return 'Failed to restore data. Error: $e';
        }
      } else if (jsonFiles.length > 1) {}

      await dbHelper.openBox();
      return 'Data restored successfully';
    } catch (e) {
      return 'Data restoration failed';
    }
  }

  Future<bool> restoreImages(
      MutableBool dbOpResult, String selectedDirectory) async {
    try {
      // get the backup data directory
      final Directory dataDirectory = Directory(selectedDirectory);
      final List<FileSystemEntity> allFiles = dataDirectory.listSync();

      // get the core data directory
      final Directory coreImgDirectory =
          Directory(await getImagesStoragePath());

      if (coreImgDirectory.existsSync()) {
        // coreImgDirectory.createSync(recursive: true);
        for (var file in allFiles) {
          if (file is File && file.path.endsWith('.png')) {
            final String fileName =
                file.uri.pathSegments.last; // Extract the file name
            final String destinationPath =
                '${coreImgDirectory.path}/$fileName'; // Construct the destination path
            await file.copy(destinationPath);
          }
        }
      } else {
        return dbOpResult.value = false;
      }

      return dbOpResult.value = true;
    } catch (e) {
      return dbOpResult.value = false;
    }
  }
}
