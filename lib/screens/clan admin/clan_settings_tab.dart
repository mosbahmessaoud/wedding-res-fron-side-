// lib/screens/clan admin/settings_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wedding_reservation_app/services/connectivity_service.dart';

import '../../services/api_service.dart';
import '../../utils/colors.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  SettingsTabState createState() => SettingsTabState();
}

class SettingsTabState extends State<SettingsTab>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _saveAnimationController;
  late Animation<double> _saveAnimation;

  // Settings data
  Map<String, dynamic> _settings = {};
  int? _clanId;

  // Form controllers and values
  bool _allowCrossClanReservations = true;
  int _maxGroomsPerDate = 3;
  bool _allowTwoDayReservations = true;
  int _validationDeadlineDays = 10;
  int _calendarYearsAhead = 3;
  int _yearsMaxReservGroomFromOutClan = 1;
  int _yearsMaxReservGroomFromOriginClan = 3;
  double _paymentShouldPay = 0.0;
  // Month selection lists
  List<int> _selectedSingleDayMonths = [11, 12, 1, 2, 3, 4];
  List<int> _selectedTwoDayMonths = [5, 6, 7, 8, 9, 10];
  double? _currentPayment; // Add this line


  final List<Map<String, dynamic>> _monthsList = [
    {'value': 1, 'name': 'جانفي'},
    {'value': 2, 'name': 'فيفري'},
    {'value': 3, 'name': 'مارس'},
    {'value': 4, 'name': 'أفريل'},
    {'value': 5, 'name': 'ماي'},
    {'value': 6, 'name': 'جوان'},
    {'value': 7, 'name': 'جويلية'},
    {'value': 8, 'name': 'أوت'},
    {'value': 9, 'name': 'سبتمبر'},
    {'value': 10, 'name': 'أكتوبر'},
    {'value': 11, 'name': 'نوفمبر'},
    {'value': 12, 'name': 'ديسمبر'},

  ];


  // Invite acceptance settings
  List<int> _selectedInviteDays = []; // 1=Monday, 2=Tuesday, ..., 7=Sunday
  Map<int, TimeOfDay?> _inviteTimes = {
    1: null, 2: null, 3: null, 4: null, 5: null, 6: null, 7: null
  }; // Time for each day

  final List<Map<String, dynamic>> _daysList = [
    {'value': 1, 'name': 'الاثنين'},
    {'value': 2, 'name': 'الثلاثاء'},
    {'value': 3, 'name': 'الأربعاء'},
    {'value': 4, 'name': 'الخميس'},
    {'value': 5, 'name': 'الجمعة'},
    {'value': 6, 'name': 'السبت'},
    {'value': 7, 'name': 'الأحد'},
  ];

  // double _payment = 0;

// @override
// void initState() {
//   super.initState();
//   _initAnimations();
//   _checkConnectivityAndLoad();
// }
//   void refreshData() {
//     _initAnimations();
//     _checkConnectivityAndLoad();
//     setState(() {
      
//     });
//   }

bool _hasLoadedOnce = false;

@override
void initState() {
  super.initState();
  _initAnimations();
  // Do NOT load here — wait until tab is activated
}

void activateTab() {
  if (!_hasLoadedOnce) {
    _hasLoadedOnce = true;
    _checkConnectivityAndLoad();
  }
}

void refreshData() {
  _initAnimations();
  _checkConnectivityAndLoad();
  setState(() {});
}

Future<void> _checkConnectivityAndLoad() async {
  setState(() => _isLoading = true);

  final isOnline = ConnectivityService().isOnline ||
      await ConnectivityService().checkRealInternet();

  if (!isOnline) {
    if (mounted) {
      setState(() => _isLoading = false);
      _showOfflineBanner();
    }
    return;
  }

  await _loadInitialData();
}

void _showOfflineBanner() {
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

Future<void> _loadInitialData() async {
  await Future.wait([
    _loadSettings(),
    _loadCurrentPayment(), // Change from _saveSettings() to _loadCurrentPayment()
    // _saveSettings(), 
  ]);
  
  // Refresh the UI to update dropdown options after menus are loaded
  if (mounted) {
    setState(() {});
  }
}

Future<void> _loadCurrentPayment() async {
  try {
    final payment = await ApiService.getRequiredPayment();
    if (mounted) {
      setState(() {
        _currentPayment = payment;
      });
    }
  } catch (e) {
    print('Error loading payment: $e');
  }
}


  void _initAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _saveAnimationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _saveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _saveAnimationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _saveAnimationController.dispose();
    super.dispose();
  }
