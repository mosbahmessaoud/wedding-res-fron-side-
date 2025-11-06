// lib/screens/home/tabs/profile_tab.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:wedding_reservation_app/models/clan.dart';
import 'package:wedding_reservation_app/models/county.dart';
import '../../../services/api_service.dart';
import '../../../utils/colors.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => ProfileTabState();
}

class ProfileTabState extends State<ProfileTab> {
  bool _isLoading = true;
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _clanInfo;
  Map<String, dynamic>? _countyInfo;

  // ADD THESE CACHE VARIABLES:
  Map<String, dynamic>? _cachedUserProfile;
  Map<String, dynamic>? _cachedClanInfo;
  Map<String, dynamic>? _cachedCountyInfo;
  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    
    // Show cached data immediately
    _loadCachedData();
    
    // Load fresh data in background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileInBackground();
    });
  }
Future<void> refreshData() async {
  await _loadProfileInBackground();
}

// ============================================
// 2. ADD: Load cached data method (instant)
// ============================================

void _loadCachedData() {
  setState(() {
    _userProfile = _cachedUserProfile;
    _clanInfo = _cachedClanInfo;
    _countyInfo = _cachedCountyInfo;
    _isLoading = _cachedUserProfile == null && !_hasLoadedOnce;
  });
}


// ============================================
// 4. ADD: Background loading method (non-blocking)
// ============================================

