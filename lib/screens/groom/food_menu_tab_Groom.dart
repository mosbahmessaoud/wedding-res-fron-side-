// lib/screens/clan_admin/food_tab.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:wedding_reservation_app/services/api_service.dart';

class FoodMenuTabG extends StatefulWidget {
  const FoodMenuTabG({super.key});

  @override
  State<FoodMenuTabG> createState() => FoodMenuTabGState();
}

class FoodMenuTabGState extends State<FoodMenuTabG> {
  List<dynamic> _menus = [];
  List<dynamic> _cachedMenus = [];
  bool _hasLoadedOnce = false;
  
  String _searchQuery = '';
  String _selectedFoodType = 'الكل';
  int _selectedVisitors = 0;

  List<String> _foodTypes = [];
  List<int> _visitorOptions = [];

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkConnectivityAndLoad());
  }

  void _loadCachedData() => setState(() => _menus = _cachedMenus);

  void refreshData() => _checkConnectivityAndLoad();
  
  Future<void> _loadInitialData() async => await _checkConnectivityAndLoad();

  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: backgroundColor, duration: const Duration(seconds: 3)),
      );
    }
  }

  Future<void> _checkConnectivityAndLoad() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (_cachedMenus.isEmpty && !_hasLoadedOnce) {
        _showNoInternetDialog();
      } else {
        _showSnackBar('لا يوجد اتصال - عرض البيانات المحفوظة', Colors.orange);
      }
      return;
    }
    
    await _loadData();
  }

  Future<void> _loadFoodTypes() async {
    try {
      final foodTypes = await ApiService.getFoodTypes();
      if (mounted) setState(() => _foodTypes = List<String>.from(foodTypes));
    } catch (e) {
      if (_foodTypes.isEmpty) setState(() => _foodTypes = ['فريق', 'كسكس', 'كباب']);
    }
  }

  Future<void> _loadData() async {
    try {
      await Future.wait([_loadFoodTypes(), _loadVisitorOptions(), _loadMenus()]);
      if (mounted) setState(() {});
    } catch (e) {
      print('Error loading data: $e');
      _showSnackBar('خطأ في التحميل - عرض البيانات المحفوظة', Colors.orange);
    }
  }

  void _showNoInternetDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        title: Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.orange),
            SizedBox(width: 10),
            Text('لا يوجد اتصال', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
          ],
        ),
        content: Text(
          _hasLoadedOnce 
            ? 'يتم عرض آخر البيانات المحفوظة\nللتحديث، تحقق من اتصالك بالإنترنت'
            : 'يرجى التحقق من اتصالك بالإنترنت لتحميل البيانات',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('موافق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _checkConnectivityAndLoad();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('إعادة المحاولة', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  List<String> get _uniqueFoodTypes {
    final Set<String> foodTypes = {'الكل'};
    for (final menu in _menus) {
      final foodType = menu['food_type'] ?? '';
      if (foodType.isNotEmpty) foodTypes.add(foodType);
    }
    return foodTypes.toList();
  }

  List<int> get _uniqueVisitorCounts {
    final Set<int> visitorCounts = {0};
    for (final menu in _menus) {
      final visitors = menu['number_of_visitors'] ?? 0;
      if (visitors > 0) visitorCounts.add(visitors);
    }
    final sortedList = visitorCounts.toList();
    sortedList.sort();
    return sortedList;
  }

  Future<void> _loadVisitorOptions() async {
    try {
      final visitorOptions = await ApiService.getVisitorOptions();
      if (mounted) setState(() => _visitorOptions = List<int>.from(visitorOptions));
    } catch (e) {
      if (_visitorOptions.isEmpty) {
        setState(() => _visitorOptions = [50, 100, 150, 200, 250, 300, 350, 400, 450, 500, 600]);
      }
    }
  }

  Future<void> _loadMenus() async {
    try {
      final menus = await ApiService.getClanMenus();
      if (mounted) {
        setState(() {
          _menus = menus;
          _cachedMenus = List.from(menus);
          _hasLoadedOnce = true;
        });
      }
    } catch (e) {
      print('Error loading menus: $e');
      if (mounted && _cachedMenus.isNotEmpty) {
        _showSnackBar('خطأ في التحميل - عرض البيانات المحفوظة', Colors.orange);
      } else {
        _showSnackBar('خطأ في تحميل القوائم: $e', Colors.red);
      }
    }
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) => null,
      child: Scaffold(
        body: Column(
          children: [
            _buildFilters(),
            Expanded(child: _buildMenusList()),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'البحث في القوائم...',
              hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
              prefixIcon: Icon(Icons.search, color: isDark ? Colors.white70 : Colors.grey[700]),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
            ),
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedFoodType,
                  dropdownColor: isDark ? Colors.grey[850] : Colors.white,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: 'نوع طعام الوليمة',
                    labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey[700]),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: isDark ? Colors.grey[850] : Colors.white,
                  ),
                  items: _uniqueFoodTypes.map((String foodType) {
                    return DropdownMenuItem<String>(value: foodType, child: Text(foodType));
                  }).toList(),
                  onChanged: (String? newValue) => setState(() => _selectedFoodType = newValue ?? 'الكل'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedVisitors,
                  dropdownColor: isDark ? Colors.grey[850] : Colors.white,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: 'عدد المدعوين',
                    labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey[700]),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: isDark ? Colors.grey[850] : Colors.white,
                  ),
                  items: _uniqueVisitorCounts.map((int visitors) {
                    return DropdownMenuItem<int>(
                      value: visitors,
                      child: Text(visitors == 0 ? 'الكل' : visitors.toString()),
                    );
                  }).toList(),
                  onChanged: (int? newValue) => setState(() => _selectedVisitors = newValue ?? 0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenusList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredMenus = _filteredMenus;
    
    if (filteredMenus.isEmpty) {
      return RefreshIndicator(
        onRefresh: _checkConnectivityAndLoad,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu, size: 80, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    _menus.isEmpty ? 'لا توجد قوائم طعام' : 'لا توجد قوائم تطابق البحث',
                    style: TextStyle(fontSize: 18, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                  if (!_hasLoadedOnce && _cachedMenus.isEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cloud_off, size: 16, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('غير متصل', style: TextStyle(color: Colors.orange, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'اسحب لأسفل للتحديث',
                    style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[500] : Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _checkConnectivityAndLoad,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: filteredMenus.length + 1,
        itemBuilder: (context, index) {
          if (index == filteredMenus.length) return const SizedBox(height: 80);
          return _buildMenuCard(filteredMenus[index], isDark);
        },
      ),
    );
  }

  Widget _buildMenuCard(dynamic menu, bool isDark) {
    final foodType = menu['food_type'] ?? '';
    final numberOfVisitors = menu['number_of_visitors'] ?? 0;
    final menuDetails = List<String>.from(menu['menu_details'] ?? []);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isDark ? 4 : 2,
      color: isDark ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.blue[300] : Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'عدد المدعوين: $numberOfVisitors',
                        style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showMenuDetails(menu),
                  icon: Icon(Icons.visibility, color: isDark ? Colors.blue[300] : Colors.blue),
                  tooltip: 'عرض التفاصيل',
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (menuDetails.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'عناصر القائمة:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.grey[300] : Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      menuDetails.take(3).join(', ') + (menuDetails.length > 3 ? '...' : ''),
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foodType = menu['food_type'] ?? '';
    final numberOfVisitors = menu['number_of_visitors'] ?? 0;
    final menuDetails = List<String>.from(menu['menu_details'] ?? []);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        title: Text('تفاصيل قائمة $foodType', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('نوع طعام الوليمة:', foodType, isDark),
              _buildDetailRow('عدد المدعوين:', numberOfVisitors.toString(), isDark),
              const SizedBox(height: 16),
              Text(
                'عناصر القائمة:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              ...menuDetails.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $item', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
              )),
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

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
            ),
          ),
          Expanded(child: Text(value, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87))),
        ],
      ),
    );
  }
}