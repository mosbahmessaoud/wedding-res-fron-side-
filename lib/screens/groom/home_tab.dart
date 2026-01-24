// lib/screens/home/tabs/home_tab.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../services/api_service.dart';
import '../../../utils/colors.dart';

class HomeTab extends StatefulWidget { 
  final Function(int)? onTabChanged;
  
  const HomeTab({super.key, this.onTabChanged});

  @override
  HomeTabState createState() => HomeTabState();
}

class HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _pendingReservation;
  Map<String, dynamic>? _validatedReservation;

  Map<String, int> _reservationStats = {
    'total': 0,
    'validated': 0,
    'cancelled': 0,
    'pending': 0,
  };
  List<Map<String, dynamic>> _recentReservations = [];
  
  Map<String, dynamic> _clanStats = {
    'today': 0, 'month': 0, 'year': 0,
    'today_data': [], 'month_data': [], 'year_data': []
  };
  Map<String, dynamic> _countyStats = {
    'today': 0, 'month': 0, 'year': 0,
    'today_data': [], 'month_data': [], 'year_data': []
  };
  
  bool _isClanChartExpanded = true;
  bool _isCountyChartExpanded = false;
  String _clanSelectedPeriod = 'year';
  String _countySelectedPeriod = 'year';
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _hasValidReservation = false;
  bool _isCheckingReservation = true;

  
  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkReservationStatus().then((_) {
      if (mounted) {
        _loadDataInBackground();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Check if user has a valid reservation
  Future<void> _checkReservationStatus() async {
    if (!mounted) return;
    
    setState(() {
      _isCheckingReservation = true;
    });

    try {
      final validatedReservation = await ApiService.getMyValidatedReservation();
      
      if (!mounted) return;
      
      if (validatedReservation != null && validatedReservation.isNotEmpty) {
        setState(() {
          _hasValidReservation = true;
          _isCheckingReservation = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('No validated reservation found: $e');
    }

    if (!mounted) return;
    
    setState(() {
      _hasValidReservation = false;
      _isCheckingReservation = false;
    });
  }

  void _loadDataInBackground() {
    if (!mounted) return;
    _checkConnectivityAndLoad();
  }

  void refreshData() async {
    if (!mounted) return;
    
    final connectivityResult = await Connectivity().checkConnectivity();
    
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (mounted) {
        _showNoInternetDialog();
      }
      return;
    }
    
    await _checkReservationStatus();
    if (mounted) {
      _loadDashboardData();
    }
  }

  Future<void> _loadData() async {
    try {
      await Future.wait([
        _loadUserProfile(),
        _loadPendingReservation(),
        _loadReservationStats(),
        _loadChartStatistics(),
      ]);
      
      if (mounted) {
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل البيانات: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await ApiService.getProfile();
      if (mounted) {
        setState(() => _userProfile = profile);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _userProfile = null);
      }
    }
  }

  Future<void> _loadPendingReservation() async {
    try {
      final pending = await ApiService.getMyPendingReservation();
      if (mounted) {
        setState(() => _pendingReservation = pending);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _pendingReservation = null);
      }
    }
  }

  Future<void> _checkConnectivityAndLoad() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (mounted) {
        _showNoInternetDialog();
      }
      return;
    }
    
    await _loadData();
  }

  void _showNoInternetDialog() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.orange),
            SizedBox(width: 10),
            Text('لا يوجد اتصال'),
          ],
        ),
        content: const Text('يرجى التحقق من اتصالك بالإنترنت'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _checkConnectivityAndLoad();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('إعادة المحاولة', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
  }

  Future<void> _loadDashboardData() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (mounted) {
        _showNoInternetDialog();
      }
      return;
    }
    
    await _loadData();
  }

  Future<void> _loadReservationStats() async {
    try {
      final results = await Future.wait([
        ApiService.getMyAllReservations(),
        ApiService.getMyValidatedReservation().catchError((_) => null),
        ApiService.getMyCancelledReservations(),
      ]);
      
      if (!mounted) return;
      
      final allReservations = results[0] as List;
      final validatedReservation = results[1] as Map<String, dynamic>?;
      final cancelledReservations = results[2] as List;
      
      setState(() {
        _validatedReservation = validatedReservation;
        
        _reservationStats = {
          'total': allReservations.length,
          'validated': validatedReservation != null ? 1 : 0,
          'cancelled': cancelledReservations.length,
          'pending': _pendingReservation != null ? 1 : 0,
        };

        if (allReservations.isNotEmpty) {
          _recentReservations = allReservations
              .take(3)
              .map((r) => Map<String, dynamic>.from(r))
              .toList();
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _reservationStats = {'total': 0, 'validated': 0, 'cancelled': 0, 'pending': 0};
        });
      }
    }
  }

  Future<void> _loadChartStatistics() async {
    if (!_hasValidReservation) {
      if (mounted) {
        setState(() {
          _clanStats = {'today': 0, 'month': 0, 'year': 0, 'today_data': [], 'month_data': [], 'year_data': []};
          _countyStats = {'today': 0, 'month': 0, 'year': 0, 'today_data': [], 'month_data': [], 'year_data': []};
        });
      }
      return;
    }

    try {
      final results = await Future.wait([
        ApiService.getValidatedReservationsToday(),
        ApiService.getValidatedReservationsMonth(),
        ApiService.getValidatedReservationsYear(),
        ApiService.getValidatedReservationsTodayCounty(),
        ApiService.getValidatedReservationsMonthCounty(),
        ApiService.getValidatedReservationsYearCounty(),
      ]);
      
      if (!mounted) return;
      
      setState(() {
        _clanStats = {
          'today': results[0]['count'] ?? 0,
          'month': results[1]['count'] ?? 0,
          'year': results[2]['count'] ?? 0,
          'today_data': results[0]['reservations'] ?? [],
          'month_data': results[1]['reservations'] ?? [],
          'year_data': results[2]['reservations'] ?? [],
        };
        
        _countyStats = {
          'today': results[3]['count'] ?? 0,
          'month': results[4]['count'] ?? 0,
          'year': results[5]['count'] ?? 0,
          'today_data': results[3]['reservations'] ?? [],
          'month_data': results[4]['reservations'] ?? [],
          'year_data': results[5]['reservations'] ?? [],
        };
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _clanStats = {'today': 0, 'month': 0, 'year': 0, 'today_data': [], 'month_data': [], 'year_data': []};
          _countyStats = {'today': 0, 'month': 0, 'year': 0, 'today_data': [], 'month_data': [], 'year_data': []};
        });
      }
    }
  }

  void _showExitDialog(bool isDark) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'تسجيل الخروج',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ApiService.clearToken();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        _showExitDialog(isDark);
      },
      child: Container(
        color: isDark ? const Color(0xFF121212) : const Color(0xFFF6F6F6),
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          color: const Color(0xFF1DB954),
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildHeader(isDark),
              _buildStatusCard(isDark),
              const SizedBox(height: 24),
              _buildStatsSection(isDark),
              const SizedBox(height: 32),
              _buildQuickActions(isDark),
              if (_recentReservations.isNotEmpty) ...[
                const SizedBox(height: 32),
                _buildRecentReservations(isDark),
              ],
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final userName = _userProfile != null 
        ? (_userProfile!['guardian_name']?.toString().trim().isNotEmpty ?? false
            ? '${_userProfile!['guardian_name']}'.trim()
            : '${_userProfile!['first_name'] ?? ''} ${_userProfile!['last_name'] ?? ''}'.trim())
        : 'العريس الكريم';
    
    final timeOfDay = DateTime.now().hour;
    String greeting = timeOfDay < 12 
        ? 'السلام عليكم صباح الخير' 
        : timeOfDay < 18 
            ? 'السلام عليكم مرحبا بك' 
            : 'السلام عليكم مساء الخير';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1DB954).withOpacity(isDark ? 0.2 : 0.15),
            isDark ? const Color(0xFF121212) : const Color(0xFFF6F6F6),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: isDark ? const Color(0xFF1DB954) : const Color(0xFF009013),
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : const Color(0xFF6A6A6A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(bool isDark) {
    if (_reservationStats['validated'] != null && _reservationStats['validated']! > 0) {
      return _buildValidatedCard(isDark);
    }
    
    if (_pendingReservation != null) {
      return _buildPendingCard(isDark);
    }
    
    return _buildReadyCard(isDark);
  }

  Widget _buildValidatedCard(bool isDark) {
    if (_validatedReservation == null) return _buildReadyCard(isDark);
    
    final res = _validatedReservation!;
    final date = res['date1'] ?? 'غير محدد';
    final date2 = res['date2'];
    final hall = res['hall_name'] ?? 'غير محدد';
    
    return _buildStatusCardWrapper(
      isDark: isDark,
      gradient: [
        isDark ? const Color(0xFF159843) : const Color(0xFF1DB954),
        isDark ? const Color(0x8D1DB954) : const Color(0xFF1ED760),
      ],
      icon: Icons.check_circle_rounded,
      title: 'حجز مؤكد',
      subtitle: 'تهانينا! حجزك جاهز',
      date: date2 != null && date2.isNotEmpty ? '$date و $date2' : date,
      hall: hall,
      onTap: () => widget.onTabChanged!(2),
    );
  }

  Widget _buildPendingCard(bool isDark) {
    final date = _pendingReservation!['date1'] ?? 'غير محدد';
    final date2 = _pendingReservation!['date2'];
    final hall = _pendingReservation!['hall_name'] ?? 'غير محدد';
    
    return _buildStatusCardWrapper(
      isDark: isDark,
      gradient: [
        isDark ? const Color(0xFF875812) : Colors.orange.shade300,
        isDark ? const Color(0xFFC86400) : Colors.orange.shade600,
      ],
      icon: Icons.pending_rounded,
      title: 'حجز معلق',
      subtitle: 'في انتظار الموافقة',
      date: date2 != null && date2.isNotEmpty ? '$date و $date2' : date,
      hall: hall,
      onTap: () => widget.onTabChanged!(2),
      shadowColor: isDark ? Colors.orange.shade700.withOpacity(0.8) : Colors.orange.shade600,
    );
  }

  Widget _buildReadyCard(bool isDark) {
    return GestureDetector(
      onTap: () => widget.onTabChanged!(1),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isDark ? Colors.green.shade600 : Colors.green.shade400.withOpacity(0.7),
              isDark ? Colors.green.shade900 : Colors.green.shade700.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? const Color(0xFF1DB954).withOpacity(0.7) 
                  : Colors.green.shade700.withOpacity(0.7),
              blurRadius: 25,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.celebration_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ابدأ الحجز',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'احجز تاريخ العرس الآن',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCardWrapper({
    required bool isDark,
    required List<Color> gradient,
    required IconData icon,
    required String title,
    required String subtitle,
    required String date,
    required String hall,
    required VoidCallback onTap,
    Color? shadowColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: shadowColor ?? gradient[0].withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.event_rounded, size: 16, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          date,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 16, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          hall,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(bool isDark) {
    if (!_hasValidReservation) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.lock_outline,
                size: 48,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'الإحصائيات متاحة بعد تأكيد الحجز',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إحصائيات',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF121212),
            ),
          ),
          const SizedBox(height: 20),
          _buildChartCard(
            title: 'أعراس العشيرة',
            icon: Icons.groups_rounded,
            selectedPeriod: _clanSelectedPeriod,
            data: _clanStats,
            onPeriodChanged: (period) {
              if (mounted) {
                setState(() => _clanSelectedPeriod = period);
              }
            },
            isDark: isDark,
            color: const Color(0xFF1DB954),
            isExpanded: _isClanChartExpanded,
            onToggleExpand: () {
              if (mounted) {
                setState(() => _isClanChartExpanded = !_isClanChartExpanded);
              }
            },
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            title: 'أعراس القصر',
            icon: Icons.location_city_rounded,
            selectedPeriod: _countySelectedPeriod,
            data: _countyStats,
            onPeriodChanged: (period) {
              if (mounted) {
                setState(() => _countySelectedPeriod = period);
              }
            },
            isDark: isDark,
            color: const Color(0xFF1ED760),
            isExpanded: _isCountyChartExpanded,
            onToggleExpand: () {
              if (mounted) {
                setState(() => _isCountyChartExpanded = !_isCountyChartExpanded);
              }
            },
          ),
        ],
      ),
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
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBorderFocus.withOpacity(isDark ? 0.2 : 0.1),
            blurRadius: 15,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggleExpand,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF121212),
                          ),
                        ),
                        if (!isExpanded) ...[
                          const SizedBox(height: 4),
                          Text(
                            '  أعراس هذا الشهر  ${(data['month'] as num?) ?? 0} ',
                            style: TextStyle(
                              fontSize: 13,
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
                      color: isDark ? Colors.grey[400] : const Color(0xFF6A6A6A),
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildPeriodButton('اليوم', 'today', selectedPeriod, onPeriodChanged, color, isDark),
                    const SizedBox(width: 8),
                    _buildPeriodButton('الشهر', 'month', selectedPeriod, onPeriodChanged, color, isDark),
                    const SizedBox(width: 8),
                    _buildPeriodButton('السنة', 'year', selectedPeriod, onPeriodChanged, color, isDark),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 180,
                  child: _buildLineChart(data, selectedPeriod, color, isDark),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Column(
                    children: [
                      Text(
                        '${(data[selectedPeriod] as num?) ?? 0}',
                        style: TextStyle(
                          fontSize: 32,
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
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : const Color(0xFF6A6A6A),
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

  Widget _buildPeriodButton(
    String label,
    String value,
    String selectedPeriod,
    Function(String) onPeriodChanged,
    Color color,
    bool isDark,
  ) {
    final isSelected = selectedPeriod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onPeriodChanged(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
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
              fontSize: 12,
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
  ) {
    final List<dynamic> reservations = data['${selectedPeriod}_data'] ?? [];
    
    List<FlSpot> spots;
    Map<String, int> dateCounts = {};
    
    if (selectedPeriod == 'today') {
      for (var res in reservations) {
        try {
          final dateStr = res['date1'] ?? res['wedding_date'] ?? '';
          if (dateStr.isNotEmpty) {
            final date = DateTime.parse(dateStr);
            final hour = date.hour.toString();
            dateCounts[hour] = (dateCounts[hour] ?? 0) + 1;
          }
        } catch (e) {
          // Skip invalid dates
        }
      }
      spots = List.generate(24, (i) => FlSpot(i.toDouble(), (dateCounts[i.toString()] ?? 0).toDouble()));
      
    } else if (selectedPeriod == 'month') {
      for (var res in reservations) {
        try {
          final dateStr = res['date1'] ?? res['wedding_date'] ?? '';
          if (dateStr.isNotEmpty) {
            final date = DateTime.parse(dateStr);
            final day = date.day.toString();
            dateCounts[day] = (dateCounts[day] ?? 0) + 1;
          }
        } catch (e) {
          // Skip invalid dates
        }
      }
      final now = DateTime.now();
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      spots = List.generate(
        daysInMonth, 
        (i) => FlSpot(i.toDouble(), (dateCounts[(i + 1).toString()] ?? 0).toDouble())
      );
      
    } else {
      for (var res in reservations) {
        try {
          final dateStr = res['date1'] ?? res['wedding_date'] ?? '';
          if (dateStr.isNotEmpty) {
            final date = DateTime.parse(dateStr);
            final month = date.month.toString();
            dateCounts[month] = (dateCounts[month] ?? 0) + 1;
          }
        } catch (e) {
          // Skip invalid dates
        }
      }
      spots = List.generate(12, (i) => FlSpot(i.toDouble(), (dateCounts[(i + 1).toString()] ?? 0).toDouble()));
    }
    
    final maxY = spots.isEmpty ? 5.0 : spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    final adjustedMaxY = maxY > 0 ? (maxY * 1.3).ceilToDouble() : 5.0;
    final midY = adjustedMaxY / 2;
    
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
              reservedSize: 30,
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
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    displayValue,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : const Color(0xFF6A6A6A),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: midY > 0 ? midY : 1,
              getTitlesWidget: (value, meta) {
                if (value == 0.0) {
                  return Text(
                    '0',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : const Color(0xFF6A6A6A),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  );
                } else if ((value - midY).abs() < 1) {
                  return Text(
                    midY.round().toString(),
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : const Color(0xFF6A6A6A),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  );
                } else if ((value - adjustedMaxY).abs() < 1) {
                  return Text(
                    adjustedMaxY.round().toString(),
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : const Color(0xFF6A6A6A),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
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
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final hasData = spot.y > 0;
                return FlDotCirclePainter(
                  radius: hasData ? 6 : 2,
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
                    radius: 8,
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

  Widget _buildQuickActions(bool isDark) {
    final actions = [
      {
        'icon': Icons.add_circle_rounded,
        'title': 'حجز جديد',
        'subtitle': 'احجز موعد زفافك',
        'onTap': () => widget.onTabChanged!(1)
      },
      {
        'icon': Icons.calendar_month_rounded,
        'title': 'حجوزاتي',
        'subtitle': 'عرض وإدارة الحجوزات',
        'onTap': () => widget.onTabChanged!(2)
      },
      {
        'icon': Icons.restaurant_menu_rounded,
        'title': 'قائمة مقادير الوليمة',
        'subtitle': 'اطلع على قائمة الطعام',
        'onTap': () => widget.onTabChanged!(3)
      },
      {
        'icon': Icons.person_rounded,
        'title': 'الملف الشخصي',
        'subtitle': 'إعدادات وتفضيلات',
        'onTap': () => widget.onTabChanged!(4)
      },
      {
        'icon': Icons.rule_outlined,
        'title': 'اللوازم',
        'subtitle': 'اطلع على القوانين والقواعد',
        'onTap': () => widget.onTabChanged!(5)
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الإجراءات السريعة',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF121212),
            ),
          ),
          const SizedBox(height: 16),
          ...actions.map((action) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: action['onTap'] as VoidCallback,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkBorderFocus.withOpacity(isDark ? 0.15 : 0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1DB954).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        action['icon'] as IconData,
                        color: const Color(0xFF1DB954),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            action['title'] as String,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF121212),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            action['subtitle'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : const Color(0xFF6A6A6A),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: isDark ? Colors.grey[400] : const Color(0xFF6A6A6A),
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRecentReservations(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الحجوزات الأخيرة',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF121212),
            ),
          ),
          const SizedBox(height: 16),
          ...(_recentReservations.map((res) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildReservationCard(res, isDark),
          ))),
        ],
      ),
    );
  }

  Widget _buildReservationCard(Map<String, dynamic> reservation, bool isDark) {
    final status = reservation['status'] ?? 'pending';
    final date = reservation['date1'] ?? 'غير محدد';
    final hall = reservation['hall_name'] ?? 'غير محدد';
    
    Color color = Colors.orange;
    IconData icon = Icons.pending_rounded;
    String text = 'معلق';
    
    if (status.toLowerCase() == 'confirmed' || status.toLowerCase() == 'validated') {
      color = const Color(0xFF1DB954);
      icon = Icons.check_circle_rounded;
      text = 'مؤكد';
    } else if (status.toLowerCase() == 'cancelled') {
      color = Colors.red.shade400;
      icon = Icons.cancel_rounded;
      text = 'ملغي';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hall,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF121212),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : const Color(0xFF6A6A6A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}