// lib/screens/home/tabs/profile_tab.dart
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
  bool _isEditing = false;
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _clanInfo;
  Map<String, dynamic>? _countyInfo;
  
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _fatherNameController;
  late TextEditingController _grandfatherNameController;
  late TextEditingController _phoneController;
  late TextEditingController _birthDateController;
  late TextEditingController _birthAddressController;
  late TextEditingController _homeAddressController;
  late TextEditingController _guardianNameController;
  late TextEditingController _guardianPhoneController;
  late TextEditingController _guardianRelationController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadProfile();
  }
  void refreshData() {
    // Add your profile refresh logic here
    // For example:
    _loadProfile();
    setState(() {
      // Trigger rebuild
    });
  }
  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _initializeControllers() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _fatherNameController = TextEditingController();
    _grandfatherNameController = TextEditingController();
    _phoneController = TextEditingController();
    _birthDateController = TextEditingController();
    _birthAddressController = TextEditingController();
    _homeAddressController = TextEditingController();
    _guardianNameController = TextEditingController();
    _guardianPhoneController = TextEditingController();
    _guardianRelationController = TextEditingController();
  }

  void _disposeControllers() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _fatherNameController.dispose();
    _grandfatherNameController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _birthAddressController.dispose();
    _homeAddressController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    _guardianRelationController.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    
    try {
      _userProfile = await ApiService.getProfile();
      _populateControllers();
      
      // Load additional information
      if (_userProfile?['clan_id'] != null) {
        try {
          final clans = await ApiService.getClans();
          final foundClan = clans.cast<Clan?>().firstWhere(
            (clan) => clan?.id == _userProfile?['clan_id'],
            orElse: () => null,
          );
          _clanInfo = foundClan?.toJson();
        } catch (e) {
          // Handle clan loading error
        }
      }
      
      if (_userProfile?['county_id'] != null) {
        try {
          final counties = await ApiService.getCounties();
          final foundCounty = counties.cast<County?>().firstWhere(
            (county) => county?.id == _userProfile?['county_id'],
            orElse: () => null,
          );
          _countyInfo = foundCounty?.toJson();
        } catch (e) {
          // Handle county loading error
        }
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل الملف الشخصي: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _populateControllers() {
    if (_userProfile != null) {
      _firstNameController.text = _userProfile?['first_name'] ?? '';
      _lastNameController.text = _userProfile?['last_name'] ?? '';
      _fatherNameController.text = _userProfile?['father_name'] ?? '';
      _grandfatherNameController.text = _userProfile?['grandfather_name'] ?? '';
      _phoneController.text = _userProfile?['phone_number'] ?? '';
      _birthDateController.text = _userProfile?['birth_date'] ?? '';
      _birthAddressController.text = _userProfile?['birth_address'] ?? '';
      _homeAddressController.text = _userProfile?['home_address'] ?? '';
      _guardianNameController.text = _userProfile?['guardian_name'] ?? '';
      _guardianPhoneController.text = _userProfile?['guardian_phone'] ?? '';
      _guardianRelationController.text = _userProfile?['guardian_relation'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
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
        ],
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
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => setState(() => _isEditing = !_isEditing),
                icon: Icon(_isEditing ? Icons.cancel : Icons.edit),
                label: Text(_isEditing ? 'إلغاء' : 'تعديل'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                ),
              ),
              if (_isEditing) ...[
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save),
                  label: const Text('حفظ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
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
              'البلدية',
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
        child: Form(
          key: _formKey,
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
              
              // First Name
              _buildFormField(
                controller: _firstNameController,
                label: 'الاسم الأول',
                icon: Icons.person,
                validator: (value) => value?.isEmpty == true ? 'الاسم الأول مطلوب' : null,
              ),
              const SizedBox(height: 12),
              
              // Last Name
              _buildFormField(
                controller: _lastNameController,
                label: 'اسم العائلة',
                icon: Icons.person_outline,
                validator: (value) => value?.isEmpty == true ? 'اسم العائلة مطلوب' : null,
              ),
              const SizedBox(height: 12),
              
              // Father Name
              _buildFormField(
                controller: _fatherNameController,
                label: 'اسم الأب',
                icon: Icons.person,
              ),
              const SizedBox(height: 12),
              
              // Grandfather Name
              _buildFormField(
                controller: _grandfatherNameController,
                label: 'اسم الجد',
                icon: Icons.person,
              ),
              const SizedBox(height: 12),
              
              // Phone Number
              _buildFormField(
                controller: _phoneController,
                label: 'رقم الهاتف',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) => value?.isEmpty == true ? 'رقم الهاتف مطلوب' : null,
              ),
              const SizedBox(height: 12),
              
              // Birth Date
              _buildFormField(
                controller: _birthDateController,
                label: 'تاريخ الميلاد',
                icon: Icons.calendar_today,
                readOnly: true,
                onTap: _isEditing ? _selectBirthDate : null,
              ),
              const SizedBox(height: 12),
              
              // Birth Address
              _buildFormField(
                controller: _birthAddressController,
                label: 'مكان الميلاد',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 12),
              
              // Home Address
              _buildFormField(
                controller: _homeAddressController,
                label: 'عنوان السكن',
                icon: Icons.home,
                maxLines: 2,
              ),
            ],
          ),
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
            
            // Guardian Name
            _buildFormField(
              controller: _guardianNameController,
              label: 'اسم ولي الأمر',
              icon: Icons.person,
            ),
            const SizedBox(height: 12),
            
            // Guardian Phone
            _buildFormField(
              controller: _guardianPhoneController,
              label: 'هاتف ولي الأمر',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            
            // Guardian Relation
            _buildFormField(
              controller: _guardianRelationController,
              label: 'صلة القرابة',
              icon: Icons.family_restroom,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLines,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      readOnly: readOnly || !_isEditing,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabled: _isEditing,
        filled: !_isEditing,
        fillColor: !_isEditing ? Colors.grey[100] : null,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
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
                title: const Text('الأمان والخصوصية'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showSecuritySettings,
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

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _birthDateController.text = picked.toLocal().toString().split(' ')[0];
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    try {
      final updatedData = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'father_name': _fatherNameController.text,
        'grandfather_name': _grandfatherNameController.text,
        'phone_number': _phoneController.text,
        'birth_date': _birthDateController.text.isNotEmpty ? _birthDateController.text : null,
        'birth_address': _birthAddressController.text.isNotEmpty ? _birthAddressController.text : null,
        'home_address': _homeAddressController.text.isNotEmpty ? _homeAddressController.text : null,
        'guardian_name': _guardianNameController.text.isNotEmpty ? _guardianNameController.text : null,
        'guardian_phone': _guardianPhoneController.text.isNotEmpty ? _guardianPhoneController.text : null,
        'guardian_relation': _guardianRelationController.text.isNotEmpty ? _guardianRelationController.text : null,
      };

      await ApiService.updateProfile(updatedData);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث الملف الشخصي بنجاح')),
      );
      
      setState(() {
        _isEditing = false;
      });
      
      // Reload profile to get updated data
      _loadProfile();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحديث الملف الشخصي: ${e.toString()}')),
      );
    }
  }

  void _showNotificationSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('إعدادات الإشعارات قيد التطوير')),
    );
  }

  void _showSecuritySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('إعدادات الأمان قيد التطوير')),
    );
  }

  void _showHelpSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('صفحة المساعدة قيد التطوير')),
    );
  }

  void _showAboutApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حول التطبيق'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تطبيق حجوزات الأفراح'),
            SizedBox(height: 8),
            Text('الإصدار: 1.0.0'),
            SizedBox(height: 8),
            Text('تم تطويره لتسهيل عملية حجز قاعات الأفراح وإدارة المناسبات.'),
          ],
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
              await _deleteAccount();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف الحساب'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      await ApiService.deleteProfile();
      ApiService.clearToken();
      
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف الحساب بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في حذف الحساب: ${e.toString()}')),
        );
      }
    }
  }
}