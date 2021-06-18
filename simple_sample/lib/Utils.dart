class Utils {

  static String removeExtension(String name) {
    var split = name.split(".");
    return split[0];
  }

}