import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
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

  Future<String> backupHiveData(context) async {
    MutableBool dbOpResult = MutableBool(false);

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

      final jsonString = jsonEncode(hiveData.map((key, value) => MapEntry(
            key.toString(),
            {
              "text": value['text'],
              "imagePath": value['imagePath'],
            },
          )));
      final File jsonFile = File('$selectedDirectory/Data_Backup.txt');
      if (await jsonFile.exists()) {
        await jsonFile.writeAsString(jsonString, mode: FileMode.append);
      } else {
        await jsonFile.writeAsString(jsonEncode(jsonString));
      }

      // backup images
      await backupImages(selectedDirectory, dbOpResult);

      if (dbOpResult.value == true) {
        return 'Backup Done successfully';
      } else {
        return 'Images didn\'t got backed up';
      }
    } catch (e) {
      return 'Backup failed due to this reason \n $e';
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
