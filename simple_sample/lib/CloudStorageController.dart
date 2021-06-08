import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

    FirebaseStorage storage = FirebaseStorage.instance;

    rootRef = storage.ref(); //nessun aegomento fornito, pe cui punta alla root dello storage bucket

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

    //Todo: all'interno del widget fare:;
    //Image.network(downloadURL)

    //Todo eseguire questo metodo di download per permettere a un utente di scaricare elementi condivisi
  }

  //Uploads record to the cloud storage
  //todo fare integrazione con il sistema di record
  Future<void> upload(/*Record record*/ String? path) async { //FUNZIONA
    //String recURL = record.getUrl(); //absolute path
    //File toUpload = File(recURL);

    File toUpload = File (path!);

    //todo creare sistema di cartelle univoche

    try {
      await FirebaseStorage.instance.ref(Model().getStorageUploadPath()+"example.wav").putFile(toUpload);
    } on FirebaseException catch (e) {
      //todo implementare tutti i codice delle eccezioni
    }
  }

  Future<void> download() async { //FUNZIONANTE
    File newFile = File(Model().docPath+"download_ex.wav");
    try {
      await FirebaseStorage.instance.ref("uploads/example.wav").writeToFile(newFile);
    } on FirebaseException catch (e) {
      //todo fare gestione eccezioni
    }

    print("FIne esecuzione metodo download");
  }

}


