String _buildTimesString() {
  List<String> times = [];
  
  // FIXED: Build times array in correct order (day 1 to 7)
  for (int dayValue = 1; dayValue <= 7; dayValue++) {
    TimeOfDay? time = _inviteTimes[dayValue];
    if (time != null && _selectedInviteDays.contains(dayValue)) {
      String hour = time.hour.toString().padLeft(2, '0');
      String minute = time.minute.toString().padLeft(2, '0');
      times.add('$hour:$minute');
    } else {
      times.add(''); // Empty string for days without time or not selected
    }
  }
  
  return times.join(',');
}
  Future<void> _loadSettings() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getSettings();
      if (!mounted) return;

      setState(() {
        _settings = response;
        _clanId = response['clan_id'];
        _populateFormFields();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'فشل في تحميل الإعدادات: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _savePayment() async {
  setState(() {
    _isSaving = true;
    _errorMessage = null;
  });

  try {
    await ApiService.updatePayment(_paymentShouldPay);
    
    // Reload the current payment after successful save
    await _loadCurrentPayment();

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    _showSuccessDialog();

  } catch (e) {
    if (!mounted) return;
    setState(() {
      _errorMessage = 'فشل في حفظ المبلغ: $e';
      _isSaving = false;
    });
  }
}
Future<double> _getCurrentPayment() async {
  final payment = await ApiService.getRequiredPayment();
  return payment;
}
Widget _buildPaymentCard(bool isMobile, bool isDark) {
  return Container(
    padding: EdgeInsets.all(isMobile ? 10 : 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
          spreadRadius: 0,
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.payments_outlined, color: Colors.green, size: 20),
            ),
            SizedBox(width: 12),
            Text(
              'المبلغ المطلوب للحجز',
              style: TextStyle(
                fontSize: isMobile ? 18 : 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        _currentPayment == null
            ? Center(child: CircularProgressIndicator())
            : Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentPayment!.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'DA',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => _showEditPaymentDialog(isDark),
                      icon: Icon(Icons.edit),
                      color: AppColors.primary,
                      iconSize: 28,
                    ),
                  ],
                ),
              ),
        // SizedBox(height: 16),
        // SizedBox(
        //   width: double.infinity,
        //   child: ElevatedButton(
        //     onPressed: _isSaving ? null : _savePayment,
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: Colors.green,
        //       foregroundColor: Colors.white,
        //       padding: EdgeInsets.symmetric(vertical: 12),
        //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        //     ),
        //     child: _isSaving
        //         ? Row(
        //             mainAxisSize: MainAxisSize.min,
        //             children: [
        //               SizedBox(
        //                 width: 16,
        //                 height: 16,
        //                 child: CircularProgressIndicator(
        //                   strokeWidth: 2,
        //                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        //                 ),
        //               ),
        //               SizedBox(width: 12),
        //               Text('جارٍ الحفظ...', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        //             ],
        //           )
        //         : Text('حفظ المبلغ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        //   ),
        // ),
      ],
    ),
  );
}

