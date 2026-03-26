// // lib/screens/reservation/create_reservation_screen.dart
// import 'dart:math' as math;

// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart' hide TextDirection; // For date formatting
// import 'package:wedding_reservation_app/screens/groom/groom_home_screen.dart';

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
//   State<CreateReservationScreen> createState() => CreateReservationScreenState();
// }

// class CreateReservationScreenState extends State<CreateReservationScreen> {
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
//   final _customMadaehCommitteeController = TextEditingController();
//   bool _showCustomMadaehInput = false;

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
  
//   bool _isLoading = false;
//   bool _isSubmitting = false;
//   int _maxCapacityPerDate = 3;
//   int _years_max_reserv_GroomFromOutClan = 1;
//   int _years_max_reserv_GrooomFromOriginClan = 3;


//   bool _isLoadingInstructionSettings = false;
//   bool _instructionSettingsLoaded = false;
//   Map<String, dynamic>? _originClanSettings;
//   Map<String, dynamic>? _selectedClanSettings;  

//   bool _isLoadingClans = false;
//   bool _isLoadingHalls = false;


//   // Add these with other state variables (around line 28-30)
//   String? _selectedTilawaType; // null, 'جماعية', or 'فردية'
//   final _customTilawaNameController = TextEditingController();
//   bool _showCustomTilawaInput = false;


//   @override
//   void initState() {
//     super.initState();
//     _loadInitialData();
//   }


//  void refreshData() {
//     _loadInitialData();
//     _refreshData();
//     setState(() {
//       // Trigger rebuild
//     });
//   }
  
//   // @override
//   // void dispose() {
//   //   _date1Controller.dispose();
//   //   _pageController.dispose();
//   //   super.dispose();
//   // }
//   @override
// void dispose() {
//   _date1Controller.dispose();
//   // Remove or comment out this line:
//   // _pageController.dispose();
//   _customMadaehCommitteeController.dispose(); 
//   _customTilawaNameController.dispose(); 


//   super.dispose();
// }
// // Add this method in the CreateReservationScreenState class
// bool get _isOriginClan {
//   if (_userProfile == null || _selectedClan == null) {
//     return false;
//   }
//   return _userProfile!['clan_id'] == _selectedClan!['id'];
// }
// void _showMessageDialog({
//   required String title,
//   required String message,
//   Color? titleColor,
//   Color? backgroundColor,
//   IconData? icon,
//   bool isError = false, 

// }) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         title: Row(
//           children: [
//             if (icon != null) ...[
//               Icon(
//                 icon,
//                 color: titleColor ?? (isError ? Colors.red : Colors.green),
//                 size: 24,
//               ),
//               const SizedBox(width: 8),
//             ],
//             Expanded(
//               child: Text(
//                 title,
//                 style: TextStyle(
//                   color: titleColor ?? (isError ? Colors.red : Colors.green),
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         content: SingleChildScrollView(

//           child: Text(
//             message,
//             style:  TextStyle(
//               fontSize: 16,
//               height: 1.4,
//               color: const Color.fromARGB(255, 64, 73, 78),
//             ),
//             textAlign: TextAlign.right,
//           ),
//         ),
//         backgroundColor: backgroundColor ?? Colors.white,
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             style: TextButton.styleFrom(
//               foregroundColor: titleColor ?? (isError ? Colors.red : Colors.green),
//             ),
//             child: const Text('حسناً'),
//           ),
//         ],
//       );
//     },
//   );
// }

// // Future<void> _refreshData() async {
// //   setState(() => _isLoading = true);
  
// //   try {
// //     // Reset all selections when refreshing
// //     _selectedClan = null;
// //     _selectedHall = null;
// //     _selectedHaiaCommittee = null;
// //     _selectedMadaehCommittee = null;
// //     _halls.clear();
// //     _clanSettings = null;
// //     _originClanSettings = null;
// //     _selectedClanSettings = null;
// //     _instructionSettingsLoaded = false;
// //     _canSelectTwoDays = false;
// //     _date2Bool = false;
// //     _maxCapacityPerDate = 3;
    
    
// //     // Clear form fields
// //     _date1Controller.clear();
    
// //     // Reset options
// //     _allowOthers = false;
// //     _joinToMassWedding = false;
    
// //     // Go back to first step
// //     _currentStep = 0;
// //     _pageController.animateToPage(
// //       0,
// //       duration: const Duration(milliseconds: 300),
// //       curve: Curves.easeInOut,
// //     );
    
// //     await _loadInitialData();
    
// //     if (mounted) {
// //       _showMessageDialog(
// //         title: 'تم التحديث',
// //         message: 'تم تحديث البيانات بنجاح',
// //         icon: Icons.refresh,
// //         isError: false,
// //       );
// //     }
// //   } catch (e) {
// //     if (mounted) {
// //       _showMessageDialog(
// //         title: 'خطأ في التحديث',
// //         message: 'خطأ في تحديث البيانات: $e',
// //         icon: Icons.error,
// //         isError: true,
// //       );
// //     }
// //   } finally {
// //     if (mounted) {
// //       setState(() => _isLoading = false);
// //     }
// //   }
// // }


// // Add this method in the CreateReservationScreenState class

// void _handleSpecialReservationDate(DateTime selectedDate, DateAvailability availability, TextEditingController controller) {
//   final reservation = availability.specialReservation;
  
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       title: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.black.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.star,
//               color: Colors.black,
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 12),
//           const Expanded(
//             child: Text(
//               'حجز خاص من العشيرة',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.05),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: Colors.black.withOpacity(0.1),
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       const Icon(Icons.event, size: 20),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           'اسم الحجز',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey[600],
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     reservation?.reservName ?? 'غير محدد',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
            
//             if (reservation?.reservDescription != null) ...[
//               const SizedBox(height: 12),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.05),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: Colors.black.withOpacity(0.1),
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         const Icon(Icons.description, size: 20),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             'الوصف',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey[600],
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       reservation!.reservDescription!,
//                       style: const TextStyle(
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
            
//             const SizedBox(height: 16),
            
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.orange.shade50,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.orange.shade200),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.info_outline, color: Colors.orange[700], size: 24),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       'هذا التاريخ محجوز لمناسبة خاصة من قبل العشيرة ولا يمكن حجزه.',
//                       style: TextStyle(
//                         color: Colors.orange[900],
//                         fontSize: 14,
//                         height: 1.4,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
            
//             if (reservation?.fullName != null || reservation?.phoneNumber != null) ...[
//               const SizedBox(height: 16),
//               const Text(
//                 'معلومات الاتصال:',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey,
//                 ),
//               ),
//               const SizedBox(height: 8),
              
//               if (reservation?.fullName != null)
//                 Row(
//                   children: [
//                     const Icon(Icons.person, size: 18, color: Colors.grey),
//                     const SizedBox(width: 8),
//                     Text(reservation!.fullName!),
//                   ],
//                 ),
              
