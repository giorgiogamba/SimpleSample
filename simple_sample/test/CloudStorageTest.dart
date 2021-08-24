import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_sample/Controllers/AuthenticationController.dart';
import 'package:simple_sample/Controllers/CloudStorageController.dart';
import 'package:simple_sample/Models/Model.dart';
import 'package:simple_sample/Models/Record.dart';

import 'setupCloudFirestoreMock.dart';

void main() {

  setupCloudFirestoreMocks();

  ///INTEGRATION TEST
  test("Upload element and download", () async {

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    final model = Model();

    Record record = Record("nuovopath");
    record.setRecordOwnerID("1");

    CloudStorageController().uploadRecord(record);

    CloudStorageController().downloadRecord(record);

    String exPath = model.getExtDocPath()+"/"+record.getFilename()+"_downloaded.wav";
    File file = File(exPath);

    expect(file.exists(), true);

  });

  test ("Parse tags 3", () async {

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    List<String> tags = ["Ciao", "Come", "Stai"];

    String parsed_tags = CloudStorageController().parseTags(tags);
    expect(parsed_tags, "Ciao | Come | Stai");

  });

  test ("Parse tags 2", () async {

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    List<String> tags = ["Ciao", "Come"];

    String parsed_tags = CloudStorageController().parseTags(tags);
    expect(parsed_tags, "Ciao | Come");

  });

  test ("Parse tags 4", () async {

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    List<String> tags = ["Ciao", "Come", "Stai", "Bene"];

    String parsed_tags = CloudStorageController().parseTags(tags);
    expect(parsed_tags, "Ciao | Come | Stai | Bene");

  });

  ///INTEGRATION TEST
  test("downloads number", () async {

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    String oldNumber = "1";
    String res = CloudStorageController().updateDownloadNumber(oldNumber);
    expect ("1", res);
  });


  ///INTEGRATION TEST
  test("Profile Image", () async {

    //todo prelevare il path di un'immagine
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();


    String path = "";
    CloudStorageController().uploadProfileImage(path);
    String? downloadedPath = await CloudStorageController().downloadProfileImage();
    expect(downloadedPath, path);


  });

  ///INTEGRATION TEST
  test("Favourites 1", () async {

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    Record record = Record("URL");
    record.setFilename("toUploadRecord");
    CloudStorageController().addToFavourites(record);
    List<Record> favs = await CloudStorageController().getFavouritesFromDB();

    expect(favs.contains(record), true);
  });

  ///INTEGRATION TEST
  test("Favourites 2", () async {

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    Record record = Record("URL");
    record.setFilename("toUploadRecord");
    CloudStorageController().addToFavourites(record); //already tested
    CloudStorageController().removeFromSharedSamples(record);
    List<Record> favs = await CloudStorageController().getFavouritesFromDB();
    expect(favs.contains(record), false);

  });

  ///INTEGRATION TEST
  test("Username", () async {

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    String newUsername = "giorgio";
    CloudStorageController().setUsername(newUsername);
    String usnm = await CloudStorageController().getUsername();

    expect (usnm, newUsername);

  });


  ///INTEGRATION TEST
  test("Downloads Upgrade", () async {

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    Model model = Model();

    //Login
    String email = "46.gio@live.it";
    String password = "Ciao+123";
    AuthenticationController().signInWithEmailAndPassword(email, password);
    User? currentUser = model.getUser();

    if (currentUser != null) {
      int oldValue = await CloudStorageController().getDownloadsNumber();
      CloudStorageController().upgradeDownloads(Model().getUser()!.uid);
      int newValue = await CloudStorageController().getDownloadsNumber();
      expect(newValue, oldValue+1);
    }

  });

  ///INTEGRATION TEST
  test("Share 1", () async {

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    Model model = Model();

    //Login
    String email = "46.gio@live.it";
    String password = "Ciao+123";
    AuthenticationController().signInWithEmailAndPassword(email, password);
    User? currentUser = model.getUser();

    if (currentUser != null) {

      Record newRec = Record("URL");
      newRec.setFilename("provatest.wav");
      String newName = "provatestuploaded";
      await CloudStorageController().shareRecord(newRec, [], newName);
      List<Record> recs = await CloudStorageController().getFavouritesFromDB();

      bool check = false;
      for (int i = 0; i < recs.length; i ++) {
        if (recs[i].getFilename() == newName) {
          check = true;
        }
      }

      expect (check, true);
    }
  });

  ///INTEGRATION TEST
  test("Share 2", () async {

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    Model model = Model();

    //Login
    String email = "46.gio@live.it";
    String password = "Ciao+123";
    AuthenticationController().signInWithEmailAndPassword(email, password);
    User? currentUser = model.getUser();

    if (currentUser != null) {

      Record newRec = Record("URL");
      newRec.setFilename("provatest.wav");
      String newName = "provatestuploaded";
      await CloudStorageController().shareRecord(newRec, [], newName);
      Record toRemove = Record("URL");
      toRemove.setFilename(newName);
      await CloudStorageController().removeFromSharedSamples(toRemove);
      List<Record> recs = await CloudStorageController().getFavouritesFromDB();

      bool check = false;
      for (int i = 0; i < recs.length; i ++) {
        if (recs[i].getFilename() == newName) {
          check = true;
        }
      }

      expect (check, false);
    }
  });


  test ("User ID", () async {

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    String path = "uploads/1234/ciao.wav";
    String ID = CloudStorageController().getOwnerID(path);
    expect(ID, "1234");

  });

  ///INTEGRATION TEST
  test("Upload", () async {

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    Record toUpload = Record("URL");
    toUpload.setFilename("toBeUploaded");
    await CloudStorageController().uploadRecord(toUpload);
    List<Record> onlineRecs = await CloudStorageController().getOnlineRecords();

    bool check = false;
    for (int i = 0; i < onlineRecs.length; i ++) {
      if (onlineRecs[i].getFilename() == toUpload.getFilename()) {
        check = true;
      }
    }

    expect(check, true);

  });

  test("Download", () async {

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    Record toUpload = Record("URL");
    toUpload.setFilename("toBeUploaded");

    CloudStorageController().downloadRecord(toUpload);

    //todo fare check su come fare controloo nel filesystem

  });

  //todo fare test getElementsIntoDirectory

}