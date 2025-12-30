import 'dart:convert';
import 'dart:io';

import 'package:mylifegame/core/errors.dart';
import 'package:mylifegame/core/get_file_path.dart';


/// Persistencia best-effort sin plugins.
/// - En desktop funciona perfecto.
/// - En mobile, la ruta puede variar según entorno.
/// Si luego permites plugins, sustituyes esta clase por una que use path_provider.
class JsonStore {
  JsonStore({required this.fileName});

  final String fileName;

Future<File> _file() async {
  final path = await getFilePath(fileName);
  final f = File(path);
  if (!f.existsSync()) {
    f.createSync(recursive: true);
    f.writeAsStringSync(jsonEncode({}));
  }
  return f;
}

  Future<Map<String, dynamic>> read() async {
    try {
      final f = await _file();
      final raw = await f.readAsString();
      if (raw.trim().isEmpty) return {};
      return (jsonDecode(raw) as Map).cast<String, dynamic>();
    } catch (e) {
      throw AppError('No se pudo leer JsonStore', cause: e);
    }
  }

  Future<void> write(Map<String, dynamic> json) async {
    try {
      final f = await _file();
      await f.writeAsString(jsonEncode(json));
    } catch (e) {
      throw AppError('No se pudo escribir JsonStore', cause: e);
    }
  }
}