//               if (reservation?.phoneNumber != null) ...[
//                 const SizedBox(height: 4),
//                 Row(
//                   children: [
//                     const Icon(Icons.phone, size: 18, color: Colors.grey),
//                     const SizedBox(width: 8),
//                     Text(reservation!.phoneNumber!),
//                   ],
//                 ),
//               ],
//             ],
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           style: TextButton.styleFrom(
//             foregroundColor: Colors.black,
//           ),
//           child: const Text('حسناً'),
//         ),
//       ],
//     ),
//   );
// }

// Future<void> _refreshData() async {
//   setState(() => _isLoading = true);
  
//   final connectivityResult = await Connectivity().checkConnectivity();
  
//   if (connectivityResult.contains(ConnectivityResult.none)) {
//     _showNoInternetDialog();
//     setState(() => _isLoading = false);
//     return;
//   }
  
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
    
//     // Clear custom inputs
//     _customMadaehCommitteeController.clear();
//     _selectedTilawaType = null;
//     _showCustomTilawaInput = false;
//     _customTilawaNameController.clear();
//     _showCustomMadaehInput = false;
    
//     // Reset to first step BEFORE loading data
//     _currentStep = 0;
//     if (mounted && _pageController.hasClients) {
//       await _pageController.animateToPage(
//         0,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
        
//     await _loadData();
    
//     if (mounted) {
//       _showMessageDialog(
//         title: 'تم التحديث',
//         message: 'تم تحديث البيانات بنجاح',
//         icon: Icons.refresh,
//         isError: false,
//       );
//     }
//   } catch (e) {
//     if (mounted) {
//       _showMessageDialog(
//         title: 'خطأ في التحديث',
//         message: 'خطأ في تحديث البيانات: $e',
//         icon: Icons.error,
//         isError: true,
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


//   Map<String, String> _getClanAcceptanceTime(bool isOriginClan) {
//     Map<String, dynamic>? settings =isOriginClan ?  _originClanSettings :_selectedClanSettings ;
    
//     if (settings == null) {
//       return {'day': 'يوم غير محدد', 'time': 'وقت غير محدد'};
//     }
    

//   // Parse acceptance day
//   // Parse acceptance days (can be multiple days)
//   String dayKey = 'days_to_accept_invites';
//   dynamic dayValue = settings[dayKey];
//   List<String> arabicDays = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];

//   String day = 'يوم غير محدد'; // Default value

//   if (dayValue != null && dayValue.toString().isNotEmpty) {
//     String dayString = dayValue.toString().trim();
    
//     // Split by comma to handle multiple days
//     List<String> dayIndices = dayString.split(',')
//         .map((s) => s.trim())
//         .where((s) => s.isNotEmpty)
//         .toList();
    
//     List<String> validDays = [];
    
//     for (String indexStr in dayIndices) {
//       int? dayIndex = int.tryParse(indexStr);
//       if (dayIndex != null && dayIndex >= 0 && dayIndex < 7) {
//         validDays.add(arabicDays[dayIndex]);
//       }
//     }
    
//     if (validDays.isNotEmpty) {
//       // Join multiple days with " و " (Arabic "and")
//       day = validDays.join(' و ');
//     }
//   }

//   // Parse acceptance times (can be multiple times)
//   String timeKey = 'accept_invites_times';
//   dynamic timeValue = settings[timeKey];

//   String time = 'وقت غير محدد'; // Default value

//   if (timeValue != null && timeValue.toString().isNotEmpty) {
//     String timeString = timeValue.toString().trim();
    
//     // Split by comma and clean up empty values
//     List<String> timeSlots = timeString.split(',')
//         .map((s) => s.trim())
//         .where((s) => s.isNotEmpty)
//         .toList();
    
//     List<String> validTimes = [];
    
//     for (String timeSlot in timeSlots) {
//       // Basic validation for time format (HH:MM)
//       RegExp timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
//       if (timeRegex.hasMatch(timeSlot)) {
//         validTimes.add(timeSlot);
//       }
//     }
    
//     if (validTimes.isNotEmpty) {
//       // Join multiple times with " و " (Arabic "and")
//       time = validTimes.join(' و ');
//     }
//   }

//     return {'day': day, 'time': time};

//   }

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

// // String _buildReservationInstructionText() {
// //   String baseText = 'للحصول على الموافقة النهائية، يجب طباعة الحجز وختمه وتوقيعه من:\n';

// // Map<String, String> originClanTime = _getClanAcceptanceTime(true);
// // String originClanName = _getOriginClanName();


// // String formattedSchedule = _formatDayTimeSchedule(
// //   originClanTime['day'] ?? '', 
// //   originClanTime['time'] ?? ''
// // );
// // baseText += '\n';
// // baseText += '1)  إدارة عشيرتك $originClanName $formattedSchedule\n\n';


// // if (_isCrossClanReservation()) {
// //   Map<String, String> selectedClanTime = _getClanAcceptanceTime(false);
// //   String selectedClanName = _getSelectedClanName();
  
// //   String formattedSchedule = _formatDayTimeSchedule(
// //     selectedClanTime['day'] ?? '', 
// //     selectedClanTime['time'] ?? ''
// //   );
// //   baseText += '\n';
// //   baseText += '2) الدار المضيفة ($selectedClanName) $formattedSchedule\n';
// // }



// // baseText += '\n';
// // if (_isCrossClanReservation()) {baseText +=  '3) الهيئة الدينية\n';}else{baseText +=  '2) الهيئة الدينية\n';}

// //   // Safely get validation deadline days with fallback
// //   String daysMax = _getValidationDeadlineDays();

// //   baseText += '\n';
// //   baseText += 'يجب استكمال هذه الإجراءات خلال $daysMax أيام كحد أقصى، وإلا يُلغى الحجز تلقائياً.\n\n'
// //               'بعد ختم وتوقيع جميع الجهات، توجّه إلى إدارة عشيرتك $originClanName ليؤكد حجزك في النظام.\n\n';

// //   return baseText;
// // }
// Widget _buildReservationInstructionWidget() {
//   final originClanTime = _getClanAcceptanceTime(true);
//   final originClanName = _getOriginClanName();
//   final formattedSchedule = _formatDayTimeSchedule(originClanTime['day'] ?? '', originClanTime['time'] ?? '');
//   final daysMax = _getValidationDeadlineDays();

//   return Center(
//     child: SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(16), // Changed this line
//         child: Column(
//           children: [
//             Text('━━━━━━━━━━━━━━━━━━━━━━', textAlign: TextAlign.center),
//             Text('📝 خطوات إتمام الحجز', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             Text('━━━━━━━━━━━━━━━━━━━━━━', textAlign: TextAlign.center),
//             SizedBox(height: 20),
//             Text('للحصول على الموافقة النهائية، يجب طباعة الحجز وختمه وتوقيعه من:', textAlign: TextAlign.center),
//             SizedBox(height: 20),
//             Text('⊙ إدارة عشيرتك', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
//             Text(originClanName, textAlign: TextAlign.center),
//             Text('🕐 $formattedSchedule', textAlign: TextAlign.center),
//             SizedBox(height: 20),
//             if (_isCrossClanReservation()) ...[
//               Text('⊙ الدار المضيفة', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
//               Text(_getSelectedClanName(), textAlign: TextAlign.center),
//               Text('🕐 ${_formatDayTimeSchedule(_getClanAcceptanceTime(false)['day'] ?? '', _getClanAcceptanceTime(false)['time'] ?? '')}', textAlign: TextAlign.center),
//               SizedBox(height: 20),
//             ],
//             Text('⊙ الهيئة الدينية', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
//             SizedBox(height: 20),
//             Text('━━━━━━━━━━━━━━━━━━━━━━', textAlign: TextAlign.center),
//             Text('⚠️ تنبيه ', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
//             Text('━━━━━━━━━━━━━━━━━━━━━━', textAlign: TextAlign.center),
//             SizedBox(height: 12),
//             Text('يجب استكمال هذه الإجراءات خلال $daysMax يوم كحد أقصى', textAlign: TextAlign.center),
//             Text('وإلا يُلغى الحجز تلقائياً', textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
//             SizedBox(height: 12),
//             Text('بعد ختم وتوقيع جميع الجهات، توجّه إلى إدارة عشيرتك', textAlign: TextAlign.center),
//             Text(originClanName, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600)),
//             Text('لتؤكد حجزك في النظام', textAlign: TextAlign.center),
//           ],
//         ),
//       ),
//     ),
//   );
// }  



// Future<void> _submitReservation() async {
//   setState(() => _isSubmitting = true);
  
//   Map<String, dynamic>? response;
  
//   try {
//     // NEW: Check if clan admin exists and is active
//     if (_userProfile!['clan_id'] != null) {
//       try {
//         final clanAdminStatus = await ApiService.checkClanAdminStatus();
        
        
//         if (clanAdminStatus['has_admin']==false || clanAdminStatus['is_active']==false ) {
//             if (clanAdminStatus['has_admin']==false) {
//             if (mounted) {
//                 _showMessageDialog(
//                   title: 'عشيرتك ليست في النضام حالياً',
//                   // message:  'يرجى التواصل مع إدارة عشيرتك.',
//                   message: 'عذراً،  ${clanAdminStatus['clan_name']} ليست في النضام حالياً.\n\n'
//                           'يرجى التواصل مع إدارة عشيرتك لمزيد من التفاصيل.',
//                   // message: 'عذراً،  ${clanAdminStatus['clan_name']} غير مشتركة حالياً في التطبيق.\n\n'
//                   //         'يرجى التواصل مع إدارة عشيرتك للانضمام إلى النظام.',
//                   icon: Icons.business_center_outlined,
//                   titleColor: Colors.orange,
//                   isError: true,
//                 );
//               }
//           } else if (clanAdminStatus['is_active']==false) {
//             if (mounted) {
//                 _showMessageDialog(
//                   title: 'التسجيلات متوقفة مؤقتا ',
//                   message: 'التسجيلات متوقفة مؤقتا في ${clanAdminStatus['clan_name']} سيتم فتحها في أقرب وقت.',

//                   icon: Icons.business_center_outlined,
//                   titleColor: Colors.orange,
//                   isError: true,
//                 );
//               }
//           } 
          
//           return;

//         }
        

//       } catch (e) {
//         print('Error checking clan admin status: $e');
//         if (mounted) {
//           _showMessageDialog(
//             title: 'خطأ في التحقق',
//             message: 'حدث خطأ أثناء التحقق من حالة العشيرة.\n\nيرجى المحاولة مرة أخرى.',
//             icon: Icons.error,
//             isError: true,
//           );
//         }
//         return;
//       }
//     }
//     // Prepare the reservation data matching backend expectations
//     final reservationData = {
//       'date1': _date1Controller.text,
//       'date2_bool': _date2Bool,
//       'allow_others': _allowOthers,
//       'join_to_mass_wedding': _joinToMassWedding,
//       'clan_id': _selectedClan!['id'],
//       'hall_id': _selectedHall!['id'],
//       'haia_committee_id': _selectedHaiaCommittee!['id'],
//       'madaeh_committee_id': _selectedMadaehCommittee!['id'],
//     };

//     // Add custom madaeh committee name if provided
//     if (_showCustomMadaehInput && _customMadaehCommitteeController.text.trim().isNotEmpty) {
//       reservationData['custom_madaeh_committee_name'] = _customMadaehCommitteeController.text.trim();
//     }

//     // Add tilawa type
//     if (_selectedTilawaType != null) {
      
//       if (_showCustomTilawaInput && _customTilawaNameController.text.trim().isNotEmpty) {
//         reservationData['tilawa_type'] = _customTilawaNameController.text.trim();
//       }else{
//         reservationData['tilawa_type'] = _selectedTilawaType;
//       }


//     }

//     print('Submitting reservation data: $reservationData');

//     response = await ApiService.createReservation(reservationData);
//     print('Reservation created successfully: ${response['reservation_id']}');

//     if (mounted) {
//       // Navigate to GroomHomeScreen with reservations tab selected
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(
//           builder: (context) => const GroomHomeScreen(initialTabIndex: 2),
//         ),
//       );
      
//       String daysMax = _getValidationDeadlineDays();
//       String successMessage = 
//         'تم إنشاء حجز جديد بنجاح!\n\n'
//         'يجب طباعة الحجز وختمه وتوقيعه خلال $daysMax يوم كأقصى حد، '
//         'وإلا سيتم إلغاء الحجز تلقائيًا.\n\n'
//         'يمكنك الآن الذهاب إلى قائمة الحجوزات لطباعة الحجز.';

//       _showMessageDialog(
//         title: 'تم إنشاء الحجز بنجاح',
//         message: successMessage,
//         icon: Icons.check_circle,
//         titleColor: Colors.green,
//         isError: false,
//       );
//     }
    
//   } on FormatException catch (e) {
//     print('Format error: $e');
//     if (mounted) {
//       _showMessageDialog(
//         title: 'خطأ في التحليل',
//         message: 'خطأ في تحليل استجابة الخادم.\n\nيرجى المحاولة مرة أخرى.',
//         icon: Icons.error_outline,
//         isError: true,
//       );
//     }
//   } catch (e) {
//     print('Error creating reservation: $e');
    
//     String errorStr = e.toString().toLowerCase();
//     if (errorStr.contains('401') || errorStr.contains('unauthorized') || 
//         errorStr.contains('invalid token') || errorStr.contains('token expired')) {
//       if (mounted) {
//         Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
//         _showMessageDialog(
//           title: 'انتهاء الجلسة',
//           message: 'انتهت صلاحية الجلسة.\n\nيرجى تسجيل الدخول مرة أخرى.',
//           icon: Icons.login,
//           isError: true,
//         );
//       }
//       return;
//     }

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
//       String errorTitle = 'خطأ في إرسال الطلب';
//       String errorMessage = 'خطأ في إرسال طلب الحجز';
      
//       if (errorStr.contains('already have an active reservation')) {
//         errorTitle = 'حجز موجود مسبقاً';
//         errorMessage = 'لديك حجز نشط بالفعل.\n\nلا يمكن إنشاء حجز جديد حتى يتم إلغاء أو تأكيد الحجز الحالي.';
//       } else if (errorStr.contains('not allowed in this month')) {
//         errorTitle = 'غير مسموح في هذا الشهر';
//         errorMessage = 'حجز يومين غير مسموح في هذا الشهر.\n\nيرجى اختيار يوم واحد فقط أو اختيار شهر آخر.';
//       } else if (errorStr.contains('already reserved')) {
//         errorTitle = 'التاريخ محجوز';
//         errorMessage = 'التاريخ محجوز بالفعل من قبل شخص آخر.\n\nيرجى اختيار تاريخ آخر.';
//       } else if (errorStr.contains('fully booked')) {
//         errorTitle = 'التاريخ ممتلئ';
//         errorMessage = 'التاريخ ممتلئ بالكامل ولا يمكن إضافة حجوزات جديدة.\n\nيرجى اختيار تاريخ آخر.';
//       } else if (errorStr.contains('pdf')) {
//         errorTitle = 'خطأ في إنشاء PDF';
//         errorMessage = 'خطأ في إنشاء ملف PDF للحجز.\n\nيرجى المحاولة مرة أخرى.';
//       } else if (errorStr.contains('server error') || errorStr.contains('500')) {
//         errorTitle = 'خطأ في الخادم';
//         errorMessage = 'حدث خطأ في الخادم.\n\nيرجى المحاولة لاحقاً أو التواصل مع الدعم الفني.';
//       } else if (errorStr.contains('network') || errorStr.contains('connection')) {
//         errorTitle = 'خطأ في الاتصال';
//         errorMessage = 'خطأ في الاتصال بالإنترنت.\n\nتحقق من اتصالك بالإنترنت وحاول مرة أخرى.';
//       } else {
//         String actualError = e.toString();
//         if (actualError.length > 250) {
//           actualError = actualError.substring(0, 250) + '...';
//         }
//         errorMessage = ' \n\n$actualError\n\n  .';
//       }
      
//       _showMessageDialog(
//         title: errorTitle,
//         message: errorMessage,
//         icon: Icons.error,
//         isError: true,
//       );
//     }
//   } finally {
//     if (mounted) {
//       setState(() => _isSubmitting = false);
//     }
//   }
// }
   
// // Future<void> _submitReservation() async {
// //   setState(() => _isSubmitting = true);
  
// //   Map<String, dynamic>? response;
  
// //   try {
// //     // Prepare the reservation data matching backend expectations
// //     final reservationData = {
// //       'date1': _date1Controller.text,
// //       'date2_bool': _date2Bool,
// //       'allow_others': _allowOthers,
// //       'join_to_mass_wedding': _joinToMassWedding,
// //       'clan_id': _selectedClan!['id'],
// //       'hall_id': _selectedHall!['id'],
// //       'haia_committee_id': _selectedHaiaCommittee!['id'],
// //       'madaeh_committee_id': _selectedMadaehCommittee!['id'],
// //     };

// //     print('Submitting reservation data: $reservationData');

// //     response = await ApiService.createReservation(reservationData);
// //     print('Reservation created successfully: ${response['reservation_id']}');

// //     if (mounted) {
// //       // Navigate to GroomHomeScreen with reservations tab selected
// //       Navigator.of(context).pushReplacement(
// //         MaterialPageRoute(
// //           builder: (context) => const GroomHomeScreen(initialTabIndex: 2),
// //         ),
// //       );
      
// //       String daysMax = _getValidationDeadlineDays();
// //       String successMessage = 
// //         'تم إنشاء حجز جديد بنجاح!\n\n'
// //         'يجب طباعة الحجز وختمه وتوقيعه خلال $daysMax أيام كأقصى حد، '
// //         'وإلا سيتم إلغاء الحجز تلقائيًا.\n\n'
// //         'يمكنك الآن الذهاب إلى قائمة الحجوزات لطباعة الحجز.';

// //       _showMessageDialog(
// //         title: 'تم إنشاء الحجز بنجاح',
// //         message: successMessage,
// //         icon: Icons.check_circle,
// //         titleColor: Colors.green,
// //         isError: false,
// //       );
// //     }
    
// //   } on FormatException catch (e) {
// //     print('Format error: $e');
// //     if (mounted) {
// //       _showMessageDialog(
// //         title: 'خطأ في التحليل',
// //         message: 'خطأ في تحليل استجابة الخادم.\n\nيرجى المحاولة مرة أخرى.',
// //         icon: Icons.error_outline,
// //         isError: true,
// //       );
// //     }
// //   } catch (e) {
// //     print('Error creating reservation: $e');
    
// //     String errorStr = e.toString().toLowerCase();
// //     if (errorStr.contains('401') || errorStr.contains('unauthorized') || 
// //         errorStr.contains('invalid token') || errorStr.contains('token expired')) {
// //       if (mounted) {
// //         Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
// //         _showMessageDialog(
// //           title: 'انتهاء الجلسة',
// //           message: 'انتهت صلاحية الجلسة.\n\nيرجى تسجيل الدخول مرة أخرى.',
// //           icon: Icons.login,
// //           isError: true,
// //         );
// //       }
// //       return;
// //     }

// //     if (response != null && response.containsKey('reservation_id')) {
// //       try {
// //         print('Deleting reservation due to error: ${response['reservation_id']}');
// //         await ApiService.deleteReservation(response['reservation_id']);
// //         print('Reservation deleted successfully');
// //       } catch (deleteError) {
// //         print('Failed to delete reservation: $deleteError');
// //       }
// //     }
    
// //     if (mounted) {
// //       String errorTitle = 'خطأ في إرسال الطلب';
// //       String errorMessage = 'خطأ في إرسال طلب الحجز';
      
// //       if (errorStr.contains('already have an active reservation')) {
// //         errorTitle = 'حجز موجود مسبقاً';
// //         errorMessage = 'لديك حجز نشط بالفعل.\n\nلا يمكن إنشاء حجز جديد حتى يتم إلغاء أو تأكيد الحجز الحالي.';
// //       } else if (errorStr.contains('not allowed in this month')) {
// //         errorTitle = 'غير مسموح في هذا الشهر';
// //         errorMessage = 'حجز يومين غير مسموح في هذا الشهر.\n\nيرجى اختيار يوم واحد فقط أو اختيار شهر آخر.';
// //       } else if (errorStr.contains('already reserved')) {
// //         errorTitle = 'التاريخ محجوز';
// //         errorMessage = 'التاريخ محجوز بالفعل من قبل شخص آخر.\n\nيرجى اختيار تاريخ آخر.';
// //       } else if (errorStr.contains('fully booked')) {
// //         errorTitle = 'التاريخ ممتلئ';
// //         errorMessage = 'التاريخ ممتلئ بالكامل ولا يمكن إضافة حجوزات جديدة.\n\nيرجى اختيار تاريخ آخر.';
// //       } else if (errorStr.contains('pdf')) {
// //         errorTitle = 'خطأ في إنشاء PDF';
// //         errorMessage = 'خطأ في إنشاء ملف PDF للحجز.\n\nيرجى المحاولة مرة أخرى.';
// //       } else if (errorStr.contains('server error') || errorStr.contains('500')) {
// //         errorTitle = 'خطأ في الخادم';
// //         errorMessage = 'حدث خطأ في الخادم.\n\nيرجى المحاولة لاحقاً أو التواصل مع الدعم الفني.';
// //       } else if (errorStr.contains('network') || errorStr.contains('connection')) {
// //         errorTitle = 'خطأ في الاتصال';
// //         errorMessage = 'خطأ في الاتصال بالإنترنت.\n\nتحقق من اتصالك بالإنترنت وحاول مرة أخرى.';
// //       } else {
// //         String actualError = e.toString();
// //         if (actualError.length > 150) {
// //           actualError = actualError.substring(0, 150) + '...';
// //         }
// //         errorMessage = ' \n\n$actualError\n\nيرجى المحاولة مرة أخرى  .';
// //       }
      
// //       _showMessageDialog(
// //         title: errorTitle,
// //         message: errorMessage,
// //         icon: Icons.error,
// //         isError: true,
// //       );
// //     }
// //   } finally {
// //     if (mounted) {
// //       setState(() => _isSubmitting = false);
// //     }
// //   }
// // }

//   // Load clan settings by clan ID
//   Future<void> _loadSettingForClan(int clanId) async {
//     try {
//       final settings = await ApiService.getSettingsByClanId(clanId.toString());
//       setState(() { 
//         _clanSettings = settings;
//         print('--------------Loaded clan settings: $_clanSettings');
//         _maxCapacityPerDate = settings['max_grooms_per_date'] ?? 3;
//         _years_max_reserv_GroomFromOutClan = settings['years_max_reserv_GroomFromOutClan'] ?? 1;
//         _years_max_reserv_GrooomFromOriginClan = settings['years_max_reserv_GrooomFromOriginClan'] ?? 3;
//       });
//     } catch (e) {
//       print('Error loading clan settings: $e');
//       setState(() {
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



// // Future<void> _loadInitialData() async {
// //   setState(() => _isLoading = true);
  
// //   try {
// //     print('Loading user profile...');
// //     final profile = await ApiService.getProfile();
// //     print('Profile loaded: ${profile.runtimeType}');
// //     _userProfile = profile;
    
// //     print('Loading clans for county: ${profile['county_id']}');
// //     final clans = await ApiService.getClansByCounty(profile['county_id']);
// //     print('Clans loaded: ${clans.runtimeType} - ${clans}');
    
// //     print('Loading county info...');
// //     final county_n = await ApiService.getCounty(profile['county_id']);
// //     print('County loaded: ${county_n.runtimeType}');
// //     _selectedCounty = county_n as Map<String, dynamic>?;
    
// //     print('Loading Haia committees...');
// //     final haiaCommittees = await ApiService.getGroomHaia();
// //     print('Haia committees loaded: ${haiaCommittees.runtimeType} - Length: ${haiaCommittees.length}');
    
// //     print('Loading Madaeh committees...');
// //     final madaehCommittees = await ApiService.getGroomMadaihCommittee();
// //     print('Madaeh committees loaded: ${madaehCommittees.runtimeType} - Length: ${madaehCommittees.length}');
    
// //     setState(() {
// //       if (clans is List) {
// //         _clans = clans;
// //       } else {
// //         print('WARNING: clans is not a List, it is: ${clans.runtimeType}');
// //         _clans = [];
// //       }
      
// //       _haiaCommittees = haiaCommittees;
// //       _madaehCommittees = madaehCommittees;
// //     });
    
// //     print('All data loaded successfully');
    
// //   } catch (e, stackTrace) {
// //     print('Error in _loadInitialData: $e');
// //     print('Stack trace: $stackTrace');
// //     if (mounted) {
// //       _showMessageDialog(
// //         title: 'خطأ في تحميل البيانات',
// //         message: 'حدث خطأ أثناء تحميل البيانات الأساسية:\n\n${e.toString()}\n\nيرجى المحاولة مرة أخرى أو التواصل مع الدعم الفني.',
// //         icon: Icons.error,
// //         isError: true,
// //       );
// //     }
// //   } finally {
// //     if (mounted) {
// //       setState(() => _isLoading = false);
// //     }
// //   }
// // }

// Future<void> _loadInitialData() async {
//   await _checkConnectivityAndLoad();
// }

// Future<void> _checkConnectivityAndLoad() async {
//   setState(() => _isLoading = false);
  
//   // Show loading for 2 seconds
//   // await Future.delayed(Duration(seconds: 2));
  
//   final connectivityResult = await Connectivity().checkConnectivity();
  
//   if (connectivityResult.contains(ConnectivityResult.none)) {
//     _showNoInternetDialog();
//     setState(() => _isLoading = false);
//     return;
//   }
  
//   await _loadData();
// }
// // 3. Update _loadData method (add loading state for clans)
// Future<void> _loadData() async {
//   setState(() => _isLoadingClans = true);
  
//   try {
//     print('Loading user profile...');
//     final profile = await ApiService.getProfile();
//     print('Profile loaded: ${profile.runtimeType}');
//     _userProfile = profile;
    
//     print('Loading clans for county: ${profile['county_id']}');
//     final clans = await ApiService.getClansByCounty(profile['county_id']);
//     print('Clans loaded: ${clans.runtimeType} - ${clans}');
    
//     print('Loading county info...');
//     final county_n = await ApiService.getCounty(profile['county_id']);
//     print('County loaded: ${county_n.runtimeType}');
//     _selectedCounty = county_n as Map<String, dynamic>?;
    
//     print('Loading Haia committees...');
//     final haiaCommittees = await ApiService.getGroomHaia();
//     print('Haia committees loaded: ${haiaCommittees.runtimeType} - Length: ${haiaCommittees.length}');
    
//     print('Loading Madaeh committees...');
//     final madaehCommittees = await ApiService.getGroomMadaihCommittee();
//     print('Madaeh committees loaded: ${madaehCommittees.runtimeType} - Length: ${madaehCommittees.length}');
    
//     // setState(() {
//     //   if (clans is List) {
//     //     _clans = clans;
//     //   } else {
//     //     print('WARNING: clans is not a List, it is: ${clans.runtimeType}');
//     //     _clans = [];
//     //   }
      
//     //   _haiaCommittees = haiaCommittees;
//     //   _madaehCommittees = madaehCommittees;
//     //   _isLoadingClans = false;
//     // });
//     setState(() {
//   if (clans is List) {
//     // Sort clans by ID
//     _clans = List<dynamic>.from(clans)
//       ..sort((a, b) {
//         final idA = a['id'] ?? 0;
//         final idB = b['id'] ?? 0;
//         return idA.compareTo(idB);
//       });
//   } else {
//     print('WARNING: clans is not a List, it is: ${clans.runtimeType}');
//     _clans = [];
//   }
  
//   _haiaCommittees = haiaCommittees;
//   _madaehCommittees = madaehCommittees;
//   _isLoadingClans = false;
// });
    
//     print('All data loaded successfully');
    
//   } catch (e, stackTrace) {
//     print('Error in _loadData: $e');
//     print('Stack trace: $stackTrace');
    
//     setState(() => _isLoadingClans = false);
    
//     if (mounted) {
//       _showMessageDialog(
//         title: 'خطأ في تحميل البيانات',
//         message: 'حدث خطأ أثناء تحميل البيانات الأساسية:\n\n${e.toString()}\n\nيرجى المحاولة مرة أخرى أو التواصل مع الدعم الفني.',
//         icon: Icons.error,
//         isError: true,
//       );
//     }
//   } finally {
//     if (mounted) {
//       setState(() => _isLoading = false);
//     }
//   }
// }

// // void _showNoInternetDialog() {
// //   showDialog(
// //     context: context,
// //     barrierDismissible: false,
// //     builder: (context) => AlertDialog(
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
// //       title: Row(
// //         children: [
// //           Icon(Icons.wifi_off, color: Colors.orange),
// //           SizedBox(width: 10),
// //           Text('لا يوجد اتصال'),
// //         ],
// //       ),
// //       content: Text('يرجى التحقق من اتصالك بالإنترنت'),
// //       actions: [
// //         TextButton(
// //           onPressed: () => Navigator.pop(context),
// //           child: Text('إلغاء'),
// //         ),
// //         ElevatedButton(
// //           onPressed: () {
// //             Navigator.pop(context);
// //             _checkConnectivityAndLoad();
// //           },
// //           style: ElevatedButton.styleFrom(
// //             backgroundColor: AppColors.primary,
// //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //           ),
// //           child: Text('إعادة المحاولة', style: TextStyle(color: Colors.white)),
// //         ),
// //       ],
// //     ),
// //   );
// // }

// void _showNoInternetDialog() {
//   if (!mounted) return;
  
//   showDialog(
//     context: context,
//     barrierDismissible: true,
//     builder: (context) => AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       contentPadding: const EdgeInsets.all(24),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Icon Container
//           Container(
//             width: 70,
//             height: 70,
//             decoration: BoxDecoration(
//               color: Colors.orange.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.wifi_off_rounded,
//               color: Colors.orange,
//               size: 36,
//             ),
//           ),
//           const SizedBox(height: 20),
          
//           // Title
//           const Text(
//             'لا يوجد اتصال بالإنترنت',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 10),
          
//           // Description
//           Text(
//             'يرجى التحقق من اتصالك بالإنترنت',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[600],
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
          
//           // Buttons
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text('إغلاق'),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                     _checkConnectivityAndLoad();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text('إعادة المحاولة'),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//   );
// }



// Future<void> _loadHallsForClan(int clanId) async {
//   setState(() => _isLoadingHalls = true);
  
//   try {
//     final halls = await ApiService.getHallsByClan(clanId);
//     setState(() {
//       _halls = halls;
//       _selectedHall = null;
//       _isLoadingHalls = false;
//     });
//   } catch (e) {
//     setState(() => _isLoadingHalls = false);
    
//     if (mounted) {
//       _showMessageDialog(
//         title: 'خطأ في تحميل القاعات',
//         message: 'حدث خطأ أثناء تحميل قاعات العشيرة المختارة:\n\n${e.toString()}\n\nيرجى المحاولة مرة أخرى.',
//         icon: Icons.error,
//         isError: true,
//       );
//     }
//   }
// }

// Future<void> _selectDate(TextEditingController controller, String title) async {
//   if (_selectedClan == null || _selectedHall == null) {
//     _showMessageDialog(
//       title: 'معلومات ناقصة',
//       message: 'يرجى اختيار العشيرة والقاعة أولاً قبل تحديد التاريخ.',
//       icon: Icons.warning,
//       titleColor: Colors.orange,
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
    
//     if (Navigator.canPop(context)) {
//       Navigator.of(context).pop();
//     }

//     if (mounted) {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => BeautifulCustomCalendarPicker(

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
//             // In the _selectDate method, update the switch statement:

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
//                     _showMessageDialog(
//                       title: 'التاريخ غير متاح',
//                       message: 'هذا التاريخ في انتظار التأكيد ولا يسمح بالانضمام.\n\nيرجى اختيار تاريخ آخر.',
//                       icon: Icons.pending,
//                       titleColor: Colors.orange,
//                     );
//                   }
//                   break;
//                 case DateStatus.specialReservation: // ADD THIS CASE
//                   _handleSpecialReservationDate(selectedDate, availability, controller);
//                   break;
//                 case DateStatus.reserved:
//                   _showMessageDialog(
//                     title: 'التاريخ محجوز',
//                     message: 'هذا التاريخ محجوز بالفعل.\n\nيرجى اختيار تاريخ آخر.',
//                     icon: Icons.event_busy,
//                     isError: true,
//                   );
//                   break;
//                 case DateStatus.disabled:
//                   _showMessageDialog(
//                     title: 'التاريخ غير متاح',
//                     message: 'هذا التاريخ غير متاح للحجز.\n\nيرجى اختيار تاريخ آخر.',
//                     icon: Icons.block,
//                     isError: true,
//                   );
//                   break;
//               }
//             }
            
//           },
//           onCancel: () {
//             Navigator.of(context).pop();
//           },
//           isOriginClan: _isOriginClan, // or false based on your logic
//           yearsMaxReservGroomFromOriginClan: _years_max_reserv_GrooomFromOriginClan ,
//           yearsMaxReservGroomFromOutClan: _years_max_reserv_GroomFromOutClan ,
//         ),
//       );
//     }

//   } catch (e) {
//     if (Navigator.canPop(context)) {
//       Navigator.of(context).pop();
//     }
    
//     print('Error loading calendar: $e');
    
//     if (mounted) {
//       _showMessageDialog(
//         title: 'خطأ في تحميل التقويم',
//         message: 'خطأ في تحميل التقويم:\n\n$e\n\nسيتم فتح منتقي التاريخ البديل.',
//         icon: Icons.calendar_today,
//         isError: true,
//       );

//       _showFallbackDatePicker(controller, title);
//     }
//   }
// }

//   // Updated _onClanSelected method to load settings
//   void _onClanSelected(Map<String, dynamic>? clan) {
//     setState(() {
//       _selectedClan = clan;
//       _selectedHall = null;
//       _halls.clear();
//       _clanSettings = null;

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


// // @override
// // Widget build(BuildContext context) {
// //   final isDark = Theme.of(context).brightness == Brightness.dark;
  
// //   if (_isLoading) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('إنشاء حجز جديد'),
// //         backgroundColor: isDark ? AppColors.darkBackground : AppColors.primary,
// //         foregroundColor: Colors.white,
// //       ),
// //       body: Center(
// //         child: CircularProgressIndicator(
// //           color: isDark ? AppColors.darkPrimary : AppColors.primary,
// //         ),
// //       ),
// //     );
// //   }

// //   return Scaffold(
// //     backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
// //     body: Stack(
// //   children: [
// //     Column(
// //       children: [
// //         Padding(
// //           padding: const EdgeInsets.all(16.0),
// //           child: Row(
// //             children: [
// //               for (int i = 0; i < 3; i++) ...[
// //                 Expanded(
// //                   child: Container(
// //                     height: 4,
// //                     decoration: BoxDecoration(
// //                       color: i <= _currentStep 
// //                         ? (isDark ? AppColors.darkPrimary : const Color.fromARGB(255, 0, 151, 98))
// //                         : (isDark 
// //                             ? AppColors.darkPrimary.withOpacity(0.3)
// //                             : const Color.fromARGB(255, 110, 174, 122).withOpacity(0.3)),
// //                       borderRadius: BorderRadius.circular(2),
// //                     ),
// //                   ),
// //                 ),
// //                 if (i < 2) const SizedBox(width: 8),
// //               ],
// //             ],
// //           ),
// //         ),
// //         Expanded(
// //           child: RefreshIndicator(
// //             onRefresh: _refreshData,
// //             color: AppColors.primary,
// //             backgroundColor: Colors.white,
// //             child: Form(
// //               key: _formKey,
// //               child: PageView(
// //                 controller: _pageController,
// //                 onPageChanged: (index) => setState(() => _currentStep = index),
// //                 children: [
// //                   _buildClanAndHallSelectionStep(),
// //                   _buildReservationDetailsStep(),
// //                   _buildConfirmationStep(),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ],
// //     ),
// //     // Changed from _buildSideNavigation to _buildBottomNavigation
// //     // if (_buildBottomNavigation() != null) _buildBottomNavigation()!,
// //   ],
// // ),
    
// //   );
  
// // }
// @override
// Widget build(BuildContext context) {
//   final isDark = Theme.of(context).brightness == Brightness.dark;
  
//   if (_isLoading) {
//     return PopScope(
//       canPop: false,
//       onPopInvokedWithResult: (bool didPop, dynamic result) {
//         // Do nothing - blocks back navigation during loading
//         return;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('إنشاء حجز جديد'),
//           backgroundColor: isDark ? AppColors.darkBackground : AppColors.primary,
//           foregroundColor: Colors.white,
//           automaticallyImplyLeading: false, // No back button
//         ),
//         body: Center(
//           child: CircularProgressIndicator(
//             color: isDark ? AppColors.darkPrimary : AppColors.primary,
//           ),
//         ),
//       ),
//     );
//   }

//   return PopScope(
//     canPop: false, // Prevents back navigation
//     onPopInvokedWithResult: (bool didPop, dynamic result) {
//       // Do nothing - completely blocks all back button attempts
//       return;
//     },
//     child: Scaffold(
//       backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
//       body: Column(
//         children: [
//           // Progress indicator
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
//                           ? (isDark ? AppColors.darkPrimary : const Color.fromARGB(255, 0, 151, 98))
//                           : (isDark 
//                               ? AppColors.darkPrimary.withOpacity(0.3)
//                               : const Color.fromARGB(255, 110, 174, 122).withOpacity(0.3)),
//                         borderRadius: BorderRadius.circular(2),
//                       ),
//                     ),
//                   ),
//                   if (i < 2) const SizedBox(width: 8),
//                 ],
//               ],
//             ),
//           ),
          
//           // Main content
//           Expanded(
//             child: RefreshIndicator(
//               onRefresh: _refreshData,
//               color: AppColors.primary,
//               backgroundColor: Colors.white,
//               child: Form(
//                 key: _formKey,
//                 child: PageView(
//                   controller: _pageController,
//                   onPageChanged: (index) => setState(() => _currentStep = index),
//                   children: [
//                     _buildClanAndHallSelectionStep(),
//                     _buildReservationDetailsStep(),
//                     _buildConfirmationStep(),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }


// Widget _buildClanAndHallSelectionStep() {
//   final isDark = Theme.of(context).brightness == Brightness.dark;
  
//   return SingleChildScrollView(
//     physics: const AlwaysScrollableScrollPhysics(),
//     padding: const EdgeInsets.all(16),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'اختيار دار إقامة العرس',
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: isDark ? AppColors.darkPrimary : AppColors.primary,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Row(
//           children: [
//             Expanded(
//               child: Text(
//                 'اختر العشيرة والقاعة المناسبة لحفلك\nالقصر: ${_userProfile?['county_name'] ?? 'غير محدد'}',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
//                 ),
//               ),
//             ),
//             IconButton(
//               onPressed: _refreshData,
//               icon: Icon(
//                 Icons.refresh, 
//                 color: isDark ? AppColors.darkPrimary : AppColors.primary,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 24),
        
//         // Rest of your existing clan and hall selection code...
//         // (Keep all existing content in this method)
        
//         // Clan Selection
        
// DropdownButtonFormField<Map<String, dynamic>>(
//   value: _selectedClan,
//   isExpanded: true,
//   decoration: InputDecoration(
//     labelText: 'العشيرة *',
//     prefixIcon: const Icon(Icons.group),
//     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//     helperText: 'العشائر المتاحة في قصرك',
//   ),
//   // items: _clans.map((clan) {
//   //   return DropdownMenuItem<Map<String, dynamic>>(
//   //     value: clan,
//   //     child: LayoutBuilder(
//   //       builder: (context, constraints) {
//   //         return SizedBox(
//   //           width: constraints.maxWidth,
//   //           child: Text(
//   //             clan['name']?.toString() ?? 'عشيرة غير مسماة',
//   //             style: const TextStyle(fontWeight: FontWeight.bold),
//   //             overflow: TextOverflow.ellipsis,
//   //             maxLines: 1,
//   //           ),
//   //         );
//   //       },
//   //     ),
//   //   );
//   // }).toList(),
//   items: (_clans..sort((a, b) {
//   final idA = a['id'] ?? 0;
//   final idB = b['id'] ?? 0;
//   return idA.compareTo(idB);
// })).map((clan) {
//   return DropdownMenuItem<Map<String, dynamic>>(
//     value: clan,
//     child: LayoutBuilder(
//       builder: (context, constraints) {
//         return SizedBox(
//           width: constraints.maxWidth,
//           child: Text(
//             clan['name']?.toString() ?? 'عشيرة غير مسماة',
//             style: const TextStyle(fontWeight: FontWeight.bold),
//             overflow: TextOverflow.ellipsis,
//             maxLines: 1,
//           ),
//         );
//       },
//     ),
//   );
// }).toList(),
//   onChanged: _onClanSelected,
//   validator: (value) => value == null ? 'العشيرة مطلوبة' : null,
//   icon: _isLoadingClans 
//       ? SizedBox(
//           width: 20,
//           height: 20,
//           child: CircularProgressIndicator(
//             strokeWidth: 2.5,
//             valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
//           ),
//         )
//       : const Icon(Icons.keyboard_arrow_down),
// ),

// const SizedBox(height: 24),

// // 5. Updated Hall Dropdown with loading icon
// if (_selectedClan != null) ...[
//   DropdownButtonFormField<Map<String, dynamic>>(
//     value: _selectedHall,
//     isExpanded: true,
//     decoration: InputDecoration(
//       labelText: 'القاعة *',
//       prefixIcon: const Icon(Icons.business),
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//       helperText: _halls.isEmpty ? 'لا توجد قاعات متاحة لهذه العشيرة' : 'القاعات المتاحة للعشيرة المختارة',
//     ),
//     selectedItemBuilder: (BuildContext context) {
//       return _halls.map<Widget>((hall) {
//         return LayoutBuilder(
//           builder: (context, constraints) {
//             return SizedBox(
//               width: constraints.maxWidth,
//               child: Text(
//                 hall['name']?.toString() ?? 'قاعة غير مسماة',
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//                 overflow: TextOverflow.ellipsis,
//                 maxLines: 1,
//               ),
//             );
//           },
//         );
//       }).toList();
//     },
//     items: _halls.map((hall) {
//       return DropdownMenuItem<Map<String, dynamic>>(
//         value: hall,
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return SizedBox(
//               width: constraints.maxWidth,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     hall['name']?.toString() ?? 'قاعة غير مسماة',
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                   ),
//                   Text(
//                     'السعة: ${hall['capacity']} شخص',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: AppColors.textSecondary,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       );
//     }).toList(),
//     onChanged: (value) => setState(() => _selectedHall = value),
//     validator: (value) => value == null ? 'القاعة مطلوبة' : null,
//     icon: _isLoadingHalls 
//         ? SizedBox(
//             width: 20,
//             height: 20,
//             child: CircularProgressIndicator(
//               strokeWidth: 2.5,
//               valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
//             ),
//           )
//         : const Icon(Icons.keyboard_arrow_down),
//   ),
// ],
        
//         const SizedBox(height: 24),
        
//         // Clan Information Display
//         // In _buildClanAndHallSelectionStep, update the card:
//         if (_selectedClan != null) ...[
//           Card(
//             color: isDark ? AppColors.darkCard : Colors.white,
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
//                       color: isDark ? AppColors.darkPrimary : AppColors.primary,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   _buildInfoRow('اسم العشيرة', _selectedClan!['name']?.toString() ?? '',isDark),
//                   _buildInfoRow('القصر', _selectedCounty!['name']?.toString() ?? '',isDark),
//                   if (_selectedClan!['description'] != null)
//                     _buildInfoRow('الوصف', _selectedClan!['description'].toString(),isDark),
//                 ],
//               ),
//             ),
//           ),
//           _buildIsNormal(),
//         ],
//         const SizedBox(height: 24),
//         _buildBottomNavigation(),
//         const SizedBox(height: 16), // Extra padding at bottom
//       ],
//     ),
//   );
// }

// // Fix for _buildIsNormal() - Change from async Widget to FutureBuilder
// Widget _buildIsNormal() {
//   if (_selectedClan == null || _selectedHall ==null) {
//     return const SizedBox.shrink();
//   }
//   if (_selectedClan!['id'] == 24 ) {
//       return const SizedBox.shrink();
//     }
//   return FutureBuilder<Map<String, dynamic>>(
//     future: ApiService.checkClanAdminStatusById(_selectedClan!['id']),
//     builder: (context, snapshot) {
//       if (snapshot.connectionState == ConnectionState.waiting) {
//         return const Center(
//           child: Padding(
//             padding: EdgeInsets.all(16.0),
//             child: CircularProgressIndicator(),
//           ),
//         );
//       }
      
//       if (snapshot.hasError) {
//         return const SizedBox.shrink();
//       }
      
//       final clanAdminStatus = snapshot.data;
      
//       if (clanAdminStatus != null &&
//           (clanAdminStatus['has_admin'] == false || 
//            clanAdminStatus['is_active'] == false)) {
//         return _buildCheckClanIsActiveWidget();
//       }
      
//       return const SizedBox.shrink();
//     },
//   );
// }
// Widget _buildCheckClanIsActiveWidget() {
//   String clan_name = _selectedClan!['name']?.toString() ?? '';
//   return Center(
//     child: SingleChildScrollView(
//       child: Container(
//         margin: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: Colors.red,
//             width: 3,
//           ),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               // const Text('━━━━━━━━━━━━━━━━━━━━━━', textAlign: TextAlign.center),
//               const Text(
//                 '⚠️ تنبيه ',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.orange,
//                 ),
//               ),
//               // const Text('━━━━━━━━━━━━━━━━━━━━━━', textAlign: TextAlign.center),
//               // const Text(
//               //   'دار العشيرة المختار لإقامة العرس فيها ليست في النظام حاليا',
//               //   textAlign: TextAlign.center,
//               //   style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
//               // ),
//               // const Text('━━━━━━━━━━━━━━━━━━━━━━', textAlign: TextAlign.center),
//               const SizedBox(height: 20),
//               Text(
//                  '  ستدخل $clan_name إلى النضام قريبا ',
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 'يمكنك متابعة الحجز لكن يجب عليك التأكد من اليوم المختار إذ هو متاح في $clan_name  لإقامة العرس بعد إتمام الحجز  ',
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }

// Widget _buildReservationDetailsStep() {
//   final isDark = Theme.of(context).brightness == Brightness.dark;
  
//   return SingleChildScrollView(
//     physics: const AlwaysScrollableScrollPhysics(),
//     padding: const EdgeInsets.fromLTRB(16, 16, 16, 150), // Changed this line
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'معلومات الحجز',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: isDark ? AppColors.darkPrimary : AppColors.primary,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             IconButton(
//               onPressed: _refreshData,
//               icon: Icon(
//                 Icons.refresh, 
//                 color: isDark ? AppColors.darkPrimary : AppColors.primary,
//               ),
//               tooltip: 'تحديث البيانات',
//             ),
//           ],
//         ),
//         const SizedBox(height: 24),
        
//         // Rest of your existing reservation details code...
//         // (Keep all existing content for this step)
        
//         // Primary Date
//         TextFormField(
//           controller: _date1Controller,
//           readOnly: true,
          
//           onTap: () => _selectDate(_date1Controller, 'تاريخ الحجز'),
//           decoration: InputDecoration(
            
//             labelText: 'تاريخ الحجز *',
//             prefixIcon: const Icon(Icons.calendar_today),
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             suffixIcon: const Icon(Icons.arrow_drop_down),
//             helperText: 'اختر تاريخ حفل التتويج',
//           ),
//           validator: (value) => value?.isEmpty == true ? 'التاريخ مطلوب' : null,
//         ),
        
//         const SizedBox(height: 16),
        
//         // Two day option - Updated logic
//         if (_date1Controller.text.isNotEmpty) ...[
//           // Check if two days are allowed for the selected date
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
//                     'هل تريد حجز يومين (اقامة أمنسي الوزران في نفس العشيرة)؟',
//                     style: TextStyle(
//                       color: Colors.green[700],
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
            
//             const SizedBox(height: 8),
            
//             // Info message for two days option
//             // Update the two-day availability containers:
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: isDark 
//                       ? Colors.green.withOpacity(0.2) 
//                       : Colors.green[50],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(
//                     color: isDark 
//                         ? Colors.green.withOpacity(0.5) 
//                         : Colors.green[200]!,
//                   ),
//                 ),
//                 child: Row(
//                 children: [
//                   Icon(
//                     Icons.info, 
//                     color: isDark ? Colors.green[300] : Colors.green[600],
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       _getSelectedMonthName() != null 
//                         ? 'العشيرة تسمح بحجز يومين متتاليين (اقامة أمنسي الوزران في نفس العشيرة) لشهر ${_getSelectedMonthName()}. '
//                         : 'العشيرة تسمح ب إقامة أمنسي الوزران في نفس العشيرة لهذا الشهر. ',
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
//                       _getSelectedMonthName() != null 
//                         ? '  يمكنك حجز اليوم الثاني لإقامة أمنسي الوزران عند إقتراب العرس ليس الآن'
//                         : 'يمكنك حجز اليوم الثاني لإقامة أمنسي الوزران عند إقتراب العرس ليس الآن',
//                       style: TextStyle(color: Colors.orange[700]),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ] else ...[
//           // Message when no date is selected
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.grey[100],
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.grey[300]!),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.calendar_month, color: Colors.grey[600]),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     'اختر التاريخ أولاً لمعرفة إمكانية اقامة أمنسي الوزران في نفس العشيرة.',
//                     style: TextStyle(color: Colors.grey[600]),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
        
//         const SizedBox(height: 24),
        
//         // // Haia Committee Selection
//         // DropdownButtonFormField<Map<String, dynamic>>(
//         //   value: _selectedHaiaCommittee,
//         //   decoration: InputDecoration(
//         //     labelText: ' الهيئة *',
//         //     prefixIcon: const Icon(Icons.group),
//         //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//         //     helperText: 'اختر الهيئة الدينية',
//         //   ),
//         //   items: _haiaCommittees.map((committee) {
//         //     return DropdownMenuItem<Map<String, dynamic>>(
//         //       value: committee,
//         //       child: Column(
//         //         crossAxisAlignment: CrossAxisAlignment.start,
//         //         mainAxisSize: MainAxisSize.min,
//         //         children: [
//         //           Text(
//         //             committee['name']?.toString() ?? 'لجنة غير مسماة',
//         //             style: const TextStyle(fontWeight: FontWeight.bold),
//         //           ),
//         //           if (committee['description'] != null)
//         //             Text(
//         //               committee['description'].toString(),
//         //               style: TextStyle(
//         //                 fontSize: 12,
//         //                 color: AppColors.textSecondary,
//         //               ),
//         //               maxLines: 1,
//         //               overflow: TextOverflow.ellipsis,
//         //             ),
//         //         ],
//         //       ),
//         //     );
//         //   }).toList(),
//         //   onChanged: (value) => setState(() => _selectedHaiaCommittee = value),
//         //   validator: (value) => value == null ? ' الهيئة مطلوبة' : null,
//         // ),

//                 // Haia Committee Selection
//         DropdownButtonFormField<Map<String, dynamic>>(
//           value: _selectedHaiaCommittee,
//           decoration: InputDecoration(
//             labelText: ' الهيئة *',
//             prefixIcon: const Icon(Icons.group),
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             helperText: 'اختر الهيئة الدينية',
//           ),
//           isExpanded: true,
//           selectedItemBuilder: (BuildContext context) {
//             return _haiaCommittees.map<Widget>((committee) {
//               return Text(
//                 committee['name']?.toString() ?? 'لجنة غير مسماة',
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//                 overflow: TextOverflow.ellipsis,
//                 maxLines: 1,
//               );
//             }).toList();
//           },
//           items: _haiaCommittees.map((committee) {
//             return DropdownMenuItem<Map<String, dynamic>>(
//               value: committee,
//               child: LayoutBuilder(
//                 builder: (context, constraints) {
//                   return SizedBox(
//                     width: constraints.maxWidth,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           committee['name']?.toString() ?? 'لجنة غير مسماة',
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 1,
//                         ),
//                         if (committee['description'] != null) ...[
//                           const SizedBox(height: 2),
//                           Text(
//                             committee['description'].toString(),
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: AppColors.textSecondary,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ],
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             );
//           }).toList(),
//           onChanged: (value) => setState(() => _selectedHaiaCommittee = value),
//           validator: (value) => value == null ? ' الهيئة مطلوبة' : null,
//         ),

