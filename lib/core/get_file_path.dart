import 'package:path_provider/path_provider.dart';


Future<String> getFilePath(String fileName) async {
  final directory = await getApplicationDocumentsDirectory(); // Obtiene el directorio seguro
  return '${directory.path}/$fileName';
}