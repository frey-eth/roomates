import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roomates/pages/class_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;
  final _roomIDController = TextEditingController();
  List<int> RoomIDs = [123, 456];
  List<String> docIDs = [];
  Future getDocID() async {
    await FirebaseFirestore.instance
        .collection('user')
        .get()
        .then((snapshot) => snapshot.docs.forEach((element) {
              print(element.reference);
            }));
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  void confirmRoomID() {
    if (RoomIDs.contains(int.parse(_roomIDController.text))) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ClassPage()),
      );
    } else {
      print('Room ID False');
    }
    ;
  }

  void joinRoom() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            title: Text('Enter your room ID'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _roomIDController,
                  decoration: InputDecoration(hintText: "ID"),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: confirmRoomID, child: Text('Enter')),
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel')),
                  ],
                )
              ],
            ));
      },
    );
  }

  void createNewRoom() {}

  @override
  void initState() {
    getDocID();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [IconButton(onPressed: signUserOut, icon: Icon(Icons.logout))],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
                onPressed: joinRoom,
                child: Text('Join your room', style: TextStyle(fontSize: 20))),
            TextButton(
                onPressed: createNewRoom,
                child: Text('Create new room', style: TextStyle(fontSize: 20)))
          ],
        ),
      ),
    );
  }
}