//         const SizedBox(height: 16),

//         // Tilawa Type Selection
//         DropdownButtonFormField<String>(
//           value: _selectedTilawaType,
//           decoration: InputDecoration(
//             labelText: 'نوع التلاوة *',
//             prefixIcon: const Icon(Icons.book_outlined),
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             helperText: 'اختر نوع التلاوة',
//           ),
//           items: const [
//             DropdownMenuItem<String>(
//               value: 'تلاوة جماعية',
//               child: Text(
//                 'تلاوة جماعية',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//             DropdownMenuItem<String>(
//               value: 'تلاوة فردية',
//               child: Text(
//                 'تلاوة فردية',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//           ],
//           onChanged: (value) {
//             setState(() {
//               _selectedTilawaType = value;
//               // Check if "تلاوة فردية" is selected
//               _showCustomTilawaInput = value == 'تلاوة فردية';
//               // Clear the custom input if switching away from "تلاوة فردية"
//               if (!_showCustomTilawaInput) {
//                 _customTilawaNameController.clear();
//               }
//             });
//           },
//           validator: (value) => value == null ? 'نوع التلاوة مطلوب' : null,
//         ),

//         const SizedBox(height: 16),

//         // Custom Tilawa Name Input (shown when "تلاوة فردية" is selected)
//         if (_showCustomTilawaInput) ...[
//           TextFormField(
//             controller: _customTilawaNameController,
//             decoration: InputDecoration(
//               labelText: 'اسم القارئ (اختياري)',
//               prefixIcon: const Icon(Icons.person_outline),
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               helperText: 'أدخل اسم القارئ إن وجد',
//               helperMaxLines: 2,
//             ),
//             maxLength: 300,

