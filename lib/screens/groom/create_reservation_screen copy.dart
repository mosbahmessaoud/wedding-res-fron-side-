// // lib/screens/reservation/create_reservation_screen.dart
// import 'package:flutter/material.dart';
// import '../../services/api_service.dart';
// import '../../utils/colors.dart';
// import 'package:intl/intl.dart' hide TextDirection; // For date formatting
// import '../../services/api_service.dart';
// import '../../utils/colors.dart';
// import 'custom_calendar_picker.dart'; // Import your custom calendar widget

// class CreateReservationScreen extends StatefulWidget {
//   const CreateReservationScreen({super.key});

//   @override
//   State<CreateReservationScreen> createState() => _CreateReservationScreenState();
// }

// class _CreateReservationScreenState extends State<CreateReservationScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _pageController = PageController();
//   int _currentStep = 0;
  
//   // Form controllers for dates
//   final _date1Controller = TextEditingController();
  
//   // Selection data
//   List<dynamic> _clans = [];
//   List<dynamic> _halls = [];
//   List<dynamic> _haiaCommittees = [];
//   List<dynamic> _madaehCommittees = [];
  
//   // Selected values
//   Map<String, dynamic>? _selectedClan;
//   Map<String, dynamic>? _selectedCounty;
//   Map<String, dynamic>? _selectedHall;
//   Map<String, dynamic>? _selectedHaiaCommittee;
//   Map<String, dynamic>? _selectedMadaehCommittee;
  
//   // User information (will be loaded from profile)
//   Map<String, dynamic>? _userProfile;
  
//   // Reservation settings
//   bool _allowOthers = false;
//   bool _joinToMassWedding = true;
//   bool _date2Bool = false;
//   bool _canSelectTwoDays = false; // Based on clan settings
  
//   bool _isLoading = true;
//   bool _isSubmitting = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadInitialData();
//   }

//   @override
//   void dispose() {
//     _date1Controller.dispose();
//     _pageController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadInitialData() async {
//     setState(() => _isLoading = true);
    
//     try {
//       // Load user profile first
//       print('Loading user profile...');
//       final profile = await ApiService.getProfile();
//       print('Profile loaded: ${profile.runtimeType}');
//       _userProfile = profile;
      
//       // Load clans based on user's county
//       print('Loading clans for county: ${profile['county_id']}');
//       final clans = await ApiService.getClansByCounty(profile['county_id']);
//       print('Clans loaded: ${clans.runtimeType} - ${clans}');
      
//       print('Loading county info...');
//       final county_n = await ApiService.getCounty(profile['county_id']);
//       print('County loaded: ${county_n.runtimeType}');
//       _selectedCounty = county_n as Map<String, dynamic>?;
      
//       // Load committees with detailed logging
//       print('Loading Haia committees...');
//       final haiaCommittees = await ApiService.getGroomHaia();
//       print('Haia committees loaded: ${haiaCommittees.runtimeType} - Length: ${haiaCommittees.length}');
      
//       print('Loading Madaeh committees...');
//       final madaehCommittees = await ApiService.getGroomMadaihCommittee();
//       print('Madaeh committees loaded: ${madaehCommittees.runtimeType} - Length: ${madaehCommittees.length}');
      
//       setState(() {
//         // Make sure clans is a List
//         if (clans is List) {
//           _clans = clans;
//         } else {
//           print('WARNING: clans is not a List, it is: ${clans.runtimeType}');
//           _clans = [];
//         }
        
//         _haiaCommittees = haiaCommittees;
//         _madaehCommittees = madaehCommittees;
//       });
      
//       print('All data loaded successfully');
      
//     } catch (e, stackTrace) {
//       print('Error in _loadInitialData: $e');
//       print('Stack trace: $stackTrace');
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

//   Future<void> _loadHallsForClan(int clanId) async {
//     try {
//       final halls = await ApiService.getHallsByClan(clanId);
//       setState(() {
//         _halls = halls;
//         _selectedHall = null; // Reset hall selection when clan changes
//       });
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('خطأ في تحميل القاعات: ${e.toString()}')),
//         );
//       }
//     }
//   }

//   void _onClanSelected(Map<String, dynamic>? clan) {
//     setState(() {
//       _selectedClan = clan;
//       _selectedHall = null;
//       _halls.clear();
      
