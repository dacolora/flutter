import 'dart:convert';
import 'dart:io';

import '../../core/errors.dart';

/// Persistencia best-effort sin plugins.
/// - En desktop funciona perfecto.
/// - En mobile, la ruta puede variar según entorno.
/// Si luego permites plugins, sustituyes esta clase por una que use path_provider.
class JsonStore {
  JsonStore({required this.fileName});

  final String fileName;

  Future<File> _file() async {
    // Best-effort directories:
    // 1) Directory.current (desktop/dev)
    // 2) systemTemp (fallback)
    final base = Directory.current.existsSync() ? Directory.current : Directory.systemTemp;
    final f = File('${base.path}/$fileName');
    if (!f.existsSync()) {
      f.createSync(recursive: true);
      f.writeAsStringSync(jsonEncode({}));
    }
    return f;
    // ⚠️ Si quieres persistencia “real” en mobile, aquí irá:
    // final dir = await getApplicationDocumentsDirectory(); // (plugin)
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