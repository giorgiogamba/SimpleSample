import 'Model.dart';

class SamplerController {

  static final SamplerController _instance = SamplerController._internal();

  SamplerController._internal() {}

  factory SamplerController() {
    return _instance;
  }

  bool checkIfUserConnected() {
    return Model().isUserConnected();
  }

}