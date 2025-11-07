// lib/screens/religious_event_screen.dart
import 'package:flutter/material.dart';
import 'package:wedding_reservation_app/widgets/custom_dropdown_with_sufix.dart';
import '../../utils/colors.dart';
import '../../services/api_service.dart';
import '../../models/county.dart';
import '../../models/clan.dart';
import '../../widgets/custom_dropdown.dart';

class ReligiousEventScreen extends StatefulWidget {
  const ReligiousEventScreen({super.key});

  @override
  _ReligiousEventScreenState createState() => _ReligiousEventScreenState();
}

class _ReligiousEventScreenState extends State<ReligiousEventScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Location data
  List<County> _counties = [];
  List<Clan> _clans = [];
  List<Clan> _filteredClans = [];
  County? _selectedCounty;
  Clan? _selectedClan;

  // Settings data
  Map<String, dynamic>? _clanSettings;
  bool _isLoadingSettings = false;
  bool _isLoadingCounties = false;
  bool _isLoadingClans = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
    
    // Load initial data
    _loadCounties();
    _loadClans();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Load counties
  Future<void> _loadCounties() async {
    setState(() {
      _isLoadingCounties = true;
    });

    try {
      final counties = await ApiService.getCounties();
      if (mounted) {
        setState(() {
          _counties = counties;
          _isLoadingCounties = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCounties = false;
        });
        _showErrorDialog('فشل في تحميل القصور: $e');
      }
    }
  }

  // Load all clans
  Future<void> _loadClans() async {
    if (_clans.isNotEmpty) return;

    setState(() {
      _isLoadingClans = true;
    });

    try {
      final clans = await ApiService.getAllClans();
      if (mounted) {
        setState(() {
          _clans = clans;
          _isLoadingClans = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingClans = false;
        });
        _showErrorDialog('فشل في تحميل العشائر: $e');
      }
    }
  }

  // Handle county selection
  void _onCountyChanged(County? county) {
    setState(() {
      _selectedCounty = county;
      _selectedClan = null;
      _clanSettings = null;

      if (county != null) {
        _filteredClans = _clans.where((clan) => clan.countyId == county.id).toList();
      } else {
        _filteredClans = [];
      }
    });
  }

  // Handle clan selection and load settings
  Future<void> _onClanChanged(Clan? clan) async {
    setState(() {
      _selectedClan = clan;
      _clanSettings = null;
    });

    if (clan != null) {
      await _loadClanSettings(clan.id);
    }
  }

  // Load clan settings
  Future<void> _loadClanSettings(int clanId) async {
    setState(() {
      _isLoadingSettings = true;
    });

    try {
      final settings = await ApiService.getSettingsByClanId(clanId.toString());
      if (mounted) {
        setState(() {
          _clanSettings = settings;
          _isLoadingSettings = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSettings = false;
        });
        _showErrorDialog('فشل في تحميل إعدادات العشيرة: $e');
      }
    }
  }

 // Get clan acceptance time from settings
Map<String, String> _getClanAcceptanceTime() {
  if (_clanSettings == null) {
    return {'day': 'يوم غير محدد', 'time': 'وقت غير محدد'};
  }

  // Parse acceptance days
  dynamic dayValue = _clanSettings!['days_to_accept_invites'];
  List<String> arabicDays = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];

  String day = 'يوم غير محدد';

  if (dayValue != null && dayValue.toString().isNotEmpty) {
    String dayString = dayValue.toString().trim();
    
    List<String> dayIndices = dayString.split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    
    List<String> validDays = [];
    
    for (String indexStr in dayIndices) {
      int? dayIndex = int.tryParse(indexStr);
      if (dayIndex != null && dayIndex >= 0 && dayIndex < 7) {
        validDays.add(arabicDays[dayIndex]);
      }
    }
    
    if (validDays.isNotEmpty) {
      day = validDays.join(' و ');
    }
  }

  // Parse acceptance times (can be multiple times)
  dynamic timeValue = _clanSettings!['accept_invites_times'];
  String time = 'وقت غير محدد';

  if (timeValue != null && timeValue.toString().isNotEmpty) {
    String timeString = timeValue.toString().trim();
    
    // Split by comma and clean up empty values
    List<String> timeSlots = timeString.split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    
    List<String> validTimes = [];
    
    for (String timeSlot in timeSlots) {
      // Basic validation for time format (HH:MM)
      RegExp timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
      if (timeRegex.hasMatch(timeSlot)) {
        validTimes.add(timeSlot);
      }
    }
    
    if (validTimes.isNotEmpty) {
      // Join multiple times with " و " (Arabic "and")
      time = validTimes.join(' و ');
    }
  }

  return {'day': day, 'time': time};
}

