import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:steno_dictionary/database/database_helper.dart';

class BackupHelper {
  static final BackupHelper backupHelperInstance = BackupHelper._privateConstructor();
  BackupHelper._privateConstructor();

  final dbHelper = DatabaseHelper.instance;

  Future<String> backupData(context) async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        return "Please select a directory to backup";
      }
      await dbHelper.openBox();
      final dynamic hiveData = dbHelper.getAllData(context);
      if (hiveData == null || hiveData.isEmpty) {
        return "No data available to backup.";
      }
      // Convert the list of data to a JSON string
      final String jsonString = jsonEncode(hiveData);

      final File jsonFile = File('$selectedDirectory/data backup.json');
      await jsonFile.writeAsString(jsonString);

      // Copy all images to the selected directory
      // for (final entry in hiveData.values) {
      //   final String? imagePath = entry['imagePath'];
      //   if (imagePath != null && File(imagePath).existsSync()) {
      //     final File imageFile = File(imagePath);
      //     final String imageName = imageFile.uri.pathSegments.last;
      //     await imageFile.copy('$selectedDirectory/$imageName');
      //   }
      // }

      return 'Backup Done successfully';
    } catch (e) {
      return 'Backup failed due to some reason';
    }
  }
}