Future<void> _loadProfileInBackground() async {
  try {
    // Don't show loading spinner if we have cached data
    if (_cachedUserProfile == null) {
      setState(() => _isLoading = true);
    }
    
    // Load profile
    _userProfile = await ApiService.getProfile();
    _cachedUserProfile = _userProfile;
    
    // Load clan and county information in parallel
    await Future.wait([
      _loadClanInfo(),
      _loadCountyInfo(),
    ]);
    
    _hasLoadedOnce = true;
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  } catch (e) {
    // Keep cached data on error
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}


Future<void> _checkConnectivityAndLoad() async {
  // Show cached data first
  _loadCachedData();
  
  final connectivityResult = await Connectivity().checkConnectivity();
  
  if (connectivityResult.contains(ConnectivityResult.none)) {
    _showNoInternetDialog();
    return;
  }
  
  // Load fresh data in background
  await _loadProfileInBackground();
}


void _showNoInternetDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.orange),
          SizedBox(width: 10),
          Text('لا يوجد اتصال'),
        ],
      ),
      content: Text('يرجى التحقق من اتصالك بالإنترنت'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('إلغاء'),
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
          child: Text('إعادة المحاولة', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

Future<void> _loadProfile() async {
  await _loadProfileInBackground();
}
Future<void> _loadClanInfo() async {
  if (_userProfile?['clan_id'] == null) return;
  
  try {
    final clans = await ApiService.getClans();
    final foundClan = clans.cast<Clan?>().firstWhere(
      (clan) => clan?.id == _userProfile?['clan_id'],
      orElse: () => null,
    );
    _clanInfo = foundClan?.toJson();
    _cachedClanInfo = _clanInfo; // Cache it
  } catch (e) {
    // Keep cached data on error
  }
}


Future<void> _loadCountyInfo() async {
  if (_userProfile?['county_id'] == null) return;
  
  try {
    final counties = await ApiService.getCounties();
    final foundCounty = counties.cast<County?>().firstWhere(
      (county) => county?.id == _userProfile?['county_id'],
      orElse: () => null,
    );
    _countyInfo = foundCounty?.toJson();
    _cachedCountyInfo = _countyInfo; // Cache it
  } catch (e) {
    // Keep cached data on error
  }
}

@override
Widget build(BuildContext context) {
  // Show loading only on first load with no cache
  if (_isLoading && _cachedUserProfile == null) {
    return const Center(child: CircularProgressIndicator());
  }

  // Show cached or fresh data
  return PopScope(
    canPop: false,
    onPopInvokedWithResult: (bool didPop, Object? result) {
      // Do nothing - completely block back navigation
      return;
    },
    child: RefreshIndicator(
      onRefresh: _loadProfileInBackground,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildLocationInfo(),
            const SizedBox(height: 24),
            _buildPersonalInfoSection(),
            const SizedBox(height: 24),
            _buildGuardianInfoSection(),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 60),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildProfileHeader() {
    final fullName = '${_userProfile?['first_name'] ?? ''} ${_userProfile?['last_name'] ?? ''}'.trim();    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            fullName.isNotEmpty ? fullName : 'العريس',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userProfile?['phone_number'] ?? '',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'معلومات الموقع',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.location_city,
              'القصر',
              _countyInfo?['name'] ?? 'غير محدد',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.group,
              'العشيرة',
              _clanInfo?['name'] ?? 'غير محدد',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'المعلومات الشخصية',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildInfoRow(
              Icons.person,
              'الاسم الأول',
              _userProfile?['first_name'] ?? 'غير محدد',
            ),
            const SizedBox(height: 12),
            
            _buildInfoRow(
              Icons.person_outline,
              'اسم العائلة',
              _userProfile?['last_name'] ?? 'غير محدد',
            ),
            const SizedBox(height: 12),
            
            _buildInfoRow(
              Icons.person,
              'اسم الأب',
              _userProfile?['father_name'] ?? 'غير محدد',
            ),
            const SizedBox(height: 12),
            
            _buildInfoRow(
              Icons.person,
              'اسم الجد',
              _userProfile?['grandfather_name'] ?? 'غير محدد',
            ),
            const SizedBox(height: 12),
            
            _buildInfoRow(
              Icons.phone,
              'رقم الهاتف',
              _userProfile?['phone_number'] ?? 'غير محدد',
            ),
            const SizedBox(height: 12),
            
            _buildInfoRow(
              Icons.calendar_today,
              'تاريخ الميلاد',
              _userProfile?['birth_date'] ?? 'غير محدد',
            ),
            const SizedBox(height: 12),
            
            _buildInfoRow(
              Icons.location_on,
              'مكان الميلاد',
              _userProfile?['birth_address'] ?? 'غير محدد',
            ),
            const SizedBox(height: 12),
            
            _buildInfoRow(
              Icons.home,
              'عنوان السكن',
              _userProfile?['home_address'] ?? 'غير محدد',
            ),
          ],
        ),
      ),
    );
  } 

  Widget _buildGuardianInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'معلومات ولي الأمر',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildInfoRow(
              Icons.person,
              'اسم ولي الأمر',
              _userProfile?['guardian_name'] ?? 'غير محدد',
            ),
            const SizedBox(height: 12),
            
            _buildInfoRow(
              Icons.phone,
              'هاتف ولي الأمر',
              _userProfile?['guardian_phone'] ?? 'غير محدد',
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, size: 20, color: isDark ?AppColors.primaryLight : AppColors.primary,),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style:  TextStyle(
            fontWeight: FontWeight.w500,
            color: isDark ?AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style:  TextStyle(
              color: isDark ?AppColors.darkTextHint : AppColors.darkCard,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Account Actions
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.notifications, color: AppColors.primary),
                title: const Text('الإشعارات'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showNotificationSettings,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.security, color: AppColors.primary),
                title: const Text('اخر اخبار العشيرة'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showNewsClan,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.help, color: AppColors.primary),
                title: const Text('المساعدة والدعم'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showHelpSupport,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.info, color: AppColors.primary),
                title: const Text('حول التطبيق'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showAboutApp,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Danger Zone
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.orange),
                title: const Text('تسجيل الخروج'),
                onTap: _showLogoutDialog,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('حذف الحساب'),
                onTap: _showDeleteAccountDialog,
              ),
            ],
          ),
        ),
      ],
    );
  }

void _showNotificationSettings() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'إعدادات الإشعارات',
          textAlign: TextAlign.right,
        ),
        content: const Text(
          'هذه الميزة قيد التطوير حالياً. سيتم إضافتها قريباً.',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('حسناً'),
          ),
        ],
      );
    },
  );
}

