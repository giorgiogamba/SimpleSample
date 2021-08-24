import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_sample/Controllers/AuthenticationController.dart';
import 'package:simple_sample/Models/Record.dart';
import 'package:simple_sample/Utils.dart';
import 'package:simple_sample/Utils/LocaleConstant.dart';
import 'AudioController.dart';
import 'CloudStorageController.dart';
import '../Models/Model.dart';

///Class managing User Page

class UserPageController {

  static final UserPageController _instance = UserPageController._internal();

  UserPageController._internal() {
    print("Initializing UserPageController");
  }

  factory UserPageController() {
    return _instance;
  }

  List<String> _elements = ["Select image from Gallery", "Select image from Camera"]; //strings for profile image upload
  List<Record> _userSharedRecords = []; //list of records shared by user
  List<Record> _favourites = []; //list of user's favourite records

  //Profile image with default path
  ValueNotifier profileImagePath = ValueNotifier("assets/userlogo_white.png"); //!!! NON PRIVATIZZARE
  ValueNotifier<bool> loaded = ValueNotifier(false); //= false when page has to be reloaded

  List<String> _languagesList = ["English", "Italiano", "Francais"]; //selectedble languages
  List<String> _languagesCode = ["en", "it", "fr"];

  String getElementAt(int index) { ///OK
    return this._elements[index];
  }

  int getElementsLength() { ///OK
    return this._elements.length;
  }

  ///Takes image from camera, sets it as a profile image and uploads it on the cloud
  Future<PickedFile?> pickImageFromCamera() async {
    ImagePicker picker = ImagePicker();
    PickedFile? pickedImage = await picker.getImage(source: ImageSource.camera, imageQuality: 100);
    if (pickedImage != null) {
      setProfileImagePath(pickedImage.path);
      CloudStorageController().uploadProfileImage(pickedImage.path);
    }
    return pickedImage;
  }

  ///Takes image from gallery and sets it as profile image and uploads it on the cloud
  Future<PickedFile?> pickImageFromGallery() async {
    ImagePicker picker = ImagePicker();
    PickedFile? pickedImage = await picker.getImage(source: ImageSource.gallery, imageQuality: 100);
    if (pickedImage != null) {
      setProfileImagePath(pickedImage.path);
      CloudStorageController().uploadProfileImage(pickedImage.path);
    }
    return pickedImage;
  }

  ///Manages profile image source selection from setting menu
  Future<PickedFile?> executeOperation(int index) async { ///OK
    if (index == 0) {
      PickedFile? image = await pickImageFromGallery();
      return image;
    } else if (index == 1) {
      PickedFile? image = await pickImageFromCamera();
      return image;
    }
  }

  ///Gets all the records shared by the user in order to display them into user page
  Future<void> getUserSharedRecords() async { ///OK
    await CloudStorageController().downloadUserSharedRecords().then((value) {
      _userSharedRecords = value;
    });
  }

  int getUserSharedRecordsLength() { ///OK
    return this._userSharedRecords.length;
  }

  Record getUserSharedRecordAt(int index) { ///OK
    return this._userSharedRecords[index];
  }

  void playRecordAt(int index) { ///OK
    Record record = getUserSharedRecordAt(index);
    AudioController().playAtURL(record.getUrl());
  }

  void setProfileImagePath(String path) { ///OK
    profileImagePath.value = path;
  }

  Future<void> disconnect() async { ///OK
    await AuthenticationController().signOut();
    Model().clearUser();
  }

  ///Gets user's favourites from Cloud
  Future<void> initFavourites() async { ///OK
    List<Record> favs = await CloudStorageController().getFavouritesFromDB();
    this._favourites = favs;
  }

  List<Record> getFavourites() { ///OK
    return this._favourites;
  }

  Record getFavouriteAt(int index) { ///OK
    return this._favourites[index];
  }

  int getFavouritesLength() { ///OK
    return this._favourites.length;
  }

  Future<void> setUsername(String newUsername) async { ///OK
    await CloudStorageController().setUsername(newUsername);
  }

  Future<String> getUsername() async { ///OK
    return await CloudStorageController().getUsername();
  }

  ///Deletes account
  Future<void> deleteAccount() async { ///OK
    AuthenticationController().signOutGoogle(); //signing out from google
    AuthenticationController().signOut(); //signing out from firebase
    await CloudStorageController().deleteUserDocument(); //Deleting user's document from firebase
    await AuthenticationController().deleteUserAccount(); //Deleting user's info from Firebase
    print("*** End of account deletion ***");
  }

  Future<String> signInWithEmailAndPassword(String email, String password) async { ///OK
    return await AuthenticationController().signInWithEmailAndPassword(email, password);
  }

  Future<String> createUserWithEmailAndPassword(String email, String password) async { ///OK
    return await AuthenticationController().createUserWithEmailAndPassword(email, password);
  }

  ///Makes the User Page updated
  void updateUserPage() async { ///OK
    loaded.value = false;
    await getUserSharedRecords();
    await initFavourites();
    loaded.value = true;
  }

  Future<int> getDownloadsNumber() async { ///OK
    int value = await CloudStorageController().getDownloadsNumber();
    return value;
  }

  Future<void> handleRemoveFromFavourites(int index) async { ///OK
    Record record = this._favourites[index];
    await CloudStorageController().removeFromFavourites(record);
    this._favourites.remove(record);
  }

  ValueNotifier getModelAuth () { ///OK
    return Model().getAuth();
  }

  void handleChangeLanguage(BuildContext context, String key) { ///OK
    changeLanguage(context, Utils.remove3(key));
  }

  String getLanguageName(int index) { ///OK
    return this._languagesList[index];
  }

  String getLanguagesCode(int index) { ///OK
    return this._languagesCode[index];
  }

  int getLanguagesListLength() { ///OK
    return this._languagesList.length;
  }

  Future<bool> handleRemoveFromSharedSamples(int index) async { ///OK
    Record toDelete = getUserSharedRecordAt(index);
    return await CloudStorageController().removeFromSharedSamples(toDelete);
  }

}