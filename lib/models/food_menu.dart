// lib/models/food_menu.dart
class FoodMenu {
  final int id;
  final String foodType;
  final int numberOfVisitors;
  final List<String> menuDetails;
  final int clanId;

  FoodMenu({
    required this.id,
    required this.foodType,
    required this.numberOfVisitors,
    required this.menuDetails,
    required this.clanId,
  });

  factory FoodMenu.fromJson(Map<String, dynamic> json) {
    return FoodMenu(
      id: json['id'],
      foodType: json['food_type'],
      numberOfVisitors: json['number_of_visitors'],
      menuDetails: List<String>.from(json['menu_items']),
      clanId: json['clan_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'food_type': foodType,
      'number_of_visitors': numberOfVisitors,
      'menu_items': menuDetails,
      'clan_id': clanId,
    };
  }
}