// lib/models/user.dart
class User {
  final int id;
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String fatherName;
  final String grandfatherName;
  final DateTime? birthDate;
  final String? birthAddress;
  final String? homeAddress;
  final int? clanId;
  final int? countyId;
  final String role;
  final bool phoneVerified;
  final String? guardianName;
  final String? guardianPhone;
  final String? guardianRelation;

  User({
    required this.id,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.fatherName,
    required this.grandfatherName,
    this.birthDate,
    this.birthAddress,
    this.homeAddress,
    this.clanId,
    this.countyId,
    required this.role,
    this.phoneVerified = false,
    this.guardianName,
    this.guardianPhone,
    this.guardianRelation,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      phoneNumber: json['phone_number'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      fatherName: json['father_name'],
      grandfatherName: json['grandfather_name'],
      birthDate: json['birth_date'] != null ? DateTime.parse(json['birth_date']) : null,
      birthAddress: json['birth_address'],
      homeAddress: json['home_address'],
      clanId: json['clan_id'],
      countyId: json['county_id'],
      role: json['role'],
      phoneVerified: json['phone_verified'] ?? false,
      guardianName: json['guardian_name'],
      guardianPhone: json['guardian_phone'],
      guardianRelation: json['guardian_relation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'first_name': firstName,
      'last_name': lastName,
      'father_name': fatherName,
      'grandfather_name': grandfatherName,
      'birth_date': birthDate?.toIso8601String().split('T')[0],
      'birth_address': birthAddress,
      'home_address': homeAddress,
      'clan_id': clanId,
      'county_id': countyId,
      'role': role,
      'phone_verified': phoneVerified,
      'guardian_name': guardianName,
      'guardian_phone': guardianPhone,
      'guardian_relation': guardianRelation,
    };
  }

  User copyWith({
    int? id,
    String? phoneNumber,
    String? firstName,
    String? lastName,
    String? fatherName,
    String? grandfatherName,
    DateTime? birthDate,
    String? birthAddress,
    String? homeAddress,
    int? clanId,
    int? countyId,
    String? role,
    bool? phoneVerified,
    String? guardianName,
    String? guardianPhone,
    String? guardianRelation,
  }) {
    return User(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fatherName: fatherName ?? this.fatherName,
      grandfatherName: grandfatherName ?? this.grandfatherName,
      birthDate: birthDate ?? this.birthDate,
      birthAddress: birthAddress ?? this.birthAddress,
      homeAddress: homeAddress ?? this.homeAddress,
      clanId: clanId ?? this.clanId,
      countyId: countyId ?? this.countyId,
      role: role ?? this.role,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      guardianName: guardianName ?? this.guardianName,
      guardianPhone: guardianPhone ?? this.guardianPhone,
      guardianRelation: guardianRelation ?? this.guardianRelation,
    );
  }

  String get fullName => '$firstName $lastName';
  String get fullNameWithFather => '$firstName $lastName $fatherName';
  String get fullNameComplete => '$firstName $lastName $fatherName $grandfatherName';
  
  bool get isGroom => role == 'groom';
  bool get isClanAdmin => role == 'clan_admin';
  bool get isSuperAdmin => role == 'super_admin';
  
  @override
  String toString() {
    return 'User{id: $id, phoneNumber: $phoneNumber, fullName: $fullName, role: $role}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          phoneNumber == other.phoneNumber;

  @override
  int get hashCode => id.hashCode ^ phoneNumber.hashCode;
}

// UserCreate model for registration
class UserCreate {
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String fatherName;
  final String grandfatherName;
  final DateTime? birthDate;
  final String? birthAddress;
  final String? homeAddress;
  final int? clanId;
  final int? countyId;
  final String password;
  final String role;
  final String? guardianName;
  final String? guardianPhone;
  final String? guardianRelation;

  UserCreate({
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.fatherName,
    required this.grandfatherName,
    this.birthDate,
    this.birthAddress,
    this.homeAddress,
    this.clanId,
    this.countyId,
    required this.password,
    required this.role,
    this.guardianName,
    this.guardianPhone,
    this.guardianRelation,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'first_name': firstName,
      'last_name': lastName,
      'father_name': fatherName,
      'grandfather_name': grandfatherName,
      'birth_date': birthDate?.toIso8601String().split('T')[0],
      'birth_address': birthAddress,
      'home_address': homeAddress,
      'clan_id': clanId,
      'county_id': countyId,
      'password': password,
      'role': role,
      'guardian_name': guardianName,
      'guardian_phone': guardianPhone,
      'guardian_relation': guardianRelation,
    };
  }
}

// UserUpdate model for profile updates
class UserUpdate {
  final String? password;
  final String? firstName;
  final String? lastName;
  final String? fatherName;
  final String? grandfatherName;
  final DateTime? birthDate;
  final String? birthAddress;
  final String? homeAddress;
  final int? clanId;
  final int? countyId;
  final String? guardianName;
  final String? guardianPhone;
  final String? guardianRelation;

  UserUpdate({
    this.password,
    this.firstName,
    this.lastName,
    this.fatherName,
    this.grandfatherName,
    this.birthDate,
    this.birthAddress,
    this.homeAddress,
    this.clanId,
    this.countyId,
    this.guardianName,
    this.guardianPhone,
    this.guardianRelation,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (password != null) data['password'] = password;
    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    if (fatherName != null) data['father_name'] = fatherName;
    if (grandfatherName != null) data['grandfather_name'] = grandfatherName;
    if (birthDate != null) data['birth_date'] = birthDate!.toIso8601String().split('T')[0];
    if (birthAddress != null) data['birth_address'] = birthAddress;
    if (homeAddress != null) data['home_address'] = homeAddress;
    if (clanId != null) data['clan_id'] = clanId;
    if (countyId != null) data['county_id'] = countyId;
    if (guardianName != null) data['guardian_name'] = guardianName;
    if (guardianPhone != null) data['guardian_phone'] = guardianPhone;
    if (guardianRelation != null) data['guardian_relation'] = guardianRelation;
    
    return data;
  }
}