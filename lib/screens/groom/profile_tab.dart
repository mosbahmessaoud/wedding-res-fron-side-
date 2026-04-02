// lib/screens/home/tabs/profile_tab.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wedding_reservation_app/models/clan.dart';
import 'package:wedding_reservation_app/models/county.dart';
import 'package:wedding_reservation_app/screens/groom/updating_patge.dart';
import 'package:wedding_reservation_app/services/notification_manager.dart';
import 'package:wedding_reservation_app/services/token_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedding_reservation_app/services/notification_service.dart';
import 'package:wedding_reservation_app/services/foreground_notification_service.dart';
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
  bool _canUpdateProfile = false;
  String? _updateBlockReason;
  Map<String, dynamic>? _cachedUserProfile;
  Map<String, dynamic>? _cachedClanInfo;
  Map<String, dynamic>? _cachedCountyInfo;
  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfileInBackground());
  }

  Future<void> refreshData() async => await _loadProfileInBackground();

  void _loadCachedData() {
    setState(() {
      _userProfile = _cachedUserProfile;
      _clanInfo = _cachedClanInfo;
      _countyInfo = _cachedCountyInfo;
      _isLoading = _cachedUserProfile == null && !_hasLoadedOnce;
    });
  }

  Future<void> _loadProfileInBackground() async {
    try {
      if (_cachedUserProfile == null) setState(() => _isLoading = true);
      _userProfile = await ApiService.getMyGroomProfile();
      _cachedUserProfile = _userProfile;
      await _checkUpdateEligibility();
      await Future.wait([_loadClanInfo(), _loadCountyInfo()]);
      _hasLoadedOnce = true;
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkUpdateEligibility() async {
    try {
      final result = await ApiService.canUpdateGroomProfile();
      if (mounted) setState(() {
        _canUpdateProfile = result['can_update'] == true;
        _updateBlockReason = result['reason'];
      });
    } catch (e) {
      print('Error checking update eligibility: $e');
      if (mounted) setState(() {
        _canUpdateProfile = false;
        _updateBlockReason = 'خطأ في التحقق من إمكانية التحديث';
      });
    }
  }

  Future<void> _checkConnectivityAndLoad() async {
    _loadCachedData();
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      _showNoInternetDialog();
      return;
    }
    await _loadProfileInBackground();
  }

  // void _showNoInternetDialog() {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => AlertDialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //       title: Row(children: [Icon(Icons.wifi_off, color: Colors.orange), SizedBox(width: 10), Text('لا يوجد اتصال')]),
  //       content: Text('يرجى التحقق من اتصالك بالإنترنت'),
  //       actions: [
  //         TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء')),
  //         ElevatedButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             _checkConnectivityAndLoad();
  //           },
  //           style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon Container
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              color: Colors.orange,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          
          // Title
          const Text(
            'لا يوجد اتصال بالإنترنت',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          
          // Description
          Text(
            'يرجى التحقق من اتصالك بالإنترنت',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('إغلاق'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _checkConnectivityAndLoad();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('إعادة المحاولة'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  Future<void> _loadClanInfo() async {
    if (_userProfile?['clan_id'] == null) return;
    try {
      final clans = await ApiService.getClans();
      final foundClan = clans.cast<Clan?>().firstWhere((clan) => clan?.id == _userProfile?['clan_id'], orElse: () => null);
      _clanInfo = foundClan?.toJson();
      _cachedClanInfo = _clanInfo;
    } catch (e) {}
  }

  Future<void> _loadCountyInfo() async {
    if (_userProfile?['county_id'] == null) return;
    try {
      final counties = await ApiService.getCounties();
      final foundCounty = counties.cast<County?>().firstWhere((county) => county?.id == _userProfile?['county_id'], orElse: () => null);
      _countyInfo = foundCounty?.toJson();
      _cachedCountyInfo = _countyInfo;
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _cachedUserProfile == null) return const Center(child: CircularProgressIndicator());

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) => null,
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
              _buildGroomInfoSection(),
              const SizedBox(height: 24),
              _buildGuardianInfoSection(),
              const SizedBox(height: 24),
              _buildWakilInfoSection(),
              const SizedBox(height: 24),
              _buildActionButtonsReservUpdate(),
              const SizedBox(height: 24),
              _buildSecuritySection(),
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
        gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CircleAvatar(radius: 40, backgroundColor: Colors.white.withOpacity(0.2), child: Icon(Icons.person, size: 40, color: Colors.white)),
          const SizedBox(height: 12),
          Text(fullName.isNotEmpty ? fullName : 'العريس', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(_userProfile?['phone_number'] ?? '', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16)),
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
            const Text('معلومات الموقع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.location_city, 'القصر', _countyInfo?['name'] ?? 'غير محدد'),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.group, 'العشيرة', _clanInfo?['name'] ?? 'غير محدد'),
          ],
        ),
      ),
    );
  }

  Widget _buildGroomInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('معلومات العريس', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                IconButton(icon: Icon(Icons.edit, color: _canUpdateProfile ? AppColors.primary : Colors.grey), onPressed: _canUpdateProfile ? _showEditGroomDialog : _showCannotEditDialog),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.person, 'إسم العريس', _userProfile?['first_name'] ?? 'غير محدد'),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.person_outline, 'اللقب', _userProfile?['last_name'] ?? 'غير محدد'),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.person, 'اسم الأب', _userProfile?['father_name'] ?? 'غير محدد'),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.person, 'اسم الجد', _userProfile?['grandfather_name'] ?? 'غير محدد'),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.phone, 'رقم الهاتف', _userProfile?['phone_number'] ?? 'غير محدد'),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.calendar_today, 'تاريخ الميلاد', _userProfile?['birth_date'] ?? 'غير محدد'),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_on, 'مكان الميلاد', _userProfile?['birth_address'] ?? 'غير محدد'),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.home, 'عنوان السكن', _userProfile?['home_address'] ?? 'غير محدد'),
            if (_userProfile?['family_name'] != null && _userProfile!['family_name'].toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(Icons.family_restroom, 'إسم العائلة (إختياري)', _userProfile?['family_name']),
            ],
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('معلومات ولي الأمر', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                IconButton(icon: Icon(Icons.edit, color: _canUpdateProfile ? AppColors.primary : Colors.grey), onPressed: _canUpdateProfile ? _showEditGuardianDialog : _showCannotEditDialog),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.person, 'اسم الولي', _userProfile?['guardian_name'] ?? 'غير محدد'),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.phone, 'هاتف الولي', _userProfile?['guardian_phone'] ?? 'غير محدد'),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.calendar_today, 'تاريخ ميلاد الولي', _userProfile?['guardian_birth_date'] ?? 'غير محدد'),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_on, 'مكان ميلاد الولي', _userProfile?['guardian_birth_address'] ?? 'غير محدد'),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.home, 'عنوان سكن الولي', _userProfile?['guardian_home_address'] ?? 'غير محدد'),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.family_restroom, 'صلة القرابة', _userProfile?['guardian_relation'] ?? 'غير محدد'),
          ],
        ),
      ),
    );
  }

  // Widget _buildWakilInfoSection() {
  //   final hasWakilInfo = _userProfile?['wakil_full_name'] != null && _userProfile!['wakil_full_name'].toString().isNotEmpty;
  //   return Card(
  //     child: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               const Text('معلومات وكيل العرس (إختياري)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
  //               IconButton(icon: Icon(hasWakilInfo ? Icons.edit : Icons.add, color: _canUpdateProfile ? AppColors.primary : Colors.grey), onPressed: _canUpdateProfile ? _showEditWakilDialog : _showCannotEditDialog),
  //             ],
  //           ),
  //           const SizedBox(height: 16),
  //           if (hasWakilInfo) ...[
  //             _buildInfoRow(Icons.person_pin, 'الاسم الكامل', _userProfile?['wakil_full_name'] ?? 'غير محدد'),
  //             const SizedBox(height: 12),
  //             _buildInfoRow(Icons.phone, 'رقم الهاتف', _userProfile?['wakil_phone_number'] ?? 'غير محدد'),
  //           ] else
  //             Center(child: Text('لم يتم إضافة معلومات وكيل العرس', style: TextStyle(color: Colors.grey[600], fontSize: 14))),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  Widget _buildWakilInfoSection() {
  final hasWakilInfo = _userProfile?['wakil_full_name'] != null && 
                        _userProfile!['wakil_full_name'].toString().isNotEmpty;
  
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Wrap the Text in Expanded to allow it to wrap on small screens
              Expanded(
                child: const Text(
                  'معلومات وكيل العرس (إختياري)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary
                  ),
                  // Optional: Add overflow and maxLines for better control
                  overflow: TextOverflow.visible,
                  softWrap: true,
                ),
              ),
              // Add a small spacing
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  hasWakilInfo ? Icons.edit : Icons.add,
                  color: _canUpdateProfile ? AppColors.primary : Colors.grey
                ),
                onPressed: _canUpdateProfile 
                    ? _showEditWakilDialog 
                    : _showCannotEditDialog
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (hasWakilInfo) ...[
            _buildInfoRow(Icons.person_pin, 'الاسم الكامل', 
                         _userProfile?['wakil_full_name'] ?? 'غير محدد'),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.phone, 'رقم الهاتف', 
                         _userProfile?['wakil_phone_number'] ?? 'غير محدد'),
          ] else
            Center(
              child: Text(
                'لم يتم إضافة معلومات وكيل العرس',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14
                ),
                textAlign: TextAlign.center,
              )
            ),
        ],
      ),
    ),
  );
}

  Widget _buildSecuritySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text('الأمان', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.lock_reset, color: Colors.orange),
              ),
              title: Text('تغيير كلمة المرور'),
              subtitle: Text('قم بتحديث كلمة مرورك بانتظام', style: TextStyle(fontSize: 12)),
              trailing: Icon(Icons.chevron_right),
              onTap: _showChangePasswordDialog,
            ),
            Divider(height: 1),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.phone_android, color: Colors.blue),
              ),
              title: Text('تغيير رقم الهاتف'),
              subtitle: Text('تحديث رقم الهاتف المسجل', style: TextStyle(fontSize: 12)),
              trailing: Icon(Icons.chevron_right),
              onTap: _showChangePhoneDialog,
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
        Icon(icon, size: 20, color: isDark ? AppColors.primaryLight : AppColors.primary),
        const SizedBox(width: 12),
        Text('$label: ', style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
        Expanded(child: Text(value, style: TextStyle(color: isDark ? AppColors.darkTextHint : AppColors.darkCard, fontWeight: FontWeight.w500))),
      ],
    );
  }

  void _showCannotEditDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [Icon(Icons.block, color: Colors.orange), SizedBox(width: 10), Text('لا يمكن التعديل')]),
        content: Text(_updateBlockReason ?? 'لا يمكن تعديل الملف الشخصي في الوقت الحالي', textAlign: TextAlign.right),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('حسناً'))],
      ),
    );
  }

  // ==================== PASSWORD CHANGE ====================
  
  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.lock_reset, color: Colors.orange),
              ),
              SizedBox(width: 12),
              Text('تغيير كلمة المرور'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: obscureCurrent,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور الحالية',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(obscureCurrent ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => obscureCurrent = !obscureCurrent),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور الجديدة',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => obscureNew = !obscureNew),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'تأكيد كلمة المرور',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => obscureConfirm = !obscureConfirm),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.blue),
                      SizedBox(width: 8),
                      Expanded(child: Text('يجب أن تحتوي كلمة المرور على 6 أحرف على الأقل', style: TextStyle(fontSize: 12, color: Colors.blue))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                if (currentPasswordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('يرجى إدخال كلمة المرور الحالية'), backgroundColor: Colors.red));
                  return;
                }
                if (newPasswordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('يرجى إدخال كلمة المرور الجديدة'), backgroundColor: Colors.red));
                  return;
                }
                if (newPasswordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('كلمات المرور غير متطابقة'), backgroundColor: Colors.red));
                  return;
                }
                if (newPasswordController.text.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('كلمة المرور قصيرة جداً'), backgroundColor: Colors.red));
                  return;
                }

                Navigator.pop(context);
                showDialog(context: context, barrierDismissible: false, builder: (context) => Center(child: CircularProgressIndicator()));

                try {
                  await ApiService.resetPasswordGroom(
                    currentPassword: currentPasswordController.text,
                    newPassword: newPasswordController.text,
                    confirmPassword: confirmPasswordController.text,
                  );
                  
                  // Check if widget is still mounted before using context
                  if (!mounted) return;
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم تغيير كلمة المرور بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  // Check if widget is still mounted before using context
                  if (!mounted) return;
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('تغيير', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== PHONE CHANGE ====================
  
  // void _showChangePhoneDialog() {
  //   final passwordController = TextEditingController();
  //   final phoneController = TextEditingController();
  //   bool obscurePassword = true;

  //   showDialog(
  //     context: context,
  //     builder: (context) => StatefulBuilder(
  //       builder: (context, setState) => AlertDialog(
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //         title: Row(
  //           children: [
  //             Container(
  //               padding: EdgeInsets.all(8),
  //               decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
  //               child: Icon(Icons.phone_android, color: Colors.blue),
  //             ),
  //             SizedBox(width: 12),
  //             Expanded(child: Text('تغيير رقم الهاتف')),
  //           ],
  //         ),
  //         content: SingleChildScrollView(
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Container(
  //                 padding: EdgeInsets.all(12),
  //                 decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
  //                 child: Row(
  //                   children: [
  //                     Icon(Icons.security, size: 16, color: Colors.orange),
  //                     SizedBox(width: 8),
  //                     Expanded(child: Text('للأمان، يرجى إدخال كلمة المرور أولاً', style: TextStyle(fontSize: 12, color: Colors.orange))),
  //                   ],
  //                 ),
  //               ),
  //               SizedBox(height: 16),
  //               TextField(
  //                 controller: passwordController,
  //                 obscureText: obscurePassword,
  //                 decoration: InputDecoration(
  //                   labelText: 'كلمة المرور',
  //                   prefixIcon: Icon(Icons.lock_outline),
  //                   suffixIcon: IconButton(
  //                     icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
  //                     onPressed: () => setState(() => obscurePassword = !obscurePassword),
  //                   ),
  //                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  //                 ),
  //               ),
  //               SizedBox(height: 16),
  //               TextField(
  //                 controller: phoneController,
  //                 keyboardType: TextInputType.phone,
  //                 inputFormatters: [FilteringTextInputFormatter.digitsOnly],
  //                 decoration: InputDecoration(
  //                   labelText: 'رقم الهاتف الجديد',
  //                   prefixIcon: Icon(Icons.phone),
  //                   // hintText: '0XXXXXXXXX',
  //                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  //                 ),
  //               ),
  //               SizedBox(height: 12),
  //               Container(
  //                 padding: EdgeInsets.all(12),
  //                 decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Row(
  //                       children: [
  //                         Icon(Icons.info_outline, size: 16, color: Colors.blue),
  //                         SizedBox(width: 8),
  //                         Text('معلومات هامة:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
  //                       ],
  //                     ),
  //                     SizedBox(height: 4),
  //                     Text('• سيتم إرسال رمز تحقق إلى الرقم الجديد', style: TextStyle(fontSize: 11, color: Colors.blue)),
  //                     // Text('• لا يمكن التغيير إذا كان لديك حجز مؤكد', style: TextStyle(fontSize: 11, color: Colors.blue)),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         actions: [
  //           TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء')),
  //           ElevatedButton(
  //             onPressed: () async {
  //               if (passwordController.text.isEmpty) {
  //                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('يرجى إدخال كلمة المرور'), backgroundColor: Colors.red));
  //                 return;
  //               }
  //               if (phoneController.text.isEmpty) {
  //                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('يرجى إدخال رقم الهاتف الجديد'), backgroundColor: Colors.red));
  //                 return;
  //               }

  //               Navigator.pop(context);
                
  //               // Verify password first by attempting login
  //               showDialog(context: context, barrierDismissible: false, builder: (context) => Center(child: CircularProgressIndicator()));
                
  //               try {
  //                 // Verify password by checking if login works with current phone and password
  //                 await ApiService.login(_userProfile?['phone_number'] ?? '', passwordController.text);
  //                 Navigator.pop(context);
                  
  //                 // Password is correct, proceed with phone change
  //                 _requestPhoneChange(phoneController.text);
  //               } catch (e) {
  //                 Navigator.pop(context);
  //                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('كلمة المرور غير صحيحة'), backgroundColor: Colors.red));
  //               }
  //             },
  //             style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
  //             child: Text('متابعة', style: TextStyle(color: Colors.white)),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
void _showChangePhoneDialog() {
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  bool obscurePassword = true;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.phone_android, color: Colors.blue),
            ),
            SizedBox(width: 12),
            Expanded(child: Text('تغيير رقم الهاتف')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(Icons.security, size: 16, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(child: Text('للأمان، يرجى إدخال كلمة المرور أولاً', style: TextStyle(fontSize: 12, color: Colors.orange))),
                  ],
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => obscurePassword = !obscurePassword),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف الجديد',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('معلومات هامة:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text('• سيتم إرسال رمز تحقق إلى الرقم الجديد', style: TextStyle(fontSize: 11, color: Colors.blue)),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              // Validation
              if (passwordController.text.isEmpty) {
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(content: Text('يرجى إدخال كلمة المرور'), backgroundColor: Colors.red)
                );
                return;
              }
              if (phoneController.text.isEmpty) {
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(content: Text('يرجى إدخال رقم الهاتف الجديد'), backgroundColor: Colors.red)
                );
                return;
              }

              // Save values before closing dialog
              final password = passwordController.text;
              final newPhone = phoneController.text;
              
              // Close dialog
              Navigator.pop(context);
              
              // Verify password in background
              if (!mounted) return;
              
              try {
                // Verify password by attempting login
                await ApiService.login(_userProfile?['phone_number'] ?? '', password);
                
                if (!mounted) return;
                
                // Password is correct, proceed with phone change
                _requestPhoneChange(newPhone);
              } catch (e) {
                if (!mounted) return;
                
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text('كلمة المرور غير صحيحة'), 
                    backgroundColor: Colors.red
                  )
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            ),
            child: Text('متابعة', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );
}

