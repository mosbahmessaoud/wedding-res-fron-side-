// lib/screens/clan_admin/food_tab.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wedding_reservation_app/services/api_service.dart';
import 'package:wedding_reservation_app/utils/colors.dart';

class FoodTab extends StatefulWidget {
  const FoodTab({super.key});

  @override
  State<FoodTab> createState() => FoodTabState();
}

class FoodTabState extends State<FoodTab> {
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
    _checkConnectivityAndLoad();
  }

  void refreshData() {
    _checkConnectivityAndLoad();
    setState(() {});
  }

  Future<void> _checkConnectivityAndLoad() async {
    setState(() => _isLoading = true);
    await Future.delayed(Duration(seconds: 2));
    final connectivityResult = await Connectivity().checkConnectivity();
    
    if (connectivityResult.contains(ConnectivityResult.none)) {
      _showNoInternetDialog();
      setState(() => _isLoading = false);
      return;
    }
    
    await _loadInitialData();
  }

  void _showNoInternetDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
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
        content: Text('يرجى التحقق من اتصالك بالإنترنت', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _checkConnectivityAndLoad();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
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

  Future<void> _loadInitialData() async {
    await Future.wait([_loadFoodTypes(), _loadVisitorOptions(), _loadMenus()]);
    if (mounted) setState(() {});
  }

  Future<void> _loadFoodTypes() async {
    try {
      final foodTypes = await ApiService.getFoodTypes();
      setState(() => _foodTypes = List<String>.from(foodTypes));
    } catch (e) {
      setState(() => _foodTypes = ['الجاري', 'الكسكس', 'الكباب']);
    }
  }

  Future<void> _loadVisitorOptions() async {
    try {
      final visitorOptions = await ApiService.getVisitorOptions();
      setState(() => _visitorOptions = List<int>.from(visitorOptions));
    } catch (e) {
      setState(() => _visitorOptions = [50, 100, 150, 200, 250, 300, 350, 400, 450, 500, 600]);
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
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة قوائم الطعام'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDark ? AppColors.primary.withOpacity(0.4) : AppColors.primary.withOpacity(0.8),
                AppColors.primary,
                AppColors.primary,
                isDark ? AppColors.primary.withOpacity(0.4) : AppColors.primary.withOpacity(0.8),
              ],
            ),
          ),
        ),
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/clan_admin_home'),
        ),
      ),
      body: Column(
        children: [
          _buildFilters(isDark),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildMenusList(isDark),
          ),
          SizedBox(height: 1),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: SizedBox(
          width: 45,  // Custom size
          height: 45,
          child: FloatingActionButton(
            onPressed: () => _showCreateMenuDialog(),
            backgroundColor: Colors.green,
            child: const Icon(Icons.add, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'البحث في القوائم...',
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
                    labelText: 'نوع الطعام',
                    labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey[700]),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: isDark ? Colors.grey[850] : Colors.white,
                  ),
                  items: _uniqueFoodTypes.map((String foodType) {
                    return DropdownMenuItem<String>(
                      value: foodType,
                      child: Text(foodType),
                    );
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
                    labelText: 'عدد الزوار',
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

  Widget _buildMenusList(bool isDark) {
    final filteredMenus = _filteredMenus;
    
    if (filteredMenus.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 80, color: isDark ? Colors.grey[600] : Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _menus.isEmpty ? 'لا توجد قوائم طعام' : 'لا توجد قوائم تطابق البحث',
              style: TextStyle(fontSize: 18, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showCreateMenuDialog(),
              child: const Text('إضافة قائمة جديدة'),
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
        itemBuilder: (context, index) => _buildMenuCard(filteredMenus[index], isDark),
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
                        'عدد الزوار: $numberOfVisitors',
                        style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  color: isDark ? Colors.grey[800] : Colors.white,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('عرض التفاصيل', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('تعديل', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('حذف', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'view': _showMenuDetails(menu); break;
                      case 'edit': _showEditMenuDialog(menu); break;
                      case 'delete': _showDeleteConfirmation(menu); break;
                    }
                  },
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
              _buildDetailRow('نوع الطعام:', foodType, isDark),
              _buildDetailRow('عدد الزوار:', numberOfVisitors.toString(), isDark),
              const SizedBox(height: 16),
              Text(
                'عناصر القائمة:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black),
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
            child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
          ),
          Expanded(child: Text(value, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87))),
        ],
      ),
    );
  }

  void _showCreateMenuDialog() => _showMenuFormDialog(isEdit: false);
  void _showEditMenuDialog(dynamic menu) => _showMenuFormDialog(isEdit: true, menu: menu);

  void _showMenuFormDialog({required bool isEdit, dynamic menu}) {
    showDialog(
      context: context,
      builder: (context) => _MenuFormDialog(
        isEdit: isEdit,
        menu: menu,
        foodTypes: _foodTypes,
        visitorOptions: _visitorOptions,
        onSuccess: (String message) {
          _showSuccessSnackBar(message);
          _loadMenus();
        },
        onError: _showErrorSnackBar,
      ),
    );
  }

  void _showDeleteConfirmation(dynamic menu) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foodType = menu['food_type'] ?? '';
    final numberOfVisitors = menu['number_of_visitors'] ?? 0;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        title: Text('تأكيد الحذف', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: Text(
          'هل أنت متأكد من حذف قائمة $foodType لـ $numberOfVisitors زائر؟',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ApiService.deleteFoodMenu(menu['id']);
                _showSuccessSnackBar('تم حذف القائمة بنجاح');
                Navigator.pop(context);
                _loadMenus();
              } catch (e) {
                _showErrorSnackBar('خطأ في الحذف: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

class _MenuFormDialog extends StatefulWidget {
  final bool isEdit;
  final dynamic menu;
  final List<String> foodTypes;
  final List<int> visitorOptions;
  final Function(String) onSuccess;
  final Function(String) onError;

  const _MenuFormDialog({
    required this.isEdit,
    this.menu,
    required this.foodTypes,
    required this.visitorOptions,
    required this.onSuccess,
    required this.onError,
  });

  @override
  State<_MenuFormDialog> createState() => _MenuFormDialogState();
}

class _MenuFormDialogState extends State<_MenuFormDialog> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _foodTypeController;
  late final TextEditingController _visitorsController;
  late final TextEditingController _menuItemController;
  late List<String> _menuItems;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _foodTypeController = TextEditingController(text: widget.menu?['food_type'] ?? '');
    _visitorsController = TextEditingController(text: widget.menu?['number_of_visitors']?.toString() ?? '');
    _menuItemController = TextEditingController();
    _menuItems = List<String>.from(widget.menu?['menu_details'] ?? []);
  }

  @override
  void dispose() {
    _foodTypeController.dispose();
    _visitorsController.dispose();
    _menuItemController.dispose();
    super.dispose();
  }

  void _addMenuItem() {
    final value = _menuItemController.text.trim();
    if (value.isNotEmpty) {
      setState(() {
        _menuItems.add(value);
        _menuItemController.clear();
      });
    }
  }

  void _removeMenuItem(int index) => setState(() => _menuItems.removeAt(index));

  Future<void> _saveMenu() async {
    if (_formKey.currentState!.validate() && _menuItems.isNotEmpty) {
      try {
        final foodType = _foodTypeController.text.trim();
        final numberOfVisitors = int.parse(_visitorsController.text.trim());
        
        if (widget.isEdit) {
          await ApiService.updateFoodMenu(widget.menu['id'], {
            'food_type': foodType,
            'number_of_visitors': numberOfVisitors,
            'menu_items': _menuItems,
          });
          widget.onSuccess('تم تعديل القائمة بنجاح');
        } else {
          final userInfo = await ApiService.getCurrentUserInfo();
          await ApiService.createFoodMenu({
            'food_type': foodType,
            'number_of_visitors': numberOfVisitors,
            'menu_items': _menuItems,
            'clan_id': userInfo['clan_id'],
          });
          widget.onSuccess('تم إنشاء القائمة بنجاح');
        }
        Navigator.pop(context);
      } catch (e) {
        widget.onError('خطأ: $e');
      }
    } else if (_menuItems.isEmpty) {
      widget.onError('يجب إضافة عنصر واحد على الأقل للقائمة');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      title: Text(
        widget.isEdit ? 'تعديل القائمة' : 'إضافة قائمة جديدة',
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _foodTypeController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'نوع الطعام',
                  labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey[700]),
                  hintText: 'مثال: كباب كسكس جاري',
                  hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: isDark ? Colors.grey[850] : Colors.grey[50],
                  suffixIcon: widget.foodTypes.isNotEmpty
                      ? PopupMenuButton<String>(
                          icon: Icon(Icons.arrow_drop_down, color: isDark ? Colors.white70 : Colors.grey[700]),
                          color: isDark ? Colors.grey[800] : Colors.white,
                          onSelected: (String value) => _foodTypeController.text = value,
                          itemBuilder: (BuildContext context) {
                            return widget.foodTypes.map((String choice) {
                              return PopupMenuItem<String>(
                                value: choice,
                                child: Text(choice, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                              );
                            }).toList();
                          },
                        )
                      : null,
                ),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'يرجى إدخال نوع الطعام' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _visitorsController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'عدد الزوار',
                  labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey[700]),
                  hintText: 'مثال: 100، 200، 500',
                  hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: isDark ? Colors.grey[850] : Colors.grey[50],
                  suffixIcon: widget.visitorOptions.isNotEmpty
                      ? PopupMenuButton<int>(
                          icon: Icon(Icons.arrow_drop_down, color: isDark ? Colors.white70 : Colors.grey[700]),
                          color: isDark ? Colors.grey[800] : Colors.white,
                          onSelected: (int value) => _visitorsController.text = value.toString(),
                          itemBuilder: (BuildContext context) {
                            return widget.visitorOptions.map((int choice) {
                              return PopupMenuItem<int>(
                                value: choice,
                                child: Text(choice.toString(), style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                              );
                            }).toList();
                          },
                        )
                      : null,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'يرجى إدخال عدد الزوار';
                  final visitors = int.tryParse(value);
                  if (visitors == null || visitors <= 0) return 'يرجى إدخال رقم صحيح أكبر من صفر';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _menuItemController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        labelText: 'إضافة عنصر للقائمة',
                        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey[700]),
                        hintText: ' مثال: بصل 20 كيلو ',
                        hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: isDark ? Colors.grey[850] : Colors.grey[50],
                      ),
                      onSubmitted: (_) => _addMenuItem(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addMenuItem,
                    icon: Icon(Icons.add, color: isDark ? Colors.white70 : Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_menuItems.isNotEmpty)
                Container(
                  width: double.maxFinite,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                    color: isDark ? Colors.grey[850] : Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'عناصر القائمة:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          itemCount: _menuItems.length,
                          separatorBuilder: (context, index) => Divider(height: 1, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                          itemBuilder: (context, index) => ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            title: Text(
                              _menuItems[index],
                              style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () => _removeMenuItem(index),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _saveMenu,
          child: Text(widget.isEdit ? 'تعديل' : 'إضافة'),
        ),
      ],
    );
  }
}