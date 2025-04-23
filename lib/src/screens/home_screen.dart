import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AgroTrack Inicio')),
      drawer: const AppDrawer(),
      body: Center(
        child: ElevatedButton(
          onPressed: _signOut,
          child: const Text('Cerrar Sesión'),
        ),
      ),
    );
  }
}
