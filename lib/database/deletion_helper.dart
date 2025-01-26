import 'dart:io';

import 'package:hive/hive.dart';
import 'package:steno_dictionary/common_methods.dart';
import 'package:steno_dictionary/database/database_helper.dart';

class DeletionHelper {
  static final DeletionHelper deletionHelperInstance = DeletionHelper._privateConstructor();
  DeletionHelper._privateConstructor();
  final dbHelper = DatabaseHelper.instance;

  Future<String> deleteAllData() async {
    try {
      String isDataDeleted = await dbHelper.clearBox();
      bool isImgsDeleted = await deleteAllImages();

      if (isDataDeleted == 'Data deleted successfully' && isImgsDeleted) {
        return 'Data deleted successfully';
      } else if (isDataDeleted == 'There is no data present') {
        return isDataDeleted;
      } else {
        return 'Data partially deleted';
      }
    } catch (e) {
      return 'Something went wrong while deleting data \n $e';
    }
  }

  Future<bool> deleteAllImages() async {
    try {
      String imagesStoragePath = await getImagesStoragePath();

      final Directory imgsDirectory = Directory(imagesStoragePath);
      final List<FileSystemEntity> imgFiles = imgsDirectory.listSync();

      for (FileSystemEntity img in imgFiles) {
        img.delete();
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