//           ),
//           const SizedBox(height: 16),
//         ],


//         const SizedBox(height: 16),

//         // // Madaeh Committee Selection
//         // DropdownButtonFormField<Map<String, dynamic>>(
//         //   value: _selectedMadaehCommittee,
//         //   decoration: InputDecoration(
//         //     labelText: ' اللجنة *',
//         //     prefixIcon: const Icon(Icons.group_outlined),
//         //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//         //     helperText: 'اختر لجنة المدائح و الانشاد ',
//         //   ),
//         //   items: _madaehCommittees.map((committee) {
//         //     return DropdownMenuItem<Map<String, dynamic>>(
//         //       value: committee,
//         //       child: Column(
//         //         crossAxisAlignment: CrossAxisAlignment.start,
//         //         mainAxisSize: MainAxisSize.min,
//         //         children: [
//         //           Text(
//         //             committee['name']?.toString() ?? 'لجنة غير مسماة',
//         //             style: const TextStyle(fontWeight: FontWeight.bold),
//         //           ),
//         //           if (committee['description'] != null)
//         //             Text(
//         //               committee['description'].toString(),
//         //               style: TextStyle(
//         //                 fontSize: 12,
//         //                 color: AppColors.textSecondary,
//         //               ),
//         //               maxLines: 1,
//         //               overflow: TextOverflow.ellipsis,
//         //             ),
//         //         ],
//         //       ),
//         //     );
//         //   }).toList(),
//         //   onChanged: (value) {
//         //     setState(() {
//         //       _selectedMadaehCommittee = value;
//         //       // Check if "لجنة خاصة" is selected
//         //       _showCustomMadaehInput = value?['name']?.toString() == 'لجنة خاصة';
//         //       // Clear the custom input if switching away from "لجنة خاصة"
//         //       if (!_showCustomMadaehInput) {
//         //         _customMadaehCommitteeController.clear();
//         //       }
//         //     });
//         //   },
//         //   validator: (value) => value == null ? 'لجنة المدائح و الانشاد مطلوبة' : null,
//         // ),

