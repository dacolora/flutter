import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LocalStorage {
  final String fileName;

  LocalStorage(this.fileName);

  static Future<LocalStorage> create({String fileName = 'local_storage.json'}) async {
    return LocalStorage(fileName);
  }

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName');
  }

  Future<Map<String, dynamic>?> read(String key) async {
    try {
      final file = await _getFile();
      if (!file.existsSync()) {
        return null;
      }
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      return data[key] as Map<String, dynamic>?;
    } catch (e) {
      print('Error leyendo el archivo: $e');
      return null;
    }
  }

  Future<void> write(String key, dynamic value) async {
    try {
      final file = await _getFile();
      Map<String, dynamic> data = {};
      if (file.existsSync()) {
        final content = await file.readAsString();
        data = jsonDecode(content) as Map<String, dynamic>;
      }
      data[key] = value;
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      print('Error escribiendo en el archivo: $e');
    }
  }

  Future<void> clear() async {
    try {
      final file = await _getFile();
      if (file.existsSync()) {
        await file.writeAsString(jsonEncode({})); // Limpia el archivo
      }
    } catch (e) {
      print('Error limpiando el archivo: $e');
    }
  }
}