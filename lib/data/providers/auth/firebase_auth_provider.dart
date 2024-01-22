// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
];

class FirebaseAuthProvider {
  FirebaseAuthProvider();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: scopes);

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Stream<User?> onAuthChanged() {
    return _firebaseAuth.authStateChanges();
  }

  Future<String?> signInWithGoogle() async {
    try {
      print('before signOut.....');
      await _googleSignIn.signOut();
      print('signOut.....');
      GoogleSignInAccount? googleUser;
      try {
        googleUser = await _googleSignIn.signIn();
      } catch (_) {
        print('ERROR ~> $_');
      }

      if (googleUser != null) {
        print('googleUser.....');
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        print('googleAuth.....');
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await _firebaseAuth.signInWithCredential(credential);
        User? user = _firebaseAuth.currentUser;
        return user?.getIdToken();
      }

      return null;
    } catch (e, stackTrace) {
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return null;
    }
  }

  Future<String?> signInWithApple() async {
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);
    try {
      final appleIdCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );
      final oAuthCredential = OAuthProvider('apple.com').credential(
        idToken: appleIdCredential.identityToken,
        rawNonce: rawNonce,
      );
      await _firebaseAuth.signInWithCredential(oAuthCredential);
      User? user = _firebaseAuth.currentUser;
      return await user?.getIdToken();
    } catch (e, stackTrace) {
      debugPrintStack(label: e.toString(), stackTrace: stackTrace);
      return null;
    }
  }

  Future<String?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user?.uid;
  }

  Future<String?> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user?.uid;
  }

  Future<bool> isSignedIn() async {
    final currentUser = _firebaseAuth.currentUser;
    return currentUser != null;
  }

  Future<User?> getCurrentUser() async {
    User? user = _firebaseAuth.currentUser;
    return user;
  }

  Future<String?> getAccessToken() async {
    User? user = await getCurrentUser();
    return await user?.getIdToken();
  }

  Future<String?> getRefreshToken() async {
    User? user = _firebaseAuth.currentUser;
    return user?.getIdToken(true);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }
}
