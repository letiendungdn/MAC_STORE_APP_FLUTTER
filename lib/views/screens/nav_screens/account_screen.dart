import 'package:flutter/material.dart';
import 'package:mac_store_app/controllers/auth_controllers.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await signOutUsers(context: context);
          },
          child: const Text('Signout'),
        ),
      ),
    );
  }
}
