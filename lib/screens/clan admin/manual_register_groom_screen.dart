import 'package:flutter/material.dart';
import 'package:wedding_reservation_app/utils/constants.dart';

import '../../services/api_service.dart';
import '../groom/custom_calendar_picker.dart';

class ManualRegisterGroomScreen extends StatefulWidget {
  const ManualRegisterGroomScreen({Key? key}) : super(key: key);

  @override
  State<ManualRegisterGroomScreen> createState() => _ManualRegisterGroomScreenState();
}
class _ManualRegisterGroomScreenState extends State<ManualRegisterGroomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _grandfatherNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _date1Controller = TextEditingController();
  final _customMadaehCommitteeController = TextEditingController();
  final _customTilawaNameController = TextEditingController();
  
  // New controllers for additional fields
  final _birthDateController = TextEditingController();
  final _birthAddressController = TextEditingController();
  final _homeAddressController = TextEditingController();
  final _guardianHomeAddressController = TextEditingController();
  final _guardianBirthAddressController = TextEditingController();
  final _guardianBirthDateController = TextEditingController();
  
  bool _isSubmitting = false, _createReservation = false, _date2Bool = false;
  bool _allowOthers = false, _showCustomMadaehInput = false, _showCustomTilawaInput = false;
  bool _isLoadingDropdowns = false, _isLoadingClans = false, _isLoadingHalls = false;
  int? _clanId, _countyId;
  
  Map<String, dynamic>? _selectedClan, _selectedCounty, _selectedHall;
  Map<String, dynamic>? _selectedHaiaCommittee, _selectedMadaehCommittee;
  String? _selectedTilawaType;
  String? _selectedGuardianRelation = AppConstants.guardianRelations.first;
  
  List<Map<String, dynamic>> _clans = [], _halls = [];
  List<Map<String, dynamic>> _haiaCommittees = [], _madaehCommittees = [];
