import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendal extends StatefulWidget {
  const Calendal({Key? key, required this.roomID}) : super(key: key);
  final String roomID;
  @override
  State<Calendal> createState() => _CalendalState();
}

class _CalendalState extends State<Calendal> {
  final startDate = DateTime.utc(2023, 4, 1);
  final endDate = DateTime.utc(2024, 4, 1);
  late User _user;
  late String _email;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _email = _user.email!;
  }

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

  Future<String> getOwner() async {
    final roomDocumentSnapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomID)
        .get();
    final owner = roomDocumentSnapshot.get('owner') as String;
    return owner;
  }

  void JobAssigment() async {
    final days = endDate.difference(startDate).inDays;
    final roomDocumentSnapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomID)
        .get();
    final roomData = roomDocumentSnapshot.data() as Map<String, dynamic>;
    final member = roomData['member'];
    member.shuffle(Random());
    List<Map<String, dynamic>> assigment = [];
    for (var day = 0; day < days; day++) {
      assigment.add({
        'userId': member[day % member.length],
        'day': DateTime.utc(startDate.year, startDate.month, startDate.day)
            .add(Duration(days: day))
      });
    }
    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomID)
        .update({'assignment': assigment});
    setState(() {});
  }

  Future<Map<String, dynamic>> getMemberByDate(DateTime date) async {
    final roomDocumentSnapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomID)
        .get();
    final assignment = roomDocumentSnapshot.get('assignment');
    final assignedUser =
        assignment.firstWhere((a) => a['day'].toDate() == date)['userId'];
    final assignedUserDocumentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(assignedUser)
        .get();
    final assignedUserData =
        assignedUserDocumentSnapshot.data() as Map<String, dynamic>;
    return assignedUserData;
  }

  Future<List<Map<String, dynamic>>> getMembersForLastThreeDays() async {
    final now = Timestamp.fromDate(DateTime.utc(
            DateTime.now().year, DateTime.now().month, DateTime.now().day))
        .toDate();
    final yesterday = Timestamp.fromDate(DateTime.utc(
            DateTime.now().year, DateTime.now().month, DateTime.now().day - 1))
        .toDate();
    final tomorrow = Timestamp.fromDate(DateTime.utc(
            DateTime.now().year, DateTime.now().month, DateTime.now().day + 1))
        .toDate();

    final memberToday = await getMemberByDate(now);
    final memberYesterday = await getMemberByDate(yesterday);
    final memberTomorrow = await getMemberByDate(tomorrow);

    return [memberYesterday, memberToday, memberTomorrow];
  }

  Widget _buildMembers() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getMembersForLastThreeDays(),
      builder: (BuildContext context,
          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasData) {
          final members = snapshot.data!;
          return SingleChildScrollView(
            padding: EdgeInsets.all(5),
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final member in members)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 3.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: (member['avatarUrl'] != null)
                              ? NetworkImage(member['avatarUrl'])
                              : null,
                          radius: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(member['last name']),
                      ],
                    ),
                  ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildJobAssigmentButton() {
    return FutureBuilder<String>(
      future: getOwner(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.data == _email) {
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
        } else {
          return Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                border: Border.all(), borderRadius: BorderRadius.circular(10)),
            child: Text(
              'PHÒNG ' + widget.roomID.toUpperCase(),
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: Color.fromARGB(255, 95, 96, 207)),
            ),
          );
        }
      },
    );
  }

  Widget _buildListMember() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getMembers(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        } else {
          return Expanded(
              child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(7),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 238, 215, 240),
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(
                            snapshot.data[index]['first name'] +
                                ' ' +
                                snapshot.data[index]['last name'],
                            style: TextStyle(fontSize: 15),
                          ),
                          leading: Container(
                            padding: EdgeInsets.all(2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: snapshot.data[index]['avatarUrl'] != null
                                  ? Image.network(
                                      snapshot.data[index]['avatarUrl'],
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(
                                          Icons.error,
                                        );
                                      },
                                    )
                                  : Icon(
                                      Icons.people,
                                      size: 50,
                                    ),
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color.fromARGB(255, 252, 252, 252),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    );
                  }));
        }
      },
    );
  }

  Widget _buildTableCalendar() {
    return SafeArea(child: Padding(
      padding: EdgeInsets.only(left: 30,right: 30),
      child: TableCalendar(
        calendarFormat: CalendarFormat.twoWeeks,
        rowHeight: 40,
        focusedDay: DateTime.now(), firstDay: startDate, lastDay: endDate),));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildJobAssigmentButton(),
          SizedBox(
            height: 5,
          ),
          Text("Hôm qua       Hôm Nay       Ngày Mai"),
          _buildMembers(),
          _buildTableCalendar(),
          Text(
            'Thành viên',
            style: TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 40, 29, 44),
                fontFamily: 'Alkatra'),
          ),
          _buildListMember(),
        ],
      ),
    ));
  }
}
