// lib/widgets/beautiful_custom_calendar_picker.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wedding_reservation_app/services/api_service.dart';
import '../../utils/colors.dart'; 
import '../../widgets/theme_toggle_button.dart'; 

// Export DateStatus and DateAvailability for use in other files
export 'custom_calendar_picker.dart' show DateStatus, DateAvailability;

enum DateStatus { 
  available, 
  pending, 
  reserved, 
  disabled,
  massWeddingOpen,
  mixed,
}

class DateAvailability {
  final DateTime date;
  final DateStatus status;
  final String? note;
  final int currentCount;
  final int validatedCount;
  final int pendingCount;
  final int maxCapacity;
  final List<dynamic> reservations;
  final List<dynamic> validatedReservations;
  final List<dynamic> pendingReservations;
  final bool allowMassWedding;

  DateAvailability({
    required this.date,
    required this.status,
    this.note,
    this.currentCount = 0,
    this.validatedCount = 0,
    this.pendingCount = 0,
    this.maxCapacity = 1,
    this.reservations = const [],
    this.validatedReservations = const [],
    this.pendingReservations = const [],
    this.allowMassWedding = false,
  });
}
class BeautifulCustomCalendarPicker extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Function(DateTime, DateAvailability?) onDateSelected;
  final VoidCallback onCancel;
  final String title;
  final bool allowTwoConsecutiveDays;
  final int clanId;
  final int? hallId;
  final int maxCapacityPerDate;
  final bool isOriginClan; // ADD THIS
  final int yearsMaxReservGroomFromOriginClan; // ADD THIS
  final int yearsMaxReservGroomFromOutClan; // ADD THIS

  const BeautifulCustomCalendarPicker({
    Key? key,
    this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateSelected,
    required this.onCancel,
    this.title = 'اختر تاريخ الحجز',
    this.allowTwoConsecutiveDays = false,
    required this.clanId,
    this.hallId,
    this.maxCapacityPerDate = 10,
    required this.isOriginClan, // ADD THIS
    this.yearsMaxReservGroomFromOriginClan = 1, // ADD THIS
    this.yearsMaxReservGroomFromOutClan = 3, // ADD THIS
  }) : super(key: key);

  @override
  State<BeautifulCustomCalendarPicker> createState() => _BeautifulCustomCalendarPickerState();
}
class _BeautifulCustomCalendarPickerState extends State<BeautifulCustomCalendarPicker>
    with TickerProviderStateMixin {
  late DateTime _currentMonth;
  DateTime? _selectedDate;
  bool _isLocaleInitialized = false;
  bool _isLoading = false;
  bool _allowsMassWedding=true;
  Map<String, DateAvailability> _dateAvailabilities = {};
  int _maxGroomsPerDate = 3;
  Map<String, List<String>> _groomMultiDayReservations = {};
  Map<String, String> _dateToGroomMap = {};
  Map<String, List<DateTime>> _connectedDateRanges = {};
  
  Set<String> _specialReservationDates = {};

  bool _showYearPicker = false;
  late int _maxYearsAllowed;
  late DateTime _effectiveLastDate;

  
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _bounceController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _bounceAnimation;



  // ADD THESE TWO NEW ONES
  bool _showDayPickerDialog = false;
  DateTime? _tempSelectedDate;



@override
void initState() {
  super.initState();
  
  // Calculate max years and effective last date based on clan origin
  _maxYearsAllowed = widget.isOriginClan 
      ? widget.yearsMaxReservGroomFromOriginClan 
      : widget.yearsMaxReservGroomFromOutClan;
  
  final today = DateTime.now();
  _effectiveLastDate = DateTime(
    today.year + _maxYearsAllowed,
    today.month,
    today.day,
  );
  
  _currentMonth = widget.initialDate ?? DateTime.now();
  _selectedDate = widget.initialDate;
    
    // Initialize animations
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _slideController.forward();
    _initializeLocale();
    _loadClanSettings();
    _loadMonthData();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocale() async {
    try {
      await initializeDateFormatting('ar');
      setState(() {
        _isLocaleInitialized = true;
      });
    } catch (e) {
      print('Error initializing Arabic locale: $e');
      setState(() {
        _isLocaleInitialized = true;
      });
    }
  }

  Future<void> _loadClanSettings() async {
    try {
      final clanSettings = await ApiService.getSettings();
      setState(() {
        _maxGroomsPerDate = clanSettings['max_grooms_per_date'] ?? 3;
      });
    } catch (e) {
      print('Error loading clan settings: $e');
    }
  }
Future<void> _loadMonthData() async {
  setState(() {
    _isLoading = true;
  });

  try {
    // ADD THIS - Fetch special reservations
    final specialReservations = await ApiService.getSpecialReservations();
    Set<String> specialDates = {};
    
    for (var reservation in specialReservations) {
      final date1 = reservation['date1']?.toString();
      final date2 = reservation['date2']?.toString();
      
      if (date1 != null) specialDates.add(date1);
      if (date2 != null && date2 != date1) specialDates.add(date2);
    }
    
    final validatedDates = await ApiService.getValidatedDates(widget.clanId);
    final pendingDates = await ApiService.getPendingDates(widget.clanId);

      Map<String, DateAvailability> newAvailabilities = {};
      Map<String, List<String>> newGroomMultiDayReservations = {};
      Map<String, String> newDateToGroomMap = {};
      Map<String, List<DateTime>> newConnectedDateRanges = {};

      void processReservations(List<dynamic> reservations, bool isValidated) {
        for (var reservation in reservations) {
          final groomId = reservation['groom_id']?.toString() ?? reservation['id']?.toString();
          final date1Str = reservation['date1']?.toString();
          final date2Str = reservation['date2']?.toString();
          
          if (groomId != null && date1Str != null) {
            List<String> groomDates = [date1Str];
            List<DateTime> groomDateObjects = [DateTime.parse(date1Str)];
            
            if (date2Str != null && date2Str != date1Str) {
              groomDates.add(date2Str);
              groomDateObjects.add(DateTime.parse(date2Str));
            }
            
            if (groomDates.length > 1) {
              newGroomMultiDayReservations[groomId] = groomDates;
              groomDateObjects.sort();
              newConnectedDateRanges[groomId] = groomDateObjects;
              
              for (String date in groomDates) {
                newDateToGroomMap[date] = groomId;
              }
            }
          }
        }
      }

      processReservations(validatedDates, true);
      processReservations(pendingDates, false);

      // Group validated dates by date
      Map<String, List<dynamic>> validatedByDate = {};
      for (var reservation in validatedDates) {
        final date1 = reservation['date1']?.toString();
        final date2 = reservation['date2']?.toString();
        
        if (date1 != null) {
          validatedByDate.putIfAbsent(date1, () => []).add(reservation);
        }
        if (date2 != null && date2 != date1) {
          validatedByDate.putIfAbsent(date2, () => []).add(reservation);
        }
      }

      // Group pending dates by date
      Map<String, List<dynamic>> pendingByDate = {};
      for (var reservation in pendingDates) {
        final date1 = reservation['date1']?.toString();
        final date2 = reservation['date2']?.toString();
        
        if (date1 != null) {
          pendingByDate.putIfAbsent(date1, () => []).add(reservation);
        }
        if (date2 != null && date2 != date1) {
          pendingByDate.putIfAbsent(date2, () => []).add(reservation);
        }
      }

      Set<String> allDates = {...validatedByDate.keys, ...pendingByDate.keys};

      for (String dateStr in allDates) {
        final date = DateTime.parse(dateStr);
        final validatedReservations = validatedByDate[dateStr] ?? [];
        final pendingReservations = pendingByDate[dateStr] ?? [];
        final allReservations = [...validatedReservations, ...pendingReservations];

        final validatedCount = validatedReservations.length;
        final pendingCount = pendingReservations.length;
        final totalCount = validatedCount + pendingCount;

        bool hasAllowOthersValidated = validatedReservations.any((res) => res['allow_others'] == true);
        bool hasAllowOthersPending = pendingReservations.any((res) => res['allow_others'] == true);
        bool hasAllowOthers = hasAllowOthersValidated || hasAllowOthersPending;

        bool isFullyBooked = totalCount >= _maxGroomsPerDate;

        DateStatus status;
        String note;
        bool allowMassWedding = false;



        if (validatedCount > 0 && pendingCount > 0) {
          if (isFullyBooked) {
            status = DateStatus.reserved;
            note = 'محجوز بالكامل (${validatedCount} مؤكد + ${pendingCount} في الانتظار)';
          } else if (hasAllowOthers) {
            status = DateStatus.mixed;
            note = 'متاح للانضمام (${validatedCount} مؤكد + ${pendingCount} في الانتظار من ${totalCount}/${_maxGroomsPerDate})';
            allowMassWedding = true;
          } else {
            status = DateStatus.reserved;
            note = 'محجوز ولا يسمح بالانضمام (${validatedCount} مؤكد + ${pendingCount} في الانتظار)';
          }
        } else if (validatedCount > 0) {
          if (isFullyBooked) {
            status = DateStatus.reserved;
            note = 'محجوز بالكامل (${validatedCount}/${_maxGroomsPerDate})';
          } else if (hasAllowOthersValidated) {
            status = DateStatus.massWeddingOpen;
            note = 'متاح للعرس الجماعي (${validatedCount}/${_maxGroomsPerDate})';
            allowMassWedding = true;
          } else {
            status = DateStatus.reserved;
            note = 'محجوز ولا يسمح بالانضمام (${validatedCount}/${_maxGroomsPerDate})';
          }
        } else {
          if (isFullyBooked) {
            status = DateStatus.pending;
            note = 'في انتظار التأكيد - مكتمل (${pendingCount}/${_maxGroomsPerDate})';
          } else if (hasAllowOthersPending) {
            status = DateStatus.pending;
            note = 'في انتظار التأكيد - متاح للانضمام (${pendingCount}/${_maxGroomsPerDate})';
            allowMassWedding = true;
          } else {
            status = DateStatus.pending;
            note = 'في انتظار التأكيد (${pendingCount}/${_maxGroomsPerDate})';
          }
        }

        if (pendingCount > 0) {
          note += '\nتنبيه: الحجوزات المعلقة قد تُلغى خلال 10 أيام';
        }

        newAvailabilities[dateStr] = DateAvailability(
          date: date,
          status: status,
          currentCount: totalCount,
          validatedCount: validatedCount,
          pendingCount: pendingCount,
          maxCapacity: _maxGroomsPerDate,
          reservations: allReservations,
          validatedReservations: validatedReservations,
          pendingReservations: pendingReservations,
          note: note,
          allowMassWedding: allowMassWedding,
        );
      }

      setState(() {
        _dateAvailabilities = newAvailabilities;
        _groomMultiDayReservations = newGroomMultiDayReservations;
        _dateToGroomMap = newDateToGroomMap;
        _connectedDateRanges = newConnectedDateRanges;
        _specialReservationDates = specialDates; 

        _isLoading = false;
      });
    } catch (e) {
      print('Error loading month data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

String _getMonthYearText(DateTime date) {
  // Algerian Arabic month names (ar_DZ)
  const monthsDZ = [
    '', 'جانفي', 'فيفري', 'مارس', 'أفريل', 'ماي', 'جوان',
    'جويلية', 'أوت', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
  ];

  try {
    // Try formatting using the 'ar_DZ' locale
    return DateFormat('MMMM yyyy', 'ar_DZ').format(date);
  } catch (e) {
    // Fallback to custom Algerian month names if locale not initialized
    return '${monthsDZ[date.month]} ${date.year}';
  }
}
DateAvailability _getDateAvailability(DateTime date) {
  final key = DateFormat('yyyy-MM-dd').format(date);
  
  final today = DateTime.now();
  final dateOnly = DateTime(date.year, date.month, date.day);
  final todayOnly = DateTime(today.year, today.month, today.day);
  
  // Check if date is in the past
  if (dateOnly.isBefore(todayOnly)) {
    return DateAvailability(
      date: date,
      status: DateStatus.disabled,
      maxCapacity: _maxGroomsPerDate,
      note: 'تاريخ منتهي',
    );
  }
  
  // ADD THIS - Check if date is a special reservation
  if (_specialReservationDates.contains(key)) {
    return DateAvailability(
      date: date,
      status: DateStatus.disabled,
      maxCapacity: _maxGroomsPerDate,
      note: 'حجز خاص - غير متاح',
    );
  }
  
  // Check if date exceeds max years allowed
  if (dateOnly.isAfter(_effectiveLastDate)) {
    return DateAvailability(
      date: date,
      status: DateStatus.disabled,
      maxCapacity: _maxGroomsPerDate,
      note: widget.isOriginClan 
          ? 'يمكن الحجز حتى $_maxYearsAllowed ${_maxYearsAllowed == 1 ? "سنة" : "سنوات"} فقط'
          : 'يمكن الحجز حتى $_maxYearsAllowed سنوات فقط',
    );
  }
  
  return _dateAvailabilities[key] ?? DateAvailability(
    date: date,
    status: DateStatus.available,
    maxCapacity: _maxGroomsPerDate,
  );
}
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Color _getDateColor(DateTime date, DateAvailability availability) {
    if (_selectedDate != null && _isSameDay(date, _selectedDate!)) {
      return const Color(0xFF6C63FF);
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    
    if (_dateToGroomMap.containsKey(dateStr)) {
      final groomId = _dateToGroomMap[dateStr]!;
      final groomDates = _groomMultiDayReservations[groomId] ?? [];
      
      if (groomDates.length > 1) {
        bool hasValidated = false;
        bool hasPending = false;
        bool allowsMassWedding = false;
        bool isCapacityFull = false;
        
        for (String groomDateStr in groomDates) {
          final groomDateAvailability = _dateAvailabilities[groomDateStr];
           
          if (groomDateAvailability != null) {
            if (groomDateAvailability.validatedCount > 0) hasValidated = true;
            if (groomDateAvailability.pendingCount > 0) hasPending = true;
            if (groomDateAvailability.allowMassWedding) allowsMassWedding = true;
            if (groomDateAvailability.currentCount >= groomDateAvailability.maxCapacity) isCapacityFull = true;
          }
        }
        _allowsMassWedding= allowsMassWedding;
        
        if (hasValidated && hasPending) {
          return allowsMassWedding && !isCapacityFull 
              ? const Color.fromARGB(255, 5, 150, 247)
              : const Color.fromARGB(255, 249, 15, 15);
        } else if (hasValidated) {
          return allowsMassWedding && !isCapacityFull 
              ? const Color(0xFF00BCD4)
              : const Color.fromARGB(255, 249, 15, 15);
        } else {
          return allowsMassWedding && !isCapacityFull 
              ? const Color(0xFFFFB74D)
              : const Color(0xFFFFB74D);
        }
      }
    }

    switch (availability.status) {
      case DateStatus.available:
        return const Color(0xFF4CAF50);
      case DateStatus.pending:
        return const Color(0xFFFFB74D);
      case DateStatus.reserved:
        return const Color.fromARGB(255, 249, 15, 15);
      case DateStatus.massWeddingOpen:
        return const Color(0xFF00BCD4);
      case DateStatus.mixed:
        return const Color.fromARGB(255, 5, 150, 247);
      case DateStatus.disabled:
        return const Color(0xFFBDBDBD);
    }
  }

  Color _getDateTextColor(DateTime date, DateAvailability availability) {
    if (_selectedDate != null && _isSameDay(date, _selectedDate!)) {
      return Colors.white;
    }
    
    switch (availability.status) {
      case DateStatus.available:
        return Colors.white;
      case DateStatus.pending:
        return const Color(0xFF795548);
      case DateStatus.reserved:
        return Colors.white;
      case DateStatus.massWeddingOpen:
        return Colors.white;
      case DateStatus.mixed:
        return Colors.white;
      case DateStatus.disabled:
        return const Color(0xFF757575);
    }
  }

  Widget _buildLoadingShimmer() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment(_shimmerAnimation.value - 1, 0),
              end: Alignment(_shimmerAnimation.value, 0),
              colors: [
                const Color(0xFFF5F5F5),
                const Color(0xFFE0E0E0),
                const Color(0xFFF5F5F5),
              ],
          ),
        )
        );
      },
    );
  }

  bool _isDateSelectable(DateTime date, DateAvailability availability) {
    bool isBasicallyAvailable = availability.status == DateStatus.available || 
                               availability.status == DateStatus.massWeddingOpen ||
                               availability.status == DateStatus.mixed ||
                               (availability.status == DateStatus.pending && availability.allowMassWedding);
    
    if (!isBasicallyAvailable) {
      return false;
    }
    
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    
    if (_dateToGroomMap.containsKey(dateStr)) {
      final groomId = _dateToGroomMap[dateStr]!;
      final groomDates = _connectedDateRanges[groomId];
      
      if (groomDates != null && groomDates.length > 1) {
        final currentIndex = groomDates.indexWhere((d) => _isSameDay(d, date));
        final isFirstDay = currentIndex == 0;
        
        if (!isFirstDay) {
          return false;
        }
        
        return availability.allowMassWedding;
      }
    }
    
    return true;
  }

