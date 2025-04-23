import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AgroTrack Inicio')),
      body: Center(
        child: ElevatedButton(
          onPressed: _signOut,
          child: const Text('Cerrar Sesión'),
        ),
      ),
    );
  }
}
