import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:simple_sample/main.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import "dart:io";
import 'Model.dart';
import 'Record.dart';

class GoogleDriveController {

  GoogleHTTPCLient? authenticateClient;
  drive.DriveApi? driveApi;

  static final GoogleDriveController _instance = GoogleDriveController._internal();

  final http.Client _client = new http.Client();

  GoogleDriveController._internal() {
    print("Initializing GoogleDriveController");
    initGoogleDriveController();
  }

  factory GoogleDriveController() {
    return _instance;
  }

  //NB questo metodo suppone che sia già stato effettuato l'accesso a google
  void initGoogleDriveController()  async{
    GoogleSignInAccount? googleAccount = Model().getGoogleSignInAccount();

    //Getting headers
    final accountHeaders = await googleAccount?.authHeaders;
    authenticateClient = GoogleHTTPCLient(accountHeaders);
    driveApi = drive.DriveApi(authenticateClient!);

    final Stream<List<int>> mediaStream = Future.value([104, 105]).asStream();
    var media = new drive.Media(mediaStream, 2);
    var driveFile = new drive.File();
    driveFile.name = "hello_world.txt";
    final result = await driveApi?.files.create(driveFile, uploadMedia: media);
    print("Upload result: $result");

  }

  Future<void> listGoogleDriveFiles() async {
    drive.FileList? fileList = await driveApi?.files.list();

    print("FILELIST è nULLO? "+(fileList == null).toString()); //todo è nullo

    print("Stampa degli elementi presenti in google drive");
    int length = fileList!.files!.length; //todo schifo
    for (int i = 0; i < length; i ++) {
      print("ID: ${fileList.files![i].id} con NOME: ${fileList.files![i].name}");
    }
  }

  void upload(Record record) async {
    print("GoogleDriveController -- upload method");
    File file = File(record.getUrl());
    var mediaStream = Future.value(file.readAsBytesSync()).asStream();
    print ("Ho calcolato mediastream");
    int length = await mediaStream.length;
    var media = new drive.Media(mediaStream, length);
    var driveFile = new drive.File();
    driveFile.name = record.getFilename();
    print("Sto per eseguire result");
    final result = await driveApi?.files.create(driveFile, uploadMedia: media);
    print("Upload result: $result");
  }


  /*Future<void> download(String fName, String gdID) async {
    drive.Media file = await driveApi!.files.get(gdID, downloadOptions: drive.DownloadOptions.FullMedia); //todo correggere problema qua
    print(file.stream);

    final saveFile = File('${Model().extDocPath}/${new DateTime.now().millisecondsSinceEpoch}$fName');
    List<int> dataStore = [];
    file.stream.listen((data) {
      print("DataReceived: ${data.length}");
      dataStore.insertAll(dataStore.length, data);
    }, onDone: () {
      print("Task Done");
      saveFile.writeAsBytes(dataStore);
      print("File saved at ${saveFile.path}");
    }, onError: (error) {
      print("Some Error");
    });
  }*/

}


class GoogleHTTPCLient extends http.BaseClient {
  final Map<String, String>? _headers;
  final http.Client _client = new http.Client();

  GoogleHTTPCLient(this._headers);

  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers!));
  }
}