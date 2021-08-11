import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/drive/v3.dart' as drive;
import "dart:io";
import '../Models/Model.dart';
import '../Models/Record.dart';

class GoogleDriveController {

  GoogleHTTPCLient? authenticateClient;
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
    authenticateClient = GoogleHTTPCLient(accountHeaders);
    driveApi = drive.DriveApi(authenticateClient!);
    print("GoogleDriveController initialization completed");
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
    var driveFile = new drive.File();
    driveFile.name = record.getFilename();
    if (driveApi == null) {
      throw("Error: driveApi is null"); //null when googleAccount isn't saved into model
    }
    await driveApi?.files.create(driveFile, uploadMedia: drive.Media(file.openRead(), file.lengthSync()));
  }
}


class GoogleHTTPCLient extends http.BaseClient {
  final Map<String, String>? _headers;
  final http.Client _client = new http.Client();

  GoogleHTTPCLient(this._headers);

  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers!));
  }
}