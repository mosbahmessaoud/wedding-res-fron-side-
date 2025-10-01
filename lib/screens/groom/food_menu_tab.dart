// // lib/screens/home/tabs/food_menu_tab.dart
// import 'package:flutter/material.dart';
// import '../../../services/api_service.dart';
// import '../../../utils/colors.dart';

// class FoodMenuTabG extends StatefulWidget {
//   const FoodMenuTabG({super.key});

//   @override
//   State<FoodMenuTabG> createState() => FoodMenuTabGState();
// }

// class FoodMenuTabGState extends State<FoodMenuTabG> {
//   bool _isLoading = true;
//   List<dynamic> _foodTypes = [];
//   List<dynamic> _visitorOptions = [];
//   List<dynamic> _filteredMenus = [];
//   Map<String, dynamic>? _userProfile;
  
//   String? _selectedFoodType;
//   int? _selectedVisitorCount;

//   @override
//   void initState() {
//     super.initState();
//     _loadInitialData();
//   }
//   void refreshData() {

//     _loadInitialData();
//     _loadFilteredMenus();
//     setState(() {
//       // Trigger rebuild
//     });
//   }
//   Future<void> _loadInitialData() async {
//     setState(() => _isLoading = true);
    
//     try {
//       // Load user profile to get clan_id
//       _userProfile = await ApiService.getProfile();
      
//       // Load food types and visitor options
//       final futures = await Future.wait([
//         ApiService.getFoodTypes(),
//         ApiService.getVisitorOptions(),
//       ]);
      
