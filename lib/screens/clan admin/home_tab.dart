// lib/screens/clan admin/home_tab.dart
import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedding_reservation_app/models/reservation_special.dart';
import 'package:wedding_reservation_app/providers/theme_provider.dart';
import 'package:wedding_reservation_app/screens/clan%20admin/bulk_upload_grooms_screen.dart';
import 'package:wedding_reservation_app/screens/clan%20admin/custom_calendar_picker_view.dart';
import 'package:wedding_reservation_app/screens/clan%20admin/expiring_reservations_page.dart';
import 'package:wedding_reservation_app/screens/clan%20admin/manual_register_groom_screen.dart';
import 'package:wedding_reservation_app/services/connectivity_service.dart';
import 'package:wedding_reservation_app/services/foreground_notification_service.dart';
import 'package:wedding_reservation_app/services/notification_service.dart';
import 'package:wedding_reservation_app/services/token_manager.dart';
import 'package:wedding_reservation_app/utils/constants.dart';
import 'package:wedding_reservation_app/widgets/notification_panel.dart';

import '../../services/api_service.dart';
import '../../utils/colors.dart';

class HomeTab extends StatefulWidget {
  final Function(int)? onNavigateToTab;
  
  const HomeTab({super.key, this.onNavigateToTab});
  
  @override
  HomeTabState createState() => HomeTabState();
}

class HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _refreshAnimationController;
  late Animation<double> _refreshAnimation;

  // Dynamic data variables
  bool _isLoading = false;
  Map<String, dynamic> _dashboardData = {
    'halls_count': 0,
    'reservations_count': 0,
    'grooms_count': 0,
    'menus_count': 0,
    'pending_reservations': 0,
    'validated_reservations': 0,
    'cancelled_reservations': 0,
  };
  List<dynamic> _recentActivities = [];
  String _adminName = 'مدير العشيرة';
  String _ClanName = '';
  Timer? _notificationTimer;
  int _lastUnreadCount = 0;
  // Add these new state variables after existing ones
Map<String, dynamic> _clanStats = {
    'today': 0,
    'month': 0,
    'year': 0,
    'today_data': [],
    'month_data': [],
    'year_data': [],
  };
  
  Map<String, dynamic> _countyStats = {
    'today': 0,
    'month': 0,
    'year': 0,
    'today_data': [],
    'month_data': [],
    'year_data': [],
  };

  bool _statsLoading = false;
bool _isClanChartExpanded = true;
bool _isCountyChartExpanded = false;
String _clanSelectedPeriod = 'year';
String _countySelectedPeriod = 'year';

// Add after existing state variables (around line 50)
Map<String, DateAvailability> _calendarDateAvailabilities = {};
bool _calendarLoading = false;
DateTime _displayMonth = DateTime.now();
int _clanId = 0;
// Add after _displayMonth = DateTime.now();
bool _showYearPicker = false;


bool _offlineBannerShown = false;


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _refreshAnimationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _refreshAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _refreshAnimationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
    _loadDashboardData();
    _startNotificationPolling();
      _loadCalendarData(); // ADD THIS LINE

  }
// Add this helper method to fetch clan info
Future<Map<String, dynamic>?> _getClanInfo(int clanId) async {
  try {
    // Use the getAllClans API and filter by clan_id
    final clans = await ApiService.getAllClans();
    final clan = clans.firstWhere(
      (c) => c.id == clanId,
      orElse: () => throw Exception('Clan not found'),
    );
    
    return {
      'clan_id': clan.id,
      'clan_name': clan.name,
      'county_id': clan.countyId,
    };
  } catch (e) {
    print('Error fetching clan info: $e');
    return null;
  }
}

Future<void> _loadCalendarData() async {
  setState(() => _calendarLoading = true);

  final isOnline = ConnectivityService().isOnline ||
      await ConnectivityService().checkRealInternet();

  if (!isOnline) {
  if (mounted) setState(() => _calendarLoading = false);
  return; // silent
}

  try {
    final userInfo = await ApiService.getCurrentUserInfo();
    final clanId = userInfo['clan_id'];

    if (clanId == null) {
      setState(() => _calendarLoading = false);
      return;
    }

    setState(() => _clanId = clanId);

    final results = await Future.wait([
      ApiService.getGroomsWithValidatedReservations(clanId).catchError((_) => <dynamic>[]),
      ApiService.getGroomsWithPendingReservations(clanId).catchError((_) => <dynamic>[]),
      ApiService.getSpecialReservations(clanId).catchError((_) => <ReservationSpecial>[]),
      ApiService.getGroomsWithValidatedReservationsNotBelong(clanId).catchError((_) => <dynamic>[]),
      ApiService.getGroomsWithPendingReservationsNotBelong(clanId).catchError((_) => <dynamic>[]),
    ]);

    final validatedReservations   = results[0] as List<dynamic>;
    final pendingReservations     = results[1] as List<dynamic>;
    final specialReservations     = results[2] as List<ReservationSpecial>;
    final validatedNotBelong      = results[3] as List<dynamic>;
    final pendingNotBelong        = results[4] as List<dynamic>;
// In _loadCalendarData, replace enrichReservation:
Map<String, dynamic> enrichReservation(dynamic reservation, bool notBelong) {
  final enriched = Map<String, dynamic>.from(reservation);
  enriched['reservation_clan_id'] = reservation['clan_id'];
  enriched['not_belong_to_clan'] = notBelong;
  if (reservation['groom'] != null) {
    final groom = reservation['groom'];
    enriched['first_name']      = groom['first_name'];
    enriched['last_name']       = groom['last_name'];
    enriched['father_name']     = groom['father_name'];
    enriched['phone_number']    = groom['phone_number'];
    enriched['guardian_name']   = groom['guardian_name'];
    enriched['guardian_phone']  = groom['guardian_phone'];
    enriched['groom_clan_id']   = groom['clan_id'];
    enriched['groom_clan_name'] = groom['clan_name']; // NEW - direct from backend
  }
  return enriched;
}

    Map<String, List<Map<String, dynamic>>> validatedByDate = {};
    Map<String, List<Map<String, dynamic>>> pendingByDate   = {};

    for (var r in validatedReservations) {
      final e = enrichReservation(r, false);
      for (var key in ['date1', 'date2']) {
        final d = r[key]; if (d != null) validatedByDate.putIfAbsent(d, () => []).add(e);
      }
    }
    for (var r in validatedNotBelong) {
      final e = enrichReservation(r, true);
      for (var key in ['date1', 'date2']) {
        final d = r[key]; if (d != null) validatedByDate.putIfAbsent(d, () => []).add(e);
      }
    }
    for (var r in pendingReservations) {
      final e = enrichReservation(r, false);
      for (var key in ['date1', 'date2']) {
        final d = r[key]; if (d != null) pendingByDate.putIfAbsent(d, () => []).add(e);
      }
    }
    for (var r in pendingNotBelong) {
      final e = enrichReservation(r, true);
      for (var key in ['date1', 'date2']) {
        final d = r[key]; if (d != null) pendingByDate.putIfAbsent(d, () => []).add(e);
      }
    }

    Set<String> specialDates = {};
    Map<String, ReservationSpecial> specialMap = {};
    for (var r in specialReservations) {
      specialDates.add(r.date);
      specialMap[r.date] = r;
    }

    Map<String, DateAvailability> newAvailabilities = {};
    Set<String> allDates = {...validatedByDate.keys, ...pendingByDate.keys, ...specialDates};

    for (String dateStr in allDates) {
      final date      = DateTime.parse(dateStr);
      final validated = validatedByDate[dateStr] ?? [];
      final pending   = pendingByDate[dateStr]   ?? [];
      final allRes    = [...validated, ...pending];

      DateStatus status;
      String note;

      if (specialDates.contains(dateStr)) {
        status = DateStatus.specialReservation;
        note = 'حجز خاص من العشيرة';
      } else if (validated.isNotEmpty && pending.isNotEmpty) {
        status = DateStatus.mixed;
        note = '${validated.length} مؤكد + ${pending.length} في الانتظار';
      } else if (validated.isNotEmpty) {
        status = DateStatus.reserved;
        note = '${validated.length} حجز مؤكد';
      } else if (pending.isNotEmpty) {
        status = DateStatus.pending;
        note = '${pending.length} في الانتظار';
      } else {
        status = DateStatus.available;
        note = 'متاح';
      }

      newAvailabilities[dateStr] = DateAvailability(
        date: date,
        status: status,
        currentCount: allRes.length,
        validatedCount: validated.length,
        pendingCount: pending.length,
        maxCapacity: 3,
        reservations: allRes,
        validatedReservations: validated,
        pendingReservations: pending,
        note: note,
        specialReservation: specialMap[dateStr],
      );
    }

    setState(() {
      _calendarDateAvailabilities = newAvailabilities;
      _calendarLoading = false;
    });
  } catch (e) {
    print('Error loading calendar data: $e');
    if (mounted) setState(() => _calendarLoading = false);
  }
}