void _showNewsClan() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'أخبار العشيرة',
          textAlign: TextAlign.right,
        ),
        content: const Text(
          'هذه الصفحة قيد التطوير حالياً. سيتم إضافتها قريباً.',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('حسناً'),
          ),
        ],
      );
    },
  );
}


  void _showAboutApp() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حول التطبيق'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'تطبيق حجوزات الأعراس الخاص بجميع العشائر ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('الإصدار: 1.0.1'),
              const SizedBox(height: 16),
              const Text(
                'يسرّنا أن نرحب بكم في تطبيق الأعراس،\nونضع بين أيديكم وسيلة ميسرة لتنظيم و حجز العرس الخاص بكم',
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'برعاية:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text('عشيرة آت الشيخ الحاج مسعود'),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'معلومات المطور:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.email, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('mosbah07messaoud@gmail.com'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.phone, size: 18),
                  const SizedBox(width: 8),
                  const Text('0658890501'),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ?Colors.green.shade300 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDark ?Colors.green.shade500 : Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.message, color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '   لأي ملاحظات أو استفسارات عن التطبيق، \n يرجى التواصل عبر الواتساب (0658890501)'   ,
                        style: TextStyle(fontSize: 13, color: isDark ?AppColors.darkTextPrimary : AppColors.darkBorder),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showHelpSupport() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('لدعم والمساعدة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // const Text(
              //   'معلومات المطور:',
              //   style: TextStyle(fontWeight: FontWeight.bold),
              // ),
              // const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.email, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('mosbah07messaoud@gmail.com'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.phone, size: 18),
                  const SizedBox(width: 8),
                  const Text('0658890501'),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ?Colors.green.shade300 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDark ?Colors.green.shade500 : Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.message, color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '   لأي ملاحظات أو استفسارات عن التطبيق، \n يرجى التواصل عبر الواتساب (0658890501)'   ,
                        style: TextStyle(fontSize: 13, color: isDark ?AppColors.darkTextPrimary : AppColors.darkBorder),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
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

  void _showDeleteAccountDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('حذف الحساب'),
      content: const Text('تحذير: هذا الإجراء لا يمكن التراجع عنه. سيتم حذف جميع بياناتك نهائياً.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            
            // Capture the navigator and mounted check BEFORE showing loading dialog
            final navigator = Navigator.of(context);
            
            // Show loading indicator
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(
                child: CircularProgressIndicator(),
              ),
            );

            // Check for active reservations
            final hasReservations = await _hasActiveReservations();
            
            // Hide loading using the captured navigator
            navigator.pop();

            if (hasReservations) {
              // Show error dialog
              if (mounted) {
                _showCannotDeleteDialog();
              }
            } else {
              // Proceed with deletion
              await _deleteAccount();
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('حذف الحساب'),
        ),
      ],
    ),
  );
}
void _showCannotDeleteDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning, color: Colors.orange),
          SizedBox(width: 10),
          Text('لا يمكن حذف الحساب'),
        ],
      ),
      content: const Text(
        'لديك حجز نشط (معلق أو مؤكد). يجب إلغاء الحجز أولاً قبل حذف الحساب.',
        textAlign: TextAlign.right,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('حسناً'),
        ),
      ],
    ),
  );
}

Future<bool> _hasActiveReservations() async {
  try {
    // Check for pending reservation
    final pendingReservation = await ApiService.getMyPendingReservation();
    if (pendingReservation.isNotEmpty) {
      return true;
    }
  } catch (e) {
    // No pending reservation found
    print('No pending reservation: $e');
  }

  try {
    // Check for validated reservation
    final validatedReservation = await ApiService.getMyValidatedReservation();
    if (validatedReservation.isNotEmpty) {
      return true;
    }
  } catch (e) {
    // No validated reservation found
    print('No validated reservation: $e');
  }

  return false;
}

Future<void> _deleteAccount() async {
  try {
    await ApiService.deleteProfile();
    await ApiService.clearToken();
    
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حذف الحساب بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في حذف الحساب: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
}