//       if (clan != null) {
//         // Check if clan allows two days (will be updated when date is selected)
//         _updateTwoDayAvailability();
        
//         // Load halls for this clan
//         _loadHallsForClan(clan['id']);
//       } else {
//         _canSelectTwoDays = false;
//         _date2Bool = false;
//       }
//     });
//   }

//   // New method to check if two days are allowed based on selected date
//   void _updateTwoDayAvailability() {
//     if (_selectedClan == null || _date1Controller.text.isEmpty) {
//       _canSelectTwoDays = false;
//       _date2Bool = false;
//       return;
//     }

//     try {
//       final selectedDate = DateTime.parse(_date1Controller.text);
//       final selectedMonth = selectedDate.month;
      
//       // Get clan settings
//       final settings = _selectedClan!['settings'] as Map<String, dynamic>?;
//       if (settings == null) {
//         _canSelectTwoDays = false;
//         _date2Bool = false;
//         return;
//       }

//       // Check if clan allows two day reservations at all
//       final allowTwoDay = settings['allow_two_day_reservations'] == true;
//       if (!allowTwoDay) {
//         _canSelectTwoDays = false;
//         _date2Bool = false;
//         return;
//       }

//       // Check allowed months for two days
//       final twoDateMonths = settings['allowed_months_two_day']?.toString() ?? '';
//       final allowedMonths = twoDateMonths.split(',').map((m) => int.tryParse(m.trim())).where((m) => m != null).toSet();
      
//       _canSelectTwoDays = allowedMonths.contains(selectedMonth);
//       if (!_canSelectTwoDays) {
//         _date2Bool = false;
//       }
//     } catch (e) {
//       _canSelectTwoDays = false;
//       _date2Bool = false;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text('إنشاء حجز جديد'),
//           backgroundColor: AppColors.primary,
//           foregroundColor: Colors.white,
//         ),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

// return Scaffold(
//   body: Column(
//     children: [
//       Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           children: [
//             for (int i = 0; i < 3; i++) ...[
//               Expanded(
//                 child: Container(
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: i <= _currentStep 
//                       ? const Color.fromARGB(255, 0, 151, 98)
//                       : const Color.fromARGB(255, 110, 174, 122).withOpacity(0.3),
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//               ),
//               if (i < 2) const SizedBox(width: 8),
//             ],
//           ],
//         ),
//       ),
//       Expanded(
//         child: Form(
//           key: _formKey,
//           child: PageView(
//             controller: _pageController,
//             onPageChanged: (index) => setState(() => _currentStep = index),
//             children: [
//               _buildClanAndHallSelectionStep(),
//               _buildReservationDetailsStep(),
//               _buildConfirmationStep(),
//             ],
//           ),
//         ),
//       ),
//     ],
//   ),
//   bottomNavigationBar: _buildBottomNavigation(),
// );
//   }

//   Widget _buildClanAndHallSelectionStep() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'اختيار العشيرة والقاعة',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: AppColors.primary,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'اختر العشيرة والقاعة المناسبة لحفلك\nالمحافظة: ${_userProfile?['county_name'] ?? 'غير محدد'}',
//             style: const TextStyle(
//               fontSize: 16,
//               color: AppColors.textSecondary,
//             ),
//           ),
//           const SizedBox(height: 24),
          
//           // Clan Selection
//           DropdownButtonFormField<Map<String, dynamic>>(
//             value: _selectedClan,
//             decoration: InputDecoration(
//               labelText: 'العشيرة *',
//               prefixIcon: const Icon(Icons.group),
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               helperText: 'العشائر المتاحة في محافظتك',
//             ),
//             items: _clans.map((clan) {
//               return DropdownMenuItem<Map<String, dynamic>>(
//                 value: clan,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       clan['name']?.toString() ?? 'عشيرة غير مسماة',
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     if (clan['allow_two_days'] == true)
//                       Text(
//                         'تسمح بيومين',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.green[600],
//                         ),
//                       ),
//                   ],
//                 ),
//               );
//             }).toList(),
//             onChanged: _onClanSelected,
//             validator: (value) => value == null ? 'العشيرة مطلوبة' : null,
//           ),
          
//           const SizedBox(height: 24),
          
