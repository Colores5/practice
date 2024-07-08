import 'package:diary/entity/file_picked.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:diary/diary_page/diary_page.dart';
import 'package:diary/entity/meeting.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(MettingAdapter());
  Hive.registerAdapter(FilePickedAdapter());

  await Hive.openBox('mybox');

  const app = App();
  runApp(app);
}
