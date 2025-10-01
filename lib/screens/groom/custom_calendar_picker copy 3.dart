// // lib/widgets/custom_calendar_picker.dart
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:intl/date_symbol_data_local.dart';
// import 'package:wedding_reservation_app/services/api_service.dart';

// // Export DateStatus and DateAvailability for use in other files
// export 'custom_calendar_picker.dart' show DateStatus, DateAvailability;

// enum DateStatus { 
//   available, 
//   pending, 
//   reserved, 
//   disabled,
//   massWeddingOpen, // New status for dates with mass wedding available
//   mixed, // New status for dates with both validated and pending reservations
// }

// class DateAvailability {
//   final DateTime date;
//   final DateStatus status;
//   final String? note;
//   final int currentCount;
//   final int validatedCount; // Count of validated reservations
//   final int pendingCount; // Count of pending reservations
//   final int maxCapacity;
//   final List<dynamic> reservations;
//   final List<dynamic> validatedReservations; // Separate lists for display
//   final List<dynamic> pendingReservations;
//   final bool allowMassWedding;

//   DateAvailability({
//     required this.date,
//     required this.status,
//     this.note,
//     this.currentCount = 0,
//     this.validatedCount = 0,
//     this.pendingCount = 0,
//     this.maxCapacity = 1,
//     this.reservations = const [],
//     this.validatedReservations = const [],
//     this.pendingReservations = const [],
//     this.allowMassWedding = false,
//   });
// }

// class CustomCalendarPicker extends StatefulWidget {
//   final DateTime? initialDate;
//   final DateTime firstDate;
//   final DateTime lastDate;
//   final Function(DateTime, DateAvailability?) onDateSelected;
//   final VoidCallback onCancel;
//   final String title;
//   final bool allowTwoConsecutiveDays;
//   final int clanId;
//   final int? hallId;
//   final int maxCapacityPerDate;

//   const CustomCalendarPicker({
//     Key? key,
//     this.initialDate,
//     required this.firstDate,
//     required this.lastDate,
//     required this.onDateSelected,
//     required this.onCancel,
//     this.title = 'اختر تاريخ الحجز',
//     this.allowTwoConsecutiveDays = false,
//     required this.clanId,
//     this.hallId,
//     this.maxCapacityPerDate = 10,
//   }) : super(key: key);

//   @override
//   State<CustomCalendarPicker> createState() => _CustomCalendarPickerState();
// }

// class _CustomCalendarPickerState extends State<CustomCalendarPicker>
//     with TickerProviderStateMixin {
//   late DateTime _currentMonth;
//   DateTime? _selectedDate;
//   bool _isLocaleInitialized = false;
//   bool _isLoading = false;
//   Map<String, DateAvailability> _dateAvailabilities = {};
//   int _maxGroomsPerDate = 3;
//   Map<String, List<String>> _groomMultiDayReservations = {}; // groom_id -> list of dates
//   Map<String, String> _dateToGroomMap = {}; // date -> groom_id (for single groom spanning multiple dates)
//   Map<String, List<DateTime>> _connectedDateRanges = {}; // groomId -> list of consecutive dates

//   late AnimationController _pulseController;
//   late AnimationController _shimmerController;
//   late Animation<double> _pulseAnimation;
//   late Animation<double> _shimmerAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _currentMonth = widget.initialDate ?? DateTime.now();
//     _selectedDate = widget.initialDate;
    
//     // Initialize animations
//     _pulseController = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     )..repeat(reverse: true);
    
//     _shimmerController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     )..repeat();

//     _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );

//     _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
//       CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
//     );

//     _initializeLocale();
//     _loadClanSettings();
//     _loadMonthData();
//   }

//   @override
//   void dispose() {
//     _pulseController.dispose();
//     _shimmerController.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeLocale() async {
//     try {
//       await initializeDateFormatting('ar');
//       setState(() {
//         _isLocaleInitialized = true;
//       });
//     } catch (e) {
//       print('Error initializing Arabic locale: $e');
//       setState(() {
//         _isLocaleInitialized = true;
//       });
//     }
//   }

//   Future<void> _loadClanSettings() async {
//     try {
//       final clanSettings = await ApiService.getSettings();
//       setState(() {
//         _maxGroomsPerDate = clanSettings['max_grooms_per_date'] ?? 3;
//       });
//     } catch (e) {
//       print('Error loading clan settings: $e');
//     }
//   }

// Future<void> _loadMonthData() async {
//   setState(() {
//     _isLoading = true;
//   });

//   try {
//     final validatedDates = await ApiService.getValidatedDates(widget.clanId);
//     final pendingDates = await ApiService.getPendingDates(widget.clanId);

//     Map<String, DateAvailability> newAvailabilities = {};
//     Map<String, List<String>> newGroomMultiDayReservations = {};
//     Map<String, String> newDateToGroomMap = {};
//     Map<String, List<DateTime>> newConnectedDateRanges = {}; // Add this line