void _debugStatisticsData() {
  print('═════════════════════════════════════════');
  print('🔍 STATISTICS DEBUG INFORMATION');
  print('═════════════════════════════════════════');
  
  print('\n📊 CLAN STATISTICS:');
  print('Today Count: ${_clanStats['today']}');
  print('Month Count: ${_clanStats['month']}');
  print('Year Count: ${_clanStats['year']}');
  print('Today Data Length: ${(_clanStats['today_data'] as List?)?.length ?? 0}');
  print('Month Data Length: ${(_clanStats['month_data'] as List?)?.length ?? 0}');
  print('Year Data Length: ${(_clanStats['year_data'] as List?)?.length ?? 0}');
  
  if ((_clanStats['year_data'] as List?)?.isNotEmpty ?? false) {
    print('\nSample Year Data:');
    final yearData = _clanStats['year_data'] as List;
    for (var i = 0; i < (yearData.length > 3 ? 3 : yearData.length); i++) {
      print('  Reservation $i: ${yearData[i]}');
    }
  }
  
  print('\n📊 COUNTY STATISTICS:');
  print('Today Count: ${_countyStats['today']}');
  print('Month Count: ${_countyStats['month']}');
  print('Year Count: ${_countyStats['year']}');
  print('Today Data Length: ${(_countyStats['today_data'] as List?)?.length ?? 0}');
  print('Month Data Length: ${(_countyStats['month_data'] as List?)?.length ?? 0}');
  print('Year Data Length: ${(_countyStats['year_data'] as List?)?.length ?? 0}');
  
  print('\n═════════════════════════════════════════\n');
}

void _startNotificationPolling() {
  _notificationTimer = Timer.periodic(
    const Duration(seconds: 30),
    (timer) async {
      // Skip silently when offline
      if (!ConnectivityService().isOnline) return;
      try {
        final newCount = await ApiService.getUnreadNotificationCount();
        if (newCount > _lastUnreadCount && mounted) {
          setState(() => _lastUnreadCount = newCount);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لديك إشعارات جديدة'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        // Silent — no error popup during polling
      }
    },
  );
}

void _showOfflineSnackbar() {
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: const [
          Icon(Icons.wifi_off, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text('لا يوجد اتصال بالإنترنت'),
        ],
      ),
      backgroundColor: Colors.red.shade700,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}


  @override
  void dispose() {
    _animationController.dispose();
    _refreshAnimationController.dispose();
    _notificationTimer?.cancel();
    super.dispose();
  }
void _navigateToTab(int tabIndex) {
  if (widget.onNavigateToTab != null) {
    widget.onNavigateToTab!(tabIndex);
  }
}


void _showLogoutDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('تسجيل الخروج'),
      content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          // onPressed: () async {
          //     await TokenManager.clearToken(); // ← ADD THIS
          //     ApiService.clearToken();         // keep this too
          //     // await NotificationManager().stopMonitoring(); // ✅ now awaited
          //     await NotificationManager().cancelAllNotifications();
          //     if (!context.mounted) return;
          //     Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          //   },
          onPressed: () async {
            // ── 1. Clear auth token ──
            await TokenManager.clearToken();
            await ApiService.clearToken();
 
            // ── 2. Clear stored credentials from SharedPreferences ──
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('auth_token');
            await prefs.remove('user_role');
 
            // ── 3. Stop notification services & clear tracking ──
            await WeddingNotificationService().clearOnLogout();
            await WeddingForegroundNotificationService().stopService();
 
            if (!context.mounted) return;
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/login', (route) => false);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text('تسجيل الخروج'),
        ),
      ],
    ),
  );
}

// Future<void> _loadDashboardData() async {
//   if (!mounted) return;

//   // Check connectivity before making any API calls
//   final isOnline = ConnectivityService().isOnline ||
//       await ConnectivityService().checkRealInternet();

//   if (!isOnline) {
//     if (mounted) setState(() => _isLoading = false);
//     _showOfflineSnackbar();
//     return;
//   }

//   setState(() => _isLoading = true);
Future<void> _loadDashboardData() async {
  if (!mounted) return;

  final isOnline = ConnectivityService().isOnline ||
      await ConnectivityService().checkRealInternet();

  if (!isOnline) {
    if (mounted) {
      setState(() => _isLoading = false);
      if (!_offlineBannerShown) {
        _offlineBannerShown = true;
        _showOfflineSnackbar();
      }
    }
    return;
  }

  _offlineBannerShown = false; // reset when online
  setState(() => _isLoading = true);

  try {
    final futures = await Future.wait([
      ApiService.listHalls().catchError((_) => <dynamic>[]),
      ApiService.listGrooms().catchError((_) => <dynamic>[]),
      ApiService.getClanMenus().catchError((_) => <dynamic>[]),
      ApiService.getAllReservations().catchError((_) => <dynamic>[]),
      ApiService.getPendingReservations().catchError((_) => <dynamic>[]),
      ApiService.getValidatedReservations().catchError((_) => <dynamic>[]),
      ApiService.getCancelledReservations().catchError((_) => <dynamic>[]),
      ApiService.getCurrentUserInfo().catchError((_) => <String, dynamic>{}),
    ]);

    if (!mounted) return;

    final halls = futures[0] as List<dynamic>;
    final grooms = futures[1] as List<dynamic>;
    final menus = futures[2] as List<dynamic>;
    final allReservations = futures[3] as List<dynamic>;
    final pendingReservations = futures[4] as List<dynamic>;
    final validatedReservations = futures[5] as List<dynamic>;
    final cancelledReservations = futures[6] as List<dynamic>;
    final userInfo = futures[7] as Map<String, dynamic>;

    _recentActivities = _generateRecentActivities(
        halls, grooms, menus, allReservations);
    await _loadStatisticsData();

    setState(() {
      _dashboardData = {
        'halls_count': halls.length,
        'reservations_count': allReservations.length,
        'grooms_count': grooms.length,
        'menus_count': menus.length,
        'pending_reservations': pendingReservations.length,
        'validated_reservations': validatedReservations.length,
        'cancelled_reservations': cancelledReservations.length,
      };
      _adminName = _extractAdminName(userInfo);
      _ClanName = userInfo['clan_name'] ?? '';
      _isLoading = false;
    });

    _refreshAnimationController.forward().then((_) {
      _refreshAnimationController.reverse();
    });
  } catch (e) {
    if (!mounted) return;
    setState(() => _isLoading = false);
    print('Error loading dashboard data: $e');
  }
}

