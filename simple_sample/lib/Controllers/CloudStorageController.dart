import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:simple_sample/Models/Model.dart';

import '../Models/Record.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

///Class representing FirebaseStorage Controller
///This controller manages all data globally saved and shared between users
///NB It is different from personal cloud storage

class CloudStorageController {

  static final CloudStorageController _instance = CloudStorageController._internal();
  Reference? rootRef = null;

  CloudStorageController._internal() {
    print("Initializing CloudStorageController");
    initCloudStorageController();
  }

  factory CloudStorageController() {
    return _instance;
  }

  void initCloudStorageController() {

    rootRef = FirebaseStorage.instance.ref(); //nessun aegomento fornito, pe cui punta alla root dello storage bucket

    print("CloudStorageController initialization completed");
  }

  //Method which shows all the elements in the bucket
  //se questo metodo ritorna in troppo tempo, usare list() con un limite massimo
  Future<void> listAllElements() async {
    ListResult res = await rootRef!.listAll();
    res.items.forEach((Reference ref) {
      print("File: $ref");
    });
  }

  Future<void> downloadURL(String dataString) async {
    //NB dataString ha una struttura del tipo ("Users/123/avatar.jpg")
    String downloadURL = await FirebaseStorage.instance.ref(dataString).getDownloadURL();

    print("*************** Download URL prelevato vale: "+downloadURL);
  }

  //prefixes == directories, items == files
  Future<List<Record>> getOnlineRecords() async {
    List<Record> records = [];

    //Getting reference to uploads folder
    Reference? uploadsRef = rootRef?.child("shared");
    ListResult? uploadsChilds = await uploadsRef!.listAll();

    //Pre ognuna delle cartelle dei vari utenti
    for (var element in uploadsChilds.prefixes) {

      print("Analyzing directory: "+element.name);
      //Prelevo gli elementi contenuti nella cartella
      List<Record> elementChildsRecords = await getElementsIntoDirectory(element);
      records = new List.from(records)..addAll(elementChildsRecords);
    }

    return records;
  }

  Future<void> getDirectoryURL() async {
    print("Metodo getDirectory URL");
    Reference? ref = rootRef?.child("uploads");
    print("ref vale; "+ref.toString());
    // await ref?.getDownloadURL(); //todo problemi nel ricavare questo URL
  }

  Future<List<Record>> getElementsIntoDirectory(Reference ref) async {
    List<Record> records = [];
    ListResult elementRes = await ref.listAll();
    for (var element in elementRes.items) {

      String temp = await element.getDownloadURL();
      Record newRec = Record(temp);
      newRec.setRecordOwnerID(getOwnerID(element.fullPath));
      newRec.setFilename(element.name);

      //Getting files metadata and adding tags to the new record
      FullMetadata metadata = await element.getMetadata();
      String tags = metadata.customMetadata!["tags"]!;

      //Deparsing tags
      List<String> tagsList = tags.split("|");
      for (int i = 0; i < tagsList.length; i ++) {
        newRec.addNewTag(tagsList[i]);
      }

      //Adding downloads number
      if (metadata.customMetadata == null) {
        print("+++++++++ NULLO"); //non ci arriva
      }
      newRec.setDownloadsNumber(int.parse(metadata.customMetadata!["downloads"]!));

      records.add(newRec);
    }
    return records;
  }

  String getOwnerID(String path) {
    var splitted = path.split("/");
    //into the position we have: uploads, uniqueid, samplename
    return splitted[1];
  }