//     // Helper function to process reservations and track multi-day bookings
//     void processReservations(List<dynamic> reservations, bool isValidated) {
//       for (var reservation in reservations) {
//         final groomId = reservation['groom_id']?.toString() ?? reservation['id']?.toString();
//         final date1Str = reservation['date1']?.toString();
//         final date2Str = reservation['date2']?.toString();
        
//         if (groomId != null && date1Str != null) {
//           List<String> groomDates = [date1Str];
//           List<DateTime> groomDateObjects = [DateTime.parse(date1Str)];
          
//           if (date2Str != null && date2Str != date1Str) {
//             groomDates.add(date2Str);
//             groomDateObjects.add(DateTime.parse(date2Str));
//           }
          
//           // Store multi-day information
//           if (groomDates.length > 1) {
//             newGroomMultiDayReservations[groomId] = groomDates;
//             // Sort dates to ensure proper order
//             groomDateObjects.sort();
//             newConnectedDateRanges[groomId] = groomDateObjects;
            
//             for (String date in groomDates) {
//               newDateToGroomMap[date] = groomId;
//             }
//           }
//         }
//       }
//     }


//     // Process both validated and pending reservations to identify multi-day bookings
//     processReservations(validatedDates, true);
//     processReservations(pendingDates, false);

//     // Group validated dates by date
//     Map<String, List<dynamic>> validatedByDate = {};
//     for (var reservation in validatedDates) {
//       final date1 = reservation['date1']?.toString();
//       final date2 = reservation['date2']?.toString();
      
//       if (date1 != null) {
//         validatedByDate.putIfAbsent(date1, () => []).add(reservation);
//       }
//       if (date2 != null && date2 != date1) {
//         validatedByDate.putIfAbsent(date2, () => []).add(reservation);
//       }
//     }

//     // Group pending dates by date
//     Map<String, List<dynamic>> pendingByDate = {};
//     for (var reservation in pendingDates) {
//       final date1 = reservation['date1']?.toString();
//       final date2 = reservation['date2']?.toString();
      
//       if (date1 != null) {
//         pendingByDate.putIfAbsent(date1, () => []).add(reservation);
//       }
//       if (date2 != null && date2 != date1) {
//         pendingByDate.putIfAbsent(date2, () => []).add(reservation);
//       }
//     }

//     // Get all unique dates that have either validated or pending reservations
//     Set<String> allDates = {...validatedByDate.keys, ...pendingByDate.keys};

//     for (String dateStr in allDates) {
//       final date = DateTime.parse(dateStr);
//       final validatedReservations = validatedByDate[dateStr] ?? [];
//       final pendingReservations = pendingByDate[dateStr] ?? [];
//       final allReservations = [...validatedReservations, ...pendingReservations];

//       final validatedCount = validatedReservations.length;
//       final pendingCount = pendingReservations.length;
//       final totalCount = validatedCount + pendingCount;

//       // Check if any reservation allows others
//       bool hasAllowOthersValidated = validatedReservations.any((res) => res['allow_others'] == true);
//       bool hasAllowOthersPending = pendingReservations.any((res) => res['allow_others'] == true);
//       bool hasAllowOthers = hasAllowOthersValidated || hasAllowOthersPending;

//       bool isFullyBooked = totalCount >= _maxGroomsPerDate;

//       DateStatus status;
//       String note;
//       bool allowMassWedding = false;

//       // Determine status based on combinations
//       if (validatedCount > 0 && pendingCount > 0) {
//         // Mixed: both validated and pending
//         if (isFullyBooked) {
//           status = DateStatus.reserved;
//           note = 'محجوز بالكامل (${validatedCount} مؤكد + ${pendingCount} في الانتظار)';
//         } else if (hasAllowOthers) {
//           status = DateStatus.mixed;
//           note = 'متاح للانضمام (${validatedCount} مؤكد + ${pendingCount} في الانتظار من ${totalCount}/${_maxGroomsPerDate})';
//           allowMassWedding = true;
//         } else {
//           status = DateStatus.reserved;
//           note = 'محجوز ولا يسمح بالانضمام (${validatedCount} مؤكد + ${pendingCount} في الانتظار)';
//         }
//       } else if (validatedCount > 0) {
//         // Only validated reservations
//         if (isFullyBooked) {
//           status = DateStatus.reserved;
//           note = 'محجوز بالكامل (${validatedCount}/${_maxGroomsPerDate})';
//         } else if (hasAllowOthersValidated) {
//           status = DateStatus.massWeddingOpen;
//           note = 'متاح للزفاف الجماعي (${validatedCount}/${_maxGroomsPerDate})';
//           allowMassWedding = true;
//         } else {
//           status = DateStatus.reserved;
//           note = 'محجوز ولا يسمح بالانضمام (${validatedCount}/${_maxGroomsPerDate})';
//         }
//       } else {
//         // Only pending reservations
//         if (isFullyBooked) {
//           status = DateStatus.pending;
//           note = 'في انتظار التأكيد - مكتمل (${pendingCount}/${_maxGroomsPerDate})';
//         } else if (hasAllowOthersPending) {
//           status = DateStatus.pending;
//           note = 'في انتظار التأكيد - متاح للانضمام (${pendingCount}/${_maxGroomsPerDate})';
//           allowMassWedding = true;
//         } else {
//           status = DateStatus.pending;
//           note = 'في انتظار التأكيد (${pendingCount}/${_maxGroomsPerDate})';
//         }
//       }