Future<void> _loadStatisticsData() async {
  if (!mounted) return;

  final isOnline = ConnectivityService().isOnline ||
      await ConnectivityService().checkRealInternet();

  if (!isOnline) {
  if (mounted) setState(() => _statsLoading = false);
  return; // silent — home already showed banner
}

  setState(() => _statsLoading = true);

  try {
    final results = await Future.wait([
      ApiService.getValidatedReservationsToday().catchError((_) => <String, dynamic>{}),
      ApiService.getValidatedReservationsMonth().catchError((_) => <String, dynamic>{}),
      ApiService.getValidatedReservationsYear().catchError((_) => <String, dynamic>{}),
      ApiService.getValidatedReservationsTodayCounty().catchError((_) => <String, dynamic>{}),
      ApiService.getValidatedReservationsMonthCounty().catchError((_) => <String, dynamic>{}),
      ApiService.getValidatedReservationsYearCounty().catchError((_) => <String, dynamic>{}),
    ]);

    if (!mounted) return;

    final clanToday    = results[0] as Map<String, dynamic>;
    final clanMonth    = results[1] as Map<String, dynamic>;
    final clanYear     = results[2] as Map<String, dynamic>;
    final countyToday  = results[3] as Map<String, dynamic>;
    final countyMonth  = results[4] as Map<String, dynamic>;
    final countyYear   = results[5] as Map<String, dynamic>;

    setState(() {
      _clanStats = {
        'today': clanToday['count'] ?? 0,
        'month': clanMonth['count'] ?? 0,
        'year':  clanYear['count']  ?? 0,
        'today_data': clanToday['reservations'] ?? [],
        'month_data': clanMonth['reservations'] ?? [],
        'year_data':  clanYear['reservations']  ?? [],
      };
      _countyStats = {
        'today': countyToday['count'] ?? 0,
        'month': countyMonth['count'] ?? 0,
        'year':  countyYear['count']  ?? 0,
        'today_data': countyToday['reservations'] ?? [],
        'month_data': countyMonth['reservations'] ?? [],
        'year_data':  countyYear['reservations']  ?? [],
      };
      _statsLoading = false;
    });
    _debugStatisticsData();
  } catch (e) {
    if (!mounted) return;
    setState(() => _statsLoading = false);
    print('❌ Error loading statistics: $e');
  }
}
  // Public method to refresh data from parent
  void refreshData() {
    _loadDashboardData();
  }

  String _extractAdminName(Map<String, dynamic> userInfo) {
    if (userInfo.isEmpty) return 'مدير العشيرة';
    
    final firstName = userInfo['first_name'] ?? '';
    final lastName = userInfo['last_name'] ?? '';
    
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    } else if (firstName.isNotEmpty) {
      return firstName;
    } else {
      return 'مدير العشيرة';
    }
  }

  List<Map<String, dynamic>> _generateRecentActivities(
    List<dynamic> halls,
    List<dynamic> grooms,
    List<dynamic> menus,
    List<dynamic> reservations,
  ) {
    List<Map<String, dynamic>> activities = [];

    // Add recent reservations
    if (reservations.isNotEmpty) {
      final recentReservations = reservations.take(2).toList();
      for (var reservation in recentReservations) {
        activities.add({
          'icon': Icons.book_outlined,
          'title': 'حجز جديد',
          'subtitle': '${reservation['guardian_name'] ?? 'غير محدد'} - ${_formatTimeAgo(reservation['created_at'])}',
          'color': Colors.orange,
        });
      }
    }

    // Add recent grooms
    if (grooms.isNotEmpty) {
      final recentGrooms = grooms.take(1).toList();
      for (var groom in recentGrooms) {
        activities.add({
          'icon': Icons.person_add_outlined,
          'title': 'عريس جديد',
          'subtitle': '${groom['first_name'] ?? ''} ${groom['last_name'] ?? ''} - ${_formatTimeAgo(groom['created_at'])}',
          'color': Colors.blue,
        });
      }
    }

    // Add recent menus
    if (menus.isNotEmpty) {
      final recentMenu = menus.first;
      activities.add({
        'icon': Icons.restaurant_menu,
        'title': 'قائمة طعام محدثة',
        'subtitle': '${recentMenu['name'] ?? 'قائمة جديدة'} - ${_formatTimeAgo(recentMenu['created_at'])}',
        'color': Colors.purple,
      });
    }

    // Add halls info
    if (halls.isNotEmpty) {
      activities.add({
        'icon': Icons.add_circle_outline,
        'title': 'إجمالي القاعات',
        'subtitle': 'يتم إدارة ${halls.length} قاعة حالياً',
        'color': Colors.green,
      });
    }

    return activities.take(4).toList();
  }

  String _formatTimeAgo(dynamic createdAt) {
    if (createdAt == null) return 'منذ وقت قريب';
    
    try {
      final date = DateTime.parse(createdAt.toString());
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return 'منذ ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}';
      } else if (difference.inHours > 0) {
        return 'منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
      } else if (difference.inMinutes > 0) {
        return 'منذ ${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
      } else {
        return 'منذ لحظات';
      }
    } catch (e) {
      return 'منذ وقت قريب';
    }
  }

 @override
