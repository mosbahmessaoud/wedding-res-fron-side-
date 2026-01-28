// import 'package:flutter/material.dart';

// import '../../services/api_service.dart';
// // TODO: Uncomment this import when custom_calendar_picker.dart is available
// import '../groom/custom_calendar_picker.dart';

// class ManualRegisterGroomScreen extends StatefulWidget {
//   const ManualRegisterGroomScreen({Key? key}) : super(key: key);

//   @override
//   State<ManualRegisterGroomScreen> createState() => _ManualRegisterGroomScreenState();
// }

// class _ManualRegisterGroomScreenState extends State<ManualRegisterGroomScreen> {
//   final _formKey = GlobalKey<FormState>();
  
//   // Groom info controllers
//   final _phoneController = TextEditingController();
//   final _firstNameController = TextEditingController();
//   final _lastNameController = TextEditingController();
//   final _fatherNameController = TextEditingController();
//   final _grandfatherNameController = TextEditingController();
//   final _guardianPhoneController = TextEditingController();
//   final _guardianNameController = TextEditingController();
  
//   // Reservation controllers
//   final _date1Controller = TextEditingController();
//   final _customMadaehCommitteeController = TextEditingController();
//   final _customTilawaNameController = TextEditingController();
  
//   // State variables
//   bool _isSubmitting = false;
//   int? _clanId;
//   int? _countyId;
//   bool _createReservation = false;
//   bool _date2Bool = false;
//   bool _allowOthers = false;
//   bool _joinToMassWedding = false;
//   bool _showCustomMadaehInput = false;
//   bool _showCustomTilawaInput = false;
//   bool _isLoadingDropdowns = false;
  
//   // Dropdown data
//   Map<String, dynamic>? _selectedClan;
//   Map<String, dynamic>? _selectedCounty;
//   Map<String, dynamic>? _selectedHall;
//   Map<String, dynamic>? _selectedHaiaCommittee;
//   Map<String, dynamic>? _selectedMadaehCommittee;
//   String? _selectedTilawaType;
  
//   List<Map<String, dynamic>> _clans = [];
//   List<Map<String, dynamic>> _halls = [];
//   List<Map<String, dynamic>> _haiaCommittees = [];
//   List<Map<String, dynamic>> _madaehCommittees = [];
//   bool _isLoadingClans = false;
//   bool _isLoadingHalls = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserInfo();
//     _loadDropdownData();
//   }

//   Future<void> _loadUserInfo() async {
//     try {
//       final userInfo = await ApiService.getCurrentUserInfo();
//       if (mounted) {
//         setState(() {
//           _clanId = userInfo['clan_id'];
//           _countyId = userInfo['county_id'];
//         });
//       }
//     } catch (e) {
//       print('Error loading user info: $e');
//     }
//   }

//   Future<void> _loadDropdownData() async {
//     print('🔵 [_loadDropdownData] Starting to load dropdown data...');
//     setState(() => _isLoadingDropdowns = true);
    
//     try {
//       // Load county info first if available
//       if (_countyId != null) {
//         print('🔵 [_loadDropdownData] Loading county data for county_id: $_countyId');
//         try {
//           final countyData = await ApiService.getCounty(_countyId!);
//           if (mounted) {
//             setState(() => _selectedCounty = countyData);
//             print('✅ [_loadDropdownData] County loaded: ${countyData['name']}');
//           }
//         } catch (e) {
//           print('⚠️ [_loadDropdownData] Error loading county: $e');
//           // Continue even if county load fails
//         }
//       }

//       // Load data sequentially with timeout handling
//       List<Map<String, dynamic>> clans = [];
//       List<Map<String, dynamic>> haiaCommittees = [];
//       List<Map<String, dynamic>> madaehCommittees = [];

//       // Load clans
//       if (_countyId != null) {
//         try {
//           print('🔵 [_loadDropdownData] Loading clans for county_id: $_countyId');
//           clans = List<Map<String, dynamic>>.from(
//             await ApiService.getClansByCounty(_countyId!).timeout(
//               const Duration(seconds: 10),
//               onTimeout: () {
//                 print('⚠️ Clans loading timed out');
//                 return [];
//               },
//             ),
//           );
//           print('✅ [_loadDropdownData] Loaded ${clans.length} clans');
//         } catch (e) {
//           print('❌ [_loadDropdownData] Error loading clans: $e');
//         }
//       }

