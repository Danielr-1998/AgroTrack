import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/');
  }

  void _showFarmsDialog(BuildContext context, List<QueryDocumentSnapshot> farms) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fincas Registradas'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: farms.length,
            itemBuilder: (context, index) {
              final farm = farms[index];
              return ListTile(
                leading: const Icon(Icons.agriculture),
                title: Text(farm['name']),
                subtitle: Text('Tipo: ${farm['type']}'),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard AgroTrack'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('farms').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error cargando datos'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final farms = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _showFarmsDialog(context, farms),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.green[600],
                    child: SizedBox(
                      height: 120,
                      child: Center(
                        child: ListTile(
                          leading: const Icon(Icons.forest, size: 40, color: Colors.white),
                          title: Text(
                            'Fincas Registradas',
                            style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),
                          ),
                          subtitle: Text(
                            '${farms.length} finca(s)',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Puedes añadir más cards aquí (ej: tareas pendientes, clima, etc.)
              ],
            ),
          );
        },
      ),
    );
  }
}
