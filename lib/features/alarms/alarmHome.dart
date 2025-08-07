import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:onboard_screen_alarm_app/constants/colors.dart';
import 'package:onboard_screen_alarm_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class AlarmHome extends StatefulWidget {
  const AlarmHome({super.key});
  @override
  _AlarmHomeState createState() => _AlarmHomeState();
}

class Alarm {
  final int id;
  DateTime alarmDateTime;
  bool isActive;

  Alarm({required this.id, required this.alarmDateTime, this.isActive = true});

  String get time => DateFormat('h:mm a').format(alarmDateTime);
  String get date => DateFormat('E, d MMM yyyy').format(alarmDateTime);

  Map<String, dynamic> toJson() => {
    'id': id,
    'alarmDateTime': alarmDateTime.toIso8601String(),
    'isActive': isActive,
  };

  factory Alarm.fromJson(Map<String, dynamic> json) => Alarm(
    id: json['id'],
    alarmDateTime: DateTime.parse(json['alarmDateTime']),
    isActive: json['isActive'],
  );
}

class _AlarmHomeState extends State<AlarmHome> {
  String? _userLocation;
  List<Alarm> alarms = [];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _loadLocation();
    _loadAlarms();
  }

  Future<void> _requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> _saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final alarmListJson = jsonEncode(alarms.map((a) => a.toJson()).toList());
    await prefs.setString('alarms', alarmListJson);
  }

  Future<void> _loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final alarmJson = prefs.getString('alarms');

    if (alarmJson != null) {
      final List<dynamic> decoded = jsonDecode(alarmJson);
      setState(() {
        alarms = decoded.map((item) => Alarm.fromJson(item)).toList();
      });

      // Re-schedule all active alarms on app start
      alarms.forEach((alarm) {
        if (alarm.isActive) {
          _scheduleAlarm(alarm);
        }
      });
    }
  }

  Future<void> _loadLocation() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userLocation = prefs.getString('user_location') ?? 'Location not set';
    });
  }

  Future<void> _scheduleAlarm(Alarm alarm) async {
    final scheduledTZDateTime = tz.TZDateTime.from(
      alarm.alarmDateTime,
      tz.local,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      alarm.id, // Use the alarm's unique id
      'Alarm',
      'It\'s time: ${alarm.time}',
      scheduledTZDateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel',
          'Alarms',
          channelDescription: 'Alarm notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
          DateTimeComponents.time, // For daily repeating alarms
    );
  }

  Future<void> _cancelAlarm(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.10),

            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Selected Location",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: Colors.grey[300]),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _userLocation ?? '',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      minimumSize: Size(double.infinity, 53),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (picked != null) {
                        var now = DateTime.now();
                        var alarmDateTime = DateTime(
                          now.year,
                          now.month,
                          now.day,
                          picked.hour,
                          picked.minute,
                        );

                        if (alarmDateTime.isBefore(now)) {
                          alarmDateTime = alarmDateTime.add(
                            const Duration(days: 1),
                          );
                        }

                        final newAlarm = Alarm(
                          id: DateTime.now().millisecondsSinceEpoch % 10000000,
                          alarmDateTime: alarmDateTime,
                        );

                        setState(() {
                          alarms.add(newAlarm);
                        });

                        await _scheduleAlarm(newAlarm);
                        await _saveAlarms();
                      }
                    },

                    child: Text('Add Alarm', style: TextStyle(fontSize: 16)),
                    // styling same as before...
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),
            Text(
              'Alarms',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: alarms.length,
                itemBuilder: (context, index) {
                  final alarm = alarms[index];
                  return Dismissible(
                    key: Key(alarm.id.toString()),
                    onDismissed: (direction) async {
                      await _cancelAlarm(alarm.id);
                      setState(() {
                        alarms.removeAt(index);
                      });
                      await _saveAlarms();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${alarm.time} alarm dismissed'),
                        ),
                      );
                    },
                    background: Container(
                      color: Colors.red[400],
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                alarm.time,
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                alarm.date,
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                            ],
                          ),
                          Switch(
                            value: alarm.isActive,
                            onChanged: (val) async {
                              setState(() {
                                alarm.isActive = val;
                              });
                              if (alarm.isActive) {
                                await _scheduleAlarm(alarm);
                              } else {
                                await _cancelAlarm(alarm.id);
                              }
                              await _saveAlarms();
                            },
                            activeColor: Colors.white,
                            activeTrackColor: Color(
                              colors.color_purple_deep_dot,
                            ),
                            inactiveThumbColor: Colors.grey[200],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
