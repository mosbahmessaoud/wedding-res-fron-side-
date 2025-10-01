// // lib/screens/clan_admin/food_tab.dart
// import 'package:flutter/material.dart';
// import 'package:wedding_reservation_app/services/api_service.dart';

// class FoodTab extends StatefulWidget {
//   const FoodTab({super.key});

//   @override
//   State<FoodTab> createState() => _FoodTabState();
// }

// class _FoodTabState extends State<FoodTab> {
//   List<dynamic> _menus = [];
//   bool _isLoading = false;
//   String _searchQuery = '';
//   String _selectedFoodType = 'الكل';
//   int _selectedVisitors = 0;

//   List<String> _foodTypes = [];
//   List<int> _visitorOptions = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadInitialData();
//   }

//   Future<void> _loadInitialData() async {
//     await Future.wait([
//       _loadFoodTypes(),
//       _loadVisitorOptions(),
//       _loadMenus(),
//     ]);
//   }

//   Future<void> _loadFoodTypes() async {
//     try {
//       final foodTypes = await ApiService.getFoodTypes();
//       setState(() {
//         _foodTypes = List<String>.from(foodTypes);
//       });
//     } catch (e) {
//       // Fallback to default values if API fails
//       setState(() {
//         _foodTypes = ['فريق', 'كسكس', 'كباب'];
//       });
//     }
//   }

//   Future<void> _loadVisitorOptions() async {
//     try {
//       final visitorOptions = await ApiService.getVisitorOptions();
//       setState(() {
//         _visitorOptions = List<int>.from(visitorOptions);
//       });
//     } catch (e) {
//       // Fallback to default values if API fails
//       setState(() {
//         _visitorOptions = [50, 100, 150, 200, 250, 300, 350,  400,450 , 500 ,600];
//       });
//     }
//   }

//   Future<void> _loadMenus() async {
//     setState(() => _isLoading = true);
//     try {
//       final menus = await ApiService.getClanMenus();
//       setState(() {
//         _menus = menus;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       _showErrorSnackBar('خطأ في تحميل القوائم: $e');
//     }
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }

//   void _showSuccessSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }

//   List<dynamic> get _filteredMenus {
//     return _menus.where((menu) {
//       final menuDetails = menu['menu_details'] ?? [];
//       final foodType = menu['food_type'] ?? '';
//       final numberOfVisitors = menu['number_of_visitors'] ?? 0;
      
//       final matchesSearch = menuDetails.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
//           foodType.toLowerCase().contains(_searchQuery.toLowerCase());
//       final matchesFoodType = _selectedFoodType == 'الكل' || foodType == _selectedFoodType;
//       final matchesVisitors = _selectedVisitors == 0 || numberOfVisitors == _selectedVisitors;
      
//       return matchesSearch && matchesFoodType && matchesVisitors;
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           _buildHeader(),
//           _buildFilters(),
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : _buildMenusList(),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _showCreateMenuDialog(),
//         backgroundColor: Colors.blue,
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.blue.shade50,
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(20),
//           bottomRight: Radius.circular(20),
//         ),
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'إدارة قوائم الطعام',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blue,
//                 ),
//               ),
//               IconButton(
//                 onPressed: _loadMenus,
//                 icon: const Icon(Icons.refresh, color: Colors.blue),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           Text(
//             'إجمالي القوائم: ${_menus.length}',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey.shade600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilters() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // Search bar
//           TextField(
//             decoration: InputDecoration(
//               hintText: 'البحث في القوائم...',
//               prefixIcon: const Icon(Icons.search),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               filled: true,
//               fillColor: Colors.grey.shade100,
//             ),
//             onChanged: (value) {
//               setState(() => _searchQuery = value);
//             },
//           ),
//           const SizedBox(height: 16),
          
//           // Filter row
//           Row(
//             children: [
//               // Food type filter (input field)
//               Expanded(
//                 child: TextField(
//                   decoration: InputDecoration(
//                     labelText: 'نوع الطعام',
//                     hintText: 'أدخل نوع الطعام',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   onChanged: (value) {
//                     setState(() => _selectedFoodType = value.isEmpty ? 'الكل' : value);
//                   },
//                 ),
//               ),
//               const SizedBox(width: 16),
              