//         // Madaeh Committee Selection
//         DropdownButtonFormField<Map<String, dynamic>>(
//           value: _selectedMadaehCommittee,
//           decoration: InputDecoration(
//             labelText: ' اللجنة *',
//             prefixIcon: const Icon(Icons.group_outlined),
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             helperText: 'اختر لجنة المدائح و الانشاد ',
//           ),
//           isExpanded: true,
//           selectedItemBuilder: (BuildContext context) {
//             return _madaehCommittees.map<Widget>((committee) {
//               return Text(
//                 committee['name']?.toString() ?? 'لجنة غير مسماة',
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//                 overflow: TextOverflow.ellipsis,
//                 maxLines: 1,
//               );
//             }).toList();
//           },
//           items: _madaehCommittees.map((committee) {
//             return DropdownMenuItem<Map<String, dynamic>>(
//               value: committee,
//               child: LayoutBuilder(
//                 builder: (context, constraints) {
//                   return SizedBox(
//                     width: constraints.maxWidth,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           committee['name']?.toString() ?? 'لجنة غير مسماة',
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 1,
//                         ),
//                         if (committee['description'] != null) ...[
//                           const SizedBox(height: 2),
//                           Text(
//                             committee['description'].toString(),
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: AppColors.textSecondary,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ],
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             );
//           }).toList(),
//           onChanged: (value) {
//             setState(() {
//               _selectedMadaehCommittee = value;
//               _showCustomMadaehInput = value?['name']?.toString() == ' لجنة خاصة';
//               if (!_showCustomMadaehInput) {
//                 _customMadaehCommitteeController.clear();
//               }
//             });
//           },
//           validator: (value) => value == null ? 'لجنة المدائح و الانشاد مطلوبة' : null,
//         ),
//         // Add this spacing and conditional custom input field
//         const SizedBox(height: 16),

