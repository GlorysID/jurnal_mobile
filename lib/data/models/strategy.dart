import 'package:isar/isar.dart';

part 'strategy.g.dart';

@collection
class Strategy {
  Id id = Isar.autoIncrement;

  @Index()
  late int userId;

  late String name;
  String? description;
}