//       // Add warning for pending reservations
//       if (pendingCount > 0) {
//         note += '\nتنبيه: الحجوزات المعلقة قد تُلغى خلال 10 أيام';
//       }

//       newAvailabilities[dateStr] = DateAvailability(
//         date: date,
//         status: status,
//         currentCount: totalCount,
//         validatedCount: validatedCount,
//         pendingCount: pendingCount,
//         maxCapacity: _maxGroomsPerDate,
//         reservations: allReservations,
//         validatedReservations: validatedReservations,
//         pendingReservations: pendingReservations,
//         note: note,
//         allowMassWedding: allowMassWedding,
//       );
//     }

//     setState(() {
//       _dateAvailabilities = newAvailabilities;
//       _groomMultiDayReservations = newGroomMultiDayReservations;
//       _dateToGroomMap = newDateToGroomMap;
//       _connectedDateRanges = newConnectedDateRanges;
//       _isLoading = false;
//     });
//   } catch (e) {
//     print('Error loading month data: $e');
//     setState(() {
//       _isLoading = false;
//     });
//   }
// }


//   String _getMonthYearText(DateTime date) {
//     if (!_isLocaleInitialized) {
//       const months = [
//         '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
//         'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
//       ];
//       return '${months[date.month]} ${date.year}';
//     }

//     try {
//       return DateFormat('MMMM yyyy', 'ar').format(date);
//     } catch (e) {
//       const months = [
//         '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
//         'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
//       ];
//       return '${months[date.month]} ${date.year}';
//     }
//   }

//   DateAvailability _getDateAvailability(DateTime date) {
//     final key = DateFormat('yyyy-MM-dd').format(date);
    
//     final today = DateTime.now();
//     final dateOnly = DateTime(date.year, date.month, date.day);
//     final todayOnly = DateTime(today.year, today.month, today.day);
    
//     if (dateOnly.isBefore(todayOnly)) {
//       return DateAvailability(
//         date: date,
//         status: DateStatus.disabled,
//         maxCapacity: _maxGroomsPerDate,
//         note: 'تاريخ منتهي',
//       );
//     }
    
//     return _dateAvailabilities[key] ?? DateAvailability(
//       date: date,
//       status: DateStatus.available,
//       maxCapacity: _maxGroomsPerDate,
//     );
//   }

//   String _formatReservationDate(String? dateStr) {
//     if (dateStr == null) return '';
//     try {
//       final date = DateTime.parse(dateStr);
//       return DateFormat('dd/MM/yyyy').format(date);
//     } catch (e) {
//       return '';
//     }
//   }

//   bool _isSameDay(DateTime date1, DateTime date2) {
//     return date1.year == date2.year &&
//         date1.month == date2.month &&
//         date1.day == date2.day;
//   }

// Color _getDateColor(DateTime date, DateAvailability availability) {
//   if (_selectedDate != null && _isSameDay(date, _selectedDate!)) {
//     return const Color(0xFF2E7D6A).withOpacity(0.9);
//   }

//   final dateStr = DateFormat('yyyy-MM-dd').format(date);
  
//   // Check if this date is part of a multi-day reservation
//   if (_dateToGroomMap.containsKey(dateStr)) {
//     final groomId = _dateToGroomMap[dateStr]!;
//     final groomDates = _groomMultiDayReservations[groomId] ?? [];
    
//     if (groomDates.length > 1) {
//       // This is part of a multi-day reservation - check if it allows mass wedding
//       bool hasValidated = false;
//       bool hasPending = false;
//       bool allowsMassWedding = false;
//       bool isCapacityFull = false;
      
//       for (String groomDateStr in groomDates) {
//         final groomDateAvailability = _dateAvailabilities[groomDateStr];
//         if (groomDateAvailability != null) {
//           if (groomDateAvailability.validatedCount > 0) hasValidated = true;
//           if (groomDateAvailability.pendingCount > 0) hasPending = true;
//           if (groomDateAvailability.allowMassWedding) allowsMassWedding = true;
//           if (groomDateAvailability.currentCount >= groomDateAvailability.maxCapacity) isCapacityFull = true;
//         }
//       }
      