Widget build(BuildContext context) {
  final screenSize = MediaQuery.of(context).size;
  final isTablet = screenSize.width > 768;
  final isMobile = screenSize.width <= 480;

  return Scaffold(
    appBar: _buildSliverAppBar(isMobile),
    body: RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: AppColors.primary,
      backgroundColor: Colors.white,
      displacement: 20,
      child: CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : (isTablet ? 32 : 20),
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeCard(isMobile, isTablet),
                    SizedBox(height: isMobile ? 24 : 32),
                    _buildExpiringReservationsBanner(isMobile),
                    SizedBox(height: isMobile ? 16 : 20),
                    _buildCalendarOverview(isMobile, isTablet),
                    SizedBox(height: isMobile ? 24 : 32),
                    _buildStatsCards(isMobile, isTablet),
                    SizedBox(height: isMobile ? 24 : 32),
                    _buildQuickActions(context),
                    SizedBox(height: isMobile ? 24 : 32),
                    _buildRecentActivity(isMobile, isTablet),
                    // SizedBox(height: 80),
                    SizedBox(height: isMobile ? 24 : 32),
                    _buildStatisticsSection(isMobile, isTablet), // ADD THIS LINE
                    SizedBox(height: 80),


                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildExpiringReservationsBanner(bool isMobile) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ExpiringReservationsPage(),
      ),
    ),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [Color(0xFF7F0000), Color(0xFFB71C1C)]
              : [Color(0xFFFFCDD2), Color(0xFFEF9A9A)],
        ),
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(
          color: isDark
              ? Colors.red.shade700
              : Colors.red.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.15),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 10 : 12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: isDark ? Colors.red.shade200 : Colors.red.shade700,
              size: isMobile ? 24 : 28,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حجوزات قريبة الانتهاء',
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 17,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.red.shade100 : Colors.red.shade800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'اضغط لعرض الحجوزات التي تقترب من تاريخ انتهائها',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    color: isDark
                        ? Colors.red.shade200.withOpacity(0.85)
                        : Colors.red.shade700.withOpacity(0.85),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_left,
            color: isDark ? Colors.red.shade200 : Colors.red.shade600,
            size: isMobile ? 20 : 24,
          ),
        ],
      ),
    ),
  );
}
PreferredSizeWidget _buildSliverAppBar(bool isMobile) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return AppBar(
    
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    elevation: 0,
    automaticallyImplyLeading: false,
    flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? AppColors.primary.withOpacity(0.4):AppColors.primary.withOpacity(0.8) ,
            AppColors.primary,
            AppColors.primary,
            isDark ? AppColors.primary.withOpacity(0.4):AppColors.primary.withOpacity(0.8) ,
            // isDark ? AppColors.primary.withOpacity(0.4):const Color.fromARGB(255, 130, 161, 112).withOpacity(0.9),
            
          ],
        ),
      ),
    ),
    title: Text(
      AppConstants.appName,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: isMobile ? 16 : 20,
      ),
    ),
    actions: [
      Container(
        margin: EdgeInsets.only(right: isMobile ? 4 : 8),
        child: Stack(
          children: [
            FutureBuilder<int>(
              future: ApiService.getUnreadNotificationCount(),
              builder: (context, snapshot) {
                final unreadCount = snapshot.data ?? 0;
                
                return IconButton(
                  icon: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          size: 20,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationPanel(),
                      ),
                    );
                  },
                );
              },
            ),
               
            Positioned(
              right: isMobile ? 6 : 8,
              top: isMobile ? 6 : 8,
              child: AnimatedBuilder(
                animation: _refreshAnimation,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_refreshAnimation.value * 0.3),
                    child: child,
                  );
                },
              ),
            ),
          ],
        ),
      ),
              const SizedBox(width: 8),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 20,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          onPressed: () {
            // Toggle theme using the provider
            final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
            themeProvider.toggleTheme();
          },
          tooltip: isDark ? 'الوضع الفاتح' : 'الوضع الداكن',
        ),
      PopupMenuButton<String>(
        icon: CircleAvatar(
          radius: isMobile ? 16 : 18,
          backgroundColor: Colors.white.withOpacity(0.2),
          child: Icon(Icons.logout, 
            color: Colors.white, 
            size: isMobile ? 18 : 20),
        ),
        onSelected: (String value) {
          if (value == 'logout') {
            _showLogoutDialog();
          } else if (value == 'profile') {
            _navigateToTab(8);
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          // PopupMenuItem<String>(
          //   value: 'profile',
          //   child: Row(
          //     children: [
          //       Icon(Icons.person_outline, color: AppColors.primary),
          //       SizedBox(width: 8),
          //       Text('الملف الشخصي'),
          //     ],
          //   ),
          // ),
          // PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'logout',
            child: Row(
              children: [
                Icon(Icons.logout, color: Colors.red),
                SizedBox(width: 8),
                Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
        color: Theme.of(context).cardColor, // Changed for dark mode
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ],
  );
}
  Widget _buildWelcomeCard(bool isMobile, bool isTablet) {
      final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.5),
            AppColors.primary,
            AppColors.primary,
            AppColors.primary.withOpacity(0.5),
            // isDark ? const Color.fromARGB(102, 118, 84, 25).withOpacity(0.8) : const Color.fromARGB(255, 176, 126, 39).withOpacity(0.8) ,
            // isDark ? const Color.fromARGB(103, 107, 76, 22).withOpacity(0.8) : const Color.fromARGB(255, 183, 143, 58).withOpacity(0.9) ,
            
          ],
        ),
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.5),
            spreadRadius: 10,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_ClanName',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 22 : (isTablet ? 32 : 28),
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'لوحة تحكم شاملة لإدارة جميع جوانب العشيرة',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (isTablet) ...[
                      SizedBox(height: 16),
                      Row(
                        children: [
                          _buildMiniStatCard('الحجوزات', _dashboardData['reservations_count'].toString()),
                          SizedBox(width: 16),
                          _buildMiniStatCard('العرسان', _dashboardData['grooms_count'].toString()),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                ),
                child: Icon(
                  Icons.dashboard_outlined,
                  color: Colors.white,
                  size: isMobile ? 24 : 32,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatCard(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
Widget _buildStatsCards(bool isMobile, bool isTablet) {
  final stats = [
    {
      'title': 'القاعات',
      'value': _dashboardData['halls_count'].toString(),
      'icon': Icons.castle_outlined,
      'color': Colors.blue,
      'trend': '+2.5%'
    },
    {
      'title': 'الحجوزات',
      'value': _dashboardData['reservations_count'].toString(),
      'icon': Icons.book_outlined,
      'color': Colors.green,
      'trend': '+12.3%'
    },
    {
      'title': 'العرسان',
      'value': _dashboardData['grooms_count'].toString(),
      'icon': Icons.group_outlined,
      'color': Colors.orange,
      'trend': '+8.1%'
    },
    if (!isMobile) {
      'title': 'القوائم',
      'value': _dashboardData['menus_count'].toString(),
      'icon': Icons.restaurant_menu,
      'color': Colors.purple,
      'trend': '+5.7%'
    },
  ];

  return LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      
      // More granular breakpoints for better responsiveness
      int crossAxisCount;
      double childAspectRatio;
      
      if (width < 480) {
        // Small mobile
        crossAxisCount = 2;
        childAspectRatio = 1.15;
      } else if (width < 600) {
        // Large mobile
        crossAxisCount = 2;
        childAspectRatio = 1.2;
      } else if (width < 900) {
        // Tablet portrait
        crossAxisCount = 3;
        childAspectRatio = 1.25;
      } else if (width < 1200) {
        // Tablet landscape / Small desktop
        crossAxisCount = 4;
        childAspectRatio = 1.3;
      } else if (width < 1600) {
        // Desktop
        crossAxisCount = 4;
        childAspectRatio = 1.35;
      } else {
        // Large desktop / Ultra-wide
        crossAxisCount = 4;
        childAspectRatio = 1.4;
      }
      
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: width < 600 ? 10 : 16,
          crossAxisSpacing: width < 600 ? 10 : 16,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index] as Map<String, dynamic>;
          return _buildStatCard(
            stat['title'],
            stat['value'],
            stat['icon'],
            stat['color'],
            stat['trend'],
            width < 600, // Pass isMobile based on width
          );
        },
      );
    },
  );
}
Widget _buildStatCard(String title, String value, IconData icon, Color color, 
                     String trend, bool isMobile) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  return Container(
    padding: EdgeInsets.all(isMobile ? 12 : 16),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor, // Changed for dark mode
      borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
      boxShadow: [
        BoxShadow(
          color: isDark 
            ? const Color.fromARGB(255, 20, 102, 13).withOpacity(0.3)
            : const Color.fromARGB(255, 173, 255, 135).withOpacity(0.04),
          spreadRadius: 0,
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
      border: Border.all(
        color: isDark 
          ? Colors.white.withOpacity(0.1)
          : Colors.grey.withOpacity(0.1)
      ),

    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 6 : 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
              ),
              child: Icon(icon, color: color, size: isMobile ? 30 : 37),
            ),
            if (!isMobile)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: isMobile ? 18 : 24,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).textTheme.bodyLarge?.color, // Changed
              ),
            ),
            SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: isMobile ? 10 : 12,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7), // Changed
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildQuickActions(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isCompact = screenWidth < 600;
  final crossAxisCount = screenWidth < 600 ? 2 : screenWidth < 900 ? 3 : screenWidth < 1200 ? 4 : 5;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  final actions = [
    (Icons.castle_outlined, 'القاعات', '${_dashboardData['halls_count']} قاعة', Color(0xFF1877F2), 1),
    (Icons.group_outlined, 'العرسان', '${_dashboardData['grooms_count']} مسجل', Color(0xFF42B72A), 2),
    (Icons.book_outlined, 'الحجوزات', '${_dashboardData['pending_reservations']} معلق', Color(0xFFE4405F), 3),
    (Icons.restaurant_outlined, 'قوائم الطعام', '${_dashboardData['menus_count']} قائمة', Color(0xFFFF6F00), 4),
    (Icons.settings_outlined, 'الإعدادات', ' إعداد النظام', Color(0xFF1565C0), 5),
    (Icons.notifications_outlined, 'الإشعارات', ' إرسال إشعارات', Color(0xFF9C27B0), 9),
    (Icons.rule_outlined, 'اللوازم ', ' لوازم العريس ', Color(0xFF00BCD4), 7),
    (Icons.star_border_outlined, 'الحجوزات الخاصة', ' حجز أيام خاصة بالعشيرة', Color(0xFFF57C00), 8),
    // (Icons.lock_outline, '  كلمة المرور للوصول ', ' انشاء كلمة المرور للوصول الى الصفحات الخاصة', Color.fromARGB(255, 0, 245, 53), 10),
    (Icons.stacked_bar_chart, '  الإحصائيات ', ' تنزيل الإحصائيات على الجهاز', Color.fromARGB(255, 0, 159, 245), 10),
    (Icons.warning_amber_rounded, 'حجوزات قريبة الانتهاء', 'عرض الحجوزات قريبة الانتهاء', Color(0xFFD32F2F), -3),
    // NEW ACTIONS - Add these two new items
    (Icons.person_add_alt_outlined, 'تسجيل عريس يدوي', ' إضافة عريس جديد ي  دوياً', Color(0xFF00897B), -1), // -1 for manual navigation
    // (Icons.upload_file_outlined, 'تحميل عرسان جماعي', ' رفع ملف Excel للعرسان', Color(0xFF7B1FA2), -2), // -2 for manual navigation
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: isCompact ? 4 : 0),
        child: Text(
          'الإجراءات السريعة',
          style: TextStyle(
            fontSize: isCompact ? 20 : 24,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            letterSpacing: -0.5,
          ),
        ),
      ),
      SizedBox(height: isCompact ? 12 : 16),
      LayoutBuilder(
        builder: (context, constraints) {
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: actions.length,
            padding: EdgeInsets.zero,
            itemBuilder: (_, i) {
              final a = actions[i];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Handle navigation based on index
                    if (a.$5 == -1) {
                      // Navigate to Manual Register Groom Screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManualRegisterGroomScreen(),
                        ),
                      );
                    } else if (a.$5 == -2) {
                      // Navigate to Bulk Upload Grooms Screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BulkUploadGroomsScreen(),
                        ),
                      );
                    } else if (a.$5 == -3) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExpiringReservationsPage(),
                        ),
                      );
                    } else {
                      // Use existing tab navigation
                      widget.onNavigateToTab?.call(a.$5);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  splashColor: a.$4.withOpacity(0.1),
                  highlightColor: a.$4.withOpacity(0.05),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark 
                          ? Colors.white.withOpacity(0.1)
                          : Color(0xFFE4E6EB),
                        width: 1
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                            ? const Color.fromARGB(255, 20, 102, 13).withOpacity(0.3)
                            : Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(isCompact ? 12 : 14),
                          decoration: BoxDecoration(
                            color: a.$4.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            a.$1,
                            color: a.$4,
                            size: isCompact ? 28 : 32,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          a.$2,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: isCompact ? 14 : 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            a.$3,
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                              fontSize: isCompact ? 12 : 13,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    ],
  );
}