void _showEditPaymentDialog(bool isDark) {
final TextEditingController controller = TextEditingController(
    text: (_currentPayment ?? 0).toStringAsFixed(0) // Use _currentPayment instead
  );  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor:  Colors.white,
      title: Text('تعديل المبلغ', style: TextStyle(color:  AppColors.textPrimary)),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        autofocus: true,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color:  AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: 'المبلغ (DA)',
          labelStyle: TextStyle(color:  AppColors.textSecondary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('إلغاء', style: TextStyle(color:  AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () async {
            
            final value = double.tryParse(controller.text) ?? 0;
            setState((){
              _paymentShouldPay = value.clamp(0, 100000);
              _currentPayment = value.clamp(0, 100000);

            });
            Navigator.pop(context);
            await _savePayment();

          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child:_isSaving ? 
          Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('جارٍ الحفظ...', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  )
           : Text('حفظ', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}


void _populateFormFields() {
  _allowCrossClanReservations = _settings['allow_cross_clan_reservations'] ?? true;
  _maxGroomsPerDate = _settings['max_grooms_per_date'] ?? 3;
  _allowTwoDayReservations = _settings['allow_two_day_reservations'] ?? true;
  _validationDeadlineDays = _settings['validation_deadline_days'] ?? 10;
  _calendarYearsAhead = _settings['calendar_years_ahead'] ?? 3;
  _yearsMaxReservGroomFromOutClan = _settings['years_max_reserv_GroomFromOutClan'] ?? 3;
  _yearsMaxReservGroomFromOriginClan = _settings['years_max_reserv_GrooomFromOriginClan'] ?? 1;
  _paymentShouldPay = double.tryParse(_settings['payment_should_pay']?.toString() ?? '0') ?? 0.0; // Add this line


  // Parse month strings to lists
  if (_settings['allowed_months_single_day'] != null) {
    _selectedSingleDayMonths = _settings['allowed_months_single_day']
        .toString()
        .split(',')
        .map((s) => int.tryParse(s.trim()) ?? 0)
        .where((i) => i > 0 && i <= 12)
        .toList();
  }

  if (_settings['allowed_months_two_day'] != null) {
    _selectedTwoDayMonths = _settings['allowed_months_two_day']
        .toString()
        .split(',')
        .map((s) => int.tryParse(s.trim()) ?? 0)
        .where((i) => i > 0 && i <= 12)
        .toList();
  }

  // Parse invite acceptance settings - FIXED
  if (_settings['days_to_accept_invites'] != null && _settings['days_to_accept_invites'].toString().isNotEmpty) {
    _selectedInviteDays = _settings['days_to_accept_invites']
        .toString()
        .split(',')
        .map((s) => int.tryParse(s.trim()) ?? 0)
        .where((i) => i > 0 && i <= 7)
        .toList();
  }

  // Reset times first
  _inviteTimes = {1: null, 2: null, 3: null, 4: null, 5: null, 6: null, 7: null};
  
  if (_settings['accept_invites_times'] != null && _settings['accept_invites_times'].toString().isNotEmpty) {
    List<String> times = _settings['accept_invites_times']
        .toString()
        .split(',');
    
    // FIXED: Match day values correctly with array indices
    for (int dayValue = 1; dayValue <= 7; dayValue++) {
      int arrayIndex = dayValue - 1; // Convert day value to array index
      
      if (arrayIndex < times.length) {
        String timeStr = times[arrayIndex].trim();
        if (timeStr.isNotEmpty && timeStr != '') {
          List<String> timeParts = timeStr.split(':');
          if (timeParts.length == 2) {
            int? hour = int.tryParse(timeParts[0]);
            int? minute = int.tryParse(timeParts[1]);
            if (hour != null && minute != null && hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
              _inviteTimes[dayValue] = TimeOfDay(hour: hour, minute: minute);
            }
          }
        }
      }
    }
  }
}
Future<void> _saveSettings() async {
  if (_clanId == null) {
    setState(() => _errorMessage = 'معرف العشيرة غير متاح');
    return;
  }

  setState(() {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
  });

  try {
    final settingsData = {
      'allow_cross_clan_reservations': _allowCrossClanReservations,
      'max_grooms_per_date': _maxGroomsPerDate,
      'years_max_reserv_GroomFromOutClan': _yearsMaxReservGroomFromOutClan,
      'years_max_reserv_GrooomFromOriginClan': _yearsMaxReservGroomFromOriginClan,
      'allow_two_day_reservations': _allowTwoDayReservations,
      'validation_deadline_days': _validationDeadlineDays,
      'allowed_months_single_day': _selectedSingleDayMonths.join(','),
      'allowed_months_two_day': _selectedTwoDayMonths.join(','),
      'calendar_years_ahead': _calendarYearsAhead,
      'days_to_accept_invites': _selectedInviteDays.join(','),
      'accept_invites_times': _buildTimesString(),
    };

    await ApiService.updateSettings(_clanId!, settingsData);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    // Show success popup dialog
    _showSuccessDialog();

  } catch (e) {
    if (!mounted) return;
    setState(() {
      _errorMessage = 'فشل في حفظ الإعدادات: $e';
      _isSaving = false;
    });
  }
}
void _showSuccessDialog() {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              color: Colors.green.shade600,
              size: 48,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'تم الحفظ بنجاح',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.border : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'تم حفظ جميع الإعدادات بنجاح',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'حسناً',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 768;
    final isMobile = screenSize.width <= 480;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(  
        title: Text('إعدادات العشيرة'),
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
            ),        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/clan_admin_home');
            },
          ),
      ),

      backgroundColor: Color(0xFFF8FAFC),
      body: _isLoading
          ? _buildLoadingState()
          : RefreshIndicator(
              onRefresh: _loadSettings,
              color: AppColors.primary,
              child: CustomScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: EdgeInsets.all(isMobile ? 16 : 24),
                        child: Column(
                          children: [
                            if (_errorMessage != null) _buildErrorCard(),
                            if (_successMessage != null) _buildSuccessCard(),
                            _buildSettingsForm(isMobile, isTablet),
                            SizedBox(height: 32),
                            _buildSaveButton(isMobile),
                            SizedBox(height: 90), 

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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'جارٍ تحميل الإعدادات...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessCard() {
    return AnimatedBuilder(
      animation: _saveAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_saveAnimation.value * 0.05),
          child: Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green.shade600),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _successMessage!,
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsForm(bool isMobile, bool isTablet) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        _buildPaymentCard(isMobile, isDark), // Add this line
        SizedBox(height: 20),
        _buildGeneralSettingsCard(isMobile, isTablet),
        SizedBox(height: 20),
        _buildInviteAcceptanceCard(isMobile, isTablet), // Add this line
        SizedBox(height: 20),
        _buildReservationRulesCard(isMobile, isTablet),
        SizedBox(height: 20),
        _buildMonthSelectionCard(isMobile, isTablet),
      ],
    );
  }
  Widget _buildInviteAcceptanceCard(bool isMobile, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.schedule, color: Colors.blue, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                'أوقات قبول الدعوات',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          
          Text(
            'اختر الأيام والأوقات التي تقبل فيها الدعوات',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 16),
          
          ..._daysList.map((day) => _buildDayTimeTile(day, isMobile)).toList(),
        ],
      ),
    );
  }

  Widget _buildDayTimeTile(Map<String, dynamic> day, bool isMobile) {
    final dayValue = day['value'] as int;
    final isSelected = _selectedInviteDays.contains(dayValue);
    final time = _inviteTimes[dayValue];
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isSelected,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedInviteDays.add(dayValue);
                } else {
                  _selectedInviteDays.remove(dayValue);
                  _inviteTimes[dayValue] = null;
                }
              });
            },
            activeColor: AppColors.primary,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              day['name'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
          if (isSelected) ...[
            GestureDetector(
              onTap: () => _selectTime(dayValue),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: time != null ? AppColors.primary : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  time != null 
                      ? time.format(context)
                      : 'اختر الوقت',
                  style: TextStyle(
                    color: time != null ? Colors.white : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _selectTime(int dayValue) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _inviteTimes[dayValue] ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _inviteTimes[dayValue] = picked;
      });
    }
  }
  Widget _buildGeneralSettingsCard(bool isMobile, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.settings, color: AppColors.primary, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                'الإعدادات العامة',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          
          // Allow cross-clan reservations
          _buildSwitchTile(
            title: 'السماح بالحجوزات بين العشائر',
            subtitle: 'يمكن للعشائر الأخرى الحجز في قاعاتكم',
            value: _allowCrossClanReservations,
            onChanged: (value) => setState(() => _allowCrossClanReservations = value),
            icon: Icons.group_work_outlined,
          ),
          
          Divider(height: 32),
          
          // Allow two-day reservations
          _buildSwitchTile(
            title: 'السماح بالحجوزات لمدة يومين',
            subtitle: 'إمكانية حجز القاعات لفترة يومين متتاليين',
            value: _allowTwoDayReservations,
            onChanged: (value) => setState(() => _allowTwoDayReservations = value),
            icon: Icons.calendar_view_day_outlined,
          ),
        ],
      ),
    );
  }