//           // Hall Selection
//           if (_selectedClan != null) ...[
//             DropdownButtonFormField<Map<String, dynamic>>(
//               value: _selectedHall,
//               decoration: InputDecoration(
//                 labelText: 'القاعة *',
//                 prefixIcon: const Icon(Icons.business),
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                 helperText: _halls.isEmpty ? 'لا توجد قاعات متاحة لهذه العشيرة' : 'القاعات المتاحة للعشيرة المختارة',
//               ),
//               items: _halls.map((hall) {
//                 return DropdownMenuItem<Map<String, dynamic>>(
//                   value: hall,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         hall['name']?.toString() ?? 'قاعة غير مسماة',
//                         style: const TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       Text(
//                         'السعة: ${hall['capacity']} شخص',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: AppColors.textSecondary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }).toList(),
//               onChanged: (value) => setState(() => _selectedHall = value),
//               validator: (value) => value == null ? 'القاعة مطلوبة' : null,
//             ),
//           ] else ...[
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.grey[300]!),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.info, color: Colors.grey[600]),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'اختر العشيرة أولاً لعرض القاعات المتاحة',
//                       style: TextStyle(color: Colors.grey[600]),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
          
//           const SizedBox(height: 24),
          
//           // Clan Information Display
//           if (_selectedClan != null) ...[
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'معلومات العشيرة المختارة',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.primary,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     _buildInfoRow('الاسم', _selectedClan!['name']?.toString() ?? ''),
//                     _buildInfoRow('المحافظة', _selectedCounty!['name']?.toString() ?? ''),
//                     _buildInfoRow('السماح بيومين', _selectedClan!['allow_two_days'] == true ? 'نعم' : 'لا'),
//                     if (_selectedClan!['description'] != null)
//                       _buildInfoRow('الوصف', _selectedClan!['description'].toString()),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildReservationDetailsStep() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'تفاصيل الحجز',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: AppColors.primary,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'اختر تفاصيل الحجز والتاريخ واللجان',
//             style: TextStyle(
//               fontSize: 16,
//               color: AppColors.textSecondary,
//             ),
//           ),
//           const SizedBox(height: 24),
          
//           // Primary Date
//           TextFormField(
//             controller: _date1Controller,
//             readOnly: true,
//             onTap: () => _selectDate(_date1Controller, 'تاريخ الحجز'),
//             decoration: InputDecoration(
//               labelText: 'تاريخ الحجز *',
//               prefixIcon: const Icon(Icons.calendar_today),
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               suffixIcon: const Icon(Icons.arrow_drop_down),
//               helperText: 'اختر تاريخ الحفل',
//             ),
//             validator: (value) => value?.isEmpty == true ? 'التاريخ مطلوب' : null,
//           ),
          
//           const SizedBox(height: 16),
          
//           // Two day option (only if clan allows and based on month settings)
//           if (_canSelectTwoDays) ...[
//             Row(
//               children: [
//                 Checkbox(
//                   value: _date2Bool,
//                   onChanged: (value) {
//                     setState(() {
//                       _date2Bool = value ?? false;
//                     });
//                   },
//                 ),
//                 Expanded(
//                   child: Text(
//                     'هل تريد حجز يومين متتاليين؟',
//                     style: TextStyle(
//                       color: Colors.green[700],
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
            
//             const SizedBox(height: 8),
            
// // Info message for two days option
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.green[50],
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.green[200]!),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.info, color: Colors.green[600]),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'العشيرة تسمح بحجز يومين متتاليين لهذا الشهر. الخادم سيحدد التاريخ الثاني تلقائياً',
//                       style: TextStyle(color: Colors.green[700]),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ] else ...[
//             // Info message for single day only
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.orange[50],
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.orange[200]!),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.info, color: Colors.orange[600]),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'العشيرة تسمح بيوم واحد فقط لهذا الشهر',
//                       style: TextStyle(color: Colors.orange[700]),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
          
//           const SizedBox(height: 24),
          
//           // Haia Committee Selection
//           DropdownButtonFormField<Map<String, dynamic>>(
//             value: _selectedHaiaCommittee,
//             decoration: InputDecoration(
//               labelText: 'لجنة الهيئة *',
//               prefixIcon: const Icon(Icons.group),
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               helperText: 'اختر لجنة الهيئة المناسبة',
//             ),
//             items: _haiaCommittees.map((committee) {
//               return DropdownMenuItem<Map<String, dynamic>>(
//                 value: committee,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       committee['name']?.toString() ?? 'لجنة غير مسماة',
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     if (committee['description'] != null)
//                       Text(
//                         committee['description'].toString(),
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: AppColors.textSecondary,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                   ],
//                 ),
//               );
//             }).toList(),
//             onChanged: (value) => setState(() => _selectedHaiaCommittee = value),
//             validator: (value) => value == null ? 'لجنة الهيئة مطلوبة' : null,
//           ),
//           const SizedBox(height: 16),
          