@override
void initState() {
  super.initState();
  _selectedTilawaType = 'تلاوة جماعية'; // Initialize with default value
  
  // Set default values
  final today = DateTime.now().toLocal().toString().split(' ')[0];
  _birthDateController.text = today;
  _guardianBirthDateController.text = today;
  _birthAddressController.text = 'غرداية';
  _homeAddressController.text = 'غرداية';
  _guardianHomeAddressController.text = 'غرداية';
  _guardianBirthAddressController.text = 'غرداية';
  
  _loadUserInfo();
}
Future<void> _loadUserInfo() async {
  try {
    final userInfo = await ApiService.getCurrentUserInfo();
    if (mounted) {
      setState(() {
        _clanId = userInfo['clan_id'];
        _countyId = userInfo['county_id'];
      });
      
      print('✅ User info loaded - County ID: $_countyId, Clan ID: $_clanId');
      
      // ✅ ADD THIS CHECK
      if (_clanId == null || _countyId == null) {
        print('⚠️ Warning: clan_id or county_id is null!');
        _showMessageDialog(
          title: 'تحذير',
          message: 'معلومات العشيرة أو المحافظة غير متوفرة. يرجى تحديث ملفك الشخصي',
          icon: Icons.warning,
          isError: false,
        );
        return; // Don't load dropdown data if these are null
      }
      
      // Load dropdown data after user info is loaded
      await _loadDropdownData();
    }
  } catch (e) {
    print('❌ Error loading user info: $e');
    if (mounted) {
      _showMessageDialog(
        title: 'خطأ',
        message: 'فشل في تحميل معلومات المستخدم',
        icon: Icons.error,
        isError: true,
      );
    }
  }
}
Future<void> _loadDropdownData() async {
  if (_countyId == null) {
    print('⚠️ County ID is null, cannot load clans');
    return;
  }

  setState(() => _isLoadingDropdowns = true);
  
  try {
    print('🔵 Loading dropdown data for county: $_countyId');
    
    // Load county data first
    try {
      final countyData = await ApiService.getCounty(_countyId!);
      if (mounted) {
        setState(() => _selectedCounty = countyData);
        print('✅ County loaded: ${countyData['name']}');
      }
    } catch (e) {
      print('⚠️ Error loading county: $e');
    }

    // Load clans for the county
    List<Map<String, dynamic>> clans = [];
    try {
      print('🔵 Fetching clans for county: $_countyId');
      final clansData = await ApiService.getClansByCounty(_countyId!).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏱️ Clans loading timed out');
          return [];
        },
      );
      clans = List<Map<String, dynamic>>.from(clansData);
      print('✅ Loaded ${clans.length} clans');
    } catch (e) {
      print('❌ Error loading clans: $e');
      clans = [];
    }

    // Load committees
    List<Map<String, dynamic>> haiaCommittees = [];
    try {
      print('🔵 Loading Haia committees');
      final haiaData = await ApiService.getGroomHaia().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('⏱️ Haia loading timed out');
          return [];
        },
      );
      haiaCommittees = List<Map<String, dynamic>>.from(haiaData);
      print('✅ Loaded ${haiaCommittees.length} Haia committees');
    } catch (e) {
      print('❌ Error loading Haia: $e');
      haiaCommittees = [];
    }

    List<Map<String, dynamic>> madaehCommittees = [];
    try {
      print('🔵 Loading Madaeh committees');
      final madaehData = await ApiService.getGroomMadaihCommittee().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('⏱️ Madaeh loading timed out');
          return [];
        },
      );
      madaehCommittees = List<Map<String, dynamic>>.from(madaehData);
      print('✅ Loaded ${madaehCommittees.length} Madaeh committees');
    } catch (e) {
      print('❌ Error loading Madaeh: $e');
      madaehCommittees = [];
    }
    
    if (mounted) {
      setState(() {
        _clans = clans;
        _haiaCommittees = haiaCommittees;
        _madaehCommittees = madaehCommittees;
        
        // Set default values to first item if available
        if (clans.isNotEmpty && _selectedClan == null) {
          _selectedClan = clans[0];
          _onClanSelected(_selectedClan); // Load halls for default clan
        }
        if (haiaCommittees.isNotEmpty && _selectedHaiaCommittee == null) {
          _selectedHaiaCommittee = haiaCommittees[0];
        }
        if (madaehCommittees.isNotEmpty && _selectedMadaehCommittee == null) {
          _selectedMadaehCommittee = madaehCommittees[0];
          _showCustomMadaehInput = madaehCommittees[0]['name'] == 'لجنة خاصة';
        }
        
        _isLoadingDropdowns = false;
      });
      print('✅ All dropdown data loaded successfully with default values');
      
      // Show warning if no clans found
      if (clans.isEmpty) {
        _showMessageDialog(
          title: 'تحذير',
          message: 'لا توجد عشائر متاحة في قصرك',
          icon: Icons.warning,
          isError: false,
        );
      }
    }
  } catch (e) {
    print('❌ Critical error in _loadDropdownData: $e');
    if (mounted) {
      setState(() => _isLoadingDropdowns = false);
      _showMessageDialog(
        title: 'خطأ',
        message: 'حدث خطأ في تحميل البيانات: ${e.toString()}',
        icon: Icons.error,
        isError: true,
      );
    }
  }
}
Future<void> _onClanSelected(Map<String, dynamic>? clan) async {
  setState(() {
    _selectedClan = clan;
    _selectedHall = null;
    _halls = [];
    _isLoadingHalls = true;
  });

  if (clan != null) {
    try {
      final halls = await ApiService.getHallsByClan(clan['id']);
      if (mounted) {
        final hallsList = List<Map<String, dynamic>>.from(halls);
        setState(() {
          _halls = hallsList;
          // Set default hall to first item if available
          if (hallsList.isNotEmpty && _selectedHall == null) {
            _selectedHall = hallsList[0];
          }
          _isLoadingHalls = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingHalls = false);
    }
  }
}
  Future<void> _selectDate(BuildContext context) async {
    if (_selectedClan == null || _selectedHall == null) {
      _showMessageDialog(title: 'معلومات ناقصة', message: 'يرجى اختيار العشيرة والقاعة أولاً', icon: Icons.warning, isError: false);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final now = DateTime.now();
      if (Navigator.canPop(context)) Navigator.of(context).pop();

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => BeautifulCustomCalendarPicker(
            title: 'تاريخ الحجز',
            clanId: _selectedClan!['id'],
            hallId: _selectedHall?['id'],
            maxCapacityPerDate: 3,
            initialDate: _date1Controller.text.isNotEmpty 
                ? DateTime.tryParse(_date1Controller.text) ?? now.add(const Duration(days: 30))
                : now.add(const Duration(days: 30)),
            firstDate: now,
            lastDate: now.add(const Duration(days: 365)),
            allowTwoConsecutiveDays: false,
            onDateSelected: (selectedDate, availability) {
              Navigator.of(context).pop();
              setState(() => _date1Controller.text = selectedDate.toLocal().toString().split(' ')[0]);
            },
            onCancel: () => Navigator.of(context).pop(),
            isOriginClan: _clanId == _selectedClan!['id'],
            yearsMaxReservGroomFromOriginClan: 3,
            yearsMaxReservGroomFromOutClan: 1,
          ),
        );
      }
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.of(context).pop();
      if (mounted) _showFallbackDatePicker(context);
    }
  }

  Future<void> _showFallbackDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    
    if (picked != null && mounted) {
      setState(() => _date1Controller.text = picked.toLocal().toString().split(' ')[0]);
      _showMessageDialog(title: 'تحذير', message: 'تم اختيار التاريخ بدون فحص التوفر', icon: Icons.warning, isError: false);
    }
  }

  void _showMessageDialog({required String title, required String message, required IconData icon, bool isError = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: isError ? Colors.red : Colors.green),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  Future<void> _register() async {
  if (!_formKey.currentState!.validate()) return;

  // ✅ ADD THIS CHECK - Ensure clan and county are set
  if (_clanId == null || _countyId == null) {
    _showMessageDialog(
      title: 'خطأ', 
      message: 'فشل في تحميل معلومات العشيرة والمحافظة. يرجى المحاولة مرة أخرى', 
      icon: Icons.error, 
      isError: true
    );
    return;
  }

  if (_createReservation) {
    if (_date1Controller.text.isEmpty || _selectedClan == null || _selectedHall == null || 
        _selectedHaiaCommittee == null || _selectedMadaehCommittee == null || _selectedTilawaType == null) {
      _showMessageDialog(title: 'خطأ', message: 'يرجى إكمال جميع الحقول المطلوبة', icon: Icons.error, isError: true);
      return;
    }
  }

  setState(() => _isSubmitting = true);

  try {
    final groomResponse = await ApiService.registerGroomByAdmin(
      phoneNumber: _phoneController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      fatherName: _fatherNameController.text.trim(),
      grandfatherName: _grandfatherNameController.text.trim(),
      clanId: _clanId!, // Safe to use ! now because we checked above
      countyId: _countyId!,
      birthDate: _birthDateController.text.trim().isEmpty ? null : _birthDateController.text.trim(),
      birthAddress: _birthAddressController.text.trim().isEmpty ? null : _birthAddressController.text.trim(),
      homeAddress: _homeAddressController.text.trim().isEmpty ? null : _homeAddressController.text.trim(),
      guardianPhone: _guardianPhoneController.text.trim().isEmpty ? null : _guardianPhoneController.text.trim(),
      guardianName: _guardianNameController.text.trim().isEmpty ? null : _guardianNameController.text.trim(),
      guardianHomeAddress: _guardianHomeAddressController.text.trim().isEmpty ? null : _guardianHomeAddressController.text.trim(),
      guardianBirthAddress: _guardianBirthAddressController.text.trim().isEmpty ? null : _guardianBirthAddressController.text.trim(),
      guardianBirthDate: _guardianBirthDateController.text.trim().isEmpty ? null : _guardianBirthDateController.text.trim(),
      guardianRelation: _selectedGuardianRelation,
    );

    // ✅ FIX: Changed from groomResponse['user_id'] to groomResponse['user']['id']
    if (_createReservation) {
      await _createReservationForGroom(groomResponse['user']['id']);
    } else {
      if (mounted) {
        _showMessageDialog(title: 'نجاح', message: 'تم تسجيل العريس بنجاح', icon: Icons.check_circle, isError: false);
        _clearForm();
      }
    }
  } catch (e) {
    if (mounted) _showMessageDialog(title: 'خطأ', message: 'فشل التسجيل: ${e.toString()}', icon: Icons.error, isError: true);
  } finally {
    if (mounted) setState(() => _isSubmitting = false);
  }
}
  Future<void> _createReservationForGroom(int groomUserId) async {
    try {
      final reservationData = {
        'date1': _date1Controller.text,
        'date2_bool': _date2Bool,
        'allow_others': _allowOthers,
        'clan_id': _selectedClan!['id'],
        'hall_id': _selectedHall!['id'],
        'haia_committee_id': _selectedHaiaCommittee!['id'],
        'madaeh_committee_id': _selectedMadaehCommittee!['id'],
        'user_id': groomUserId,
      };

      if (_showCustomMadaehInput && _customMadaehCommitteeController.text.trim().isNotEmpty) {
        reservationData['custom_madaeh_committee_name'] = _customMadaehCommitteeController.text.trim();
      }

      if (_selectedTilawaType != null) {
        reservationData['tilawa_type'] = _showCustomTilawaInput && _customTilawaNameController.text.trim().isNotEmpty
            ? _customTilawaNameController.text.trim()
            : _selectedTilawaType;
      }

      final response = await ApiService.createReservationbyAdmin(reservationData,groomUserId);

      if (mounted) {
        _showMessageDialog(title: 'نجاح', message: 'تم التسجيل والحجز بنجاح!\nرقم الحجز: ${response['reservation_id']}', icon: Icons.check_circle, isError: false);
        _clearForm();
      }
    } catch (e) {
      if (mounted) _showMessageDialog(title: 'خطأ', message: 'فشل إنشاء الحجز: ${e.toString()}', icon: Icons.error, isError: true);
    }
  }
void _clearForm() {
  _formKey.currentState!.reset();
  [_phoneController, _firstNameController, _lastNameController, _fatherNameController, 
   _grandfatherNameController, _guardianPhoneController, _guardianNameController,
   _date1Controller, _customMadaehCommitteeController, _customTilawaNameController,
   _birthDateController, _birthAddressController, _homeAddressController,
   _guardianHomeAddressController, _guardianBirthAddressController, _guardianBirthDateController].forEach((c) => c.clear());
  
  setState(() {
    _createReservation = _date2Bool = _allowOthers = false;
    _showCustomMadaehInput = _showCustomTilawaInput = false;
    _selectedClan = _selectedHall = _selectedHaiaCommittee = _selectedMadaehCommittee = null;
    _selectedTilawaType = 'تلاوة جماعية';
    _selectedGuardianRelation = AppConstants.guardianRelations.first;
    _halls = [];
    
    // Reset default values
    final today = DateTime.now().toLocal().toString().split(' ')[0];
    _birthDateController.text = today;
    _guardianBirthDateController.text = today;
    _birthAddressController.text = 'غرداية';
    _homeAddressController.text = 'غرداية';
    _guardianHomeAddressController.text = 'غرداية';
    _guardianBirthAddressController.text = 'غرداية';
  });
}
Future<void> _selectBirthDate(BuildContext context, TextEditingController controller) async {
  final now = DateTime.now();
  final picked = await showDatePicker(
    context: context,
    initialDate: controller.text.isNotEmpty 
        ? DateTime.tryParse(controller.text) ?? now
        : now,
    firstDate: DateTime(1900),
    lastDate: now,
  );
  
  if (picked != null && mounted) {
    setState(() => controller.text = picked.toLocal().toString().split(' ')[0]);
  }
}
  Widget _buildCard({required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        ),
      ),
      child: child,
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, String? Function(String?)? validator, TextInputType? keyboardType}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
      ),
      keyboardType: keyboardType,
      validator: validator ?? (v) => v?.isEmpty == true ? '$label مطلوب' : null,
    );
  }

  Widget _buildDropdown<T>({required String label, required IconData icon, required T? value, required List<Map<String, dynamic>> items, required void Function(T?) onChanged, String? Function(T?)? validator, bool isLoading = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.3)),
        ),
      ),
      items: items.map((item) => DropdownMenuItem<T>(
        value: item as T,
        child: Text(item['name']?.toString() ?? ''),
      )).toList(),
      onChanged: onChanged,
      validator: validator,
      icon: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.keyboard_arrow_down),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل عريس جديد'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.8),
                Theme.of(context).primaryColor,
              ],
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Groom Info Card
            // Groom Info Card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.person, color: Theme.of(context).primaryColor, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'معلومات العريس',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(controller: _phoneController, label: 'رقم الهاتف *', icon: Icons.phone, keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _firstNameController, label: 'الاسم *', icon: Icons.person),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _lastNameController, label: 'اسم العائلة *', icon: Icons.family_restroom),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _fatherNameController, label: 'اسم الأب *', icon: Icons.person_outline),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _grandfatherNameController, label: 'اسم الجد *', icon: Icons.elderly),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => _selectBirthDate(context, _birthDateController),
                    child: AbsorbPointer(
                      child: _buildTextField(
                        controller: _birthDateController, 
                        label: 'تاريخ الميلاد', 
                        icon: Icons.cake,
                        validator: null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _birthAddressController, 
                    label: 'مكان الميلاد', 
                    icon: Icons.location_on,
                    validator: null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _homeAddressController, 
                    label: 'عنوان السكن', 
                    icon: Icons.home,
                    validator: null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _guardianNameController, label: 'اسم الولي *', icon: Icons.supervised_user_circle),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _guardianPhoneController, label: 'رقم هاتف الولي *', icon: Icons.phone_android, keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedGuardianRelation,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'صلة القرابة',
                      prefixIcon: Icon(Icons.family_restroom, color: Theme.of(context).primaryColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.3)),
                      ),
                    ),
                    items: AppConstants.guardianRelations.map((relation) => 
                      DropdownMenuItem<String>(
                        value: relation,
                        child: Text(relation),
                      )
                    ).toList(),
                    onChanged: (v) => setState(() => _selectedGuardianRelation = v),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => _selectBirthDate(context, _guardianBirthDateController),
                    child: AbsorbPointer(
                      child: _buildTextField(
                        controller: _guardianBirthDateController, 
                        label: 'تاريخ ميلاد الولي', 
                        icon: Icons.cake,
                        validator: null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _guardianBirthAddressController, 
                    label: 'مكان ميلاد الولي', 
                    icon: Icons.location_on,
                    validator: null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _guardianHomeAddressController, 
                    label: 'عنوان سكن الولي', 
                    icon: Icons.home,
                    validator: null,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Create Reservation Toggle
            _buildCard(
              child: SwitchListTile(
                title: const Text('إنشاء حجز مع التسجيل', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('تفعيل لإنشاء حجز تلقائياً للعريس'),
                value: _createReservation,
                onChanged: (v) => setState(() => _createReservation = v),
                activeColor: Theme.of(context).primaryColor,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            
            // Reservation Details
            if (_createReservation) ...[
              const SizedBox(height: 16),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.book_outlined, color: Theme.of(context).primaryColor, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'تفاصيل الحجز',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildDropdown<Map<String, dynamic>>(
                      label: 'العشيرة *',
                      icon: Icons.group,
                      value: _selectedClan,
                      items: _clans,
                      onChanged: _onClanSelected,
                      validator: (v) => v == null ? 'مطلوب' : null,
                      isLoading: _isLoadingClans,
                    ),
                    if (_selectedClan != null) ...[
                      const SizedBox(height: 16),
                      _buildDropdown<Map<String, dynamic>>(
                        label: 'القاعة *',
                        icon: Icons.business,
                        value: _selectedHall,
                        items: _halls,
                        onChanged: (v) => setState(() => _selectedHall = v),
                        validator: (v) => v == null ? 'مطلوب' : null,
                        isLoading: _isLoadingHalls,
                      ),
                    ],
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: _buildTextField(controller: _date1Controller, label: 'تاريخ الحجز *', icon: Icons.calendar_today),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown<Map<String, dynamic>>(
                      label: 'الهيئة *',
                      icon: Icons.group,
                      value: _selectedHaiaCommittee,
                      items: _haiaCommittees,
                      onChanged: (v) => setState(() => _selectedHaiaCommittee = v),
                      validator: (v) => v == null ? 'مطلوب' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown<Map<String, dynamic>>(
                      label: 'اللجنة *',
                      icon: Icons.group_outlined,
                      value: _selectedMadaehCommittee,
                      items: _madaehCommittees,
                      onChanged: (v) => setState(() {
                        _selectedMadaehCommittee = v;
                        _showCustomMadaehInput = v?['name'] == 'لجنة خاصة';
                      }),
                      validator: (v) => v == null ? 'مطلوب' : null,
                    ),
                    if (_showCustomMadaehInput) ...[
                      const SizedBox(height: 16),
                      _buildTextField(controller: _customMadaehCommitteeController, label: 'اسم اللجنة الخاصة', icon: Icons.edit, validator: null),
                    ],
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedTilawaType ?? 'تلاوة جماعية', // Set default to first option
                      decoration: InputDecoration(
                        labelText: 'نوع التلاوة *',
                        prefixIcon: Icon(Icons.book_outlined, color: Theme.of(context).primaryColor),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.3)),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'تلاوة جماعية', child: Text('تلاوة جماعية')),
                        DropdownMenuItem(value: 'تلاوة فردية', child: Text('تلاوة فردية')),
                      ],
                      onChanged: (v) => setState(() {
                        _selectedTilawaType = v;
                        _showCustomTilawaInput = v == 'تلاوة فردية';
                      }),
                      validator: (v) => v == null ? 'مطلوب' : null,
                    ),
                    if (_showCustomTilawaInput) ...[
                      const SizedBox(height: 16),
                      _buildTextField(controller: _customTilawaNameController, label: 'اسم القارئ', icon: Icons.person_outline, validator: null),
                    ],
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('حجز يومين متتاليين'),
                      value: _date2Bool,
                      onChanged: (v) => setState(() => _date2Bool = v),
                      activeColor: Theme.of(context).primaryColor,
                      contentPadding: EdgeInsets.zero,
                    ),
                    SwitchListTile(
                      title: const Text('السماح للآخرين بالانضمام'),
                      value: _allowOthers,
                      onChanged: (v) => setState(() => _allowOthers = v),
                      activeColor: Theme.of(context).primaryColor,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Submit Button
            Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_createReservation ? 'تسجيل وإنشاء حجز' : 'تسجيل', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
@override
void dispose() {
  [_phoneController, _firstNameController, _lastNameController, _fatherNameController,
   _grandfatherNameController, _guardianPhoneController, _guardianNameController,
   _date1Controller, _customMadaehCommitteeController, _customTilawaNameController,
   _birthDateController, _birthAddressController, _homeAddressController,
   _guardianHomeAddressController, _guardianBirthAddressController, _guardianBirthDateController].forEach((c) => c.dispose());
  super.dispose();
}
}