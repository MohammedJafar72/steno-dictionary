import 'package:hive/hive.dart';

class MutableBool {
  bool value;
  MutableBool(this.value);
}

class DeletionHelper {
  Future<void> deleteAllData(Box sdData) async {
    await sdData.clear();
  }
}
