import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:steno_dictionary/common_methods.dart';
import 'package:steno_dictionary/database/database_helper.dart';

class MutableBool {
  bool value;
  MutableBool(this.value);
}

class BackupHelper {
  static final BackupHelper backupHelperInstance = BackupHelper._privateConstructor();
  BackupHelper._privateConstructor();

  final dbHelper = DatabaseHelper.instance;

  Future<String> backupHiveData(BuildContext context) async {
    MutableBool dbOpResult = MutableBool(false);

    try {
      // Request storage permission
      bool hasPermissions = await requestStoragePermission();
      if (!hasPermissions) {
        return "Storage permission denied";
      }

      // Open directory selector
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        return "Please select a directory to backup";
      }

      // Get all data from Hive
      await dbHelper.openBox();
      final Map<dynamic, dynamic> hiveData = dbHelper.getAllData(context);
      if (hiveData.isEmpty) {
        return "No data available to backup";
      }

      // Prepare Hive data for JSON serialization
      final Map<String, dynamic> newData = hiveData.map((key, value) => MapEntry(
        key.toString(),
        {
          "text": value['text'],
          "imagePath": value['imagePath'],
        },
      ));

      // Define the backup file path
      final String backupFilePath = '$selectedDirectory/Data_Backup.json';
      final File jsonFile = File(backupFilePath);

      // Handle existing file
      Map<String, dynamic> mergedData = {};

      if (await jsonFile.exists()) {
        final String existingContent = await jsonFile.readAsString();
        if (existingContent.isNotEmpty) {
          try {
            // Parse the existing content
            final Map<String, dynamic> existingData = jsonDecode(existingContent) as Map<String, dynamic>;
            mergedData = {...existingData};
          } catch (e) {
            // If the file contains invalid JSON, overwrite it
            print("Invalid JSON in backup file. Overwriting...");
          }
        }
      }

      // Merge new data into the existing data
      newData.forEach((key, value) {
        mergedData[key] = value; // Add or overwrite
      });

      // Write merged data back to the file
      await jsonFile.writeAsString(jsonEncode(mergedData));

      // Backup images
      bool result = await backupImages(selectedDirectory, dbOpResult);

      if (result) {
        return 'Backup completed successfully.';
      } else {
        return 'Data backup partially completed.';
      }
    } catch (e) {
      return 'Backup failed due to this reason: \n $e';
    }
  }

  Future<bool> backupImages(String selectedDirectory, MutableBool dbOpResult) async {
    try {
      final String imageStoragePath = await getImagesStoragePath();
      final Directory imagesDirectory = Directory(imageStoragePath);
      if (!imagesDirectory.existsSync()) {
        return dbOpResult.value = false;
      }

      final List<FileSystemEntity> imageFiles = imagesDirectory.listSync();
      for (final file in imageFiles) {
        if (file is File) {
          final String imageName = file.uri.pathSegments.last;
          await file.copy('$selectedDirectory/$imageName');
        }
      }

      return dbOpResult.value = true;
    } catch (e) {
      return dbOpResult.value = false;
    }
  }
}