//       // Return color based on the overall status and mass wedding availability
//       if (hasValidated && hasPending) {
//         return allowsMassWedding && !isCapacityFull 
//             ? const Color(0xFF9C27B0)  // Purple for mixed with mass wedding
//             : const Color(0xFFE53935); // Red for mixed without mass wedding or full capacity
//       } else if (hasValidated) {
//         return allowsMassWedding && !isCapacityFull 
//             ? const Color(0xFF2196F3)  // Blue for confirmed with mass wedding available
//             : const Color(0xFFE53935); // Red for confirmed without mass wedding or full capacity
//       } else {
//         return allowsMassWedding && !isCapacityFull 
//             ? const Color(0xFFFFC107)  // Yellow for pending with mass wedding
//             : const Color(0xFFFFC107); // Yellow for pending
//       }
//     }
//   }

//   // Default color logic for single-day reservations
//   switch (availability.status) {
//     case DateStatus.available:
//       return const Color(0xFF4CAF50);
//     case DateStatus.pending:
//       return const Color(0xFFFFC107);
//     case DateStatus.reserved:
//       return const Color(0xFFE53935);
//     case DateStatus.massWeddingOpen:
//       return const Color(0xFF2196F3);
//     case DateStatus.mixed:
//       return const Color(0xFF9C27B0);
//     case DateStatus.disabled:
//       return Colors.grey.shade400;
//   }
// }

//   Color _getDateTextColor(DateTime date, DateAvailability availability) {
//     if (_selectedDate != null && _isSameDay(date, _selectedDate!)) {
//       return Colors.white;
//     }
    
//     switch (availability.status) {
//       case DateStatus.available:
//         return Colors.white;
//       case DateStatus.pending:
//         return Colors.black87;
//       case DateStatus.reserved:
//         return Colors.white;
//       case DateStatus.massWeddingOpen:
//         return Colors.white;
//       case DateStatus.mixed:
//         return Colors.white;
//       case DateStatus.disabled:
//         return Colors.grey.shade700;
//     }
//   }