//       // Load Haia committees with retry
//       try {
//         print('🔵 [_loadDropdownData] Loading Haia committees...');
//         haiaCommittees = List<Map<String, dynamic>>.from(
//           await ApiService.getGroomHaia().timeout(
//             const Duration(seconds: 15),
//             onTimeout: () {
//               print('⚠️ Haia committees loading timed out');
//               return [];
//             },
//           ),
//         );
//         print('✅ [_loadDropdownData] Loaded ${haiaCommittees.length} Haia committees');
//       } catch (e) {
//         print('❌ [_loadDropdownData] Error loading Haia: $e');
//         // Provide empty list as fallback
//         haiaCommittees = [];
//       }

//       // Load Madaeh committees with retry
//       try {
//         print('🔵 [_loadDropdownData] Loading Madaeh committees...');
//         madaehCommittees = List<Map<String, dynamic>>.from(
//           await ApiService.getGroomMadaihCommittee().timeout(
//             const Duration(seconds: 15),
//             onTimeout: () {
//               print('⚠️ Madaeh committees loading timed out');
//               return [];
//             },
//           ),
//         );
//         print('✅ [_loadDropdownData] Loaded ${madaehCommittees.length} Madaeh committees');
//       } catch (e) {
//         print('❌ [_loadDropdownData] Error loading Madaeh: $e');
//         // Provide empty list as fallback
//         madaehCommittees = [];
//       }
      
//       if (mounted) {
//         setState(() {
//           _clans = clans;
//           _haiaCommittees = haiaCommittees;
//           _madaehCommittees = madaehCommittees;
//           _isLoadingDropdowns = false;
//         });
//         print('✅ [_loadDropdownData] All data loaded successfully');
//       }
//     } catch (e) {
//       print('❌ [_loadDropdownData] Critical error: $e');
//       if (mounted) setState(() => _isLoadingDropdowns = false);
      
//       // Show user-friendly error message
//       if (mounted) {
//         _showMessageDialog(
//           title: 'تحذير',
//           message: 'حدث خطأ في تحميل بعض البيانات. يمكنك المحاولة مرة أخرى أو الاستمرار بالبيانات المتاحة.',
//           icon: Icons.warning,
//           titleColor: Colors.orange,
//         );
//       }
//     }
//   }

//   Future<void> _onClanSelected(Map<String, dynamic>? clan) async {
//     setState(() {
//       _selectedClan = clan;
//       _selectedHall = null;
//       _halls = [];
//       _isLoadingHalls = true;
//     });

