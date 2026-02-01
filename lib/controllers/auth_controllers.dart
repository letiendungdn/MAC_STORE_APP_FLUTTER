import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_store_app/global_variables.dart';
import 'package:mac_store_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:mac_store_app/services/manage_http_response.dart';
import 'package:mac_store_app/views/screens/authentiaction/login_screen.dart';
import 'package:mac_store_app/views/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mac_store_app/provider/user_provider.dart';

final providerContainer = ProviderContainer();

class AuthControllers {
  Future<void> signUpUsers({
    required BuildContext context,
    required String email,
    required String fullName,
    required String password,
  }) async {
    try {
      User user = User(
        id: '',
        fullName: fullName,
        email: email,
        state: '',
        city: '',
        locality: '',
        password: password,
        token: '',
      );
      http.Response response = await http.post(
        Uri.parse('$uri/api/signup'),
        body: user
            .toJson(), // Covert the user Object to json for the request body
        headers: <String, String>{
          // Set the Headers for the request
          "Content-Type":
              "application/json;charset=UTF-8", //specify the context types as Json
        },
      );
      if (!context.mounted) return;
      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () async {
          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
          showSnackBar(context, 'Account has been  Create for you');
        },
      );
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  // Signin users function

  Future<void> signInUsers({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse("$uri/api/signin"),
        body: jsonEncode({
          'email': email, // inclue the email in the request body,
          'password': password, //include the password in the request body,
        }),
        headers: <String, String>{
          // Set the Headers for the request
          "Content-Type":
              "application/json;charset=UTF-8", //specify the context types as Json
        },
      );
      if (!context.mounted) return;
      // Handle the response using  the managehttpresponse

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () async {
          //Access sharedPreferences for token and user data storage
          SharedPreferences preferences = await SharedPreferences.getInstance();
          //Extract the authentication token from the response body
          String token = jsonDecode(response.body)['token'];
          //STORE the authentication token securely in sharedPreferences
          await preferences.setString('auth_token', token);
          //Encode the user data recived from the backend as json
          final userJson = jsonEncode(jsonDecode(response.body)['user']);
          // update the user provider with the user data
          providerContainer.read(userProvider.notifier).setUser(userJson);
          // store the user data in the provider container
          await preferences.setString('user', userJson);
          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const MainScreen();
              },
            ), // MaterialPageRoute
            (route) => false,
          );
          showSnackBar(context, 'Logged in');
        },
      );
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  //Update user's state, city and locality
  Future<void> updateUserLocation({
    required BuildContext context,
    required String id,
    required String state,
    required String city,
    required String locality,
  }) async {
    try {
      //Make an HTTP PUT request to update user's state, city and locality
      final http.Response response = await http.put(
        Uri.parse('$uri/api/users/$id'),
        //set the header for the request to specify that the content is Json
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
        //Encode the update data(state, city and locality) AS Json object
        body: jsonEncode({'state': state, 'city': city, 'locality': locality}),
      );
      if (!context.mounted) return;
      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () async {
          //Decode the updated user data from the response body
          //this converts the json String response into Dart Map
          final updatedUser = jsonDecode(response.body);
          //Shared preference for local data storage
          SharedPreferences preferences = await SharedPreferences.getInstance();
          //Encode the update user data as json String
          //this prepares the data for storage in shared preference
          final userJson = jsonEncode(updatedUser);
          //update the application state with the updated user data userin Riverpod
          //this ensures the app reflects the most recent user data
          providerContainer.read(userProvider.notifier).setUser(userJson);
          //store the updated user data in shared preference for future user
          //this allows the app to retrive the user data even after the app restarts
          await preferences.setString('user', userJson);
        },
      );
    } catch (e) {
      //catch any error that occure during the proccess
      //show an error message to the user if the update fails
      showSnackBar(context, 'Error updating location');
    }
  }
}

// Signout users function
Future<void> signOutUsers({required BuildContext context}) async {
  try {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove('auth_token');
    await preferences.remove('user');
    providerContainer.read(userProvider.notifier).signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
    showSnackBar(context, 'Logged out');
  } catch (e) {
    debugPrint("Error: $e");
    showSnackBar(context, 'Error: $e');
  }
}
