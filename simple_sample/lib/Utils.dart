import 'package:flutter/material.dart';

///Class including utility static functions

class Utils {

  static String getFilenameFromURL(String URL) {
    var splitted = URL.split("/");
    return splitted[splitted.length-1];
  }

  static String removeExtension(String name) {
    var split = name.split(".");
    return split[0];
  }

  //Sampler: 5, UserOgae: 9, Explorer: 32
  static String wrapText(String text, int maxLength) {
    int length = text.length;
    if (length >= maxLength) {
      var substring = text.substring(0, maxLength-1);
      var ext = "..";
      return substring + ext;
    }
    return text;
  }

  static void showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.pink,
        content: Text(message),
        action: SnackBarAction(
          textColor: Colors.black,
          label: "Close",
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  ///Removes 3 characters from start and end of the string
  static String remove3(String input) {
    String temp = input.substring(3);
    return temp.substring(0, temp.length-3);
  }

  static String getExtension(String input) {
    var splitted = input.split(".");
    return splitted[splitted.length-1];
  }


}