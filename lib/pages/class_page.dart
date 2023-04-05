import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:roomates/pages/calendal.dart';
import 'package:roomates/pages/profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class ClassPage extends StatefulWidget {
  final String roomID;
  final List<String> members;
  const ClassPage({super.key, required this.roomID, required this.members});

  @override
  State<ClassPage> createState() => _ClassPageState();
}

class _ClassPageState extends State<ClassPage> {
  late User _user;
  late String _email;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _email = _user.email!;
  }

  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<List<String?>> getUserData() async {
    final documentSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(_email).get();
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

  Future<void> uploadAvatar() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('avatarProfile')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    final task = ref.putFile(File(pickedFile!.path));
    // get link after upload image
    final snapshot = await task.whenComplete(() => null);
    final downloadUrl = await snapshot.ref.getDownloadURL();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_email)
        .update({'avatarUrl': downloadUrl});
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      Calendal(
        roomID: widget.roomID,
      ),
      FutureBuilder<List<String?>>(
        future: getUserData(),
        builder: (BuildContext context, AsyncSnapshot<List<String?>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Nếu dữ liệu chưa được load, hiển thị widget loading
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            // Nếu có lỗi, hiển thị thông báo lỗi
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            // Nếu không có dữ liệu hoặc dữ liệu rỗng, hiển thị thông báo
            return Center(
              child: Text('No data'),
            );
          } else {
            // Nếu có dữ liệu, trả về widget Profile với dữ liệu đã lấy được
            return Profile(
              first_name: snapshot.data![0] ?? '',
              last_name: snapshot.data![1] ?? '',
              email: _email,
              uploadAvatar: uploadAvatar,
              avatarUrl: snapshot.data![2] ?? '',
            );
          }
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 235, 174, 194),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
