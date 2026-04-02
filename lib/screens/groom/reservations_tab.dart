// lib/screens/home/tabs/reservations_tab.dart
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wedding_reservation_app/utils/pdf_mobile_downloader.dart'
    if (dart.library.html) 'package:wedding_reservation_app/utils/pdf_web_downloader.dart';

import '../../../services/api_service.dart';
import '../../../utils/colors.dart';

class ReservationsTab extends StatefulWidget {
  const ReservationsTab({super.key});

  @override
  State<ReservationsTab> createState() => ReservationsTabState();
}

class ReservationsTabState extends State<ReservationsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // Remove _isLoading variable
  bool _isRefreshing = false;
  
  // Initialize with empty/default data
  Map<String, dynamic>? _pendingReservation;
  Map<String, dynamic>? _validatedReservation;
  List<dynamic> _cancelledReservations = [];
  List<dynamic> _allReservations = [];

  // Cached data
  Map<String, dynamic>? _cachedPendingReservation;
  Map<String, dynamic>? _cachedValidatedReservation;
  List<dynamic> _cachedCancelledReservations = [];
  List<dynamic> _cachedAllReservations = [];
  bool _hasLoadedOnce = false;


  Map<String, dynamic>? _originClanSettings;
  Map<String, dynamic>? _selectedClanSettings; 
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _selectedClan;
  bool _isLoadingInstructionSettings = false;
  bool _instructionSettingsLoaded = false;

  bool _isInitialLoading = true;
  String _connectionStatus = 'checking'; // 'checking', 'loading', 'offline', 'loaded'

// @override
// void initState() {
//   super.initState();
//   _tabController = TabController(length: 4, vsync: this);
  
//   // Always show cached data first (even if empty on first launch)
//   _loadCachedData();
  
//   // Try to load fresh data in background
//   WidgetsBinding.instance.addPostFrameCallback((_) {
//     _checkConnectivityAndLoad();
//   });
// }

@override
void initState() {
  super.initState();
  _tabController = TabController(length: 4, vsync: this);
  
  _loadCachedData();
  
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _checkConnectivityAndLoad();
  });
}



  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
void refreshData() {
  // Check connectivity before refreshing
  _checkConnectivityAndLoad();
}

void _loadCachedData() {
  // Always display cached data, even if empty
  setState(() {
    _allReservations = _cachedAllReservations;
    _pendingReservation = _cachedPendingReservation;
    _validatedReservation = _cachedValidatedReservation;
    _cancelledReservations = _cachedCancelledReservations;
  });
}

// ============================================
// 4. ADD: Background loading method (non-blocking)
// ============================================
Future<void> _loadReservationsInBackground() async {
  if (_isRefreshing) return;
  
  try {
    final allReservationsRaw = await ApiService.getMyAllReservations();
    final filteredReservations = allReservationsRaw
        .where((reservation) => reservation['status']?.toLowerCase() != 'cancelled')
        .toList();
    _sortReservationsByDateProximity(filteredReservations);
    
    Map<String, dynamic>? pending;
    try {
      pending = await ApiService.getMyPendingReservation();
    } catch (e) {
      pending = null;
    }
    
    Map<String, dynamic>? validated;
    try {
      validated = await ApiService.getMyValidatedReservation();
    } catch (e) {
      validated = null;
    }
    
    final cancelled = await ApiService.getMyCancelledReservations();
    
    if (mounted) {
      setState(() {
        _allReservations = filteredReservations;
        _pendingReservation = pending;
        _validatedReservation = validated;
        _cancelledReservations = cancelled;
        
        _cachedAllReservations = List.from(filteredReservations);
        _cachedPendingReservation = pending != null ? Map<String, dynamic>.from(pending) : null;
        _cachedValidatedReservation = validated != null ? Map<String, dynamic>.from(validated) : null;
        _cachedCancelledReservations = List.from(cancelled);
        
        _hasLoadedOnce = true;
        _connectionStatus = 'loaded';
      });
    }
  } catch (e) {
    print('Error loading reservations: $e');
    if (mounted) {
      setState(() {
        _connectionStatus = 'offline';
      });
      _showSnackBar('خطأ في التحميل - عرض البيانات المحفوظة', Colors.orange);
    }
  }
}

Future<void> _checkConnectivityAndLoad() async {
  if (mounted) {
    setState(() {
      _connectionStatus = 'checking';
    });
  }
  
  final connectivityResult = await Connectivity().checkConnectivity();
  
  if (connectivityResult.contains(ConnectivityResult.none)) {
    if (mounted) {
      setState(() {
        _connectionStatus = 'offline';
        _isInitialLoading = false;
      });
      
      if (_cachedAllReservations.isEmpty && !_hasLoadedOnce) {
        _showNoInternetDialog();
      } else {
        _showSnackBar('لا يوجد اتصال - عرض البيانات المحفوظة', Colors.orange);
      }
    }
    return;
  }
  
  if (mounted) {
    setState(() {
      _connectionStatus = 'loading';
    });
  }
  
  await _loadReservationsInBackground();
  
  if (mounted) {
    setState(() {
      _connectionStatus = 'loaded';
      _isInitialLoading = false;
    });
  }
}


// void _showNoInternetDialog() {
//   showDialog(
//     context: context,
//     barrierDismissible: true, // Allow dismissing
//     builder: (context) => AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       title: Row(
//         children: [
//           Icon(Icons.wifi_off, color: Colors.orange),
//           SizedBox(width: 10),
//           Text('لا يوجد اتصال'),
//         ],
//       ),
//       content: Text(
//         _hasLoadedOnce 
//           ? 'يتم عرض آخر البيانات المحفوظة\nللتحديث، تحقق من اتصالك بالإنترنت'
//           : 'يرجى التحقق من اتصالك بالإنترنت لتحميل البيانات'
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: Text('موافق'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             Navigator.pop(context);
//             _checkConnectivityAndLoad();
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.blue,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           ),
//           child: Text('إعادة المحاولة', style: TextStyle(color: Colors.white)),
//         ),
//       ],
//     ),
//   );
// }

