import 'package:uuid/uuid.dart';

class Id {
  static const _uuid = Uuid();

  static String newId(){
    return _uuid.v4();
  }
}