//     if (clan != null) {
//       try {
//         final halls = await ApiService.getHallsByClan(clan['id']);
//         if (mounted) {
//           setState(() {
//             _halls = List<Map<String, dynamic>>.from(halls);
//             _isLoadingHalls = false;
//           });
//         }
//       } catch (e) {
//         print('Error loading halls: $e');
//         if (mounted) {
//           setState(() => _isLoadingHalls = false);
//         }
//       }
//     }
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     if (_selectedClan == null || _selectedHall == null) {
//       _showMessageDialog(
//         title: 'معلومات ناقصة',
//         message: 'يرجى اختيار العشيرة والقاعة أولاً قبل تحديد التاريخ.',
//         icon: Icons.warning,
//         titleColor: Colors.orange,
//       );
//       return;
//     }

//     // Show loading indicator
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => const Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CircularProgressIndicator(color: Colors.white),
//             SizedBox(height: 16),
//             Text(
//               'جاري تحميل توفر التواريخ...',
//               style: TextStyle(color: Colors.white),
//             ),
//           ],
//         ),
//       ),
//     );

//     try {
//       final now = DateTime.now();
      
//       if (Navigator.canPop(context)) {
//         Navigator.of(context).pop();
//       }

//       if (mounted) {
//         // You'll need to import the custom calendar picker file
//         // import 'package:wedding_reservation_app/screens/groom/custom_calendar_picker.dart';
        
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (context) {
//             // Dynamically import the BeautifulCustomCalendarPicker here
//             // Since we don't have the full implementation, I'll create a placeholder
//             // You need to replace this with actual import
//             return BeautifulCustomCalendarPicker(
//      title: 'تاريخ الحجز',
//      clanId: _selectedClan!['id'],
//      hallId: _selectedHall?['id'],
//      maxCapacityPerDate: 3, // Or use dynamic value
//      initialDate: _date1Controller.text.isNotEmpty 
//          ? DateTime.tryParse(_date1Controller.text) ?? now.add(const Duration(days: 30))
//          : now.add(const Duration(days: 30)),
//      firstDate: now,
//      lastDate: now.add(const Duration(days: 365)),
//      allowTwoConsecutiveDays: false,
//      onDateSelected: (selectedDate, availability) {
//        Navigator.of(context).pop();
//        setState(() {
//          _date1Controller.text = selectedDate.toLocal().toString().split(' ')[0];
//        });
//      },
//      onCancel: () {
//        Navigator.of(context).pop();
//      },
//      isOriginClan: _clanId == _selectedClan!['id'],
//      yearsMaxReservGroomFromOriginClan: 3,
//      yearsMaxReservGroomFromOutClan: 1,
//    );
//           },
//         );
//       }

//     } catch (e) {
//       if (Navigator.canPop(context)) {
//         Navigator.of(context).pop();
//       }
      
//       print('Error loading calendar: $e');
      
//       if (mounted) {
//         _showMessageDialog(
//           title: 'خطأ في تحميل التقويم',
//           message: 'خطأ في تحميل التقويم:\n\n$e\n\nسيتم فتح منتقي التاريخ البديل.',
//           icon: Icons.calendar_today,
//           isError: true,
//         );

//         _showFallbackDatePicker(context);
//       }
//     }
//   }

//   // Fallback simple date picker
//   Future<void> _showFallbackDatePicker(BuildContext context) async {
//     try {
//       final now = DateTime.now();
      
//       final DateTime? picked = await showDatePicker(
//         context: context,
//         initialDate: _date1Controller.text.isNotEmpty 
//             ? DateTime.tryParse(_date1Controller.text) ?? now.add(const Duration(days: 30))
//             : now.add(const Duration(days: 30)),
//         firstDate: now,
//         lastDate: now.add(const Duration(days: 365)),
//         helpText: 'تاريخ الحجز',
//         cancelText: 'إلغاء',
//         confirmText: 'تأكيد',
//         builder: (context, child) {
//           return Theme(
//             data: Theme.of(context).copyWith(
//               colorScheme: ColorScheme.light(
//                 primary: Theme.of(context).primaryColor,
//                 onPrimary: Colors.white,
//                 surface: Colors.white,
//                 onSurface: Colors.black,
//               ),
//             ),
//             child: child!,
//           );
//         },
//       );
      
//       if (picked != null && mounted) {
//         setState(() {
//           _date1Controller.text = picked.toLocal().toString().split(' ')[0];
//         });
        
//         _showMessageDialog(
//           title: 'تحذير - تم تجاوز فحص التوفر',
//           message: 'تم اختيار التاريخ بدون التحقق من التوفر.\n\nقد يتم رفض الحجز إذا كان التاريخ محجوز مسبقاً.\n\nيُنصح بالتحقق من توفر التاريخ قبل تأكيد الحجز.',
//           icon: Icons.warning,
//           titleColor: Colors.orange,
//         );
//       }
//     } catch (e) {
//       print('Error in fallback date picker: $e');
//       if (mounted) {
//         _showMessageDialog(
//           title: 'خطأ في اختيار التاريخ',
//           message: 'خطأ في اختيار التاريخ:\n\n$e\n\nيرجى المحاولة مرة أخرى.',
//           icon: Icons.error,
//           isError: true,
//         );
//       }
//     }
//   }

//   String _getValidationDeadlineDays() {
//     try {
//       if (_date1Controller.text.isEmpty) return '7';
//       final days = DateTime.parse(_date1Controller.text).difference(DateTime.now()).inDays;
//       if (days > 30) return '7';
//       if (days > 14) return '5';
//       if (days > 7) return '3';
//       return '2';
//     } catch (e) {
//       return '7';
//     }
//   }

//   void _showMessageDialog({
//     required String title,
//     required String message,
//     required IconData icon,
//     Color? titleColor,
//     bool isError = false,
//   }) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Row(
//           children: [
//             Icon(icon, color: titleColor ?? (isError ? Colors.red : Colors.green)),
//             const SizedBox(width: 8),
//             Expanded(child: Text(title, style: TextStyle(color: titleColor ?? (isError ? Colors.red : Colors.green)))),
//           ],
//         ),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('حسناً'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _register() async {
//     if (!_formKey.currentState!.validate()) return;

//     if (_createReservation) {
//       if (_date1Controller.text.isEmpty) {
//         _showMessageDialog(title: 'خطأ في التحقق', message: 'يرجى تحديد تاريخ الحجز', icon: Icons.error, isError: true);
//         return;
//       }
//       if (_selectedClan == null || _selectedHall == null) {
//         _showMessageDialog(title: 'خطأ في التحقق', message: 'يرجى تحديد العشيرة والقاعة', icon: Icons.error, isError: true);
//         return;
//       }
//       if (_selectedHaiaCommittee == null || _selectedMadaehCommittee == null) {
//         _showMessageDialog(title: 'خطأ في التحقق', message: 'يرجى تحديد اللجان المطلوبة', icon: Icons.error, isError: true);
//         return;
//       }
//       if (_selectedTilawaType == null) {
//         _showMessageDialog(title: 'خطأ في التحقق', message: 'يرجى تحديد نوع التلاوة', icon: Icons.error, isError: true);
//         return;
//       }
//     }

//     setState(() => _isSubmitting = true);

//     try {
//       final groomResponse = await ApiService.registerGroomByAdmin(
//         phoneNumber: _phoneController.text.trim(),
//         firstName: _firstNameController.text.trim(),
//         lastName: _lastNameController.text.trim(),
//         fatherName: _fatherNameController.text.trim(),
//         grandfatherName: _grandfatherNameController.text.trim(),
//         clanId: _clanId!,
//         countyId: _countyId!,
//         guardianPhone: _guardianPhoneController.text.trim().isEmpty ? null : _guardianPhoneController.text.trim(),
//         guardianName: _guardianNameController.text.trim().isEmpty ? null : _guardianNameController.text.trim(),
//       );

//       if (_createReservation) {
//         await _createReservationForGroom(groomResponse['user_id']);
//       } else {
//         if (mounted) {
//           _showMessageDialog(
//             title: 'تم التسجيل بنجاح',
//             message: groomResponse['message'] ?? 'تم تسجيل العريس بنجاح',
//             icon: Icons.check_circle,
//             titleColor: Colors.green,
//           );
//           _clearForm();
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         _showMessageDialog(title: 'خطأ في التسجيل', message: 'فشل في تسجيل العريس: ${e.toString()}', icon: Icons.error, isError: true);
//       }
//     } finally {
//       if (mounted) setState(() => _isSubmitting = false);
//     }
//   }

//   Future<void> _createReservationForGroom(int groomUserId) async {
//     try {
//       if (_clanId != null) {
//         final clanAdminStatus = await ApiService.checkClanAdminStatus();
//         if (clanAdminStatus['has_admin'] == false || clanAdminStatus['is_active'] == false) {
//           if (mounted) {
//             _showMessageDialog(
//               title: 'عشيرتك ليست في النظام حالياً',
//               message: 'عذراً، ${clanAdminStatus['clan_name']} ليست في النظام حالياً.\n\nيرجى التواصل مع إدارة عشيرتك لمزيد من التفاصيل.',
//               icon: Icons.business_center_outlined,
//               titleColor: Colors.orange,
//               isError: true,
//             );
//           }
//           return;
//         }
//       }

//       final reservationData = {
//         'date1': _date1Controller.text,
//         'date2_bool': _date2Bool,
//         'allow_others': _allowOthers,
//         'join_to_mass_wedding': _joinToMassWedding,
//         'clan_id': _selectedClan!['id'],
//         'hall_id': _selectedHall!['id'],
//         'haia_committee_id': _selectedHaiaCommittee!['id'],
//         'madaeh_committee_id': _selectedMadaehCommittee!['id'],
//         'user_id': groomUserId,
//       };

//       if (_showCustomMadaehInput && _customMadaehCommitteeController.text.trim().isNotEmpty) {
//         reservationData['custom_madaeh_committee_name'] = _customMadaehCommitteeController.text.trim();
//       }

//       if (_selectedTilawaType != null) {
//         reservationData['tilawa_type'] = _showCustomTilawaInput && _customTilawaNameController.text.trim().isNotEmpty
//             ? _customTilawaNameController.text.trim()
//             : _selectedTilawaType;
//       }

//       final response = await ApiService.createReservation(reservationData);

//       if (mounted) {
//         _showMessageDialog(
//           title: 'تم التسجيل والحجز بنجاح',
//           message: 'تم تسجيل العريس وإنشاء الحجز بنجاح!\n\n'
//               'يجب طباعة الحجز وختمه وتوقيعه خلال ${_getValidationDeadlineDays()} أيام كأقصى حد، '
//               'وإلا سيتم إلغاء الحجز تلقائياً.\n\nرقم الحجز: ${response['reservation_id']}',
//           icon: Icons.check_circle,
//           titleColor: Colors.green,
//         );
//         _clearForm();
//       }
//     } catch (e) {
//       if (mounted) {
//         _showMessageDialog(title: 'خطأ في إنشاء الحجز', message: 'فشل في إنشاء الحجز للعريس: ${e.toString()}', icon: Icons.error, isError: true);
//       }
//     }
//   }

//   void _clearForm() {
//     _formKey.currentState!.reset();
//     _phoneController.clear();
//     _firstNameController.clear();
//     _lastNameController.clear();
//     _fatherNameController.clear();
//     _grandfatherNameController.clear();
//     _guardianPhoneController.clear();
//     _guardianNameController.clear();
//     _date1Controller.clear();
//     _customMadaehCommitteeController.clear();
//     _customTilawaNameController.clear();
    
//     setState(() {
//       _createReservation = false;
//       _date2Bool = false;
//       _allowOthers = false;
//       _joinToMassWedding = false;
//       _showCustomMadaehInput = false;
//       _showCustomTilawaInput = false;
//       _selectedClan = null;
//       _selectedHall = null;
//       _selectedHaiaCommittee = null;
//       _selectedMadaehCommittee = null;
//       _selectedTilawaType = null;
//       _halls = [];
//     });
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     String? Function(String?)? validator,
//     TextInputType? keyboardType,
//   }) {
//     return TextFormField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: label,
//         border: const OutlineInputBorder(),
//         prefixIcon: Icon(icon),
//       ),
//       keyboardType: keyboardType,
//       validator: validator ?? (value) => value == null || value.isEmpty ? '$label مطلوب' : null,
//     );
//   }

//   Widget _buildDropdown<T>({
//     required String label,
//     required IconData icon,
//     required T? value,
//     required List<Map<String, dynamic>> items,
//     required void Function(T?) onChanged,
//     String? Function(T?)? validator,
//     bool isLoading = false,
//   }) {
//     return DropdownButtonFormField<T>(
//       value: value,
//       isExpanded: true,
//       decoration: InputDecoration(
//         labelText: label,
//         border: const OutlineInputBorder(),
//         prefixIcon: Icon(icon),
//       ),
//       items: items.map((item) => DropdownMenuItem<T>(
//         value: item as T,
//         child: Text(item['name']?.toString() ?? ''),
//       )).toList(),
//       onChanged: onChanged,
//       validator: validator,
//       icon: isLoading 
//         ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5))
//         : const Icon(Icons.keyboard_arrow_down),
//     );
//   }

//   // Build info row helper
//   Widget _buildInfoRow(String label, String value, bool isDark) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 2,
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: isDark ? Colors.white70 : Colors.grey[700],
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Text(
//               value,
//               style: TextStyle(
//                 color: isDark ? Colors.white : Colors.black87,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Clan and Hall Selection Step (from document 4)
//   Widget _buildClanAndHallSelectionStep() {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'اختيار دار إقامة العرس',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Theme.of(context).primaryColor,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'اختر العشيرة والقاعة المناسبة لحفلك\nالقصر: ${_selectedCounty?['name'] ?? 'غير محدد'}',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: isDark ? Colors.white70 : Colors.grey[600],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             IconButton(
//               onPressed: _loadDropdownData,
//               icon: const Icon(Icons.refresh),
//               tooltip: 'إعادة تحميل البيانات',
//             ),
//           ],
//         ),
//         const SizedBox(height: 24),
        
//         // Show loading indicator or warning if data failed to load
//         if (_isLoadingDropdowns)
//           const Center(
//             child: Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 8),
//                   Text('جاري تحميل البيانات...'),
//                 ],
//               ),
//             ),
//           )
//         else if (_clans.isEmpty && _countyId != null)
//           Card(
//             color: Colors.orange[50],
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Row(
//                 children: [
//                   const Icon(Icons.warning, color: Colors.orange),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'لم يتم تحميل العشائر',
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 4),
//                         const Text('قد يكون هناك مشكلة في الاتصال'),
//                         const SizedBox(height: 8),
//                         ElevatedButton.icon(
//                           onPressed: _loadDropdownData,
//                           icon: const Icon(Icons.refresh, size: 18),
//                           label: const Text('إعادة المحاولة'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.orange,
//                             foregroundColor: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
        
//         // Clan Selection
//         DropdownButtonFormField<Map<String, dynamic>>(
//           value: _selectedClan,
//           isExpanded: true,
//           decoration: InputDecoration(
//             labelText: 'العشيرة *',
//             prefixIcon: const Icon(Icons.group),
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             helperText: _clans.isEmpty ? 'لا توجد عشائر متاحة' : 'العشائر المتاحة في قصرك',
//           ),
//           items: (_clans..sort((a, b) {
//             final idA = a['id'] ?? 0;
//             final idB = b['id'] ?? 0;
//             return idA.compareTo(idB);
//           })).map((clan) {
//             return DropdownMenuItem<Map<String, dynamic>>(
//               value: clan,
//               child: Text(
//                 clan['name']?.toString() ?? 'عشيرة غير مسماة',
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             );
//           }).toList(),
//           onChanged: _clans.isEmpty ? null : _onClanSelected,
//           validator: (value) => value == null ? 'العشيرة مطلوبة' : null,
//           icon: _isLoadingClans 
//               ? const SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(strokeWidth: 2.5),
//                 )
//               : const Icon(Icons.keyboard_arrow_down),
//         ),

//         const SizedBox(height: 24),

//         // Hall Selection
//         if (_selectedClan != null) ...[
//           DropdownButtonFormField<Map<String, dynamic>>(
//             value: _selectedHall,
//             isExpanded: true,
//             decoration: InputDecoration(
//               labelText: 'القاعة *',
//               prefixIcon: const Icon(Icons.business),
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               helperText: _halls.isEmpty 
//                   ? 'لا توجد قاعات متاحة لهذه العشيرة' 
//                   : 'القاعات المتاحة للعشيرة المختارة',
//             ),
//             items: _halls.map((hall) {
//               return DropdownMenuItem<Map<String, dynamic>>(
//                 value: hall,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       hall['name']?.toString() ?? 'قاعة غير مسماة',
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     Text(
//                       'السعة: ${hall['capacity']} شخص',
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//             onChanged: _halls.isEmpty ? null : (value) => setState(() => _selectedHall = value),
//             validator: (value) => value == null ? 'القاعة مطلوبة' : null,
//             icon: _isLoadingHalls 
//                 ? const SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(strokeWidth: 2.5),
//                   )
//                 : const Icon(Icons.keyboard_arrow_down),
//           ),
//         ],
        
//         const SizedBox(height: 24),
        
//         // Clan Information Display
//         if (_selectedClan != null) ...[
//           Card(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'معلومات العشيرة المختارة',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Theme.of(context).primaryColor,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   _buildInfoRow('اسم العشيرة', _selectedClan!['name']?.toString() ?? '', isDark),
//                   _buildInfoRow('القصر', _selectedCounty?['name']?.toString() ?? '', isDark),
//                   if (_selectedClan!['description'] != null)
//                     _buildInfoRow('الوصف', _selectedClan!['description'].toString(), isDark),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ],
//     );
//   }

//   // Extracted reservation details step from document 2
//   Widget _buildReservationDetailsStep() {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
    
//     return SingleChildScrollView(
//       physics: const AlwaysScrollableScrollPhysics(),
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'معلومات الحجز',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: isDark ? Colors.white : Theme.of(context).primaryColor,
//             ),
//           ),
//           const SizedBox(height: 24),
          
//           // Primary Date
//           TextFormField(
//             controller: _date1Controller,
//             readOnly: true,
//             onTap: () => _selectDate(context),
//             decoration: InputDecoration(
//               labelText: 'تاريخ الحجز *',
//               prefixIcon: const Icon(Icons.calendar_today),
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               suffixIcon: const Icon(Icons.arrow_drop_down),
//               helperText: 'اختر تاريخ حفل التتويج',
//             ),
//             validator: (value) => value?.isEmpty == true ? 'التاريخ مطلوب' : null,
//           ),
          
//           const SizedBox(height: 16),
          
//           // Two day availability info
//           if (_date1Controller.text.isNotEmpty) ...[
//             CheckboxListTile(
//               title: const Text(
//                 'حجز يومين (إقامة أمنسي الوزران في نفس العشيرة)',
//                 style: TextStyle(fontWeight: FontWeight.w500),
//               ),
//               value: _date2Bool,
//               onChanged: (value) => setState(() => _date2Bool = value ?? false),
//               contentPadding: EdgeInsets.zero,
//             ),
//             const SizedBox(height: 8),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: isDark ? Colors.green.withOpacity(0.2) : Colors.green[50],
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(
//                   color: isDark ? Colors.green.withOpacity(0.5) : Colors.green[200]!,
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.info,
//                     color: isDark ? Colors.green[300] : Colors.green[600],
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'يمكنك حجز يومين متتاليين لهذا التاريخ',
//                       style: TextStyle(color: Colors.green[700]),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
          
//           const SizedBox(height: 24),
          
//           // Haia Committee
//           _buildDropdown<Map<String, dynamic>>(
//             label: 'الهيئة *',
//             icon: Icons.group,
//             value: _selectedHaiaCommittee,
//             items: _haiaCommittees,
//             onChanged: (value) => setState(() => _selectedHaiaCommittee = value),
//             validator: (value) => value == null ? 'الهيئة مطلوبة' : null,
//             isLoading: _isLoadingDropdowns,
//           ),
          
//           const SizedBox(height: 16),
          
//           // Tilawa Type
//           DropdownButtonFormField<String>(
//             value: _selectedTilawaType,
//             decoration: InputDecoration(
//               labelText: 'نوع التلاوة *',
//               prefixIcon: const Icon(Icons.book_outlined),
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             ),
//             items: const [
//               DropdownMenuItem(
//                 value: 'تلاوة جماعية',
//                 child: Text('تلاوة جماعية', style: TextStyle(fontWeight: FontWeight.bold)),
//               ),
//               DropdownMenuItem(
//                 value: 'تلاوة فردية',
//                 child: Text('تلاوة فردية', style: TextStyle(fontWeight: FontWeight.bold)),
//               ),
//             ],
//             onChanged: (value) => setState(() {
//               _selectedTilawaType = value;
//               _showCustomTilawaInput = value == 'تلاوة فردية';
//               if (!_showCustomTilawaInput) _customTilawaNameController.clear();
//             }),
//             validator: (value) => value == null ? 'نوع التلاوة مطلوب' : null,
//           ),
          
//           if (_showCustomTilawaInput) ...[
//             const SizedBox(height: 16),
//             _buildTextField(
//               controller: _customTilawaNameController,
//               label: 'اسم القارئ (اختياري)',
//               icon: Icons.person_outline,
//               validator: null,
//             ),
//           ],
          
//           const SizedBox(height: 16),
          
//           // Madaeh Committee
//           _buildDropdown<Map<String, dynamic>>(
//             label: 'اللجنة *',
//             icon: Icons.group_outlined,
//             value: _selectedMadaehCommittee,
//             items: _madaehCommittees,
//             onChanged: (value) => setState(() {
//               _selectedMadaehCommittee = value;
//               _showCustomMadaehInput = value?['name']?.toString() == 'لجنة خاصة';
//               if (!_showCustomMadaehInput) _customMadaehCommitteeController.clear();
//             }),
//             validator: (value) => value == null ? 'لجنة المدائح والإنشاد مطلوبة' : null,
//             isLoading: _isLoadingDropdowns,
//           ),
          
//           if (_showCustomMadaehInput) ...[
//             const SizedBox(height: 16),
//             _buildTextField(
//               controller: _customMadaehCommitteeController,
//               label: 'اسم اللجنة الخاصة (اختياري)',
//               icon: Icons.edit,
//               validator: null,
//             ),
//           ],
          
//           const SizedBox(height: 24),
          
//           // Options
//           Card(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'خيارات الحجز',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Theme.of(context).primaryColor,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   SwitchListTile(
//                     title: const Text('السماح للآخرين بالانضمام'),
//                     value: _allowOthers,
//                     onChanged: (value) => setState(() => _allowOthers = value),
//                     contentPadding: EdgeInsets.zero,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
    
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('تسجيل عريس جديد'),
//         backgroundColor: Theme.of(context).primaryColor,
//       ),
//       body: Form(
//         key: _formKey,
//         child: ListView(
//           padding: const EdgeInsets.all(16.0),
//           children: [
//             // Groom Information Card
//             Card(
//               elevation: 2,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'معلومات العريس',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Theme.of(context).primaryColor,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     _buildTextField(
//                       controller: _phoneController,
//                       label: 'رقم هاتف العريس *',
//                       icon: Icons.phone,
//                       keyboardType: TextInputType.phone,
//                     ),
//                     const SizedBox(height: 16),
//                     _buildTextField(
//                       controller: _firstNameController,
//                       label: 'اسم العريس *',
//                       icon: Icons.person,
//                     ),
//                     const SizedBox(height: 16),
//                     _buildTextField(
//                       controller: _lastNameController,
//                       label: 'اسم العائلة *',
//                       icon: Icons.family_restroom,
//                     ),
//                     const SizedBox(height: 16),
//                     _buildTextField(
//                       controller: _fatherNameController,
//                       label: 'اسم الأب *',
//                       icon: Icons.person_outline,
//                     ),
//                     const SizedBox(height: 16),
//                     _buildTextField(
//                       controller: _grandfatherNameController,
//                       label: 'اسم الجد *',
//                       icon: Icons.elderly,
//                     ),
//                     const SizedBox(height: 16),
//                     _buildTextField(
//                       controller: _guardianNameController,
//                       label: 'اسم الولي *',
//                       icon: Icons.supervised_user_circle,
//                     ),
//                     const SizedBox(height: 16),
//                     _buildTextField(
//                       controller: _guardianPhoneController,
//                       label: 'رقم هاتف الولي *',
//                       icon: Icons.phone_android,
//                       keyboardType: TextInputType.phone,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
            
//             const SizedBox(height: 24),
            
//             // Create Reservation Toggle
//             Card(
//               elevation: 2,
//               color: isDark ? Colors.grey[850] : Colors.blue[50],
//               child: SwitchListTile(
//                 title: const Text(
//                   'إنشاء حجز مع التسجيل',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 subtitle: const Text('تفعيل لإنشاء حجز تلقائياً للعريس'),
//                 value: _createReservation,
//                 onChanged: (value) => setState(() => _createReservation = value),
//                 activeColor: Theme.of(context).primaryColor,
//               ),
//             ),
            
//             // Reservation Details (conditionally shown)
//             if (_createReservation) ...[
//               const SizedBox(height: 16),
//               Card(
//                 elevation: 2,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Clan and Hall Selection
//                       _buildClanAndHallSelectionStep(),
                      
//                       const SizedBox(height: 24),
//                       const Divider(),
//                       const SizedBox(height: 24),
                      
//                       // Reservation Details
//                       _buildReservationDetailsStep(),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
            
//             const SizedBox(height: 24),
            
//             // Submit Button
//             ElevatedButton(
//               onPressed: _isSubmitting ? null : _register,
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.all(16),
//                 backgroundColor: Theme.of(context).primaryColor,
//               ),
//               child: _isSubmitting
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : Text(
//                       _createReservation ? 'تسجيل وإنشاء حجز' : 'تسجيل',
//                       style: const TextStyle(fontSize: 16, color: Colors.white),
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _phoneController.dispose();
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _fatherNameController.dispose();
//     _grandfatherNameController.dispose();
//     _guardianPhoneController.dispose();
//     _guardianNameController.dispose();
//     _date1Controller.dispose();
//     _customMadaehCommitteeController.dispose();
//     _customTilawaNameController.dispose();
//     super.dispose();
//   }
// }