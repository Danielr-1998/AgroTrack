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

  Future<void> _showAllTasksByFarmDialog(BuildContext context, List<QueryDocumentSnapshot> farms) async {
    final Map<String, List<QueryDocumentSnapshot>> tasksByFarm = {};

    for (var farm in farms) {
      final tasksSnapshot = await FirebaseFirestore.instance
          .collection('farms')
          .doc(farm.id)
          .collection('tasks')
          .get();
      tasksByFarm[farm.id] = tasksSnapshot.docs;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tareas por Finca'),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: tasksByFarm.isEmpty
              ? const Center(child: Text('No hay tareas registradas.'))
              : ListView(
                  children: farms.map((farm) {
                    final farmTasks = tasksByFarm[farm.id] ?? [];

                    return ExpansionTile(
                      title: Text(farm['name']),
                      subtitle: Text('Tipo: ${farm['type']}'),
                      leading: const Icon(Icons.forest),
                      children: farmTasks.isEmpty
                          ? [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Sin tareas registradas'),
                              ),
                            ]
                          : farmTasks.map((task) {
                              return ListTile(
                                title: Text(task['type']),
                                subtitle: Text('Fecha: ${task['date']}'),
                                trailing: task['imageUrl'] != ''
                                    ? Image.file(File(task['imageUrl']), width: 50)
                                    : null,
                              );
                            }).toList(),
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

  Future<void> _showFarmsDialog(BuildContext context, List<QueryDocumentSnapshot> farms) async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Fincas Registradas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (farms.isEmpty)
                const Text('No hay fincas registradas.')
              else
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: farms.length,
                    itemBuilder: (context, index) {
                      final farm = farms[index];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          leading: const Icon(Icons.forest),
                          title: Text(farm['name']),
                          subtitle: Text('Tipo: ${farm['type']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_task, color: Colors.green),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _showAddTaskDialog(context, farm.id);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
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
                GestureDetector(
                  onTap: () => _showAllTasksByFarmDialog(context, farms),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.orange[600],
                    child: SizedBox(
                      height: 120,
                      child: Center(
                        child: ListTile(
                          leading: const Icon(Icons.task_alt, size: 40, color: Colors.white),
                          title: Text(
                            'Tareas Registradas',
                            style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),
                          ),
                          subtitle: const Text(
                            'Ver todas las tareas por finca',
                            style: TextStyle(color: Colors.white70),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