void _showOTPVerificationDialog(String newPhone, String? tempPhone) {
  final otpController = TextEditingController();
  
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.sms, color: Colors.green),
          ),
          SizedBox(width: 12),
          Text('رمز التحقق'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('تم إرسال رمز التحقق إلى', textAlign: TextAlign.center),
          SizedBox(height: 8),
          Text(tempPhone ?? newPhone, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
          SizedBox(height: 20),
          TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, letterSpacing: 8),
            decoration: InputDecoration(
              labelText: 'رمز التحقق',
              hintText: '000000',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () async {
                  try {
                    await ApiService.resendPhoneResetOTP();
                    if (!mounted) return;
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(content: Text('تم إعادة إرسال الرمز'), backgroundColor: Colors.green)
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString().replaceAll('Exception: ', '')), 
                        backgroundColor: Colors.red
                      )
                    );
                  }
                },
                icon: Icon(Icons.refresh),
                label: Text('إعادة إرسال'),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            try {
              await ApiService.cancelPhoneResetRequest();
              if (!mounted) return;
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(content: Text('تم إلغاء العملية'), backgroundColor: Colors.orange)
              );
            } catch (e) {
              if (!mounted) return;
              Navigator.of(dialogContext).pop();
            }
          },
          child: Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (otpController.text.isEmpty) {
              if (!mounted) return;
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(content: Text('يرجى إدخال رمز التحقق'), backgroundColor: Colors.red)
              );
              return;
            }
            
            // Save OTP value before closing dialog
            final otp = otpController.text;
            
            // Close the dialog first
            Navigator.of(dialogContext).pop();
            
            if (!mounted) return;
            
            // Show loading indicator
            showDialog(
              context: this.context,
              barrierDismissible: false,
              builder: (loadingContext) => Center(child: CircularProgressIndicator())
            );
            
            try {
              await ApiService.verifyPhoneNumberReset(otp);
              
              if (!mounted) return;
              
              // Close loading dialog
              Navigator.of(this.context).pop();
              
              await _loadProfileInBackground();
              
              if (!mounted) return;
              
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(content: Text('تم تغيير رقم الهاتف بنجاح'), backgroundColor: Colors.green)
              );
            } catch (e) {
              if (!mounted) return;
              
              // Close loading dialog
              Navigator.of(this.context).pop();
              
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(
                  content: Text(e.toString().replaceAll('Exception: ', '')), 
                  backgroundColor: Colors.red
                )
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
          ),
          child: Text('تحقق', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
  void _requestPhoneChange(String newPhone) async {
    showDialog(context: context, barrierDismissible: false, builder: (context) => Center(child: CircularProgressIndicator()));

    try {
      final result = await ApiService.requestPhoneNumberReset(newPhone);
      Navigator.pop(context);
      
      _showOTPVerificationDialog(newPhone, result['temp_phone_number']);
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
    }
  }

  // void _showOTPVerificationDialog(String newPhone, String? tempPhone) {
  //   final otpController = TextEditingController();

  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => AlertDialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //       title: Row(
  //         children: [
  //           Container(
  //             padding: EdgeInsets.all(8),
  //             decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
  //             child: Icon(Icons.sms, color: Colors.green),
  //           ),
  //           SizedBox(width: 12),
  //           Text('رمز التحقق'),
  //         ],
  //       ),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Text('تم إرسال رمز التحقق إلى', textAlign: TextAlign.center),
  //           SizedBox(height: 8),
  //           Text(tempPhone ?? newPhone, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
  //           SizedBox(height: 20),
  //           TextField(
  //             controller: otpController,
  //             keyboardType: TextInputType.number,
  //             inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
  //             textAlign: TextAlign.center,
  //             style: TextStyle(fontSize: 24, letterSpacing: 8),
  //             decoration: InputDecoration(
  //               labelText: 'رمز التحقق',
  //               hintText: '000000',
  //               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  //             ),
  //           ),
  //           SizedBox(height: 16),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               TextButton.icon(
  //                 onPressed: () async {
  //                   try {
  //                     await ApiService.resendPhoneResetOTP();
  //                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم إعادة إرسال الرمز'), backgroundColor: Colors.green));
  //                   } catch (e) {
  //                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
  //                   }
  //                 },
  //                 icon: Icon(Icons.refresh),
  //                 label: Text('إعادة إرسال'),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () async {
  //             try {
  //               await ApiService.cancelPhoneResetRequest();
  //               Navigator.pop(context);
  //               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم إلغاء العملية'), backgroundColor: Colors.orange));
  //             } catch (e) {
  //               Navigator.pop(context);
  //             }
  //           },
  //           child: Text('إلغاء'),
  //         ),
  //         ElevatedButton(
  //           onPressed: () async {
  //             if (otpController.text.isEmpty) {
  //               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('يرجى إدخال رمز التحقق'), backgroundColor: Colors.red));
  //               return;
  //             }

  //             Navigator.pop(context);
  //             showDialog(context: context, barrierDismissible: false, builder: (context) => Center(child: CircularProgressIndicator()));

  //             try {
  //               await ApiService.verifyPhoneNumberReset(otpController.text);
  //               Navigator.pop(context);
  //               await _loadProfileInBackground();
  //               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم تغيير رقم الهاتف بنجاح'), backgroundColor: Colors.green));
  //             } catch (e) {
  //               Navigator.pop(context);
  //               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
  //             }
  //           },
  //           style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
  //           child: Text('تحقق', style: TextStyle(color: Colors.white)),
  //         ),
  //       ],
  //     ),
  //   );
  // }



//   // ==================== EXISTING METHODS ====================
// void _showEditGroomDialog() {
//   final controllers = {
//     'first_name': TextEditingController(text: _userProfile?['first_name']),
//     'last_name': TextEditingController(text: _userProfile?['last_name']),
//     'birth_address': TextEditingController(text: _userProfile?['birth_address']),
//     'home_address': TextEditingController(text: _userProfile?['home_address']),
//     'family_name': TextEditingController(text: _userProfile?['family_name']),
//   };
  
//   DateTime? selectedBirthDate = _parseDate(_userProfile?['birth_date']);

//   showDialog(
//     context: context,
//     builder: (context) => StatefulBuilder(
//       builder: (context, setState) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(
//           mainAxisSize: MainAxisSize.min, // Add this
//           children: [
//             Icon(Icons.edit, color: AppColors.primary),
//             SizedBox(width: 10),
//             Flexible( // Wrap text in Flexible
//               child: Text(
//                 'تعديل معلومات العريس',
//                 overflow: TextOverflow.fade, // Handle overflow
//               ),
//             ),
            

//           ],
          
//         ),
//         content: SingleChildScrollView(
//           child: SizedBox(
//             width: MediaQuery.of(context).size.width * 0.9, // Constrain width
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 SizedBox(height: 12),
//                 _buildTextField(controllers['first_name']!, 'إسم العريس'),
//                 SizedBox(height: 12),
//                 _buildTextField(controllers['last_name']!, 'اللقب'),
//                 SizedBox(height: 12),
//                 _buildDateField(
//                   label: 'تاريخ الميلاد',
//                   selectedDate: selectedBirthDate,
//                   onTap: () async {
//                     final date = await _selectDate(context, selectedBirthDate);
//                     if (date != null) setState(() => selectedBirthDate = date);
//                   },
//                 ),
//                 SizedBox(height: 12),
//                 _buildTextField(controllers['birth_address']!, 'مكان الميلاد'),
//                 SizedBox(height: 12),
//                 _buildTextField(controllers['home_address']!, 'عنوان السكن'),
//                 SizedBox(height: 12),
//                 _buildTextField(controllers['family_name']!, 'اللقب (اختياري)'),
//               ],
//             ),
//           ),
//         ),

//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await _updateProfile(
//                 firstName: controllers['first_name']!.text.trim(),
//                 lastName: controllers['last_name']!.text.trim(),
//                 birthDate: selectedBirthDate != null 
//                     ? DateFormat('yyyy-MM-dd').format(selectedBirthDate!) 
//                     : null,
//                 birthAddress: controllers['birth_address']!.text.trim(),
//                 homeAddress: controllers['home_address']!.text.trim(),
//                 familyName: controllers['family_name']!.text.trim().isEmpty 
//                     ? null 
//                     : controllers['family_name']!.text.trim(),
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//             child: Text('حفظ', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     ),
//   );
// }

void _showEditGroomDialog() {
  final controllers = {
    'first_name': TextEditingController(text: _userProfile?['first_name']),
    'last_name': TextEditingController(text: _userProfile?['last_name']),
    'father_name': TextEditingController(text: _userProfile?['father_name']),
    'grandfather_name': TextEditingController(text: _userProfile?['grandfather_name']),
    'birth_address': TextEditingController(text: _userProfile?['birth_address']),
    'home_address': TextEditingController(text: _userProfile?['home_address']),
    'family_name': TextEditingController(text: _userProfile?['family_name']),
  };
  
  DateTime? selectedBirthDate = _parseDate(_userProfile?['birth_date']);

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit, color: AppColors.primary),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                'تعديل معلومات العريس',
                overflow: TextOverflow.fade,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 12),
                _buildTextField(controllers['first_name']!, 'إسم العريس'),
                SizedBox(height: 12),
                _buildTextField(controllers['last_name']!, 'اللقب'),
                SizedBox(height: 12),
                _buildTextField(controllers['father_name']!, 'اسم الأب'),
                SizedBox(height: 12),
                _buildTextField(controllers['grandfather_name']!, 'اسم الجد'),
                SizedBox(height: 12),
                _buildDateField(
                  label: 'تاريخ الميلاد',
                  selectedDate: selectedBirthDate,
                  onTap: () async {
                    final date = await _selectDate(context, selectedBirthDate);
                    if (date != null) setState(() => selectedBirthDate = date);
                  },
                ),
                SizedBox(height: 12),
                _buildTextField(controllers['birth_address']!, 'مكان الميلاد'),
                SizedBox(height: 12),
                _buildTextField(controllers['home_address']!, 'عنوان السكن'),
                SizedBox(height: 12),
                _buildTextField(controllers['family_name']!, 'اللقب (اختياري)'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateProfile(
                firstName: controllers['first_name']!.text.trim(),
                lastName: controllers['last_name']!.text.trim(),
                fatherName: controllers['father_name']!.text.trim(),
                grandfatherName: controllers['grandfather_name']!.text.trim(),
                birthDate: selectedBirthDate != null 
                    ? DateFormat('yyyy-MM-dd').format(selectedBirthDate!) 
                    : null,
                birthAddress: controllers['birth_address']!.text.trim(),
                homeAddress: controllers['home_address']!.text.trim(),
                familyName: controllers['family_name']!.text.trim().isEmpty 
                    ? null 
                    : controllers['family_name']!.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('حفظ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );
}
  void _showEditGuardianDialog() {
    final controllers = {
      'name': TextEditingController(text: _userProfile?['guardian_name']),
      'phone': TextEditingController(text: _userProfile?['guardian_phone']),
      'birth_address': TextEditingController(text: _userProfile?['guardian_birth_address']),
      'home_address': TextEditingController(text: _userProfile?['guardian_home_address']),
      'relation': TextEditingController(text: _userProfile?['guardian_relation']),
    };
    
    DateTime? selectedBirthDate = _parseDate(_userProfile?['guardian_birth_date']);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
              children: [
                Icon(Icons.edit, color: AppColors.primary),
                SizedBox(width: 10),
                Expanded(  // أضف هذا لتغليف النص
                  child: Text(
                    'تعديل معلومات الولي',
                    overflow: TextOverflow.clip,  // اختياري: يضيف ... إذا كان النص طويلاً
                    maxLines: 2,  // اختياري: يحدد عدد الأسطر
                  ),
                ),
              ],
            ),          
            content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(controllers['name']!, 'اسم الولي'),
                SizedBox(height: 12),
                _buildTextField(controllers['phone']!, 'هاتف الولي', keyboardType: TextInputType.phone),
                SizedBox(height: 12),
                _buildDateField(
                  label: 'تاريخ ميلاد الولي',
                  selectedDate: selectedBirthDate,
                  onTap: () async {
                    final date = await _selectDate(context, selectedBirthDate);
                    if (date != null) setState(() => selectedBirthDate = date);
                  },
                ),
                SizedBox(height: 12),
                _buildTextField(controllers['birth_address']!, 'مكان ميلاد الولي'),
                SizedBox(height: 12),
                _buildTextField(controllers['home_address']!, 'عنوان سكن الولي'),
                SizedBox(height: 12),
                _buildTextField(controllers['relation']!, 'صلة القرابة'),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _updateProfile(
                  guardianName: controllers['name']!.text.trim(),
                  guardianPhone: controllers['phone']!.text.trim(),
                  guardianBirthDate: selectedBirthDate != null ? DateFormat('yyyy-MM-dd').format(selectedBirthDate!) : null,
                  guardianBirthAddress: controllers['birth_address']!.text.trim(),
                  guardianHomeAddress: controllers['home_address']!.text.trim(),
                  guardianRelation: controllers['relation']!.text.trim(),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('حفظ', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditWakilDialog() {
    final controllers = {
      'name': TextEditingController(text: _userProfile?['wakil_full_name']),
      'phone': TextEditingController(text: _userProfile?['wakil_phone_number']),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
              children: [
                Icon(Icons.edit, color: AppColors.primary),
                SizedBox(width: 10),
                Expanded(  // أضف هذا لتغليف النص
                  child: Text(
                    'تعديل معلومات الوكيل',
                    overflow: TextOverflow.clip,  // اختياري: يضيف ... إذا كان النص طويلاً
                    maxLines: 2,  // اختياري: يحدد عدد الأسطر
                  ),
                ),
              ],
            ),  
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(controllers['name']!, 'الاسم الكامل للوكيل'),
            SizedBox(height: 12),
            _buildTextField(controllers['phone']!, 'رقم هاتف الوكيل', keyboardType: TextInputType.phone),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateProfile(
                wakilFullName: controllers['name']!.text.trim().isEmpty ? null : controllers['name']!.text.trim(),
                wakilPhoneNumber: controllers['phone']!.text.trim().isEmpty ? null : controllers['phone']!.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text('حفظ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      keyboardType: keyboardType,
    );
  }

  Widget _buildDateField({required String label, DateTime? selectedDate, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          suffixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
        ),
        child: Text(selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate) : 'اختر التاريخ'),
      ),
    );
  }

  Future<DateTime?> _selectDate(BuildContext context, DateTime? initialDate) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: AppColors.primary)),
          child: child!,
        );
      },
    );
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  Future<void> _updateProfile({
    String? firstName,
    String? lastName,
    String? fatherName,
    String? grandfatherName,
    String? birthDate,
    String? birthAddress,
    String? homeAddress,
    String? guardianName,
    String? guardianPhone,
    String? guardianBirthDate,
    String? guardianBirthAddress,
    String? guardianHomeAddress,
    String? guardianRelation,
    String? wakilFullName,
    String? wakilPhoneNumber,
    String? familyName,
  }) async {
    showDialog(context: context, barrierDismissible: false, builder: (context) => Center(child: CircularProgressIndicator()));

    try {
      await ApiService.updateGroomProfileDetails(
        firstName: firstName,
        lastName: lastName,
        fatherName: fatherName,
        grandfatherName: grandfatherName,
        birthDate: birthDate,
        birthAddress: birthAddress,
        homeAddress: homeAddress,
        guardianName: guardianName,
        guardianPhone: guardianPhone,
        guardianBirthDate: guardianBirthDate,
        guardianBirthAddress: guardianBirthAddress,
        guardianHomeAddress: guardianHomeAddress,
        guardianRelation: guardianRelation,
        wakilFullName: wakilFullName,
        wakilPhoneNumber: wakilPhoneNumber,
        familyName: familyName,
      );

      Navigator.pop(context);
      await _loadProfileInBackground();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم تحديث الملف الشخصي بنجاح'), backgroundColor: Colors.green));
      }
    } catch (e) {
      Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في تحديث الملف الشخصي: ${e.toString()}'), backgroundColor: Colors.red));
      }
    }
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Card(
          child: Column(
            children: [
              
              // ListTile(leading: const Icon(Icons.notifications, color: AppColors.primary), title: const Text('الإشعارات'), trailing: const Icon(Icons.chevron_right), onTap: _showNotificationSettings),
              // const Divider(height: 1),
              ListTile(leading: const Icon(Icons.security, color: AppColors.primary), title: const Text('اخر أخبار العشيرة'), trailing: const Icon(Icons.chevron_right), onTap: _showNewsClan),
              const Divider(height: 1),
              ListTile(leading: const Icon(Icons.help, color: AppColors.primary), title: const Text('المساعدة والدعم'), trailing: const Icon(Icons.chevron_right), onTap: _showHelpSupport),
              const Divider(height: 1),
              ListTile(leading: const Icon(Icons.info, color: AppColors.primary), title: const Text('حول التطبيق'), trailing: const Icon(Icons.chevron_right), onTap: _showAboutApp),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(leading: const Icon(Icons.logout, color: Colors.orange), title: const Text('تسجيل الخروج'), onTap: _showLogoutDialog),
              const Divider(height: 1),
              ListTile(leading: const Icon(Icons.delete_forever, color: Colors.red), title: const Text('حذف الحساب'), onTap: _showDeleteAccountDialog),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtonsReservUpdate() {
    return Column(
      children: [
        Card(
          child: Column(
            children: [
              ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit_calendar, color: AppColors.primary),
              ),
              title: const Text('تعديل معلومات الحجز'),
              // subtitle: const Text('تعديل الهيئة، اللجنة', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showReservationUpdateOptions,
            ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
      ],
    );
  }

  void _showNotificationSettings() => showDialog(context: context, builder: (context) => AlertDialog(title: const Text('إعدادات الإشعارات', textAlign: TextAlign.right), content: const Text('هذه الميزة قيد التطوير حالياً. سيتم إضافتها قريباً.', textAlign: TextAlign.right), actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('حسناً'))]));

  void _showNewsClan() => showDialog(context: context, builder: (context) => AlertDialog(title: const Text('أخبار العشيرة', textAlign: TextAlign.right), content: const Text('هذه الصفحة قيد التطوير حالياً. سيتم إضافتها قريباً.', textAlign: TextAlign.right), actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('حسناً'))]));

  Future<void> _launchWhatsApp() async {
    final Uri whatsappUri = Uri.parse('https://wa.me/213542951750');
    if (!await launchUrl(whatsappUri, mode: LaunchMode.externalApplication)) throw Exception('Could not launch WhatsApp');
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri.parse('mailto:itridev.soft@gmail.com');
    if (!await launchUrl(emailUri)) throw Exception('Could not launch email');
  }

  void _showAboutApp() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [Container(padding: const EdgeInsets.all(2), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.info, color: AppColors.primary, size: 24)), const SizedBox(width: 12), const Text('حول التطبيق', style: TextStyle(fontSize: 20))]),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('تطبيق حجوزات الأعراس الخاص بجميع العشائر', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.grey[100], borderRadius: BorderRadius.circular(8)), child: const Text('الإصدار: 1.0.5', style: TextStyle(fontSize: 14))),
              const SizedBox(height: 16),
              Text('يسرّنا أن نرحب بكم في تطبيق الأعراس، ونضع بين أيديكم وسيلة ميسرة لتنظيم وحجز العرس الخاص بكم', style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[300] : Colors.grey[700], height: 1.5)),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              const Text('برعاية:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.1), AppColors.primary.withOpacity(0.05)]), borderRadius: BorderRadius.circular(12)), child: const Text('عشيرة آت الشيخ الحاج مسعود', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              const Text('فريق التطوير', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 12),
              InkWell(onTap: _launchEmail, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isDark ? Colors.blue[900]?.withOpacity(0.3) : Colors.blue[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.withOpacity(0.3))), child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.email, size: 18, color: Colors.white)), const SizedBox(width: 12), const Expanded(child: Text('itridev.soft@gmail.com', style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.w500))), const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.blue)]))),
              const SizedBox(height: 12),
              InkWell(onTap: _launchWhatsApp, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isDark ? Colors.green[900]?.withOpacity(0.3) : Colors.green[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.withOpacity(0.3))), child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.green[700], borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.phone, size: 18, color: Colors.white)), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('واتساب', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)), Text('0542951750', style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold))])), const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.green)]))),
              const SizedBox(height: 16),
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isDark ? Colors.green[900]?.withOpacity(0.2) : Colors.green[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? Colors.green[700]! : Colors.green[200]!)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.info_outline, color: Colors.green[700], size: 20), const SizedBox(width: 10), Expanded(child: Text('لأي استفسارات أو ملاحظات، نسعد بتواصلكم معنا', style: TextStyle(fontSize: 13, color: isDark ? Colors.green[100] : Colors.green[900], height: 1.4)))])),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)), child: const Text('إغلاق', style: TextStyle(fontSize: 15)))],
      ),
    );
  }

  void _showHelpSupport() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(children: [Container(padding: const EdgeInsets.all(2), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.support_agent, color: AppColors.primary, size: 24)), const SizedBox(width: 12), const Text('الدعم والمساعدة', style: TextStyle(fontSize: 20))]),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('نحن هنا لمساعدتك! تواصل معنا عبر:', style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[300] : Colors.grey[700])),
              const SizedBox(height: 20),
              InkWell(onTap: _launchEmail, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: isDark ? Colors.blue[900]?.withOpacity(0.3) : Colors.blue[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.withOpacity(0.3))), child: Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.email_outlined, size: 24, color: Colors.white)), const SizedBox(width: 16), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('البريد الإلكتروني', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)), SizedBox(height: 4), Text('itridev.soft@gmail.com', style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.w600))])), const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue)]))),
              const SizedBox(height: 16),
              InkWell(onTap: _launchWhatsApp, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: LinearGradient(colors: [isDark ? Colors.green[900]!.withOpacity(0.4) : Colors.green[50]!, isDark ? Colors.green[800]!.withOpacity(0.3) : Colors.green[100]!]), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.withOpacity(0.4), width: 1.5)), child: Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.green[700], borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.chat, size: 24, color: Colors.white)), const SizedBox(width: 16), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('واتساب', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)), SizedBox(height: 4), Text('0542951750', style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold))])), const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.green)]))),
              const SizedBox(height: 20),
              Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: isDark ? Colors.orange[900]?.withOpacity(0.2) : Colors.orange[50], borderRadius: BorderRadius.circular(12)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.schedule, color: Colors.orange[700], size: 22), const SizedBox(width: 12), Expanded(child: Text('نستجيب لاستفساراتكم في أقرب وقت ممكن', style: TextStyle(fontSize: 13, color: isDark ? Colors.orange[100] : Colors.orange[900], height: 1.4)))])),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)), child: const Text('إغلاق', style: TextStyle(fontSize: 15)))],
      ),
    );
  }

  void _showLogoutDialog() => 
  showDialog(context: context, builder: (context) =>
   AlertDialog(title: const Text('تسجيل الخروج'), 
   content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'), 
   actions: [TextButton(onPressed: () => Navigator.pop(context), 
   child: const Text('إلغاء')), 
   ElevatedButton(
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
     style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), child: const Text('تسجيل الخروج'))]));

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الحساب'),
        content: const Text('تحذير: هذا الإجراء لا يمكن التراجع عنه. سيتم حذف جميع بياناتك نهائياً.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final navigator = Navigator.of(context);
              showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
              final hasReservations = await _hasActiveReservations();
              navigator.pop();
              if (hasReservations) {
                if (mounted) _showCannotDeleteDialog();
              } else {
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

  void _showCannotDeleteDialog() => showDialog(context: context, builder: (context) => AlertDialog(title: const Row(children: [Icon(Icons.warning, color: Colors.orange), SizedBox(width: 10), Text('لا يمكن حذف الحساب')]), content: const Text('لديك حجز نشط (معلق أو مؤكد). يجب إلغاء الحجز أولاً قبل حذف الحساب.', textAlign: TextAlign.right), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسناً'))]));

  Future<bool> _hasActiveReservations() async {
    try {
      final pendingReservation = await ApiService.getMyPendingReservation();
      if (pendingReservation.isNotEmpty) return true;
    } catch (e) {
      print('No pending reservation: $e');
    }
    try {
      final validatedReservation = await ApiService.getMyValidatedReservation();
      if (validatedReservation.isNotEmpty) return true;
    } catch (e) {
      print('No validated reservation: $e');
    }
    return false;
  }

  Future<void> _deleteAccount() async {
    try {
      await ApiService.deleteProfile();
      await TokenManager.clearToken(); // ← ADD THIS
      await ApiService.clearToken();         // keep this too
      // await NotificationManager().stopMonitoring(); // ✅ now awaited
      await NotificationManager().cancelAllNotifications();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف الحساب بنجاح'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في حذف الحساب: ${e.toString()}'), backgroundColor: Colors.red));
      }
    }
  }



  // Add this method in the class (around line 800-900, near other dialog methods)

