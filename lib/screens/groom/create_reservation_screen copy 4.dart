// // lib/screens/reservation/create_reservation_screen.dart
// import 'dart:math' as math;

// import 'package:flutter/material.dart';
// import 'package:wedding_reservation_app/screens/groom/groom_home_screen.dart';
// import '../../services/api_service.dart';
// import '../../utils/colors.dart';
// import 'package:intl/intl.dart' hide TextDirection; // For date formatting
// import '../../services/api_service.dart';
// import '../../utils/colors.dart';
// import 'custom_calendar_picker.dart'; // Import your custom calendar widget

// class CreateReservationScreen extends StatefulWidget {
//   final VoidCallback? onReservationCreated;
  
//   const CreateReservationScreen({
//     super.key, 
//     this.onReservationCreated,
//   });

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
//   // Map<String, dynamic>? _response; // This will store the reservation response
    
//   // Clan settings (loaded separately)
//   Map<String, dynamic>? _clanSettings;
  
//   // Reservation settings
//   bool _allowOthers = false;
//   bool _joinToMassWedding = false;
//   bool _date2Bool = false;
//   bool _canSelectTwoDays = false; // Based on clan settings
  
//   bool _isLoading = true;
//   bool _isSubmitting = false;
//   int _maxCapacityPerDate = 3;


//   bool _isLoadingInstructionSettings = false;
//   bool _instructionSettingsLoaded = false;
//   Map<String, dynamic>? _originClanSettings;
//   Map<String, dynamic>? _selectedClanSettings;  


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

// Future<void> _refreshData() async {
//   setState(() => _isLoading = true);
  
//   try {
//     // Reset all selections when refreshing
//     _selectedClan = null;
//     _selectedHall = null;
//     _selectedHaiaCommittee = null;
//     _selectedMadaehCommittee = null;
//     _halls.clear();
//     _clanSettings = null;
//     _originClanSettings = null;
//     _selectedClanSettings = null;
//     _instructionSettingsLoaded = false;
//     _canSelectTwoDays = false;
//     _date2Bool = false;
//     _maxCapacityPerDate = 3;
    
//     // Clear form fields
//     _date1Controller.clear();
    
//     // Reset options
//     _allowOthers = false;
//     _joinToMassWedding = false;
    
//     // Go back to first step
//     _currentStep = 0;
//     _pageController.animateToPage(
//       0,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
    
//     await _loadInitialData();
    
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('تم تحديث البيانات بنجاح'),
//           backgroundColor: Colors.green,
//           duration: Duration(seconds: 2),
//         ),
//       );
//     }
//   } catch (e) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('خطأ في تحديث البيانات: $e'),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     }
//   } finally {
//     if (mounted) {
//       setState(() => _isLoading = false);
//     }
//   }
// }

// Future<void> _loadInstructionClanSettings() async {
//   if (_instructionSettingsLoaded) return;
  
//   setState(() => _isLoadingInstructionSettings = true);
  
//   try {
//       // Load origin clan settings (user's clan)
//       if (_userProfile?['clan_id'] != null) {
//         final clanId = _userProfile!['clan_id'].toString();
//         print("DEBUG: Loading origin clan settings for clan_id = $clanId");

//         try {
//           _originClanSettings = await ApiService.getSettingsByClanId(clanId);
//           print("DEBUG: Origin clan settings loaded successfully: $_originClanSettings");
//         } catch (e, stack) {
//           print("ERROR: Failed to load origin clan settings for clan_id = $clanId");
//           print("Exception: $e");
//           print("Stacktrace: $stack");
//         }
//       } else {
//         print("DEBUG: No clan_id found in _userProfile, skipping origin clan settings load.");
//       }

//     // Load selected clan settings if different from origin clan
//     if (_selectedClan != null && _selectedClan!['id'] != _userProfile?['clan_id']) {
//       _selectedClanSettings = await ApiService.getSettingsByClanId(_selectedClan!['id'].toString());
//     }
    
//     setState(() {
//       _instructionSettingsLoaded = true;
//     });
//   } catch (e) {
//     print('Error loading instruction clan settings: $e');
//   } finally {
//     setState(() => _isLoadingInstructionSettings = false);
//   }
// }

