import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:simple_sample/Model.dart';

import 'Record.dart';
import 'dart:io';

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
  //todo usare questo metodo per riempure "esplora"
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
    Reference? uploadsRef = rootRef?.child("uploads");
    ListResult? uploadsChilds = await uploadsRef!.listAll();

    //Pre ognuna delle cartelle dei vari utenti
    for (var element in uploadsChilds.prefixes) {
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
      newRec.printRecordInfo();
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
  Future<void> upload(/*Record record*/ String? path) async {
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
  }

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

  Future<void> download() async { //FUNZIONANTE
    File newFile = File(Model().docPath+"download_ex.wav");
    try {
      await FirebaseStorage.instance.ref("uploads/example.wav").writeToFile(newFile);
    } on FirebaseException catch (e) {
      print(e.toString());
    }

    print("FIne esecuzione metodo download");
  }

  void downloadRecord(Record record) async {
    print("CloudStorageController -- downloadRecord method");
    var splitted = record.getFilename().split(".");
    String newURL = Model().getExtDocPath()!+"/"+splitted[0]+"_downloaded.wav";
    File newFile = File(newURL);

    //Creating record's cloud storage path
    String cloudPath = "uploads/"+record.getRecordOwnerID()+"/"+record.getFilename();

    try {
      await FirebaseStorage.instance.ref(cloudPath).writeToFile(newFile);
    } on FirebaseException catch (e) {
      print(e.toString());
    }
  }

}


