//               // Visitors filter (input field)
//               Expanded(
//                 child: TextField(
//                   decoration: InputDecoration(
//                     labelText: 'عدد الزوار',
//                     hintText: 'أدخل عدد الزوار',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   keyboardType: TextInputType.number,
//                   onChanged: (value) {
//                     setState(() => _selectedVisitors = int.tryParse(value) ?? 0);
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMenusList() {
//     final filteredMenus = _filteredMenus;
    
//     if (filteredMenus.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.restaurant_menu,
//               size: 80,
//               color: Colors.grey.shade400,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               _menus.isEmpty ? 'لا توجد قوائم طعام' : 'لا توجد قوائم تطابق البحث',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.grey.shade600,
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () => _showCreateMenuDialog(),
//               child: const Text('إضافة قائمة جديدة'),
//             ),
//           ],
//         ),
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: _loadMenus,
//       child: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: filteredMenus.length,
//         itemBuilder: (context, index) {
//           final menu = filteredMenus[index];
//           return _buildMenuCard(menu);
//         },
//       ),
//     );
//   }

//   Widget _buildMenuCard(dynamic menu) {
//     final foodType = menu['food_type'] ?? '';
//     final numberOfVisitors = menu['number_of_visitors'] ?? 0;
//     final menuDetails = List<String>.from(menu['menu_details'] ?? []);
    
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         foodType,
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blue,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         'عدد الزوار: $numberOfVisitors',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 PopupMenuButton(
//                   itemBuilder: (context) => [
//                     const PopupMenuItem(
//                       value: 'view',
//                       child: Row(
//                         children: [
//                           Icon(Icons.visibility, color: Colors.blue),
//                           SizedBox(width: 8),
//                           Text('عرض التفاصيل'),
//                         ],
//                       ),
//                     ),
//                     const PopupMenuItem(
//                       value: 'edit',
//                       child: Row(
//                         children: [
//                           Icon(Icons.edit, color: Colors.orange),
//                           SizedBox(width: 8),
//                           Text('تعديل'),
//                         ],
//                       ),
//                     ),
//                     const PopupMenuItem(
//                       value: 'delete',
//                       child: Row(
//                         children: [
//                           Icon(Icons.delete, color: Colors.red),
//                           SizedBox(width: 8),
//                           Text('حذف'),
//                         ],
//                       ),
//                     ),
//                   ],
//                   onSelected: (value) {
//                     switch (value) {
//                       case 'view':
//                         _showMenuDetails(menu);
//                         break;
//                       case 'edit':
//                         _showEditMenuDialog(menu);
//                         break;
//                       case 'delete':
//                         _showDeleteConfirmation(menu);
//                         break;
//                     }
//                   },
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
            
//             // Menu items preview
//             if (menuDetails.isNotEmpty)
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'عناصر القائمة:',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.grey,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       menuDetails.take(3).join(', ') + 
//                       (menuDetails.length > 3 ? '...' : ''),
//                       style: TextStyle(
//                         color: Colors.grey.shade700,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showMenuDetails(dynamic menu) {
//     final foodType = menu['food_type'] ?? '';
//     final numberOfVisitors = menu['number_of_visitors'] ?? 0;
//     final menuDetails = List<String>.from(menu['menu_details'] ?? []);
    
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('تفاصيل قائمة $foodType'),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _buildDetailRow('نوع الطعام:', foodType),
//               _buildDetailRow('عدد الزوار:', numberOfVisitors.toString()),
//               const SizedBox(height: 16),
//               const Text(
//                 'عناصر القائمة:',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               ...menuDetails.map((item) => 
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 4),
//                   child: Text('• $item'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('إغلاق'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 80,
//             child: Text(
//               label,
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(child: Text(value)),
//         ],
//       ),
//     );
//   }

//   void _showCreateMenuDialog() {
//     _showMenuFormDialog(isEdit: false);
//   }

//   void _showEditMenuDialog(dynamic menu) {
//     _showMenuFormDialog(isEdit: true, menu: menu);
//   }

//   void _showMenuFormDialog({required bool isEdit, dynamic menu}) {
//     final formKey = GlobalKey<FormState>();
//     final foodTypeController = TextEditingController(text: menu?['food_type'] ?? '');
//     final visitorsController = TextEditingController(
//       text: menu?['number_of_visitors']?.toString() ?? '',
//     );
//     List<String> menuItems = List<String>.from(menu?['menu_details'] ?? []);
//     final menuItemController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(isEdit ? 'تعديل القائمة' : 'إضافة قائمة جديدة'),
//         content: StatefulBuilder(
//           builder: (context, setDialogState) => Form(
//             key: formKey,
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Food type input field
//                   TextFormField(
//                     controller: foodTypeController,
//                     decoration: InputDecoration(
//                       labelText: 'نوع الطعام',
//                       hintText: 'مثال: فطار، غداء، عشاء',
//                       border: const OutlineInputBorder(),
//                       suffixIcon: _foodTypes.isNotEmpty
//                           ? PopupMenuButton<String>(
//                               icon: const Icon(Icons.arrow_drop_down),
//                               onSelected: (String value) {
//                                 foodTypeController.text = value;
//                               },
//                               itemBuilder: (BuildContext context) {
//                                 return _foodTypes.map((String choice) {
//                                   return PopupMenuItem<String>(
//                                     value: choice,
//                                     child: Text(choice),
//                                   );
//                                 }).toList();
//                               },
//                             )
//                           : null,
//                     ),
//                     validator: (value) {
//                       if (value == null || value.trim().isEmpty) {
//                         return 'يرجى إدخال نوع الطعام';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
                  
//                   // Number of visitors input field
//                   TextFormField(
//                     controller: visitorsController,
//                     decoration: InputDecoration(
//                       labelText: 'عدد الزوار',
//                       hintText: 'مثال: 100، 200، 500',
//                       border: const OutlineInputBorder(),
//                       suffixIcon: _visitorOptions.isNotEmpty
//                           ? PopupMenuButton<int>(
//                               icon: const Icon(Icons.arrow_drop_down),
//                               onSelected: (int value) {
//                                 visitorsController.text = value.toString();
//                               },
//                               itemBuilder: (BuildContext context) {
//                                 return _visitorOptions.map((int choice) {
//                                   return PopupMenuItem<int>(
//                                     value: choice,
//                                     child: Text(choice.toString()),
//                                   );
//                                 }).toList();
//                               },
//                             )
//                           : null,
//                     ),
//                     keyboardType: TextInputType.number,
//                     validator: (value) {
//                       if (value == null || value.trim().isEmpty) {
//                         return 'يرجى إدخال عدد الزوار';
//                       }
//                       final visitors = int.tryParse(value);
//                       if (visitors == null || visitors <= 0) {
//                         return 'يرجى إدخال رقم صحيح أكبر من صفر';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
                  
//                   // Menu items input
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: menuItemController,
//                           decoration: const InputDecoration(
//                             labelText: 'إضافة عنصر للقائمة',
//                             hintText: 'مثال: أرز، دجاج، سلطة',
//                             border: OutlineInputBorder(),
//                           ),
//                           onSubmitted: (value) {
//                             if (value.trim().isNotEmpty) {
//                               setDialogState(() {
//                                 menuItems.add(value.trim());
//                                 menuItemController.clear();
//                               });
//                             }
//                           },
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       IconButton(
//                         onPressed: () {
//                           if (menuItemController.text.trim().isNotEmpty) {
//                             setDialogState(() {
//                               menuItems.add(menuItemController.text.trim());
//                               menuItemController.clear();
//                             });
//                           }
//                         },
//                         icon: const Icon(Icons.add),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
                  
//                   // Menu items list
//                   if (menuItems.isNotEmpty)
//                     Container(
//                       constraints: const BoxConstraints(maxHeight: 200),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Padding(
//                             padding: EdgeInsets.all(8.0),
//                             child: Text(
//                               'عناصر القائمة:',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                             child: ListView.builder(
//                               shrinkWrap: true,
//                               itemCount: menuItems.length,
//                               itemBuilder: (context, index) => ListTile(
//                                 dense: true,
//                                 title: Text(menuItems[index]),
//                                 trailing: IconButton(
//                                   icon: const Icon(Icons.delete, color: Colors.red, size: 20),
//                                   onPressed: () {
//                                     setDialogState(() {
//                                       menuItems.removeAt(index);
//                                     });
//                                   },
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               if (formKey.currentState!.validate() && menuItems.isNotEmpty) {
//                 try {
//                   final foodType = foodTypeController.text.trim();
//                   final numberOfVisitors = int.parse(visitorsController.text.trim());
                  
//                   if (isEdit) {
//                     await ApiService.updateFoodMenu(menu['id'], {
//                       'food_type': foodType,
//                       'number_of_visitors': numberOfVisitors,
//                       'menu_items': menuItems,
//                     });
//                     _showSuccessSnackBar('تم تعديل القائمة بنجاح');
//                   } else {
//                     // Get current user info to get clan_id
//                     final userInfo = await ApiService.getCurrentUserInfo();
//                     await ApiService.createFoodMenu({
//                       'food_type': foodType,
//                       'number_of_visitors': numberOfVisitors,
//                       'menu_items': menuItems,
//                       'clan_id': userInfo['clan_id'],
//                     });
//                     _showSuccessSnackBar('تم إنشاء القائمة بنجاح');
//                   }
//                   Navigator.pop(context);
//                   _loadMenus();
//                 } catch (e) {
//                   _showErrorSnackBar('خطأ: $e');
//                 }
//               } else if (menuItems.isEmpty) {
//                 _showErrorSnackBar('يجب إضافة عنصر واحد على الأقل للقائمة');
//               }
//             },
//             child: Text(isEdit ? 'تعديل' : 'إضافة'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showDeleteConfirmation(dynamic menu) {
//     final foodType = menu['food_type'] ?? '';
//     final numberOfVisitors = menu['number_of_visitors'] ?? 0;
    
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('تأكيد الحذف'),
//         content: Text('هل أنت متأكد من حذف قائمة $foodType لـ $numberOfVisitors زائر؟'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               try {
//                 await ApiService.deleteFoodMenu(menu['id']);
//                 _showSuccessSnackBar('تم حذف القائمة بنجاح');
//                 Navigator.pop(context);
//                 _loadMenus();
//               } catch (e) {
//                 _showErrorSnackBar('خطأ في الحذف: $e');
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('حذف'),
//           ),
//         ],
//       ),
//     );
//   }
// }