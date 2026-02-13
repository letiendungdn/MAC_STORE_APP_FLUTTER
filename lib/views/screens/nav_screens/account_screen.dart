import 'package:flutter/material.dart';
import 'package:mac_store_app/controllers/auth_controllers.dart';
import 'package:mac_store_app/views/screens/detail/screens/order_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const OrderScreen();
                },
              ),
            );
          },
          child: const Text('My Orders'),
        ),
      ),
    );
  }
}
