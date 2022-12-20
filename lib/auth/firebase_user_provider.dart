import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class FamotyFlutterFirebaseUser {
  FamotyFlutterFirebaseUser(this.user);
  User? user;
  bool get loggedIn => user != null;
}

FamotyFlutterFirebaseUser? currentUser;
bool get loggedIn => currentUser?.loggedIn ?? false;
Stream<FamotyFlutterFirebaseUser> famotyFlutterFirebaseUserStream() =>
    FirebaseAuth.instance
        .authStateChanges()
        .debounce((user) => user == null && !loggedIn
            ? TimerStream(true, const Duration(seconds: 1))
            : Stream.value(user))
        .map<FamotyFlutterFirebaseUser>(
      (user) {
        currentUser = FamotyFlutterFirebaseUser(user);
        return currentUser!;
      },
    );
