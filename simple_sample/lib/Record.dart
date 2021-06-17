/// Class representing a record made with sampler or downloaded from cloud storage
class Record {

  //Record URL can be local or external depending on the storage location (filesystem or firebase)
  String _url = "";
  int _ID = 0;
  int? _position;
  String _ownerID = "";
  String _filename = "";
  List<String> _tags = [];
  int _downloadsNumber = 0;

  //Constructor
  Record(String url) {
    this._url = url;
    extractFilename();
  }

  String getUrl() {
    return _url;
  }

  void setUrl(String newUrl) {
    this._url = newUrl;
  }

  int getID() {
    return _ID;
  }

  void setID(int newID) {
    this._ID = newID;
  }

  int? getPosition() {
    return this._position;
  }

  void setPosition(int position) {
    this._position = position;
  }

  String getRecordOwnerID () {
    return _ownerID;
  }

  void setRecordOwnerID(String newID) {
    this._ownerID = newID;
  }

  String getFilename() {
    return this._filename;
  }

  void setFilename(String newFilename) {
    this._filename = newFilename;
  }

  void extractFilename() {
    String path = this.getUrl();
    var splitted = path.split("/");
    this._filename = splitted[splitted.length-1];
  }

  void printRecordInfo() {
    print("Record info: url == ${getUrl()} | filename == ${getFilename()} | Owner == ${getRecordOwnerID()}");
  }

  void addNewTag(String tag) {
    this._tags.add(tag);
  }

  String getTagAt(int index) {
    if (index < this._tags.length) {
      return this._tags[index];
    }
    return ""; //empty tag, not valid
  }

  List<String> getTagList() {
    return this._tags;
  }

  void setDownloadsNumber(int newNumber) {
    this._downloadsNumber = newNumber;
  }

  void upgradeDownloadsNumber() {
    this._downloadsNumber ++;
  }

  int getDownloadsNumber() {
    return this._downloadsNumber;
  }

}