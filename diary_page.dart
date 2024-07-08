import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'package:diary/data/database.dart';
import 'package:diary/entity/meeting.dart';
import 'package:permission_handler/permission_handler.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        SfGlobalLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('ru'),
      ],
      locale: Locale('ru'),
      debugShowCheckedModeBanner: false,
      home: Diary(),
    );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return Color(appointments![index].background);
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}

class FilePicked {
  FilePicked(this.contriller, this.file);

  TextEditingController contriller;
  String file;
}

class Diary extends StatefulWidget {
  const Diary({super.key});

  @override
  State<Diary> createState() => _DiaryState();
}

class _DiaryState extends State<Diary> {
  final _mybox = Hive.box('mybox');

  final db = DiaryDataBase();

  @override
  void initState() {
    super.initState();
    final box = _mybox.get('DIARY');

    if (box == null || box.isEmpty) {
      db.createInitialData();
    } else {
      db.loadData();
    }
  }

  TimeOfDay _startTime = TimeOfDay.now();

  TimeOfDay _endTime = TimeOfDay.now();

  DateTime selectedDateCalendar = DateTime.now();

  final _eventNameController = TextEditingController();

  void _deleteMeeting(Meeting meet) {
    setState(() {
      db.source.remove(meet);
    });
    db.upgradeData();
  }

