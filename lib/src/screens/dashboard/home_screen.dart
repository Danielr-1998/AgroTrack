import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/');
  }

  Future<void> _showAddTaskDialog(BuildContext context, String farmId) async {
    final _taskTypeController = TextEditingController();
    final _quantityController = TextEditingController();
    final _dateController = TextEditingController();
    XFile? _image;

    DateTime selectedDate = DateTime.now();
    final ImagePicker picker = ImagePicker();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Agregar Tarea'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Tipo de tarea'),
                    items: const [
                      DropdownMenuItem(value: 'Siembra', child: Text('Siembra')),
                      DropdownMenuItem(value: 'Poda', child: Text('Poda')),
                    ],
                    onChanged: (value) => _taskTypeController.text = value!,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Fecha'),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                          _dateController.text = '${picked.toLocal()}'.split(' ')[0];
                        });
                      }
                    },
                  ),
                  if (_taskTypeController.text == 'Siembra')
                    TextField(
                      controller: _quantityController,
                      decoration: const InputDecoration(labelText: 'Cantidad'),
                      keyboardType: TextInputType.number,
                    ),
                  const SizedBox(height: 12),
                  _image == null
                      ? ElevatedButton.icon(
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Tomar Foto'),
                          onPressed: () async {
                            final image = await picker.pickImage(source: ImageSource.camera);
                            setState(() {
                              _image = image;
                            });
                          },
                        )
                      : Image.file(File(_image!.path), height: 100),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final taskType = _taskTypeController.text;
                final taskData = {
                  'type': taskType,
                  'date': _dateController.text,
                  'imageUrl': _image?.path ?? '',
                  'createdAt': FieldValue.serverTimestamp(),
                };

                if (taskType == 'Siembra') {
                  taskData['quantity'] = int.tryParse(_quantityController.text) ?? 0;
                }

                await FirebaseFirestore.instance
                    .collection('farms')
                    .doc(farmId)
                    .collection('tasks')
                    .add(taskData);

                // Actualizar el contador de tareas
                FirebaseFirestore.instance.collection('farms').doc(farmId).update({
                  'taskCount': FieldValue.increment(1),
                });

                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPickupDialog(BuildContext context, List<QueryDocumentSnapshot> farms) async {
    String? selectedFarmId;
    final pickerNameController = TextEditingController();
    final quantityController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Registrar Recogida'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedFarmId,
                hint: const Text('Seleccione una finca'),
                items: farms.map((farm) {
                  return DropdownMenuItem<String>(value: farm.id, child: Text(farm['name']));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedFarmId = value!;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pickerNameController,
                decoration: const InputDecoration(labelText: 'Nombre del recolector'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (selectedFarmId != null) {
                  final pickupData = {
                    'picker': pickerNameController.text,
                    'quantity': int.tryParse(quantityController.text) ?? 0,
                    'date': FieldValue.serverTimestamp(),
                  };

                  await FirebaseFirestore.instance
                      .collection('farms')
                      .doc(selectedFarmId)
                      .collection('pickups')
                      .add(pickupData);

                  // Actualizar el contador de recogidas
                  FirebaseFirestore.instance.collection('farms').doc(selectedFarmId).update({
                    'pickupCount': FieldValue.increment(1),
                  });

                  Navigator.of(context).pop();
                }
              },
              child: const Text('Guardar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Panel Principal'),
        backgroundColor: Colors.green[800],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('farms').snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los datos.'));
          }

          final farms = snapshot.data!.docs;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collectionGroup('tasks').snapshots(),
            builder: (ctx, taskSnapshot) {
              if (taskSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final tasks = taskSnapshot.data!.docs;

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collectionGroup('pickups').snapshots(),
                builder: (ctx, pickupSnapshot) {
                  if (pickupSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final pickups = pickupSnapshot.data!.docs;
                  final totalPickups = pickups.fold<int>(
                    0,
                    (sum, doc) => sum + ((doc['quantity'] ?? 0) as num).toInt(),
                  );

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildDashboardCard(
                          icon: Icons.forest,
                          title: 'Fincas Registradas',
                          subtitle: '${farms.length} fincas',
                          color: Colors.green,
                          onTap: () => _showFarmsDialog(context, farms),
                        ),
                        const SizedBox(height: 16),
                        _buildDashboardCard(
                          icon: Icons.task_alt,
                          title: 'Tareas Registradas',
                          subtitle: '${tasks.length} tareas',
                          color: Colors.blue,
                          onTap: () {
                            // Aquí se puede agregar el código necesario para mostrar tareas
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildDashboardCard(
                          icon: Icons.local_shipping,
                          title: 'Recogidas Registradas',
                          subtitle: '${pickups.length} registros',
                          color: Colors.orange,
                          onTap: () => _showPickupDialog(context, farms),
                        ),
                        const SizedBox(height: 16),
                        _buildDashboardCard(
                          icon: Icons.numbers,
                          title: 'Total de Recogidas',
                          subtitle: '$totalPickups unidades',
                          color: Colors.deepPurple,
                          onTap: () {},
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text("Registrar Recogida"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: () => _showPickupDialog(context, farms),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text("Registrar Tarea"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          onPressed: () => _showAddTaskDialog(context, farms.first.id),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  void _showFarmsDialog(BuildContext context, List<QueryDocumentSnapshot> farms) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fincas Registradas'),
        content: SingleChildScrollView(
          child: Column(
            children: farms.map((farm) {
              return ListTile(
                title: Text(farm['name']),
                subtitle: Text('Tipo: ${farm['type']}'),
              );
            }).toList(),
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
}
