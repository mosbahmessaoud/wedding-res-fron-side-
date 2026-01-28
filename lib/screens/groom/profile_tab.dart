// lib/screens/home/tabs/profile_tab.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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


// Helper functions
Future<void> _launchWhatsApp() async {
  final Uri whatsappUri = Uri.parse('https://wa.me/213542951750');
  if (!await launchUrl(whatsappUri, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch WhatsApp');
  }
}

Future<void> _launchEmail() async {
  final Uri emailUri = Uri.parse('mailto:itridev.soft@gmail.com');
  if (!await launchUrl(emailUri)) {
    throw Exception('Could not launch email');
  }
}

Future<void> _launchPhone() async {
  final Uri phoneUri = Uri.parse('tel:+213542951750');
  if (!await launchUrl(phoneUri)) {
    throw Exception('Could not launch phone');
  }
}
void _showAboutApp() {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.info, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          const Text('حول التطبيق', style: TextStyle(fontSize: 20)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تطبيق حجوزات الأعراس الخاص بجميع العشائر',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('الإصدار: 1.0.5', style: TextStyle(fontSize: 14)),
            ),
            const SizedBox(height: 16),
            Text(
              'يسرّنا أن نرحب بكم في تطبيق الأعراس، ونضع بين أيديكم وسيلة ميسرة لتنظيم وحجز العرس الخاص بكم',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'برعاية:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'عشيرة آت الشيخ الحاج مسعود',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'فريق التطوير',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 12),
            
            // Email Button
            InkWell(
              onTap: _launchEmail,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.blue[900]?.withOpacity(0.3) : Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.email, size: 18, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'itridev.soft@gmail.com',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.blue),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // WhatsApp Button
            InkWell(
              onTap: _launchWhatsApp,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.green[900]?.withOpacity(0.3) : Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green[700],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.phone, size: 18, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'واتساب',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            '0542951750',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.green),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Info Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.green[900]?.withOpacity(0.2) : Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.green[700]! : Colors.green[200]!,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.green[700], size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'لأي استفسارات أو ملاحظات، نسعد بتواصلكم معنا',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.green[100] : Colors.green[900],
                        height: 1.4,
                      ),
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
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('إغلاق', style: TextStyle(fontSize: 15)),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.support_agent, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          const Text('الدعم والمساعدة', style: TextStyle(fontSize: 20)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'نحن هنا لمساعدتك! تواصل معنا عبر:',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 20),
            
            // Email Button
            InkWell(
              onTap: _launchEmail,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.blue[900]?.withOpacity(0.3) : Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.email_outlined, size: 24, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'البريد الإلكتروني',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'itridev.soft@gmail.com',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // WhatsApp Button
            InkWell(
              onTap: _launchWhatsApp,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isDark ? Colors.green[900]!.withOpacity(0.4) : Colors.green[50]!,
                      isDark ? Colors.green[800]!.withOpacity(0.3) : Colors.green[100]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green[700],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.chat, size: 24, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'واتساب',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '0542951750',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.green),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Help Info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? Colors.orange[900]?.withOpacity(0.2) : Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.schedule, color: Colors.orange[700], size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'نستجيب لاستفساراتكم في أقرب وقت ممكن',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.orange[100] : Colors.orange[900],
                        height: 1.4,
                      ),
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
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('إغلاق', style: TextStyle(fontSize: 15)),
        ),
      ],
    ),
  );
}
  // void _showAboutApp() {
  //   final isDark = Theme.of(context).brightness == Brightness.dark;

  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('حول التطبيق'),
  //       content: SingleChildScrollView(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             const Text(
  //               'تطبيق حجوزات الأعراس الخاص بجميع العشائر ',
  //               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //             ),
  //             const SizedBox(height: 8),
  //             const Text('الإصدار: 1.0.1'),
  //             const SizedBox(height: 16),
  //             const Text(
  //               'يسرّنا أن نرحب بكم في تطبيق الأعراس،\nونضع بين أيديكم وسيلة ميسرة لتنظيم و حجز العرس الخاص بكم',
  //             ),
  //             const SizedBox(height: 16),
  //             const Divider(),
  //             const SizedBox(height: 8),
  //             const Text(
  //               'برعاية:',
  //               style: TextStyle(fontWeight: FontWeight.bold),
  //             ),
  //             const SizedBox(height: 4),
  //             const Text('عشيرة آت الشيخ الحاج مسعود'),
  //             const SizedBox(height: 16),
  //             const Divider(),
  //             const SizedBox(height: 8),
  //             const Text(
  //               ' معلومات فريق التطوير:',
  //               style: TextStyle(fontWeight: FontWeight.bold),
  //             ),
  //             const SizedBox(height: 8),
  //             Row(
  //               children: [
  //                 const Icon(Icons.email, size: 18),
  //                 const SizedBox(width: 8),
  //                 const Expanded(
  //                   child: Text('itridev.soft@gmail.com'),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 8),
  //             Row(
  //               children: [
  //                 const Icon(Icons.phone, size: 18),
  //                 const SizedBox(width: 8),
  //                 const Text('0542951750'),
  //               ],
  //             ),
  //             const SizedBox(height: 16),
  //             Container(
  //               padding: const EdgeInsets.all(12),
  //               decoration: BoxDecoration(
  //                 color: isDark ?Colors.green.shade300 : Colors.green.shade50,
  //                 borderRadius: BorderRadius.circular(8),
  //                 border: Border.all(color: isDark ?Colors.green.shade500 : Colors.green.shade200),
  //               ),
  //               child: Row(
  //                 children: [
  //                   Icon(Icons.message, color: Colors.green.shade700, size: 20),
  //                   const SizedBox(width: 8),
  //                   Expanded(
  //                     child: Text(
  //                       '   لأي ملاحظات أو استفسارات عن التطبيق، \n يرجى التواصل عبر الواتساب (0542951750)'   ,
  //                       style: TextStyle(fontSize: 13, color: isDark ?AppColors.darkTextPrimary : AppColors.darkBorder),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('موافق'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // void _showHelpSupport() {
  //   final isDark = Theme.of(context).brightness == Brightness.dark;

  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('لدعم والمساعدة'),
  //       content: SingleChildScrollView(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
              
  //             // const Text(
  //             //   'معلومات فريق  التطوير:',
  //             //   style: TextStyle(fontWeight: FontWeight.bold),
  //             // ),
  //             // const SizedBox(height: 8),
  //             Row(
  //               children: [
  //                 const Icon(Icons.email, size: 18),
  //                 const SizedBox(width: 8),
  //                 const Expanded(
  //                   child: Text('itridev.soft@gmail.com'),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 8),
  //             Row(
  //               children: [
  //                 const Icon(Icons.phone, size: 18),
  //                 const SizedBox(width: 8),
  //                 const Text('0542951750'),
  //               ],
  //             ),
  //             const SizedBox(height: 16),
  //             Container(
  //               padding: const EdgeInsets.all(12),
  //               decoration: BoxDecoration(
  //                 color: isDark ?Colors.green.shade300 : Colors.green.shade50,
  //                 borderRadius: BorderRadius.circular(8),
  //                 border: Border.all(color: isDark ?Colors.green.shade500 : Colors.green.shade200),
  //               ),
  //               child: Row(
  //                 children: [
  //                   Icon(Icons.message, color: Colors.green.shade700, size: 20),
  //                   const SizedBox(width: 8),
  //                   Expanded(
  //                     child: Text(
  //                       '   لأي ملاحظات أو استفسارات عن التطبيق، \n يرجى التواصل عبر الواتساب (0542951750)'   ,
  //                       style: TextStyle(fontSize: 13, color: isDark ?AppColors.darkTextPrimary : AppColors.darkBorder),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('موافق'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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