import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  static void showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: "Close",
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }


}