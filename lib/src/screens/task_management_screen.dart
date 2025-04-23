import 'package:flutter/material.dart';

class TaskManagementScreen extends StatelessWidget {
  const TaskManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tareas = ['Siembra', 'Poda', 'Fertilización', 'Riego', 'Cosecha'];

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Tareas')),
      body: ListView.builder(
        itemCount: tareas.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.agriculture),
              title: Text(tareas[index]),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Aquí podrías abrir una vista para editar la tarea
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aquí podrías abrir un formulario para crear una nueva tarea
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
