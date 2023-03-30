import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roomates/pages/calendal.dart';
import 'package:roomates/pages/profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassPage extends StatefulWidget {
  const ClassPage({super.key});

  @override
  State<ClassPage> createState() => _ClassPageState();
}

class _ClassPageState extends State<ClassPage> {
  late User _user;
  late String _email;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
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
      return [firstName, lastName];
    } else {
      return [null, null];
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      Calendal(),
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