  Future<String> _pickFile(Meeting meeting) async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final file = result.files.first;
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
      final type = file.extension;
      final name = file.name;
      final byte = await file.xFile.readAsBytes();
      final newFile = await saveFile(byte.toList(), name, type ?? 'jpg');
      return newFile;
    }
    return '';
  }

  void openFile(String file) {
    OpenFile.open(file);
  }

  Future<String> saveFile(List<int> bytes, String name, String type) async {
    final appDocDir = Directory('/storage/emulated/0/Download');
    final newFile =
        File("${appDocDir.path}${Platform.pathSeparator}$name.$type");

    if (!newFile.existsSync()) {
      await newFile.create();
    }
    await newFile.writeAsBytes(bytes);
    return newFile.path;
  }

  void _saveMeeting() {
    setState(() {
      final meeting = Meeting(
        _eventNameController.text,
        DateTime(
          selectedDateCalendar.year,
          selectedDateCalendar.month,
          selectedDateCalendar.day,
          _startTime.hour,
          _startTime.minute,
        ),
        DateTime(
          selectedDateCalendar.year,
          selectedDateCalendar.month,
          selectedDateCalendar.day,
          _endTime.hour,
          _endTime.minute,
        ),
        1,
        false,
      );
      db.source.add(meeting);
      _eventNameController.clear();
      db.noteControllers[meeting] = FilePicked(TextEditingController(), '');
      Navigator.of(context).pop();
    });
    db.upgradeData();
  }

  void _addNoteForMeeting(Meeting meeting) async {
    if (!db.noteControllers.containsKey(meeting)) {
      db.noteControllers[meeting] = FilePicked(TextEditingController(), '');
    }
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        if ((db.noteControllers[meeting]?.contriller.text.isEmpty ?? true) &&
            (db.noteControllers[meeting]?.file.isEmpty ?? true)) {
          return AlertDialog(
            title: const Text('Заметка'),
            content: TextField(
              onChanged: (value) => setState(() {}),
              controller: db.noteControllers[meeting]?.contriller,
            ),
            actions: [
              ElevatedButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 109, 162, 3),
                  foregroundColor: Colors.black,
                ),
                onPressed: () async {
                  final file = await _pickFile(meeting);
                  setState(() {
                    db.noteControllers[meeting]?.file = file;
                  });
                },
                child: const Text('Выбрать файл'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 109, 162, 3),
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Записать'),
              ),
            ],
          );
        } else if ((db.noteControllers[meeting]?.contriller.text.isNotEmpty ??
                true) &&
            (db.noteControllers[meeting]?.file.isEmpty ?? true)) {
          return AlertDialog(
            title: const Text('Заметка'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(db.noteControllers[meeting]?.contriller.text ?? ''),
              ],
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 109, 162, 3),
                  foregroundColor: Colors.black,
                ),
                onPressed: () async {
                  final file = await _pickFile(meeting);
                  setState(() {
                    db.noteControllers[meeting]?.file = file;
                  });
                },
                child: const Text('Выбрать файл'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 109, 162, 3),
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Ок'),
              ),
            ],
          );
        } else {
          return AlertDialog(
            title: const Text('Заметка'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(db.noteControllers[meeting]?.contriller.text ?? ''),
              ],
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 109, 162, 3),
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  openFile(db.noteControllers[meeting]?.file ?? '');
                },
                child: const Text('Файл'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 109, 162, 3),
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Ок'),
              ),
            ],
          );
        }
      },
    );
    db.upgradeData();
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    db.noteControllers.forEach((key, filePicked) {
      filePicked.contriller.dispose();
    });
    super.dispose();
  }

  Future<void> _selectedTime(BuildContext context, StateSetter setDialogState,
      bool isStartTime) async {
    final initialTime = isStartTime ? _startTime : _endTime;
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (selectedTime != null) {
      setDialogState(() {
        if (isStartTime) {
          _startTime = selectedTime;
        } else {
          _endTime = selectedTime;
        }
      });
    }
    db.upgradeData();
  }

  Future<void> _addMeeting() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Введите данные',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _eventNameController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Название предмета'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 109, 162, 3),
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () =>
                              _selectedTime(context, setDialogState, true),
                          child: Text('Начало: ${_startTime.format(context)}'),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 109, 162, 3),
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () =>
                              _selectedTime(context, setDialogState, false),
                          child: Text('Конец: ${_endTime.format(context)}'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 109, 162, 3),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    _saveMeeting();
                  },
                  child: const Text("Ок"),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 109, 162, 3),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Отмена'),
                ),
              ],
            );
          },
        );
      },
    );
    db.upgradeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 109, 162, 3),
        title: const Text(
          'Ежедневник',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
      ),
      body: SfCalendar(
        appointmentBuilder: (context, calendarAppointmentDetails) {
          final Meeting note = calendarAppointmentDetails.appointments.first;
          return GestureDetector(
            onTap: () => _addNoteForMeeting(note),
            child: Slidable(
              endActionPane: ActionPane(
                extentRatio: 0.3,
                motion: const StretchMotion(),
                children: [
                  SlidableAction(
                    flex: 10,
                    borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    onPressed: (context) {
                      _deleteMeeting(note);
                    },
                    icon: Icons.delete,
                    backgroundColor: Colors.red.shade500,
                  ),
                ],
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 109, 162, 3),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      topLeft: Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(
                        1.0,
                        0.5,
                      ),
                      blurRadius: 1.0,
                      spreadRadius: 0.0,
                    )
                  ],
                ),
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          note.eventName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                          '${DateFormat('kk:mm').format(note.from)} - ${DateFormat('kk:mm').format(note.to)}')
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        view: CalendarView.month,
        headerStyle: const CalendarHeaderStyle(
            textAlign: TextAlign.center,
            backgroundColor: Color.fromARGB(255, 109, 162, 3),
            textStyle: TextStyle(
                fontSize: 20,
                letterSpacing: 2,
                color: Colors.white,
                fontWeight: FontWeight.w500)),
        showWeekNumber: true,
        allowedViews: const <CalendarView>[
          CalendarView.day,
          CalendarView.month,
        ],
        showTodayButton: true,
        weekNumberStyle: const WeekNumberStyle(
          backgroundColor: Color.fromARGB(255, 109, 162, 3),
          textStyle: TextStyle(color: Colors.white, fontSize: 15),
        ),
        selectionDecoration: BoxDecoration(
          color: const Color.fromARGB(65, 77, 116, 16),
          border: Border.all(
              color: const Color.fromARGB(255, 82, 132, 2), width: 2),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
        ),
        todayHighlightColor: const Color.fromARGB(255, 82, 132, 2),
        cellBorderColor: const Color.fromARGB(255, 106, 156, 6),
        backgroundColor: const Color.fromARGB(96, 141, 244, 32),
        dataSource: MeetingDataSource(db.source),
        showNavigationArrow: true,
        monthViewSettings: const MonthViewSettings(
          monthCellStyle: MonthCellStyle(
            trailingDatesBackgroundColor: Color.fromARGB(141, 89, 153, 11),
          ),
          numberOfWeeksInView: 6,
          appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
          showAgenda: true,
          agendaStyle: AgendaStyle(
              placeholderTextStyle:
                  TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
          agendaItemHeight: 70,
          agendaViewHeight: 350,
        ),
        onTap: (CalendarTapDetails details) {
          setState(() {
            selectedDateCalendar = details.date ?? DateTime.now();
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 109, 162, 3),
        onPressed: _addMeeting,
        child: const Icon(Icons.add),
      ),
    );
  }
}