void _showNoInternetDialog() {
  if (!mounted) return;
  
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _getCardColor(context),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Icon Container
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: Colors.orange,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              'لا يوجد اتصال بالإنترنت',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _getTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Description
            Text(
              _hasLoadedOnce 
                ? 'يتم عرض آخر البيانات المحفوظة\nللتحديث، تحقق من اتصالك بالإنترنت'
                : 'يرجى التحقق من اتصالك بالإنترنت\nلتحميل البيانات',
              style: TextStyle(
                fontSize: 14,
                color: _getSecondaryTextColor(context),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: _getSecondaryTextColor(context).withOpacity(0.2),
                        ),
                      ),
                    ),
                    child: Text(
                      'إغلاق',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _getSecondaryTextColor(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _checkConnectivityAndLoad();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh_rounded, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'إعادة المحاولة',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

  Color _getCardColor(BuildContext context) {
  return Theme.of(context).cardColor;
}


Color _getTextColor(BuildContext context) {
  return Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textPrimary;
}

Color _getSecondaryTextColor(BuildContext context) {
  return Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary;
}



Future<void> _refreshReservations() async {
  if (_isRefreshing) return;
  
  // Check connectivity first
  final connectivityResult = await Connectivity().checkConnectivity();
  
  if (connectivityResult.contains(ConnectivityResult.none)) {
    _showSnackBar('لا يوجد اتصال - عرض البيانات المحفوظة', Colors.orange);
    return;
  }
  
  setState(() => _isRefreshing = true);
  
  try {
    // Reset instruction settings when refreshing
    _instructionSettingsLoaded = false;
    _originClanSettings = null;
    _selectedClanSettings = null;
    _userProfile = null;
    _selectedClan = null;
    
    await _loadReservationsInBackground();
    
    if (mounted) {
      _showSnackBar('تم التحديث بنجاح', Colors.green);
    }
  } catch (e) {
    if (mounted) {
      _showSnackBar('خطأ في التحديث - عرض البيانات المحفوظة', Colors.orange);
    }
  } finally {
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }
}
void _sortReservationsByDateProximity(List<dynamic> reservations) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  
  reservations.sort((a, b) {
    DateTime? dateA = _getReservationDate(a);
    DateTime? dateB = _getReservationDate(b);
    
    // If one has no date, put it at the end
    if (dateA == null && dateB == null) return 0;
    if (dateA == null) return 1;
    if (dateB == null) return -1;
    
    // Calculate absolute difference from today
    int diffA = dateA.difference(today).inDays.abs();
    int diffB = dateB.difference(today).inDays.abs();
    
    // Sort by closest to today
    return diffA.compareTo(diffB);
  });
}

DateTime? _getReservationDate(Map<String, dynamic> reservation) {
  try {
    final date1 = reservation['date1'];
    if (date1 == null) return null;
    
    // Try to parse the date
    if (date1 is String) {
      return DateTime.parse(date1);
    } else if (date1 is DateTime) {
      return date1;
    }
  } catch (e) {
    print('Error parsing date for reservation ${reservation['id']}: $e');
  }
  return null;
}


// Updated _loadClanSettings method
Future<void> _loadInstructionClanSettings(Map<String, dynamic> reservation) async {
  if (_instructionSettingsLoaded) return;
  
  setState(() => _isLoadingInstructionSettings = true);
  
  try {
    // Extract user profile info from reservation 
    _userProfile = {
      'clan_id': reservation['clan_id_origin'] ,
      'clan_name': reservation['clan_name_origin'] ,
    };
    print("DEBUG: Reservation data: $reservation");
    print("DEBUG: Loaded user profile from reservation: $_userProfile");
    print("DEBUG: User's clan_id: ${reservation['clan_id_origin']}");
    print("DEBUG: Selected clan_id: ${reservation['clan_id']}");
    print("DEBUG: Selected clan_name: ${reservation['clan_name']}");
    print("DEBUG: User's clan_name: ${reservation['clan_name_origin']}");

    // Extract selected clan info from reservation
    _selectedClan = {
      'id': reservation['clan_id'] ,
      'name': reservation['clan_name'] ?? 
              'العشيرة المختارة',
    };


    print("DEBUG: Loaded selected clan from reservation: $_selectedClan");
    print("DEBUG: Selected clan data: $_selectedClan");
    print("DEBUG: Selected clan_id: ${_selectedClan?['id']}");
    print("DEBUG: Selected clan_name: ${_selectedClan?['name']}");

    // Load origin clan settings (user's clan)
    if (_userProfile?['clan_id'] != null) {
      final clanId = _userProfile!['clan_id'].toString();
      print("DEBUG: Loading origin clan settings for clan_id = $clanId");

      try {
        _originClanSettings = await ApiService.getSettingsByClanId(clanId);
        print("DEBUG: Origin clan settings loaded successfully: $_originClanSettings");
      } catch (e, stack) {
        print("ERROR: Failed to load origin clan settings for clan_id = $clanId");
        print("Exception: $e");
        print("Stacktrace: $stack");
      }
    } else {
      print("DEBUG: No clan_id found in _userProfile, skipping origin clan settings load.");
    }

    // Load selected clan settings if different from origin clan
    if (_selectedClan != null && _selectedClan!['id'] != _userProfile?['clan_id']) {
      _selectedClanSettings = await ApiService.getSettingsByClanId(_selectedClan!['id'].toString());
    }
    
    setState(() {
      _instructionSettingsLoaded = true;
    });
  } catch (e) {
    print('Error loading instruction clan settings: $e');
  } finally {
    setState(() => _isLoadingInstructionSettings = false);
  }
}

// Add these helper methods
bool _isCrossClanReservation() {
  return _userProfile?['clan_id'] != null && 
         _selectedClan != null && 
         _userProfile!['clan_id'] != _selectedClan!['id'];
}


Map<String, String> _getClanAcceptanceTime(bool isOriginClan) {
  Map<String, dynamic>? settings = isOriginClan ? _originClanSettings : _selectedClanSettings;
  
  if (settings == null) {
    return {'day': 'يوم غير محدد', 'time': 'وقت غير محدد'};
  }

  // Parse acceptance days (can be multiple days)
  String dayKey = 'days_to_accept_invites';
  dynamic dayValue = settings[dayKey];
  List<String> arabicDays = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];

  String day = 'يوم غير محدد'; // Default value

  if (dayValue != null && dayValue.toString().isNotEmpty) {
    String dayString = dayValue.toString().trim();
    
    // Split by comma to handle multiple days
    List<String> dayIndices = dayString.split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    
    List<String> validDays = [];
    
    for (String indexStr in dayIndices) {
      int? dayIndex = int.tryParse(indexStr);
      if (dayIndex != null && dayIndex >= 0 && dayIndex < 7) {
        validDays.add(arabicDays[dayIndex]);
      }
    }
    
    if (validDays.isNotEmpty) {
      // Join multiple days with " و " (Arabic "and")
      day = validDays.join(' و ');
    }
  }

  // Parse acceptance times (can be multiple times)
  String timeKey = 'accept_invites_times';
  dynamic timeValue = settings[timeKey];

  String time = 'وقت غير محدد'; // Default value

  if (timeValue != null && timeValue.toString().isNotEmpty) {
    String timeString = timeValue.toString().trim();
    
    // Split by comma and clean up empty values
    List<String> timeSlots = timeString.split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    
    List<String> validTimes = [];
    
    for (String timeSlot in timeSlots) {
      // Basic validation for time format (HH:MM)
      RegExp timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
      if (timeRegex.hasMatch(timeSlot)) {
        validTimes.add(timeSlot);
      }
    }
    
    if (validTimes.isNotEmpty) {
      // Join multiple times with " و " (Arabic "and")
      time = validTimes.join(' و ');
    }
  }

  return {'day': day, 'time': time};
}

String _getSelectedClanName() {
  return _selectedClan?['name']?.toString() ?? 'العشيرة المختارة';
}

String _getOriginClanName() {
  // Try to get from user profile first, fallback to selected clan name
  String? clanName = _userProfile?['clan_name']?.toString();
  if (clanName != null && clanName.isNotEmpty) {
    return clanName;
  }
  
  // If origin clan settings are loaded, try to get name from there
  if (_originClanSettings?['clan_name'] != null) {
    return _originClanSettings!['clan_name'].toString();
  }
  
  return 'عشيرتك';
}

String _getValidationDeadlineDays() {
  // Try to get from origin clan settings first, then selected clan
  int? days = _originClanSettings?['validation_deadline_days'] ?? 
              _selectedClanSettings?['validation_deadline_days'];
  
  return days?.toString() ?? '10';
}




// Replace the existing _buildReservationInstructionText method
// String _buildReservationInstructionText() {
//   String baseText = 'للحصول على الموافقة النهائية، يجب طباعة الحجز وختمه وتوقيعه من:\n'
//                    '- الهيئة الدينية\n';

//   if (_isCrossClanReservation()) {
//     Map<String, String> selectedClanTime = _getClanAcceptanceTime(false);
//     String selectedClanName = _getSelectedClanName();
    
//     String formattedSchedule = _formatDayTimeSchedule(
//       selectedClanTime['day'] ?? '', 
//       selectedClanTime['time'] ?? ''
//     );
//     baseText += '\n';
//     baseText += '- الدار المضيفة ($selectedClanName) $formattedSchedule\n';

//   }

//   Map<String, String> originClanTime = _getClanAcceptanceTime(true);
//   String originClanName = _getOriginClanName();

//   String formattedSchedule = _formatDayTimeSchedule(
//     originClanTime['day'] ?? '', 
//     originClanTime['time'] ?? ''
//   );

//   baseText += '\n';
//   baseText += '- إدارة عشيرتك  $originClanName $formattedSchedule\n\n';

//   // Safely get validation deadline days with fallback
//   String daysMax = _getValidationDeadlineDays();
  
//   baseText += '\n';
//   baseText += 'يجب استكمال هذه الإجراءات خلال $daysMax أيام كحد أقصى، وإلا يُلغى الحجز تلقائياً.\n\n'
//               'بعد ختم وتوقيع جميع الجهات، توجّه إلى إدارة عشيرتك $originClanName ليؤكد حجزك في النظام.\n\n';

//   return baseText;
// }

Widget _buildReservationInstructionWidget() {
  final originClanTime = _getClanAcceptanceTime(true);
  final originClanName = _getOriginClanName();
  final formattedSchedule = _formatDayTimeSchedule(originClanTime['day'] ?? '', originClanTime['time'] ?? '');
  final daysMax = _getValidationDeadlineDays();

  return Center(
    child: SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '━━━━━━━━━━━━━━━━━━━━━━',
              textAlign: TextAlign.center,
              style: TextStyle(color: _getSecondaryTextColor(context)),
            ),
            Text(
              '📝 خطوات إتمام الحجز',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _getTextColor(context),
              ),
            ),
            Text(
              '━━━━━━━━━━━━━━━━━━━━━━',
              textAlign: TextAlign.center,
              style: TextStyle(color: _getSecondaryTextColor(context)),
            ),
            SizedBox(height: 20),
            Text(
              'للحصول على الموافقة النهائية، يجب طباعة الحجز وختمه وتوقيعه من:',
              textAlign: TextAlign.center,
              style: TextStyle(color: _getTextColor(context)),
            ),
            SizedBox(height: 20),
            Text(
              '⊙ إدارة عشيرتك',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _getTextColor(context),
              ),
            ),
            Text(
              originClanName,
              textAlign: TextAlign.center,
              style: TextStyle(color: _getTextColor(context)),
            ),
            Text(
              '🕐 $formattedSchedule',
              textAlign: TextAlign.center,
              style: TextStyle(color: _getSecondaryTextColor(context)),
            ),
            SizedBox(height: 20),
            if (_isCrossClanReservation()) ...[
              Text(
                '⊙ الدار المضيفة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _getTextColor(context),
                ),
              ),
              Text(
                _getSelectedClanName(),
                textAlign: TextAlign.center,
                style: TextStyle(color: _getTextColor(context)),
              ),
              Text(
                '🕐 ${_formatDayTimeSchedule(_getClanAcceptanceTime(false)['day'] ?? '', _getClanAcceptanceTime(false)['time'] ?? '')}',
                textAlign: TextAlign.center,
                style: TextStyle(color: _getSecondaryTextColor(context)),
              ),
              SizedBox(height: 20),
            ],
            Text(
              '⊙ الهيئة الدينية',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _getTextColor(context),
              ),
            ),
            SizedBox(height: 20),
            Text(
              '━━━━━━━━━━━━━━━━━━━━━━',
              textAlign: TextAlign.center,
              style: TextStyle(color: _getSecondaryTextColor(context)),
            ),
            Text(
              '⚠️ تنبيه ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            Text(
              '━━━━━━━━━━━━━━━━━━━━━━',
              textAlign: TextAlign.center,
              style: TextStyle(color: _getSecondaryTextColor(context)),
            ),
            SizedBox(height: 12),
            Text(
              'يجب استكمال هذه الإجراءات خلال $daysMax يوم كحد أقصى',
              textAlign: TextAlign.center,
              style: TextStyle(color: _getTextColor(context)),
            ),
            Text(
              'وإلا يُلغى الحجز تلقائياً',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'بعد ختم وتوقيع جميع الجهات، توجّه إلى إدارة العشيرة التي تقيم فيها العرس',
              textAlign: TextAlign.center,
              style: TextStyle(color: _getTextColor(context)),
            ),
            // Text(
            //   originClanName,
              
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     fontWeight: FontWeight.w600,
            //     color: _getTextColor(context),
            //   ),
            // ),
            Text(
              'ليؤكدو حجزك في النظام',
              textAlign: TextAlign.center,
              style: TextStyle(color: _getTextColor(context)),
            ),
          ],
        ),
      ),
    ),
  );
}
// Add this new helper method after the existing _getClanAcceptanceTime method
String _formatDayTimeSchedule(String days, String times) {
  if (days.isEmpty || times.isEmpty) {
    return '(لم يتم تحديد مواعيد الاستقبال)';
  }
  
  // Split days and times
  List<String> dayList = days.split(' و ').map((d) => d.trim()).toList();
  List<String> timeList = times.split(' و ').map((t) => t.trim()).toList();
  
  List<String> schedules = [];
  
  // Pair each day with its corresponding time
  int maxLength = math.min(dayList.length, timeList.length);
  
  for (int i = 0; i < maxLength; i++) {
    schedules.add('(يتم الاستقبال يوم ${dayList[i]} في الساعة ${timeList[i]})');
  }
  
  // Handle extra days or times
  if (dayList.length > timeList.length) {
    for (int i = maxLength; i < dayList.length; i++) {
      schedules.add('(يتم الاستقبال يوم ${dayList[i]} - وقت غير محدد)');
    }
  }
  
  if (schedules.isEmpty) {
    return '(لم يتم تحديد مواعيد الاستقبال)';
  }
  
  return schedules.join(' و ');
}




@override
Widget build(BuildContext context) {
  return PopScope(
    canPop: false,
    onPopInvokedWithResult: (bool didPop, Object? result) {
      // Do nothing - completely block back navigation
      return;
    },
    child: Column(
      children: [
        Container(
          color: Theme.of(context).appBarTheme.backgroundColor ?? _getCardColor(context),
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: _getSecondaryTextColor(context),
            indicatorColor: AppColors.primary,
            isScrollable: true,
            tabs: const [
              Tab(text: 'الكل'),
              Tab(text: 'معلق'),
              Tab(text: 'مؤكد'),
              Tab(text: 'ملغي'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAllReservationsTab(),
              _buildPendingReservationTab(),
              _buildValidatedReservationTab(),
              _buildCancelledReservationsTab(),
            ],
          ),
        ),
      ],
    ),
  );
}


  Widget _buildAllReservationsTab() {
    if (_allReservations.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshReservations,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            child: _buildEmptyState(
              icon: Icons.calendar_today,
              title: 'لا توجد حجوزات',
              subtitle: 'تأكد بإتصالك بالأنترنت \nاسحب لأسفل للتحديث',
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshReservations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _allReservations.length + 1, // +1 for refresh indicator space
        itemBuilder: (context, index) {
          if (index == _allReservations.length) {
            // Add some space at the bottom for better pull-to-refresh experience
            return const SizedBox(height: 80);
          }
          final reservation = _allReservations[index];
          return _buildReservationCard(reservation);
        },
      ),
    );
  }

  Widget _buildPendingReservationTab() {
    if (_pendingReservation == null) {
      return RefreshIndicator(
        onRefresh: _refreshReservations,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            child: _buildEmptyState(
              icon: Icons.pending_actions,
              title: 'لا توجد حجوزات معلقة',
              subtitle: 'تأكد بإتصالك بالأنترنت\nاسحب لأسفل للتحديث',
              actionButton: ElevatedButton(
                onPressed: _navigateToNewReservation,
                child: const Text('حجز جديد'),
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshReservations,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildDetailedReservationCard(
              _pendingReservation!,
              showActions: true,
              actions: [
                ElevatedButton.icon(
                  onPressed: () => _cancelReservation(_pendingReservation!['id']),
                  icon: const Icon(Icons.cancel),
                  label: const Text('إلغاء الحجز'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80), // Space for refresh indicator
          ],
        ),
      ),
    );
  }

  Widget _buildValidatedReservationTab() {
    if (_validatedReservation == null) {
      return RefreshIndicator(
        onRefresh: _refreshReservations,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            child: _buildEmptyState(
              icon: Icons.check_circle,
              title: 'لا توجد حجوزات مؤكدة',
              subtitle: ' تأكد بإتصالك بالأنترنت\nاسحب لأسفل للتحديث',
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshReservations,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildDetailedReservationCard(
              _validatedReservation!,
              showActions: true,
              actions: [
                ElevatedButton.icon(
                  onPressed: () => _downloadPdf(_validatedReservation!['id']),
                  icon: const Icon(Icons.download),
                  label: const Text('تحميل الملف'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80), // Space for refresh indicator
          ],
        ),
      ),
    );
  }

  Widget _buildCancelledReservationsTab() {
    if (_cancelledReservations.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshReservations,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            child: _buildEmptyState(
              icon: Icons.cancel,
              title: 'لا توجد حجوزات ملغاة',
              subtitle: 'تأكد بإتصالك بالأنترنت\nاسحب لأسفل للتحديث',
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshReservations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _cancelledReservations.length + 1, // +1 for refresh indicator space
        itemBuilder: (context, index) {
          if (index == _cancelledReservations.length) {
            // Add some space at the bottom for better pull-to-refresh experience
            return const SizedBox(height: 80);
          }
          final reservation = _cancelledReservations[index];
          return _buildReservationCard(reservation, showStatus: true);
        },
      ),
    );
  }

  Widget _buildReservationCard(Map<String, dynamic> reservation, {bool showStatus = false}) {
  String formatDates(Map<String, dynamic> reservation) {
    final date1 = reservation['date1'];
    final date2 = reservation['date2'];
    final date2Bool = reservation['date2_bool'] ?? false;
    
    if (date1 == null) return 'غير محدد';
    
    if (date2Bool && date2 != null) {
      return '$date1 - $date2';
    }
    return date1;
  }

  bool isCancelled = reservation['status']?.toLowerCase() == 'cancelled';
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Card(
    margin: const EdgeInsets.only(bottom: 16),
    color: isDark ? const Color.fromARGB(255, 22, 26, 45) :const Color.fromARGB(255, 255, 255, 255),  
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'حجز رقم: ${reservation['id']}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _getTextColor(context),
                ),
              ),
              _buildStatusChip(reservation['status']),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.event, 'التاريخ', formatDates(reservation)),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.family_restroom, 'العشيرة', _getClanName(reservation)),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_city, 'القصر', _getCountyName(reservation)),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.home, 'القاعة', _getHallName(reservation)),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.access_time, 'تاريخ الإنشاء', _formatDateTime(reservation['created_at'])),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  if (reservation['status']?.toLowerCase() == 'pending_validation') {
                    _tabController.animateTo(1);
                  } else {
                    _showReservationDetails(reservation);
                  }
                },
                child: const Text('عرض التفاصيل'),
              ),
              if (!isCancelled)
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      child: ElevatedButton.icon(
                        onPressed: () => _downloadPdf(reservation['id']),
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('تحميل ورقة الحجز', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                          minimumSize: const Size(0, 28),
                        ),
                      ),
                    ),
                   
                  ],
                ),
            ],
          ),
        ],
      ),
    ),
  );
}

  
   Widget _buildDetailedReservationCard(
    Map<String, dynamic> reservation, {
    bool showActions = false,
    List<Widget> actions = const [],
  }) {
    bool isCancelled = reservation['status']?.toLowerCase() == 'cancelled';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تفاصيل الحجز #${reservation['id']}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(reservation['status']),
              ],
            ),
            const Divider(height: 24),
            
            // Reservation Basic Information
            _buildDetailSection('معلومات أساسية', [
              _buildInfoRow(Icons.event, 'التاريخ الأول', reservation['date1'] ?? 'غير محدد'),
              if (reservation['date2_bool'] == true && reservation['date2'] != null)
                _buildInfoRow(Icons.event_available, 'التاريخ الثاني', reservation['date2']),
              _buildInfoRow(Icons.family_restroom, 'العشيرة', _getClanName(reservation)),
              _buildInfoRow(Icons.location_city, 'القصر', _getCountyName(reservation)),
              _buildInfoRow(Icons.access_time, 'تاريخ الإنشاء', _formatDateTime(reservation['created_at'])),
              if (reservation['expires_at'] != null)
                _buildInfoRow(Icons.schedule, 'تاريخ الانتهاء', _formatDateTime(reservation['expires_at'])),
            ]),
            
            const SizedBox(height: 16),
            
            // Location and Committees Information
            _buildDetailSection('معلومات المكان واللجان', [
              _buildInfoRow(Icons.home, 'القاعة', _getHallName(reservation)),
              _buildInfoRow(Icons.group, 'لجنة الهيئة', _getCommitteeName(reservation, 'haia_committee')),
              _buildInfoRow(Icons.restaurant_menu, 'لجنة المذائح', _getCommitteeName(reservation, 'madaeh_committee')),
            ]),
            
            const SizedBox(height: 16),
            
            // Personal Information
            _buildDetailSection('المعلومات الشخصية للعريس', [
              _buildInfoRow(Icons.person, 'الاسم الكامل', _getFullName(reservation)),
              _buildInfoRow(Icons.cake, 'تاريخ الميلاد', reservation['birth_date'] ?? 'غير محدد'),
              _buildInfoRow(Icons.location_on, 'مكان الميلاد', reservation['birth_address'] ?? 'غير محدد'),
              _buildInfoRow(Icons.home_outlined, 'عنوان السكن', reservation['home_address'] ?? 'غير محدد'),
              _buildInfoRow(Icons.phone, 'رقم الهاتف', reservation['phone_number'] ?? 'غير محدد'),
            ]),
            
            const SizedBox(height: 16),
            
            // Guardian Information
            if (_hasGuardianInfo(reservation))
              _buildDetailSection('المعلومات الشخصية لولي الأمر', [
                _buildInfoRow(Icons.person_outline, 'الاسم الكامل', reservation['guardian_name'] ?? 'غير محدد'),
                _buildInfoRow(Icons.phone_android, 'رقم الهاتف', reservation['guardian_phone'] ?? 'غير محدد'),
                _buildInfoRow(Icons.home_work, 'عنوان السكن', reservation['guardian_home_address'] ?? 'غير محدد'),
                _buildInfoRow(Icons.location_searching, 'مكان الميلاد', reservation['guardian_birth_address'] ?? 'غير محدد'),
                _buildInfoRow(Icons.calendar_today, 'تاريخ الميلاد', reservation['guardian_birth_date'] ?? 'غير محدد'),
              ]),
            
            const SizedBox(height: 16),
            
            // Options and Settings
            _buildDetailSection('الخيارات والإعدادات', [
              _buildInfoRow(
                Icons.people_alt, 
                'السماح للآخرين بالانضمام', 
                (reservation['allow_others'] == true) ? 'نعم' : 'لا'
              ),
              _buildInfoRow(
                Icons.groups, 
                'الانضمام للزفاف الجماعي', 
                (reservation['join_to_mass_wedding'] == true) ? 'نعم' : 'لا'
              ),
            ]),

            // Important Note for Pending Reservations (only show if not cancelled)            
            if (reservation['status'] == 'pending_validation' && !isCancelled) ...[
              const SizedBox(height: 16),
              
              // Load clan settings only once when this card is built
              Builder(
                builder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                  // Load settings only if not already loaded for this reservation
                  if (!_instructionSettingsLoaded) {
                    // Call load settings but don't wait for it in build
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _loadInstructionClanSettings(reservation);
                    });
                  }
                  
                  if (_isLoadingInstructionSettings) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? Colors.blue.withOpacity(0.15)
                            : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark 
                              ? Colors.blue.withOpacity(0.4)
                              : Colors.blue.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'جاري تحميل معلومات الاستقبال...',
                            style: TextStyle(color: _getTextColor(context)),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark 
                          ? Colors.red.withOpacity(0.15)
                          : const Color.fromARGB(255, 253, 227, 227),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark 
                            ? Colors.red.withOpacity(0.3)
                            : const Color.fromARGB(255, 249, 144, 144),
                      ),
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info,
                                color: isDark 
                                    ? Colors.red.withOpacity(0.8)
                                    : const Color.fromARGB(255, 249, 144, 144),
                                size: 32,
                              ),
                            ],
                          ),
                          _buildReservationInstructionWidget(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
            // Enhanced PDF Download Section (only show if not cancelled)
            if (!isCancelled) ...[
              const SizedBox(height: 16),
              _buildDetailSection('تحميل ومشاركة', [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.green.withOpacity(0.1)
                        : Colors.green.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.picture_as_pdf,
                        size: 32,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ملف PDF جاهز',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'حمّل أو شارك الملف',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _downloadPdf(reservation['id']),
                              icon: const Icon(Icons.download, size: 16),
                              label: const Text('تحميل ورقة الحجز', style: TextStyle(fontSize: 13)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
            ],
            
            
            if (showActions && actions.isNotEmpty) ...[
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: actions,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark 
              ? AppColors.primary.withOpacity(0.2) 
              : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark 
                ? AppColors.primary.withOpacity(0.4) 
                : AppColors.primary.withOpacity(0.3),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.primary.withOpacity(0.9) : AppColors.primary,
          ),
        ),
      ),
      const SizedBox(height: 12),
      ...children,
    ],
  );
}

  Widget _buildInfoRow(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: _getSecondaryTextColor(context)),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: _getSecondaryTextColor(context),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              color: _getTextColor(context),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildStatusChip(String? status) {
    Color color;
    String text;
    
    switch (status?.toLowerCase()) {
      case 'pending_validation':
        color = Colors.orange;
        text = 'معلق التأكيد';
        break;
      case 'validated':
        color = Colors.green;
        text = 'مؤكد';
        break;
      case 'cancelled':
        color = Colors.red;
        text = 'ملغي';
        break;
      default:
        color = Colors.grey;
        text = status ?? 'غير محدد';
    }

    return Chip(
      label: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.5)),
    );
  }

  Widget _buildEmptyState({
  required IconData icon,
  required String title,
  required String subtitle,
  Widget? actionButton,
}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 64,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        // Show connection status indicator during initial load
        if (_isInitialLoading) ...[
          const SizedBox(height: 16),
          _buildConnectionStatusIndicator(),
        ],
        if (actionButton != null) ...[
          const SizedBox(height: 24),
          actionButton,
        ],
      ],
    ),
  );
}

Widget _buildConnectionStatusIndicator() {
  IconData icon;
  Color color;
  String text;
  
  switch (_connectionStatus) {
    case 'checking':
      icon = Icons.sync;
      color = Colors.blue;
      text = 'جاري الفحص...';
      break;
    case 'loading':
      icon = Icons.cloud_download;
      color = Colors.green;
      text = 'جاري التحميل...';
      break;
    case 'offline':
      icon = Icons.cloud_off;
      color = Colors.orange;
      text = 'غير متصل';
      break;
    case 'loaded':
      icon = Icons.cloud_done;
      color = Colors.green;
      text = 'تم التحديث';
      break;
    default:
      icon = Icons.sync;
      color = Colors.grey;
      text = 'جاري التحقق...';
  }
  
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_connectionStatus == 'checking' || _connectionStatus == 'loading')
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          )
        else
          Icon(icon, size: 16, color: color),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );
}

 void _showReservationDetails(Map<String, dynamic> reservation) {
    bool isCancelled = reservation['status']?.toLowerCase() == 'cancelled';
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 700, maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: const Text('تفاصيل الحجز'),
                automaticallyImplyLeading: false,
                actions: [
                  // Add PDF download button in the app bar only if not cancelled
                  if (!isCancelled)
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf),
                      onPressed: () => _downloadPdf(reservation['id']),
                      tooltip: 'تحميل PDF',
                    ),
                  // Add refresh button in dialog
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      Navigator.pop(context);
                      _refreshReservations();
                    },
                    tooltip: 'تحديث',
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildDetailedReservationCard(reservation),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
// Replace the existing _cancelReservation method with this updated version:

Future<void> _cancelReservation(int reservationId) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('تأكيد الإلغاء'),
      content: const Text('هل أنت متأكد من رغبتك في إلغاء هذا الحجز؟\nلا يمكن التراجع عن هذا الإجراء.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('تأكيد الإلغاء'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      
      if (connectivityResult.contains(ConnectivityResult.none)) {
        _showNoInternetDialog();
        return;
      }
      
      await ApiService.cancelMyReservation(reservationId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إلغاء الحجز بنجاح'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Navigate to home page after successful cancellation
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/groom_home',
          (route) => false, // Remove all previous routes
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إلغاء الحجز: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

String _generatePdfFileName(int reservationId, Map<String, dynamic>? reservation) {
  String groomName = 'العريس';
  
  if (reservation != null) {
    final firstName = reservation['first_name'] ?? '';
    final fatherName = reservation['father_name'] ?? '';
    final grandfatherName = reservation['grandfather_name'] ?? '';
    final lastName = reservation['last_name'] ?? '';
    
    final List<String> nameParts = [firstName, fatherName, grandfatherName, lastName]
        .where((part) => part.toString().trim().isNotEmpty)
        .map((part) => part.toString().trim())
        .toList();
    
    if (nameParts.isNotEmpty) {
      groomName = nameParts.join(' ');
    }
  }
  
  // Include reservation ID for uniqueness
  return 'معلومات_الحجز_للعريس_${groomName.replaceAll(' ', '_')}_رقم_$reservationId.pdf';
}

Map<String, dynamic>? _getReservationById(int id) {
  if (_pendingReservation?['id'] == id) return _pendingReservation;
  if (_validatedReservation?['id'] == id) return _validatedReservation;
  
  try {
    return _allReservations.firstWhere((r) => r['id'] == id);
  } catch (e) {
    return null;
  }
}
// 4. NEW - Add this function (permission explanation dialog)
void _showPermissionExplanationDialog() {
  if (!mounted) return;
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.orange, size: 24),
          SizedBox(width: 8),
          Expanded(child: Text('تنبيه الصلاحيات')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('فشل حفظ الملف على جهازك.'),
          SizedBox(height: 12),
          Text(
            'الحلول الممكنة:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('1. امنح التطبيق صلاحية الوصول للتخزين من إعدادات الجهاز'),
          SizedBox(height: 4),
          Text('2. استخدم زر "مشاركة" لحفظ الملف في تطبيق آخر'),
          SizedBox(height: 4),
          Text('3. تأكد من وجود مساحة كافية على الجهاز'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('إغلاق'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            // Try to download and share directly
            try {
              final pdfBytes = await ApiService.downloadPdf(
                _pendingReservation?['id'] ?? _validatedReservation?['id'] ?? 0
              );
              await _sharePdf(
                _pendingReservation?['id'] ?? _validatedReservation?['id'] ?? 0, 
                pdfBytes
              );
            } catch (e) {
              _showSnackBar('حاول مرة أخرى', Colors.orange);
            }
          },
          child: Text('مشاركة الملف'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    ),
  );
}

Future<void> _sharePdf(int reservationId, Uint8List pdfBytes) async {
  // Web: just trigger another download (no native share on web)
  if (kIsWeb) {
    await _downloadPdfWeb(pdfBytes, reservationId);
    return;
  }
 
  try {
    final reservation = _getReservationById(reservationId);
    final fileName = _generatePdfFileName(reservationId, reservation);
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/$fileName');
    await tempFile.writeAsBytes(pdfBytes);
 
    await Share.shareXFiles(
      [XFile(tempFile.path)],
      text: 'ملف حجز رقم $reservationId',
      subject: 'حجز الزفاف رقم $reservationId',
    );
 
    _showSnackBar('تم فتح خيارات المشاركة', Colors.green.shade400);
  } catch (e) {
    print('Share error: $e');
  }
}


  // Replace these 3 functions in your code:

Future<void> _downloadPdf(int reservationId) async {
  // Skip connectivity check on web (browser handles it)
  if (!kIsWeb) {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      _showNoInternetDialog();
      return;
    }
  }
 
  try {
    _showSnackBar('جاري إنشاء الملف...', Colors.blue.shade400);
    await ApiService.generatePdf(reservationId);
    await Future.delayed(const Duration(seconds: 1));
 
    _showSnackBar('جاري تحميل الملف...', Colors.blue.shade400);
    final pdfBytes = await ApiService.downloadPdf(reservationId);
 
    if (mounted) ScaffoldMessenger.of(context).clearSnackBars();
 
    if (kIsWeb) {
      // ✅ WEB: trigger browser download directly
      await _downloadPdfWeb(pdfBytes, reservationId);
    } else {
      // ✅ MOBILE/DESKTOP: save to local storage
      _showSnackBar('جاري حفظ الملف...', Colors.blue.shade400);
      final savedFile = await _savePdfFile(
        pdfBytes,
        reservationId,
        reservation: _getReservationById(reservationId),
      );
 
      if (savedFile != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          _showSnackBar('تم تحميل الملف بنجاح ✓', Colors.green.shade400);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _showPdfActionsDialog(savedFile.path, reservationId, pdfBytes);
            }
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          _showSnackBar('فشل حفظ الملف. تحقق من صلاحيات التطبيق', Colors.red);
          Future.delayed(Duration(milliseconds: 500), () {
            if (mounted) _showPermissionExplanationDialog();
          });
        }
      }
    }
  } catch (e) {
    print('Download error: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      _showSnackBar('خطأ في تحميل الملف: $e', Colors.red.shade400);
    }
  }
}


Future<void> _downloadPdfWeb(Uint8List pdfBytes, int reservationId) async {
  final reservation = _getReservationById(reservationId);
  final fileName = _generatePdfFileName(reservationId, reservation);
  downloadPdfOnWeb(pdfBytes, fileName); // ← calls the right file automatically
  _showSnackBar('تم تحميل الملف ✓', Colors.green.shade400);
}
 
void _showPdfActionsDialog(String filePath, int reservationId, Uint8List pdfBytes) {
  if (!mounted) return;
 
  // On web this dialog is never called (web downloads directly)
  // This is only for mobile/desktop
 
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: EdgeInsets.all(20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle, color: Colors.green, size: 40),
          ),
          SizedBox(height: 16),
          Text(
            'تم التحميل بنجاح',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            filePath.split('/').last,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('إغلاق'),
        ),
        // Share button only on mobile (not desktop, not web)
        if (!kIsWeb)
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _sharePdf(reservationId, pdfBytes);
            },
            icon: Icon(Icons.share, size: 18),
            label: Text('مشاركة'),
          ),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(ctx);
            _openPdfFile(filePath);
          },
          icon: Icon(Icons.open_in_new, size: 18),
          label: Text('فتح'),
          style: FilledButton.styleFrom(backgroundColor: Colors.green),
        ),
      ],
    ),
  );
}
 


Future<void> _openPdfFile(String filePath) async {
  // Web never reaches here
  if (kIsWeb) return;
 
  try {
    final file = File(filePath);
    if (!await file.exists()) {
      if (mounted) _showSnackBar('الملف غير موجود', Colors.red);
      return;
    }
 
    final result = await OpenFile.open(filePath);
 
    if (mounted) {
      switch (result.type) {
        case ResultType.done:
          break;
        case ResultType.fileNotFound:
          _showSnackBar('الملف غير موجود', Colors.red);
          break;
        case ResultType.noAppToOpen:
          _showSnackBar(
              'لا يوجد تطبيق لفتح ملفات PDF. يرجى تثبيت قارئ PDF',
              Colors.orange);
          _showInstallPdfReaderDialog(filePath);
          break;
        case ResultType.permissionDenied:
          _showSnackBar('تم رفض الصلاحية لفتح الملف', Colors.red);
          break;
        case ResultType.error:
          _showSnackBar('خطأ في فتح الملف: ${result.message}', Colors.red);
          _showFileLocationDialog(filePath);
          break;
      }
    }
  } catch (e) {
    if (mounted) {
      _showSnackBar('خطأ في فتح الملف', Colors.red);
      _showFileLocationDialog(filePath);
    }
  }
}


// New helper method to suggest PDF reader installation
void _showInstallPdfReaderDialog(String filePath) {
  if (!mounted) return;
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 8),
          Expanded(child: Text('تطبيق قارئ PDF مطلوب')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('لا يوجد تطبيق لفتح ملفات PDF على جهازك.'),
          SizedBox(height: 12),
          Text(
            'يمكنك:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('• تثبيت قارئ PDF من متجر التطبيقات'),
          Text('• استخدام متصفح الإنترنت لفتح الملف'),
          Text('• مشاركة الملف مع تطبيق آخر'),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.folder, size: 16, color: Colors.blue),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'الملف: ${filePath.split('/').last}',
                    style: TextStyle(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('إغلاق'),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            Navigator.pop(context);
            // Get the PDF bytes and share
            try {
              final file = File(filePath);
              final bytes = await file.readAsBytes();
              final reservationId = int.tryParse(
                filePath.split('_').last.split('.').first
              ) ?? 0;
              await _sharePdf(reservationId, bytes);
            } catch (e) {
              _showSnackBar('خطأ في المشاركة', Colors.red);
            }
          },
          icon: Icon(Icons.share, size: 16),
          label: Text('مشاركة'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    ),
  );
}