// / Update _buildCalendarDay to handle dialog context
Widget _buildCalendarDay(DateTime date, {BuildContext? dialogContext}) {
  final availability = _getDateAvailability(date);
  final isCurrentMonth = date.month == _currentMonth.month && date.year == _currentMonth.year;
  final isToday = _isSameDay(date, DateTime.now());
  final isSelected = _selectedDate != null && _isSameDay(date, _selectedDate!);
  final dateStr = DateFormat('yyyy-MM-dd').format(date);
  
  final isSelectable = isCurrentMonth &&
                      (date.isAfter(widget.firstDate.subtract(const Duration(days: 1))) &&
                       date.isBefore(widget.lastDate.add(const Duration(days: 3 * 365)))) &&
                      _isDateSelectable(date, availability);

  if (_isLoading && isCurrentMonth) {
    return Container(
      margin: const EdgeInsets.all(2),
      child: _buildLoadingShimmer(),
    );
  }

  String? groomId = _dateToGroomMap[dateStr];
  List<DateTime>? connectedDates = groomId != null ? _connectedDateRanges[groomId] : null;
  bool isConnectedRange = connectedDates != null && connectedDates.length > 1;
  
  int? positionInRange;
  bool isFirst = false;
  bool isLast = false;
  
  if (isConnectedRange && connectedDates != null) {
    positionInRange = connectedDates.indexWhere((d) => _isSameDay(d, date));
    isFirst = positionInRange == 0;
    isLast = positionInRange == connectedDates.length - 1;
  }

  return GestureDetector(
    onTap: isSelectable ? () {
      setState(() {
        _selectedDate = date;
      });
      _bounceController.forward().then((_) => _bounceController.reverse());
      
      // Close dialog if it's open
      if (dialogContext != null) {
        Navigator.of(dialogContext).pop();
      }
    } : null,
    onLongPress: isCurrentMonth && availability.reservations.isNotEmpty ? () {
      _showReservationDetails(date, availability);
    } : null,
    child: AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _bounceAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: isSelected ? _pulseAnimation.value * _bounceAnimation.value : 1.0,
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isCurrentMonth ? _getDateColor(date, availability) : Colors.transparent,
              borderRadius: isConnectedRange 
                ? BorderRadius.horizontal(
                    right: isFirst ? const Radius.circular(16) : Radius.zero,
                    left: isLast ? const Radius.circular(16) : Radius.zero,
                  )
                : BorderRadius.circular(16),
              border: isSelected 
                  ? Border.all(color: Colors.white, width: 2.5)
                  : isToday && isCurrentMonth
                      ? Border.all(color: const Color(0xFF6C63FF), width: 2)
                      : null,
              boxShadow: isSelected ? [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: const Offset(0, 3),
                )
              ] : null,
            ),
            child: Stack(
              children: [
                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          color: isCurrentMonth 
                              ? _getDateTextColor(date, availability)
                              : const Color(0xFFBDBDBD),
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : isToday ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      if (isToday && isCurrentMonth && !isSelected)
                        Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            color: availability.status == DateStatus.available 
                                ? Colors.white 
                                : const Color(0xFF6C63FF),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Rest of the Stack children remain the same...
                if (isCurrentMonth && availability.currentCount > 0)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        '${availability.currentCount}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: _getDateColor(date, availability),
                        ),
                      ),
                    ),
                  ),
                // ... rest of indicators
              ],
            ),
          ),
        );
      },
    ),
  );
}

  void _showReservationDetails(DateTime date, DateAvailability availability) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag indicator
            Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with gradient background
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF6C63FF),
                            const Color(0xFF6C63FF).withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C63FF).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'تفاصيل الحجوزات',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DateFormat('dd/MM/yyyy').format(date),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Beautiful statistics cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            '${availability.validatedCount}',
                            'مؤكد',
                            const Color(0xFF4CAF50),
                            Icons.verified,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            '${availability.pendingCount}',
                            'في الانتظار',
                            const Color(0xFFFFB74D),
                            Icons.schedule,
                          ),
                        ),

                        const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              '${availability.currentCount}/${availability.maxCapacity}',
                              'الإجمالي',
                              const Color(0xFF9E9E9E),
                              Icons.people,
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Enhanced status indicator
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _getDateColor(date, availability).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getDateColor(date, availability).withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: _getDateColor(date, availability),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getDateColor(date, availability).withOpacity(0.3),
                                      blurRadius: 6,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  availability.note ?? _getStatusText(availability.status),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (availability.pendingCount > 0) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFB74D).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFFFB74D).withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFB74D).withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.warning_amber,
                                      size: 18,
                                      color: Color(0xFFE65100),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'تنبيه: الحجوزات المعلقة قد تُلغى خلال 10 أيام',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFE65100),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Validated reservations with beautiful design
                    if (availability.validatedReservations.isNotEmpty) ...[
                      _buildSectionHeader(
                        'الحجوزات المؤكدة',
                        const Color(0xFF4CAF50),
                        Icons.check_circle,
                      ),
                      const SizedBox(height: 12),
                      ...availability.validatedReservations.map((reservation) => 
                        _buildBeautifulReservationTile(reservation, true),
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    // Pending reservations with beautiful design
                    if (availability.pendingReservations.isNotEmpty) ...[
                      _buildSectionHeader(
                        'الحجوزات في الانتظار',
                        const Color(0xFFFFB74D),
                        Icons.schedule,
                      ),
                      const SizedBox(height: 12),
                      ...availability.pendingReservations.map((reservation) => 
                        _buildBeautifulReservationTile(reservation, false),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeautifulReservationTile(Map<String, dynamic> reservation, bool isValidated) {
    final groomId = reservation['groom_id']?.toString() ?? reservation['id']?.toString();
    final groomName = reservation['guardian_name'] ?? 
                     '${reservation['first_name'] ?? ''} ${reservation['last_name'] ?? ''}';
    final phone_number = reservation['guardian_phone'] ??  reservation['phone_number'];
    
    List<DateTime>? connectedDates;
    if (groomId != null && _connectedDateRanges.containsKey(groomId)) {
      connectedDates = _connectedDateRanges[groomId];
    }
    
    final primaryColor = isValidated ? const Color(0xFF4CAF50) : const Color(0xFFFFB74D);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar with gradient
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor,
                      primaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      groomName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phone_number,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isValidated ? 'مؤكد' : 'في الانتظار',
                            style: TextStyle(
                              fontSize: 12,
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Status and allow others indicators
              Column(
                children: [
                  if (reservation['allow_others'] == true)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00BCD4).withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'يسمح بالانضمام',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (reservation['allow_others'] == false)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF5252), Color(0xFFD32F2F)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF5252).withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'لا يسمح بانضمام آخرين',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isValidated ? Icons.check_circle : Icons.schedule,
                      size: 20,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Multi-day reservation information
          if (connectedDates != null && connectedDates.length > 1) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor.withOpacity(0.1),
                    primaryColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primaryColor.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.date_range,
                          size: 16,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'حجز متعدد الأيام (${connectedDates.length} أيام)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: connectedDates.map((date) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        DateFormat('dd/MM').format(date),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getStatusText(DateStatus status) {
    switch (status) {
      case DateStatus.available:
        return 'متاح للحجز';
      case DateStatus.pending:
        return 'في انتظار التأكيد';
      case DateStatus.reserved:
        return 'محجوز ومؤكد';
      case DateStatus.massWeddingOpen:
        return 'متاح للعرس الجماعي';
      case DateStatus.mixed:
        return 'مختلط (مؤكد ومعلق)';
      case DateStatus.disabled:
        return 'غير متاح';
    }
  }

List<Widget> _buildWeekDays() {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  const weekDays = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
  
  return weekDays.map((day) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        day,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDark 
            ? Colors.green.shade300.withOpacity(0.7)
            : const Color(0xFF757575),
          fontSize: 13,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  )).toList();
}
// Update the original _buildCalendarDays to pass dialogContext when needed
List<Widget> _buildCalendarDays({BuildContext? dialogContext}) {
  final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
  final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
  final firstWeekday = firstDayOfMonth.weekday % 7;

  List<Widget> days = [];

  for (int i = 0; i < firstWeekday; i++) {
    final prevMonthDay = DateTime(_currentMonth.year, _currentMonth.month, 1 - firstWeekday + i);
    days.add(_buildCalendarDay(prevMonthDay, dialogContext: dialogContext));
  }

  for (int day = 1; day <= daysInMonth; day++) {
    final date = DateTime(_currentMonth.year, _currentMonth.month, day);
    days.add(_buildCalendarDay(date, dialogContext: dialogContext));
  }

  final totalCells = 42;
  final remainingCells = totalCells - days.length;
  for (int i = 1; i <= remainingCells; i++) {
    final nextMonthDay = DateTime(_currentMonth.year, _currentMonth.month + 1, i);
    days.add(_buildCalendarDay(nextMonthDay, dialogContext: dialogContext));
  }

  return days;
}

Widget _buildDayPickerGrid(StateSetter setDialogState, BuildContext dialogContext) {
  final screenWidth = MediaQuery.of(context).size.width;
  
  double spacing;
  double aspectRatio;
  // if (screenWidth > 1200) {
  //   spacing = 100;
  //   aspectRatio = 2;

  // }else if (screenWidth > 900) {
  //   spacing = 50;
  //   aspectRatio = 0.9;
  // } else if (screenWidth > 600) {
  //   spacing = 50;
  //   aspectRatio = 0.9;
  // } else {
    spacing = 10;
    aspectRatio = 0.9;
  // }
  
  return GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 7,
    crossAxisSpacing: spacing,
    mainAxisSpacing: spacing,
    childAspectRatio: aspectRatio,
    children: _buildCalendarDays(dialogContext: dialogContext),
  );
}

  @override
Widget build(BuildContext context) {
  final safeAreaPadding = MediaQuery.of(context).padding;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  return SlideTransition(
    position: _slideAnimation,
    child: Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height - safeAreaPadding.top - safeAreaPadding.bottom - 40,
        ),
        decoration: BoxDecoration(
          color: isDark 
            ? Colors.black.withOpacity(0.95)
            : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark 
              ? Colors.green.shade400.withOpacity(0.3)
              : Colors.green.shade300.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark 
                ? Colors.green.shade300.withOpacity(0.2)
                : Colors.green.shade300.withOpacity(0.3),
              blurRadius: isDark ? 12 : 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildModernHeader(isDark),
            _buildMonthNavigation(isDark),
            Flexible(
              child: _buildCalendarGrid(),
            ),
            _buildBottomSection(isDark),
          ],
        ),
      ),
    ),
  );
}
Widget _buildModernHeader(bool isDark) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.green.shade600,
          Colors.green.shade800,
        ],
      ),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
    ),
    child: SafeArea(
      bottom: false,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 30,
            height: 25,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: widget.onCancel,
              icon: const Icon(Icons.close, color: Colors.white),
              iconSize: 12,
              padding: EdgeInsets.zero,
            ),
          ),
          Expanded(
            child: Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            height: 20,
            child: _isLoading
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          ),
        ],
      ),
    ),
  );
}