//         // Custom Madaeh Committee Input (shown when "لجنة خاصة" is selected)
//         if (_showCustomMadaehInput) ...[
//           TextFormField(
//             controller: _customMadaehCommitteeController,
//             decoration: InputDecoration(
//               labelText: 'اسم اللجنة الخاصة (اختياري)',
//               prefixIcon: const Icon(Icons.edit),
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               helperText: 'أدخل اسم اللجنة الخاصة إن وجد',
//               helperMaxLines: 2,
//             ),
//             maxLength: 100,
//             // Optional: Add validation if you want to make it required
//             // validator: (value) {
//             //   if (_showCustomMadaehInput && (value == null || value.trim().isEmpty)) {
//             //     return 'يرجى إدخال اسم اللجنة الخاصة';
//             //   }
//             //   return null;
//             // },
//           ),
//           const SizedBox(height: 16),
//         ],
        
//         // const SizedBox(height: 24),
        
//         // // Options
//         // Card(
//         //   child: Padding(
//         //     padding: const EdgeInsets.all(16),
//         //     child: Column(
//         //       crossAxisAlignment: CrossAxisAlignment.start,
//         //       children: [
//         //         const Text(
//         //           'خيارات الحجز',
//         //           style: TextStyle(
//         //             fontSize: 16,
//         //             fontWeight: FontWeight.bold,
//         //             color: AppColors.primary,
//         //           ),
//         //         ),
//         //         const SizedBox(height: 12),
                
