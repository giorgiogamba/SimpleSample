import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:simple_sample/Controllers/UserPageController.dart';

import 'CloudStorageController.dart';
import '../Models/Model.dart';

class AuthenticationController {

  static final AuthenticationController _instance = AuthenticationController._internal();
  String username = "";

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

  bool checkIfUseConnected() {
    if (FirebaseAuth.instance.currentUser != null) {
      print("User is already connected");
      return true;
    } else {
      print("User is not connected");
      return false;
    }
  }


  Future<void> signInWithGoogle() async {

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
        Model().setUser(_user!);
        print("Authentication Controller -- signInWithGoogle -- found User with infos: ");
        print(_user.toString());

        //Downloading profile image
        String? imagePath = await CloudStorageController().downloadProfileImage();
        if (imagePath != null) {
          UserPageController().setProfileImagePath(imagePath);
        } else {
          print("******* Profile image download not completed ********");
        }

        firestoreAuthentication(_user);


        //Test
        //DropboxController();

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

  Future<void> firestoreAuthentication(User currentUser) async {
    //Addition Users Info Management
    CollectionReference users = FirebaseFirestore.instance.collection("users");
    DocumentSnapshot snapshot = await users.doc(currentUser.uid).get();
    if (!snapshot.exists) {

      //The document doesn't exist -> creating new user account
      print("Document does not exist, creating a new one");
      DocumentReference userDocRef = users.doc(currentUser.uid);
      userDocRef.set({
        "nDownloads": 0,
        "username": username,
        "device_token" : Model().getDeviceToken(),
        "toUpdateExplorer" : false.toString(),
        "toUpdateUserPage" : false.toString(),
      }).then((value) => print("+++ Created Firestore document for the User +++"));

    } else {

      //THe document already exist -> accessing users data
      print("+++ Authentication Controller -- signInWithGoogle: document already exists +++");

    }
  }

  ///Signs out current user from google
  Future<void> signOutGoogle() async{
    GoogleSignIn _googleSignIn = GoogleSignIn();
    await _googleSignIn.signOut();
    FirebaseAuth.instance.signOut();
    print("End of signOutGoogle method");
  }

  ///Signs out user not accessed with google
  Future<void> signOut () async {
    await FirebaseAuth.instance.signOut();
    Model().clearUser();
    print("End signOut method");
  }


  ///Creates a new user with email and password infos
  ///NB automatically signs in the new user
  Future<String> createUserWithEmailAndPassword(String newEmail, String newPassword) async {
    try {
      UserCredential credentials = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: newEmail,
        password: newPassword,
      );

      User? user = credentials.user;
      if (user != null) { //ACCESS CORRECTLY EXECUTED

        Model().setUser(user);
        String? imagePath = await CloudStorageController().downloadProfileImage();
        if (imagePath != null) {
          UserPageController().setProfileImagePath(imagePath);
        } else {
          print("******* Profile image download not completed ********");
        }
        firestoreAuthentication(user);
        return "true";

      } else { //ACCESS NOT CORRECTLY EXECUTED
        return "Error during registration, user not valid";
      }

    } on FirebaseAuthException catch (error) {
      switch (error.code) {

        case "email-already-in-use":
          return "This email address is already in use.";

        case "invalid-email":
          return "Invalid Email";

        case "operation-not-allowed":
          return "This operation is not allowed";

        case "weak-password":
          return "Your password is weak";

        default:
          return "unknown error during registration";
      }
    } catch (e) {
      print(e);
    }
    return "unknown error during registration";
  }

  Future<String> signInWithEmailAndPassword(String newEmail, String newPassword) async {
    try {
      UserCredential credentials = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: newEmail,
          password: newPassword,
      );

      User? user = credentials.user;
      if (user != null) { //Access correctly executed
        Model().setUser(user);
        return "true";
      } else { //Access not executed
        return "Error during access user is not valid";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return "No user found for that email.";
      } else if (e.code == 'wrong-password') {
        return "Wrong password provided for that user.";
      } else if (e.code == "invalid-email") {
        return "Invalid email";
      } else if (e.code == "user-disabled") {
        return "This user is disabled";
      } else if (e.toString() == "[firebase_auth/unknown] Given String is empty or null") {
        return "[firebase_auth/unknown] Given String is empty or null";
      }
    }
    return "Sign-In: Unknown error";
  }


  Future<void> deleteUserAccount() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await currentUser.delete();
    } else {
      print("AuthenticationController -- deleteUserAccount -- currentUser is null, unable to delete account");
    }
  }



}
