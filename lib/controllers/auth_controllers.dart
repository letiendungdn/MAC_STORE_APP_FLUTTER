import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mac_store_app/global_variables.dart';
import 'package:mac_store_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:mac_store_app/services/manage_http_response.dart';
import 'package:mac_store_app/views/screens/authentiaction_screens/login_screen.dart';
import 'package:mac_store_app/views/screens/main_screen.dart';

class AuthControllers {
  Future<void> signUpUsers({
    required context,
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
      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
          showSnackBar(context, 'Account has been  Create for you');
        },
      );
    } catch (e) {
      print("Error: $e");
    }
  }

  // Signin users function

  Future<void> signInUsers({
    required context,
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
      // Handle the response using  the managehttpresponse

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
          showSnackBar(context, 'Logged In');
        },
      );
    } catch (e) {
      print("Error: $e");
    }
  }
}