Widget _buildModernActionCard({
  required IconData icon,
  required String title,
  required String subtitle,
  required List<Color> gradient,
  required VoidCallback onTap,
  required bool isMobile,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(isMobile ? 14 : 18),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 8 : 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: isMobile ? 20 : 24,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 11,
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
Widget _buildRecentActivity(bool isMobile, bool isTablet) {
  if (_recentActivities.isEmpty && !_isLoading) {
    return SizedBox.shrink();
  }

  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'النشاط الأخير',
        style: TextStyle(
          fontSize: isMobile ? 20 : (isTablet ? 28 : 24),
          fontWeight: FontWeight.w700,
          color: Theme.of(context).textTheme.bodyLarge?.color, // Changed
        ),
      ),
      SizedBox(height: isMobile ? 16 : 20),
      Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor, // Changed
          borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
          boxShadow: [
            BoxShadow(
              color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.04),
              spreadRadius: 0,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1)
          ),
        ),
        child: _isLoading
            ? Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            : _recentActivities.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'لا توجد أنشطة حديثة',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7), // Changed
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: _recentActivities.map<Widget>((activity) {
                      final index = _recentActivities.indexOf(activity);
                      return Column(
                        children: [
                          _buildActivityItem(
                            icon: activity['icon'],
                            title: activity['title'],
                            subtitle: activity['subtitle'],
                            color: activity['color'],
                            isMobile: isMobile,
                          ),
                          if (index < _recentActivities.length - 1)
                            Divider(
                              height: isMobile ? 20 : 24,
                              color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey.shade200
                            ),
                        ],
                      );
                    }).toList(),
                  ),
      ),
    ],
  );
}

Widget _buildStatisticsSection(bool isMobile, bool isTablet) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'إحصائيات الحجوزات',
        style: TextStyle(
          fontSize: isMobile ? 20 : (isTablet ? 28 : 24),
          fontWeight: FontWeight.w700,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      SizedBox(height: isMobile ? 16 : 20),
      
      if (_statsLoading)
        Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        )
      else
        Column(
          children: [
            // Clan Statistics Card with expandable chart
            _buildChartCard(
              title: 'أعراس العشيرة',
              icon: Icons.groups_rounded,
              selectedPeriod: _clanSelectedPeriod,
              data: _clanStats,
              onPeriodChanged: (period) => setState(() => _clanSelectedPeriod = period),
              isDark: isDark,
              color: AppColors.primary,
              isExpanded: _isClanChartExpanded,
              onToggleExpand: () => setState(() => _isClanChartExpanded = !_isClanChartExpanded),
              isMobile: isMobile,
            ),
            SizedBox(height: 16),
            
            // County Statistics Card with expandable chart
            _buildChartCard(
              title: 'أعراس القصر',
              icon: Icons.location_city_rounded,
              selectedPeriod: _countySelectedPeriod,
              data: _countyStats,
              onPeriodChanged: (period) => setState(() => _countySelectedPeriod = period),
              isDark: isDark,
              color: Colors.blue,
              isExpanded: _isCountyChartExpanded,
              onToggleExpand: () => setState(() => _isCountyChartExpanded = !_isCountyChartExpanded),
              isMobile: isMobile,
            ),
          ],
        ),
    ],
  );
}

