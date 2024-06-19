import 'package:chatflutter/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbatState();
}

class _NavbatState extends State<Navbar> {
  final _auth = FirebaseAuth.instance;

  User? loggedInUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        loggedInUser = user;
      });
    }
  }

  Future<Map<String, dynamic>> _getUser(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection("users").doc(userId).get();
    final userData = userDoc.data()!;
    return {
      "name": userData["name"] ?? "",
      "email": userData["email"] ?? "",
      "imageUrl": userData["imageUrl"] ?? ""
    };
  }

  final currentUser = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      children: [
        FutureBuilder<Map<String, dynamic>>(
          future: _getUser(loggedInUser!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final userData = snapshot.data!;
              return UserAccountsDrawerHeader(
                  accountName: Text(
                    userData["name"],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w500  
                    ),
                  ),
                  accountEmail: Text(userData["email"]),
                  currentAccountPicture: CircleAvatar(
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(userData["imageUrl"]),
                      radius: 45,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFF3876FD),
                  ));
            } else {
              return Center(child: Text('No user data found'));
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text("Perfil"),
          // ignore: avoid_print
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProfileScreen()));
          },
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.black,
            size: 15,
          ),
          shape: const Border(
            bottom: BorderSide(),
          ),
        ),
      ],
    ));
  }
}
