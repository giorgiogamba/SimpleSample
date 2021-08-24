import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:simple_sample/Controllers/UserPageController.dart';

import 'CloudStorageController.dart';
import '../Models/Model.dart';
import 'GoogleDriveController.dart';

///Manages user authentication

class AuthenticationController {

  static final AuthenticationController _instance = AuthenticationController._internal();
  String username = "username"; //Default username

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

  ///Called the first time controller is invoked
  void initAuthenticationController() async {
    FirebaseAuth authorizer = FirebaseAuth.instance;

    ///Initializing listener connected to the "User" object
    ///Executed different operations depending on the object state
    authorizer.userChanges().listen((User? user) async {
      if (user == null) {
        print("User is currently signed out");
      } else { //When the user logs in
        print("*** User logged in. Printing infos... ***");
        print(user.toString());

        //Writes the user into the model iff user has verified email address
        //If "user" model field is null, user cannot access to user page
        if (user.emailVerified) {
          Model().setUser(user);
        }

        //Making google access in order to enable Google Drive Service
        if (user.providerData[0].providerId == "google.com") { //if the user registered to app using google
          final GoogleSignIn googleSignIn = GoogleSignIn.standard(scopes: [drive.DriveApi.driveScope]);
          await googleSignIn.signInSilently();

          GoogleSignInAccount? googleAccount = googleSignIn.currentUser;
          print("*** Google Account Infos: ***");
          print(googleAccount.toString());
          Model().setGoogleSignInAccount(googleAccount);

          //initializing Google Drive Controller
          if (googleAccount != null) {
            GoogleDriveController().initGoogleDriveController();
          } else {
            print ("Google Account is null");
          }

        }
      }
    });

    print("Authentication Controller: End Authentication");
  }

  bool checkIfUseConnected() {
    if (FirebaseAuth.instance.currentUser != null) {
      print("Authentication Controller: User is already connected");
      return true;
    } else {
      print("Authentication Controller: User is not connected");
      return false;
    }
  }

  void tryGoogleSignIn() async {
    final GoogleSignIn googleSignIn = GoogleSignIn.standard(scopes: [drive.DriveApi.driveScope]);
    final GoogleSignInAccount? googleAccount = await googleSignIn.signIn();

    authenticateGoogleAccount(googleAccount);
  }


  ///Completes Google Sign In / Registration making also access to Firebase
  void authenticateGoogleAccount(GoogleSignInAccount? googleAccount) async {

    Model().setGoogleSignInAccount(googleAccount);

    //initializing Google Drive Controller
    if (googleAccount != null) {
      GoogleDriveController().initGoogleDriveController();
    }

    if (googleAccount != null) { //User correctly logged in
      GoogleSignInAuthentication googleAuthentication = await googleAccount.authentication;

      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuthentication.accessToken,
        idToken: googleAuthentication.idToken,
      );

      //Making Firebase Sign In using Google infos
      try {
        UserCredential _userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        User? _user = _userCredential.user; //getting user
        Model().setUser(_user!);

        //Downloading profile image
        String? imagePath = await CloudStorageController().downloadProfileImage();
        if (imagePath != null) {
          UserPageController().setProfileImagePath(imagePath);
        } else {
          print("*** Profile image not downloaded ***");
        }
        firestoreAuthentication(_user);

      } on FirebaseAuthException catch (e) {
        if (e.code == "account-exists-woth-different-credential") {
          throw("Authentication Controller: account exists with different credential");
        } else if (e.code == "invalid-credential") {
          throw("Authentication Controller: invalid credential");
        }
      } catch (e) {
        throw("Authentication Controller: Firebase access using Google not completed");
      }
    } else {
      print("Authentication Controller: Authenticate Google Account: googleAccount is null");
    }

  }

  Future<void> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn.standard(scopes: [drive.DriveApi.driveScope]);
    final GoogleSignInAccount? googleAccount = await googleSignIn.signIn();

    authenticateGoogleAccount(googleAccount);
  }

  ///Completed Firebase Authentication writing support infos
  Future<void> firestoreAuthentication(User currentUser) async {

    //Getting user's document
    CollectionReference users = FirebaseFirestore.instance.collection("users");
    DocumentSnapshot snapshot = await users.doc(currentUser.uid).get();

    if (!snapshot.exists) {

      print("User's document does not exist, creating a new one");
      DocumentReference userDocRef = users.doc(currentUser.uid);
      userDocRef.set({
        "nDownloads": 0,
        "username": username,
        "device_token" : Model().getDeviceToken(),
        "toUpdateExplorer" : false.toString(),
        "toUpdateUserPage" : false.toString(),
      }).then((value) => print("*** Created Firestore document for the User ***"));

    } else {
      print("*** Authentication Controller -- Firebase document already exists ***");
    }
  }

  ///Signs out current user from google
  Future<void> signOutGoogle() async{
    GoogleSignIn _googleSignIn = GoogleSignIn();
    await _googleSignIn.signOut();
    FirebaseAuth.instance.signOut();
    print("*** User is correctly signed out from google ***");
  }

  ///Signs out user accessed with email and password
  Future<void> signOut () async {
    await FirebaseAuth.instance.signOut();
    Model().clearUser();
    print("*** User is correctly signed out from Firebase ***");
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

        String? imagePath = await CloudStorageController().downloadProfileImage();
        if (imagePath != null) {
          UserPageController().setProfileImagePath(imagePath);
        } else {
          print("*** Profile image not downaloaded ***");
        }

        //Sending verification email
        if (!user.emailVerified) {
          firestoreAuthentication(user);
          user.sendEmailVerification();
          return "Verify your email";
        }

        //Sign in Completed, writing user into model
        Model().setUser(user);
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


  ///Signs in user using Email and password
  Future<String> signInWithEmailAndPassword(String newEmail, String newPassword) async {
    try {
      UserCredential credentials = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: newEmail,
          password: newPassword,
      );

      User? user = credentials.user;
      if (user != null) { //Access correctly executed
        if (user.emailVerified) {
          Model().setUser(user);
          return "true";
        } else { //email still not verified
          return "Verify your email";
        }

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
    return "Sign-In with email and password: Unknown error";
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
