// lib/screens/home/super_admin_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Add this import at the top with other imports
import 'package:wedding_reservation_app/screens/super%20admin/access_password_management_page.dart';
import 'package:wedding_reservation_app/screens/super%20admin/clan_admins_management_screen.dart';
import 'package:wedding_reservation_app/screens/super%20admin/clans_tab.dart';
import 'package:wedding_reservation_app/screens/super%20admin/create_clan_admin_screen.dart';
import 'package:wedding_reservation_app/screens/super%20admin/haia_tab.dart';
import 'package:wedding_reservation_app/screens/super%20admin/madaih_tab.dart';
import 'package:wedding_reservation_app/screens/super%20admin/notifications_tab.dart';
import 'package:wedding_reservation_app/screens/super%20admin/otp_verification_screen.dart';
import 'package:wedding_reservation_app/services/api_service.dart';
import 'package:wedding_reservation_app/widgets/theme_toggle_button.dart';

import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../super admin/counties_tab.dart';
class SuperAdminHomeScreen extends StatefulWidget {
  const SuperAdminHomeScreen({super.key});

  @override
  _SuperAdminHomeScreenState createState() => _SuperAdminHomeScreenState();
}

class _SuperAdminHomeScreenState extends State<SuperAdminHomeScreen> 
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Dashboard data
  Map<String, dynamic> _dashboardStats = {};
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadDashboardData();
  }
 
  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    _animationController.forward();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Load all dashboard data in parallel
      final futures = await Future.wait([
        _loadCountiesData(),
        _loadClansData(),
        _loadReservationsData(),
        _loadApiHealth(),
      ]);

      setState(() {
        _dashboardStats = {
          'counties': futures[0],
          'clans': futures[1],
          'reservations': futures[2],
          'apiHealth': futures[3],
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ في تحميل البيانات: $e';
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _loadCountiesData() async {
    try {
      final counties = await ApiService.listCountiesAdmin();
      return {
        'count': counties.length,
        'data': counties,
      };
    } catch (e) {
      return {'count': 0, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _loadClansData() async {
    try {
      final clans = await ApiService.getAllClans();
      return {
        'count': clans.length,
        'data': clans,
      };
    } catch (e) {
      return {'count': 0, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _loadReservationsData() async {
    try {
      final stats = await ApiService.getReservationStats();
      return stats;
    } catch (e) {
      return {
        'total': 0,
        'pending': 0,
        'validated': 0,
        'cancelled': 0,
        'error': e.toString()
      };
    }
  }

  Future<Map<String, dynamic>> _loadApiHealth() async {
    try {
      final health = await ApiService.getApiHealth();
      return health;
    } catch (e) {
      return {'status': 'error', 'error': e.toString()};
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  // Show confirmation dialog for sign out
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
            onPressed: () {
              ApiService.clearToken();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }


  @override
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final screenSize = MediaQuery.of(context).size;
  final isTablet = screenSize.width > 600;
  final isDesktop = screenSize.width > 1200;
  
  return PopScope(
    canPop: false,
    onPopInvokedWithResult: (bool didPop, dynamic result) async {
      if (didPop) return;
      
      // Show exit confirmation dialog instead of going back
      final shouldExit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('الخروج من التطبيق'),
          content: const Text('هل تريد الخروج من التطبيق؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('خروج'),
            ),
          ],
        ),
      );
      
      if (shouldExit == true && context.mounted) {
        // Exit the app (on Android)
        SystemNavigator.pop();
      }
    },
    child: Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: _buildModernAppBar(context, isTablet, isDesktop),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(context, isTablet, isDesktop),
          CountiesTab(),
          ClansTab(),
          MadaihTab(),
          HaiaTab(),
          NotificationsTab(), // ← Add this line

          _buildProfileTab(isDark),
        ],
      ),
      bottomNavigationBar: _buildModernBottomNav(isTablet, isDesktop),
    ),
  );
}
PreferredSizeWidget _buildModernAppBar(BuildContext context, bool isTablet, bool isDesktop) {
  final isSmall = MediaQuery.of(context).size.width < 600;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return AppBar(
    title: Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.admin_panel_settings, color: isDark ? Colors.grey[850] : Colors.white, size: isDesktop ? 24 : 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppConstants.appName, style: TextStyle(fontWeight: FontWeight.w700, fontSize: isDesktop ? 22 : isTablet ? 20 : 18, letterSpacing: 0.5), overflow: TextOverflow.ellipsis),
              if (!isSmall) Text('لوحة التحكم الرئيسية', style: TextStyle(fontSize: isDesktop ? 12 : 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    ),
    backgroundColor: isDark ? Colors.grey[850] : Colors.white,
    foregroundColor: AppColors.primary,
    elevation: 0,
    bottom: PreferredSize(
      preferredSize: Size.fromHeight(1),
      child: Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, AppColors.primary.withOpacity(0.1), Colors.transparent]))),
    ),
    actions: [
      if (!isSmall) ...[
        _buildAppBarAction(Icons.refresh, _loadDashboardData, isTablet, isDesktop),
        _buildAppBarAction(Icons.admin_panel_settings, () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClanAdminsManagementScreen())), isTablet, isDesktop),
        _buildAppBarAction(Icons.person_add, () => Navigator.push(context, MaterialPageRoute(builder: (_) => CreateClanAdminScreen())), isTablet, isDesktop),
        _buildAppBarAction(Icons.notifications_outlined, () {}, isTablet, isDesktop),
        _buildAppBarAction(Icons.person_outline, () {}, isTablet, isDesktop),
        // Add this line in the actions array, before the phone_android button
        _buildAppBarAction(Icons.lock_outline, () => Navigator.push(context, MaterialPageRoute(builder: (_) => SuperAdminAccessPasswordPage())), isTablet, isDesktop),
        _buildAppBarAction(Icons.phone_android, () => Navigator.push(context, MaterialPageRoute(builder: (_) => OTPVerificationScreenE(isClanadmin: false))), isTablet, isDesktop),
      ] else
        _buildAppBarAction(Icons.refresh, _loadDashboardData, isTablet, isDesktop),
      Container(margin: EdgeInsets.symmetric(horizontal: 4), child: ThemeToggleButton()),
      if (!isSmall)
        _buildAppBarAction(Icons.logout, _showLogoutDialog, isTablet, isDesktop)
      else
        PopupMenuButton<VoidCallback>(
          icon: Icon(Icons.more_vert, color: AppColors.primary),
          onSelected: (fn) => fn(),
          itemBuilder: (_) => [
            PopupMenuItem(value: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClanAdminsManagementScreen())), child: Row(children: [Icon(Icons.admin_panel_settings, size: 20), SizedBox(width: 12), Text('إدارة المشرفين')])),
            PopupMenuItem(value: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CreateClanAdminScreen())), child: Row(children: [Icon(Icons.person_add, size: 20), SizedBox(width: 12), Text('إضافة مشرف')])),
            PopupMenuItem(value: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SuperAdminAccessPasswordPage())), child: Row(children: [Icon(Icons.lock_outline, size: 20), SizedBox(width: 12), Text('إدارة كلمة المرور')])),
            PopupMenuItem(value: () {}, child: Row(children: [Icon(Icons.notifications_outlined, size: 20), SizedBox(width: 12), Text('الإشعارات')])),
            PopupMenuItem(value: () {}, child: Row(children: [Icon(Icons.person_outline, size: 20), SizedBox(width: 12), Text('الملف الشخصي')])),
            PopupMenuItem(value: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OTPVerificationScreenE(isClanadmin: false))), child: Row(children: [Icon(Icons.phone_android, size: 20), SizedBox(width: 12), Text('التحقق')])),
            PopupMenuItem(value: _showLogoutDialog, child: Row(children: [Icon(Icons.logout, size: 20, color: Colors.red), SizedBox(width: 12), Text('خروج', style: TextStyle(color: Colors.red))])),
          ],
        ),
      SizedBox(width: 8),
    ],
  );
}

  Widget _buildAppBarAction(IconData icon, VoidCallback onPressed, bool isTablet, bool isDesktop) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.primary.withOpacity(0.05),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: isDesktop ? 24 : isTablet ? 22 : 20,
        ),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: EdgeInsets.all(12),
        ),
      ),
    );
  }

