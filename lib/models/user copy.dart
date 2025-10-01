
// // lib/models/user_model.dart
// class User {
//   final int? id;
//   final String phoneNumber;
//   final String firstName;
//   final String lastName;
//   final String fatherName;
//   final String grandfatherName;
//   final DateTime? birthDate;
//   final String? birthAddress;
//   final String? homeAddress;
//   final int? clanId;
//   final int? countyId;
//   final String role;
//   final bool phoneVerified;
//   final String? guardianName;
//   final String? guardianPhone;
//   final String? guardianRelation;

//   User({
//     this.id,
//     required this.phoneNumber,
//     required this.firstName,
//     required this.lastName,
//     required this.fatherName,
//     required this.grandfatherName,
//     this.birthDate,
//     this.birthAddress,
//     this.homeAddress,
//     this.clanId,
//     this.countyId,
//     required this.role,
//     this.phoneVerified = false,
//     this.guardianName,
//     this.guardianPhone,
//     this.guardianRelation,
//   });

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['id'],
//       phoneNumber: json['phone_number'],
//       firstName: json['first_name'],
//       lastName: json['last_name'],
//       fatherName: json['father_name'],
//       grandfatherName: json['grandfather_name'],
//       birthDate: json['birth_date'] != null 
//           ? DateTime.parse(json['birth_date']) 
//           : null,
//       birthAddress: json['birth_address'],
//       homeAddress: json['home_address'],
//       clanId: json['clan_id'],
//       countyId: json['county_id'],
//       role: json['role'],
//       phoneVerified: json['phone_verified'] ?? false,
//       guardianName: json['guardian_name'],
//       guardianPhone: json['guardian_phone'],
//       guardianRelation: json['guardian_relation'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'phone_number': phoneNumber,
//       'first_name': firstName,
//       'last_name': lastName,
//       'father_name': fatherName,
//       'grandfather_name': grandfatherName,
//       'birth_date': birthDate?.toIso8601String()?.split('T')[0],
//       'birth_address': birthAddress,
//       'home_address': homeAddress,
//       'clan_id': clanId,
//       'county_id': countyId,
//       'role': role,
//       'guardian_name': guardianName,
//       'guardian_phone': guardianPhone,
//       'guardian_relation': guardianRelation,
//     };
//   }
// }