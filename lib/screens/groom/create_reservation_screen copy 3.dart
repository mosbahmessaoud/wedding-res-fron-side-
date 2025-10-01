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
//   int _maxCapacityPerDate = 3; // Add this line after other field declarations

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
// // 2. Add missing API service method for clan settings
// Future<void> _loadClanSettings() async {
//   if (_selectedClan == null) return;
  
//   try {
//     // This method needs to be added to ApiService
//     final settings = await ApiService.getSettings();
//     setState(() {
//       // Update the max capacity from clan settings
//       _maxCapacityPerDate = settings['max_grooms_per_date'] ?? 3;
//     });
//   } catch (e) {
//     print('Error loading clan settings: $e');
//     // Use default value
//     _maxCapacityPerDate = 3;
//   }
// }
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

//  // 4. Update the _onClanSelected method to load settings
// void _onClanSelected(Map<String, dynamic>? clan) {
//   setState(() {
//     _selectedClan = clan;
//     _selectedHall = null;
//     _halls.clear();
    
//     if (clan != null) {
//       // Check if clan allows two days (will be updated when date is selected)
//       _updateTwoDayAvailability();
      
//       // Load halls for this clan
//       _loadHallsForClan(clan['id']);
      
//       // Load clan settings for capacity
//       _loadClanSettings();
//     } else {
//       _canSelectTwoDays = false;
//       _date2Bool = false;
//       _maxCapacityPerDate = 3; // Reset to default
//     }
//   });
// }

//   // New method to check if two days are allowed based on selected date
//  // Updated method to check two-day availability based on selected date and clan settings
//   void _updateTwoDayAvailability() {
//     if (_selectedClan == null || _date1Controller.text.isEmpty) {
//       setState(() {
//         _canSelectTwoDays = false;
//         _date2Bool = false;
//       });
//       return;
//     } 

//     try {
//       final selectedDate = DateTime.parse(_date1Controller.text);
//       final selectedMonth = selectedDate.month;
      
//       print('Checking two-day availability for month: $selectedMonth');
      
//       // Get clan settings
//       final settings = _selectedClan!['settings'] as Map<String, dynamic>?;
//       if (settings == null) {
//         print('No clan settings found3');
//         setState(() {
//           _canSelectTwoDays = false;
//           _date2Bool = false;
//         });
//         return;
//       }

//       // Check if clan allows two day reservations at all
//       final allowTwoDay = settings['allow_two_day_reservations'] == true;
//       print('------ tow day : $allowTwoDay');
//       if (!allowTwoDay) {
//         print('Clan does not allow two-day reservations');
//         setState(() {
//           _canSelectTwoDays = false;
//           _date2Bool = false;
//         });
//         return;
//       }

//       // Check allowed months for two days
//       final twoDateMonths = settings['allowed_months_two_day']?.toString() ?? '';
//       print('Allowed months string: $twoDateMonths');
      
//       if (twoDateMonths.isEmpty) {
//         print('No allowed months specified');
//         setState(() {
//           _canSelectTwoDays = false;
//           _date2Bool = false;
//         });
//         return;
//       }

//       // Parse allowed months
//       final allowedMonths = twoDateMonths
//           .split(',')
//           .map((m) => int.tryParse(m.trim()))
//           .where((m) => m != null && m >= 1 && m <= 12)
//           .cast<int>()
//           .toSet();
      
//       print('Parsed allowed months: $allowedMonths');
      
//       final isAllowed = allowedMonths.contains(selectedMonth);
//       print('Is month $selectedMonth allowed for two days: $isAllowed');
      
//       setState(() {
//         _canSelectTwoDays = isAllowed;
//         if (!isAllowed) {
//           _date2Bool = false; // Reset if not allowed
//         }
//       });
      
//     } catch (e) {
//       print('Error checking two-day availability: $e');
//       setState(() {
//         _canSelectTwoDays = false;
//         _date2Bool = false;
//       });
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

// Widget _buildReservationDetailsStep() {
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
          
//           // Two day option - Updated logic
//           if (_date1Controller.text.isNotEmpty) ...[
//             // Check if two days are allowed for the selected date
//             if (_canSelectTwoDays) ...[
//               Row(
//                 children: [
//                   Checkbox(
//                     value: _date2Bool,
//                     onChanged: (value) {
//                       setState(() {
//                         _date2Bool = value ?? false;
//                       });
//                     },
//                   ),
//                   Expanded(
//                     child: Text(
//                       'هل تريد حجز يومين متتاليين؟',
//                       style: TextStyle(
//                         color: Colors.green[700],
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
              
