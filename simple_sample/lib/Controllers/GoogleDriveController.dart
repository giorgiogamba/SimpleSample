import 'package:google_sign_in/google_sign_in.dart';
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
      throw("GoogleDriveController -- Error: Google Account is null"); // null when google account isn't saved into Model
    }

    //Getting headers
    final accountHeaders = await googleAccount.authHeaders;
    authenticateClient = GoogleHTTPClient(accountHeaders);
    driveApi = drive.DriveApi(authenticateClient!);
    print("GoogleDriveController initialization completed");
  }

  ///Returns a list of all the records urls saved into drive
  Future<List<String>> listGoogleDriveFiles() async {

    List<String> driveElems = [];
    drive.FileList? fileList = await driveApi?.files.list();

    if (fileList != null) {
      int length = fileList.files!.length;

      for (int i = 0; i < length; i ++) {
        drive.File temp = fileList.files![i];
        String fileExtension = Utils.getExtension(temp.name!);
        if (fileExtension == "wav" || fileExtension == "mp3") {
          driveElems.add(temp.id!);
        }
      }
    } else {
      print("GoogleDriveController -- listGoogleDriveFiles: unable to download records list");
    }

    return driveElems;
  }

  void upload(Record record) async {
    File file = File(record.getUrl());
    var driveFile = new drive.File();
    driveFile.name = record.getFilename();
    if (driveApi == null) {
      throw("Error: driveApi is null"); //null when googleAccount isn't saved into Model
    }
    //Uploads file into google Drive
    await driveApi?.files.create(driveFile, uploadMedia: drive.Media(file.openRead(), file.lengthSync()));
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