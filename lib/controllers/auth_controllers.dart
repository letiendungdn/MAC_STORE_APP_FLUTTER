import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_store_app/global_variables.dart';
import 'package:mac_store_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:mac_store_app/services/manage_http_response.dart';
import 'package:mac_store_app/views/screens/authentiaction/login_screen.dart';
import 'package:mac_store_app/views/screens/authentiaction/otp_screen.dart';
import 'package:mac_store_app/views/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mac_store_app/provider/user_provider.dart';
import 'package:mac_store_app/provider/delivered_order_count_provider.dart';

class AuthControllers {
  Future<void> signUpUsers({
    required BuildContext context,
    required String fullName,
    required String email,
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
        body: user.toJson(),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () async {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
            builder: (context) {
              return OtpScreen(email: email); // Pass email to OTP screen
            },
          ), (route) => false);
          showSnackBar(context, 'Account created. Please verify your OTP.');
        },
      );
    } catch (e) {
      showSnackBar(context, 'Error: $e');
    }
  }

  Future<void> signInUsers({
    required BuildContext context,
    required String email,
    required String password,
    required WidgetRef ref,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse("$uri/api/signin"),
        body: jsonEncode(
            {"email": email, "password": password}), // Create a map here
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8'
        },
      );

      manageHttpResponse(
          response: response,
          context: context,
          onSuccess: () async {
            //Access sharedPreferences for token and user data storage
            SharedPreferences preferences =
                await SharedPreferences.getInstance();

            //Extract the authentication token from the response body
            String token = jsonDecode(response.body)['token'];

            //STORE the authentication token securely in sharedPreferences

            preferences.setString('auth_token', token);

            //Encode the user data recived from the backend as json
            final userJson = jsonEncode(jsonDecode(response.body));

            //update the application state with the user data using Riverpod
            ref.read(userProvider.notifier).setUser(response.body);

            //store the data in sharePreference  for future use

            await preferences.setString('user', userJson);

            if (ref.read(userProvider)!.token.isNotEmpty) {
              Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (context) {
                return MainScreen();
              }), (route) => false);

              showSnackBar(context, 'Logged in');
            }
          });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  getUserData(context, WidgetRef ref) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      String? token = preferences.getString('auth_token');

      if (token == null) {
        preferences.setString('auth_token', '');
      }

      var tokenResponse = await http.post(
        Uri.parse('$uri/tokenIsValid'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
          'x-auth-token': token!,
        },
      );

      var response = jsonDecode(tokenResponse.body);
      if (response == true) {
        http.Response userResponse = await http.get(
          Uri.parse('$uri/'),
          headers: <String, String>{
            "Content-Type": 'application/json; charset=UTF-8',
            'x-auth-token': token,
          },
        );

        ref.read(userProvider.notifier).setUser(userResponse.body);
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  //Signout

  Future<void> signOutUsers({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      //clear the token and user from SharedPreferenace
      await preferences.remove('auth_token');
      await preferences.remove('user');
      //clear the user state
      ref.read(userProvider.notifier).signOut();
      ref.read(deliveredOrderCountProvider.notifier).resetCount();

      //navigate the user back to the login screen

      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) {
        return const LoginScreen();
      }), (route) => false);

      showSnackBar(context, 'signout successfully');
    } catch (e) {
      showSnackBar(context, "error signing out");
    }
  }

  //Update user's state, city and locality
  Future<bool> updateUserLocation({
    required BuildContext context,
    required String id,
    required String state,
    required String city,
    required String locality,
    required WidgetRef ref,
  }) async {
    try {
      //Make an HTTP PUT request to update user's state, city and locality
      final http.Response response = await http.put(
        Uri.parse('$uri/api/users/$id'),
        //set the header for the request to specify   that the content  is Json
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8'
        },
        //Encode the update data(state, city and locality) AS  Json object
        body: jsonEncode({
          'state': state,
          'city': city,
          'locality': locality,
        }),
      );

      if (!context.mounted) return false;
      final success = response.statusCode == 200 || response.statusCode == 201;

      manageHttpResponse(
          response: response,
          context: context,
          onSuccess: () async {
            //Decode the updated user data from the response body
            //this converts the json String response into Dart Map
            final updatedUser = jsonDecode(response.body);
            //Access Shared preference for local data storage
            //shared preferences allow us to store data persisitently on the the device
            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            //Encode the update user data as json String
            //this prepares the data for storage in shared preference
            final userJson = jsonEncode(updatedUser);

            //update the application state with the updated user data  using Riverpod
            //this ensures the app reflects the most recent user data
            ref.read(userProvider.notifier).setUser(userJson);

            //store the updated user data in shared preference  for future user
            //this allows the app to retrive the user data  even after the app restarts
            await preferences.setString('user', userJson);
          });
      return success;
    } catch (e) {
      //catch any error that occure during the proccess
      //show an error message to the user if the update fails
      if (context.mounted) {
        showSnackBar(context, 'Error updating location');
      }
      return false;
    }
  }

//Verify Otp Method

  Future<void> verifyOtp({
    required BuildContext context,
    required String email,
    required String otp,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse('$uri/api/verify-otp'),
        body: jsonEncode({
          "email": email,
          'otp': otp,
        }),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8'
        },
      );

      manageHttpResponse(
          response: response,
          context: context,
          onSuccess: () async {
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (context) {
              return const LoginScreen();
            }), (route) => false);
            showSnackBar(context, 'Account verified . Please log in.');
          });
    } catch (e) {
      showSnackBar(context, 'Error verifying  OTP:  $e');
    }
  }

  Future<void> deleteAccount(
      {required BuildContext context,
      required String id,
      required WidgetRef ref // Access to the Riverpod Provider
      }) async {
    try {
      //Get the authentication token from  shared preferences  for authorization
      SharedPreferences preferences = await SharedPreferences.getInstance();

      String? token = preferences.getString('auth_token');

      if (token == null) {
        showSnackBar(context, 'You need  to log in to perform  this action');
        return;
      }

      //Send DELETE REQUEST TO THE BACKEND API

      http.Response response = await http.delete(
        Uri.parse("$uri/api/user/delete-account/$id"),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      manageHttpResponse(
          response: response,
          context: context,
          onSuccess: () async {
            //handle successfull deletion , navigate the  user  back to the login screen

            //clear user data from sharedPreferences
            await preferences.remove('auth_token');

            await preferences.remove('user');

            //clear the user data from the provider  state
            ref.read(userProvider.notifier).signOut();

            //Redirect to the login screen after succesful deletion

            showSnackBar(context, 'Account deleted successfully');

            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
              builder: (context) {
                return const LoginScreen(); // Pass email to OTP screen
              },
            ), (route) => false);
          });
    } catch (e) {
      showSnackBar(context, "Error deleting account $e");
    }
  }
}