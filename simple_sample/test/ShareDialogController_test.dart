import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_sample/Controllers/ShareDialogController.dart';
import 'package:simple_sample/Models/Model.dart';

void main() {

  setUpAll(() {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '.';
    });
  });

  test("AddToSelectedtags", () {
    final model = Model();

    ShareDialogController().addToSelectedTags(0);
    String tag2 = model.getTagAt(0);

    List<String> tags = ShareDialogController().getSelectedTags();

    expect(tags[0], tag2);
  });

  test("RemoveFromSelectedTags", () {
    ShareDialogController().addToSelectedTags(0);
    expect(ShareDialogController().getSelectedTags().length, 1);

    ShareDialogController().removeFromSelectedTags(0);
    expect(ShareDialogController().getSelectedTags().length, 0);
  });



}