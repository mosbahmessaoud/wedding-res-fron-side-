// lib/models/clan.dart
class Clan {
  final int id;
  final String name;
  final int countyId;

  Clan({
    required this.id,
    required this.name,
    required this.countyId,
  });

  factory Clan.fromJson(Map<String, dynamic> json) {
    return Clan(
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

  Clan copyWith({
    int? id,
    String? name,
    int? countyId,
  }) {
    return Clan(
      id: id ?? this.id,
      name: name ?? this.name,
      countyId: countyId ?? this.countyId,
    );
  }

  @override
  String toString() {
    return 'Clan{id: $id, name: $name, countyId: $countyId}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Clan &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          countyId == other.countyId;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ countyId.hashCode;
}

// ClanCreate model for creating new clans
class ClanCreate {
  final String name;
  final int countyId;

  ClanCreate({
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

// ClanUpdate model for updating clans
class ClanUpdate {
  final String? name;
  final int? countyId;

  ClanUpdate({
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

// ClanSettings model for clan configuration
class ClanSettings {
  final int id;
  final int clanId;
  final int? maxGroomsPerDate;
  final bool? allowTwoDayReservations;
  final int? validationDeadlineDays;
  final String? allowedMonthsSingleDay;
  final String? allowedMonthsTwoDay;
  final int? calendarYearsAhead;

  ClanSettings({
    required this.id,
    required this.clanId,
    this.maxGroomsPerDate,
    this.allowTwoDayReservations,
    this.validationDeadlineDays,
    this.allowedMonthsSingleDay,
    this.allowedMonthsTwoDay,
    this.calendarYearsAhead,
  });

  factory ClanSettings.fromJson(Map<String, dynamic> json) {
    return ClanSettings(
      id: json['id'],
      clanId: json['clan_id'],
      maxGroomsPerDate: json['max_grooms_per_date'],
      allowTwoDayReservations: json['allow_two_day_reservations'],
      validationDeadlineDays: json['validation_deadline_days'],
      allowedMonthsSingleDay: json['allowed_months_single_day'],
      allowedMonthsTwoDay: json['allowed_months_two_day'],
      calendarYearsAhead: json['calendar_years_ahead'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clan_id': clanId,
      'max_grooms_per_date': maxGroomsPerDate,
      'allow_two_day_reservations': allowTwoDayReservations,
      'validation_deadline_days': validationDeadlineDays,
      'allowed_months_single_day': allowedMonthsSingleDay,
      'allowed_months_two_day': allowedMonthsTwoDay,
      'calendar_years_ahead': calendarYearsAhead,
    };
  }

  ClanSettings copyWith({
    int? id,
    int? clanId,
    int? maxGroomsPerDate,
    bool? allowTwoDayReservations,
    int? validationDeadlineDays,
    String? allowedMonthsSingleDay,
    String? allowedMonthsTwoDay,
    int? calendarYearsAhead,
  }) {
    return ClanSettings(
      id: id ?? this.id,
      clanId: clanId ?? this.clanId,
      maxGroomsPerDate: maxGroomsPerDate ?? this.maxGroomsPerDate,
      allowTwoDayReservations: allowTwoDayReservations ?? this.allowTwoDayReservations,
      validationDeadlineDays: validationDeadlineDays ?? this.validationDeadlineDays,
      allowedMonthsSingleDay: allowedMonthsSingleDay ?? this.allowedMonthsSingleDay,
      allowedMonthsTwoDay: allowedMonthsTwoDay ?? this.allowedMonthsTwoDay,
      calendarYearsAhead: calendarYearsAhead ?? this.calendarYearsAhead,
    );
  }
}

// ClanSettingsUpdate model for updating clan settings
class ClanSettingsUpdate {
  final int? maxGroomsPerDate;
  final bool? allowTwoDayReservations;
  final int? validationDeadlineDays;
  final String? allowedMonthsSingleDay;
  final String? allowedMonthsTwoDay;
  final int? calendarYearsAhead;

  ClanSettingsUpdate({
    this.maxGroomsPerDate,
    this.allowTwoDayReservations,
    this.validationDeadlineDays,
    this.allowedMonthsSingleDay,
    this.allowedMonthsTwoDay,
    this.calendarYearsAhead,
  });

  Map<String, dynamic> toJson() {
    return {
      'max_grooms_per_date': maxGroomsPerDate,
      'allow_two_day_reservations': allowTwoDayReservations,
      'validation_deadline_days': validationDeadlineDays,
      'allowed_months_single_day': allowedMonthsSingleDay,
      'allowed_months_two_day': allowedMonthsTwoDay,
      'calendar_years_ahead': calendarYearsAhead,
    };
  }
}