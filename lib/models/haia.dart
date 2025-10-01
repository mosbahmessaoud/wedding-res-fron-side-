// lib/models/haia.dart
class Haia {
  final int id;
  final String name;
  final int countyId;

  Haia({
    required this.id,
    required this.name,
    required this.countyId,
  });

  factory Haia.fromJson(Map<String, dynamic> json) {
    return Haia(
      id: json['id'],
      name: json['name'],
      countyId: json['county_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'county_id': countyId,
    };
  }

  Haia copyWith({
    int? id,
    String? name,
    int? countyId,
  }) {
    return Haia(
      id: id ?? this.id,
      name: name ?? this.name,
      countyId: countyId ?? this.countyId,
    );
  }

  @override
  String toString() {
    return 'Haia{id: $id, name: $name, countyId: $countyId}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Haia &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// HaiaCreate model for creating new Haia committees
class HaiaCreate {
  final String name;
  final int countyId;

  HaiaCreate({
    required this.name,
    required this.countyId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'county_id': countyId,
    };
  }
}

// HaiaUpdate model for updating Haia committees
class HaiaUpdate {
  final String? name;
  final int? countyId;

  HaiaUpdate({
    this.name,
    this.countyId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (countyId != null) data['county_id'] = countyId;
    return data;
  }
}
