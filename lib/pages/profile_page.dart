import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  final String first_name;
  final String last_name;
  final String email;
  final VoidCallback uploadAvatar;
  final String avatarUrl;
  const Profile({
    super.key,
    required this.first_name,
    required this.last_name,
    required this.email,
    required this.uploadAvatar,
    required this.avatarUrl,
  });

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    bool checkAvatar = widget.avatarUrl!='';
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 20,
        ),
        Center(
          child: GestureDetector(
            onTap: widget.uploadAvatar,
            child: CircleAvatar(
              radius: 70,
              backgroundImage: checkAvatar
                  ? NetworkImage(
                      widget.avatarUrl)
                  : null,
              child: checkAvatar
                  ? null
                  : Icon(Icons.person,size: 70,),
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),

        /// Name
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.first_name.toUpperCase() +
                  ' ' +
                  widget.last_name.toUpperCase(),
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 9, 14)),
            ),
            Icon(
              Icons.verified,
              color: Colors.greenAccent,
            )
          ],
        ),
      ],
    );
  }
}