//         //         SwitchListTile(
//         //           // title: const Text('السماح للآخرين بالانضمام'),
//         //           title: const Text('هل يمكن السماح للآخرين بالانضمام الىعرسكم (عرس جماعي , على الأكثر 3 ) ؟'),
//         //           // subtitle: const Text('هل تسمح للآخرين بالانضمام الى العرس ؟'),
//         //           value: _allowOthers,
//         //           onChanged: (value) => setState(() => _allowOthers = value),
//         //           contentPadding: EdgeInsets.zero,
//         //         ),
                
//         //         // SwitchListTile(
//         //         //   // title: const Text('الانضمام لعرس جماعي'),
//         //         //   title: const Text('هل تريد الانضمام الى العرس الجماعي؟'),
//         //         //   // subtitle: const Text('هل تريد الانضمام الى العرس الجماعي ؟'),
//         //         //   value: _joinToMassWedding,
//         //         //   onChanged: (value) => setState(() => _joinToMassWedding = value),
//         //         //   contentPadding: EdgeInsets.zero,
//         //         // ),
//         //       ],
//         //     ),
//         //   ),
//         // ),

//         const SizedBox(height: 24),

//         // Options
//         Card(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'عرس  جماعي  ',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.primary,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
                
//                 // Question text
//                 const Text(
//                   'هل يمكن السماح للآخرين بالانضمام إلى عرسكم (عرس جماعي، على الأكثر 3)؟',
//                   style: TextStyle(fontSize: 18),
//                 ),
//                 const SizedBox(height: 12),
                
//                 // Yes/No buttons
//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton(
//                         onPressed: () => setState(() => _allowOthers = true),
//                         style: OutlinedButton.styleFrom(
//                           backgroundColor: _allowOthers ? AppColors.primary : Colors.transparent,
//                           foregroundColor: _allowOthers ? Colors.white : AppColors.primary,
//                           side: BorderSide(color: AppColors.primary),
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                         ),
//                         child: const Text('نعم'),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: OutlinedButton(
//                         onPressed: () => setState(() => _allowOthers = false),
//                         style: OutlinedButton.styleFrom(
//                           backgroundColor: !_allowOthers ? AppColors.primary : Colors.transparent,
//                           foregroundColor: !_allowOthers ? Colors.white : AppColors.primary,
//                           side: BorderSide(color: AppColors.primary),
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                         ),
//                         child: const Text('لا'),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 24),
//         _buildBottomNavigation(),
//         const SizedBox(height: 16), // Extra padding at bottom
//       ],
//     ),
//   );
// }

// Widget _buildConfirmationStep() {
//   return SingleChildScrollView(
//     physics: const AlwaysScrollableScrollPhysics(),
//     padding: const EdgeInsets.all(16),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'مراجعة وتأكيد الحجز',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.primary,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     'راجع تفاصيل حجزك قبل التأكيد',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             IconButton(
//               onPressed: _refreshData,
//               icon: const Icon(Icons.refresh, color: AppColors.primary),
//               tooltip: 'تحديث البيانات',
//             ),
//           ],
//         ),
//         const SizedBox(height: 24),
        
//         // Rest of your existing confirmation content...
//         // (Keep all existing content for this step)
        
//         // gardian Information Summary
//         _buildSummaryCard('معلومات ولي العريس', [
//           _buildSummaryItem(' الاسم الكامل', '${_userProfile?['guardian_name'] ?? 'غير محدد'}'),
//           _buildSummaryItem('رقم الهاتف', _userProfile?['guardian_phone']?.toString() ?? 'غير محدد'),
//           ]),
        
//         const SizedBox(height: 16),
//         // User Information Summary
//         _buildSummaryCard('معلومات العريس', [
//           _buildSummaryItem('الاسم الكامل', '${_userProfile?['first_name'] ?? ''} ${_userProfile?['last_name'] ?? ''}'),
//           _buildSummaryItem('رقم الهاتف', _userProfile?['phone_number']?.toString() ?? ''),
//           _buildSummaryItem('العشيرة', _userProfile?['clan_name']?.toString() ?? 'غير محدد'),        
//           _buildSummaryItem('القصر', _userProfile?['county_name']?.toString() ?? 'غير محدد'),        
//           ]),
        
//         const SizedBox(height: 16),
        
//         // Selection Summary
//         // Selection Summary
//         _buildSummaryCard('تفاصيل الحجز', [
//           _buildSummaryItem('التاريخ المحدد', _date1Controller.text),
//           if (_selectedClan != null)
//             _buildSummaryItem('العشيرة', _selectedClan!['name']?.toString() ?? ''),
//           if (_selectedHall != null)
//             _buildSummaryItem('القاعة', _selectedHall!['name']?.toString() ?? ''),
//           if (_selectedHaiaCommittee != null)
//             _buildSummaryItem('الهيئة الدينية', _selectedHaiaCommittee!['name']?.toString() ?? ''),
//           if (_selectedMadaehCommittee != null) ...[
//             _buildSummaryItem('لجنة المدائح و الانشاد', _selectedMadaehCommittee!['name']?.toString() ?? ''),
//             // Show custom committee name if provided
//             if (_showCustomMadaehInput && _customMadaehCommitteeController.text.trim().isNotEmpty)
//               _buildSummaryItem('  ↳ اسم اللجنة الخاصة', _customMadaehCommitteeController.text.trim()),
//           ],
//           // Add tilawa type summary
//           if (_selectedTilawaType != null) ...[
//             _buildSummaryItem(
//               'نوع التلاوة', 
//               _selectedTilawaType == 'جماعية' ? 'تلاوة جماعية' : 'تلاوة فردية'
//             ),
//             // Show custom reader name if provided
//             if (_showCustomTilawaInput && _customTilawaNameController.text.trim().isNotEmpty)
//               _buildSummaryItem('  ↳ اسم القارئ', _customTilawaNameController.text.trim()),
//           ],
//         ]),

//         const SizedBox(height: 16),

//         // Options Summary
//         _buildSummaryCard('خيارات الحجز', [
//           _buildSummaryItem('السماح للآخرين', _allowOthers ? 'نعم' : 'لا'),
//           _buildSummaryItem('زفاف جماعي', _joinToMassWedding ? 'نعم' : 'لا'),
//           _buildSummaryItem('حجز يومين متتاليين', _date2Bool ? 'نعم' : 'لا'),
//         ]),
        
//         const SizedBox(height: 16),
        
//         // Important Note with dynamic content
//         Builder(
//           builder: (context) {
//               final isDark = Theme.of(context).brightness == Brightness.dark;

//             // Load settings only if clan is selected and settings not loaded
//             if (_selectedClan != null && !_instructionSettingsLoaded) {
//               // Call load settings but don't wait for it in build
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                 _loadInstructionClanSettings();
//               });
//             }
            
//             if (_isLoadingInstructionSettings) {
//               return Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: const Color.fromARGB(255, 253, 227, 227),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: const Color.fromARGB(255, 249, 144, 144)),
//                 ),
//                 child: Row(
//                   children: [
//                     SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: const Color.fromARGB(255, 249, 144, 144),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Text('جاري تحميل معلومات الاستقبال...'),
//                   ],
//                 ),
//               );
//             }
            
//             return Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: isDark 
//                       ? Colors.red.withOpacity(0.2) 
//                       : const Color.fromARGB(255, 253, 227, 227),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: isDark 
//                         ? Colors.red.withOpacity(0.5) 
//                         : const Color.fromARGB(255, 249, 144, 144),
//                   ),
//                 ),
//                 child: Directionality(
//                   textDirection: TextDirection.rtl,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             Icons.info,
//                             color: isDark 
//                                 ? Colors.red[300] 
//                                 : const Color.fromARGB(255, 249, 144, 144),
//                             size: 32,
//                           ),
//                         // const SizedBox(height: 8),
//                         // Text(
//                         //   'ملاحظة مهمة',
//                         //   style: TextStyle(
//                         //     fontSize: 16,
//                         //     fontWeight: FontWeight.bold,
//                         //     color: const Color.fromARGB(255, 0, 0, 0),
//                         //   ),
//                         //   textAlign: TextAlign.center,
//                         // ),
//                       ],
//                     ),
//                     // const SizedBox(height: 8),

//                     // Dynamic instruction text
//                     _buildReservationInstructionWidget(),
                    


