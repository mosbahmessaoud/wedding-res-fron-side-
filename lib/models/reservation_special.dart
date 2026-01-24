// models/reservation_special.dart
class ReservationSpecial {
  final int id;
  final int clanId;
  final int countyId;
  final String? fullName;
  final String? homeAddress;
  final String? phoneNumber;
  final String? reservName;
  final String? reservDescription;
  final String date;
  final String status;
  final String createdAt;

  ReservationSpecial({
    required this.id,
    required this.clanId,
    required this.countyId,
    this.fullName,
    this.homeAddress,
    this.phoneNumber,
    this.reservName,
    this.reservDescription,
    required this.date,
    required this.status,
    required this.createdAt,
  });

  factory ReservationSpecial.fromJson(Map<String, dynamic> json) {
    return ReservationSpecial(
      id: json['id'],
      clanId: json['clan_id'],
      countyId: json['county_id'],
      fullName: json['full_name'],
      homeAddress: json['home_address'],
      phoneNumber: json['phone_number'],
      reservName: json['reserv_name'],
      reservDescription: json['reserv_desctiption'],
      date: json['date'],
      status: json['status'],
      createdAt: json['created_at'],
    );
  }
}