Widget _buildReservationRulesCard(bool isMobile, bool isTablet) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  return Container(
    padding: EdgeInsets.all(isMobile ? 16 : 20),
    decoration: BoxDecoration(
      color:  Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
          spreadRadius: 0,
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.rule_outlined, color: Colors.orange, size: 20),
            ),
            SizedBox(width: 12),
            Text(
              'قواعد الحجز',
              style: TextStyle(
                fontSize: isMobile ? 18 : 20,
                fontWeight: FontWeight.w700,
                color:  AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        
        _buildNumberInputTileWithEdit(
          title: 'أقصى عدد عرسان في اليوم الواحد',
          subtitle: 'العدد الأقصى المسموح للحجز في نفس التاريخ',
          value: _maxGroomsPerDate,
          onChanged: (value) => setState(() => _maxGroomsPerDate = value),
          min: 1,
          max: 10,
          icon: Icons.group_outlined,
          isDark: isDark,
        ),

        SizedBox(height: 20),
        
        _buildNumberInputTileWithEdit(
          title: 'عدد السنوات المسموحة للحجز من خارج العشيرة',
          subtitle: 'عدد السنوات المستقبلية المتاحة للحجز للاعراس من عشائر أخرى',
          value: _yearsMaxReservGroomFromOutClan,
          onChanged: (value) => setState(() => _yearsMaxReservGroomFromOutClan = value),
          min: 1,
          max: 8,
          icon: Icons.event_available_outlined,
          isDark: isDark,
        ),
        
        SizedBox(height: 20),
        
        _buildNumberInputTileWithEdit(
          title: 'عدد السنوات المسموحة للحجز من داخل العشيرة',
          subtitle: 'عدد السنوات المستقبلية المتاحة للحجز للاعراس من داخل العشيرة ',
          value: _yearsMaxReservGroomFromOriginClan,
          onChanged: (value) => setState(() => _yearsMaxReservGroomFromOriginClan = value),
          min: 1,
          max: 8,
          icon: Icons.home_outlined,
          isDark: isDark,
        ),
        
        SizedBox(height: 20),
        
        _buildNumberInputTileWithEdit(
          title: 'مهلة التأكيد (بالأيام)',
          subtitle: 'عدد الأيام المسموحة للتأكيد على الحجز',
          value: _validationDeadlineDays,
          onChanged: (value) => setState(() => _validationDeadlineDays = value),
          min: 1,
          max: 30,
          icon: Icons.schedule_outlined,
          isDark: isDark,
        ),
      ],
    ),
  );
}
  Widget _buildMonthSelectionCard(bool isMobile, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.date_range, color: Colors.purple, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                'الشهور المسموحة للحجز',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          
          // Single day months
          Text(
            'شهور الحجز ليوم واحد',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          _buildMonthSelector(_selectedSingleDayMonths, true, isMobile),
          
          SizedBox(height: 24),
          
          // Two day months
          if (_allowTwoDayReservations) ...[
            Text(
              'شهور الحجز ليومين',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12),
            _buildMonthSelector(_selectedTwoDayMonths, false, isMobile),
          ],
        ],
      ),
    );
  }

  Widget _buildMonthSelector(List<int> selectedMonths, bool isSingleDay, bool isMobile) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _monthsList.map((month) {
        final isSelected = selectedMonths.contains(month['value']);
        final isSelectedInOther = isSingleDay 
            ? _selectedTwoDayMonths.contains(month['value'])
            : _selectedSingleDayMonths.contains(month['value']);
        
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                // Remove from current selection
                selectedMonths.remove(month['value']);
              } else {
                // Add to current selection and remove from other if exists
                selectedMonths.add(month['value']);
                if (isSelectedInOther) {
                  if (isSingleDay) {
                    _selectedTwoDayMonths.remove(month['value']);
                  } else {
                    _selectedSingleDayMonths.remove(month['value']);
                  }
                }
              }
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 8 : 10,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey.shade300,
              ),
            ),
            child: Text(
              month['name'],
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: value ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: value ? AppColors.primary : AppColors.textSecondary,
            size: 20,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildNumberInputTile({
    required String title,
    required String subtitle,
    required int value,
    required Function(int) onChanged,
    required int min,
    required int max,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: value > min ? () => onChanged(value - 1) : null,
              icon: Icon(Icons.remove_circle_outline),
              color: value > min ? AppColors.primary : AppColors.textSecondary,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            IconButton(
              onPressed: value < max ? () => onChanged(value + 1) : null,
              icon: Icon(Icons.add_circle_outline),
              color: value < max ? AppColors.primary : AppColors.textSecondary,
            ),
          ],
        ),
      ],
    );
  }

