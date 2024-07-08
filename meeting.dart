import 'package:hive/hive.dart';

part 'meeting.g.dart';

@HiveType(typeId: 0, adapterName: "MettingAdapter")
class Meeting extends HiveObject {
  @HiveField(0)
  String eventName;

  @HiveField(1)
  DateTime from;

  @HiveField(2)
  DateTime to;

  @HiveField(3)
  int background;

  @HiveField(4)
  bool isAllDay;

  Meeting(
    this.eventName,
    this.from,
    this.to,
    this.background,
    this.isAllDay,
  );
}
