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
    setState(() {
      
    });
  }

  Future<void> _checkConnectivityAndLoad() async {
      setState(() {
    _isLoading = true;
  });
  
  // Show loading for 2 seconds
  await Future.delayed(Duration(seconds: 2));
  final connectivityResult = await Connectivity().checkConnectivity();
  
  if (connectivityResult.contains(ConnectivityResult.none)) {
    _showNoInternetDialog();
    setState(() {
      _isLoading = false;
    });
    return;
  }
  
  await _loadInitialData();
}

void _showNoInternetDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.orange),
          SizedBox(width: 10),
          Text('لا يوجد اتصال'),
        ],
      ),
      content: Text('يرجى التحقق من اتصالك بالإنترنت'),
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


  Future<void> _loadFoodTypes() async {
    try {
      final foodTypes = await ApiService.getFoodTypes();
      setState(() {
        _foodTypes = List<String>.from(foodTypes);
      });
    } catch (e) {
      // Fallback to default values if API fails
      setState(() {
        _foodTypes = ['الجاري', 'الكسكس', 'الكباب'];
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
    appBar: AppBar(
      title: Text('إدارة قوائم الطعام'),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/clan_admin_home');
        },
      ),
    ),
    body: Column(
      children: [ 
        _buildFilters(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildMenusList(),
        ),
        SizedBox(height: 80), 
      ],
    ),
    floatingActionButton: Padding(
      padding: EdgeInsets.only(bottom: 50), // Add padding to lift the FAB
      child: FloatingActionButton(
        onPressed: () => _showCreateMenuDialog(),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('عرض التفاصيل'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('تعديل'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('حذف'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'view':
                        _showMenuDetails(menu);
                        break;
                      case 'edit':
                        _showEditMenuDialog(menu);
                        break;
                      case 'delete':
                        _showDeleteConfirmation(menu);
                        break;
                    }
                  },
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

  void _showCreateMenuDialog() {
    _showMenuFormDialog(isEdit: false);
  }

  void _showEditMenuDialog(dynamic menu) {
    _showMenuFormDialog(isEdit: true, menu: menu);
  }

void _showMenuFormDialog({required bool isEdit, dynamic menu}) {
  // Create a separate stateful widget for the dialog content
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
      onError: (String message) {
        _showErrorSnackBar(message);
      },
    ),
    
  );
}


  void _showDeleteConfirmation(dynamic menu) {
    final foodType = menu['food_type'] ?? '';
    final numberOfVisitors = menu['number_of_visitors'] ?? 0;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف قائمة $foodType لـ $numberOfVisitors زائر؟'),
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

// Add this as a separate class in the same file (before the closing brace of FoodTabState)
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
    _visitorsController = TextEditingController(
      text: widget.menu?['number_of_visitors']?.toString() ?? '',
    );
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

  void _removeMenuItem(int index) {
    setState(() {
      _menuItems.removeAt(index);
    });
  }

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
    return AlertDialog(
      title: Text(widget.isEdit ? 'تعديل القائمة' : 'إضافة قائمة جديدة'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Food type input field
              TextFormField(
                controller: _foodTypeController,
                decoration: InputDecoration(
                  labelText: 'نوع الطعام',
                  hintText: 'مثال: كباب كسكس جاري',
                  border: const OutlineInputBorder(),
                  suffixIcon: widget.foodTypes.isNotEmpty
                      ? PopupMenuButton<String>(
                          icon: const Icon(Icons.arrow_drop_down),
                          onSelected: (String value) {
                            _foodTypeController.text = value;
                          },
                          itemBuilder: (BuildContext context) {
                            return widget.foodTypes.map((String choice) {
                              return PopupMenuItem<String>(
                                value: choice,
                                child: Text(choice),
                              );
                            }).toList();
                          },
                        )
                      : null,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال نوع الطعام';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Number of visitors input field
              TextFormField(
                controller: _visitorsController,
                decoration: InputDecoration(
                  labelText: 'عدد الزوار',
                  hintText: 'مثال: 100، 200، 500',
                  border: const OutlineInputBorder(),
                  suffixIcon: widget.visitorOptions.isNotEmpty
                      ? PopupMenuButton<int>(
                          icon: const Icon(Icons.arrow_drop_down),
                          onSelected: (int value) {
                            _visitorsController.text = value.toString();
                          },
                          itemBuilder: (BuildContext context) {
                            return widget.visitorOptions.map((int choice) {
                              return PopupMenuItem<int>(
                                value: choice,
                                child: Text(choice.toString()),
                              );
                            }).toList();
                          },
                        )
                      : null,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال عدد الزوار';
                  }
                  final visitors = int.tryParse(value);
                  if (visitors == null || visitors <= 0) {
                    return 'يرجى إدخال رقم صحيح أكبر من صفر';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Menu items input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _menuItemController,
                      decoration: const InputDecoration(
                        labelText: 'إضافة عنصر للقائمة',
                        hintText: ' مثال: بصل 20 كيلو ',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _addMenuItem(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addMenuItem,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Menu items list
              if (_menuItems.isNotEmpty)
                Container(
                  width: double.maxFinite,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'عناصر القائمة:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          itemCount: _menuItems.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) => ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            title: Text(
                              _menuItems[index],
                              style: const TextStyle(fontSize: 14),
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