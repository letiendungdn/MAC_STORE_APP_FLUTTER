import 'package:flutter/material.dart';
import 'package:mac_store_app/controllers/auth_controllers.dart';

class AccountScreen extends StatelessWidget {
   AccountScreen({super.key});

  final AuthControllers _authController = AuthControllers();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await _authController.signOutUsers(context: context);
          },
          child: const Text('Signout'),
        ),
      ),
    );
  }
}
