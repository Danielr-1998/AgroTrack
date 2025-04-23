// src/models/farm.dart
class Farm {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String type;

  Farm({required this.id, required this.name, required this.latitude, required this.longitude, required this.type});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'type': type,
    };
  }

  factory Farm.fromMap(Map<String, dynamic> map, String id) {
    return Farm(
      id: id,
      name: map['name'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      type: map['type'],
    );
  }
}