Widget _buildMonthNavigation(bool isDark) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
    decoration: BoxDecoration(
      color: isDark 
        ? Colors.black.withOpacity(0.3)
        : Colors.white,
      border: Border(
        bottom: BorderSide(
          color: isDark 
            ? Colors.green.shade700.withOpacity(0.3)
            : Colors.green.shade100,
          width: 1,
        ),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildModernNavButton(
          Icons.chevron_left_rounded,
          () {
            setState(() {
              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
            });
            _loadMonthData();
          },
          isDark,
        ),
        
        InkWell(
          onTap: () {
            setState(() {
              _showYearPicker = !_showYearPicker;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _showYearPicker 
                  ? (isDark ? Colors.green.shade800.withOpacity(0.3) : Colors.green.shade50)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: _showYearPicker 
                  ? Border.all(
                      color: isDark 
                        ? Colors.green.shade600.withOpacity(0.5)
                        : Colors.green.shade300.withOpacity(0.5),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getMonthYearText(_currentMonth),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.green.shade300 : Colors.green.shade800,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _showYearPicker ? Icons.expand_less : Icons.expand_more,
                  color: isDark ? Colors.green.shade300 : Colors.green.shade800,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        
        _buildModernNavButton(
          Icons.chevron_right_rounded,
          () {
            setState(() {
              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
            });
            _loadMonthData();
          },
          isDark,
        ),
      ],
    ),
  );
}
Widget _buildYearPicker(bool isDark) {
  final today = DateTime.now();
  final currentYear = today.year;
  final List<int> availableYears = List.generate(
    _maxYearsAllowed + 1,
    (index) => currentYear + index,
  );

  return Container(
    height: 120,
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: isDark 
        ? Colors.black.withOpacity(0.3)
        : Colors.grey.shade50,
      border: Border(
        bottom: BorderSide(
          color: isDark 
            ? Colors.green.shade700.withOpacity(0.3)
            : Colors.green.shade100,
          width: 1,
        ),
      ),
    ),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'اختر السنة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.green.shade300 : Colors.green.shade700,
                ),
              ),
              Text(
                widget.isOriginClan 
                    ? 'متاح حتى $_maxYearsAllowed ${_maxYearsAllowed == 1 ? "سنة" : "سنوات"}'
                    : 'متاح حتى $_maxYearsAllowed سنوات',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark 
                    ? Colors.green.shade400.withOpacity(0.7)
                    : Colors.green.shade600.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            reverse: true,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: availableYears.length,
            itemBuilder: (context, index) {
              final year = availableYears[index];
              final isSelected = year == _currentMonth.year;
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _currentMonth = DateTime(year, _currentMonth.month);
                      _showYearPicker = false;
                    });
                    _loadMonthData();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 80,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.green.shade600,
                                Colors.green.shade800,
                              ],
                            )
                          : null,
                      color: isSelected 
                          ? null
                          : (isDark 
                              ? Colors.green.shade900.withOpacity(0.3)
                              : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : (isDark 
                                ? Colors.green.shade600.withOpacity(0.5)
                                : Colors.green.shade300.withOpacity(0.5)),
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.green.shade300.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        year.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected 
                              ? Colors.white
                              : (isDark ? Colors.green.shade300 : Colors.green.shade700),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

Widget _buildModernNavButton(IconData icon, VoidCallback onPressed, bool isDark) {
  return Container(
    decoration: BoxDecoration(
      color: isDark 
        ? Colors.green.shade800.withOpacity(0.3)
        : Colors.green.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDark 
          ? Colors.green.shade600.withOpacity(0.5)
          : Colors.green.shade300.withOpacity(0.5),
        width: 1,
      ),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: isDark ? Colors.green.shade300 : Colors.green.shade700,
            size: 24,
          ),
        ),
      ),
    ),
  );
}

