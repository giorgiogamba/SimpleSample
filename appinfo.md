*** APPLICATION ID ***	
com.example.simple_sample

*** COMANDO PER RICAVARE PASSOWRD SHA1 ***
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore
password: android
\n
SHA1 9B:8B:5E:C0:4B:7E:DE:DD:1C:C9:1D:79:8C:A9:C4:F6:67:EB:35:98



service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}