  //Todo cancellare quando finiti i test
  //Uploads record to the cloud storage
  /*Future<void> upload(/*Record record*/ String? path) async {
    //String recURL = record.getUrl(); //absolute path

    //var splitted = recURL.split("/");
    var splitted = path!.split("/");
    String uploadPath = Model().createCloudStoragePath(splitted[splitted.length-1]);


    //File toUpload = File(recURL);

    File toUpload = File (path); //al posto di path ci dovrà essere l'indirizzo assoluto del campione

    try {
      await FirebaseStorage.instance.ref(uploadPath).putFile(toUpload);
    } on FirebaseException catch (e) {
      print(e.toString());
    }
  }*/

  //Uploads record to the cloud storage
  Future<void> uploadRecord(Record record) async {
    String recURL = record.getUrl(); //absolute path
    var splitted = recURL.split("/");

    //Creating path into the cloud storage
    //It follows the pattern "uploads/[uniqueID]/[filename].wav"
    String uploadPath = Model().createCloudStoragePath(splitted[splitted.length-1]);

    //Pointer in the filesystem to the file to be uploaded
    File toUpload = File(recURL);

    try {
      await FirebaseStorage.instance.ref(uploadPath).putFile(toUpload);
    } on FirebaseException catch (e) {
      print(e.toString());
    }
  }

  /*Future<void> download() async { //FUNZIONANTE
    File newFile = File(Model().getExtDocPath()+"download_ex.wav");
    try {
      await FirebaseStorage.instance.ref("uploads/example.wav").writeToFile(newFile);
    } on FirebaseException catch (e) {
      print(e.toString());
    }

    print("FIne esecuzione metodo download");
  }*/

  void downloadRecord(Record record) async {
    print("CloudStorageController -- downloadRecord method");
    var splitted = record.getFilename().split(".");
    String newURL = Model().getExtDocPath()+"/"+splitted[0]+"_downloaded.wav";
    File newFile = File(newURL);

    //Creating record's cloud storage path
    String cloudPath = "shared/"+record.getRecordOwnerID()+"/"+record.getFilename();

    try {
      Reference element = FirebaseStorage.instance.ref(cloudPath);
      FullMetadata metadata = await element.getMetadata();
      String updatedDownloadsNumber = updateDownloadNumber(metadata.customMetadata!["downloads"]);

      //Updating metadatas
      String tags = "";
      if (metadata.customMetadata!["tags"] != null) {
        tags = metadata.customMetadata!["tags"]!;
      }

      String owner = "";
      if (metadata.customMetadata!["owner"] != null) {
        owner = metadata.customMetadata!["owner"]!;
      }

      SettableMetadata updatetedMetadata = SettableMetadata(
        customMetadata: <String, String>{
          "tags" : tags,
          "owner" : owner,
          "downloads" : updatedDownloadsNumber,
        },
      );
      element.updateMetadata(updatetedMetadata);

      await element.writeToFile(newFile);
    } on FirebaseException catch (e) {
      print(e.toString());
    }
  }

  String updateDownloadNumber(String? oldNumber) {
    if (oldNumber != null) {
      int parsed = int.parse(oldNumber);
      parsed ++;
      return parsed.toString();
    } else {
      print("CloudStorageController -- updateDownloadNummber: aegument is null, returnin \"\"");
      return "";
    }
  }

  Future<bool> shareRecord(Record toUpload, List<String> tags, String newName) async {

    File file = File(toUpload.getUrl());

    String parsedtags = parseTags(tags);
    String owner = "";
    User? user = Model().getUser();
    if (user != null) {
      owner = user.uid;

      // Create your custom metadata.
      SettableMetadata metadata = SettableMetadata(
        customMetadata: <String, String>{
          "tags" : parsedtags,
          "owner" : owner,
          "downloads" : "0",
        },
      );

      //Adding tags to record to be shared
      for (int i = 0; i < tags.length; i ++) {
        toUpload.addNewTag(tags[i]);
      }

      try {
        // Pass metadata to any file upload method e.g putFile.
        await FirebaseStorage.instance.ref('shared/'+user.uid.toString()+"/"+newName+".wav").putFile(file, metadata);
        //await updateAllUsersField("toUpdateExplorer", true.toString());
        //await updateUserField("toUpdateUserPage", true.toString());
        return true;
      } on FirebaseException catch (e) {
        print("share Record exception");
        print(e.toString());
      }

    }
    return false;
  }

  String parseTags(List<String> tags) {
    String res = "";
    if (tags.length > 0) {
      for (int i = 0; i < tags.length - 2; i ++) {
        res = res + tags[i] + "|";
      }
      res = res + tags[tags.length - 1];
    }
    return res;
  }

  Future<List<Record>> downloadUserSharedRecords() async {
    print("CloudStorageController -- downloadUserSharedRecords");
    User? user = Model().getUser();
    if (user != null) {

      String sharedDirectoryPath = "shared/"+user.uid.toString()+"/";
      Reference sharedDirectoryRef = FirebaseStorage.instance.ref(sharedDirectoryPath);
      List<Record> sharedRecords = await getElementsIntoDirectory(sharedDirectoryRef);
      return sharedRecords;
    }
    print("Sto ritornando con utente scollegato");
    return [];
  }

  Future<void> uploadProfileImage(String imagePath) async {
    User? user = Model().getUser();
    if (user != null) {

      File toUpload = File(imagePath);

      String userID = user.uid;
      String uploadPath = "profiles/"+userID+"/profile_picture.jpeg";

      try {
        await FirebaseStorage.instance.ref(uploadPath).putFile(toUpload);
      } on FirebaseException catch (e) {
        print(e.toString());
      }

    } else {
      print("User is not logged in");
    }

  }

  //Downloads firebase image profile
  //Called when user is logged in
  Future<String?> downloadProfileImage() async {

    User? user = Model().getUser();
    if (user != null) {
      String imageCloudPath = "profiles/"+user.uid+"/profile_picture.jpeg";

      String downloadedPath = Model().getExtDocPath() + "firebase_profile_picture.jpeg";
      File downloadedImage = File(downloadedPath);

      try {
        Reference imageRef = FirebaseStorage.instance.ref(imageCloudPath); //todo gestire se la reference è nulla
        await imageRef.writeToFile(downloadedImage);
        return downloadedPath;
      } on FirebaseException catch (e) {
        print(e.toString());
      }
      return null;
    }
    return null;
  }

  void getUserInfos() async {
    User? currentUser = Model().getUser();
    if (currentUser != null) {

      String uid = currentUser.uid;
      CollectionReference usersDoc = FirebaseFirestore.instance.collection('users');
      DocumentSnapshot currentUserDoc = await usersDoc.doc("uid").get();

      String assignedDownloads = currentUserDoc.get("downloads").toString();
      print("CloudStorageController -- getUserInfos -- "+assignedDownloads);


    } else {
      print("CloudStorageController -- getUserInfos -- User is not logged in");
    }

  }

  ///Adds record to user's favourites into firestore
  Future<void> addToFavourites(Record record) async {
    DocumentReference userDocRef = FirebaseFirestore.instance.collection("users").doc(Model().getUser()!.uid);
    CollectionReference favCollRef = userDocRef.collection("favourites");
    //By now, I'm uploading favourites with the path "[filename - ownerID]"
    String path = record.getFilename() + " - " + record.getRecordOwnerID();

    //If it doesn't exist, creates a new document
    DocumentSnapshot snapshot = await favCollRef.doc(path).get();

    //Assigning url into a field
    if (!snapshot.exists) {
      DocumentReference userDocRef = favCollRef.doc(path);
      userDocRef.set({
        "url": record.getUrl(),
      }).then((value) {
        print("CloudStorage -- Record saved into favourites");

        //Updating user's data
        String ownerID = record.getRecordOwnerID();
        if (ownerID != "") {
          upgradeDownloads(ownerID);
        } else {
          print("CloudStorageController -- Unable to update downloads number because pwner ID is not defined");
        }
      });
    } else {
      print("CloudStorageController -- addtoFavourited:; Unable to save record into favourites");
      //Quando si arriva qua è perchè probabilmente è già statp salvato --> cambiar stato
    }
  }


  Future<void> removeFromFavourites(Record record) async {
    DocumentReference userDocRef = FirebaseFirestore.instance.collection("users").doc(Model().getUser()!.uid);
    CollectionReference favCollRef = userDocRef.collection("favourites");
    String path = record.getFilename() + " - " + record.getRecordOwnerID();
    favCollRef.doc(path).delete().then((value) => print("Delete completed"));
  }

  Future<void> upgradeDownloads(String ownerID) async {
    DocumentReference userDocRef = FirebaseFirestore.instance.collection("users").doc(ownerID);
    DocumentSnapshot snap = await userDocRef.get();

    if (snap.exists) {
      int newValue = snap.get("nDownloads") + 1;
      //Setting up new value
      userDocRef.update({"nDownloads": newValue}).then((value) => print("nDownloads updated"));
    } else {
      print("CloudStorageController -- upgradeDownalods -- snaposht doesn't exist");
    }
  }

  Future<int> getDownloadsNumber() async {
    User? user = Model().getUser();
    if (user != null) {

      DocumentReference userDocRef = FirebaseFirestore.instance.collection("users").doc(user.uid);
      DocumentSnapshot snap = await userDocRef.get();
      if (snap.exists) {
        return snap.get("nDownloads");
      }

    } else {
      print("CloudStorageController -- getDownloadsNumber -- user is null");
    }
    return 0;
  }

  ///Gets from the DB all the user's favourites and returns a list of all the queried urls
  Future<List<Record>> getFavouritesFromDB() async {
    List<Record> records = [];

    User? currentUser = Model().getUser();
    if (currentUser != null) {//user is logged in

      //Getting favourites collection
      DocumentReference userDocRef = FirebaseFirestore.instance.collection("users").doc(Model().getUser()!.uid);
      CollectionReference favCollRef = userDocRef.collection("favourites");
      QuerySnapshot favSnap = await favCollRef.get();

      List<QueryDocumentSnapshot> docList = favSnap.docs;
      for (int i = 0; i < docList.length; i ++) {

        //Composing record
        Record newRecord = Record(docList[i].get("url").toString());
        //Dividing filename and owner
        var splitted = docList[i].id.split(" - ");
        newRecord.setFilename(splitted[0]);
        newRecord.setRecordOwnerID(splitted[1]);
        records.add(newRecord);
      }

    } else {
      print("CloudStorageController -- getFavpuritesFromDB -- user is not logged in, returning empty list");
    }

    return records;
  }

  ///Sets up new username in firebase
  Future<void> setUsername(String newUsername) async {
    User? user = Model().getUser();
    if (user != null) {
      CollectionReference usersDoc = FirebaseFirestore.instance.collection('users');
      usersDoc.doc(user.uid).update({"username":newUsername})
          .then((value) => print("CloudStorageController: username correctly updated"));
    } else {
      print("CloudStorageController -- setUsername: user nullo, utente non collegato");
    }
  }

  ///Gets personal username from firebase
  Future<String> getUsername() async {
    String res = "";
    User? user = Model().getUser();
    if (user != null) {
      CollectionReference usersDoc = FirebaseFirestore.instance.collection('users');
      DocumentSnapshot snap = await usersDoc.doc(user.uid).get();
      if (snap.exists) {
        res = snap.get("username");
      }

    } else {
      print("CloudStorageController -- getUsername: user nullo, utente non collegato");
    }
    return res;
  }

  Future<void> deleteUserDocument() async {
    User? user = Model().getUser();
    if (user != null) {

      CollectionReference usersDoc = FirebaseFirestore.instance.collection('users');
      await usersDoc.doc(user.uid).delete().then((value) => print("User document correctly deleted"));

    } else {
      print("CloudStorageController -- deleteUserDocument -- user is null");
    }
  }

  /*///Updates all users' "field" field in firestore
  ///"field" value can be "toUpdateExplorer" or "ToUpdateUserPage"
  Future<void> updateAllUsersField(String field, String value) async {
    QuerySnapshot usersSnap = await FirebaseFirestore.instance.collection("users").get();
    List<QueryDocumentSnapshot> docsSnap = usersSnap.docs; //contiene tutti gli id degli utenti
    for (QueryDocumentSnapshot temp in docsSnap) {
      if (temp.exists) {
        print(temp.id);
        FirebaseFirestore.instance.collection("users").doc(temp.id).update({field: value})
            .then((value) => print("${temp.id} updated"));
      }
    }
  }

  Future<String?> getFieldValue(String field) async {
    DocumentSnapshot userSnap = await FirebaseFirestore.instance.collection("users").doc(Model().getUser()!.uid).get();
    if (userSnap.exists) {
      return userSnap.get(field);
    } else {
      return null;
    }
  }

  ///Sets to "value" the field "field" for the current user
  Future<void> updateUserField(String field, String value) async {
    await FirebaseFirestore.instance.collection("users").doc(Model().getUser()!.uid).update({field: value});
  }*/


}


















