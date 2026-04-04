// // lib/screens/clan_admin/groom_access_password_page.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// import '../../services/api_service.dart';

// class GroomAccessPasswordPage extends StatefulWidget {
//   const GroomAccessPasswordPage({Key? key}) : super(key: key);

//   @override
//   State<GroomAccessPasswordPage> createState() => GroomAccessPasswordPageState();
// }

// class GroomAccessPasswordPageState extends State<GroomAccessPasswordPage> {
//   List<dynamic> _grooms = [];
//   List<dynamic> _filteredGrooms = [];
//   bool _isLoading = true;
//   String _searchQuery = '';

//   @override
//   void initState() {
//     super.initState();
//     _loadGrooms();
//   }

//   void refreshData(){
//     _loadGrooms();
//   }
//   Future<void> _loadGrooms() async {
//     setState(() => _isLoading = true);

//     try {
//       final grooms = await ApiService.getGroomsWithAccessStatus();
//       setState(() {
//         _grooms = grooms;
//         _filterGrooms();
//         _isLoading = false;
//       });
//     } catch (e) {
//       _showError('فشل في تحميل العرسان: $e');
//       setState(() => _isLoading = false);
//     }
//   }

//   void _filterGrooms() {
//     setState(() {
//       if (_searchQuery.isEmpty) {
//         _filteredGrooms = _grooms;
//       } else {
//         _filteredGrooms = _grooms.where((groom) {
//           final firstName = groom['first_name']?.toString().toLowerCase() ?? '';
//           final lastName = groom['last_name']?.toString().toLowerCase() ?? '';
//           final phoneNumber = groom['phone_number']?.toString() ?? '';
//           final query = _searchQuery.toLowerCase();
          
//           return firstName.contains(query) || 
//                  lastName.contains(query) || 
//                  phoneNumber.contains(query);
//         }).toList();
//       }
//     });
//   }

//   Future<void> _generateAccessPassword(int groomId, String groomName) async {
//     final confirmed = await _showConfirmDialog(
//       'إنشاء كلمة مرور الوصول',
//       'هل أنت متأكد من إنشاء كلمة مرور وصول جديدة للعريس $groomName؟\nسيتم إلغاء كلمة المرور القديمة إن وجدت.',
//     );

//     if (!confirmed) return;

//     try {
//       _showLoadingDialog();
      
//       final result = await ApiService.generateGroomAccessPassword(groomId);
      
//       Navigator.pop(context); // Close loading dialog
      
//       _showGeneratedPasswordDialog(
//         result['generated_password'],
//         groomName,
//       );

//       // Reload to update status
//       _loadGrooms();
//     } catch (e) {
//       Navigator.pop(context); // Close loading dialog
//       _showError('فشل في إنشاء كلمة مرور الوصول: $e');
//     }
//   }

//   Future<void> _setCustomPassword(int groomId, String groomName) async {
//     final controller = TextEditingController();
    
//     final password = await showDialog<String>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('تعيين كلمة مرور مخصصة'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('تعيين كلمة مرور وصول للعريس: $groomName'),
//             const SizedBox(height: 16),
//             TextField(
//               controller: controller,
//               decoration: const InputDecoration(
//                 labelText: 'كلمة مرور الوصول',
//                 hintText: 'أدخل كلمة المرور',
//                 border: OutlineInputBorder(),
//               ),
//               obscureText: true,
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'ملاحظة: استخدم كلمة مرور سهلة التذكر للعريس',
//               style: TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (controller.text.isNotEmpty) {
//                 Navigator.pop(context, controller.text);
//               }
//             },
//             child: const Text('تعيين'),
//           ),
//         ],
//       ),
//     );

//     if (password == null || password.isEmpty) return;

//     try {
//       _showLoadingDialog();
      
//       await ApiService.setGroomAccessPassword(groomId, password);
      
//       Navigator.pop(context); // Close loading dialog
      
//       _showSuccess('تم تعيين كلمة مرور الوصول بنجاح للعريس $groomName');
//       _loadGrooms();
//     } catch (e) {
//       Navigator.pop(context);
//       _showError('فشل في تعيين كلمة مرور الوصول: $e');
//     }
//   }

