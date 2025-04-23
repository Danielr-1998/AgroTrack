import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/task_management_screen.dart';
import '../screens/farm_register_screen.dart'; // Importa la pantalla de registro de finca

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pop(); // Cierra el drawer
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sesión cerrada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.green),
            child: Text(
              'AgroTrack',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Registrar Finca'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const FarmRegisterScreen(),
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.task),
            title: const Text('Gestión de Tareas'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const TaskManagementScreen(),
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: () => _signOut(context),
          ),
        ],
      ),
    );
  }
}