//           // Madaeh Committee Selection
//           DropdownButtonFormField<Map<String, dynamic>>(
//             value: _selectedMadaehCommittee,
//             decoration: InputDecoration(
//               labelText: 'لجنة المدائح *',
//               prefixIcon: const Icon(Icons.music_note),
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               helperText: 'اختر لجنة المدائح المناسبة',
//             ),
//             items: _madaehCommittees.map((committee) {
//               return DropdownMenuItem<Map<String, dynamic>>(
//                 value: committee,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       committee['name']?.toString() ?? 'لجنة غير مسماة',
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     if (committee['description'] != null)
//                       Text(
//                         committee['description'].toString(),
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: AppColors.textSecondary,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                   ],
//                 ),
//               );
//             }).toList(),
//             onChanged: (value) => setState(() => _selectedMadaehCommittee = value),
//             validator: (value) => value == null ? 'لجنة المدائح مطلوبة' : null,
//           ),
          
//           const SizedBox(height: 24),
          
//           // Options
//           Card(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'خيارات الحجز',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.primary,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
                  
//                   SwitchListTile(
//                     title: const Text('السماح للآخرين بالانضمام'),
//                     subtitle: const Text('هل تسمح لآخرين بالانضمام لحفلك؟'),
//                     value: _allowOthers,
//                     onChanged: (value) => setState(() => _allowOthers = value),
//                     contentPadding: EdgeInsets.zero,
//                   ),
                  
//                   SwitchListTile(
//                     title: const Text('الانضمام لزفاف جماعي'),
//                     subtitle: const Text('هل تريد الانضمام لحفل زفاف جماعي؟'),
//                     value: _joinToMassWedding,
//                     onChanged: (value) => setState(() => _joinToMassWedding = value),
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

//   Widget _buildConfirmationStep() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'مراجعة وتأكيد الحجز',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: AppColors.primary,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'راجع تفاصيل حجزك قبل التأكيد',
//             style: TextStyle(
//               fontSize: 16,
//               color: AppColors.textSecondary,
//             ),
//           ),
//           const SizedBox(height: 24),
          
//           // User Information Summary
//           _buildSummaryCard('معلومات المستخدم', [
//             _buildSummaryItem('الاسم', '${_userProfile?['first_name'] ?? ''} ${_userProfile?['last_name'] ?? ''}'),
//             _buildSummaryItem('رقم الهاتف', _userProfile?['phone_number']?.toString() ?? ''),
//             _buildSummaryItem('المحافظة', _userProfile?['county_name']?.toString() ?? ''),
//           ]),
          
//           const SizedBox(height: 16),
          
//           // Selection Summary
//           _buildSummaryCard('تفاصيل الحجز', [
//             _buildSummaryItem('التاريخ المحدد', _date1Controller.text),
//             if (_selectedClan != null)
//               _buildSummaryItem('العشيرة', _selectedClan!['name']?.toString() ?? ''),
//             if (_selectedHall != null)
//               _buildSummaryItem('القاعة', _selectedHall!['name']?.toString() ?? ''),
//             if (_selectedHaiaCommittee != null)
//               _buildSummaryItem('لجنة الهيئة', _selectedHaiaCommittee!['name']?.toString() ?? ''),
//             if (_selectedMadaehCommittee != null)
//               _buildSummaryItem('لجنة المدائح', _selectedMadaehCommittee!['name']?.toString() ?? ''),
//           ]),

//           const SizedBox(height: 16),

//           // Options Summary
//           _buildSummaryCard('خيارات الحجز', [
//             _buildSummaryItem('السماح للآخرين', _allowOthers ? 'نعم' : 'لا'),
//             _buildSummaryItem('زفاف جماعي', _joinToMassWedding ? 'نعم' : 'لا'),
//             _buildSummaryItem('حجز يومين متتاليين', _date2Bool ? 'نعم' : 'لا'),
//             if (_date2Bool)
//               _buildSummaryItem('ملاحظة', 'سيتم تحديد التاريخ الثاني تلقائياً من قبل النظام'),
//           ]),
          