// Show error dialog
void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('خطأ'),
      content: Text(
        "يرجى التأكد من اتصالك بالإنترنت وحاول مرة أخرى.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('حسناً'),
        ),
      ],
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    final titleFontSize = screenWidth * 0.055;
    final messageFontSize = screenWidth * 0.045;
    final infoFontSize = screenWidth * 0.035;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.teal.shade700,
              Colors.teal.shade600,
              Colors.teal.shade500,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        'إحياء حفل الله أكبر',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: titleFontSize.clamp(18.0, 24.0),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 48),
                  ],
                ),
              ),
              
              // Main Content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: screenHeight * 0.02,
                      ),
                      child: Column(
                        children: [
                          // Location Selection Card
                          _buildLocationSelectionCard(
                            screenWidth,
                            screenHeight,
                            messageFontSize,
                            infoFontSize,
                          ),
                          
                          // Acceptance Time Card (only show when clan is selected)
                          if (_selectedClan != null && _clanSettings != null)
                            _buildAcceptanceTimeCard(
                              screenWidth,
                              screenHeight,
                              titleFontSize,
                              messageFontSize,
                              infoFontSize,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build location selection card
  Widget _buildLocationSelectionCard(
    double screenWidth,
    double screenHeight,
    double messageFontSize,
    double infoFontSize,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.03),
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'اختر القصر والعشيرة التي ستقيم فيها حفل الله اكبر ',
            style: TextStyle(
              color: Colors.teal.shade700,
              fontSize: messageFontSize.clamp(16.0, 20.0),
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: screenHeight * 0.02),
           Theme(
  data: Theme.of(context).copyWith(
    hintColor: Colors.grey.shade600,
    canvasColor: Colors.white,
  ),
  child: CustomDropdownSufix<County>(
    label: '',
    value: _selectedCounty,
    hint: 'اختر القصر',
    items: _counties.map((county) => DropdownMenuItem<County>(
      value: county,
      child: Text(
        county.name,
        style: TextStyle(color: Colors.black87),
      ),
    )).toList(),
    onChanged: _onCountyChanged,
    prefixIcon: Icons.location_city,
    isLoading: _isLoadingCounties, // Use the new isLoading parameter
  ),
),

SizedBox(height: screenHeight * 0.02),

// Clan Dropdown
Theme(
  data: Theme.of(context).copyWith(
    hintColor: Colors.grey.shade600,
    canvasColor: Colors.white,
  ),
  child: CustomDropdownSufix<Clan>(
    label: '',
    value: _selectedClan,
    hint: 'اختر العشيرة',
    items: _filteredClans.map((clan) => DropdownMenuItem<Clan>(
      value: clan,
      child: Text(
        clan.name,
        style: TextStyle(color: Colors.black87),
      ),
    )).toList(),
    onChanged: _onClanChanged,
    prefixIcon: Icons.groups,
    enabled: _filteredClans.isNotEmpty,
    isLoading: _isLoadingClans, // Use the new isLoading parameter
  ),
),
          
          // No clans message
          if (_selectedCounty != null && _filteredClans.isEmpty) ...[
            SizedBox(height: screenHeight * 0.02),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.grey.shade700,
                    size: infoFontSize.clamp(16.0, 20.0),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'لا توجد عشائر مسجلة في هذا القصر حالياً',
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: infoFontSize.clamp(12.0, 14.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Loading indicator
          if (_isLoadingSettings)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                child: CircularProgressIndicator(
                  color: Colors.teal.shade700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Build acceptance time card
  Widget _buildAcceptanceTimeCard(
    double screenWidth,
    double screenHeight,
    double titleFontSize,
    double messageFontSize,
    double infoFontSize,
  ) {
    final acceptanceInfo = _getClanAcceptanceTime();
    
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.access_time,
              size: 40,
              color: Colors.teal.shade700,
            ),
          ),
          
          SizedBox(height: screenHeight * 0.02),
          
          // Title
          Text(
            'أوقات الاستقبال في العشيرة',
            style: TextStyle(
              color: Colors.teal.shade700,
              fontSize: titleFontSize.clamp(16.0, 20.0),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: screenHeight * 0.02),
          
          // Divider
          Container(
            width: screenWidth * 0.15,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.teal.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          SizedBox(height: screenHeight * 0.03),
          
          // Clan name
          Text(
            _selectedClan!.name,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: messageFontSize.clamp(14.0, 18.0),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: screenHeight * 0.02),
          
          // Day info
          _buildInfoRow(
            Icons.calendar_today,
            'اليوم',
            acceptanceInfo['day']!,
            infoFontSize,
          ),
          
          SizedBox(height: screenHeight * 0.015),
          
          // Time info
          _buildInfoRow(
            Icons.access_time,
            'الوقت',
            acceptanceInfo['time']!,
            infoFontSize,
          ),
          
          SizedBox(height: screenHeight * 0.025),
          
          // Note
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.amber.shade700,
                  size: infoFontSize.clamp(16.0, 20.0),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'يرجى التواصل مع عشيرتك في الأوقات المحددة للحجز',
                    style: TextStyle(
                      color: Colors.amber.shade900,
                      fontSize: infoFontSize.clamp(12.0, 14.0),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build info row
  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    double fontSize,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.teal.shade700,
            size: fontSize.clamp(18.0, 22.0),
          ),
          SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: fontSize.clamp(13.0, 15.0),
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: fontSize.clamp(14.0, 16.0),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}