// bool _isCrossClanReservation() {
//   return _userProfile?['clan_id'] != null && 
//          _selectedClan != null && 
//          _userProfile!['clan_id'] != _selectedClan!['id'];
// }

// Map<String, String> _getClanAcceptanceTime(bool isOriginClan) {
//   Map<String, dynamic>? settings =isOriginClan ?  _originClanSettings :_selectedClanSettings ;
  
//   if (settings == null) {
//     return {'day': 'يوم غير محدد', 'time': 'وقت غير محدد'};
//   }
  

// // Parse acceptance day
// // Parse acceptance days (can be multiple days)
// String dayKey = 'days_to_accept_invites';
// dynamic dayValue = settings[dayKey];
// List<String> arabicDays = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];

// String day = 'يوم غير محدد'; // Default value

// if (dayValue != null && dayValue.toString().isNotEmpty) {
//   String dayString = dayValue.toString().trim();
  
//   // Split by comma to handle multiple days
//   List<String> dayIndices = dayString.split(',')
//       .map((s) => s.trim())
//       .where((s) => s.isNotEmpty)
//       .toList();
  
//   List<String> validDays = [];
  
//   for (String indexStr in dayIndices) {
//     int? dayIndex = int.tryParse(indexStr);
//     if (dayIndex != null && dayIndex >= 0 && dayIndex < 7) {
//       validDays.add(arabicDays[dayIndex]);
//     }
//   }
  
//   if (validDays.isNotEmpty) {
//     // Join multiple days with " و " (Arabic "and")
//     day = validDays.join(' و ');
//   }
// }

// // Parse acceptance times (can be multiple times)
// String timeKey = 'accept_invites_times';
// dynamic timeValue = settings[timeKey];

// String time = 'وقت غير محدد'; // Default value

// if (timeValue != null && timeValue.toString().isNotEmpty) {
//   String timeString = timeValue.toString().trim();
  
//   // Split by comma and clean up empty values
//   List<String> timeSlots = timeString.split(',')
//       .map((s) => s.trim())
//       .where((s) => s.isNotEmpty)
//       .toList();
  
//   List<String> validTimes = [];
  
//   for (String timeSlot in timeSlots) {
//     // Basic validation for time format (HH:MM)
//     RegExp timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
//     if (timeRegex.hasMatch(timeSlot)) {
//       validTimes.add(timeSlot);
//     }
//   }
  
//   if (validTimes.isNotEmpty) {
//     // Join multiple times with " و " (Arabic "and")
//     time = validTimes.join(' و ');
//   }
// }

//   return {'day': day, 'time': time};

// }

// String _getSelectedClanName() {
//   return _selectedClan?['name']?.toString() ?? 'العشيرة المختارة';
// }

// String _getOriginClanName() {
//   // Try to get from user profile first, fallback to selected clan name
//   String? clanName = _userProfile?['clan_name']?.toString();
//   if (clanName != null && clanName.isNotEmpty) {
//     return clanName;
//   }
  
//   // If origin clan settings are loaded, try to get name from there
//   if (_originClanSettings?['clan_name'] != null) {
//     return _originClanSettings!['clan_name'].toString();
//   }
  
//   return 'عشيرتك';
// }

// String _getValidationDeadlineDays() {
//   // Try to get from selected clan settings first, then origin clan
//   int? days = _originClanSettings?['validation_deadline_days'];
  
//   return days?.toString() ?? '10';
// }

// // Helper method to format day-time pairs
// String _formatDayTimeSchedule(String days, String times) {
//   if (days.isEmpty || times.isEmpty) {
//     return '(لم يتم تحديد مواعيد الاستقبال)';
//   }
  
//   // Split days and times
//   List<String> dayList = days.split(' و ').map((d) => d.trim()).toList();
//   List<String> timeList = times.split(' و ').map((t) => t.trim()).toList();
  
//   List<String> schedules = [];
  
//   // Pair each day with its corresponding time
//   int maxLength = math.min(dayList.length, timeList.length);
  
//   for (int i = 0; i < maxLength; i++) {
//     schedules.add('(يتم الاستقبال يوم ${dayList[i]} في الساعة ${timeList[i]})');
//   }
  
