import 'package:image_picker/image_picker.dart';

class UserPageController {

  static final UserPageController _instance = UserPageController._internal();

  UserPageController._internal() {
    print("Initializing UserPageController");
  }

  factory UserPageController() {
    return _instance;
  }

  List<String> _elements = ["Select image from Gallery", "Select image from Camera"];

  String getElementAt(int index) {
    return this._elements[index];
  }

  int getElementsLength() {
    return this._elements.length;
  }

  Future<void> pickImageFromCamera() async {
    ImagePicker picker = ImagePicker();
    PickedFile? pickedImage = await picker.getImage(source: ImageSource.camera, imageQuality: 100);
    /*setState(() {
      if (pickedImage != null) {
        _imageFile = File(pickedImage.path);
      } else {
        print("No valid picked Image");
      }
    });*/
  }

  Future<void> pickImageFromGallery() async {
    ImagePicker picker = ImagePicker();
    PickedFile? pickedImage = await picker.getImage(source: ImageSource.gallery, imageQuality: 100);
    /*setState(() {
      if (pickedImage != null) {
        _imageFile = File(pickedImage.path);
      } else {
        print("No valid picked Image");
      }
    });*/
  }

}