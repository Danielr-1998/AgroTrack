// lib/screens/harvest_register_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HarvestRegisterScreen extends StatefulWidget {
  const HarvestRegisterScreen({super.key});

  @override
  State<HarvestRegisterScreen> createState() => _HarvestRegisterScreenState();
}

class _HarvestRegisterScreenState extends State<HarvestRegisterScreen> {
  final TextEditingController _collectorController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  String? _selectedFarmId;
  String? _selectedFarmName;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _farms = [];

  @override
  void initState() {
    super.initState();
    _loadFarms();
  }

  Future<void> _loadFarms() async {
    final snapshot = await FirebaseFirestore.instance.collection('farms').get();
    setState(() {
      _farms = snapshot.docs;
    });
  }

  Future<void> _saveHarvest() async {
    if (_selectedFarmId == null || _collectorController.text.isEmpty || _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos y selecciona una finca')),
      );
      return;
    }

    final harvestData = {
      'collector': _collectorController.text,
      'quantity': double.tryParse(_quantityController.text) ?? 0.0,
      'date': _selectedDate.toIso8601String(),
      'createdAt': Timestamp.now(),
    };

    await FirebaseFirestore.instance
        .collection('farms')
        .doc(_selectedFarmId)
        .collection('harvests')
        .add(harvestData);

    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Recogida')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedFarmId,
              hint: const Text('Selecciona una finca'),
              items: _farms.map((farm) {
                return DropdownMenuItem<String>(
                  value: farm.id,
                  child: Text(farm['name']),
                );
              }).toList(),
              onChanged: (value) {
                final farm = _farms.firstWhere((f) => f.id == value);
                setState(() {
                  _selectedFarmId = value;
                  _selectedFarmName = farm['name'];
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _collectorController,
              decoration: const InputDecoration(labelText: 'Recolector'),
            ),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Cantidad (kg)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Fecha: ${_selectedDate.toLocal().toString().split(' ')[0]}'),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDate,
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _saveHarvest,
              icon: const Icon(Icons.save),
              label: const Text('Guardar Recogida'),
            ),
          ],
        ),
      ),
    );
  }
}
