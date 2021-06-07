/// Class representing a record made with sampler or downloaded from cloud storage
class Record {

  String _url = "";
  int _ID = 0;
  int? _position;

  //Constructor
  Record(String url) {
    this._url = url;
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

}