//               const SizedBox(height: 8),
              
//               // Info message for two days option
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.green[50],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.green[200]!),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.info, color: Colors.green[600]),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         _getSelectedMonthName() != null 
//                           ? 'العشيرة تسمح بحجز يومين متتاليين لشهر ${_getSelectedMonthName()}. سيتم تحديد التاريخ الثاني تلقائياً'
//                           : 'العشيرة تسمح بحجز يومين متتاليين لهذا الشهر. سيتم تحديد التاريخ الثاني تلقائياً',
//                         style: TextStyle(color: Colors.green[700]),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ] else ...[
//               // Info message for single day only
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.orange[50],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.orange[200]!),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.info, color: Colors.orange[600]),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         _getSelectedMonthName() != null 
//                           ? 'العشيرة تسمح بيوم واحد فقط لشهر ${_getSelectedMonthName()}'
//                           : 'العشيرة تسمح بيوم واحد فقط لهذا الشهر',
//                         style: TextStyle(color: Colors.orange[700]),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ] else ...[
//             // Message when no date is selected
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.grey[300]!),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.calendar_month, color: Colors.grey[600]),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'اختر التاريخ أولاً لمعرفة إمكانية الحجز ليومين',
//                       style: TextStyle(color: Colors.grey[600]),
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
  
  
//     Widget _buildConfirmationStep() {
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
//             _buildSummaryItem('المحافظة',_selectedCounty!['name']?.toString() ?? ''),
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
// // Updated _selectDate method for create_reservation_screen.dart


// // Updated _selectDate method for create_reservation_screen.dart
// // Replace your existing _selectDate method with this:


// // Updated _selectDate method for create_reservation_screen.dart
// // Replace the existing _selectDate method with this updated version
// // Updated _selectDate method for create_reservation_screen.dart
// // Replace the existing _selectDate method with this updated version
// // Updated _selectDate method for create_reservation_screen.dart
// // Replace the existing _selectDate method with this updated version
// // Replace the entire _selectDate method and fallback method in create_reservation_screen.dart with this updated version

// // 5. Complete replacement for the _selectDate method
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
//     builder: (context) => const Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           CircularProgressIndicator(color: Colors.white),
//           SizedBox(height: 16),
//           Text(
//             'جاري تحميل توفر التواريخ...',
//             style: TextStyle(color: Colors.white),
//           ),
//         ],
//       ),
//     ),
//   );

//   try {
//     final now = DateTime.now();
    
//     // Close loading indicator
//     if (Navigator.canPop(context)) {
//       Navigator.of(context).pop();
//     }

//     // Show enhanced calendar picker with API integration
//     if (mounted) {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => CustomCalendarPicker(
//           title: title,
//           clanId: _selectedClan!['id'],
//           hallId: _selectedHall?['id'],
//           maxCapacityPerDate: _maxCapacityPerDate,
//           initialDate: controller.text.isNotEmpty 
//               ? DateTime.tryParse(controller.text) ?? now.add(const Duration(days: 30))
//               : now.add(const Duration(days: 30)),
//           firstDate: now,
//           lastDate: now.add(const Duration(days: 365)),
//           allowTwoConsecutiveDays: _canSelectTwoDays,
//           onDateSelected: (selectedDate, availability) {
//             Navigator.of(context).pop();
            
//             // Handle different date statuses
//             if (availability != null) {
//               switch (availability.status) {
//                 case DateStatus.available:
//                   _handleAvailableDate(selectedDate, controller);
//                   break;
//                 case DateStatus.massWeddingOpen:
//                   _handleMassWeddingDate(selectedDate, availability, controller);
//                   break;
//                 case DateStatus.mixed:
//                   _handleMixedStatusDate(selectedDate, availability, controller);
//                   break;
//                 case DateStatus.pending:
//                   if (availability.allowMassWedding) {
//                     _handlePendingMassWeddingDate(selectedDate, availability, controller);
//                   } else {
//                     _showDateNotAvailableMessage('هذا التاريخ في انتظار التأكيد ولا يسمح بالانضمام');
//                   }
//                   break;
//                 case DateStatus.reserved:
//                   _showDateNotAvailableMessage('هذا التاريخ محجوز بالكامل');
//                   break;
//                 case DateStatus.disabled:
//                   _showDateNotAvailableMessage('هذا التاريخ غير متاح للحجز');
//                   break;
//               }
//             } else {
//               _showDateNotAvailableMessage('خطأ في تحميل معلومات التاريخ');
//             }
//           },
//           onCancel: () {
//             Navigator.of(context).pop();
//           },
//         ),
//       );
//     }

