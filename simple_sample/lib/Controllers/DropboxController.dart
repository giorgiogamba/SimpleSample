import 'package:dropbox_client/dropbox_client.dart';
import '../Models/Model.dart';
import '../Models/Record.dart';

const String dropbox_key = "1ardts67mhrvvbr";
const String dropbox_secret = "1ardts67mhrvvbr";

class DropboxController {

  String? accessToken = "";

  static final DropboxController _instance = DropboxController._internal();

  DropboxController._internal() {
    print("Initializing DropboxController");
    initDropboxController();
  }

  factory DropboxController() {
    return _instance;
  }

  Future<void> initDropboxController() async {
    //await initDropbox(); //todo trovare il modo di chiamarlo solo una volta
    testLogin();
    await getAccessToken();
    print("access toekn $accessToken");
  }

  //Si crea problema quando si cerca di riutilizzare key e secret
  Future initDropbox() async {
    print("+++++++++++++ INIT DROPBOXXX +++++++++++");
    // init dropbox client. (call only once!)
    String? dropbox_clientId = Model().getUser()?.uid;
    if (dropbox_clientId != null) {
      await Dropbox.init(dropbox_clientId, dropbox_key, dropbox_secret);
      print("+++++++++++++++ FINE INIT DROPBOX");
      await testLogin();
      await getAccessToken();
    } else {
      print("++++++++++++++ UTENTE NULL");
    }
  }

  Future testLogin() async {
    print("++++++++ TEST LOGIN +++++++++");
    // this will run Dropbox app if possible, if not it will run authorization using a web browser.
    await Dropbox.authorize();
  }

  Future getAccessToken() async {
    accessToken = await Dropbox.getAccessToken();
  }

  Future loginWithAccessToken() async {
    await Dropbox.authorizeWithAccessToken(accessToken!);
  }

  Future testLogout() async {
    // unlink removes authorization
    await Dropbox.unlink();
  }

  Future testListFolder() async {
    final result = await Dropbox.listFolder(''); // list root folder
    print(result);

    final url = await Dropbox.getTemporaryLink('/file.txt');
    print(url);
  }

  Future testUpload() async {
    final filepath = '/path/to/local/file.txt';
    final result = await Dropbox.upload(filepath, '/file.txt', (uploaded, total) {
      print('progress $uploaded / $total');
    });
  }

  Future testDownload() async {
    final filepath = '/path/to/local/file.txt';
    final result = await Dropbox.download('/dropbox_file.txt', filepath, (downloaded, total) {
      print('progress $downloaded / $total');
    });
  }

  Future uploadRecord(Record record) async {
    final result = await Dropbox.upload("/"+record.getFilename(), record.getUrl(), (downloaded, total) {
      print('progress $downloaded / $total');
    });
  }

  //Future<Record> downloadRecord() async {}


}