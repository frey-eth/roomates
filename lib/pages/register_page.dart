import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _rememberMe = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  //sign user up method
  Future signUserUp() async {
    //show loading circle
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
    //try createing the user
    try {
      //check if password == confirm password
      if (_passwordController.text.trim() ==
          _passwordConfirmController.text.trim()) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        // addUserDetails
        addUserDetails(_firstNameController.text.trim(),
            _lastNameController.text.trim(), _emailController.text.trim());
      } else {
        Navigator.pop(context);
        wrongPasswordMessage();
      }
      //pop loading circle
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      //pop loading circle
      Navigator.pop(context);
      wrongPasswordMessage();
    }
  }

  Future addUserDetails(String firstName, String lastName, String email) async {
    await FirebaseFirestore.instance.collection('users').doc(email).set({
      'first name': firstName,
      'last name': lastName,
      'email': email,
    });
  }

  void wrongEmailMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Tài khoản sai rồi cha!!!'),
        );
      },
    );
  }

  void wrongPasswordMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Nhập lộn pass rồi, nhập lại đi!'),
        );
      },
    );
  }

  Widget _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Email',
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        SizedBox(
          height: 10,
        ),
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

  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Password',
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          alignment: Alignment.centerLeft,
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(width: 1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextField(
            controller: _passwordController,
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(
                  top: 14.0,
                ),
                prefixIcon: Icon(
                  Icons.lock,
                  color: Colors.white,
                ),
                hintText: 'Enter your Password',
                hintStyle: TextStyle(
                  color: Color.fromARGB(255, 110, 98, 98),
                  fontFamily: 'OpenSans',
                )),
          ),
        )
      ],
    );
  }

  Widget _buildConfirmPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Confirm Password',
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          alignment: Alignment.centerLeft,
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(width: 1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextField(
            controller: _passwordConfirmController,
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(
                  top: 14.0,
                ),
                prefixIcon: Icon(
                  Icons.lock,
                  color: Colors.white,
                ),
                hintText: 'Confirm your Password',
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
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () => print('Forgot Password Button Pressed'),
          child: Text(
            'Forgot Password?',
            style: TextStyle(color: Colors.white),
          ),
        ));
  }

  Widget _buildRememberMeCheckbox() {
    return Container(
      child: Row(children: <Widget>[
        Theme(
            data: ThemeData(unselectedWidgetColor: Colors.white),
            child: Checkbox(
              value: _rememberMe,
              checkColor: Colors.green,
              activeColor: Colors.white,
              onChanged: (value) {
                setState(() {
                  _rememberMe = !_rememberMe;
                });
              },
            )),
        Text(
          'Remember me',
          style: TextStyle(color: Colors.white),
        )
      ]),
    );
  }

  Widget _buildSignUpWithText() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account?',
          style: TextStyle(color: Colors.white),
        ),
        TextButton(
          onPressed: widget.onTap,
          child: Text(
            'Sign In',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Widget _buildLoginBtn() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        width: double.infinity,
        child: TextButton(
          onPressed: signUserUp,
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
            'Sign Up',
            style: TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 49, 142, 158),
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
                fontFamily: 'OpenSans'),
          ),
        ));
  }

  Widget _buildSignInWithText() {
    return Column(
      children: <Widget>[
        Text(
          '-OR-',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
        ),
        SizedBox(height: 15),
        Text(
          'Sign in with',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
        )
      ],
    );
  }

  Widget _buildLogoLoginBtn() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        GestureDetector(
          onTap: () => print('login with facebook'),
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(offset: Offset(0, 2), blurRadius: 6.0)],
                image: DecorationImage(
                    image: AssetImage('assets/images/facebook.png'))),
          ),
        ),
        GestureDetector(
          onTap: () => print('login with google'),
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [BoxShadow(offset: Offset(0, 2), blurRadius: 6.0)],
                image: DecorationImage(
                    image: AssetImage('assets/images/google-symbol.png'))),
          ),
        )
      ],
    );
  }

  Widget _buildFirstNameTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'First Name',
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          alignment: Alignment.centerLeft,
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(width: 1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextField(
            controller: _firstNameController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(
                  top: 14.0,
                ),
                prefixIcon: Icon(
                  Icons.account_box,
                  color: Colors.white,
                ),
                hintText: 'Enter your First Name',
                hintStyle: TextStyle(
                  color: Color.fromARGB(255, 110, 98, 98),
                  fontFamily: 'OpenSans',
                )),
          ),
        )
      ],
    );
  }

  Widget _buildLastNameTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'First Name',
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          alignment: Alignment.centerLeft,
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(width: 1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextField(
            controller: _lastNameController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(
                  top: 14.0,
                ),
                prefixIcon: Icon(
                  Icons.account_box,
                  color: Colors.white,
                ),
                hintText: 'Enter your Last Name',
                hintStyle: TextStyle(
                  color: Color.fromARGB(255, 110, 98, 98),
                  fontFamily: 'OpenSans',
                )),
          ),
        )
      ],
    );
  }

  @override
  void dispone() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
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
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 120,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'OpenSans-Bold',
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildFirstNameTF(),
                      SizedBox(height: 5),
                      _buildLastNameTF(),
                      SizedBox(height: 5),
                      _buildEmailTF(),
                      SizedBox(height: 5),
                      _buildPasswordTF(),
                      SizedBox(height: 5),
                      _buildConfirmPasswordTF(),
                      SizedBox(height: 5),
                      _buildLoginBtn(),
                      SizedBox(height: 15),
                      _buildSignUpWithText(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