//   } catch (e) {
//     // Close loading indicator if still open
//     if (Navigator.canPop(context)) {
//       Navigator.of(context).pop();
//     }
    
//     print('Error loading calendar: $e');
    
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('خطأ في تحميل التقويم: $e'),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 4),
//         ),
//       );

//       // Fall back to default date picker
//       _showFallbackDatePicker(controller, title);
//     }
//   }
// }

// // Add this new method to handle mixed status dates (both validated and pending reservations)
// void _handleMixedStatusDate(DateTime selectedDate, DateAvailability availability, TextEditingController controller) {
//   // Show detailed dialog for mixed status
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: const Text('تاريخ مختلط (مؤكد ومعلق)'),
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'هذا التاريخ يحتوي على حجوزات مؤكدة وحجوزات في انتظار التأكيد:',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),
            
//             // Validated reservations count
//             Row(
//               children: [
//                 Container(
//                   width: 12,
//                   height: 12,
//                   decoration: const BoxDecoration(
//                     color: Colors.green,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Text('حجوزات مؤكدة: ${availability.validatedCount}'),
//               ],
//             ),
//             const SizedBox(height: 8),
            
//             // Pending reservations count
//             Row(
//               children: [
//                 Container(
//                   width: 12,
//                   height: 12,
//                   decoration: const BoxDecoration(
//                     color: Colors.orange,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Text('حجوزات معلقة: ${availability.pendingCount}'),
//               ],
//             ),
//             const SizedBox(height: 8),
            
//             // Total count
//             Row(
//               children: [
//                 Container(
//                   width: 12,
//                   height: 12,
//                   decoration: const BoxDecoration(
//                     color: Colors.purple,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   'المجموع: ${availability.currentCount}/${availability.maxCapacity}',
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
            
//             if (availability.allowMassWedding) ...[
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.blue.shade200),
//                 ),
//                 child: const Row(
//                   children: [
//                     Icon(Icons.people_alt, color: Colors.blue, size: 20),
//                     SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         'يمكنك الانضمام لهذا التاريخ',
//                         style: TextStyle(
//                           color: Colors.blue,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 8),
//             ],
            
//             // Warning about pending reservations
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.orange.shade50,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.orange.shade200),
//               ),
//               child: const Row(
//                 children: [
//                   Icon(Icons.warning_amber, color: Colors.orange, size: 20),
//                   SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'تنبيه: الحجوزات المعلقة قد تُلغى خلال 10 أيام',
//                       style: TextStyle(
//                         color: Colors.orange,
//                         fontSize: 12,
//                         fontStyle: FontStyle.italic,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 12),
            
//             Text(
//               availability.allowMassWedding 
//                   ? 'هل تريد تقديم طلب للانضمام لهذا التاريخ؟'
//                   : 'هذا التاريخ لا يسمح بحجوزات إضافية.',
//               style: const TextStyle(fontWeight: FontWeight.w500),
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: const Text('إلغاء'),
//         ),
//         if (availability.allowMassWedding)
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.purple,
//               foregroundColor: Colors.white,
//             ),
//             onPressed: () {
//               Navigator.of(context).pop();
//               setState(() {
//                 controller.text = selectedDate.toLocal().toString().split(' ')[0];
//                 _joinToMassWedding = true; // Automatically set to join
                
//                 if (controller == _date1Controller) {
//                   _updateTwoDayAvailability();
//                 }
//               });
              
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text(
//                     'تم اختيار التاريخ المختلط في ${DateFormat('dd/MM/yyyy').format(selectedDate)}. '
//                     'طلبك سيكون معلقاً حتى يتم تأكيد الحجوزات الأخرى.'
//                   ),
//                   backgroundColor: Colors.purple,
//                   duration: const Duration(seconds: 4),
//                 ),
//               );
//             },
//             child: const Text('نعم، أريد الانضمام'),
//           ),
//       ],
//     ),
//   );
// }


// // 6. Add these helper methods for handling different date selection scenarios
// void _handleAvailableDate(DateTime selectedDate, TextEditingController controller) {
//   setState(() {
//     controller.text = selectedDate.toLocal().toString().split(' ')[0];
    
//     if (controller == _date1Controller) {
//       _updateTwoDayAvailability();
//     }
//   });
  
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       content: Text('تم اختيار التاريخ ${DateFormat('dd/MM/yyyy').format(selectedDate)}'),
//       backgroundColor: Colors.green,
//       duration: const Duration(seconds: 2),
//     ),
//   );
// }

// void _handleMassWeddingDate(DateTime selectedDate, DateAvailability availability, TextEditingController controller) {
//   // Show confirmation dialog for mass wedding
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: const Text('زفاف جماعي متاح'),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('هذا التاريخ متاح للزفاف الجماعي'),
//           const SizedBox(height: 8),
//           Text('العدد الحالي: ${availability.currentCount}/${availability.maxCapacity}'),
//           const SizedBox(height: 8),
//           const Text('هل تريد الانضمام لهذا الزفاف الجماعي؟'),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: const Text('إلغاء'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//             setState(() {
//               controller.text = selectedDate.toLocal().toString().split(' ')[0];
//               _joinToMassWedding = true; // Automatically set to join
              
//               if (controller == _date1Controller) {
//                 _updateTwoDayAvailability();
//               }
//             });
            
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('تم اختيار التاريخ للانضمام للزفاف الجماعي في ${DateFormat('dd/MM/yyyy').format(selectedDate)}'),
//                 backgroundColor: Colors.blue,
//                 duration: const Duration(seconds: 3),
//               ),
//             );
//           },
//           child: const Text('نعم، أريد الانضمام'),
//         ),
//       ],
//     ),
//   );
// }

// void _handlePendingMassWeddingDate(DateTime selectedDate, DateAvailability availability, TextEditingController controller) {
//   // Show info dialog for pending mass wedding
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: const Text('حجز في انتظار التأكيد'),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('هذا التاريخ به حجز في انتظار التأكيد لكن يسمح بالانضمام'),
//           const SizedBox(height: 8),
//           Text('العدد الحالي: ${availability.currentCount}/${availability.maxCapacity}'),
//           const SizedBox(height: 8),
//           const Text('هل تريد تقديم طلب للانضمام؟'),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: const Text('إلغاء'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//             setState(() {
//               controller.text = selectedDate.toLocal().toString().split(' ')[0];
//               _joinToMassWedding = true;
              
//               if (controller == _date1Controller) {
//                 _updateTwoDayAvailability();
//               }
//             });
            
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('تم اختيار التاريخ. طلبك سيكون في انتظار التأكيد في ${DateFormat('dd/MM/yyyy').format(selectedDate)}'),
//                 backgroundColor: Colors.orange,
//                 duration: const Duration(seconds: 3),
//               ),
//             );
//           },
//           child: const Text('نعم، أريد تقديم الطلب'),
//         ),
//       ],
//     ),
//   );
// }

// void _showDateNotAvailableMessage(String message) {
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       content: Text(message),
//       backgroundColor: Colors.red,
//       duration: const Duration(seconds: 3),
//     ),
//   );
// }

// // Updated fallback method with better error handling
// // 7. Update the fallback date picker method
// Future<void> _showFallbackDatePicker(TextEditingController controller, String title) async {
//   try {
//     final now = DateTime.now();
    
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: controller.text.isNotEmpty 
//           ? DateTime.tryParse(controller.text) ?? now.add(const Duration(days: 30))
//           : now.add(const Duration(days: 30)),
//       firstDate: now,
//       lastDate: now.add(const Duration(days: 365)),
//       helpText: title,
//       cancelText: 'إلغاء',
//       confirmText: 'تأكيد',
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: Color(0xFF4CAF50),
//               onPrimary: Colors.white,
//               surface: Colors.white,
//               onSurface: Colors.black,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
    
//     if (picked != null && mounted) {
//       setState(() {
//         controller.text = picked.toLocal().toString().split(' ')[0];
        
//         if (controller == _date1Controller) {
//           _updateTwoDayAvailability();
//         }
//       });
      
//       // Show warning that this bypasses availability checking
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('تم اختيار التاريخ بدون التحقق من التوفر. قد يتم رفض الحجز إذا كان التاريخ محجوز.'),
//           backgroundColor: Colors.orange,
//           duration: Duration(seconds: 4),
//         ),
//       );
//     }
//   } catch (e) {
//     print('Error in fallback date picker: $e');
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('خطأ في اختيار التاريخ: $e'),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     }
//   }
// }

//  // Helper method to get selected month name in Arabic
//   String? _getSelectedMonthName() {
//     if (_date1Controller.text.isEmpty) return null;
    
//     try {
//       final selectedDate = DateTime.parse(_date1Controller.text);
//       final monthNames = [
//         'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
//         'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
//       ];
//       return monthNames[selectedDate.month - 1];
//     } catch (e) {
//       return null;
//     }
//   }
// }