//       _foodTypes = futures[0] as List<dynamic>;
//       _visitorOptions = futures[1] as List<dynamic>;
      
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('خطأ في تحميل البيانات: ${e.toString()}')),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   Future<void> _loadFilteredMenus() async {
//     if (_selectedFoodType == null || 
//         _selectedVisitorCount == null || 
//         _userProfile?['clan_id'] == null) {
//       return;
//     }

//     try {
//       final menus = await ApiService.getFilteredMenu(
//         _selectedFoodType!,
//         _selectedVisitorCount!,
//         _userProfile!['clan_id'],
//       );
      
//       setState(() {
//         _filteredMenus = menus;
//       });
      
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('خطأ في تحميل القوائم: ${e.toString()}')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return Column(
//       children: [
//         _buildFiltersSection(),
//         Expanded(
//           child: _buildMenusContent(),
//         ),
//       ],
//     );
//   }

//   Widget _buildFiltersSection() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'اختر نوع القائمة وعدد الضيوف',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: AppColors.primary,
//             ),
//           ),
//           const SizedBox(height: 16),
          
//           // Food Type Dropdown
//           DropdownButtonFormField<String>(
//             value: _selectedFoodType,
//             decoration: InputDecoration(
//               labelText: 'نوع الطعام',
//               prefixIcon: const Icon(Icons.restaurant_menu),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             items: _foodTypes.map<DropdownMenuItem<String>>((type) {
//               return DropdownMenuItem<String>(
//                 value: type['value'] ?? type.toString(),
//                 child: Text(type['label'] ?? type.toString()),
//               );
//             }).toList(),
//             onChanged: (value) {
//               setState(() {
//                 _selectedFoodType = value;
//                 _filteredMenus.clear();
//               });
//               if (_selectedVisitorCount != null) {
//                 _loadFilteredMenus();
//               }
//             },
//           ),
          
//           const SizedBox(height: 12),
          
//           // Visitor Count Dropdown
//           DropdownButtonFormField<int>(
//             value: _selectedVisitorCount,
//             decoration: InputDecoration(
//               labelText: 'عدد الضيوف',
//               prefixIcon: const Icon(Icons.people),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             items: _visitorOptions.map<DropdownMenuItem<int>>((option) {
//               return DropdownMenuItem<int>(
//                 value: option['value'] ?? int.tryParse(option.toString()),
//                 child: Text(option['label'] ?? option.toString()),
//               );
//             }).toList(),
//             onChanged: (value) {
//               setState(() {
//                 _selectedVisitorCount = value;
//                 _filteredMenus.clear();
//               });
//               if (_selectedFoodType != null) {
//                 _loadFilteredMenus();
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMenusContent() {
//     if (_selectedFoodType == null || _selectedVisitorCount == null) {
//       return _buildEmptyState(
//         icon: Icons.restaurant,
//         title: 'اختر نوع الطعام وعدد الضيوف',
//         subtitle: 'لعرض القوائم المتاحة',
//       );
//     }

//     if (_filteredMenus.isEmpty) {
//       return _buildEmptyState(
//         icon: Icons.no_meals,
//         title: 'لا توجد قوائم متاحة',
//         subtitle: 'لا توجد قوائم تطابق اختياراتك',
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: _filteredMenus.length,
//       itemBuilder: (context, index) {
//         final menu = _filteredMenus[index];
//         return _buildMenuCard(menu);
//       },
//     );
//   }

//   Widget _buildMenuCard(Map<String, dynamic> menu) {
//     final totalCost = menu['total_cost'] ?? 0;
//     final costPerPerson = menu['cost_per_person'] ?? 0;

//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 2,
//       child: InkWell(
//         onTap: () => _showMenuDetails(menu),
//         borderRadius: BorderRadius.circular(8),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Menu header
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Text(
//                       menu['name'] ?? 'قائمة غير مسماة',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: AppColors.primary.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       _selectedFoodType ?? '',
//                       style: TextStyle(
//                         color: AppColors.primary,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
              
//               if (menu['description'] != null) ...[
//                 const SizedBox(height: 8),
//                 Text(
//                   menu['description'],
//                   style: TextStyle(
//                     color: AppColors.textSecondary,
//                     fontSize: 14,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
              
//               const SizedBox(height: 12),
              
//               // Cost information
//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildCostInfo(
//                       'التكلفة الإجمالية',
//                       '$totalCost دينار عراقي',
//                       Icons.receipt_long,
//                     ),
//                   ),
//                   Expanded(
//                     child: _buildCostInfo(
//                       'التكلفة للشخص',
//                       '$costPerPerson د.ع',
//                       Icons.person,
//                     ),
//                   ),
//                 ],
//               ),
              
//               const SizedBox(height: 12),
              
//               // Items count
//               if (menu['items'] != null && menu['items'].isNotEmpty)
//                 Row(
//                   children: [
//                     Icon(Icons.restaurant, size: 16, color: AppColors.textSecondary),
//                     const SizedBox(width: 4),
//                     Text(
//                       '${menu['items'].length} عنصر في القائمة',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
              
//               const SizedBox(height: 12),
              
//               // Action buttons
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   TextButton.icon(
//                     onPressed: () => _showMenuDetails(menu),
//                     icon: const Icon(Icons.info_outline),
//                     label: const Text('التفاصيل'),
//                   ),
//                   ElevatedButton.icon(
//                     onPressed: () => _selectMenu(menu),
//                     icon: const Icon(Icons.check),
//                     label: const Text('اختيار القائمة'),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCostInfo(String label, String value, IconData icon) {
//     return Row(
//       children: [
//         Icon(icon, size: 16, color: AppColors.textSecondary),
//         const SizedBox(width: 4),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 10,
//                 color: AppColors.textSecondary,
//               ),
//             ),
//             Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildEmptyState({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//   }) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             icon,
//             size: 64,
//             color: AppColors.textSecondary,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: AppColors.textPrimary,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             subtitle,
//             style: const TextStyle(
//               fontSize: 16,
//               color: AppColors.textSecondary,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   void _showMenuDetails(Map<String, dynamic> menu) {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         child: Container(
//           constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Header
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: AppColors.primary,
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(8),
//                     topRight: Radius.circular(8),
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         menu['name'] ?? 'تفاصيل القائمة',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.close, color: Colors.white),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ],
//                 ),
//               ),
              
//               // Content
//               Flexible(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Description
//                       if (menu['description'] != null) ...[
//                         const Text(
//                           'الوصف:',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                             color: AppColors.primary,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           menu['description'],
//                           style: const TextStyle(fontSize: 14),
//                         ),
//                         const SizedBox(height: 16),
//                       ],
                      
//                       // Cost Information
//                       Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: AppColors.primary.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: AppColors.primary.withOpacity(0.3)),
//                         ),
//                         child: Column(
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 const Text('التكلفة الإجمالية:', style: TextStyle(fontWeight: FontWeight.bold)),
//                                 Text('${menu['total_cost'] ?? 0} دينار عراقي', style: const TextStyle(fontWeight: FontWeight.bold)),
//                               ],
//                             ),
//                             const SizedBox(height: 8),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 const Text('التكلفة للشخص:', style: TextStyle(fontWeight: FontWeight.bold)),
//                                 Text('${menu['cost_per_person'] ?? 0} د.ع', style: const TextStyle(fontWeight: FontWeight.bold)),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
                      
//                       const SizedBox(height: 16),
                      
//                       // Menu Items
//                       if (menu['items'] != null && menu['items'].isNotEmpty) ...[
//                         const Text(
//                           'عناصر القائمة:',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                             color: AppColors.primary,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         ...menu['items'].map<Widget>((item) => Container(
//                           margin: const EdgeInsets.only(bottom: 8),
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: Colors.grey[50],
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(color: Colors.grey[300]!),
//                           ),
//                           child: Row(
//                             children: [
//                               Icon(Icons.restaurant, size: 20, color: AppColors.primary),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       item['name'] ?? 'عنصر غير مسمى',
//                                       style: const TextStyle(fontWeight: FontWeight.w500),
//                                     ),
//                                     if (item['description'] != null)
//                                       Text(
//                                         item['description'],
//                                         style: TextStyle(
//                                           fontSize: 12,
//                                           color: AppColors.textSecondary,
//                                         ),
//                                       ),
//                                   ],
//                                 ),
//                               ),
//                               if (item['price'] != null)
//                                 Text(
//                                   '${item['price']} د.ع',
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: AppColors.primary,
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         )).toList(),
                        
//                         const SizedBox(height: 16),
//                       ],
                      
//                       // Action Button
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton.icon(
//                           onPressed: () {
//                             Navigator.pop(context);
//                             _selectMenu(menu);
//                           },
//                           icon: const Icon(Icons.check),
//                           label: const Text('اختيار هذه القائمة'),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _selectMenu(Map<String, dynamic> menu) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('تأكيد اختيار القائمة'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('هل تريد اختيار القائمة: ${menu['name']}؟'),
//             const SizedBox(height: 8),
//             Text('التكلفة الإجمالية: ${menu['total_cost'] ?? 0} دينار عراقي'),
//             Text('عدد الضيوف: $_selectedVisitorCount شخص'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _proceedWithMenuSelection(menu);
//             },
//             child: const Text('تأكيد'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _proceedWithMenuSelection(Map<String, dynamic> menu) {
//     // TODO: Navigate to reservation screen with selected menu
//     // Or save the menu selection for later use
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('تم اختيار القائمة: ${menu['name']}'),
//         action: SnackBarAction(
//           label: 'المتابعة للحجز',
//           onPressed: () {
//             // TODO: Navigate to reservation screen
//           },
//         ),
//       ),
//     );
//   }
// }