//           const SizedBox(height: 16),
          
//           // Important Note
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: const Color.fromARGB(255, 253, 227, 227),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: const Color.fromARGB(255, 249, 144, 144)!),
//             ),
// child: Directionality(
//   textDirection: TextDirection.rtl, // النصوص من اليمين لليسار
//   child: Column(
//     crossAxisAlignment: CrossAxisAlignment.stretch, // النصوص تلتزم بالـ RTL
//     children: [
//       // الجزء اللي في الوسط
//       Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             Icons.info,
//             color: const Color.fromARGB(255, 249, 144, 144),
//             size: 32,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'ملاحظة مهمة',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: const Color.fromARGB(255, 0, 0, 0),
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//       const SizedBox(height: 8),

//       // النص الرئيسي RTL
// Text(
//   'للحصول على الموافقة النهائية، يجب طباعة الحجز وختمه وتوقيعه من:\n'
//   '- الهيئة الدينية\n'
//   '- الدار المضيفة (في حالة الحجز في عشيرة أخرى)\n'
//   '- إدارة العشيرة\n\n'
//   'ثم إرجاعه إلى النظام خلال 10 أيام كحد أقصى، وإلا يُلغى الحجز تلقائيًا.\n\n'
//   'لتحميل الملف، اذهب إلى صفحة الحجوزات.',
//   style: TextStyle(
//     fontSize: 14,
//     color: const Color.fromARGB(255, 0, 0, 0),
//     height: 1.5,
//   ),
//   textAlign: TextAlign.start,
// ),

//     ],
//   ),
// ),

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
//           Text(
//             '$label: ',
//             style: const TextStyle(
//               fontWeight: FontWeight.w500,
//               color: AppColors.textSecondary,
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(color: AppColors.textPrimary),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSummaryCard(String title, List<Widget> children) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.primary,
//               ),
//             ),
//             const SizedBox(height: 12),
//             ...children,
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSummaryItem(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '$label: ',
//             style: const TextStyle(
//               fontWeight: FontWeight.w500,
//               color: AppColors.textSecondary,
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(color: AppColors.textPrimary),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBottomNavigation() {
//     return Container(
//       padding: const EdgeInsets.all(5),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 4,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           if (_currentStep > 0) ...[
//             Expanded(
//               child: OutlinedButton(
//                 onPressed: _goToPreviousStep,
//                 child: const Text('السابق'),
//               ),
//             ),
//             const SizedBox(width: 10),
//           ],
//           Expanded(
//             flex: 2,
//             child: ElevatedButton(
//               onPressed: _isSubmitting ? null : _handleNextStep,
//               child: _isSubmitting
//                   ? const SizedBox(
//                       height: 10,
//                       width: 10,
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     )
//                   : Text(_currentStep == 2 ? 'تأكيد الحجز' : 'التالي'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _goToPreviousStep() {
//     if (_currentStep > 0) {
//       _pageController.previousPage(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
//   }

//   void _handleNextStep() {
//     if (_currentStep == 2) {
//       _submitReservation();
//     } else {
//       if (_validateCurrentStep()) {
//         _pageController.nextPage(
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//         );
//       }
//     }
//   }

//   bool _validateCurrentStep() {
//     switch (_currentStep) {
//       case 0:
//         // Validate clan and hall selection
//         if (_selectedClan == null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('يرجى اختيار العشيرة')),
//           );
//           return false;
//         }
//         if (_selectedHall == null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('يرجى اختيار القاعة')),
//           );
//           return false;
//         }
//         return true;
//       case 1:
//         // Validate reservation details
//         if (_date1Controller.text.isEmpty) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('يرجى اختيار التاريخ')),
//           );
//           return false;
//         }
//         if (_selectedHaiaCommittee == null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('يرجى اختيار لجنة الهيئة')),
//           );
//           return false;
//         }
//         if (_selectedMadaehCommittee == null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('يرجى اختيار لجنة المدائح')),
//           );
//           return false;
//         }
//         return true;
//       default:
//         return _formKey.currentState?.validate() == true;
//     }
//   }

//   Future<void> _submitReservation() async {
//   setState(() => _isSubmitting = true);
  
//   try {
//     // Prepare the reservation data matching backend expectations
//     final reservationData = {
//       // Required fields matching ReservationCreate schema
//       'date1': _date1Controller.text, // Backend expects string in YYYY-MM-DD format
//       'date2_bool': _date2Bool, // Backend will calculate date2 automatically
//       'allow_others': _allowOthers,
//       'join_to_mass_wedding': _joinToMassWedding,
//       'clan_id': _selectedClan!['id'],
      
//       // Required fields based on backend validation
//       'hall_id': _selectedHall!['id'],
//       'haia_committee_id': _selectedHaiaCommittee!['id'],
//       'madaeh_committee_id': _selectedMadaehCommittee!['id'],
//     };

//     print('Submitting reservation data: $reservationData');

//     final response = await ApiService.createReservation(reservationData);
    
//     print('Reservation created successfully: $response');
    
//     if (mounted) {
//       Navigator.of(context).pop();
      
//       // Show success message with PDF info if available
//       String successMessage = 
//         'تم إنشاء حجز جديد بنجاح! يجب طباعة الحجز وختمه وتوقيعه خلال 10 أيام كأقصى حد، '
//         'وإلا سيتم إلغاء الحجز تلقائيًا.';
//       if (response['pdf_url'] != null) {
//         successMessage += '\nيمكنك تحميل نسخة PDF من الحجز';
//       }
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(successMessage),
//           backgroundColor: Colors.green,
//           duration: const Duration(seconds: 10),
//           action: response['pdf_url'] != null ? SnackBarAction(
//             label: 'تحميل PDF',
//             textColor: Colors.white,
//             onPressed: () {
//               // Handle PDF download - you might want to implement this
//               print('Download PDF from: ${response['pdf_url']}');
//             },
//           ) : null,
//         ),
//       );
//     }
    
//   } on FormatException catch (e) {
//     print('Format error: $e');
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('خطأ في تحليل استجابة الخادم. يرجى المحاولة مرة أخرى.'),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 5),
//         ),
//       );
//     }
//   } catch (e) {
//     print('Error creating reservation: $e');
    
