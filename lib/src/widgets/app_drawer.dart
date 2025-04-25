import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../screens/task_management_screen.dart';
import '../screens/farm_register_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sesión cerrada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: const Text("Bienvenido", style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: const Text("usuario@agrotrack.com"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(LucideIcons.leaf, color: Colors.green, size: 30),
            ),
          ),
          ListTile(
            leading: const Icon(LucideIcons.mapPin, color: Colors.green),
            title: const Text('Registrar Finca', style: TextStyle(fontSize: 16)),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const FarmRegisterScreen(),
              ));
            },
          ),
          ListTile(
            leading: const Icon(LucideIcons.clipboardList, color: Colors.green),
            title: const Text('Gestión de Tareas', style: TextStyle(fontSize: 16)),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const TaskManagementScreen(),
              ));
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
              icon: const Icon(LucideIcons.logOut, color: Colors.white),
              label: const Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
              onPressed: () => _signOut(context),
            ),
          ),
        ],
      ),
    );
  }
}
