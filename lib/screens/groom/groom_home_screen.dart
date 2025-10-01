// lib/screens/home/groom_home_screen.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wedding_reservation_app/screens/groom/food_menu_tab.dart';
import 'package:wedding_reservation_app/screens/groom/food_menu_tab_Groom.dart';
import 'package:wedding_reservation_app/services/api_service.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import 'create_reservation_screen.dart';
import 'home_tab.dart';
import 'reservations_tab.dart';
import 'profile_tab.dart';

class GroomHomeScreen extends StatefulWidget {
  final int initialTabIndex;
  
  const GroomHomeScreen({super.key, required this.initialTabIndex});

  @override
  _GroomHomeScreenState createState() => _GroomHomeScreenState();
}

class _GroomHomeScreenState extends State<GroomHomeScreen> {
  int _currentIndex = 0;
  late List<Widget> _tabs;
  Widget? _externalScreen;
  String? _externalScreenTitle;
  
  final GlobalKey<HomeTabState> _homeTabKey = GlobalKey<HomeTabState>();
  final GlobalKey<ReservationsTabState> _reservationsTabKey = GlobalKey<ReservationsTabState>();
  final GlobalKey<ProfileTabState> _profileTabKey = GlobalKey<ProfileTabState>();
  final GlobalKey<FoodMenuTabGState> _foodMenuTabKey = GlobalKey<FoodMenuTabGState>();
  final GlobalKey<CreateReservationScreenState> _creatResTabKey = GlobalKey<CreateReservationScreenState>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
    
