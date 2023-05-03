import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:typed_data';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  String generateCustomUid(String email) {
    var ebytes = utf8.encode(email); // data being hashed
    var digest = sha1.convert(ebytes);
    var hexString = digest.toString();
    BigInt bigInt = BigInt.parse(hexString, radix: 16);

    // Take the modulus with 10^11 and return the result as an integer
    return (bigInt % BigInt.from(pow(10, 11))).toString();
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final customUid = generateCustomUid(email);
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await FirebaseFirestore.instance.collection('users').doc(customUid).set({
      'email': email,
      'uid': customUid,
    });
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