Widget _buildNumberInputTileWithEdit({
  required String title,
  required String subtitle,
  required int value,
  required Function(int) onChanged,
  required int min,
  required int max,
  required IconData icon,
  required bool isDark,
}) {
  return Row(
    children: [
      Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _showEditNumberDialog(
              title: title,
              currentValue: value,
              min: min,
              max: max,
              isDark: isDark,
              onSave: onChanged,
            ),
            icon: Icon(Icons.edit),
            color: AppColors.primary,
            iconSize: 24,
          ),
        ],
      ),
    ],
  );
}
void _showEditNumberDialog({
  required String title,
  required int currentValue,
  required int min,
  required int max,
  required bool isDark,
  required Function(int) onSave,
}) {
  final TextEditingController controller = TextEditingController(text: currentValue.toString());
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: isDark ? Color(0xFF1E1E1E) : Colors.white,
      title: Text(title, style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary)),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        autofocus: true,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: 'أدخل القيمة ($min - $max)',
          labelStyle: TextStyle(color: isDark ? Colors.white70 : AppColors.textSecondary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('إلغاء', style: TextStyle(color: isDark ? Colors.white70 : AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () {
            final value = int.tryParse(controller.text) ?? currentValue;
            final clampedValue = value.clamp(min, max);
            onSave(clampedValue);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text('حفظ', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
  Widget _buildSaveButton(bool isMobile) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isSaving
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'جارٍ الحفظ...',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                'حفظ الإعدادات',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
} 


 