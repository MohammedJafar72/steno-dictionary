import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:steno_dictionary/common_methods.dart';
import 'package:steno_dictionary/database/database_helper.dart';

class BackupHelper {
  static final BackupHelper backupHelperInstance = BackupHelper._privateConstructor();
  BackupHelper._privateConstructor();

  final dbHelper = DatabaseHelper.instance;

  Future<String> backupData(context) async {
    try {
      bool hasPermissions = await requestStoragePermission();
      if (!hasPermissions) {
        return "Storage permission denied";
      }

      // open directory selector
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        return "Please select a directory to backup";
      }

      // get all data and Convert the list of data to a JSON string
      await dbHelper.openBox();
      final Map<dynamic, dynamic> hiveData = dbHelper.getAllData(context);
      if (hiveData.isEmpty) {
        return "No data available to backup";
      }
      //final String jsonString = jsonEncode(hiveData);
      final jsonString = jsonEncode(hiveData.map((key, value) => MapEntry(
            key.toString(),
            {
              "text": value['text'],
              "imagePath": value['imagePath'],
            },
          )));
      final File jsonFile = File('$selectedDirectory/Data_Backup.json');
      await jsonFile.writeAsString(jsonEncode(jsonString));

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
      return 'Backup failed due to some reason \n $e';
    }
  }
}
