// lib/screens/religious_event_screen.dart
import 'package:flutter/material.dart';
import 'package:wedding_reservation_app/widgets/custom_dropdown_with_sufix.dart';
import 'package:wedding_reservation_app/widgets/theme_toggle_button.dart';
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
  late Animation<double> _slideAnimation;

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
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 20.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
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

    // Parse acceptance times
    dynamic timeValue = _clanSettings!['accept_invites_times'];
    String time = 'وقت غير محدد';

    if (timeValue != null && timeValue.toString().isNotEmpty) {
      String timeString = timeValue.toString().trim();
      
      List<String> timeSlots = timeString.split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      
      List<String> validTimes = [];
      
      for (String timeSlot in timeSlots) {
        RegExp timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
        if (timeRegex.hasMatch(timeSlot)) {
          validTimes.add(timeSlot);
        }
      }
      
      if (validTimes.isNotEmpty) {
        time = validTimes.join(' و ');
      }
    }

    return {'day': day, 'time': time};
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'خطأ',
          style: TextStyle(
            color: isDark ? Colors.green.shade300 : Colors.green.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "يرجى التأكد من اتصالك بالإنترنت وحاول مرة أخرى.",
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: isDark ? Colors.green.shade300 : Colors.green.shade700,
            ),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            colors: isDark
                ? [
                    Colors.black.withOpacity(0.9),
                    Colors.green.shade900.withOpacity(0.7),
                    Colors.black.withOpacity(0.9),
                  ]
                : [
                    Colors.white,
                    Colors.green.shade50.withOpacity(0.3),
                    Colors.white,
                  ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main Content
              Column(
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: isDark ? Colors.green.shade300 : Colors.green.shade700,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          style: IconButton.styleFrom(
                            padding: const EdgeInsets.all(12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'إِحْياء حَفْل اللَّه أَكْبَر',
                            style: TextStyle(
                              color: isDark ? Colors.green.shade300 : Colors.green.shade800,
                              fontSize: titleFontSize.clamp(18.0, 24.0),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  
                  // Animated Content
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05,
                            vertical: screenHeight * 0.02,
                          ),
                          child: Column(
                            children: [
                              // Location Selection Card
                              _buildLocationSelectionCard(
                                isDark,
                                screenWidth,
                                screenHeight,
                                messageFontSize,
                                infoFontSize,
                              ),
                              
                              // Acceptance Time Card
                              if (_selectedClan != null && _clanSettings != null)
                                _buildAcceptanceTimeCard(
                                  isDark,
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
              
              // Theme Toggle Button
              const Positioned(
                top: 8,
                left: 16,
                child: ThemeToggleButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build location selection card
  Widget _buildLocationSelectionCard(
    bool isDark,
    double screenWidth,
    double screenHeight,
    double messageFontSize,
    double infoFontSize,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.03),
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.green.shade900.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: isDark 
            ? Border.all(color: Colors.green.shade800.withOpacity(0.3), width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'اختر القصر والعشيرة التي ستقيم فيها حفل اللَّهُ اكبر',
            style: TextStyle(
              color: isDark ? Colors.green.shade300 : Colors.green.shade800,
              fontSize: messageFontSize.clamp(16.0, 20.0),
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: screenHeight * 0.02),
          
          // County Dropdown
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              // border: Border.all(
              //   color: isDark ? Colors.green.shade700.withOpacity(0.5) : Colors.grey.shade300,
              //   width: 1.5,
              // ),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                hintColor: isDark ? Colors.green.shade900 : Colors.grey.shade600,
                canvasColor: isDark ? Colors.grey.shade900 : Colors.white,
              ),
              child: CustomDropdownSufix<County>(
                label: '',
                value: _selectedCounty,
                hint: 'اختر القصر',
                items: _counties.map((county) => DropdownMenuItem<County>(
                  value: county,
                  child: Text(
                    county.name,
                    style: TextStyle(
                      color:  Colors.black87,
                    ),
                  ),
                )).toList(),
                onChanged: _onCountyChanged,
                prefixIcon: Icons.location_city,
                isLoading: _isLoadingCounties,
              ),
            ),
          ),

          SizedBox(height: screenHeight * 0.02),

          // Clan Dropdown
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              // border: Border.all(
              //   color: isDark ? Colors.green.shade700.withOpacity(0.5) : Colors.grey.shade300,
              //   width: 1.5,
              // ),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                hintColor: isDark ? Colors.green.shade900 : Colors.grey.shade600,
                canvasColor: isDark ? Colors.grey.shade900 : Colors.white,

              ),
              child: CustomDropdownSufix<Clan>(
                label: '',
                value: _selectedClan,
                hint: 'اختر العشيرة',
                items: _filteredClans.map((clan) => DropdownMenuItem<Clan>(
                  value: clan,
                  child: Text(
                    clan.name,
                    style: TextStyle(
                      color:  Colors.black87,
                    ),
                  ),
                )).toList(),
                onChanged: _onClanChanged,
                prefixIcon: Icons.groups,
                enabled: _filteredClans.isNotEmpty,
                isLoading: _isLoadingClans,
              ),
            ),
          ),
          
          // No clans message
          if (_selectedCounty != null && _filteredClans.isEmpty) ...[
            SizedBox(height: screenHeight * 0.02),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.grey.shade800.withOpacity(0.5)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: isDark ? Colors.green.shade400 : Colors.grey.shade700,
                    size: infoFontSize.clamp(16.0, 20.0),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'لا توجد عشائر مسجلة في هذا القصر حالياً',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey.shade800,
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
                  color: isDark ? Colors.green.shade400 : Colors.green.shade700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Build acceptance time card
  Widget _buildAcceptanceTimeCard(
    bool isDark,
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
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.green.shade900.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: isDark 
            ? Border.all(color: Colors.green.shade800.withOpacity(0.3), width: 1)
            : null,
      ),
      child: Column(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.green.shade800,
                        Colors.green.shade900,
                      ]
                    : [
                        Colors.green.shade600,
                        Colors.green.shade800,
                      ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.shade300.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.access_time,
              size: 40,
              color: Colors.white,
            ),
          ),
          
          SizedBox(height: screenHeight * 0.02),
          
          // Title
          Text(
            'أوقات الاستقبال في العشيرة',
            style: TextStyle(
              color: isDark ? Colors.green.shade300 : Colors.green.shade800,
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
              gradient: LinearGradient(
                colors: isDark
                    ? [Colors.green.shade700, Colors.green.shade500]
                    : [Colors.green.shade400, Colors.green.shade600],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          SizedBox(height: screenHeight * 0.03),
          
          // Clan name
          Text(
            _selectedClan!.name,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.grey.shade800,
              fontSize: messageFontSize.clamp(14.0, 18.0),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: screenHeight * 0.02),
          
          // Day info
          _buildInfoRow(
            isDark,
            Icons.calendar_today,
            'اليوم',
            acceptanceInfo['day']!,
            infoFontSize,
          ),
          
          SizedBox(height: screenHeight * 0.015),
          
          // Time info
          _buildInfoRow(
            isDark,
            Icons.access_time,
            'الوقت',
            acceptanceInfo['time']!,
            infoFontSize,
          ),
          
          SizedBox(height: screenHeight * 0.025),
          
          // Contact Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark 
                  ? Colors.amber.shade900.withOpacity(0.2)
                  : Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.amber.shade700 : Colors.amber.shade200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: isDark ? Colors.amber.shade400 : Colors.amber.shade700,
                  size: infoFontSize.clamp(16.0, 20.0),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'للحجز يرجى التواصل مع عشيرتك',
                    style: TextStyle(
                      color: isDark ? Colors.amber.shade200 : Colors.amber.shade900,
                      fontSize: infoFontSize.clamp(12.0, 14.0),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: screenHeight * 0.015),
          
          // Development Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark 
                  ? Colors.blue.shade900.withOpacity(0.2)
                  : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.blue.shade700 : Colors.blue.shade200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.construction_outlined,
                  color: isDark ? Colors.blue.shade400 : Colors.blue.shade700,
                  size: infoFontSize.clamp(16.0, 20.0),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'نعمل على تطوير هذه الميزة',
                    style: TextStyle(
                      color: isDark ? Colors.blue.shade200 : Colors.blue.shade900,
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
    bool isDark,
    IconData icon,
    String label,
    String value,
    double fontSize,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.grey.shade800.withOpacity(0.5)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDark ? Colors.green.shade400 : Colors.green.shade700,
            size: fontSize.clamp(18.0, 22.0),
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              color: isDark ? Colors.green.shade300 : Colors.grey.shade600,
              fontSize: fontSize.clamp(13.0, 15.0),
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.grey.shade800,
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