    _tabs = [
      HomeTab(
        key: _homeTabKey,
        onTabChanged: _changeTab,
      ),
      CreateReservationScreen(
        key: _creatResTabKey,
        onReservationCreated: () {
          _changeTab(2);
        },
      ),
      ReservationsTab(key: _reservationsTabKey),
      FoodMenuTabG(key: _foodMenuTabKey),
      ProfileTab(key: _profileTabKey),
    ];
  }

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
      _externalScreen = null;
      _externalScreenTitle = null;
    });
    _refreshCurrentTab(index);
  }

  void _refreshCurrentTab(int index) {
    switch (index) {
      case 0:
        _homeTabKey.currentState?.refreshData();
        break;
      case 1:
        _creatResTabKey.currentState?.refreshData();
        break;
      case 2:
        _reservationsTabKey.currentState?.refreshData();
        break;
      case 3:
        _foodMenuTabKey.currentState?.refreshData();
        break;
      case 4:
        _profileTabKey.currentState?.refreshData();
        break;
    }
  }

  void _navigateToExternalScreen(Widget screen, String title) {
    setState(() {
      _externalScreen = screen;
      _externalScreenTitle = title;
    });
  }

  void _closeExternalScreen() {
    setState(() {
      _externalScreen = null;
      _externalScreenTitle = null;
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'تسجيل الخروج',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: TextStyle(color: Colors.grey[700]),
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
    return WillPopScope(
      onWillPop: () async {
        if (_externalScreen != null) {
          _closeExternalScreen();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        appBar: _buildSpotifyAppBar(),
        drawer: _buildSpotifyDrawer(),
        body: Stack(
          children: [
            // Main content - FULL SCREEN (including bottom nav area)
            Positioned.fill(
              child: _externalScreen != null
                  ? Column(
                      children: [
                        // Custom app bar for external screen
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back, size: 22),
                                onPressed: _closeExternalScreen,
                              ),
                              Expanded(
                                child: Text(
                                  _externalScreenTitle ?? '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 48), // Balance the back button
                            ],
                          ),
                        ),
                        // External screen content - FULL SCREEN
                        Expanded(
                          child: _externalScreen!,
                        ),
                      ],
                    )
                  : IndexedStack(
                      index: _currentIndex,
                      children: _tabs,
                    ),
            ),
            
            // Bottom Navigation Bar - FLOATING ON TOP
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildSpotifyBottomNav(),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildSpotifyAppBar() {
    return AppBar(
      title: Text(
        _getAppBarTitle(),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.menu, size: 20),
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        IconButton(
          icon: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.notifications_outlined, size: 20),
              ),
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          onPressed: _showNotifications,
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.logout_outlined, size: 20),
          ),
          onPressed: _showLogoutDialog,
          tooltip: 'تسجيل الخروج',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSpotifyDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_circle,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'قائمة التنقل',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Navigation Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildDrawerItem(Icons.home_rounded, 'الرئيسية', 0),
                    _buildDrawerItem(Icons.add_circle_outline_rounded, 'انشاء حجز', 1),
                    _buildDrawerItem(Icons.calendar_today_rounded, 'حجوزاتي', 2),
                    _buildDrawerItem(Icons.restaurant_menu_rounded, 'قائمة مقادير الوليمة', 3),
                    _buildDrawerItem(Icons.person_outline_rounded, 'الملف الشخصي', 4),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Divider(color: Colors.grey[300], thickness: 1),
                    ),
                    
                    _buildExternalDrawerItem(Icons.settings_outlined, 'الإعدادات', 
                      const Center(child: Text('شاشة الإعدادات'))),
                    _buildExternalDrawerItem(Icons.help_outline_rounded, 'المساعدة والدعم', 
                      const Center(child: Text('شاشة المساعدة والدعم'))),
                    _buildExternalDrawerItem(Icons.info_outline_rounded, 'حول التطبيق', 
                      const Center(child: Text('شاشة حول التطبيق'))),
                    _buildExternalDrawerItem(Icons.star_outline_rounded, 'تقييم التطبيق', 
                      const Center(child: Text('شاشة تقييم التطبيق'))),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Divider(color: Colors.grey[300], thickness: 1),
                    ),
                    
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                      ),
                      title: const Text(
                        'تسجيل الخروج',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _showLogoutDialog();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    final isSelected = _currentIndex == index && _externalScreen == null;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey[700],
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.primary : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 15,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          _changeTab(index);
        },
      ),
    );
  }

  Widget _buildExternalDrawerItem(IconData icon, String title, Widget screen) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.grey[700], size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          _navigateToExternalScreen(screen, title);
        },
      ),
    );
  }

  Widget _buildSpotifyBottomNav() {
    return Container(
      margin: const EdgeInsets.all(10),
      // padding: EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(47, 79, 79, 79),
        borderRadius: BorderRadius.circular(45),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 35,
            offset: const Offset(0, -4),
            spreadRadius: 0,
          ),
          // BoxShadow(
          //   color: const Color.fromARGB(255, 21, 219, 90).withOpacity(0.1),
          //   blurRadius: 14,
          //   offset: const Offset(0, -0),
          //   spreadRadius: 12,
          // ),
        ],
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(45),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildNavItem(Icons.home_rounded, 'الرئيسية', 0),
                  _buildNavItem(Icons.add_circle_outline_rounded, 'انشاء حجز', 1),
                  _buildNavItem(Icons.calendar_today_rounded, 'الحجوزات', 2),
                  _buildNavItem(Icons.restaurant_menu_rounded, 'الوليمة', 3),
                  _buildNavItem(Icons.person_outline_rounded, 'الملف الشخصي', 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index && _externalScreen == null;
    
    return GestureDetector(
      onTap: () => _changeTab(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    Color.fromARGB(82, 98, 216, 139),
                    Color.fromARGB(43, 2, 168, 110),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black.withOpacity(0.5),
              size: isSelected ? 26 : 24,
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    if (_externalScreen != null) {
      return _externalScreenTitle ?? '';
    }
    
    switch (_currentIndex) {
      case 0:
        return AppConstants.appName;
      case 1:
        return 'انشاء حجز جديد';
      case 2:
        return 'الحجوزات';
      case 3:
        return 'قائمة مقادير الوليمة';
      case 4:
        return 'الملف الشخصي';
      default:
        return AppConstants.appName;
    }
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'الإشعارات',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNotificationItem(
                Icons.info_rounded,
                Colors.blue,
                'مرحباً بك في التطبيق',
                'نتمنى لك تجربة ممتعة في حجز قاعة زفافك',
              ),
              const SizedBox(height: 12),
              _buildNotificationItem(
                Icons.update_rounded,
                Colors.green,
                'تحديث التطبيق',
                'تم إضافة ميزات جديدة للتطبيق',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'موافق',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(IconData icon, Color color, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}  