Future<void> _showReservationUpdateOptions() async {
  // First, fetch user's reservations
  showDialog(
    context: context, 
    barrierDismissible: false, 
    builder: (context) => const Center(child: CircularProgressIndicator())
  );

  try {
    final reservationsData = await ApiService.getMyReservations();
    final reservations = reservationsData['reservations'] as List<dynamic>;

    if (!mounted) return;
    Navigator.pop(context); // Close loading dialog

    if (reservations.isEmpty) {
      _showNoReservationsDialog();
      return;
    }

    // Show list of reservations to choose from
    _showReservationSelectionDialog(reservations);
  } catch (e) {
    if (!mounted) return;
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('خطأ في تحميل الحجوزات: ${e.toString().replaceAll('Exception: ', '')}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

void _showNoReservationsDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(width: 10),
          const Text('لا توجد حجوزات'),
        ],
      ),
      content: const Text(
        'ليس لديك أي حجوزات حالياً يمكن تحديثها.',
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

void _showReservationSelectionDialog(List<dynamic> reservations) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.edit_calendar, color: AppColors.primary),
      ),
      const SizedBox(width: 10),
      Expanded(  // Add this to allow text wrapping
        child: const Text(
          'اختر الحجز للتحديث',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          overflow: TextOverflow.ellipsis,  // Optional: adds ... if still too long
          maxLines: 2,  // Optional: allows up to 2 lines before ellipsis
        ),
      ),
    ],
  ),

      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: reservations.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final reservation = reservations[index];
            final date1 = reservation['date1'];
            final date2 = reservation['date2'];
            final status = reservation['status'];
            
            // Status color and icon
            Color statusColor;
            IconData statusIcon;
            String statusText;
            
            switch (status) {
              case 'validated':
                statusColor = Colors.green;
                statusIcon = Icons.check_circle;
                statusText = 'مؤكد';
                break;
              case 'pending_validation':
                statusColor = Colors.orange;
                statusIcon = Icons.pending;
                statusText = 'قيد المراجعة';
                break;
              case 'cancelled':
                statusColor = Colors.red;
                statusIcon = Icons.cancel;
                statusText = 'ملغى';
                break;
              default:
                statusColor = Colors.grey;
                statusIcon = Icons.help_outline;
                statusText = status ?? 'غير محدد';
            }

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: statusColor.withOpacity(0.2),
                child: Icon(statusIcon, color: statusColor, size: 20),
              ),
              title: Text(
                'التاريخ: $date1',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (date2 != null) Text('التاريخ الثاني: $date2'),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                Navigator.pop(context); // Close selection dialog
                
                // Navigate to update page
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateReservationInfoPage(
                      reservation: reservation,
                    ),
                  ),
                );

                // Refresh if update was successful
                if (result == true && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تحديث معلومات الحجز بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
      ],
    ),
  );
}

}  