//     if (mounted) {
//       // Handle different types of errors
//       String errorMessage = 'خطأ في إرسال طلب الحجز';
      
//       // Parse common backend error messages
//       String errorStr = e.toString().toLowerCase();
//       if (errorStr.contains('already have an active reservation')) {
//         errorMessage = 'لديك حجز نشط بالفعل';
//       } else if (errorStr.contains('not allowed in this month')) {
//         errorMessage = 'حجز يومين غير مسموح في هذا الشهر';
//       } else if (errorStr.contains('already reserved')) {
//         errorMessage = 'التاريخ محجوز بالفعل';
//       } else if (errorStr.contains('fully booked')) {
//         errorMessage = 'التاريخ ممتلئ بالكامل';
//       } else if (errorStr.contains('server error')) {
//         errorMessage = 'خطأ في الخادم. يرجى المحاولة لاحقاً';
//       } else if (errorStr.contains('network') || errorStr.contains('connection')) {
//         errorMessage = 'خطأ في الاتصال. تحقق من الإنترنت';
//       } else {
//         // Show the actual error for debugging, but limit length
//         String actualError = e.toString();
//         if (actualError.length > 100) {
//           actualError = actualError.substring(0, 100) + '...';
//         }
//         errorMessage = 'خطأ: $actualError';
//       }
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(errorMessage),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 5),
//         ),
//       );
//     }
//   } finally {
//     if (mounted) {
//       setState(() => _isSubmitting = false);
//     }
//   }
// }
//   // Future<void> _selectDate(TextEditingController controller, String title) async {
//   //   final DateTime? picked = await showDatePicker(
//   //     context: context,
//   //     initialDate: DateTime.now().add(const Duration(days: 30)),
//   //     firstDate: DateTime.now().add(const Duration(days: 1)),
//   //     lastDate: DateTime.now().add(const Duration(days: 365)),
//   //     helpText: title,
//   //     cancelText: 'إلغاء',
//   //     confirmText: 'تأكيد',
//   //   );
    
//   //   if (picked != null) {
//   //     setState(() {
//   //       controller.text = picked.toLocal().toString().split(' ')[0];
        
//   //       // Update two day availability based on selected date
//   //       if (controller == _date1Controller) {
//   //         _updateTwoDayAvailability();
//   //       }
//   //     });
//   //   }
//   // }
//   // Replace your existing _selectDate method in create_reservation_screen.dart with this:

