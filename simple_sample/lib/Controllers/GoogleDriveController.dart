import 'package:google_sign_in/google_sign_in.dart';
//import 'package:googleapis/docs/v1.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/drive/v3.dart' as drive;
import "dart:io";
import "dart:core";
import '../Models/Model.dart';
import '../Models/Record.dart';
import '../Utils.dart';

class GoogleDriveController {

  GoogleHTTPClient? authenticateClient;
  drive.DriveApi? driveApi;

  static final GoogleDriveController _instance = GoogleDriveController._internal();

  GoogleDriveController._internal() {
    print("Initializing GoogleDriveController");
    initGoogleDriveController();
  }

  factory GoogleDriveController() {
    return _instance;
  }

  //This method supposes google access is already done
  void initGoogleDriveController()  async{
    GoogleSignInAccount? googleAccount = Model().getGoogleSignInAccount();
    if (googleAccount == null) {
      throw("Error: Google Account is null"); // è nullo quando nel model non è salvato il googleAccount
    }

    //Getting headers
    final accountHeaders = await googleAccount.authHeaders;
    authenticateClient = GoogleHTTPClient(accountHeaders);
    driveApi = drive.DriveApi(authenticateClient!);
    print("GoogleDriveController initialization completed");
  }

  Future<List<String>> listGoogleDriveFiles() async {

    List<String> driveElems = [];
    drive.FileList? fileList = await driveApi?.files.list();

    if (fileList != null) {
      print("Stampa degli elementi presenti in google drive");
      int length = fileList.files!.length;

      for (int i = 0; i < length; i ++) {
        drive.File temp = fileList.files![i];
        String fileExtension = Utils.getExtension(temp.name!);
        if (fileExtension == "wav" || fileExtension == "mp3") { //todo verificare se gli mp3 si possono effettivamente usare
          print("NAME: "+ temp.name!);
          print("ID: "+ temp.id!);


          //Adding to the list to be returned
          driveElems.add(temp.id!); //todo provare a resitutire un link
        }
      }
    } else {
      print("GoogleDriveController -- listGoogleDriveFiles: fileList è nullo");
    }

    return driveElems;
  }

  void upload(Record record) async {
    print("GoogleDriveController -- upload method");
    File file = File(record.getUrl());
    var driveFile = new drive.File();
    driveFile.name = record.getFilename();
    if (driveApi == null) {
      throw("Error: driveApi is null"); //null when googleAccount isn't saved into model
    }
    await driveApi?.files.create(driveFile, uploadMedia: drive.Media(file.openRead(), file.lengthSync()));
  }


  Future<void> downloadGoogleDriveFile(String fName, String gdID) async {

    print("********* Metodo  downaload googleDriveFile ********");
    print("******** PARAMETRI PASSATI AL METODO ********");
    print("fName: ${fName}");
    print("gdID: ${gdID}");
    //final res = await driveApi!.files.get(gdID, downloadOptions: drive.DownloadOptions.fullMedia).asStream().toList();
    
    //drive.Media? media = await driveApi!.files.export(gdID, "audio", downloadOptions: drive.DownloadOptions.fullMedia);

    //await driveApi!.files.export(gdID, "application/vnd.google-apps.audio");
    /*Object obj = await driveApi!.files.get(gdID); //obj è istanza di file
    drive.File cast = obj as drive.File;
    print(cast.);
    print(obj.toString());*/

    //drive.Media? media = await driveApi!.files.export(gdID, {alt:'media'});

    //drive.Media file = await driveApi.files.get(gdID, downloadOptions: ga.DownloadOptions.FullMedia);

    String newPath = Model().getPersonalPath(fName);
    File newFile = File(newPath);
    

    List<int> dataStore = [];
    /*media!.stream.listen((data) { //todo forse c'è problema con listen in IOS
      print("DataReceived: ${data.length}");
      dataStore.insertAll(dataStore.length, data);
    }, onDone: () {
      print("Task Done");
      newFile.writeAsBytes(dataStore);
      print("File saved at ${newFile.path}");
    }, onError: (error) {
      print("Some Error");
    });*/

    print("Fine metodo download file from google drive");
  }


}


class GoogleHTTPClient extends http.BaseClient {
  final Map<String, String>? _headers;
  final http.Client _client = new http.Client();

  GoogleHTTPClient(this._headers);

  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers!));
  }
}