Widget _buildModernBottomNav(bool isTablet, bool isDesktop) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Container(
    decoration: BoxDecoration(
      color: isDark ? Colors.grey[850] : Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          offset: Offset(0, -4),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ],
    ),
    child: SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 60 : isTablet ? 40 : 8,
          vertical: isTablet ? 12 : 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_outlined, Icons.home, 'الرئيسية', isTablet),
            _buildNavItem(1, Icons.location_city_outlined, Icons.location_city, 'القصور', isTablet),
            _buildNavItem(2, Icons.groups_outlined, Icons.groups, 'العشائر', isTablet),
            _buildNavItem(3, Icons.business_outlined, Icons.business, 'المدايح', isTablet),
            _buildNavItem(4, Icons.group_work_outlined, Icons.group_work, 'الهيئات', isTablet),
            _buildNavItem(5, Icons.notifications_outlined, Icons.notifications, 'إشعارات', isTablet), // ← Add this line

            _buildNavItem(5, Icons.person_outline, Icons.person, 'الملف', isTablet),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildNavItem(int index, IconData outlinedIcon, IconData filledIcon, 
                      String label, bool isTablet) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 8,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: Duration(milliseconds: 200),
              child: Icon(
                isSelected ? filledIcon : outlinedIcon,
                key: ValueKey(isSelected),
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: isTablet ? 26 : 24,
              ),
            ),
            SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isTablet ? 12 : 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context, bool isTablet, bool isDesktop) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final screenWidth = MediaQuery.of(context).size.width;
  final padding = isDesktop ? 32.0 : isTablet ? 24.0 : 16.0;
  
  if (_isLoading) {
    return _buildLoadingState(padding);
  }

  if (_errorMessage.isNotEmpty) {
    return _buildErrorState(padding);
  }
  
  return RefreshIndicator(
    onRefresh: _loadDashboardData,
    color: AppColors.primary,
    backgroundColor: Colors.white,
    child: FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(isTablet, isDesktop, isDark),
              SizedBox(height: 32),
              
              if (isDesktop) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('الإحصائيات العامة', isTablet, isDesktop),
                          SizedBox(height: 20),
                          _buildStatsGrid(isTablet, isDesktop),
                          SizedBox(height: 32),
                          _buildSectionTitle('الإجراءات السريعة', isTablet, isDesktop),
                          SizedBox(height: 20),
                          _buildActionGrid(isTablet, isDesktop),
                        ],
                      ),
                    ),
                    SizedBox(width: 32),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('حالة النظام', isTablet, isDesktop),
                          SizedBox(height: 20),
                          _buildSystemStatus(isTablet, isDesktop),
                          SizedBox(height: 32),
                          _buildRecentActivity(isTablet, isDesktop),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                _buildSectionTitle('الإحصائيات العامة', isTablet, isDesktop),
                SizedBox(height: 20),
                _buildStatsGrid(isTablet, isDesktop),
                SizedBox(height: 32),
                _buildSectionTitle('الإجراءات السريعة', isTablet, isDesktop),
                SizedBox(height: 20),
                _buildActionGrid(isTablet, isDesktop),
                SizedBox(height: 32),
                _buildSectionTitle('حالة النظام', isTablet, isDesktop),
                SizedBox(height: 20),
                _buildSystemStatus(isTablet, isDesktop),
                if (!isTablet) ...[
                  SizedBox(height: 32),
                  _buildRecentActivity(isTablet, isDesktop),
                ],
              ],
              SizedBox(height: 32), // Bottom padding for better scroll
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildLoadingState(double padding) {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: AppColors.primary,
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height - 200,
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              SizedBox(height: 16),
              Text(
                'جاري تحميل البيانات...',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(double padding) {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: AppColors.primary,
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height - 200,
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                _errorMessage,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadDashboardData,
                icon: Icon(Icons.refresh),
                label: Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'أو اسحب للأسفل للتحديث',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(bool isTablet, bool isDesktop , bool isDark) {
    final apiHealth = _dashboardStats['apiHealth'] ?? {};
    final isHealthy = apiHealth['status'] == 'healthy';
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 32 : isTablet ? 28 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
            AppColors.primary.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            offset: Offset(0, 8),
            blurRadius: 24,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.admin_panel_settings,
                  color: isDark ? Colors.grey[850] : Colors.white,
                  size: isDesktop ? 32 : isTablet ? 28 : 24,
                ),
              ),
              Spacer(),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'مدير عام',
                      style: TextStyle(
                        color: isDark ? Colors.grey[850] : Colors.white,
                        fontSize: isDesktop ? 16 : isTablet ? 14 : 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isHealthy ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isHealthy ? Icons.check_circle : Icons.error,
                      color: isDark ? Colors.grey[850] : Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'مرحباً بك في لوحة التحكم',
            style: TextStyle(
              color: isDark ? Colors.grey[850] : Colors.white,
              fontSize: isDesktop ? 36 : isTablet ? 32 : 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'تحكم في جميع القصور والعشائر والهيئات من مكان واحد',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isDesktop ? 20 : isTablet ? 18 : 16,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          if (isDesktop) ...[
            SizedBox(height: 16),
            Text(
              'آخر تحديث: ${DateTime.now().toString().split('.')[0]}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isTablet, bool isDesktop ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 4,
          height: isDesktop ? 32 : isTablet ? 28 : 24,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: isDesktop ? 28 : isTablet ? 24 : 20,
            fontWeight: FontWeight.w700,
            color: isDark ?AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

Widget _buildStatsGrid(bool isTablet, bool isDesktop) {
  final reservationStats = _dashboardStats['reservations'] ?? {};
  final countiesData = _dashboardStats['counties'] ?? {};
  final clansData = _dashboardStats['clans'] ?? {};

  final stats = [
    {
      'icon': Icons.location_city,
      'title': 'البلديات',
      'count': '${countiesData['count'] ?? 0}',
      'color': AppColors.primary,
      'subtitle': 'إجمالي البلديات المسجلة',
    },
    {
      'icon': Icons.groups,
      'title': 'العشائر',
      'count': '${clansData['count'] ?? 0}',
      'color': AppColors.secondary,
      'subtitle': 'إجمالي العشائر المسجلة',
    },
    {
      'icon': Icons.event_available,
      'title': 'الحجوزات المؤكدة',
      'count': '${reservationStats['validated'] ?? 0}',
      'color': Colors.green,
      'subtitle': 'حجوزات تم تأكيدها',
    },
    {
      'icon': Icons.pending,
      'title': 'الحجوزات المعلقة',
      'count': '${reservationStats['pending'] ?? 0}',
      'color': Colors.orange,
      'subtitle': 'حجوزات في انتظار المراجعة',
    },
    {
      'icon': Icons.cancel,
      'title': 'الحجوزات الملغاة',
      'count': '${reservationStats['cancelled'] ?? 0}',
      'color': Colors.red,
      'subtitle': 'حجوزات تم إلغاؤها',
    },
    {
      'icon': Icons.event,
      'title': 'إجمالي الحجوزات',
      'count': '${reservationStats['total'] ?? 0}',
      'color': Colors.purple,
      'subtitle': 'جميع الحجوزات المسجلة',
    },

  ];

  return LayoutBuilder(
    builder: (context, constraints) {
      // Determine layout based on available width
      final width = constraints.maxWidth;
      
      int crossAxisCount;
      double childAspectRatio;
      double spacing;
      
      if (width > 1200) {
        // Desktop/Large screens
        crossAxisCount = 3;
        childAspectRatio = 1.4;
        spacing = 20.0;
      } else if (width > 800) {
        // Tablet/Medium screens
        crossAxisCount = 2;
        childAspectRatio = 1.3;
        spacing = 16.0;
      } else if (width > 600) {
        // Large phones/Small tablets
        crossAxisCount = 2;
        childAspectRatio = 1.2;
        spacing = 12.0;
      } else {
        // Small phones
        crossAxisCount = 2;
        childAspectRatio = 0.95;
        spacing = 10.0;
      }

      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: childAspectRatio,
        ),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];
          return _buildModernStatsCard(
            icon: stat['icon'] as IconData,
            title: stat['title'] as String,
            count: stat['count'] as String,
            subtitle: stat['subtitle'] as String,
            color: stat['color'] as Color,
            isTablet: isTablet,
            isDesktop: isDesktop,
          );
        },
      );
    },
  );
}

  Widget _buildModernStatsCard({
    required IconData icon,
    required String title,
    required String count,
    required String subtitle,
    required Color color,
    required bool isTablet,
    required bool isDesktop,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: Offset(0, 4),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isDesktop ? 12 : 10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isDesktop ? 28 : isTablet ? 24 : 20,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'نشط',
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            count,
            style: TextStyle(
              fontSize: isDesktop ? 32 : isTablet ? 28 : 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: isDesktop ? 16 : isTablet ? 14 : 12,
              color: isDark ?AppColors.darkTextPrimary : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: isDesktop ? 12 : isTablet ? 11 : 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }


// UPDATED _buildActionGrid METHOD - Better responsive action grid
Widget _buildActionGrid(bool isTablet, bool isDesktop) {
  final actions = [
    {
      'icon': Icons.location_city_outlined,
      'title': 'إدارة البلديات',
      'subtitle': 'عرض وإدارة البلديات',
      'color': AppColors.primary,
      'onTap': () {
        setState(() {
          _currentIndex = 1;
        });
      },
    },
    {
      'icon': Icons.groups_outlined,
      'title': 'إدارة العشائر',
      'subtitle': 'عرض وإدارة العشائر',
      'color': AppColors.secondary,
      'onTap': () {
        setState(() {
          _currentIndex = 2;
        });
      },
    },
    {
      'icon': Icons.business_outlined,
      'title': 'إدارة المدايح',
      'subtitle': 'عرض وإدارة المدايح',
      'color': Colors.orange,
      'onTap': () {
        setState(() {
          _currentIndex = 3;
        });
      },
    },
    {
      'icon': Icons.group_work_outlined,
      'title': 'إدارة الهيئات',
      'subtitle': 'عرض وإدارة الهيئات',
      'color': Colors.green,
      'onTap': () {
        setState(() {
          _currentIndex = 4;
        });
      },
    },
        // ← Add this new action card
    {
      'icon': Icons.notifications_active_outlined,
      'title': 'إرسال إشعارات',
      'subtitle': 'إرسال إشعارات للمستخدمين',
      'color': Colors.red,
      'onTap': () {
        setState(() {
          _currentIndex = 5;
        });
      },
    },
    // ← End of new action card
    {
      'icon': Icons.phone_android,
      'title': 'التحقق من الهاتف',
      'subtitle': 'تحقق من أرقام الهواتف',
      'color': Colors.blue,
      'onTap': () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationScreenE(
              isClanadmin: false,
            ),
          ),
        );
      },
    },
    {
      'icon': Icons.person_add_outlined,
      'title': 'إضافة مدير عشيرة',
      'subtitle': 'إضافة مدير عشيرة جديد',
      'color': Colors.purple,
      'onTap': () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateClanAdminScreen(),
          ),
        );
      },
    },
    {
      'icon': Icons.admin_panel_settings_outlined,
      'title': 'إدارة المديرين',
      'subtitle': 'عرض وإدارة مديري العشائر',
      'color': Colors.indigo,
      'onTap': () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClanAdminsManagementScreen(),
          ),
        );
      },
    },
    {
      'icon': Icons.settings_outlined,
      'title': 'الإعدادات',
      'subtitle': 'إعدادات النظام العامة',
      'color': Colors.grey,
      'onTap': () {
        // TODO: Navigate to settings
      },
    },
  ];

  // Responsive grid settings for actions
  final crossAxisCount = isDesktop ? 4 : isTablet ? 3 : 2;
  final childAspectRatio = isDesktop ? 1.15 : isTablet ? 1.0 : 0.95;
  final spacing = isDesktop ? 20.0 : isTablet ? 16.0 : 12.0;

  return GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      childAspectRatio: childAspectRatio,
    ),
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemCount: actions.length,
    itemBuilder: (context, index) {
      final action = actions[index];
      return _buildModernActionCard(
        icon: action['icon'] as IconData,
        title: action['title'] as String,
        subtitle: action['subtitle'] as String,
        color: action['color'] as Color,
        onTap: action['onTap'] as VoidCallback,
        isTablet: isTablet,
        isDesktop: isDesktop,
      );
    },
  );
}