// Update _buildCalendarGrid method
Widget _buildCalendarGrid() {
  final screenwidth = MediaQuery.of(context).size.width;
  
  // For screens > 400, show a button to open day picker dialog
  if (screenwidth > 600) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [


          
          if (_showYearPicker)
            _buildYearPicker(Theme.of(context).brightness == Brightness.dark),
          
          const SizedBox(height: 16),
          
          // Button to open day picker dialog
          InkWell(
            onTap: () {
              setState(() {
                _showDayPickerDialog = true;
              });
              _showDayPickerPopup();
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green.shade600,
                    Colors.green.shade800,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.shade300.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _selectedDate != null 
                        ? 'التاريخ المختار: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}'
                        : 'اختر تاريخ من التقويم',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // For screens <= 400, show inline calendar
  return LayoutBuilder(
    builder: (context, constraints) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_showYearPicker)
                _buildYearPicker(Theme.of(context).brightness == Brightness.dark),
              
              Row(
                children: _buildWeekDays(),
              ),
              
              const SizedBox(height: 8),
              
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 7,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 0.85,
                children: _buildCalendarDays(),
              ),
            ],
          ),
        ),
      );
    },
  );
}


// Add this new method to show the day picker popup
void _showDayPickerPopup() {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                maxWidth: 600,
              ),
              decoration: BoxDecoration(
                color: isDark 
                  ? Colors.black.withOpacity(0.95)
                  : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark 
                    ? Colors.green.shade400.withOpacity(0.3)
                    : Colors.green.shade300.withOpacity(0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark 
                      ? Colors.green.shade300.withOpacity(0.2)
                      : Colors.green.shade300.withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.green.shade600,
                          Colors.green.shade800,
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                        const Text(
                          'اختر اليوم',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  
                  // Calendar content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: _buildWeekDays(),
                          ),
                          const SizedBox(height: 12),
                          _buildDayPickerGrid(setDialogState, dialogContext),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  ).then((_) {
    setState(() {
      _showDayPickerDialog = false;
    });
  });
}