Widget _buildChartCard({
  required String title,
  required IconData icon,
  required String selectedPeriod,
  required Map<String, dynamic> data,
  required Function(String) onPeriodChanged,
  required bool isDark,
  required Color color,
  required bool isExpanded,
  required VoidCallback onToggleExpand,
  required bool isMobile,
}) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
    padding: EdgeInsets.all(isMobile ? 16 : 20),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
      boxShadow: [
        BoxShadow(
          color: isDark
            ? Colors.black.withOpacity(0.3)
            : Colors.black.withOpacity(0.04),
          spreadRadius: 0,
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
      border: Border.all(
        color: isDark
          ? Colors.white.withOpacity(0.1)
          : Colors.grey.withOpacity(0.1)
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row with toggle
        InkWell(
          onTap: onToggleExpand,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile ? 6 : 8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
                  ),
                  child: Icon(icon, color: color, size: isMobile ? 18 : 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isMobile ? 15 : 16,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      if (!isExpanded) ...[
                        SizedBox(height: 4),
                        Text(
                          'أعراس هذا الشهر ${(data['month'] as num?) ?? 0}',
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 13,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    size: isMobile ? 24 : 28,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Expandable content with chart
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: [
              SizedBox(height: isMobile ? 12 : 16),
              Row(
                children: [
                  _buildPeriodButton('اليوم', 'today', selectedPeriod, onPeriodChanged, color, isDark, isMobile),
                  SizedBox(width: 8),
                  _buildPeriodButton('الشهر', 'month', selectedPeriod, onPeriodChanged, color, isDark, isMobile),
                  SizedBox(width: 8),
                  _buildPeriodButton('السنة', 'year', selectedPeriod, onPeriodChanged, color, isDark, isMobile),
                ],
              ),
              SizedBox(height: isMobile ? 16 : 20),
              SizedBox(
                height: isMobile ? 150 : 180,
                child: _buildLineChart(data, selectedPeriod, color, isDark, isMobile),
              ),
              SizedBox(height: 12),
              Center(
                child: Column(
                  children: [
                    Text(
                      '${(data[selectedPeriod] as num?) ?? 0}',
                      style: TextStyle(
                        fontSize: isMobile ? 28 : 32,
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                    Text(
                      selectedPeriod == 'today' 
                          ? 'أعراس اليوم' 
                          : selectedPeriod == 'month' 
                              ? 'أعراس هذا الشهر' 
                              : 'أعراس هذه السنة',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 13,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          crossFadeState: isExpanded 
              ? CrossFadeState.showSecond 
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    ),
  );
}

// Add this method for period selection buttons
Widget _buildPeriodButton(
  String label,
  String value,
  String selectedPeriod,
  Function(String) onPeriodChanged,
  Color color,
  bool isDark,
  bool isMobile,
) {
  final isSelected = selectedPeriod == value;
  return Expanded(
    child: GestureDetector(
      onTap: () => onPeriodChanged(value),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? color.withOpacity(0.15) 
              : (isDark ? const Color(0xFF2A2A2A) : Colors.grey[100]),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isMobile ? 11 : 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected 
                ? color 
                : (isDark ? Colors.grey[400] : const Color(0xFF6A6A6A)),
          ),
        ),
      ),
    ),
  );
}


Widget _buildLineChart(
  Map<String, dynamic> data,
  String selectedPeriod,
  Color color,
  bool isDark,
  bool isMobile,
) {
  final List<dynamic> reservations = data['${selectedPeriod}_data'] ?? [];
  
  print('📊 DEBUG CHART DATA:');
  print('Selected Period: $selectedPeriod');
  print('Total Reservations: ${reservations.length}');
  print('Sample Data: ${reservations.take(3).toList()}');
  
  List<FlSpot> spots;
  Map<int, int> dateCounts = {}; // Changed to int keys for better handling
  
  if (selectedPeriod == 'today') {
    // Group by hour (0-23)
    for (var res in reservations) {
      try {
        final dateStr = res['date1'] ?? res['wedding_date'] ?? '';
        print('Processing date: $dateStr');
        
        if (dateStr.isNotEmpty) {
          final date = DateTime.parse(dateStr);
          final hour = date.hour;
          dateCounts[hour] = (dateCounts[hour] ?? 0) + 1;
          print('Hour $hour: ${dateCounts[hour]} reservations');
        }
      } catch (e) {
        print('Error parsing date: $e');
      }
    }
    
    // Create spots for all 24 hours
    spots = List.generate(24, (i) {
      final count = dateCounts[i] ?? 0;
      print('Hour $i final count: $count');
      return FlSpot(i.toDouble(), count.toDouble());
    });
    
  } else if (selectedPeriod == 'month') {
    // Group by day (1-31)
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    
    for (var res in reservations) {
      try {
        final dateStr = res['date1'] ?? res['wedding_date'] ?? '';
        print('Processing date: $dateStr');
        
        if (dateStr.isNotEmpty) {
          final date = DateTime.parse(dateStr);
          // Only count if it's in the current month
          if (date.year == now.year && date.month == now.month) {
            final day = date.day;
            dateCounts[day] = (dateCounts[day] ?? 0) + 1;
            print('Day $day: ${dateCounts[day]} reservations');
          }
        }
      } catch (e) {
        print('Error parsing date: $e');
      }
    }
    
    // Create spots for all days in month
    spots = List.generate(daysInMonth, (i) {
      final day = i + 1;
      final count = dateCounts[day] ?? 0;
      print('Day $day final count: $count');
      return FlSpot(i.toDouble(), count.toDouble());
    });
    
  } else {
    // Group by month (1-12)
    final now = DateTime.now();
    
    for (var res in reservations) {
      try {
        final dateStr = res['date1'] ?? res['wedding_date'] ?? '';
        print('Processing date: $dateStr');
        
        if (dateStr.isNotEmpty) {
          final date = DateTime.parse(dateStr);
          // Only count if it's in the current year
          if (date.year == now.year) {
            final month = date.month;
            dateCounts[month] = (dateCounts[month] ?? 0) + 1;
            print('Month $month: ${dateCounts[month]} reservations');
          }
        }
      } catch (e) {
        print('Error parsing date: $e');
      }
    }
    
    // Create spots for all 12 months
    spots = List.generate(12, (i) {
      final month = i + 1;
      final count = dateCounts[month] ?? 0;
      print('Month $month final count: $count');
      return FlSpot(i.toDouble(), count.toDouble());
    });
  }
  
  print('Final spots: ${spots.map((s) => '(${s.x}, ${s.y})').join(', ')}');
  
  // Calculate max Y value
  final maxY = spots.isEmpty ? 5.0 : spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
  final adjustedMaxY = maxY > 0 ? (maxY * 1.3).ceilToDouble() : 5.0;
  final midY = adjustedMaxY / 2;
  
  print('Max Y: $maxY, Adjusted Max Y: $adjustedMaxY');
  
  return LineChart(
    LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: midY > 0 ? midY : 1,
        getDrawingHorizontalLine: (value) => FlLine(
          color: (isDark ? Colors.grey[800]! : Colors.grey[200]!).withOpacity(0.5),
          strokeWidth: 1,
        ),
        getDrawingVerticalLine: (value) => FlLine(
          color: (isDark ? Colors.grey[800]! : Colors.grey[200]!).withOpacity(0.3),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: isMobile ? 25 : 30,
            interval: selectedPeriod == 'today' ? 6 : (selectedPeriod == 'month' ? 5 : 2),
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= spots.length) return const Text('');
              
              bool shouldShow = false;
              if (selectedPeriod == 'today' && index % 6 == 0) shouldShow = true;
              if (selectedPeriod == 'month' && index % 5 == 0) shouldShow = true;
              if (selectedPeriod == 'year' && index % 2 == 0) shouldShow = true;
              
              if (!shouldShow) return const Text('');
              
              final displayValue = selectedPeriod == 'today' 
                  ? index.toString() 
                  : (index + 1).toString();
              
              return Padding(
                padding: EdgeInsets.only(top: isMobile ? 6 : 8),
                child: Text(
                  displayValue,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : const Color(0xFF6A6A6A),
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 10 : 11,
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: isMobile ? 35 : 40,
            interval: midY > 0 ? midY : 1,
            getTitlesWidget: (value, meta) {
              if (value == 0.0) {
                return Text(
                  '0',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : const Color(0xFF6A6A6A),
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 10 : 11,
                  ),
                );
              } else if ((value - midY).abs() < 1) {
                return Text(
                  midY.round().toString(),
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : const Color(0xFF6A6A6A),
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 10 : 11,
                  ),
                );
              } else if ((value - adjustedMaxY).abs() < 1) {
                return Text(
                  adjustedMaxY.round().toString(),
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : const Color(0xFF6A6A6A),
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 10 : 11,
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: (isDark ? Colors.grey[800]! : Colors.grey[200]!).withOpacity(0.5),
          width: 1,
        ),
      ),
      minX: 0,
      maxX: (spots.length - 1).toDouble(),
      minY: 0.0,
      maxY: adjustedMaxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: color,
          barWidth: isMobile ? 2.5 : 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              final hasData = spot.y > 0;
              return FlDotCirclePainter(
                radius: hasData ? (isMobile ? 5 : 6) : 2,
                color: hasData ? color : color.withOpacity(0.2),
                strokeWidth: hasData ? 2 : 1,
                strokeColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withOpacity(0.3),
                color.withOpacity(0.05),
              ],
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => color.withOpacity(0.9),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              String label = '';
              if (selectedPeriod == 'today') {
                label = 'الساعة ${spot.x.toInt()}';
              } else if (selectedPeriod == 'month') {
                label = 'اليوم ${(spot.x.toInt() + 1)}';
              } else {
                label = 'الشهر ${(spot.x.toInt() + 1)}';
              }
              
              final count = spot.y.toInt();
              return LineTooltipItem(
                '$label\n${count > 0 ? "$count أعراس" : "لا يوجد أعراس"}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
        getTouchedSpotIndicator: (barData, spotIndexes) {
          return spotIndexes.map((index) {
            return TouchedSpotIndicatorData(
              FlLine(
                color: color.withOpacity(0.5),
                strokeWidth: 2,
                dashArray: [5, 5],
              ),
              FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: isMobile ? 7 : 8,
                  color: color,
                  strokeWidth: 3,
                  strokeColor: Colors.white,
                ),
              ),
            );
          }).toList();
        },
      ),
    ),
    duration: const Duration(milliseconds: 250),
  );
}

Widget _buildStatCard2({
  required String title,
  required IconData icon,
  required Color color,
  required Map<String, dynamic> stats,
  required bool isMobile,
  required bool isDark,
}) {
  return Container(
    padding: EdgeInsets.all(isMobile ? 16 : 20),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
      boxShadow: [
        BoxShadow(
          color: isDark
            ? Colors.black.withOpacity(0.3)
            : Colors.black.withOpacity(0.04),
          spreadRadius: 0,
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
      border: Border.all(
        color: isDark
          ? Colors.white.withOpacity(0.1)
          : Colors.grey.withOpacity(0.1)
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 8 : 10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
              ),
              child: Icon(icon, color: color, size: isMobile ? 20 : 24),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 16 : 20),
        
        // Statistics Rows
        _buildStatRow('اليوم', stats['today'], color, isMobile),
        SizedBox(height: 12),
        _buildStatRow('هذا الشهر', stats['month'], color, isMobile),
        SizedBox(height: 12),
        _buildStatRow('هذا العام', stats['year'], color, isMobile),
      ],
    ),
  );
}

Widget _buildStatRow(String label, int value, Color color, bool isMobile) {
  // Calculate max value for progress bar
  final maxValue = _clanStats['year'] > _countyStats['year'] 
      ? _clanStats['year'] 
      : _countyStats['year'];
  final progress = maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0.0;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
      SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: isMobile ? 6 : 8,
        ),
      ),
    ],
  );
}

Widget _buildComparisonChart(bool isMobile, bool isDark) {
  return Container(
    padding: EdgeInsets.all(isMobile ? 16 : 20),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
      boxShadow: [
        BoxShadow(
          color: isDark
            ? Colors.black.withOpacity(0.3)
            : Colors.black.withOpacity(0.04),
          spreadRadius: 0,
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
      border: Border.all(
        color: isDark
          ? Colors.white.withOpacity(0.1)
          : Colors.grey.withOpacity(0.1)
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.bar_chart,
              color: AppColors.primary,
              size: isMobile ? 20 : 24,
            ),
            SizedBox(width: 12),
            Text(
              'مقارنة الأداء',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 16 : 20),
        
        // Comparison bars
        _buildComparisonBar('اليوم', _clanStats['today'], _countyStats['today'], isMobile, isDark),
        SizedBox(height: 16),
        _buildComparisonBar('هذا الشهر', _clanStats['month'], _countyStats['month'], isMobile, isDark),
        SizedBox(height: 16),
        _buildComparisonBar('هذا العام', _clanStats['year'], _countyStats['year'], isMobile, isDark),
        
        SizedBox(height: 16),
        
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('العشيرة', AppColors.primary, isMobile),
            SizedBox(width: 24),
            _buildLegendItem('القصر', Colors.blue, isMobile),
          ],
        ),
      ],
    ),
  );
}