//                     // Text(
//                     //   _buildReservationInstructionText(),
//                     //   style: TextStyle(
//                     //     fontSize: 14,
//                     //     color: const Color.fromARGB(255, 0, 0, 0),
//                     //     height: 1.5,
//                     //   ),
//                     //   textAlign: TextAlign.start,
//                     // ),
//                   ],
//                 ),
                
//               ),
              
//             );
            
//           },
          
//         ),
//         // const SizedBox(height: 80),
//         const SizedBox(height: 24),
//         _buildBottomNavigation(),
//         const SizedBox(height: 50), // Extra padding at bottom
//       ],
//     ),
//   );
// }


//   Widget _buildInfoRow(String label, String value ,
//    bool isDark,) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '$label: ',
//             style: TextStyle(
//               fontWeight: FontWeight.w500,
//               color: isDark ?AppColors.background :AppColors.textSecondary,
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style:  TextStyle(color: isDark ?AppColors.darkTextPrimary :AppColors.darkTextHint),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSummaryCard(String title, List<Widget> children) {
//   final isDark = Theme.of(context).brightness == Brightness.dark;
  
//   return Card(
//     color: isDark ? AppColors.darkCard : Colors.white,
//     child: Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: isDark ? AppColors.darkPrimary : AppColors.primary,
//             ),
//           ),
//             const SizedBox(height: 12),
//             ...children,
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSummaryItem(String label, String value) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '$label: ',
//             style: TextStyle(
//               fontWeight: FontWeight.w500,
//               color: isDark ? Colors.white :Colors.black ,
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: TextStyle(color:  isDark ? const Color.fromARGB(201, 255, 255, 255) :const Color.fromARGB(255, 15, 0, 99) ,),
//             ),
//           ),
//         ],
//       ),

//     );
//   }

// //  Widget _buildBottomNavigation() {
// //   final isDark = Theme.of(context).brightness == Brightness.dark;
  
// //   return Positioned(
// //     left: 0,
// //     right: 0,
// //     bottom: 0,
// //     child: Container(
// //       padding: const EdgeInsets.all(0),
// //       decoration: BoxDecoration(
// //         color: isDark ? const Color.fromARGB(0, 44, 44, 44) : const Color.fromARGB(0, 255, 255, 255),
// //         // boxShadow: [
// //         //   BoxShadow(
// //         //     color: Colors.black.withOpacity(0.1),
// //         //     blurRadius: 8,
// //         //     offset: const Offset(0, -2),
// //         //   ),
// //         // ],
// //       ),
// //       child: SafeArea(
// //         child: Row(
// //           children: [
// //             // Next/Submit button (on the right for RTL)
// //             Expanded(
// //               child: ElevatedButton.icon(
// //                 onPressed: _isSubmitting ? null : _handleNextStep,
// //                 icon: _isSubmitting
// //                     ? const SizedBox(
// //                         width: 20,
// //                         height: 20,
// //                         child: CircularProgressIndicator(
// //                           strokeWidth: 2,
// //                           color: Colors.white,
// //                         ),
// //                       )
// //                     : Icon(
// //                         _currentStep == 2 
// //                             ? Icons.check_circle 
// //                             : Icons.arrow_back,
// //                       ),
// //                 label: Text(
// //                   _isSubmitting 
// //                       ? 'جاري الإرسال...'
// //                       : (_currentStep == 2 ? 'تأكيد الحجز' : 'التالي')
// //                 ),
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: _isSubmitting
// //                       ? (isDark ? const Color.fromARGB(111, 66, 66, 66) : const Color.fromARGB(202, 158, 158, 158))
// //                       : (isDark ? const Color.fromARGB(127, 102, 187, 106) : const Color.fromARGB(214, 46, 125, 50)),
// //                   foregroundColor: Colors.white,
// //                   padding: const EdgeInsets.symmetric(vertical: 16),
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(8),
// //                   ),
// //                 ),
// //               ),
// //             ),
            
// //             // Spacing between buttons
// //             if (_currentStep > 0) const SizedBox(width: 12),
            
// //             // Previous button (on the left for RTL)
// //             if (_currentStep > 0)
// //               Expanded(
// //                 child: ElevatedButton.icon(
// //                   onPressed: _goToPreviousStep,
// //                   icon: const Icon(Icons.arrow_forward),
// //                   label: const Text('السابق'),
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: isDark 
// //                         ? const Color.fromARGB(104, 44, 44, 44) 
// //                         :  Colors.white,
// //                     foregroundColor: isDark 
// //                         ? AppColors.darkPrimary 
// //                         : AppColors.primary,
// //                     side: BorderSide(
// //                       color: isDark 
// //                           ? AppColors.darkPrimary 
// //                           : AppColors.primary,
// //                     ),
// //                     padding: const EdgeInsets.symmetric(vertical: 16),
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //           ],
// //         ),
// //       ),
// //     ),
// //   );
// // }
// Widget _buildBottomNavigation() {
//   final isDark = Theme.of(context).brightness == Brightness.dark;
  
//   return Container(  // Changed from Positioned
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: isDark ? AppColors.darkBackground : Colors.white,
//     ),
//     child: SafeArea(
//       child: Row(
//         children: [
//           // Next/Submit button (on the right for RTL)
//           Expanded(
//             child: ElevatedButton.icon(
//               onPressed: _isSubmitting ? null : _handleNextStep,
//               icon: _isSubmitting
//                   ? const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: Colors.white,
//                       ),
//                     )
//                   : Icon(
//                       _currentStep == 2 
//                           ? Icons.check_circle 
//                           : Icons.arrow_back,
//                     ),
//               label: Text(
//                 _isSubmitting 
//                     ? 'جاري الإرسال...'
//                     : (_currentStep == 2 ? 'تأكيد الحجز' : 'التالي')
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: _isSubmitting
//                     ? (isDark ? const Color.fromARGB(111, 66, 66, 66) : const Color.fromARGB(202, 158, 158, 158))
//                     : (isDark ? const Color.fromARGB(127, 102, 187, 106) : const Color.fromARGB(214, 46, 125, 50)),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//             ),
//           ),
          
//           if (_currentStep > 0) const SizedBox(width: 12),
          
//           if (_currentStep > 0)
//             Expanded(
//               child: ElevatedButton.icon(
//                 onPressed: _goToPreviousStep,
//                 icon: const Icon(Icons.arrow_forward),
//                 label: const Text('السابق'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: isDark 
//                       ? const Color.fromARGB(104, 44, 44, 44) 
//                       : Colors.white,
//                   foregroundColor: isDark 
//                       ? AppColors.darkPrimary 
//                       : AppColors.primary,
//                   side: BorderSide(
//                     color: isDark 
//                         ? AppColors.darkPrimary 
//                         : AppColors.primary,
//                   ),
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     ),
//   );
// }
// void _goToPreviousStep() {
//   if (_currentStep > 0 && _pageController.hasClients) {
//     _pageController.previousPage(
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//   }
// }

//  void _handleNextStep() {
//   if (_currentStep == 2) {
//     _submitReservation();
//   } else {
//     if (_validateCurrentStep() && _pageController.hasClients) {
//       _pageController.nextPage(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
//   }
// }

// bool _validateCurrentStep() {
//   switch (_currentStep) {
//     case 0:
//       if (_selectedClan == null) {
//         _showMessageDialog(
//           title: 'العشيرة مطلوبة',
//           message: 'يرجى اختيار العشيرة قبل المتابعة.',
//           icon: Icons.group,
//           titleColor: Colors.orange,
//         );
//         return false;
//       }
//       if (_selectedHall == null) {
//         _showMessageDialog(
//           title: 'القاعة مطلوبة',
//           message: 'يرجى اختيار القاعة قبل المتابعة.',
//           icon: Icons.business,
//           titleColor: Colors.orange,
//         );
//         return false;
//       }
//       return true;
//     case 1:
//       if (_date1Controller.text.isEmpty) {
//         _showMessageDialog(
//           title: 'التاريخ مطلوب',
//           message: 'يرجى اختيار تاريخ الحفل قبل المتابعة.',
//           icon: Icons.calendar_today,
//           titleColor: Colors.orange,
//         );
//         return false;
//       }
//       if (_selectedHaiaCommittee == null) {
//         _showMessageDialog(
//           title: 'الهيئة الدينية مطلوبة',
//           message: 'يرجى اختيار الهيئة الدينية قبل المتابعة.',
//           icon: Icons.group,
//           titleColor: Colors.orange,
//         );
//         return false;
//       }
//       if (_selectedMadaehCommittee == null) {
//         _showMessageDialog(
//           title: 'لجنة المدائح و الانشاد مطلوبة',
//           message: 'يرجى اختيار لجنة المدائح و الانشاد قبل المتابعة.',
//           icon: Icons.music_note,
//           titleColor: Colors.orange,
//         );
//         return false;
//       }
//       return true;
//     default:
//       return _formKey.currentState?.validate() == true;
//   }
// }
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
//                         'تنبيه: الحجوزات المعلقة قد تُلغى خلال الايام القادمة',
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

// void _handleAvailableDate(DateTime selectedDate, TextEditingController controller) {
//   setState(() {
//     controller.text = selectedDate.toLocal().toString().split(' ')[0];
    
//     if (controller == _date1Controller) {
//       _updateTwoDayAvailability();
//     }
//   });
  
//   _showMessageDialog(
//     title: 'تم اختيار التاريخ',
//     message: 'تم اختيار التاريخ ${DateFormat('dd/MM/yyyy').format(selectedDate)} بنجاح.\n\nيمكنك الآن المتابعة للخطوة التالية.',
//     icon: Icons.check_circle,
//     isError: false,
//   );
// }

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

// void _showDateNotAvailableMessage(String message) {
//   _showMessageDialog(
//     title: 'التاريخ غير متاح',
//     message: message,
//     icon: Icons.event_busy,
//     isError: true,
//   );
// }

//   // Updated fallback date picker method
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
      
//       _showMessageDialog(
//         title: 'تحذير - تم تجاوز فحص التوفر',
//         message: 'تم اختيار التاريخ بدون التحقق من التوفر.\n\nقد يتم رفض الحجز إذا كان التاريخ محجوز مسبقاً.\n\nيُنصح بالتحقق من توفر التاريخ قبل تأكيد الحجز.',
//         icon: Icons.warning,
//         titleColor: Colors.orange,
//       );
//     }
//   } catch (e) {
//     print('Error in fallback date picker: $e');
//     if (mounted) {
//       _showMessageDialog(
//         title: 'خطأ في اختيار التاريخ',
//         message: 'خطأ في اختيار التاريخ:\n\n$e\n\nيرجى المحاولة مرة أخرى.',
//         icon: Icons.error,
//         isError: true,
//       );
//     }
//   }
// }
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