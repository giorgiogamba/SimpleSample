/// Class representing the application User
class User {

  //todo indicare come campi tutte le informazioni private dell'utente utili alla sua identificazione

  String? firstName;
  String? secondName;
  String? email;
  String? username;

  User(String? firstName, String? secondName, String? email, String? username) {
    if (firstName != null) {
      this.firstName = firstName;
    }
    if (secondName != null) {
      this.secondName = secondName;
    }
    if (email != null) {
      this.email = email;
    }
    if (username != null) {
      this.username;
    }
  }

  String? getFirstName() {
    return this.firstName;
  }

  void setFirstName(String name) {
    this.firstName = name;
  }

  String? getSecondName() {
    return this.secondName;
  }

  void setSecondName(String name) {
    this.secondName = name;
  }

  String? getEmail() {
    return this.email;
  }

  void setEmail (String email) {
    this.email = email;
  }

  String? getUsername() {
    return this.username;
  }

  void setUsername(String username) {
    this.username = username;
  }




}