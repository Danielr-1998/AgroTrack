// lib/src/screens/task_form_screen.dart
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();
  String _tipoTarea = 'Siembra';

  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _guardarTarea() async {
    if (_formKey.currentState!.validate()) {
      await _firestoreService.registrarTarea({
        'tipo': _tipoTarea,
        'descripcion': _descripcionController.text,
        'fecha': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarea registrada')),
      );

      _descripcionController.clear();
      setState(() => _tipoTarea = 'Siembra');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Tarea')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _tipoTarea,
                items: const [
                  DropdownMenuItem(value: 'Siembra', child: Text('Siembra')),
                  DropdownMenuItem(value: 'Poda', child: Text('Poda')),
                  DropdownMenuItem(value: 'Fertilización', child: Text('Fertilización')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _tipoTarea = value);
                },
                decoration: const InputDecoration(labelText: 'Tipo de tarea'),
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingresa una descripción' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarTarea,
                child: const Text('Guardar Tarea'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