//   // Handle extra days or times
//   if (dayList.length > timeList.length) {
//     for (int i = maxLength; i < dayList.length; i++) {
//       schedules.add('(يتم الاستقبال يوم ${dayList[i]} - وقت غير محدد)');
//     }
//   }
  
//   if (schedules.isEmpty) {
//     return '(لم يتم تحديد مواعيد الاستقبال)';
//   }
  
//   return schedules.join(' و ');
// }

// String _buildReservationInstructionText() {
//   String baseText = 'للحصول على الموافقة النهائية، يجب طباعة الحجز وختمه وتوقيعه من:\n'
//                    ' \n'
//                    '- الهيئة الدينية\n';

// if (_isCrossClanReservation()) {
//   Map<String, String> selectedClanTime = _getClanAcceptanceTime(false);
//   String selectedClanName = _getSelectedClanName();
  
//   String formattedSchedule = _formatDayTimeSchedule(
//     selectedClanTime['day'] ?? '', 
//     selectedClanTime['time'] ?? ''
//   );
//   baseText += '\n';
//   baseText += '- الدار المضيفة ($selectedClanName) $formattedSchedule\n';
// }


// Map<String, String> originClanTime = _getClanAcceptanceTime(true);
// String originClanName = _getOriginClanName();


// String formattedSchedule = _formatDayTimeSchedule(
//   originClanTime['day'] ?? '', 
//   originClanTime['time'] ?? ''
// );
// baseText += '\n';
// baseText += '- إدارة عشيرتك $originClanName $formattedSchedule\n\n';

//   // Safely get validation deadline days with fallback
//   String daysMax = _getValidationDeadlineDays();

//   baseText += '\n';
//   baseText += 'يجب استكمال هذه الإجراءات خلال $daysMax أيام كحد أقصى، وإلا يُلغى الحجز تلقائياً.\n\n'
//               'بعد ختم وتوقيع جميع الجهات، توجّه إلى إدارة عشيرتك $originClanName ليؤكد حجزك في النظام.\n\n';

//   return baseText;
// }


// Future<void> _submitReservation() async {
//   setState(() => _isSubmitting = true);
  
//   Map<String, dynamic>? response;
  
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

//     response = await ApiService.createReservation(reservationData);
//     print('Reservation created successfully: ${response['reservation_id']}');

