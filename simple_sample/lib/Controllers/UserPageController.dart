import 'package:flutter/cupertino.dart';
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

  List<String> _languagesList = ["English", "Italiano",]; //selectedble languages
  List<String> _languagesCode = ["en", "it",];

  String getElementAt(int index) {
    return this._elements[index];
  }

  int getElementsLength() {
    return this._elements.length;
  }

  ///Takes image from camera, sets it as a profile image and uploads it on the cloud
  Future<PickedFile?> pickImageFromCamera() async {
    /*ImagePicker picker = ImagePicker();
    PickedFile? pickedImage = await picker.getImage(source: ImageSource.camera, imageQuality: 100);

    setProfileImagePath(pickedImage.path);
    CloudStorageController().uploadProfileImage(pickedImage.path);
    
    return pickedImage;
    */

    ImagePicker picker = ImagePicker();
    Future<XFile?> pickedImage = picker.pickImage(source: ImageSource.camera);
    
    setProfileImagePath(pickedImage.toString());
    CloudStorageController().uploadProfileImage(pickedImage.toString());
    
    //return pickedImage;
    return null;
  }

  ///Takes image from gallery and sets it as profile image and uploads it on the cloud
  Future<PickedFile?> pickImageFromGallery() async {
    ImagePicker picker = ImagePicker();
    Future<XFile?> pickedImage = picker.pickImage(source: ImageSource.gallery);
    
    setProfileImagePath(pickedImage.toString());
    CloudStorageController().uploadProfileImage(pickedImage.toString());
    
    //return pickedImage;
    return null;
  }

  ///Manages profile image source selection from setting menu
  Future<PickedFile?> executeOperation(int index) async {

    PickedFile? file;

    if (index == 0) {
      file = await pickImageFromGallery();
    } else if (index == 1) {
      file = await pickImageFromCamera();
    }

    return file;
  }

  ///Gets all the records shared by the user in order to display them into user page
  Future<void> getUserSharedRecords() async {
    await CloudStorageController().downloadUserSharedRecords().then((value) {
      _userSharedRecords = value;
    });
  }

  int getUserSharedRecordsLength() {
    return this._userSharedRecords.length;
  }

  Record getUserSharedRecordAt(int index) {
    return this._userSharedRecords[index];
  }

  void playRecordAt(int index) {
    Record record = getUserSharedRecordAt(index);
    AudioController().playAtURL(record.getUrl());
  }

  void playFavouriteRecordAt(int index) {
    Record record = getFavouriteAt(index);
    AudioController().playAtURL(record.getUrl());
  }

  void setProfileImagePath(String path) {
    profileImagePath.value = path;
  }

  Future<void> disconnect() async {
    await AuthenticationController().signOut();
    Model().clearUser();
  }

  ///Gets user's favourites from Cloud
  Future<void> initFavourites() async {
    List<Record> favs = await CloudStorageController().getFavouritesFromDB();
    this._favourites = favs;
  }

  List<Record> getFavourites() {
    return this._favourites;
  }

  Record getFavouriteAt(int index) {
    return this._favourites[index];
  }

  int getFavouritesLength() {
    return this._favourites.length;
  }

  Future<void> setUsername(String newUsername) async {
    await CloudStorageController().setUsername(newUsername);
  }

  Future<String> getUsername() async {
    return await CloudStorageController().getUsername();
  }

  ///Deletes account
  Future<void> deleteAccount() async {
    AuthenticationController().signOutGoogle(); //signing out from google
    AuthenticationController().signOut(); //signing out from firebase
    await CloudStorageController().deleteUserDocument(); //Deleting user's document from firebase
    await AuthenticationController().deleteUserAccount(); //Deleting user's info from Firebase
    print("*** End of account deletion ***");
  }

  Future<String> signInWithEmailAndPassword(String email, String password) async {
    return await AuthenticationController().signInWithEmailAndPassword(email, password);
  }

  Future<String> createUserWithEmailAndPassword(String email, String password) async {
    return await AuthenticationController().createUserWithEmailAndPassword(email, password);
  }

  ///Makes the User Page updated
  void updateUserPage() async {
    loaded.value = false;
    await getUserSharedRecords();
    await initFavourites();
    loaded.value = true;
  }

  Future<int> getDownloadsNumber() async {
    int value = await CloudStorageController().getDownloadsNumber();
    return value;
  }

  Future<void> handleRemoveFromFavourites(int index) async {
    Record record = this._favourites[index];
    await CloudStorageController().removeFromFavourites(record);
    this._favourites.remove(record);
  }

  ValueNotifier getModelAuth () {
    return Model().getAuth();
  }

  void handleChangeLanguage(BuildContext context, String key) {
    changeLanguage(context, Utils.remove3(key));
  }

  String getLanguageName(int index) {
    return this._languagesList[index];
  }

  String getLanguagesCode(int index) {
    return this._languagesCode[index];
  }

  int getLanguagesListLength() {
    return this._languagesList.length;
  }

  Future<bool> handleRemoveFromSharedSamples(int index) async {
    Record toDelete = getUserSharedRecordAt(index);
    bool res = await CloudStorageController().removeFromSharedSamples(toDelete);
    if (res == true) {
      //Removing this Shared Sample from Favourites if present
      int index = 0;
      for (Record fav in this._favourites) {
        if (fav.getFilename() == toDelete.getFilename() && fav.getUrl() == toDelete.getUrl()) {
          await handleRemoveFromFavourites(index);
          break;
        }
        index ++;
      }
    }
    return res;
  }

}