//   void _showGeneratedPasswordDialog(String password, String groomName) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: Row(
//           children: [
//             const Icon(Icons.key, color: Colors.green),
//             const SizedBox(width: 8),
//             const Expanded(child: Text('كلمة مرور الوصول')),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'تم إنشاء كلمة مرور الوصول للعريس:',
//               style: Theme.of(context).textTheme.bodyMedium,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               groomName,
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 24),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade50,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.blue.shade200),
//               ),
//               child: SelectableText(
//                 password,
//                 style: const TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blue,
//                   letterSpacing: 2,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.amber.shade50,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.amber.shade200),
//               ),
//               child: Row(
//                 children: const [
//                   Icon(Icons.info_outline, color: Colors.amber, size: 20),
//                   SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'احفظ هذه الكلمة وأرسلها للعريس',
//                       style: TextStyle(
//                         color: Colors.orange,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton.icon(
//             onPressed: () {
//               Clipboard.setData(ClipboardData(text: password));
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('تم نسخ كلمة المرور'),
//                   backgroundColor: Colors.green,
//                 ),
//               );
//             },
//             icon: const Icon(Icons.copy),
//             label: const Text('نسخ'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('إغلاق'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showGroomDetails(Map<String, dynamic> groom) {
//     final hasPassword = groom['has_access_password'] ?? false;
    
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('${groom['first_name']} ${groom['last_name']}'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildInfoRow('رقم الهاتف', groom['phone_number']),
//             _buildInfoRow('تاريخ الميلاد', groom['birth_date'] ?? 'غير محدد'),
//             _buildInfoRow('العنوان', groom['home_address'] ?? 'غير محدد'),
//             const Divider(),
//             Row(
//               children: [
//                 Icon(
//                   hasPassword ? Icons.check_circle : Icons.cancel,
//                   color: hasPassword ? Colors.green : Colors.red,
//                   size: 20,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   hasPassword ? 'لديه كلمة مرور وصول' : 'لا توجد كلمة مرور وصول',
//                   style: TextStyle(
//                     color: hasPassword ? Colors.green : Colors.red,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ],
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

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(
//               '$label:',
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(
//             child: Text(value),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showLoadingDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => const Center(
//         child: Card(
//           child: Padding(
//             padding: EdgeInsets.all(20),
//             child: CircularProgressIndicator(),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<bool> _showConfirmDialog(String title, String message) async {
//     final result = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(title),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('تأكيد'),
//           ),
//         ],
//       ),
//     );
//     return result ?? false;
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }

//   void _showSuccess(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('إدارة كلمات مرور العرسان'),
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadGrooms,
//             tooltip: 'تحديث',
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Info Banner
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(16),
//             color: Colors.blue.shade50,
//             child: Row(
//               children: const [
//                 Icon(Icons.info_outline, color: Colors.blue),
//                 SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     'يمكنك إنشاء كلمات مرور وصول للعرسان للصفحات الخاصة',
//                     style: TextStyle(color: Colors.blue),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Search Bar
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: 'البحث عن عريس...',
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 suffixIcon: _searchQuery.isNotEmpty
//                     ? IconButton(
//                         icon: const Icon(Icons.clear),
//                         onPressed: () {
//                           setState(() {
//                             _searchQuery = '';
//                             _filterGrooms();
//                           });
//                         },
//                       )
//                     : null,
//               ),
//               onChanged: (value) {
//                 setState(() {
//                   _searchQuery = value;
//                   _filterGrooms();
//                 });
//               },
//             ),
//           ),

//           // Statistics
//           if (!_isLoading)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Row(
//                 children: [
//                   _buildStatCard(
//                     'إجمالي العرسان',
//                     _grooms.length.toString(),
//                     Icons.people,
//                     Colors.blue,
//                   ),
//                   const SizedBox(width: 12),
//                   _buildStatCard(
//                     'لديهم كلمة مرور',
//                     _grooms.where((g) => g['access_pages_password_hash'] == true).length.toString(),
//                     Icons.verified_user,
//                     Colors.green,
//                   ),
//                   const SizedBox(width: 12),
//                   _buildStatCard(
//                     'بدون كلمة مرور',
//                     _grooms.where((g) => g['access_pages_password_hash'] != true).length.toString(),
//                     Icons.lock_open,
//                     Colors.orange,
//                   ),
//                 ],
//               ),
//             ),

//           const SizedBox(height: 16),

//           // Grooms List
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : _filteredGrooms.isEmpty
//                     ? Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: const [
//                             Icon(Icons.person_off, size: 64, color: Colors.grey),
//                             SizedBox(height: 16),
//                             Text(
//                               'لا توجد نتائج',
//                               style: TextStyle(fontSize: 18, color: Colors.grey),
//                             ),
//                           ],
//                         ),
//                       )
//                     : ListView.builder(
//                         padding: const EdgeInsets.all(16),
//                         itemCount: _filteredGrooms.length,
//                         itemBuilder: (context, index) {
//                           final groom = _filteredGrooms[index];
//                           final hasPassword = groom['access_pages_password_hash']  != null;

//                           final fullName = '${groom['first_name']} ${groom['last_name']}';
                          
//                           return Card(
//                             margin: const EdgeInsets.only(bottom: 12),
//                             elevation: 2,
//                             child: ListTile(
//                               onTap: () => _showGroomDetails(groom),
//                               leading: CircleAvatar(
//                                 backgroundColor: hasPassword ? Colors.green : Colors.orange,
//                                 child: Text(
//                                   groom['first_name'][0].toUpperCase(),
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                               title: Text(
//                                 fullName,
//                                 style: const TextStyle(fontWeight: FontWeight.bold),
//                               ),
//                               subtitle: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text('هاتف: ${groom['phone_number']}'),
//                                   const SizedBox(height: 4),
//                                   Row(
//                                     children: [
//                                       Icon(
//                                         hasPassword ? Icons.check_circle : Icons.warning,
//                                         size: 14,
//                                         color: hasPassword ? Colors.green : Colors.orange,
//                                       ),
//                                       const SizedBox(width: 4),
//                                       Text(
//                                         hasPassword ? 'لديه كلمة مرور' : 'لا توجد كلمة مرور',
//                                         style: TextStyle(
//                                           fontSize: 12,
//                                           color: hasPassword ? Colors.green : Colors.orange,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                               trailing: PopupMenuButton<String>(
//                                 icon: const Icon(Icons.more_vert),
//                                 onSelected: (value) {
//                                   if (value == 'generate') {
//                                     _generateAccessPassword(groom['id'], fullName);
//                                   } else if (value == 'custom') {
//                                     _setCustomPassword(groom['id'], fullName);
//                                   } else if (value == 'details') {
//                                     _showGroomDetails(groom);
//                                   }
//                                 },
//                                 itemBuilder: (context) => [
//                                   const PopupMenuItem(
//                                     value: 'generate',
//                                     child: Row(
//                                       children: [
//                                         Icon(Icons.auto_awesome),
//                                         SizedBox(width: 8),
//                                         Text('إنشاء تلقائي'),
//                                       ],
//                                     ),
//                                   ),
//                                   const PopupMenuItem(
//                                     value: 'custom',
//                                     child: Row(
//                                       children: [
//                                         Icon(Icons.edit),
//                                         SizedBox(width: 8),
//                                         Text('تعيين مخصص'),
//                                       ],
//                                     ),
//                                   ),
//                                   const PopupMenuItem(
//                                     value: 'details',
//                                     child: Row(
//                                       children: [
//                                         Icon(Icons.info),
//                                         SizedBox(width: 8),
//                                         Text('التفاصيل'),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatCard(String label, String value, IconData icon, Color color) {
//     return Expanded(
//       child: Card(
//         elevation: 2,
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             children: [
//               Icon(icon, color: color, size: 24),
//               const SizedBox(height: 8),
//               Text(
//                 value,
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: color,
//                 ),
//               ),
//               Text(
//                 label,
//                 style: const TextStyle(fontSize: 10),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }