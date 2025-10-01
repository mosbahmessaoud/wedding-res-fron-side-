// lib/screens/home/tabs/reservations_tab.dart
import 'dart:math' as math;
import 'package:share_plus/share_plus.dart';

import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:wedding_reservation_app/screens/groom/create_reservation_screen.dart';
import 'package:wedding_reservation_app/screens/groom/groom_home_screen.dart';
import '../../../services/api_service.dart';
import '../../../utils/colors.dart';

class ReservationsTab extends StatefulWidget {
  const ReservationsTab({super.key});

  @override
  State<ReservationsTab> createState() => ReservationsTabState();
}

class ReservationsTabState extends State<ReservationsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _isRefreshing = false; // Add refresh state indicator
  
  Map<String, dynamic>? _pendingReservation;
  Map<String, dynamic>? _validatedReservation;
  List<dynamic> _cancelledReservations = [];
  List<dynamic> _allReservations = [];

  // Updated state variables - add these after existing state variables
  Map<String, dynamic> _userClanSettings = {};
  bool _isLoadingClanSettings = false;
  bool _clanSettingsLoaded = false; // Add this flag
  int? _currentReservationId; // Track which reservation's settings we loaded

  // Updated state variables for instruction settings
  Map<String, dynamic>? _originClanSettings;
  Map<String, dynamic>? _selectedClanSettings; 
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _selectedClan;
  bool _isLoadingInstructionSettings = false;
  bool _instructionSettingsLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadReservations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  void refreshData() {
    // Add your reservations refresh logic here
    // For example:
    _loadReservations();
    _refreshReservations();
    setState(() {
      // Trigger rebuild
    });
  }
  Future<void> _loadReservations() async {
    setState(() => _isLoading = true);
    
    try {
      // Load all reservation types
      _allReservations = await ApiService.getMyAllReservations();
      
      try {
        _pendingReservation = await ApiService.getMyPendingReservation();
      } catch (e) {
        _pendingReservation = null;
      }
      
      try {
        _validatedReservation = await ApiService.getMyValidatedReservation();
      } catch (e) {
        _validatedReservation = null;
      }
      
      _cancelledReservations = await ApiService.getMyCancelledReservations();
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل الحجوزات: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Enhanced refresh method with better UX


Future<void> _refreshReservations() async {
  if (_isRefreshing) return;
  
  setState(() => _isRefreshing = true);
  
  try {
    // Reset instruction settings when refreshing
    _instructionSettingsLoaded = false;
    _originClanSettings = null;
    _selectedClanSettings = null;
    _userProfile = null;
    _selectedClan = null;
    
    // Load all reservations first
    _allReservations = await ApiService.getMyAllReservations();
    
    // Load pending reservation with proper error handling
    try {
      _pendingReservation = await ApiService.getMyPendingReservation();
    } catch (e) {
      _pendingReservation = null;
    }
    
    // Load validated reservation with proper error handling
    try {
      _validatedReservation = await ApiService.getMyValidatedReservation();
    } catch (e) {
      _validatedReservation = null;
    }
    
    // Load cancelled reservations
    _cancelledReservations = await ApiService.getMyCancelledReservations();
    
  } catch (e) {
    if (mounted) {
      // Handle error silently or show minimal feedback
    }
  } finally {
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }
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
            Text('━━━━━━━━━━━━━━━━━━━━━━', textAlign: TextAlign.center),
            Text('📝 خطوات إتمام الحجز', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('━━━━━━━━━━━━━━━━━━━━━━', textAlign: TextAlign.center),
            SizedBox(height: 20),
            Text('للحصول على الموافقة النهائية، يجب طباعة الحجز وختمه وتوقيعه من:', textAlign: TextAlign.center),
            SizedBox(height: 20),
            Text('⊙ إدارة عشيرتك', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            Text(originClanName, textAlign: TextAlign.center),
            Text('🕐 $formattedSchedule', textAlign: TextAlign.center),
            SizedBox(height: 20),
            if (_isCrossClanReservation()) ...[
              Text('⊙ الدار المضيفة', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              Text(_getSelectedClanName(), textAlign: TextAlign.center),
              Text('🕐 ${_formatDayTimeSchedule(_getClanAcceptanceTime(false)['day'] ?? '', _getClanAcceptanceTime(false)['time'] ?? '')}', textAlign: TextAlign.center),
              SizedBox(height: 20),
            ],
            Text('⊙ الهيئة الدينية', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 20),
            Text('━━━━━━━━━━━━━━━━━━━━━━', textAlign: TextAlign.center),
            Text('⚠️ تنبيه ', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
            Text('━━━━━━━━━━━━━━━━━━━━━━', textAlign: TextAlign.center),
            SizedBox(height: 12),
            Text('يجب استكمال هذه الإجراءات خلال $daysMax أيام كحد أقصى', textAlign: TextAlign.center),
            Text('وإلا يُلغى الحجز تلقائياً', textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
            SizedBox(height: 12),
            Text('بعد ختم وتوقيع جميع الجهات، توجّه إلى إدارة عشيرتك', textAlign: TextAlign.center),
            Text(originClanName, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600)),
            Text('ليؤكد حجزك في النظام', textAlign: TextAlign.center),
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

String _getDayName(int dayNum) {
  switch (dayNum) {
    case 1: return 'الاثنين';
    case 2: return 'الثلاثاء';
    case 3: return 'الأربعاء';
    case 4: return 'الخميس';
    case 5: return 'الجمعة';
    case 6: return 'السبت';
    case 7: return 'الأحد';
    default: return 'غير محدد';
  }
}





/////
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
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
              subtitle: 'لم تقم بأي حجوزات حتى الآن\nاسحب لأسفل للتحديث',
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
              subtitle: 'جميع حجوزاتك تم التعامل معها\nاسحب لأسفل للتحديث',
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
              subtitle: 'لم يتم تأكيد أي حجوزات حتى الآن\nاسحب لأسفل للتحديث',
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
              subtitle: 'لم تقم بإلغاء أي حجوزات\nاسحب لأسفل للتحديث',
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
    // Format dates properly
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

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
            _buildInfoRow(Icons.location_city, 'المحافظة', _getCountyName(reservation)),
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
                    // If reservation is pending, switch to pending tab instead of showing dialog
                    if (reservation['status']?.toLowerCase() == 'pending_validation') {
                      _tabController.animateTo(1); // Index 1 is the pending tab
                    } else {
                      _showReservationDetails(reservation);
                    }
                  },
                  child: const Text('عرض التفاصيل'),
                ),
                // Only show download buttons if not cancelled
                if (!isCancelled)
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 4),
                        child: ElevatedButton.icon(
                          onPressed: () => _downloadPdf(reservation['id']),
                          icon: const Icon(Icons.download, size: 16),
                          label: const Text('تحميل', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            minimumSize: const Size(0, 28),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 4),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              setState(() => _isLoading = true);
                              final pdfBytes = await ApiService.downloadPdfFromServer(reservation['id']);
                              await _sharePdf(reservation['id'], pdfBytes);
                            } catch (e) {
                              _showSnackBar('خطأ في مشاركة الملف: $e', Colors.red);
                            } finally {
                              setState(() => _isLoading = false);
                            }
                          },
                          icon: const Icon(Icons.share, size: 16),
                          label: const Text('مشاركة', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
              _buildInfoRow(Icons.location_city, 'المحافظة', _getCountyName(reservation)),
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
            _buildDetailSection('المعلومات الشخصية', [
              _buildInfoRow(Icons.person, 'الاسم الكامل', _getFullName(reservation)),
              _buildInfoRow(Icons.cake, 'تاريخ الميلاد', reservation['birth_date'] ?? 'غير محدد'),
              _buildInfoRow(Icons.location_on, 'مكان الميلاد', reservation['birth_address'] ?? 'غير محدد'),
              _buildInfoRow(Icons.home_outlined, 'عنوان السكن', reservation['home_address'] ?? 'غير محدد'),
              _buildInfoRow(Icons.phone, 'رقم الهاتف', reservation['phone_number'] ?? 'غير محدد'),
            ]),
            
            const SizedBox(height: 16),
            
            // Guardian Information
            if (_hasGuardianInfo(reservation))
              _buildDetailSection('معلومات ولي الأمر', [
                _buildInfoRow(Icons.person_outline, 'اسم ولي الأمر', reservation['guardian_name'] ?? 'غير محدد'),
                _buildInfoRow(Icons.phone_android, 'هاتف ولي الأمر', reservation['guardian_phone'] ?? 'غير محدد'),
                _buildInfoRow(Icons.home_work, 'عنوان ولي الأمر', reservation['guardian_home_address'] ?? 'غير محدد'),
                _buildInfoRow(Icons.location_searching, 'مكان ولادة ولي الأمر', reservation['guardian_birth_address'] ?? 'غير محدد'),
                _buildInfoRow(Icons.calendar_today, 'تاريخ ولادة ولي الأمر', reservation['guardian_birth_date'] ?? 'غير محدد'),
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
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
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
                          Text('جاري تحميل معلومات الاستقبال...'),
                        ],
                      ),
                    );
                  }
                  
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 253, 227, 227),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color.fromARGB(255, 249, 144, 144)),
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header section
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info,
                                color: const Color.fromARGB(255, 249, 144, 144),
                                size: 32,
                              ),
                              // const SizedBox(height: 8),
                              // Text(
                              //   'ملاحظة مهمة',
                              //   style: TextStyle(
                              //     fontSize: 16,
                              //     fontWeight: FontWeight.bold,
                              //     color: const Color.fromARGB(255, 0, 0, 0),
                              //   ),
                              //   textAlign: TextAlign.center,
                              // ),
                            ],
                          ),
                          // const SizedBox(height: 8),
                          _buildReservationInstructionWidget(),

                          // Dynamic instruction text
                          // Text(
                          //   _buildReservationInstructionText(),
                          //   style: TextStyle(
                          //     fontSize: 14,
                          //     color: const Color.fromARGB(255, 0, 0, 0),
                          //     height: 1.5,
                          //   ),
                          //   textAlign: TextAlign.start,
                          // ),
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
              _buildDetailSection('تحميل ومشاركة الملفات', [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.picture_as_pdf,
                        size: 48,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'ملف الحجز جاهز للتحميل والمشاركة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'يمكنك تحميل ملف PDF أو مشاركته مباشرة',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _downloadPdf(reservation['id']),
                              icon: const Icon(Icons.download),
                              label: const Text('تحميل ملف PDF'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  setState(() => _isLoading = true);
                                  final pdfBytes = await ApiService.downloadPdfFromServer(reservation['id']);
                                  await _sharePdf(reservation['id'], pdfBytes);
                                } catch (e) {
                                  _showSnackBar('خطأ في مشاركة الملف: $e', Colors.red);
                                } finally {
                                  setState(() => _isLoading = false);
                                }
                              },
                              icon: const Icon(Icons.share),
                              label: const Text('مشاركة الملف'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
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
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
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
          if (actionButton != null) ...[
            const SizedBox(height: 24),
            actionButton,
          ],
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
        await ApiService.cancelMyReservation(reservationId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إلغاء الحجز بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          _refreshReservations(); // Use enhanced refresh method
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

  // Updated _downloadPdf method with improved functionality
Future<void> _downloadPdf(int reservationId) async {
  try {
    setState(() => _isLoading = true);
    _showSnackBar('جاري تحميل الملف...', Colors.blue.shade400);
    
    // Download the PDF
    final pdfBytes = await ApiService.downloadPdfFromServer(reservationId);
    
    // Save the file
    final savedFile = await _savePdfFile(pdfBytes, reservationId);
    
    if (savedFile != null) {
      _showSnackBar('تم تحميل الملف بنجاح', Colors.green.shade400);
      
      // Show options dialog
      _showPdfActionsDialog(savedFile.path, reservationId, pdfBytes);
    }
  } catch (e) {
    print('Download error: $e');
    _showSnackBar('خطأ في تحميل الملف: $e', Colors.red.shade400);
  } finally {
    setState(() => _isLoading = false);
  }
}
Future<void> _sharePdf(int reservationId, Uint8List pdfBytes) async {
  try {
    // Create a temporary file for sharing
    final tempDir = await getTemporaryDirectory();
    final fileName = 'reservation_${reservationId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final tempFile = File('${tempDir.path}/$fileName');
    
    await tempFile.writeAsBytes(pdfBytes);
    
    // Share the file
    await Share.shareXFiles(
      [XFile(tempFile.path)],
      text: 'ملف حجز رقم $reservationId',
      subject: 'حجز الزفاف رقم $reservationId',
    );
    
    _showSnackBar('تم فتح خيارات المشاركة', Colors.green.shade400);
  } catch (e) {
    print('Share error: $e');
    _showSnackBar('خطأ في مشاركة الملف: $e', Colors.red.shade400);
  }
}

// Add this new method to show PDF action options
void _showPdfActionsDialog(String filePath, int reservationId, Uint8List pdfBytes) {
  if (!mounted) return;
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('تم تحميل الملف'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('تم حفظ ملف PDF بنجاح. '),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.info, color: Colors.blue, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'الملف محفوظ في مجلد التحميلات',
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق'),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            Navigator.pop(context);
            await _sharePdf(reservationId, pdfBytes);
          },
          icon: const Icon(Icons.share),
          label: const Text('مشاركة'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            Navigator.pop(context);
            try {
              await OpenFile.open(filePath);
            } catch (e) {
              _showSnackBar('لا يمكن فتح الملف تلقائياً', Colors.orange);
            }
          },
          icon: const Icon(Icons.open_in_new),
          label: const Text('فتح'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    ),
  );
}

  // Save PDF file to device
Future<File?> _savePdfFile(Uint8List pdfBytes, int reservationId) async {
  try {
    Directory? directory;
    
    if (Platform.isAndroid) {
      // Request storage permission first
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          // Try with manage external storage permission for Android 11+
          status = await Permission.manageExternalStorage.request();
          if (!status.isGranted) {
            throw Exception('يجب منح صلاحية الوصول للتخزين لحفظ الملف');
          }
        }
      }
      
      // Try to save to Downloads folder (public directory)
      try {
        final downloadsPath = '/storage/emulated/0/Download';
        directory = Directory(downloadsPath);
        
        if (!await directory.exists()) {
          // Fallback to external storage directory
          directory = await getExternalStorageDirectory();
          if (directory != null) {
            // Try to create a public-like path
            final publicPath = Directory('/storage/emulated/0/Android/data/${directory.path.split('/').last}/files/Download');
            await publicPath.create(recursive: true);
            directory = publicPath;
          }
        }
      } catch (e) {
        // Final fallback to app directory
        directory = await getExternalStorageDirectory();
      }
    } else {
      // iOS - use documents directory
      directory = await getApplicationDocumentsDirectory();
    }
    
    if (directory == null) {
      throw Exception('لا يمكن الوصول إلى مجلد التخزين');
    }
    
    // Ensure directory exists
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    
    // Create file with descriptive name
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'حجز_زفاف_${reservationId}_$timestamp.pdf';
    final file = File('${directory.path}/$fileName');
    
    // Write bytes to file
    await file.writeAsBytes(pdfBytes);
    
    return file;
  } catch (e) {
    print('Error saving file: $e');
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

  // Show dialog with file location when auto-open fails
  void _showFileLocationDialog(String filePath) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تم حفظ الملف'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('تم حفظ ملف PDF بنجاح في:'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                filePath,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'يمكنك العثور على الملف في مجلد التحميلات أو في مدير الملفات.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Try to open file again
              try {
                await OpenFile.open(filePath);
              } catch (e) {
                _showSnackBar('لا يمكن فتح الملف تلقائياً', Colors.orange);
              }
            },
            child: const Text('فتح الملف'),
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