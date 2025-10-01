// // lib/screens/clan_admin/clan_rules_tab.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:wedding_reservation_app/services/api_service.dart';
// import 'package:wedding_reservation_app/utils/colors.dart';

// class ClanRulesTab extends StatefulWidget {
//   const ClanRulesTab({super.key});

//   @override
//   State<ClanRulesTab> createState() => ClanRulesTabState();
// }

// class ClanRulesTabState extends State<ClanRulesTab> {
//   Map<String, dynamic>? _clanRules;
//   bool _isLoading = false;
//   String _searchQuery = '';
//   String _selectedRuleCategory = 'الكل';

//   List<String> _ruleCategories = [
//     'الكل',
//     'القوانين العامة',
//     'مستلزمات العريس',
//     'قوانين الملابس',
//     'قوانين أدوات المطبخ'
//   ];

//   // Map for rule categories to database fields
//   Map<String, String> _categoryToField = {
//     'القوانين العامة': 'general_rule',
//     'مستلزمات العريس': 'groom_supplies',
//     'قوانين الملابس': 'rule_about_clothing',
//     'قوانين أدوات المطبخ': 'rule_about_kitchenware',
//   };

//   Map<String, String> _fieldToCategory = {
//     'general_rule': 'القوانين العامة',
//     'groom_supplies': 'مستلزمات العريس',
//     'rule_about_clothing': 'قوانين الملابس',
//     'rule_about_kitchenware': 'قوانين أدوات المطبخ',
//   };

//   @override
//   void initState() {
//     super.initState();
//     _loadClanRules();
//   }

//   void refreshData() {
//     _loadClanRules();
//     setState(() {});
//   }

//   Future<void> _loadClanRules() async {
//     setState(() => _isLoading = true);
//     try {
//       final userInfo = await ApiService.getCurrentUserInfo();
//       final clanId = userInfo['clan_id'];
      
//       final rulesData = await ApiService.getClanRulesByClanId(clanId);
//       setState(() {
//         _clanRules = rulesData;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       _showErrorSnackBar('خطأ في تحميل قوانين العشيرة: $e');
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

//   List<Map<String, String>> get _filteredRuleCards {
//     if (_clanRules == null) return [];
    
//     List<Map<String, String>> ruleCards = [];
    
//     _categoryToField.forEach((category, field) {
//       final ruleText = _clanRules![field] as String?;
//       if (ruleText != null && ruleText.isNotEmpty) {
//         final matchesSearch = category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
//             ruleText.toLowerCase().contains(_searchQuery.toLowerCase());
//         final matchesCategory = _selectedRuleCategory == 'الكل' || category == _selectedRuleCategory;
        
//         if (matchesSearch && matchesCategory) {
//           ruleCards.add({
//             'category': category,
//             'field': field,
//             'content': ruleText,
//           });
//         }
//       }
//     });
    
//     return ruleCards;
//   }

//   bool get _hasAnyRules {
//     if (_clanRules == null) return false;
    
//     return _categoryToField.values.any((field) {
//       final value = _clanRules![field] as String?;
//       return value != null && value.isNotEmpty;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('إدارة قوانين العشيرة'),
//         backgroundColor: AppColors.primary,
//         foregroundColor: Colors.white,
//         systemOverlayStyle: SystemUiOverlayStyle.light,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pushReplacementNamed(context, '/clan_admin_home');
//           },
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.edit),
//             onPressed: _clanRules != null ? () => _showEditRulesDialog() : null,
//             tooltip: 'تعديل جميع القوانين',
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           _buildFilters(),
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : _buildRulesList(),
//           ),
//         ],
//       ),
//       floatingActionButton: _clanRules == null
//           ? FloatingActionButton(
//               onPressed: () => _showCreateRulesDialog(),
//               backgroundColor: Colors.green,
//               child: const Icon(Icons.add, color: Colors.white),
//             )
//           : null,
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
//               hintText: 'البحث في القوانين...',
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
          