Future<File?> _savePdfFile(Uint8List pdfBytes, int reservationId,
    {Map<String, dynamic>? reservation}) async {
  
  // Web never reaches here (handled by _downloadPdfWeb)
  if (kIsWeb) return null;
 
  try {
    Directory? directory;
 
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          var manageStatus = await Permission.manageExternalStorage.request();
          if (!manageStatus.isGranted) {
            directory = await getExternalStorageDirectory();
            if (directory != null) {
              final downloadsDir = Directory('${directory.path}/Downloads');
              if (!await downloadsDir.exists()) {
                await downloadsDir.create(recursive: true);
              }
              directory = downloadsDir;
            }
          }
        }
      }
 
      if (directory == null) {
        final possiblePaths = [
          '/storage/emulated/0/Download',
          '/storage/emulated/0/Downloads',
          '/sdcard/Download',
          '/sdcard/Downloads',
        ];
        for (final path in possiblePaths) {
          final dir = Directory(path);
          if (await dir.exists()) {
            directory = dir;
            break;
          }
        }
 
        if (directory == null) {
          directory = await getExternalStorageDirectory();
          if (directory != null) {
            final downloadsDir = Directory('${directory.path}/Downloads');
            if (!await downloadsDir.exists()) {
              await downloadsDir.create(recursive: true);
            }
            directory = downloadsDir;
          }
        }
      }
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      // Desktop
      directory = await getDownloadsDirectory();
      directory ??= await getApplicationDocumentsDirectory();
    }
 
    if (directory == null) throw Exception('لا يمكن الوصول إلى مجلد التخزين');
 
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
 
    final fileName = _generatePdfFileName(reservationId, reservation);
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
 
    await file.writeAsBytes(pdfBytes, flush: true);
 
    if (await file.exists()) {
      return file;
    } else {
      throw Exception('فشل في إنشاء الملف');
    }
  } catch (e) {
    // Last resort: app directory
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = _generatePdfFileName(reservationId, reservation);
      final file = File('${appDir.path}/$fileName');
      await file.writeAsBytes(pdfBytes, flush: true);
      if (await file.exists()) return file;
    } catch (e2) {
      print('Last resort failed: $e2');
    }
    return null;
  }
}
 


  // Helper method to show snack bar
  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showFileLocationDialog(String filePath) {
  if (!mounted) return;
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 22),
          SizedBox(width: 8),
          Expanded(child: Text('تم حفظ الملف')),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تم حفظ ملف PDF بنجاح في:'),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SelectableText(
                filePath,
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(
              Platform.isAndroid
                  ? 'يمكنك العثور على الملف في مجلد التحميلات (Downloads) أو في مدير الملفات.'
                  : 'يمكنك العثور على الملف في مجلد المستندات.',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('موافق'),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            Navigator.pop(context);
            // Try to open file again
            try {
              await OpenFile.open(filePath);
            } catch (e) {
              _showSnackBar('لا يمكن فتح الملف تلقائياً', Colors.orange);
            }
          },
          icon: Icon(Icons.open_in_new, size: 16),
          label: Text('محاولة الفتح'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    ),
  );
}
void _navigateToNewReservation() {
  if (!mounted) return;
  
  Navigator.of(context).pushNamed(
    '/groom_home',
  ).then((_) {
    if (mounted) {
      _refreshReservations();
    }
  });
}
// void _navigateToNewReservation() {
//   Navigator.of(context).pushNamed('/creat_new_reservation').then((_) {
//     // Refresh reservations when returning from create screen
//     _refreshReservations(); // Use enhanced refresh method
//   });
// }


  // Helper methods for getting proper names
  String _getClanName(Map<String, dynamic> reservation) {
    // Try different possible field names for clan
    return reservation['clan_name'] ?? 
           reservation['clan']?['name'] ?? 
           reservation['clanName'] ?? 
           'لم يتم الاختيار بعد';
  }

  String _getCountyName(Map<String, dynamic> reservation) {
    // Try different possible field names for county
    return reservation['county_name'] ?? 
           reservation['county']?['name'] ?? 
           reservation['countyName'] ?? 
           'لم يتم الاختيار بعد';
  }

  String _getHallName(Map<String, dynamic> reservation) {
    // Try different possible field names for hall
    return reservation['hall_name'] ?? 
           reservation['hall']?['name'] ?? 
           reservation['hallName'] ?? 
           'لم يتم الاختيار بعد';
  }

  String _getCommitteeName(Map<String, dynamic> reservation, String type) {
    // Try different possible field names for committees
    final fieldName = '${type}_name';
    final nestedName = '${type}Name';
    
    return reservation[fieldName] ?? 
           reservation[type]?['name'] ?? 
           reservation[nestedName] ?? 
           'لم يتم الاختيار بعد';
  }

  String _getFullName(Map<String, dynamic> reservation) {
    final firstName = reservation['first_name'] ?? '';
    final lastName = reservation['last_name'] ?? '';
    final fatherName = reservation['father_name'] ?? '';
    final grandfatherName = reservation['grandfather_name'] ?? '';
    
    final List nameParts = [firstName, fatherName, grandfatherName, lastName]
        .where((part) => part.isNotEmpty)
        .toList();
    
    return nameParts.isEmpty ? 'غير محدد' : nameParts.join(' ');
  }

  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return 'غير محدد';
    
    try {
      DateTime parsedDate;
      if (dateTime is String) {
        parsedDate = DateTime.parse(dateTime);
      } else if (dateTime is DateTime) {
        parsedDate = dateTime;
      } else {
        return 'غير محدد';
      }
      
      return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year} ${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime.toString();
    }
  }

  bool _hasGuardianInfo(Map<String, dynamic> reservation) {
    return reservation['guardian_name'] != null ||
           reservation['guardian_phone'] != null ||
           reservation['guardian_home_address'] != null ||
           reservation['guardian_birth_address'] != null ||
           reservation['guardian_birth_date'] != null;
  }
}