Widget _buildComparisonBar(String label, int clanValue, int countyValue, bool isMobile, bool isDark) {
  final maxValue = countyValue > 0 ? countyValue : 1;
  final clanProgress = (clanValue / maxValue).clamp(0.0, 1.0);
  final countyProgress = 1.0;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: isMobile ? 13 : 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      SizedBox(height: 8),
      
      // Clan bar
      Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: clanProgress,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: isMobile ? 12 : 14,
              ),
            ),
          ),
          SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              clanValue.toString(),
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: isMobile ? 12 : 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 6),
      
      // County bar
      Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: countyProgress,
                backgroundColor: Colors.blue.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                minHeight: isMobile ? 12 : 14,
              ),
            ),
          ),
          SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              countyValue.toString(),
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: isMobile ? 12 : 13,
                fontWeight: FontWeight.w700,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _buildLegendItem(String label, Color color, bool isMobile) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: isMobile ? 12 : 14,
        height: isMobile ? 12 : 14,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      SizedBox(width: 6),
      Text(
        label,
        style: TextStyle(
          fontSize: isMobile ? 12 : 13,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
    ],
  );
}


Widget _buildActivityItem({
  required IconData icon,
  required String title,
  required String subtitle,
  required Color color,
  required bool isMobile,
}) {
  return Row(
    children: [
      Container(
        padding: EdgeInsets.all(isMobile ? 8 : 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
        ),
        child: Icon(icon, color: color, size: isMobile ? 18 : 20),
      ),
      SizedBox(width: isMobile ? 12 : 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color, // Changed
              ),
            ),
            SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7), // Changed
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      // Icon(
      //   Icons.chevron_right,
      //   color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5), // Changed
      //   size: isMobile ? 16 : 18,
      // ),
    ],
  );
}


// calundary 
// Replace _buildCalendarOverview() method with this:
Widget _buildCalendarOverview(bool isMobile, bool isTablet) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  return Center( // ADD Center widget
    child: Container(
      constraints: BoxConstraints(maxWidth: 700), // ADD max width constraint
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: isDark
              ? Colors.black.withOpacity(0.3)
              : Colors.black.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1)
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with month/year navigation
          Wrap(
  spacing: 8,
  runSpacing: 12,
  alignment: WrapAlignment.spaceBetween,
  crossAxisAlignment: WrapCrossAlignment.center,
  children: [
    // Left: icon + title + month picker
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 8 : 10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
          ),
          child: Icon(
            Icons.calendar_month,
            color: AppColors.primary,
            size: isMobile ? 20 : 24,
          ),
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'نظرة عامة على الحجوزات',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _showYearPicker = !_showYearPicker;
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('MMMM yyyy', 'ar_DZ').format(_displayMonth),
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    _showYearPicker ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),

    // Right: navigation arrows
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left, size: isMobile ? 20 : 24),
          onPressed: () {
            setState(() {
              _displayMonth = DateTime(
                _displayMonth.year,
                _displayMonth.month - 1,
              );
            });
            _loadCalendarData();
          },
          color: isDark ? Colors.green.shade300 : AppColors.primary,
        ),
        IconButton(
          icon: Icon(Icons.chevron_right, size: isMobile ? 20 : 24),
          onPressed: () {
            setState(() {
              _displayMonth = DateTime(
                _displayMonth.year,
                _displayMonth.month + 1,
              );
            });
            _loadCalendarData();
          },
          color: isDark ? Colors.green.shade300 : AppColors.primary,
        ),
      ],
    ),
  ],
),
          
          // ADD Year Picker
          if (_showYearPicker) ...[
            SizedBox(height: 12),
            _buildYearPickerForCalendar(isDark),
          ],
          
          SizedBox(height: isMobile ? 16 : 20),
          
          // Legend (rest remains same)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCalendarLegendItem('متاح', const Color(0xFF4CAF50), isDark, isMobile),
              _buildCalendarLegendItem('معلق', const Color(0xFFFFB74D), isDark, isMobile),
              _buildCalendarLegendItem('مؤكد', const Color(0xFFEF4444), isDark, isMobile),
              _buildCalendarLegendItem('مختلط', const Color.fromARGB(255, 5, 150, 247), isDark, isMobile),
              _buildCalendarLegendItem('خاص', const Color(0xFF000000), isDark, isMobile),
            ],
          ),
          
          SizedBox(height: isMobile ? 16 : 20),
          
          // Calendar grid
          if (_calendarLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else
            _buildMiniCalendarGrid(isMobile, isDark),
        ],
      ),
    ),
  );
}
// Add this new method after _buildCalendarOverview()
Widget _buildYearPickerForCalendar(bool isDark) {
  final currentYear = DateTime.now().year;
  final years = List.generate(6, (index) => currentYear -2 + index); // 5 years back, 5 years forward
  
  return Container(
    height: 80,
    padding: EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: isDark 
        ? Colors.black.withOpacity(0.3)
        : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(12),
    ),
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: years.length,
      itemBuilder: (context, index) {
        final year = years[index];
        final isSelected = year == _displayMonth.year;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: InkWell(
            onTap: () {
              setState(() {
                _displayMonth = DateTime(year, _displayMonth.month);
                _showYearPicker = false;
              });
              _loadCalendarData();
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 80,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.green.shade600,
                          Colors.green.shade800,
                        ],
                      )
                    : null,
                color: isSelected 
                    ? null
                    : (isDark 
                        ? Colors.green.shade900.withOpacity(0.3)
                        : Colors.white),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : (isDark 
                          ? Colors.green.shade600.withOpacity(0.5)
                          : Colors.green.shade300.withOpacity(0.5)),
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.green.shade300.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  year.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected 
                        ? Colors.white
                        : (isDark ? Colors.green.shade300 : Colors.green.shade700),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
Widget _buildCalendarLegendItem(String label, Color color, bool isDark, bool isMobile) {
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: isMobile ? 8 : 10,
      vertical: isMobile ? 4 : 6,
    ),
    decoration: BoxDecoration(
      color: color.withOpacity(isDark ? 0.2 : 0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: color.withOpacity(isDark ? 0.5 : 0.3),
        width: 1,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isMobile ? 8 : 10,
          height: isMobile ? 8 : 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 11 : 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    ),
  );
}

Widget _buildMiniCalendarGrid(bool isMobile, bool isDark) {
  final daysInMonth = DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;
  final firstDayOfMonth = DateTime(_displayMonth.year, _displayMonth.month, 1);
  final firstWeekday = firstDayOfMonth.weekday % 7;
  
  // Week day headers
  const weekDays = ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'];
  
  return Column(
    children: [
      // Week headers
      Row(
        children: weekDays.map((day) => Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark 
                  ? Colors.green.shade300.withOpacity(0.7)
                  : const Color(0xFF757575),
                fontSize: isMobile ? 12 : 13,
              ),
            ),
          ),
        )).toList(),
      ),
      
      SizedBox(height: 8),
      
      // Calendar days
      GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          childAspectRatio: 1,
        ),
        itemCount: firstWeekday + daysInMonth,
        itemBuilder: (context, index) {
          if (index < firstWeekday) {
            return SizedBox.shrink();
          }
          
          final day = index - firstWeekday + 1;
          final date = DateTime(_displayMonth.year, _displayMonth.month, day);
          final dateStr = DateFormat('yyyy-MM-dd').format(date);
          final availability = _calendarDateAvailabilities[dateStr];
          
          return _buildMiniCalendarDay(date, availability, isMobile, isDark);
        },
      ),
    ],
  );
}
// Replace _buildMiniCalendarDay() method:
Widget _buildMiniCalendarDay(DateTime date, DateAvailability? availability, bool isMobile, bool isDark) {
  final isToday = DateFormat('yyyy-MM-dd').format(date) == 
                  DateFormat('yyyy-MM-dd').format(DateTime.now());
  
  Color backgroundColor = availability != null
      ? _getMiniCalendarDayColor(availability.status)
      : (isDark ? Colors.grey.shade800 : Colors.grey.shade100);
      
  return InkWell(
    onTap: availability != null && (availability.reservations.isNotEmpty || availability.status == DateStatus.specialReservation)
        ? () => _showMiniCalendarDetails(date, availability)
        : null,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: isToday
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              date.day.toString(),
              style: TextStyle(
                color: availability != null
                    ? Colors.white
                    : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                fontSize: isMobile ? 12 : 13,
              ),
            ),
          ),
          // ADD special reservation star icon
          if (availability != null && availability.status == DateStatus.specialReservation)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.star,
                  size: 10,
                  color: Colors.black,
                ),
              ),
            ),
          // Show count badge for non-special reservations
          if (availability != null && 
              availability.currentCount > 0 && 
              availability.status != DateStatus.specialReservation)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                constraints: BoxConstraints(minWidth: 14),
                padding: EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${availability.currentCount}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: backgroundColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