//           // Rule category dropdown
//           DropdownButtonFormField<String>(
//             value: _selectedRuleCategory,
//             decoration: InputDecoration(
//               labelText: 'فئة القانون',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             items: _ruleCategories.map((String category) {
//               return DropdownMenuItem<String>(
//                 value: category,
//                 child: Text(category),
//               );
//             }).toList(),
//             onChanged: (String? newValue) {
//               setState(() {
//                 _selectedRuleCategory = newValue ?? 'الكل';
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRulesList() {
//     if (!_hasAnyRules) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.gavel,
//               size: 80,
//               color: Colors.grey.shade400,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'لا توجد قوانين للعشيرة',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.grey.shade600,
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () => _showCreateRulesDialog(),
//               child: const Text('إنشاء قوانين العشيرة'),
//             ),
//           ],
//         ),
//       );
//     }

//     final filteredRules = _filteredRuleCards;
    
//     if (filteredRules.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.search_off,
//               size: 80,
//               color: Colors.grey.shade400,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'لا توجد قوانين تطابق البحث',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.grey.shade600,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: _loadClanRules,
//       child: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: filteredRules.length,
//         itemBuilder: (context, index) {
//           final ruleCard = filteredRules[index];
//           return _buildRuleCard(ruleCard);
//         },
//       ),
//     );
//   }

//   Widget _buildRuleCard(Map<String, String> ruleCard) {
//     final category = ruleCard['category']!;
//     final content = ruleCard['content']!;
//     final field = ruleCard['field']!;
    
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
//                         category,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blue,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade50,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Text(
//                           content,
//                           style: TextStyle(
//                             color: Colors.grey.shade700,
//                             height: 1.5,
//                           ),
//                           maxLines: 4,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 TextButton.icon(
//                   onPressed: () => _showRuleDetails(category, content),
//                   icon: const Icon(Icons.visibility, size: 20),
//                   label: const Text('عرض كامل'),
//                 ),
//                 const SizedBox(width: 8),
//                 TextButton.icon(
//                   onPressed: () => _showEditSingleRuleDialog(field, category, content),
//                   icon: const Icon(Icons.edit, size: 20),
//                   label: const Text('تعديل'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showRuleDetails(String category, String content) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(category),
//         content: SingleChildScrollView(
//           child: Text(
//             content,
//             style: const TextStyle(
//               height: 1.6,
//               fontSize: 16,
//             ),
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

//   void _showCreateRulesDialog() {
//     _showRulesFormDialog(isEdit: false);
//   }

//   void _showEditRulesDialog() {
//     _showRulesFormDialog(isEdit: true);
//   }

//   void _showEditSingleRuleDialog(String field, String category, String currentContent) {
//     _showSingleRuleFormDialog(field, category, currentContent);
//   }

//   void _showRulesFormDialog({required bool isEdit}) {
//     showDialog(
//       context: context,
//       builder: (context) => _RulesFormDialog(
//         isEdit: isEdit,
//         existingRules: _clanRules,
//         onSuccess: (String message) {
//           _showSuccessSnackBar(message);
//           _loadClanRules();
//         },
//         onError: (String message) {
//           _showErrorSnackBar(message);
//         },
//       ),
//     );
//   }

//   void _showSingleRuleFormDialog(String field, String category, String currentContent) {
//     showDialog(
//       context: context,
//       builder: (context) => _SingleRuleFormDialog(
//         field: field,
//         category: category,
//         currentContent: currentContent,
//         existingRules: _clanRules!,
//         onSuccess: (String message) {
//           _showSuccessSnackBar(message);
//           _loadClanRules();
//         },
//         onError: (String message) {
//           _showErrorSnackBar(message);
//         },
//       ),
//     );
//   }
// }

// // Complete rules form dialog
// class _RulesFormDialog extends StatefulWidget {
//   final bool isEdit;
//   final Map<String, dynamic>? existingRules;
//   final Function(String) onSuccess;
//   final Function(String) onError;

//   const _RulesFormDialog({
//     required this.isEdit,
//     this.existingRules,
//     required this.onSuccess,
//     required this.onError,
//   });

//   @override
//   State<_RulesFormDialog> createState() => _RulesFormDialogState();
// }

// class _RulesFormDialogState extends State<_RulesFormDialog> {
//   late final TextEditingController _generalRuleController;
//   late final TextEditingController _groomSuppliesController;
//   late final TextEditingController _clothingRuleController;
//   late final TextEditingController _kitchenwareRuleController;

//   @override
//   void initState() {
//     super.initState();
//     _generalRuleController = TextEditingController(
//       text: widget.existingRules?['general_rule'] ?? '',
//     );
//     _groomSuppliesController = TextEditingController(
//       text: widget.existingRules?['groom_supplies'] ?? '',
//     );
//     _clothingRuleController = TextEditingController(
//       text: widget.existingRules?['rule_about_clothing'] ?? '',
//     );
//     _kitchenwareRuleController = TextEditingController(
//       text: widget.existingRules?['rule_about_kitchenware'] ?? '',
//     );
//   }

//   @override
//   void dispose() {
//     _generalRuleController.dispose();
//     _groomSuppliesController.dispose();
//     _clothingRuleController.dispose();
//     _kitchenwareRuleController.dispose();
//     super.dispose();
//   }

//   Future<void> _saveRules() async {
//     try {
//       final rulesData = {
//         'general_rule': _generalRuleController.text.trim().isEmpty 
//             ? null : _generalRuleController.text.trim(),
//         'groom_supplies': _groomSuppliesController.text.trim().isEmpty 
//             ? null : _groomSuppliesController.text.trim(),
//         'rule_about_clothing': _clothingRuleController.text.trim().isEmpty 
//             ? null : _clothingRuleController.text.trim(),
//         'rule_about_kitchenware': _kitchenwareRuleController.text.trim().isEmpty 
//             ? null : _kitchenwareRuleController.text.trim(),
//       };
      
//       if (widget.isEdit) {
//         await ApiService.updateClanRules(widget.existingRules!['id'], rulesData);
//         widget.onSuccess('تم تعديل القوانين بنجاح');
//       } else {
//         final userInfo = await ApiService.getCurrentUserInfo();
//         rulesData['clan_id'] = userInfo['clan_id'];
//         await ApiService.createClanRules(rulesData);
//         widget.onSuccess('تم إنشاء القوانين بنجاح');
//       }
//       Navigator.pop(context);
//     } catch (e) {
//       widget.onError('خطأ: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text(widget.isEdit ? 'تعديل قوانين العشيرة' : 'إنشاء قوانين العشيرة'),
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _buildRuleField(
//               controller: _generalRuleController,
//               label: 'القوانين العامة',
//               hint: 'اكتب القوانين العامة للعشيرة هنا...',
//             ),
//             const SizedBox(height: 16),
//             _buildRuleField(
//               controller: _groomSuppliesController,
//               label: 'مستلزمات العريس',
//               hint: 'اكتب قوانين مستلزمات العريس هنا...',
//             ),
//             const SizedBox(height: 16),
//             _buildRuleField(
//               controller: _clothingRuleController,
//               label: 'قوانين الملابس',
//               hint: 'اكتب قوانين الملابس هنا...',
//             ),
//             const SizedBox(height: 16),
//             _buildRuleField(
//               controller: _kitchenwareRuleController,
//               label: 'قوانين أدوات المطبخ',
//               hint: 'اكتب قوانين أدوات المطبخ هنا...',
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('إلغاء'),
//         ),
//         ElevatedButton(
//           onPressed: _saveRules,
//           child: Text(widget.isEdit ? 'تعديل' : 'إنشاء'),
//         ),
//       ],
//     );
//   }

//   Widget _buildRuleField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextField(
//           controller: controller,
//           decoration: InputDecoration(
//             hintText: hint,
//             border: const OutlineInputBorder(),
//             filled: true,
//             fillColor: Colors.grey.shade50,
//           ),
//           maxLines: 4,
//           textDirection: TextDirection.rtl,
//         ),
//       ],
//     );
//   }
// }

// // Single rule form dialog
// class _SingleRuleFormDialog extends StatefulWidget {
//   final String field;
//   final String category;
//   final String currentContent;
//   final Map<String, dynamic> existingRules;
//   final Function(String) onSuccess;
//   final Function(String) onError;

//   const _SingleRuleFormDialog({
//     required this.field,
//     required this.category,
//     required this.currentContent,
//     required this.existingRules,
//     required this.onSuccess,
//     required this.onError,
//   });

//   @override
//   State<_SingleRuleFormDialog> createState() => _SingleRuleFormDialogState();
// }

// class _SingleRuleFormDialogState extends State<_SingleRuleFormDialog> {
//   late final TextEditingController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = TextEditingController(text: widget.currentContent);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Future<void> _saveRule() async {
//     try {
//       final updatedRules = Map<String, dynamic>.from(widget.existingRules);
//       updatedRules[widget.field] = _controller.text.trim().isEmpty 
//           ? null : _controller.text.trim();
//       updatedRules.remove('id');
//       updatedRules.remove('clan_id');
      
//       await ApiService.updateClanRules(widget.existingRules['id'], updatedRules);
//       widget.onSuccess('تم تعديل ${widget.category} بنجاح');
//       Navigator.pop(context);
//     } catch (e) {
//       widget.onError('خطأ: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text('تعديل ${widget.category}'),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           TextField(
//             controller: _controller,
//             decoration: InputDecoration(
//               hintText: 'اكتب ${widget.category} هنا...',
//               border: const OutlineInputBorder(),
//               filled: true,
//               fillColor: Colors.grey.shade50,
//             ),
//             maxLines: 8,
//             textDirection: TextDirection.rtl,
//           ),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('إلغاء'),
//         ),
//         ElevatedButton(
//           onPressed: _saveRule,
//           child: const Text('حفظ'),
//         ),
//       ],
//     );
//   }
// }