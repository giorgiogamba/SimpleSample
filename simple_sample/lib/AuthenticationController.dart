import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:simple_sample/UserPageController.dart';

import 'CloudStorageController.dart';
import 'Model.dart';

class AuthenticationController {

  static final AuthenticationController _instance = AuthenticationController._internal();

  AuthenticationController._internal() {
    print("Initializing AuthenticationController");
    initAuthenticationController();
  }

  factory AuthenticationController() {
    return _instance;
  }

  bool checkIfAuthorized() {
    if ( Model().getUser() == null ) {
      return false;
    }
    return true;
  }

  void initAuthenticationController() async {
    FirebaseAuth authorizer = FirebaseAuth.instance;

    //Checking f there already is a persistence connection to firebase
    authorizer.userChanges().listen((User? user) { //Questo listener rimane connesso su ogni cambiamento dello stato utente
      if (user == null) {
        print("User is currently signed out");
      } else {
        print("*** User logged in. Infos");
        print(user.toString());
        Model().setUser(user); //Model gets initialized at every start so every time we have to write in it
      }
    });

    print("End method authentication controller initialization");
  }

  Future<void> signInWithGoogle() async { //todo eseguire collegamento a google

    print("****************** Google sing in ******************");
    final GoogleSignIn googleSignIn = GoogleSignIn.standard(scopes: [drive.DriveApi.driveScope]);
    final GoogleSignInAccount? googleAccount = await googleSignIn.signIn();

    Model().setGoogleSignInAccount(googleAccount);

    if (googleAccount != null) { //User correctly logged in
      GoogleSignInAuthentication googleAuthentication = await googleAccount.authentication;

      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuthentication.accessToken,
        idToken: googleAuthentication.idToken,
      );

      try {

        UserCredential _userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        User? _user = _userCredential.user;
        print("********** !!!!!!! Ricavato user !!!!!!! **************");
        print(_user!.email.toString());
        print(_user.toString());
        print(_user.uid);

        //Saving infos in model
        Model().setUser(_user);

        //Downloading profile image and setting it
        String? imagePath = await CloudStorageController().downloadProfileImage();
        if (imagePath != null) {
          UserPageController().setProfileImagePath(imagePath);
        } else {
          print("******* Profile image download not completed ********");
        }

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

  void signOutGoogle() async{
    GoogleSignIn _googleSignIn = GoogleSignIn(); //NB istanziato di nuovo, veder se da problemi
    await _googleSignIn.signOut();
    Model().clearUser();
    print("************** User Signed Out from Google ************");
  }

  /*static Future<UserCredential?> signInWithFacebook() async {
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
  }*/

}
