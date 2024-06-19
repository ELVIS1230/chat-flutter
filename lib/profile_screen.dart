import 'dart:io';

import 'package:chatflutter/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  File? _image;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
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

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<String> _uploadImage(File image) async {
    final ref = _storage
        .ref()
        .child("user_images")
        .child('${_auth.currentUser!.uid}.jpg');

    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<void> _updateProfile(String userId) async {
    try {
      Map<String, dynamic> updateData = {
      };
      if (_image != null) {
        final imageUrl = await _uploadImage(_image!);
        updateData["imageUrl"] = imageUrl;
      }
      if (_nameController.text.isNotEmpty) {
        updateData["name"] = _nameController.text;
      }
      if (updateData.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update(updateData);
        Fluttertoast.showToast(msg: "!Perfil actualizado con éxito!");
      } else {
        Fluttertoast.showToast(msg: "No hay cambios para actualizar.");
      }
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } catch (e) {
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Actualizar perfil"),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 80),
              InkWell(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, border: Border.all()),
                  child: _image == null
                      ? Center(
                          child: Icon(
                            Icons.camera_alt_rounded,
                            size: 50,
                            color: Color(0xFF3876FD),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.file(_image!, fit: BoxFit.cover),
                        ),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                      labelText: 'Nombre', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Ingresar un nombre";
                    }
                    return null;
                  }),
              SizedBox(height: 50),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.5,
                height: 55,
                child: ElevatedButton(
                 onPressed: () async {
                  await _updateProfile(loggedInUser!.uid);
                  // Navigator.pushReplacement(context,
                  //     MaterialPageRoute(builder: (context) => HomeScreen()));
                },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3876FD),
                      foregroundColor: Colors.white),
                  child: Text(
                    "Actualizar",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
