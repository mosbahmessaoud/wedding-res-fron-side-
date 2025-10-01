
// lib/models/madaih.dart
class Madaih {
  final int id;
  final String name;
  final int countyId;

  Madaih({
    required this.id,
    required this.name,
    required this.countyId,
  });

  factory Madaih.fromJson(Map<String, dynamic> json) {
    return Madaih(
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

  Madaih copyWith({
    int? id,
    String? name,
    int? countyId,
  }) {
    return Madaih(
      id: id ?? this.id,
      name: name ?? this.name,
      countyId: countyId ?? this.countyId,
    );
  }

  @override
  String toString() {
    return 'Madaih{id: $id, name: $name, countyId: $countyId}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Madaih &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// MadaihCreate model for creating new Madaih committees
class MadaihCreate {
  final String name;
  final int countyId;

  MadaihCreate({
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

// MadaihUpdate model for updating Madaih committees
class MadaihUpdate {
  final String? name;
  final int? countyId;

  MadaihUpdate({
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