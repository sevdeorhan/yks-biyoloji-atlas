import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/errors/exceptions.dart';

class HiveDataSource {
  static const String _progressBox = 'progress';
  static const String _settingsBox = 'settings';

  Future<void> init() async {
    await Hive.openBox(_progressBox);
    await Hive.openBox(_settingsBox);
  }

  Future<void> saveProgress(String key, Map<String, dynamic> data) async {
    try {
      final box = Hive.box(_progressBox);
      await box.put(key, data);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<Map<String, dynamic>?> getProgress(String key) async {
    try {
      final box = Hive.box(_progressBox);
      final data = box.get(key);
      return data != null ? Map<String, dynamic>.from(data) : null;
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<void> saveSetting(String key, dynamic value) async {
    try {
      final box = Hive.box(_settingsBox);
      await box.put(key, value);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  dynamic getSetting(String key, {dynamic defaultValue}) {
    final box = Hive.box(_settingsBox);
    return box.get(key, defaultValue: defaultValue);
  }
}
