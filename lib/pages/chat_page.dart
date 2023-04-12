import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  final String userId;

  ChatScreen({required this.roomId, required this.userId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String?>> getUserData(String UID) async {
    final documentSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(UID).get();
    if (documentSnapshot.exists) {
      final firstName = documentSnapshot.get('first name');
      final lastName = documentSnapshot.get('last name');
      final avatarUrl;
      if (documentSnapshot.data()!.containsKey('avatarUrl')) {
        avatarUrl = documentSnapshot.get('avatarUrl');
      } else {
        avatarUrl = null;
      }
      return [firstName, lastName, avatarUrl];
    } else {
      return [null, null, null];
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 186, 211, 221),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('rooms/${widget.roomId}/messages')
                    .orderBy('timestamp')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ListView(
                    padding: EdgeInsets.all(8),
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      return FutureBuilder(
                        future: getUserData(data['sender']),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshotData) {
                          if (!snapshotData.hasData) {
                            return ListTile(
                              title: Text(data['sender']),
                              subtitle: Text(data['message']),
                            );
                          } else {
                            return ListTile(
                              title: Text(
                                snapshotData.data[1],
                                style: TextStyle(fontSize: 13),
                              ),
                              leading: Container(
                                child: ClipRRect(
                                  child: Image.network(
                                    snapshotData.data[2],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                              subtitle: Container(
                                  decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 79, 101, 122),
                                      border: Border.all(),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Text(
                                      data['message'],
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )),
                            );
                          }
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            Container(
              margin: EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(20)),
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: 'Aa',
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      _sendMessage(widget.userId, _textController.text);
                      _textController.clear();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(String senderId, String message) async {
    await _firestore.collection('rooms/${widget.roomId}/messages').add({
      'sender': senderId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