// ADD THIS NEW METHOD FOR ACTION CARDS
  Widget _buildModernActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isTablet,
    required bool isDesktop,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 20 : 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              offset: Offset(0, 4),
              blurRadius: 16,
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(isDesktop ? 16 : isTablet ? 14 : 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: isDesktop ? 32 : isTablet ? 28 : 24,
              ),
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: isDesktop ? 18 : isTablet ? 16 : 14,
                fontWeight: FontWeight.w700,
                color: isDark ?AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: isDesktop ? 14 : isTablet ? 12 : 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatus(bool isTablet, bool isDesktop) {
    final apiHealth = _dashboardStats['apiHealth'] ?? {};
    final isHealthy = apiHealth['status'] == 'healthy';
    final responseTime = apiHealth['response_time_ms'] ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: Offset(0, 4),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isHealthy ? Icons.check_circle : Icons.error,
                color: isHealthy ? Colors.green : Colors.red,
                size: isDesktop ? 28 : 24,
              ),
              SizedBox(width: 12),
              Text(
                'حالة النظام',
                style: TextStyle(
                  fontSize: isDesktop ? 20 : isTablet ? 18 : 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ?AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildStatusItem(
            'حالة الخادم',
            isHealthy ? 'متصل' : 'غير متصل',
            isHealthy ? Colors.green : Colors.red,
            isTablet,
            isDesktop,
          ),
          SizedBox(height: 12),
          _buildStatusItem(
            'زمن الاستجابة',
            '${responseTime}ms',
            responseTime < 500 ? Colors.green : responseTime < 1000 ? Colors.orange : Colors.red,
            isTablet,
            isDesktop,
          ),
          SizedBox(height: 12),
          _buildStatusItem(
            'آخر تحديث',
            _formatTime(DateTime.now()),
            Colors.blue,
            isTablet,
            isDesktop,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color, bool isTablet, bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isDesktop ? 14 : 12,
            color: AppColors.textSecondary,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(bool isTablet, bool isDesktop) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final reservationStats = _dashboardStats['reservations'] ?? {};
    final activities = [
      {
        'icon': Icons.add_circle_outline,
        'title': 'حجوزات جديدة',
        'count': '${reservationStats['pending'] ?? 0}',
        'color': Colors.blue,
      },
      {
        'icon': Icons.check_circle_outline,
        'title': 'حجوزات مؤكدة',
        'count': '${reservationStats['validated'] ?? 0}',
        'color': Colors.green,
      },
      {
        'icon': Icons.cancel_outlined,
        'title': 'حجوزات ملغاة',
        'count': '${reservationStats['cancelled'] ?? 0}',
        'color': Colors.red,
      },
    ];

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: Offset(0, 4),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline,
                color: AppColors.primary,
                size: isDesktop ? 28 : 24,
              ),
              SizedBox(width: 12),
              Text(
                'النشاط الأخير',
                style: TextStyle(
                  fontSize: isDesktop ? 20 : isTablet ? 18 : 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ?AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...activities.map((activity) => Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (activity['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    activity['icon'] as IconData,
                    color: activity['color'] as Color,
                    size: isDesktop ? 20 : 16,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    activity['title'] as String,
                    style: TextStyle(
                      fontSize: isDesktop ? 14 : 12,
                      color: isDark ?AppColors.darkTextPrimary : AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  activity['count'] as String,
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    color: activity['color'] as Color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildProfileTab(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              Icons.person_outline,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'قريباً...',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ?AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'صفحة الملف الشخصي قيد التطوير',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }
}

// Add this FoodMenu model class if it doesn't exist
class FoodMenu {
  final int id;
  final String name;
  final String description;
  final double price;
  final String foodType;
  final int visitors;

  FoodMenu({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.foodType,
    required this.visitors,
  });

  factory FoodMenu.fromJson(Map<String, dynamic> json) {
    return FoodMenu(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      foodType: json['food_type'],
      visitors: json['visitors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'food_type': foodType,
      'visitors': visitors,
    };
  }
}