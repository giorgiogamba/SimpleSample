import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationController {

  void initAuthenticationController() async {
    FirebaseAuth authorizer = FirebaseAuth.instance;
    authorizer.authStateChanges().listen((User? user) {
      if (user == null) {
        print("User is currently signed out");
      } else {
        print("User logged in");
      }
    });

    //Impostazione della persistenza
    await authorizer.setPersistence(Persistence.LOCAL);
  }

  static Future<void> signInWithGoogle() async {

    GoogleSignIn googleSignIn = GoogleSignIn();
    GoogleSignInAccount? googleAccount = await googleSignIn.signIn();

    if (googleAccount != null) {
      //Utente correttamente collegato
      GoogleSignInAuthentication googleAuthentication = await googleAccount.authentication;

      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuthentication.accessToken,
        idToken: googleAuthentication.idToken,
      );

      try {
        UserCredential _userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        User? _user = _userCredential.user;
        //todo settare l'utente dentro il model
        //todo settare le credenziali dentro il model
      } on FirebaseAuthException catch (e) {
        if (e.code == "account-exists-woth-different-credential") {
          print("linkGoogle: account exists with different credential");
        } else if (e.code == "invalid-credential") {
          print("linkGooghle: invalid credential");
        }
      } catch (e) {
          print("linkGoogle: not firebaseauth error");
      }

    } else {
      print("User not connected to google");
    }
  }

  static Future<UserCredential?> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();
    if (result.status == LoginStatus.success) {
      //User logged in
      final AccessToken? accessToken = result.accessToken;
      final facebookAuthCredential = FacebookAuthProvider.credential(accessToken!.token);
      return await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
    } else {
      print("USer not logged in to facebook");
    }
  }

  static Future<bool> checkUserFacebookLogged() async {
    final AccessToken? accessToken = await FacebookAuth.instance.accessToken;
    if (accessToken != null) {
      print("User is loggd in");
      return true;
    } else {
      print("User is not logged in");
      return false;
    }
  }

  void signOutFromFacebook() async {
    await FacebookAuth.instance.logOut();
  }

}
