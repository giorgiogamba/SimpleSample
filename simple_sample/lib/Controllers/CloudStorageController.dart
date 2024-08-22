import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:simple_sample/Models/Model.dart';
import '../Models/Record.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

///Class representing FirebaseStorage Controller
///This controller manages all data globally saved and shared between users

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
    rootRef = FirebaseStorage.instance.ref(); //poiting to the root storage bucket
    print("CloudStorageController initialization completed");
  }

  ///Shows all the elements into the bucket
  Future<void> listAllElements() async {
    ListResult res = await rootRef!.listAll();
    res.items.forEach((Reference ref) {
      print("File: $ref");
    });
  }

  ///Returns a list of all the elements present into the Firebase Storage
  Future<List<Record>> getOnlineRecords() async {
    List<Record> records = [];

    //Getting reference to uploads folder
    Reference? uploadsRef = rootRef?.child("shared");
    ListResult? uploadsChilds = await uploadsRef!.listAll();

    //For each user folder
    for (var element in uploadsChilds.prefixes) {

      print("Analyzing directory: "+element.name);
      List<Record> elementChildsRecords = await getElementsIntoDirectory(element);
      records = new List.from(records)..addAll(elementChildsRecords);
    }
    return records;
  }

  ///Returns a list of records present into directory "ref"
  Future<List<Record>> getElementsIntoDirectory(Reference ref) async {
    List<Record> records = [];
    ListResult elementRes = await ref.listAll();
    for (var element in elementRes.items) {

      String temp = await element.getDownloadURL();

      //Building up a Record object
      Record newRec = Record(temp);
      newRec.setRecordOwnerID(getOwnerID(element.fullPath));
      newRec.setFilename(element.name);

      //Getting files metadata and adding tags to the new record
      FullMetadata metadata = await element.getMetadata();
      String tags = metadata.customMetadata!["tags"]!;
      List<String> tagsList = tags.split("|");
      for (int i = 0; i < tagsList.length; i ++) {
        newRec.addNewTag(tagsList[i]);
      }

      //Adding downloads number
      newRec.setDownloadsNumber(int.parse(metadata.customMetadata!["downloads"]!));
      records.add(newRec);
    }
    return records;
  }

  ///Returns owner's ID from "path"
  String getOwnerID(String path) {
    var splitted = path.split("/");
    //into the position we have: uploads, uniqueid, samplename
    return splitted[1];
  }

  ///Uploads record to the cloud storage
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


  ///Downloads a record from the cloud storage creating a new file
  void downloadRecord(Record record) async {

    //Creating a new path
    var splitted = record.getFilename().split(".");
    String newURL = "";
    if (Platform.isAndroid) {
      newURL = Model().getExtDocPath()+"/"+splitted[0]+"_downloaded.wav";
    } else if (Platform.isIOS) {
      newURL = Model().getDocPath()+"/"+splitted[0]+"_downloaded.wav";
    }
    File newFile = File(newURL);

    //Creating record's cloud storage path
    String cloudPath = "shared/"+record.getRecordOwnerID()+"/"+record.getFilename();

    try {
      Reference element = FirebaseStorage.instance.ref(cloudPath);
      FullMetadata metadata = await element.getMetadata();

      //updates user downloads number
      String ownerID = record.getRecordOwnerID();
      if (ownerID != "") {
        upgradeDownloads(ownerID);
      } else {
        print("CloudStorageController -- Unable to update downloads number because pwner ID is not defined");
      }

      //updates sample downloads number
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

  ///Upgrades +1 the number in the string as parameter
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

  ///Uploads record into Cloud Storage with given metadatas
  Future<bool> shareRecord(Record toUpload, List<String> tags, String newName) async { ///TESTED

    File file = File(toUpload.getUrl()); //Creating an object poiting to the audio file

    String parsedtags = parseTags(tags); //parsing tags as a unique string
    String owner = "";
    User? user = Model().getUser();
    if (user != null) {
      owner = user.uid;

      // Creating custom metadats
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
        //Uploading file with given metadats
        await FirebaseStorage.instance.ref('shared/'+user.uid.toString()+"/"+newName+".wav").putFile(file, metadata);
        return true;
      } on FirebaseException {
        throw ("Share Record: expection during record upload on cloud storage");
      }
    }
    return false;
  }

  ///Removes given record from shared group
  Future<bool> removeFromSharedSamples(Record record) async {

    User? user = Model().getUser();
    String recordName = record.getFilename();

    if (user != null) {

      try {
        String path = 'shared/'+user.uid.toString()+"/"+recordName;
        await FirebaseStorage.instance.ref(path).delete(); //Deleting file from cloud storage
        return true;
      } on FirebaseException {
        throw("Remove from Shared Samples: error during record delete from shared group");
      }

    } else {
      print("CloudStorageController -- removeFromSharedSamples: user is null");
    }
    return false;
  }

  ///Given a list o tags, creates a unique string containing all of the them separated by a comma
  String parseTags(List<String> tags) {
    String res = "";
    if (tags.length > 0) {
      for (int i = 0; i <= tags.length - 2; i ++) {
        res = res + tags[i] + "|";
      }
      res = res + tags[tags.length - 1];
    }
    return res;
  }

  ///RDownloads record shared from current user to the platform
  Future<List<Record>> downloadUserSharedRecords() async {
    User? user = Model().getUser();
    if (user != null) {
      String sharedDirectoryPath = "shared/"+user.uid.toString()+"/";
      Reference sharedDirectoryRef = FirebaseStorage.instance.ref(sharedDirectoryPath);
      List<Record> sharedRecords = await getElementsIntoDirectory(sharedDirectoryRef);
      return sharedRecords;
    } else {
      print("*** CloudStorageController -- downloadUserSharedRecords: Unable to download: current user is null ***");
    }
    return [];
  }

  ///Uploads to storage controller a new profile image
  Future<void> uploadProfileImage(String imagePath) async {
    User? user = Model().getUser();
    if (user != null) {
      File toUpload = File(imagePath); //Getting reference to the image to be uploaded
      String userID = user.uid;
      String uploadPath = "profiles/"+userID+"/profile_picture.jpeg";

      try {
        //uploading image
        await FirebaseStorage.instance.ref(uploadPath).putFile(toUpload);
      } on FirebaseException catch (e) {
        print(e.toString());
      }

    } else {
      print("*** CloudStorageController -- uploadProfileImage: Unable to upload new image: current user is null ***");
    }
  }

  ///Downloads user's profile image
  Future<String?> downloadProfileImage() async {
    User? user = Model().getUser();
    if (user != null) {
      String imageCloudPath = "profiles/"+user.uid+"/profile_picture.jpeg";
      String downloadedPath = Model().getExtDocPath() + "firebase_profile_picture.jpeg";
      File downloadedImage = File(downloadedPath);

      try {
        Reference imageRef = FirebaseStorage.instance.ref(imageCloudPath);
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
    //Uploading favourites with the path "[filename - ownerID]"
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
      });
    } else {
      print("CloudStorageController -- addtoFavourited:; Unable to save record into favourites");
    }
  }


  Future<void> removeFromFavourites(Record record) async {
    DocumentReference userDocRef = FirebaseFirestore.instance.collection("users").doc(Model().getUser()!.uid);
    CollectionReference favCollRef = userDocRef.collection("favourites");
    String path = record.getFilename() + " - " + record.getRecordOwnerID();
    favCollRef.doc(path).delete().then((value) => print("Delete completed"));
  }

  ///Upgrades downalods number +1
  Future<void> upgradeDownloads(String ownerID) async {
    DocumentReference userDocRef = FirebaseFirestore.instance.collection("users").doc(ownerID);
    DocumentSnapshot snap = await userDocRef.get();

    if (snap.exists) {
      int newValue = snap.get("nDownloads") + 1;
      userDocRef.update({"nDownloads": newValue}).then((value) => print("nDownloads updated")); //Setting up the new value
    } else {
      print("CloudStorageController -- upgradeDownalods -- snapshot doesn't exist");
    }
  }

  ///Return user's number of downloads taken from Cloud Storage for the given user's ID
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
        var splitted = docList[i].id.split(" - "); //Dividing filename and owner
        newRecord.setFilename(splitted[0]);
        newRecord.setRecordOwnerID(splitted[1]);
        records.add(newRecord);
      }

    } else {
      print("CloudStorageController -- getFavouritesFromDB -- user is not logged in, returning empty list");
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
      print("CloudStorageController -- setUsername: user is null");
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
      print("CloudStorageController -- getUsername: user is null");
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
}


















