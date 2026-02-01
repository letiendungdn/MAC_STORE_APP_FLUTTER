import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_store_app/models/user.dart';

class UserProvider extends Notifier<User?> {
  // contructore initializing with default User Object
  //purpose: Mange the state of the user object allowing updates
  @override
  User? build() {
    return User(
      id: '',
      fullName: '',
      email: '',
      state: '',
      city: '',
      locality: '',
      password: '',
      token: '',
    );
  }

  //Getter method to extract value from an object
  User? get user => state;

  //method to set user state from Json
  //purpose : udates he user sate base on json String respresentation of user Object
  void setUser(String userJson) {
    state = User.fromJson(userJson);
  }

  void signOut() {
    state = null;
  }

  //Method to Recreate the user state
  void recreateUserState({
    required String state,
    required String city,
    required String locality,
  }) {
    if (this.state != null) {
      this.state = User(
        id: this.state!.id,
        fullName: this.state!.fullName,
        email: this.state!.email,
        state: state,
        city: city,
        locality: locality,
        password: this.state!.password,
        token: this.state!.token,
      );
    }
  }
}

//make the data accisible within the application
final userProvider = NotifierProvider<UserProvider, User?>(UserProvider.new);
