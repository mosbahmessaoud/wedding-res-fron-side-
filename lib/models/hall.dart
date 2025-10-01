// lib/models/hall.dart
class Hall {
  final int id;
  final String name;
  final int clanId;

  Hall({
    required this.id,
    required this.name,
    required this.clanId,
  });

  factory Hall.fromJson(Map<String, dynamic> json) {
    return Hall(
      id: json['id'],
      name: json['name'],
      clanId: json['clan_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'clan_id': clanId,
    };
  }

  Hall copyWith({
    int? id,
    String? name,
    int? clanId,
  }) {
    return Hall(
      id: id ?? this.id,
      name: name ?? this.name,
      clanId: clanId ?? this.clanId,
    );
  }

  @override
  String toString() {
    return 'Hall{id: $id, name: $name, clanId: $clanId}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Hall &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          clanId == other.clanId;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ clanId.hashCode;
}

// HallCreate model for creating new halls
class HallCreate {
  final String name;
  final int clanId;

  HallCreate({
    required this.name,
    required this.clanId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'clan_id': clanId,
    };
  }
}