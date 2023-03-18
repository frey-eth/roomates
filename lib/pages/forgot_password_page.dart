import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  Widget _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(width: 1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(
                  top: 14.0,
                ),
                prefixIcon: Icon(
                  Icons.email,
                  color: Colors.white,
                ),
                hintText: 'Enter your Email',
                hintStyle: TextStyle(
                  color: Color.fromARGB(255, 110, 98, 98),
                  fontFamily: 'OpenSans',
                )),
          ),
        )
      ],
    );
  }

  Widget _buildForgotPasswordBtn() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 25),
        width: double.infinity,
        child: TextButton(
          onPressed: () async {
          await PasswordReset();
          await Future.delayed(Duration(seconds: 5));
          Navigator.pop(context);
        },
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            elevation: MaterialStatePropertyAll(7),
            backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
          ),
          child: Text(
            'Reset Password',
            style: TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 49, 142, 158),
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
                fontFamily: 'OpenSans'),
          ),
        ));
  }

  Future PasswordReset() async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Password Reset link sent! check your email'),
          );
        });
  } on FirebaseAuthException catch (e) {
    print(e);
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(e.message.toString()),
          );
        });
  }
}


  @override
  void dispone() {
    _emailController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 180, 206, 238),
                    Color.fromARGB(255, 119, 172, 233),
                    Color(0xFF478DE0),
                    Color(0xFF398AE5)
                  ],
                  stops: [0.1, 0.4, 0.7, 0.9],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 25),
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Enter you email, we will send you new password',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'OpenSans-Bold',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 15),
                  _buildEmailTF(),
                  SizedBox(height: 15),
                  _buildForgotPasswordBtn(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
