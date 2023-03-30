import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendal extends StatefulWidget {
  const Calendal({super.key});

  @override
  State<Calendal> createState() => _CalendalState();
}

class _CalendalState extends State<Calendal> {
  @override
  Widget build(BuildContext context) {
    return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 20,),
        Text(
          'A3-216 Calendar',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        TableCalendar(
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: DateTime.now(),
        ),
      ],
    ),
  );
  }
}