import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendal extends StatefulWidget {
  const Calendal({super.key, required this.roomID});
  final String roomID;
  @override
  State<Calendal> createState() => _CalendalState();
}

class _CalendalState extends State<Calendal> {
  Future<List<Map<String, dynamic>>> getMembers() async {
    final roomDocumentSnapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomID)
        .get();
    final List<dynamic> roomMembers = roomDocumentSnapshot.get('member');
    final userDocumemts = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: roomMembers)
        .get();
    final List<Map<String, dynamic>> users = userDocumemts.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
    return users;
  }

  Widget _buildJobAssignmentButton() {
    return GestureDetector(
      onTap: JobAssigment,
      child: Container(
        width: 100,
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(199, 174, 221, 1),
              Color.fromARGB(255, 219, 155, 187),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(5, 5),
              blurRadius: 10,
            )
          ],
        ),
        child: Center(
          child: Text(
            'Phân công',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void JobAssigment() {
    print('Job Assigment');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 20,
        ),
        _buildJobAssignmentButton(),
        TableCalendar(
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: DateTime.now(),
        ),
        Text(
          'Thành viên',
          style: TextStyle(
              fontSize: 20,
              color: Color.fromARGB(255, 164, 120, 182),
              fontFamily: 'Alkatra'),
        ),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: getMembers(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            } else {
              return Expanded(
                  child: ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, index) {
                        return Card(
                          child: Text(
                            snapshot.data[index]['first name'] +
                                ' ' +
                                snapshot.data[index]['last name'],
                            style: TextStyle(fontSize: 15),
                          ),
                        );
                      }));
            }
          },
        ),
      ],
    );
  }
}
