// lib/models/food_menu.dart
enum FoodType {
  traditional,
  modern,
  mixed,
}

extension FoodTypeExtension on FoodType {
  String get displayName {
    switch (this) {
      case FoodType.traditional:
        return 'تقليدي';
      case FoodType.modern:
        return 'عصري';
      case FoodType.mixed:
        return 'مختلط';
    }
  }

  String get value {
    switch (this) {
      case FoodType.traditional:
        return 'Traditional';
      case FoodType.modern:
        return 'Modern';
      case FoodType.mixed:
        return 'Mixed';
    }
  }

  static FoodType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'traditional':
        return FoodType.traditional;
      case 'modern':
        return FoodType.modern;
      case 'mixed':
        return FoodType.mixed;
      default:
        return FoodType.traditional;
    }
  }
}

class FoodMenu {
  final int id;
  final FoodType foodType;
  final int numberOfVisitors;
  final List<String> menuDetails;

  FoodMenu({
    required this.id,
    required this.foodType,
    required this.numberOfVisitors,
    required this.menuDetails,
  });

  factory FoodMenu.fromJson(Map<String, dynamic> json) {
    return FoodMenu(
      id: json['id'],
      foodType: FoodTypeExtension.fromString(json['food_type']),
      numberOfVisitors: json['number_of_visitors'],
      menuDetails: List<String>.from(json['menu_details'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'food_type': foodType.value,
      'number_of_visitors': numberOfVisitors,
      'menu_details': menuDetails,
    };
  }

  FoodMenu copyWith({
    int? id,
    FoodType? foodType,
    int? numberOfVisitors,
    List<String>? menuDetails,
  }) {
    return FoodMenu(
      id: id ?? this.id,
      foodType: foodType ?? this.foodType,
      numberOfVisitors: numberOfVisitors ?? this.numberOfVisitors,
      menuDetails: menuDetails ?? this.menuDetails,
    );
  }

  // Helper methods
  bool get isForLargeGathering => numberOfVisitors >= 300;
  bool get isForSmallGathering => numberOfVisitors < 200;
  bool get isForMediumGathering => numberOfVisitors >= 200 && numberOfVisitors < 300;

  String get visitorRangeDescription {
    if (isForSmallGathering) return 'تجمع صغير (أقل من 200)';
    if (isForMediumGathering) return 'تجمع متوسط (200-299)';
    return 'تجمع كبير (300+)';
  }

  int get estimatedCostPerPerson {
    // This could be calculated based on food type and menu items
    switch (foodType) {
      case FoodType.traditional:
        return 15000; // IQD
      case FoodType.modern:
        return 25000; // IQD
      case FoodType.mixed:
        return 20000; // IQD
    }
  }

  int get totalEstimatedCost => estimatedCostPerPerson * numberOfVisitors;

  @override
  String toString() {
    return 'FoodMenu{id: $id, foodType: ${foodType.displayName}, visitors: $numberOfVisitors}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodMenu &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// CreateFoodMenuRequest model for creating new food menus
class CreateFoodMenuRequest {
  final FoodType foodType;
  final int numberOfVisitors;
  final List<String> menuItems;
  final int clanId;

  CreateFoodMenuRequest({
    required this.foodType,
    required this.numberOfVisitors,
    required this.menuItems,
    required this.clanId,
  });

  Map<String, dynamic> toJson() {
    return {
      'food_type': foodType.value,
      'number_of_visitors': numberOfVisitors,
      'menu_items': menuItems,
      'clan_id': clanId,
    };
  }

  // Validation
  bool get isValid {
    return menuItems.isNotEmpty && 
           numberOfVisitors >= 100 && 
           numberOfVisitors <= 500 &&
           clanId > 0;
  }

  List<String> get validationErrors {
    List<String> errors = [];
    
    if (menuItems.isEmpty) {
      errors.add('يجب إضافة عناصر القائمة');
    }
    
    if (numberOfVisitors < 100) {
      errors.add('عدد الزوار يجب أن يكون 100 على الأقل');
    }
    
    if (numberOfVisitors > 500) {
      errors.add('عدد الزوار لا يمكن أن يتجاوز 500');
    }
    
    if (clanId <= 0) {
      errors.add('معرف العشيرة غير صحيح');
    }
    
    return errors;
  }
}

// UpdateFoodMenuRequest model for updating existing food menus
class UpdateFoodMenuRequest {
  final List<String> menuItems;
  final FoodType? foodType;
  final int? numberOfVisitors;

  UpdateFoodMenuRequest({
    required this.menuItems,
    this.foodType,
    this.numberOfVisitors,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'menu_items': menuItems,
    };

    if (foodType != null) {
      data['food_type'] = foodType!.value;
    }

    if (numberOfVisitors != null) {
      data['number_of_visitors'] = numberOfVisitors;
    }

    return data;
  }

  bool get isValid {
    return menuItems.isNotEmpty;
  }

  List<String> get validationErrors {
    List<String> errors = [];
    
    if (menuItems.isEmpty) {
      errors.add('يجب إضافة عناصر القائمة');
    }
    
    if (numberOfVisitors != null) {
      if (numberOfVisitors! < 100) {
        errors.add('عدد الزوار يجب أن يكون 100 على الأقل');
      }
      
      if (numberOfVisitors! > 500) {
        errors.add('عدد الزوار لا يمكن أن يتجاوز 500');
      }
    }
    
    return errors;
  }
}

// FoodMenuFilter model for filtering menus
class FoodMenuFilter {
  final FoodType? foodType;
  final int? minVisitors;
  final int? maxVisitors;
  final int? clanId;

  FoodMenuFilter({
    this.foodType,
    this.minVisitors,
    this.maxVisitors,
    this.clanId,
  });

  Map<String, String> toQueryParameters() {
    final Map<String, String> params = {};
    
    if (foodType != null) {
      params['food_type'] = foodType!.value;
    }
    
    if (minVisitors != null) {
      params['min_visitors'] = minVisitors.toString();
    }
    
    if (maxVisitors != null) {
      params['max_visitors'] = maxVisitors.toString();
    }
    
    if (clanId != null) {
      params['clan_id'] = clanId.toString();
    }
    
    return params;
  }

  bool matches(FoodMenu menu) {
    if (foodType != null && menu.foodType != foodType) {
      return false;
    }
    
    if (minVisitors != null && menu.numberOfVisitors < minVisitors!) {
      return false;
    }
    
    if (maxVisitors != null && menu.numberOfVisitors > maxVisitors!) {
      return false;
    }
    
    return true;
  }
}