// Future<void> _selectDate(TextEditingController controller, String title) async {
//   if (_selectedClan == null || _selectedHall == null) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('يرجى اختيار العشيرة والقاعة أولاً')),
//     );
//     return;
//   }

//   // Show loading indicator
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (context) => const Center(child: CircularProgressIndicator()),
//   );

//   try {
//     final now = DateTime.now();
//     final currentMonth = controller == _date1Controller && controller.text.isNotEmpty
//         ? DateTime.parse(controller.text)
//         : now;

//     // Fetch date availabilities from the server
//     final availabilities = await ApiService.getDateAvailabilities(
//       clanId: _selectedClan!['id'],
//       hallId: _selectedHall!['id'],
//       year: currentMonth.year,
//       month: currentMonth.month,
//     );

//     // Close loading indicator
//     Navigator.of(context).pop();

//     // Convert API response to DateAvailability objects
//     final List<DateAvailability> dateAvailabilityList = availabilities.map((item) {
//       DateTime date = DateTime.parse(item['date']);
//       DateStatus status;
      
//       switch (item['status']?.toString().toLowerCase()) {
//         case 'available':
//         case 'free':
//           status = DateStatus.available;
//           break;
//         case 'pending':
//           status = DateStatus.pending;
//           break;
//         case 'reserved':
//         case 'booked':
//           status = DateStatus.reserved;
//           break;
//         default:
//           status = DateStatus.disabled;
//       }

//       return DateAvailability(
//         date: date,
//         status: status,
//         note: item['note']?.toString(),
//       );
//     }).toList();

//     // Add disabled status for dates that are too close (less than 30 days from now)
//     for (int i = 1; i <= 365; i++) {
//       final date = now.add(Duration(days: i));
      
//       // Skip if we already have data for this date
//       if (dateAvailabilityList.any((d) => _isSameDay(d.date, date))) continue;
      
//       // Mark dates less than 30 days away as disabled
//       if (i < 30) {
//         dateAvailabilityList.add(DateAvailability(
//           date: date,
//           status: DateStatus.disabled,
//           note: 'يجب الحجز قبل 30 يوم على الأقل',
//         ));
//       } else {
//         // Mark other dates as available by default
//         dateAvailabilityList.add(DateAvailability(
//           date: date,
//           status: DateStatus.available,
//         ));
//       }
//     }

//     // Show custom calendar picker
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => CustomCalendarPicker(
//         title: title,
//         initialDate: controller.text.isNotEmpty 
//             ? DateTime.parse(controller.text) 
//             : now.add(const Duration(days: 30)),
//         firstDate: now.add(const Duration(days: 30)),
//         lastDate: now.add(const Duration(days: 365)),
//         dateAvailabilities: dateAvailabilityList,
//         allowTwoConsecutiveDays: _canSelectTwoDays,
//         onDateSelected: (selectedDate) {
//           Navigator.of(context).pop();
//           setState(() {
//             controller.text = selectedDate.toLocal().toString().split(' ')[0];
            
//             // Update two day availability based on selected date
//             if (controller == _date1Controller) {
//               _updateTwoDayAvailability();
//             }
//           });
//         },
//         onCancel: () {
//           Navigator.of(context).pop();
//         },
//       ),
//     );

//   } catch (e) {
//     // Close loading indicator if still open
//     if (Navigator.canPop(context)) {
//       Navigator.of(context).pop();
//     }
    
//     print('Error loading date availabilities: $e');
    
//     // Fall back to default date picker if API fails
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('تعذر تحميل توفر التواريخ. سيتم استخدام التقويم الافتراضي.'),
//         backgroundColor: Colors.orange,
//       ),
//     );

//     // Show default date picker as fallback
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now().add(const Duration(days: 30)),
//       firstDate: DateTime.now().add(const Duration(days: 1)),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//       helpText: title,
//       cancelText: 'إلغاء',
//       confirmText: 'تأكيد',
//     );
    
//     if (picked != null) {
//       setState(() {
//         controller.text = picked.toLocal().toString().split(' ')[0];
        
//         // Update two day availability based on selected date
//         if (controller == _date1Controller) {
//           _updateTwoDayAvailability();
//         }
//       });
//     }
//   }
// }

// // Helper method to check if two dates are the same day
// bool _isSameDay(DateTime date1, DateTime date2) {
//   return date1.year == date2.year &&
//       date1.month == date2.month &&
//       date1.day == date2.day;
// }
// }