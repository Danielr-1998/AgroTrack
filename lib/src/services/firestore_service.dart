// lib/src/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference tareas = FirebaseFirestore.instance.collection('tareas');

  Future<void> registrarTarea(Map<String, dynamic> tareaData) async {
    await tareas.add(tareaData);
  }
}
