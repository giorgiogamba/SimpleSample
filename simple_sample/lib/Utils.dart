class Utils {

  static String removeExtension(String name) {
    var split = name.split(".");
    return split[0];
  }

  static String wrapText(String text) {
    int length = text.length;
    if (length >= 5) {
      var substring = text.substring(0, 4);
      var ext = "..";
      return substring + ext;
    }
    return text;
  }

}