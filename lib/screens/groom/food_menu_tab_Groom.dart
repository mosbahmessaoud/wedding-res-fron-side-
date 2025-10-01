// lib/screens/clan_admin/food_tab.dart
import 'package:flutter/material.dart';
import 'package:wedding_reservation_app/services/api_service.dart';

class FoodMenuTabG extends StatefulWidget {
  const FoodMenuTabG({super.key});

  @override
  State<FoodMenuTabG> createState() => FoodMenuTabGState();
}

class FoodMenuTabGState extends State<FoodMenuTabG> {
  List<dynamic> _menus = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedFoodType = 'الكل';
  int _selectedVisitors = 0;

  List<String> _foodTypes = [];
  List<int> _visitorOptions = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void refreshData() {

    _loadInitialData();
    setState(() {
      // Trigger rebuild
    });
  }
  
Future<void> _loadInitialData() async {
  await Future.wait([
    _loadFoodTypes(),
    _loadVisitorOptions(), 
    _loadMenus(),
  ]);
  
  // Refresh the UI to update dropdown options after menus are loaded
  if (mounted) {
    setState(() {});
  }
}


  // Add these methods to get unique values from existing menus:

List<String> get _uniqueFoodTypes {
  final Set<String> foodTypes = {'الكل'}; // Add "All" option
  for (final menu in _menus) {
    final foodType = menu['food_type'] ?? '';
    if (foodType.isNotEmpty) {
      foodTypes.add(foodType);
    }
  }
  return foodTypes.toList();
}

List<int> get _uniqueVisitorCounts {
  final Set<int> visitorCounts = {0}; // Add "All" option (0 means all)
  for (final menu in _menus) {
    final visitors = menu['number_of_visitors'] ?? 0;
    if (visitors > 0) {
      visitorCounts.add(visitors);
    }
  }
  final sortedList = visitorCounts.toList();
  sortedList.sort();
  return sortedList;
}




  Future<void> _loadFoodTypes() async {
    try {
      final foodTypes = await ApiService.getFoodTypes();
      setState(() {
        _foodTypes = List<String>.from(foodTypes);
      });
    } catch (e) {
      // Fallback to default values if API fails
      setState(() {
        _foodTypes = ['فريق', 'كسكس', 'كباب'];
      });
    }
  }

  Future<void> _loadVisitorOptions() async {
    try {
      final visitorOptions = await ApiService.getVisitorOptions();
      setState(() {
        _visitorOptions = List<int>.from(visitorOptions);
      });
    } catch (e) {
      // Fallback to default values if API fails
      setState(() {
        _visitorOptions = [50, 100, 150, 200, 250, 300, 350,  400,450 , 500 ,600];
      });
    }
  }

  Future<void> _loadMenus() async {
    setState(() => _isLoading = true);
    try {
      final menus = await ApiService.getClanMenus();
      setState(() {
        _menus = menus;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('خطأ في تحميل القوائم: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  List<dynamic> get _filteredMenus {
    return _menus.where((menu) {
      final menuDetails = menu['menu_details'] ?? [];
      final foodType = menu['food_type'] ?? '';
      final numberOfVisitors = menu['number_of_visitors'] ?? 0;
      
      final matchesSearch = menuDetails.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          foodType.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFoodType = _selectedFoodType == 'الكل' || foodType == _selectedFoodType;
      final matchesVisitors = _selectedVisitors == 0 || numberOfVisitors == _selectedVisitors;
      
      return matchesSearch && matchesFoodType && matchesVisitors;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildMenusList(),
          ),
        ],
      ),

    );
  }



Widget _buildFilters() {
  return Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        // Search bar
        TextField(
          decoration: InputDecoration(
            hintText: 'البحث في القوائم...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
        ),
        const SizedBox(height: 16),
        
        // Filter row
        Row(
          children: [
            // Food type dropdown
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedFoodType,
                decoration: InputDecoration(
                  labelText: 'نوع الطعام',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: _uniqueFoodTypes.map((String foodType) {
                  return DropdownMenuItem<String>(
                    value: foodType,
                    child: Text(foodType),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedFoodType = newValue ?? 'الكل';
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            
            // Visitors dropdown
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _selectedVisitors,
                decoration: InputDecoration(
                  labelText: 'عدد الزوار',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: _uniqueVisitorCounts.map((int visitors) {
                  return DropdownMenuItem<int>(
                    value: visitors,
                    child: Text(visitors == 0 ? 'الكل' : visitors.toString()),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedVisitors = newValue ?? 0;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

  Widget _buildMenusList() {
    final filteredMenus = _filteredMenus;
    
    if (filteredMenus.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _menus.isEmpty ? 'لا توجد قوائم طعام' : 'لا توجد قوائم تطابق البحث',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),

          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMenus,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredMenus.length,
        itemBuilder: (context, index) {
          final menu = filteredMenus[index];
          return _buildMenuCard(menu);
        },
      ),
    );
  }

Widget _buildMenuCard(dynamic menu) {
  final foodType = menu['food_type'] ?? '';
  final numberOfVisitors = menu['number_of_visitors'] ?? 0;
  final menuDetails = List<String>.from(menu['menu_details'] ?? []);
  
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      foodType,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'عدد الزوار: $numberOfVisitors',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Replace PopupMenuButton with simple IconButton for viewing
              IconButton(
                onPressed: () => _showMenuDetails(menu),
                icon: const Icon(Icons.visibility, color: Colors.blue),
                tooltip: 'عرض التفاصيل',
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Menu items preview
          if (menuDetails.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'عناصر القائمة:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    menuDetails.take(3).join(', ') + 
                    (menuDetails.length > 3 ? '...' : ''),
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}


  void _showMenuDetails(dynamic menu) {
    final foodType = menu['food_type'] ?? '';
    final numberOfVisitors = menu['number_of_visitors'] ?? 0;
    final menuDetails = List<String>.from(menu['menu_details'] ?? []);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل قائمة $foodType'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('نوع الطعام:', foodType),
              _buildDetailRow('عدد الزوار:', numberOfVisitors.toString()),
              const SizedBox(height: 16),
              const Text(
                'عناصر القائمة:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ...menuDetails.map((item) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $item'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }


}