Color _getMiniCalendarDayColor(DateStatus status) {
  switch (status) {
    case DateStatus.available:
      return const Color(0xFF4CAF50);
    case DateStatus.pending:
      return const Color(0xFFFFB74D);
    case DateStatus.reserved:
      return const Color(0xFFEF4444);
    case DateStatus.mixed:
      return const Color.fromARGB(255, 5, 150, 247);
    case DateStatus.specialReservation:
      return const Color(0xFF000000);
    default:
      return Colors.grey;
  }
}
void _showMiniCalendarDetails(DateTime date, DateAvailability availability) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag indicator
          Container(
            width: 50,
            height: 5,
            margin: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              'تفاصيل ${DateFormat('dd/MM/yyyy').format(date)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Special reservation section
                  if (availability.status == DateStatus.specialReservation && 
                      availability.specialReservation != null) ...[
                    _buildSpecialReservationCard(availability.specialReservation!),
                  ] else ...[
                    // Stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailStatCard(
                            'مؤكد',
                            availability.validatedCount.toString(),
                            Colors.green,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildDetailStatCard(
                            'معلق',
                            availability.pendingCount.toString(),
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 16),
                    
                    Text(
                      availability.note ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    
                    // Reservations list with clan info
                    if (availability.reservations.isNotEmpty) ...[
                      SizedBox(height: 20),
                      Text(
                        'الحجوزات',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      ...availability.reservations.map((res) => _buildReservationCard(res, availability)),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
// Build special reservation card
Widget _buildSpecialReservationCard(ReservationSpecial specialReservation) {
  return Column(
    children: [
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF000000), Color(0xFF424242)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'حجز خاص من العشيرة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            Divider(color: Colors.white.withOpacity(0.3), height: 1),
            SizedBox(height: 16),
            
            // Reservation Name
            if (specialReservation.reservName != null) ...[
              _buildSpecialReservationInfoRow(
                icon: Icons.event,
                label: 'اسم الحجز',
                value: specialReservation.reservName!,
              ),
              SizedBox(height: 12),
            ],
            
            // Reservation Description
            if (specialReservation.reservDescription != null) ...[
              _buildSpecialReservationInfoRow(
                icon: Icons.description,
                label: 'الوصف',
                value: specialReservation.reservDescription!,
              ),
              SizedBox(height: 12),
            ],
            
            // Contact Information Section (if any exists)
            if (specialReservation.fullName != null ||
                specialReservation.phoneNumber != null ||
                specialReservation.homeAddress != null) ...[
              Divider(color: Colors.white.withOpacity(0.3), height: 1),
              SizedBox(height: 16),
              
              Row(
                children: [
                  Icon(
                    Icons.contact_phone,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'معلومات الاتصال',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              
              // Full Name
              if (specialReservation.fullName != null) ...[
                _buildSpecialReservationInfoRow(
                  icon: Icons.person,
                  label: 'الاسم الكامل',
                  value: specialReservation.fullName!,
                ),
                SizedBox(height: 12),
              ],
              
              // Phone Number
              if (specialReservation.phoneNumber != null) ...[
                _buildSpecialReservationInfoRow(
                  icon: Icons.phone,
                  label: 'رقم الهاتف',
                  value: specialReservation.phoneNumber!,
                ),
                SizedBox(height: 12),
              ],
              
              // Home Address
              if (specialReservation.homeAddress != null) ...[
                _buildSpecialReservationInfoRow(
                  icon: Icons.location_on,
                  label: 'العنوان',
                  value: specialReservation.homeAddress!,
                ),
              ],
            ],
          ],
        ),
      ),
      
      SizedBox(height: 16),
      
      // Info message
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange[700], size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'هذا التاريخ محجوز لمناسبة خاصة من قبل العشيرة .',
                style: TextStyle(
                  color: Colors.orange[900],
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

// Helper method for special reservation info rows
Widget _buildSpecialReservationInfoRow({
  required IconData icon,
  required String label,
  required String value,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: Colors.white, size: 18),
      SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
Widget _buildReservationCard(Map<String, dynamic> res, DateAvailability availability) {
  final groomName = '${res['first_name'] ?? ''} ${res['last_name'] ?? ''}'.trim();
  final guardianName = res['guardian_name'] ?? '';
  final groomPhone = res['phone_number'] ?? '';
  final guardianPhone = res['guardian_phone'] ?? '';
  final bool notBelongToClan = res['not_belong_to_clan'] == true;
  // Read clan name directly — no async call needed
  final String groomClanName = res['groom_clan_name'] ?? 'غير محدد';
  final bool hasClanInfo = res['groom_clan_id'] != null;

  return Container(
    margin: EdgeInsets.only(bottom: 12),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: notBelongToClan ? Colors.purple.shade50 : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: notBelongToClan ? Colors.purple.shade300 : Colors.grey.shade300,
        width: notBelongToClan ? 1.5 : 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Not-belong badge
        if (notBelongToClan) ...[
          Container(
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.purple.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.swap_horiz, size: 14, color: Colors.purple.shade700),
                SizedBox(width: 6),
                Text(
                  'عريس من عشيرة أخرى',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.purple.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Groom section
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (notBelongToClan ? Colors.purple : AppColors.primary).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                size: 20,
                color: notBelongToClan ? Colors.purple : AppColors.primary,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'العريس',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    groomName.isNotEmpty ? groomName : 'غير محدد',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (groomPhone.isNotEmpty) ...[
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 12, color: Colors.grey.shade600),
                        SizedBox(width: 4),
                        Text(
                          groomPhone,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),

        // Clan info — always shown, reads directly from groom's User.clan
        if (hasClanInfo) ...[
          Divider(height: 24, color: Colors.grey.shade300),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (notBelongToClan ? Colors.purple : AppColors.primary).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.groups,
                  size: 20,
                  color: notBelongToClan ? Colors.purple : AppColors.primary,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notBelongToClan ? 'عشيرة العريس (خارجية)' : 'عشيرة العريس',
                      style: TextStyle(
                        fontSize: 11,
                        color: notBelongToClan
                            ? Colors.purple.shade600
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      groomClanName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: notBelongToClan
                            ? Colors.purple.shade800
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],

        // Guardian section
        if (guardianName.isNotEmpty || guardianPhone.isNotEmpty) ...[
          Divider(height: 24, color: Colors.grey.shade300),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.supervisor_account, size: 20, color: Colors.blue),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ولي الأمر',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2),
                    if (guardianName.isNotEmpty)
                      Text(
                        guardianName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    if (guardianPhone.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 12, color: Colors.grey.shade600),
                          SizedBox(width: 4),
                          Text(
                            guardianPhone,
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],

        // Status badge
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: availability.validatedReservations.contains(res)
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: availability.validatedReservations.contains(res)
                  ? Colors.green.withOpacity(0.3)
                  : Colors.orange.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                availability.validatedReservations.contains(res)
                    ? Icons.check_circle
                    : Icons.schedule,
                size: 14,
                color: availability.validatedReservations.contains(res)
                    ? Colors.green
                    : Colors.orange,
              ),
              SizedBox(width: 4),
              Text(
                availability.validatedReservations.contains(res)
                    ? 'مؤكد'
                    : 'في الانتظار',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: availability.validatedReservations.contains(res)
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
// // Add this helper method for special reservation info rows
// Widget _buildSpecialReservationInfoRow({
//   required IconData icon,
//   required String label,
//   required String value,
// }) {
//   return Row(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Icon(icon, color: Colors.white, size: 18),
//       SizedBox(width: 10),
//       Expanded(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 11,
//                 color: Colors.white.withOpacity(0.7),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             SizedBox(height: 4),
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 15,
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//                 height: 1.4,
//               ),
//             ),
//           ],
//         ),
//       ),
//     ],
//   );
// }

Widget _buildDetailStatCard(String label, String value, Color color) {
  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}


}