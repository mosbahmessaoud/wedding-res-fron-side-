// lib/models/county.dart
class County {
  final int id;
  final String name;

  County({
    required this.id,
    required this.name,
  });

  factory County.fromJson(Map<String, dynamic> json) {
    return County(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  County copyWith({
    int? id,
    String? name,
  }) {
    return County(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  String toString() {
    return 'County{id: $id, name: $name}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is County &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

// CountyCreate model for creating new counties
class CountyCreate {
  final String name;

  CountyCreate({
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

// CountyUpdate model for updating counties
class CountyUpdate {
  final String? name;

  CountyUpdate({
    this.name,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    return data;
  }
}