Widget _buildBottomSection(bool isDark) {
  return Container(
    constraints: const BoxConstraints(maxHeight: 220),
    decoration: BoxDecoration(
      color: isDark 
        ? Colors.black.withOpacity(0.4)
        : const Color(0xFFFAFAFC),
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
    ),
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isDark 
                ? Colors.green.shade900.withOpacity(0.3)
                : Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark 
                  ? Colors.green.shade600.withOpacity(0.5)
                  : Colors.green.shade300.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: isDark ? Colors.green.shade300 : Colors.green.shade700,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'اضغط مطولاً لرؤية التفاصيل',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.green.shade300 : Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 7),
          
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildCompactLegend('متاح', const Color(0xFF4CAF50), isDark),
              _buildCompactLegend('معلق', const Color(0xFFFFB74D), isDark),
              _buildCompactLegend('محجوز', const Color(0xFFEF4444), isDark),
              _buildCompactLegend('جماعي', const Color(0xFF00BCD4), isDark),
              _buildCompactLegend('يوم غير قابل للحجز', const Color(0xFFBDBDBD), isDark),
            ],
          ),
          
          const SizedBox(height: 9),
          
          Row(
            children: [
              Expanded(
                child: _buildActionButton('إلغاء', false, widget.onCancel, isDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _buildActionButton(
                  'تأكيد الاختيار',
                  true,
                  _selectedDate != null ? () {
                    final availability = _getDateAvailability(_selectedDate!);
                    widget.onDateSelected(_selectedDate!, availability);
                  } : null,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildCompactLegend(String label, Color color, bool isDark) {
  final screenWidth = 360.0;
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: screenWidth * 0.03,
      vertical: screenWidth * 0.015,
    ),
    decoration: BoxDecoration(
      color: isDark 
        ? color.withOpacity(0.2)
        : color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: color.withOpacity(isDark ? 0.5 : 0.3),
        width: 1,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: screenWidth * 0.025,
          height: screenWidth * 0.025,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: screenWidth * 0.015),
        Text(
          label,
          style: TextStyle(
            fontSize: screenWidth * 0.03,
            fontWeight: FontWeight.w600,
            color: isDark ? color.withOpacity(0.9) : color.withOpacity(0.9),
          ),
        ),
      ],
    ),
  );
}

Widget _buildActionButton(
  String label,
  bool isPrimary,
  VoidCallback? onTap,
  bool isDark,
) {
  final isEnabled = onTap != null;
  final screenHeight = MediaQuery.of(context).size.height;
  
  return Container(
    decoration: BoxDecoration(
      gradient: isPrimary && isEnabled
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.green.shade600,
                Colors.green.shade800,
              ],
            )
          : null,
      color: isPrimary && !isEnabled
          ? (isDark ? Colors.grey.shade700 : Colors.grey.shade300)
          : isPrimary
              ? null
              : Colors.transparent,
      border: !isPrimary
          ? Border.all(
              color: isDark ? Colors.green.shade400 : Colors.green.shade700,
              width: 1.5,
            )
          : null,
      borderRadius: BorderRadius.circular(12),
      boxShadow: isPrimary && isEnabled
          ? [
              BoxShadow(
                color: Colors.green.shade300.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: screenHeight * 0.055,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isPrimary
                    ? Colors.white
                    : (isDark ? Colors.green.shade300 : Colors.green.shade700),
                fontSize: 360.0 * 0.038,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}


// /////


  Widget _buildNavigationButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: const Color(0xFF6C63FF),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBeautifulLegendItem(String label, Color color, IconData icon, double screenWidth) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 12,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}