//   Widget _buildLoadingShimmer() {
//     return AnimatedBuilder(
//       animation: _shimmerAnimation,
//       builder: (context, child) {
//         return Container(
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             gradient: LinearGradient(
//               begin: Alignment(_shimmerAnimation.value - 1, 0),
//               end: Alignment(_shimmerAnimation.value, 0),
//               colors: [
//                 Colors.grey.shade300,
//                 Colors.grey.shade100,
//                 Colors.grey.shade300,
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// bool _isDateSelectable(DateTime date, DateAvailability availability) {
//   // Basic availability check first
//   bool isBasicallyAvailable = availability.status == DateStatus.available || 
//                              availability.status == DateStatus.massWeddingOpen ||
//                              availability.status == DateStatus.mixed ||
//                              (availability.status == DateStatus.pending && availability.allowMassWedding);
  
//   if (!isBasicallyAvailable) {
//     return false;
//   }
  
//   final dateStr = DateFormat('yyyy-MM-dd').format(date);
  
//   // Check if this date is part of an existing multi-day reservation
//   if (_dateToGroomMap.containsKey(dateStr)) {
//     final groomId = _dateToGroomMap[dateStr]!;
//     final groomDates = _connectedDateRanges[groomId];
    
//     if (groomDates != null && groomDates.length > 1) {
//       // This date is part of a multi-day reservation
      
//       // Find position of this date in the reservation
//       final currentIndex = groomDates.indexWhere((d) => _isSameDay(d, date));
//       final isFirstDay = currentIndex == 0;
      
//       // Only allow selection of the first day of multi-day reservations
//       // This prevents new grooms from selecting the second day only
//       if (!isFirstDay) {
//         return false; // Block selection of second, third, etc. days
//       }
      
//       // For the first day, only allow if mass wedding is permitted
//       return availability.allowMassWedding;
//     }
//   }
  
//   // For available dates not part of existing multi-day reservations, always allow selection
//   return true;
// }

// Widget _buildCalendarDay(DateTime date) {
//   final availability = _getDateAvailability(date);
//   final isCurrentMonth = date.month == _currentMonth.month && date.year == _currentMonth.year;
//   final isToday = _isSameDay(date, DateTime.now());
//   final isSelected = _selectedDate != null && _isSameDay(date, _selectedDate!);
//   final dateStr = DateFormat('yyyy-MM-dd').format(date);
  
//   final isSelectable = isCurrentMonth &&
//                       (date.isAfter(widget.firstDate.subtract(const Duration(days: 1))) &&
//                        date.isBefore(widget.lastDate.add(const Duration(days: 1)))) &&
//                       _isDateSelectable(date, availability);

//   if (_isLoading && isCurrentMonth) {
//     return _buildLoadingShimmer();
//   }

//   // Check if this date is part of a connected range
//   String? groomId = _dateToGroomMap[dateStr];
//   List<DateTime>? connectedDates = groomId != null ? _connectedDateRanges[groomId] : null;
//   bool isConnectedRange = connectedDates != null && connectedDates.length > 1;
  
//   // Determine position in connected range
//   int? positionInRange;
//   bool isFirst = false;
//   bool isLast = false;
  
//   if (isConnectedRange && connectedDates != null) {
//     positionInRange = connectedDates.indexWhere((d) => _isSameDay(d, date));
//     isFirst = positionInRange == 0;
//     isLast = positionInRange == connectedDates.length - 1;
//   }

//   return GestureDetector(
//     onTap: isSelectable ? () {
//       setState(() {
//         _selectedDate = date;
//       });
//     } : null,
//     onLongPress: isCurrentMonth && availability.reservations.isNotEmpty ? () {
//       _showReservationDetails(date, availability);
//     } : null,
//     child: AnimatedBuilder(
//       animation: _pulseAnimation,
//       builder: (context, child) {
//         return Transform.scale(
//           scale: isSelected ? _pulseAnimation.value : 1.0,
//           child: Container(
//             margin: const EdgeInsets.all(2),
//               decoration: BoxDecoration(
//                 color: isCurrentMonth ? _getDateColor(date, availability) : Colors.transparent,
//                 // Fix RTL direction - right to left
//                 borderRadius: isConnectedRange 
//                   ? BorderRadius.horizontal(
//                       right: isFirst ? const Radius.circular(20) : Radius.zero,  // Changed: right for first
//                       left: isLast ? const Radius.circular(20) : Radius.zero,    // Changed: left for last
//                     )
//                   : BorderRadius.circular(20), // Circular for single dates
//                 border: isSelected 
//                     ? Border.all(color: Colors.white, width: 3)
//                     : isToday && isCurrentMonth
//                         ? Border.all(color: const Color(0xFF2E7D6A), width: 2)
//                         : null,
//                 boxShadow: isSelected ? [
//                   BoxShadow(
//                     color: _getDateColor(date, availability).withOpacity(0.5),
//                     blurRadius: 8,
//                     spreadRadius: 2,
//                   )
//                 ] : null,
//               ),            child: Stack(
//               children: [
//                 Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         date.day.toString(),
//                         style: TextStyle(
//                           color: isCurrentMonth 
//                               ? _getDateTextColor(date, availability)
//                               : Colors.grey.shade400,
//                           fontWeight: isSelected
//                               ? FontWeight.bold
//                               : isToday ? FontWeight.w600 : FontWeight.normal,
//                           fontSize: 14,
//                         ),
//                       ),
//                       if (isToday && isCurrentMonth && !isSelected)
//                         Container(
//                           width: 4,
//                           height: 4,
//                           margin: const EdgeInsets.only(top: 1),
//                           decoration: BoxDecoration(
//                             color: availability.status == DateStatus.available 
//                                 ? Colors.white 
//                                 : const Color(0xFF2E7D6A),
//                             shape: BoxShape.circle,
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//                 // Enhanced capacity indicator
//                 if (isCurrentMonth && availability.currentCount > 0)
//                   Positioned(
//                     top: 2,
//                     right: 2,
//                     child: Container(
//                       constraints: const BoxConstraints(minWidth: 16),
//                       padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.9),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         '${availability.currentCount}',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 8,
//                           fontWeight: FontWeight.bold,
//                           color: _getDateColor(date, availability),
//                         ),
//                       ),
//                     ),
//                   ),
//                 // Connected range indicator (only show on first date)
//                           // Connected range indicator (only show on first date)
//                       if (isCurrentMonth && isConnectedRange && isFirst && connectedDates != null)
//                         Positioned(
//                           top: 2,
//                           right: 2,  // Changed from left to right for RTL
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.9),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Text(
//                               '${connectedDates.length}d',
//                               style: TextStyle(
//                                 fontSize: 7,
//                                 fontWeight: FontWeight.bold,
//                                 color: _getDateColor(date, availability),
//                               ),
//                             ),
//                           ),
//                         ),
//                 // Mixed status indicator
//                 if (isCurrentMonth && availability.status == DateStatus.mixed && !isConnectedRange)
//                   const Positioned(
//                     bottom: 2,
//                     left: 2,
//                     child: Icon(
//                       Icons.merge_type,
//                       size: 10,
//                       color: Colors.white70,
//                     ),
//                   ),
//                 // Mass wedding indicator
//                 if (isCurrentMonth && (availability.status == DateStatus.massWeddingOpen || availability.allowMassWedding) && !isConnectedRange)
//                   const Positioned(
//                     bottom: 2,
//                     left: 2,
//                     child: Icon(
//                       Icons.people_alt,
//                       size: 10,
//                       color: Colors.white70,
//                     ),
//                   ),
//                 // Info indicator for long press
//                 // Info indicator for long press
//                 if (isCurrentMonth && availability.reservations.isNotEmpty)
//                   Positioned(
//                     bottom: 2,
//                     left: isConnectedRange && !isFirst ? 8 : 2,  // Changed logic for RTL
//                     child: const Icon(
//                       Icons.info_outline,
//                       size: 8,
//                       color: Colors.white70,
//                     ),
//                   ),
//                 // Lock icon for non-selectable reserved dates
//                 if (isCurrentMonth && !isSelectable && 
//                     (availability.status == DateStatus.reserved || isConnectedRange))
//                   const Positioned(
//                     top: 2,
//                     left: 2,
//                     child: Icon(
//                       Icons.lock,
//                       size: 10,
//                       color: Colors.white70,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     ),
//   );
// }
//   void _showReservationDetails(DateTime date, DateAvailability availability) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => Container(
//         constraints: BoxConstraints(
//           maxHeight: MediaQuery.of(context).size.height * 0.7,
//         ),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 40,
//               height: 4,
//               margin: const EdgeInsets.symmetric(vertical: 8),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             Flexible(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'تفاصيل الحجوزات - ${DateFormat('dd/MM/yyyy').format(date)}',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
                    
//                     // Summary statistics
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Container(
//                             padding: const EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: Colors.green.shade50,
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(color: Colors.green.shade200),
//                             ),
//                             child: Column(
//                               children: [
//                                 Text(
//                                   '${availability.validatedCount}',
//                                   style: TextStyle(
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.green.shade700,
//                                   ),
//                                 ),
//                                 const Text(
//                                   'مؤكد',
//                                   style: TextStyle(fontSize: 12),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Container(
//                             padding: const EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: Colors.orange.shade50,
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(color: Colors.orange.shade200),
//                             ),
//                             child: Column(
//                               children: [
//                                 Text(
//                                   '${availability.pendingCount}',
//                                   style: TextStyle(
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.orange.shade700,
//                                   ),
//                                 ),
//                                 const Text(
//                                   'في الانتظار',
//                                   style: TextStyle(fontSize: 12),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Container(
//                             padding: const EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: Colors.grey.shade100,
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(color: Colors.grey.shade300),
//                             ),
//                             child: Column(
//                               children: [
//                                 Text(
//                                   '${availability.currentCount}/${availability.maxCapacity}',
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const Text(
//                                   'الإجمالي',
//                                   style: TextStyle(fontSize: 12),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // Status indicator
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: _getDateColor(date, availability).withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: _getDateColor(date, availability).withOpacity(0.3),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Container(
//                                 width: 12,
//                                 height: 12,
//                                 decoration: BoxDecoration(
//                                   color: _getDateColor(date, availability),
//                                   shape: BoxShape.circle,
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: Text(
//                                   availability.note ?? _getStatusText(availability.status),
//                                   style: const TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           if (availability.pendingCount > 0) ...[
//                             const SizedBox(height: 8),
//                             Container(
//                               padding: const EdgeInsets.all(8),
//                               decoration: BoxDecoration(
//                                 color: Colors.orange.shade50,
//                                 borderRadius: BorderRadius.circular(8),
//                                 border: Border.all(color: Colors.orange.shade200),
//                               ),
//                               child: Row(
//                                 children: [
//                                   Icon(Icons.warning_amber, 
//                                        size: 16, color: Colors.orange.shade700),
//                                   const SizedBox(width: 8),
//                                   const Expanded(
//                                     child: Text(
//                                       'تنبيه: الحجوزات المعلقة قد تُلغى خلال 10 أيام',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         fontStyle: FontStyle.italic,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
                    
//                     const SizedBox(height: 20),
                    
//                     // Validated reservations
//                     if (availability.validatedReservations.isNotEmpty) ...[
//                       Row(
//                         children: [
//                           Container(
//                             width: 4,
//                             height: 20,
//                             decoration: BoxDecoration(
//                               color: Colors.green.shade500,
//                               borderRadius: BorderRadius.circular(2),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           const Text(
//                             'الحجوزات المؤكدة:',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.green,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       ...availability.validatedReservations.map((reservation) => 
//                         _buildReservationTile(reservation, true),
//                       ),
//                       const SizedBox(height: 16),
//                     ],
                    
//                     // Pending reservations
//                     if (availability.pendingReservations.isNotEmpty) ...[
//                       Row(
//                         children: [
//                           Container(
//                             width: 4,
//                             height: 20,
//                             decoration: BoxDecoration(
//                               color: Colors.orange.shade500,
//                               borderRadius: BorderRadius.circular(2),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           const Text(
//                             'الحجوزات في الانتظار:',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.orange,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       ...availability.pendingReservations.map((reservation) => 
//                         _buildReservationTile(reservation, false),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

// Widget _buildReservationTile(Map<String, dynamic> reservation, bool isValidated) {
//   final groomId = reservation['groom_id']?.toString() ?? reservation['id']?.toString();
//   final groomName = reservation['groom_name'] ?? 
//                    '${reservation['first_name'] ?? ''} ${reservation['last_name'] ?? ''}';
  
//   // Check if this groom has multiple days reserved
//   List<DateTime>? connectedDates;
//   if (groomId != null && _connectedDateRanges.containsKey(groomId)) {
//     connectedDates = _connectedDateRanges[groomId];
//   }
  
//   return Container(
//     margin: const EdgeInsets.only(bottom: 8),
//     padding: const EdgeInsets.all(12),
//     decoration: BoxDecoration(
//       color: isValidated ? Colors.green.shade50 : Colors.orange.shade50,
//       borderRadius: BorderRadius.circular(8),
//       border: Border.all(
//         color: isValidated ? Colors.green.shade200 : Colors.orange.shade200,
//       ),
//     ),
//     child: Column(
//       children: [
//         Row(
//           children: [
//             CircleAvatar(
//               radius: 16,
//               backgroundColor: isValidated ? Colors.green.shade100 : Colors.orange.shade100,
//               child: Icon(
//                 Icons.person,
//                 size: 16,
//                 color: isValidated ? Colors.green.shade700 : Colors.orange.shade700,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     groomName,
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: isValidated ? Colors.green.shade800 : Colors.orange.shade800,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Row(
//                     children: [
//                       Container(
//                         width: 6,
//                         height: 6,
//                         decoration: BoxDecoration(
//                           color: isValidated ? Colors.green.shade500 : Colors.orange.shade500,
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                       const SizedBox(width: 6),
//                       Text(
//                         isValidated ? 'مؤكد' : 'في الانتظار',
//                         style: TextStyle(
//                           fontSize: 11,
//                           color: isValidated ? Colors.green.shade600 : Colors.orange.shade600,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             if (reservation['allow_others'] == true)
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade100,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.blue.shade200),
//                 ),
//                 child: const Text(
//                   'يسمح بالانضمام',
//                   style: TextStyle(
//                     fontSize: 10, 
//                     color: Colors.blue,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             const SizedBox(width: 8),
//             Icon(
//               isValidated ? Icons.check_circle : Icons.schedule,
//               size: 16,
//               color: isValidated ? Colors.green.shade600 : Colors.orange.shade600,
//             ),
//           ],
//         ),
        
//         // Multi-day reservation information
//         if (connectedDates != null && connectedDates.length > 1) ...[
//           const SizedBox(height: 8),
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: (isValidated ? Colors.green.shade100 : Colors.orange.shade100).withOpacity(0.5),
//               borderRadius: BorderRadius.circular(6),
//               border: Border.all(
//                 color: isValidated ? Colors.green.shade300 : Colors.orange.shade300,
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.date_range,
//                       size: 14,
//                       color: isValidated ? Colors.green.shade700 : Colors.orange.shade700,
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       'حجز متعدد الأيام (${connectedDates.length} أيام):',
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         color: isValidated ? Colors.green.shade700 : Colors.orange.shade700,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 Wrap(
//                   spacing: 4,
//                   runSpacing: 2,
//                   children: connectedDates.map((date) => Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.8),
//                       borderRadius: BorderRadius.circular(4),
//                       border: Border.all(
//                         color: isValidated ? Colors.green.shade400 : Colors.orange.shade400,
//                         width: 0.5,
//                       ),
//                     ),
//                     child: Text(
//                       DateFormat('dd/MM').format(date),
//                       style: TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.w500,
//                         color: isValidated ? Colors.green.shade800 : Colors.orange.shade800,
//                       ),
//                     ),
//                   )).toList(),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ],
//     ),
//   );
// }
//   String _getStatusText(DateStatus status) {
//     switch (status) {
//       case DateStatus.available:
//         return 'متاح للحجز';
//       case DateStatus.pending:
//         return 'في انتظار التأكيد';
//       case DateStatus.reserved:
//         return 'محجوز ومؤكد';
//       case DateStatus.massWeddingOpen:
//         return 'متاح للزفاف الجماعي';
//       case DateStatus.mixed:
//         return 'مختلط (مؤكد ومعلق)';
//       case DateStatus.disabled:
//         return 'غير متاح';
//     }
//   }

//   List<Widget> _buildWeekDays() {
//     const weekDays = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
//     return weekDays.map((day) => Container(
//       padding: const EdgeInsets.all(8),
//       child: Text(
//         day,
//         textAlign: TextAlign.center,
//         style: const TextStyle(
//           fontWeight: FontWeight.w600,
//           color: Colors.grey,
//           fontSize: 12,
//         ),
//       ),
//     )).toList();
//   }

//   List<Widget> _buildCalendarDays() {
//     final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
//     final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
//     final firstWeekday = firstDayOfMonth.weekday % 7;

//     List<Widget> days = [];

//     // Add empty containers for days before the first day of the month
//     for (int i = 0; i < firstWeekday; i++) {
//       final prevMonthDay = DateTime(_currentMonth.year, _currentMonth.month, 1 - firstWeekday + i);
//       days.add(_buildCalendarDay(prevMonthDay));
//     }

//     // Add days of the current month
//     for (int day = 1; day <= daysInMonth; day++) {
//       final date = DateTime(_currentMonth.year, _currentMonth.month, day);
//       days.add(_buildCalendarDay(date));
//     }

//     // Add days from next month to fill the grid
//     final totalCells = 42;
//     final remainingCells = totalCells - days.length;
//     for (int i = 1; i <= remainingCells; i++) {
//       final nextMonthDay = DateTime(_currentMonth.year, _currentMonth.month + 1, i);
//       days.add(_buildCalendarDay(nextMonthDay));
//     }

//     return days;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         width: MediaQuery.of(context).size.width * 0.95,
//         constraints: const BoxConstraints(maxHeight: 700),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Header with gradient
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Color(0xFF4CAF50), Color(0xFF2E7D6A)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(16),
//                   topRight: Radius.circular(16),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       widget.title,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                   if (_isLoading)
//                     const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                       ),
//                     ),
//                 ],
//               ),
//             ),

//             // Month navigation with enhanced styling
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade50,
//                 border: Border(
//                   bottom: BorderSide(color: Colors.grey.shade200),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Material(
//                     color: Colors.transparent,
//                     child: InkWell(
//                       borderRadius: BorderRadius.circular(20),
//                       onTap: () {
//                         setState(() {
//                           _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
//                         });
//                         _loadMonthData();
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.all(8),
//                         child: const Icon(
//                           Icons.chevron_left,
//                           color: Color(0xFF4CAF50),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF4CAF50).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       _getMonthYearText(_currentMonth),
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF2E7D6A),
//                       ),
//                     ),
//                   ),
//                   Material(
//                     color: Colors.transparent,
//                     child: InkWell(
//                       borderRadius: BorderRadius.circular(20),
//                       onTap: () {
//                         setState(() {
//                           _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
//                         });
//                         _loadMonthData();
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.all(8),
//                         child: const Icon(
//                           Icons.chevron_right,
//                           color: Color(0xFF4CAF50),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Calendar grid
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Column(
//                 children: [
//                   const SizedBox(height: 16),
//                   // Week day headers
//                   Row(children: _buildWeekDays()),
//                   const SizedBox(height: 8),
//                   // Calendar days
//                   SizedBox(
//                     height: 280,
//                     child: GridView.count(
//                       crossAxisCount: 7,
//                       physics: const NeverScrollableScrollPhysics(),
//                       children: _buildCalendarDays(),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Enhanced Legend
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade50,
//                 borderRadius: const BorderRadius.only(
//                   bottomLeft: Radius.circular(16),
//                   bottomRight: Radius.circular(16),
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   const Row(
//                     children: [
//                       Icon(Icons.info_outline, size: 16, color: Colors.grey),
//                       SizedBox(width: 8),
//                       Text(
//                         'اضغط مطولاً على التاريخ لرؤية تفاصيل الحجوزات',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   const Text(
//                     'حالة التواريخ:',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 6,
//                     children: [
//                       _buildLegendItem('متاح للحجز', const Color(0xFF4CAF50)),
//                       _buildLegendItem('في انتظار التأكيد', const Color(0xFFFFC107)),
//                       _buildLegendItem('محجوز ومؤكد', const Color(0xFFE53935)),
//                       _buildLegendItem('متاح للزفاف الجماعي', const Color(0xFF2196F3)),
//                       _buildLegendItem('مختلط (مؤكد ومعلق)', const Color(0xFF9C27B0)),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   // Action buttons
//                   Row(
//                     children: [
//                       Expanded(
//                         child: OutlinedButton(
//                           onPressed: widget.onCancel,
//                           style: OutlinedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             side: const BorderSide(color: Color(0xFF4CAF50)),
//                           ),
//                           child: const Text(
//                             'إلغاء',
//                             style: TextStyle(color: Color(0xFF4CAF50)),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         flex: 2,
//                         child: ElevatedButton(
//                           onPressed: _selectedDate != null ? () {
//                             final availability = _getDateAvailability(_selectedDate!);
//                             widget.onDateSelected(_selectedDate!, availability);
//                           } : null,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF4CAF50),
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             elevation: 2,
//                           ),
//                           child: const Text(
//                             'تأكيد الاختيار',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLegendItem(String label, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 12,
//             height: 12,
//             decoration: BoxDecoration(
//               color: color,
//               shape: BoxShape.circle,
//             ),
//           ),
//           const SizedBox(width: 6),
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }