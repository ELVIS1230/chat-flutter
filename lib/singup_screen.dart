import 'dart:io';

import 'package:chatflutter/auth_provider.dart';
import 'package:chatflutter/home_screen.dart';
import 'package:chatflutter/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SingUpScreen extends StatefulWidget {
  const SingUpScreen({super.key});

  @override
  State<SingUpScreen> createState() => _SingUpScreenState();
}

class _SingUpScreenState extends State<SingUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  File? _image;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

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

  Future<void> _singUp() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
              email: _emailController.text, password: _passController.text);
      final imageurl = await _uploadImage(_image!);
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        "uid": userCredential.user!.uid,
        "name": _nameController.text,
        "email": _emailController.text,
        "imageUrl": imageurl,
      });

      Fluttertoast.showToast(msg:"!Registro exitoso!");

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } catch (e) {
      Fluttertoast.showToast(msg: '${e}');
      
    }
  }

  @override
  Widget build(BuildContext context) {
    // final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Crear cuenta"),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              SizedBox(height: 16),
              TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: 'Email', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Ingresar un correo";
                    }
                    return null;
                  }),
              SizedBox(height: 16),
              TextFormField(
                  controller: _passController,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                      labelText: 'Contraseña', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Ingresar la contraseña";
                    }
                    return null;
                  }),
              SizedBox(height: 50),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.5,
                height: 55,
                child: ElevatedButton(
                  onPressed: _singUp,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3876FD),
                      foregroundColor: Colors.white),
                  child: Text(
                    "Crear cuenta",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text("O"),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                },
                child: Text("Crear cuenta",
                    style: TextStyle(
                        color: Color(0xFF3876FD),
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              )
            ],
          ),
        ));
  }
}
