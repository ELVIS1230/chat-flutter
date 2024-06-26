
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier{

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  bool get isSignedIn => currentUser != null;

  Future<void> singnin(String email,  String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    notifyListeners();
  }

   Stream<QuerySnapshot> getUser(String query) {
    return _firestore
        .collection('users')
        .where('email', isLessThanOrEqualTo: query + '\uf8ff')
        .snapshots();
  }

  // Future<void> singUp(String email, String password, String name, String imageUrl) async {
  //   UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
  //   final imageurl = await _uploadImage(_image!);
  //   await _firestore.collection('users').doc(userCredential.user!.uid).set({
  //     "uid":userCredential.user!.uid,
  //     "name": name,
  //     "email": email,
  //     "imageUrl": imageUrl,
  //     });
  //   notifyListeners();    
  // }

  Future<void> singOut() async {
    await _auth.signOut();
    notifyListeners();
  }
} 