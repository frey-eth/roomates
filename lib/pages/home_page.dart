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
  CollectionReference roomsRef = FirebaseFirestore.instance.collection('rooms');
  final _roomIdController = TextEditingController();
  Future<DocumentSnapshot<Object?>> getDocID() async {
    return await FirebaseFirestore.instance
        .collection('user')
        .doc(user!.email)
        .get();
  }

  Future<void> createNewRoom() async {
    String roomID = _roomIdController.text;
    // Lấy dữ liệu phòng tương ứng với roomID
    final roomData = await roomsRef.doc(roomID).get();
    if (roomData.exists) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Room exits.'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'))
              ],
            );
          });
    } else {
      final newRoomData = {
        'roomID': roomID,
        'member': [user!.email],
      };
      await roomsRef.doc(roomID).set(newRoomData);
    }
  }

  Future<void> joinRoom(BuildContext context) async {
    String roomID = _roomIdController.text;
    // Get infomation room with roomID
    DocumentSnapshot roomSnapshot =
        await FirebaseFirestore.instance.collection('rooms').doc(roomID).get();
    //If room exits and user haven't join room, add user to room
    if (roomSnapshot.exists) {
      List<String> members = List<String>.from(roomSnapshot.get('member'));
      if (!members.contains(user!.email)) {
        members.add(user!.email??'');
        await FirebaseFirestore.instance
            .collection('rooms')
            .doc(roomID)
            .update({'member': members});
      }
     
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ClassPage(roomID: roomID, members: members)));
    } //If Room not exits. alert
    else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Room does not exits. Please create new room.'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'))
              ],
            );
          });
    }
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
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
            SizedBox(
              width: 200,
              child: TextField(
                decoration: InputDecoration(
                    hintText: 'Room ID',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 20)),
                controller: _roomIdController,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ElevatedButton(
                  style: myButtonStyle,
                  onPressed: () => joinRoom(context),
                  child:
                      Text('Join your room', style: TextStyle(fontSize: 20))),
              SizedBox(width: 10),
              ElevatedButton(
                  style: myButtonStyle,
                  onPressed: createNewRoom,
                  child:
                      Text('Create new room', style: TextStyle(fontSize: 20)))
            ]),
          ],
        ),
      ),
    );
  }
}

ButtonStyle myButtonStyle = ButtonStyle(
  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          side: BorderSide(color: Color.fromARGB(255, 53, 48, 48)))),
  backgroundColor:
      MaterialStateProperty.all<Color>(Color.fromARGB(255, 133, 217, 228)),
  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
      EdgeInsets.symmetric(horizontal: 20, vertical: 20)),
);
