import 'package:uuid/uuid.dart';

String randomId() {
  var uuid = const Uuid();
  return uuid.v4();
}
