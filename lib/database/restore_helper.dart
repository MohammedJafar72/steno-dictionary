import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:steno_dictionary/common_methods.dart';
import 'package:steno_dictionary/database/database_helper.dart';

class MutableBool {
  bool value;
  MutableBool(this.value);
}

class RestoreHelper {
  static final RestoreHelper backupHelperInstance = RestoreHelper._privateConstructor();
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
          if ((jsonContent.startsWith('"') && jsonContent.endsWith('"')) || (jsonContent.startsWith("'") && jsonContent.endsWith("'"))) {
            jsonContent = jsonContent.substring(1, jsonContent.length - 1);
          }
          jsonContent = jsonContent.replaceAll(r'\"', '"');

          final Map<String, dynamic> decodedJson = jsonDecode(jsonContent);

          final box = await Hive.openBox('sdData');
          for (final key in decodedJson.keys.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)))) {
            final dynamic value = decodedJson[key]; // Extract the JSON object for the current key
            if (value is Map<String, dynamic>) {
              // Add only the JSON object (nested map) to the Hive box
              await box.add(value);
            }
          }

          return 'Data successfully restored from backup.';
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
}
