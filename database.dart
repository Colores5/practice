import 'package:diary/diary_page/diary_page.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:diary/entity/meeting.dart';

class DiaryDataBase {
  Map<Meeting, FilePicked> noteControllers = {};
  List<Meeting> source = <Meeting>[];

  final _mybox = Hive.box('mybox');

  void createInitialData() {
    source = [
      Meeting(
        'Пример',
        DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          TimeOfDay.now().hour,
          TimeOfDay.now().minute,
        ),
        DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          TimeOfDay.now().hour + 1,
          TimeOfDay.now().minute + 30,
        ),
        1,
        false,
      )
    ];
  }

  void loadData() async {
    final box = _mybox.get('DIARY', defaultValue: <dynamic>[]);

    if (box != null) {
      source = box.cast<Meeting>();
    }
  }

  void upgradeData() {
    _mybox.put('DIARY', source);
  }
}