//     if (mounted) {
//       // Navigate to GroomHomeScreen with reservations tab selected
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(
//           builder: (context) => const GroomHomeScreen(initialTabIndex: 2), // Index 2 is reservations tab
//         ),
//       );
      
//       // Show success message with PDF info if available
//       String successMessage = 
//         'تم إنشاء حجز جديد بنجاح! يجب طباعة الحجز وختمه وتوقيعه خلال 10 أيام كأقصى حد، '
//         'وإلا سيتم إلغاء الحجز تلقائيًا.';

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(successMessage),
//           backgroundColor: Colors.green,
//           duration: const Duration(seconds: 12),
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
    
//     // Check if error is related to authentication
//     String errorStr = e.toString().toLowerCase();
//     if (errorStr.contains('401') || errorStr.contains('unauthorized') || 
//         errorStr.contains('invalid token') || errorStr.contains('token expired')) {
//       // Authentication error - redirect to login
//       if (mounted) {
//         Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.'),
//             backgroundColor: Colors.red,
//             duration: Duration(seconds: 5),
//           ),
//         );
//       }
//       return; // Exit early for auth errors
//     }
    



//     // If reservation was created but error occurred after, delete it
//     if (response != null && response.containsKey('reservation_id')) {
//       try {
//         print('Deleting reservation due to error: ${response['reservation_id']}');
//         await ApiService.deleteReservation(response['reservation_id']);
//         print('Reservation deleted successfully');
//       } catch (deleteError) {
//         print('Failed to delete reservation: $deleteError');
//       }
//     }
    
//     if (mounted) {
//       String errorMessage = 'خطأ في إرسال طلب الحجز';
      
//       // Parse common backend error messages
//       if (errorStr.contains('already have an active reservation')) {
//         errorMessage = 'لديك حجز نشط بالفعل';
//       } else if (errorStr.contains('not allowed in this month')) {
//         errorMessage = 'حجز يومين غير مسموح في هذا الشهر';
//       } else if (errorStr.contains('already reserved')) {
//         errorMessage = 'التاريخ محجوز بالفعل';
//       } else if (errorStr.contains('fully booked')) {
//         errorMessage = 'التاريخ ممتلئ بالكامل';
//       } else if (errorStr.contains('pdf')) {
//         errorMessage = 'خطأ في إنشاء ملف PDF. يرجى المحاولة مرة أخرى';
//       } else if (errorStr.contains('server error') || errorStr.contains('500')) {
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


//   // Load clan settings by clan ID
//   Future<void> _loadSettingForClan(int clanId) async {
//     try {
//       final settings = await ApiService.getSettingsByClanId(clanId.toString());
//       setState(() { 
//         _clanSettings = settings;
//         _maxCapacityPerDate = settings['max_grooms_per_date'] ?? 3;
//       });
//     } catch (e) {
//       print('Error loading clan settings: $e');
//       setState(() {
//         _clanSettings = null;
//         _maxCapacityPerDate = 3; 
//       });
//     }
//   }

//   // // Load general clan settings (if needed)
//   // Future<void> _loadClanSettings() async {
//   //   if (_selectedClan == null) return;
    
//   //   try {
//   //     final settings = await ApiService.getSettingsByClanId(_selectedClan!['id'].toString());
//   //     setState(() {
//   //       _clanSettings = settings;
//   //       _maxCapacityPerDate = settings['max_grooms_per_date'] ?? 3;
//   //     });
//   //   } catch (e) {
//   //     print('Error loading clan settings: $e');
//   //     setState(() {
//   //       _clanSettings = null;
//   //       _maxCapacityPerDate = 3;
//   //     });
//   //   }
//   // }


//    // Enhanced _selectDate method with API integration
//   Future<void> _selectDate(TextEditingController controller, String title) async {
//     if (_selectedClan == null || _selectedHall == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('يرجى اختيار العشيرة والقاعة أولاً')),
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
      
//       // Close loading indicator
//       if (Navigator.canPop(context)) {
//         Navigator.of(context).pop();
//       }

//       // Show enhanced calendar picker with API integration
//       if (mounted) {
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (context) => BeautifulCustomCalendarPicker(
//             title: title,
//             clanId: _selectedClan!['id'],
//             hallId: _selectedHall?['id'],
//             maxCapacityPerDate: _maxCapacityPerDate,
//             initialDate: controller.text.isNotEmpty 
//                 ? DateTime.tryParse(controller.text) ?? now.add(const Duration(days: 30))
//                 : now.add(const Duration(days: 30)),
//             firstDate: now,
//             lastDate: now.add(const Duration(days: 365)),
//             allowTwoConsecutiveDays: _canSelectTwoDays,
//             onDateSelected: (selectedDate, availability) {
//               Navigator.of(context).pop();
              
//               // Handle different date statuses
//               if (availability != null) {
//                 switch (availability.status) {
//                   case DateStatus.available:
//                     _handleAvailableDate(selectedDate, controller);
//                     break;
//                   case DateStatus.massWeddingOpen:
//                     _handleMassWeddingDate(selectedDate, availability, controller);
//                     break;
//                   case DateStatus.mixed:
//                     _handleMixedStatusDate(selectedDate, availability, controller);
//                     break;
//                   case DateStatus.pending:
//                     if (availability.allowMassWedding) {
//                       _handlePendingMassWeddingDate(selectedDate, availability, controller);
//                     } else {
//                       _showDateNotAvailableMessage('هذا التاريخ في انتظار التأكيد ولا يسمح بالانضمام');
//                     }
//                     break;
//                   case DateStatus.reserved:
//                     _showDateNotAvailableMessage('هذا التاريخ محجوز بالكامل');
//                     break;
//                   case DateStatus.disabled:
//                     _showDateNotAvailableMessage('هذا التاريخ غير متاح للحجز');
//                     break;
//                 }
//               } else {
//                 _showDateNotAvailableMessage('خطأ في تحميل معلومات التاريخ');
//               }
//             },
//             onCancel: () {
//               Navigator.of(context).pop();
//             },
//           ),
//         );
//       }

//     } catch (e) {
//       // Close loading indicator if still open
//       if (Navigator.canPop(context)) {
//         Navigator.of(context).pop();
//       }
      
//       print('Error loading calendar: $e');
      
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('خطأ في تحميل التقويم: $e'),
//             backgroundColor: Colors.red,
//             duration: const Duration(seconds: 8),
//           ),
//         );

//         // Fall back to default date picker
//         _showFallbackDatePicker(controller, title);
//       }
//     }
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

//   // Updated _onClanSelected method to load settings
//   void _onClanSelected(Map<String, dynamic>? clan) {
//     setState(() {
//       _selectedClan = clan;
//       _selectedHall = null;
//       _halls.clear();
//       _clanSettings = null; // Reset clan settings
      
//       if (clan != null) {
//         // Check if clan allows two days (will be updated when date is selected)
//         _updateTwoDayAvailability();
        
//         // Load halls for this clan
//         _loadHallsForClan(clan['id']);
//         _loadSettingForClan(clan['id']);
        
//         // Load clan settings for capacity
//         // _loadClanSettings();
//       } else {
//         _canSelectTwoDays = false;
//         _date2Bool = false;
//         _maxCapacityPerDate = 3; // Reset to default
//       }
//     });
//   }

//   // Updated method to check two-day availability based on selected date and clan settings
//   void _updateTwoDayAvailability() {
//     if (_selectedClan == null || _date1Controller.text.isEmpty || _clanSettings == null) {
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
      
//       // Use the loaded clan settings instead of trying to access from clan object
//       final settings = _clanSettings!;
      
//       // Check if clan allows two day reservations at all
//       final allowTwoDay = settings['allow_two_day_reservations'] == true;
//       print('------ two day : $allowTwoDay');
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

//     return Scaffold(
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               children: [
//                 for (int i = 0; i < 3; i++) ...[
//                   Expanded(
//                     child: Container(
//                       height: 4,
//                       decoration: BoxDecoration(
//                         color: i <= _currentStep 
//                           ? const Color.fromARGB(255, 0, 151, 98)
//                           : const Color.fromARGB(255, 110, 174, 122).withOpacity(0.3),
//                         borderRadius: BorderRadius.circular(2),
//                       ),
//                     ),
//                   ),
//                   if (i < 2) const SizedBox(width: 8),
//                 ],
//               ],
//             ),
//           ),
//           Expanded(
//             child: Form(
//               key: _formKey,
//               child: PageView(
//                 controller: _pageController,
//                 onPageChanged: (index) => setState(() => _currentStep = index),
//                 children: [
//                   _buildClanAndHallSelectionStep(),
//                   _buildReservationDetailsStep(),
//                   _buildConfirmationStep(),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: _buildBottomNavigation(),
//     );
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
//                     // Remove the check for 'allow_two_days' from clan object since it doesn't exist
//                     // Settings will be loaded separately
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
//                     // Show settings info if loaded
//                     if (_clanSettings != null)
//                       _buildInfoRow('السماح بيومين', _clanSettings!['allow_two_day_reservations'] == true ? 'نعم' : 'لا'),
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
//                           ? 'العشيرة تسمح بحجز يومين متتاليين لشهر ${_getSelectedMonthName()}. '
//                           : 'العشيرة تسمح بحجز يومين متتاليين لهذا الشهر. ',
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

//           ]),
          
//           const SizedBox(height: 16),
          

//           // Important Note with dynamic content
//           Builder(
//             builder: (context) {
//               // Load settings only if clan is selected and settings not loaded
//               if (_selectedClan != null && !_instructionSettingsLoaded) {
//                 // Call load settings but don't wait for it in build
//                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                   _loadInstructionClanSettings();
//                 });
//               }
              
//               if (_isLoadingInstructionSettings) {
//                 return Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: const Color.fromARGB(255, 253, 227, 227),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: const Color.fromARGB(255, 249, 144, 144)),
//                   ),
//                   child: Row(
//                     children: [
//                       SizedBox(
//                         width: 16,
//                         height: 16,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: const Color.fromARGB(255, 249, 144, 144),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Text('جاري تحميل معلومات الاستقبال...'),
//                     ],
//                   ),
//                 );
//               }
              
//               return Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: const Color.fromARGB(255, 253, 227, 227),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: const Color.fromARGB(255, 249, 144, 144)),
//                 ),
//                 child: Directionality(
//                   textDirection: TextDirection.rtl,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       // Header section
//                       Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             Icons.info,
//                             color: const Color.fromARGB(255, 249, 144, 144),
//                             size: 32,
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             'ملاحظة مهمة',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: const Color.fromARGB(255, 0, 0, 0),
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),

//                       // Dynamic instruction text
//                       Text(
//                         _buildReservationInstructionText(),
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: const Color.fromARGB(255, 0, 0, 0),
//                           height: 1.5,
//                         ),
//                         textAlign: TextAlign.start,
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
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

//   // Add this new method to handle mixed status dates (both validated and pending reservations)
//   void _handleMixedStatusDate(DateTime selectedDate, DateAvailability availability, TextEditingController controller) {
//     // Show detailed dialog for mixed status
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('تاريخ مختلط (مؤكد ومعلق)'),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'هذا التاريخ يحتوي على حجوزات مؤكدة وحجوزات في انتظار التأكيد:',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 12),
              
//               // Validated reservations count
//               Row(
//                 children: [
//                   Container(
//                     width: 12,
//                     height: 12,
//                     decoration: const BoxDecoration(
//                       color: Colors.green,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Text('حجوزات مؤكدة: ${availability.validatedCount}'),
//                 ],
//               ),
//               const SizedBox(height: 8),
              
//               // Pending reservations count
//               Row(
//                 children: [
//                   Container(
//                     width: 12,
//                     height: 12,
//                     decoration: const BoxDecoration(
//                       color: Colors.orange,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Text('حجوزات معلقة: ${availability.pendingCount}'),
//                 ],
//               ),
//               const SizedBox(height: 8),
              
//               // Total count
//               Row(
//                 children: [
//                   Container(
//                     width: 12,
//                     height: 12,
//                     decoration: const BoxDecoration(
//                       color: Colors.purple,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     'المجموع: ${availability.currentCount}/${availability.maxCapacity}',
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
              
//               if (availability.allowMassWedding) ...[
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.blue.shade50,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: Colors.blue.shade200),
//                   ),
//                   child: const Row(
//                     children: [
//                       Icon(Icons.people_alt, color: Colors.blue, size: 20),
//                       SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           'يمكنك الانضمام لهذا التاريخ',
//                           style: TextStyle(
//                             color: Colors.blue,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//               ],
              
//               // Warning about pending reservations
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.orange.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.orange.shade200),
//                 ),
//                 child: const Row(
//                   children: [
//                     Icon(Icons.warning_amber, color: Colors.orange, size: 20),
//                     SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         'تنبيه: الحجوزات المعلقة قد تُلغى خلال 10 أيام',
//                         style: TextStyle(
//                           color: Colors.orange,
//                           fontSize: 12,
//                           fontStyle: FontStyle.italic,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 12),
              
//               Text(
//                 availability.allowMassWedding 
//                     ? 'هل تريد تقديم طلب للانضمام لهذا التاريخ؟'
//                     : 'هذا التاريخ لا يسمح بحجوزات إضافية.',
//                 style: const TextStyle(fontWeight: FontWeight.w500),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('إلغاء'),
//           ),
//           if (availability.allowMassWedding)
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.purple,
//                 foregroundColor: Colors.white,
//               ),
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 setState(() {
//                   controller.text = selectedDate.toLocal().toString().split(' ')[0];
//                   _joinToMassWedding = true; // Automatically set to join
                  
//                   if (controller == _date1Controller) {
//                     _updateTwoDayAvailability();
//                   }
//                 });
                
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text(
//                       'تم اختيار التاريخ لانضمام لعرس جماعي في ${DateFormat('dd/MM/yyyy').format(selectedDate)}. '
//                       'طلبك سيكون معلقاً حتى يتم تأكيد الحجوزات الأخرى.'
//                     ),
//                     backgroundColor: Colors.purple,
//                     duration: const Duration(seconds: 8),
//                   ),
//                 );
//               },
//               child: const Text('نعم، أريد الانضمام'),
//             ),
//         ],
//       ),
//     );
//   }

//   // Helper methods for handling different date selection scenarios
//   void _handleAvailableDate(DateTime selectedDate, TextEditingController controller) {
//     setState(() {
//       controller.text = selectedDate.toLocal().toString().split(' ')[0];
      
//       if (controller == _date1Controller) {
//         _updateTwoDayAvailability();
//       }
//     });
    
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('تم اختيار التاريخ ${DateFormat('dd/MM/yyyy').format(selectedDate)}'),
//         backgroundColor: Colors.green,
//         duration: const Duration(seconds: 8),
//       ),
//     );
//   }

//   void _handleMassWeddingDate(DateTime selectedDate, DateAvailability availability, TextEditingController controller) {
//     // Show confirmation dialog for mass wedding
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('زفاف جماعي متاح'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('هذا التاريخ متاح للزفاف الجماعي'),
//             const SizedBox(height: 8),
//             Text('العدد الحالي: ${availability.currentCount}/${availability.maxCapacity}'),
//             const SizedBox(height: 8),
//             const Text('هل تريد الانضمام لهذا الزفاف الجماعي؟'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
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
//                   content: Text('تم اختيار التاريخ للانضمام للزفاف الجماعي في ${DateFormat('dd/MM/yyyy').format(selectedDate)}'),
//                   backgroundColor: Colors.blue,
//                   duration: const Duration(seconds: 8),
//                 ),
//               );
//             },
//             child: const Text('نعم، أريد الانضمام'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _handlePendingMassWeddingDate(DateTime selectedDate, DateAvailability availability, TextEditingController controller) {
//     // Show info dialog for pending mass wedding
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('حجز في انتظار التأكيد'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('هذا التاريخ به حجز في انتظار التأكيد لكن يسمح بالانضمام'),
//             const SizedBox(height: 8),
//             Text('العدد الحالي: ${availability.currentCount}/${availability.maxCapacity}'),
//             const SizedBox(height: 8),
//             const Text('هل تريد تقديم طلب للانضمام؟'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               setState(() {
//                 controller.text = selectedDate.toLocal().toString().split(' ')[0];
//                 _joinToMassWedding = true;
                
//                 if (controller == _date1Controller) {
//                   _updateTwoDayAvailability();
//                 }
//               });
              
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('تم اختيار التاريخ. طلبك سيكون في انتظار التأكيد في ${DateFormat('dd/MM/yyyy').format(selectedDate)}'),
//                   backgroundColor: Colors.orange,
//                   duration: const Duration(seconds: 8),
//                 ),
//               );
//             },
//             child: const Text('نعم، أريد تقديم الطلب'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showDateNotAvailableMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         duration: const Duration(seconds: 9),
//       ),
//     );
//   }

//   // Updated fallback date picker method
//   Future<void> _showFallbackDatePicker(TextEditingController controller, String title) async {
//     try {
//       final now = DateTime.now();
      
//       final DateTime? picked = await showDatePicker(
//         context: context,
//         initialDate: controller.text.isNotEmpty 
//             ? DateTime.tryParse(controller.text) ?? now.add(const Duration(days: 30))
//             : now.add(const Duration(days: 30)),
//         firstDate: now,
//         lastDate: now.add(const Duration(days: 365)),
//         helpText: title,
//         cancelText: 'إلغاء',
//         confirmText: 'تأكيد',
//         builder: (context, child) {
//           return Theme(
//             data: Theme.of(context).copyWith(
//               colorScheme: const ColorScheme.light(
//                 primary: Color(0xFF4CAF50),
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
//           controller.text = picked.toLocal().toString().split(' ')[0];
          
//           if (controller == _date1Controller) {
//             _updateTwoDayAvailability();
//           }
//         });
        
//         // Show warning that this bypasses availability checking
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('تم اختيار التاريخ بدون التحقق من التوفر. قد يتم رفض الحجز إذا كان التاريخ محجوز.'),
//             backgroundColor: Colors.orange,
//             duration: Duration(seconds: 8),
//           ),
//         );
//       }
//     } catch (e) {
//       print('Error in fallback date picker: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('خطأ في اختيار التاريخ: $e'),
//             backgroundColor: Colors.red,
//             duration: const Duration(seconds: 9),
//           ),
//         );
//       }
//     }
//   }

//   // Helper method to get selected month name in Arabic
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