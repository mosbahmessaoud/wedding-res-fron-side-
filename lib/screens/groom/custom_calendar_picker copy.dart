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
// }

// class DateAvailability {
//   final DateTime date;
//   final DateStatus status;
//   final String? note;
//   final int currentCount;
//   final int maxCapacity;
//   final List<dynamic> reservations;

//   DateAvailability({
//     required this.date,
//     required this.status,
//     this.note,
//     this.currentCount = 0,
//     this.maxCapacity = 1,
//     this.reservations = const [],
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

//   Future<void> _loadMonthData() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Get validated dates (reserved - red color)
//       final validatedDates = await ApiService.getValidatedDates(widget.clanId);
      
//       // Get pending dates (pending_validation - yellow color)
//       final pendingDates = await ApiService.getPendingDates(widget.clanId);

//       Map<String, DateAvailability> newAvailabilities = {};

//       // Process validated dates (red - not selectable)
//       // Group by date1 since each item is a reservation, not a date summary
//       Map<String, List<dynamic>> validatedByDate = {};
//       for (var reservation in validatedDates) {
//         final dateStr = reservation['date1']?.toString();
//         if (dateStr != null) {
//           final key = dateStr; // date1 is already in YYYY-MM-DD format
//           if (!validatedByDate.containsKey(key)) {
//             validatedByDate[key] = [];
//           }
//           validatedByDate[key]!.add(reservation);
//         }
//       }

//       // Create DateAvailability for validated dates
//       for (var entry in validatedByDate.entries) {
//         final dateStr = entry.key;
//         final reservations = entry.value;
//         final date = DateTime.parse(dateStr);
        
//         newAvailabilities[dateStr] = DateAvailability(
//           date: date,
//           status: DateStatus.reserved, // Red color, not selectable
//           currentCount: reservations.length,
//           maxCapacity: widget.maxCapacityPerDate,
//           reservations: reservations,
//           note: 'محجوز ومؤكد',
//         );
//       }

//       // Process pending dates (yellow - not selectable)
//       // Group by date1 since each item is a reservation, not a date summary
//       Map<String, List<dynamic>> pendingByDate = {};
//       for (var reservation in pendingDates) {
//         final dateStr = reservation['date1']?.toString();
//         if (dateStr != null) {
//           final key = dateStr; // date1 is already in YYYY-MM-DD format
//           if (!pendingByDate.containsKey(key)) {
//             pendingByDate[key] = [];
//           }
//           pendingByDate[key]!.add(reservation);
//         }
//       }

//       // Create DateAvailability for pending dates (only if not already marked as reserved)
//       for (var entry in pendingByDate.entries) {
//         final dateStr = entry.key;
//         final reservations = entry.value;
//         final date = DateTime.parse(dateStr);
        
//         // Only add if not already marked as reserved
//         if (!newAvailabilities.containsKey(dateStr)) {
//           newAvailabilities[dateStr] = DateAvailability(
//             date: date,
//             status: DateStatus.pending, // Yellow color, not selectable
//             currentCount: reservations.length,
//             maxCapacity: widget.maxCapacityPerDate,
//             reservations: reservations,
//             note: 'في انتظار التأكيد',
//           );
//         }
//       }

//       setState(() {
//         _dateAvailabilities = newAvailabilities;
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error loading month data: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

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
    
//     // Check if date is in the past (before today)
//     final today = DateTime.now();
//     final dateOnly = DateTime(date.year, date.month, date.day);
//     final todayOnly = DateTime(today.year, today.month, today.day);
    
//     if (dateOnly.isBefore(todayOnly)) {
//       return DateAvailability(
//         date: date,
//         status: DateStatus.disabled, // Past dates are disabled
//         maxCapacity: widget.maxCapacityPerDate,
//         note: 'تاريخ منتهي',
//       );
//     }
    
//     return _dateAvailabilities[key] ?? DateAvailability(
//       date: date,
//       status: DateStatus.available, // Default to available (green) for future dates
//       maxCapacity: widget.maxCapacityPerDate,
//     );
//   }

//   bool _isSameDay(DateTime date1, DateTime date2) {
//     return date1.year == date2.year &&
//         date1.month == date2.month &&
//         date1.day == date2.day;
//   }

//   Color _getDateColor(DateTime date, DateAvailability availability) {
//     if (_selectedDate != null && _isSameDay(date, _selectedDate!)) {
//       return const Color(0xFF2E7D6A).withOpacity(0.9);
//     }

//     switch (availability.status) {
//       case DateStatus.available:
//         return const Color(0xFF4CAF50); // Green for available
//       case DateStatus.pending:
//         return const Color(0xFFFFC107); // Yellow for pending (clearly visible)
//       case DateStatus.reserved:
//         return const Color(0xFFE53935); // Red for reserved/validated (clearly visible)
//       case DateStatus.disabled:
//         return Colors.grey.shade400; // Grey for disabled/past dates (more muted)
//     }
//   }

//   Color _getDateTextColor(DateTime date, DateAvailability availability) {
//     if (_selectedDate != null && _isSameDay(date, _selectedDate!)) {
//       return Colors.white;
//     }
    
//     switch (availability.status) {
//       case DateStatus.available:
//         return Colors.white;
//       case DateStatus.pending:
//         return Colors.black87; // Dark text for yellow background (better contrast)
//       case DateStatus.reserved:
//         return Colors.white;
//       case DateStatus.disabled:
//         return Colors.grey.shade700; // Darker grey text for disabled dates
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

//   Widget _buildCalendarDay(DateTime date) {
//     final availability = _getDateAvailability(date);
//     final isCurrentMonth = date.month == _currentMonth.month && date.year == _currentMonth.year;
//     final isToday = _isSameDay(date, DateTime.now());
//     final isSelected = _selectedDate != null && _isSameDay(date, _selectedDate!);
    
//     // User can only select available dates that are in current month and within date range
//     final isSelectable = availability.status == DateStatus.available && 
//                         isCurrentMonth &&
//                         (date.isAfter(widget.firstDate.subtract(const Duration(days: 1))) &&
//                          date.isBefore(widget.lastDate.add(const Duration(days: 1))));

//     if (_isLoading && isCurrentMonth) {
//       return _buildLoadingShimmer();
//     }

//     return GestureDetector(
//       onTap: isSelectable ? () {
//         setState(() {
//           _selectedDate = date;
//         });
//       } : null,
//       onLongPress: isCurrentMonth && availability.reservations.isNotEmpty ? () {
//         _showReservationDetails(date, availability);
//       } : null,
//       child: AnimatedBuilder(
//         animation: _pulseAnimation,
//         builder: (context, child) {
//           return Transform.scale(
//             scale: isSelected ? _pulseAnimation.value : 1.0,
//             child: Container(
//               margin: const EdgeInsets.all(2),
//               decoration: BoxDecoration(
//                 color: isCurrentMonth ? _getDateColor(date, availability) : Colors.transparent,
//                 shape: BoxShape.circle,
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
//               ),
//               child: Stack(
//                 children: [
//                   Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           date.day.toString(),
//                           style: TextStyle(
//                             color: isCurrentMonth 
//                                 ? _getDateTextColor(date, availability)
//                                 : Colors.grey.shade400,
//                             fontWeight: isSelected
//                                 ? FontWeight.bold
//                                 : isToday ? FontWeight.w600 : FontWeight.normal,
//                             fontSize: 14,
//                           ),
//                         ),
//                         // Small indicator for today
//                         if (isToday && isCurrentMonth && !isSelected)
//                           Container(
//                             width: 4,
//                             height: 4,
//                             margin: const EdgeInsets.only(top: 1),
//                             decoration: BoxDecoration(
//                               color: availability.status == DateStatus.available 
//                                   ? Colors.white 
//                                   : const Color(0xFF2E7D6A),
//                               shape: BoxShape.circle,
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                   // Capacity indicator for reserved/pending dates
//                   if (isCurrentMonth && (availability.status == DateStatus.reserved || 
//                       availability.status == DateStatus.pending) && 
//                       availability.currentCount > 0)
//                     Positioned(
//                       top: 2,
//                       right: 2,
//                       child: Container(
//                         width: 12,
//                         height: 12,
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.9),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Center(
//                           child: Text(
//                             availability.currentCount.toString(),
//                             style: TextStyle(
//                               fontSize: 8,
//                               fontWeight: FontWeight.bold,
//                               color: _getDateColor(date, availability),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   // Long press indicator for dates with reservations
//                   if (isCurrentMonth && availability.reservations.isNotEmpty)
//                     const Positioned(
//                       bottom: 2,
//                       left: 2,
//                       child: Icon(
//                         Icons.info_outline,
//                         size: 8,
//                         color: Colors.white70,
//                       ),
//                     ),
//                   // Lock icon for non-selectable dates with reservations
//                   if (isCurrentMonth && !isSelectable && 
//                       (availability.status == DateStatus.reserved || availability.status == DateStatus.pending))
//                     const Positioned(
//                       bottom: 2,
//                       right: 2,
//                       child: Icon(
//                         Icons.lock,
//                         size: 10,
//                         color: Colors.white70,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   void _showReservationDetails(DateTime date, DateAvailability availability) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
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
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'تفاصيل الحجوزات - ${DateFormat('dd/MM/yyyy').format(date)}',
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'العدد: ${availability.currentCount}/${availability.maxCapacity}',
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                   const SizedBox(height: 8),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: _getDateColor(date, availability).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: _getDateColor(date, availability).withOpacity(0.3),
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Container(
//                           width: 8,
//                           height: 8,
//                           decoration: BoxDecoration(
//                             color: _getDateColor(date, availability),
//                             shape: BoxShape.circle,
//                           ),
//                         ),
//                         const SizedBox(width: 6),
//                         Text(
//                           availability.note ?? _getStatusText(availability.status),
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'الحجوزات:',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   ...availability.reservations.take(3).map((reservation) => 
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 4),
//                       child: Row(
//                         children: [
//                           Icon(
//                             Icons.person,
//                             size: 16,
//                             color: Colors.grey.shade600,
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             reservation['groom_name'] ?? 'غير محدد',
//                             style: const TextStyle(fontSize: 14),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ).toList(),
//                   if (availability.reservations.length > 3)
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 4),
//                       child: Text(
//                         '... و ${availability.reservations.length - 3} حجوزات أخرى',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _getStatusText(DateStatus status) {
//     switch (status) {
//       case DateStatus.available:
//         return 'متاح للحجز';
//       case DateStatus.pending:
//         return 'في انتظار التأكيد';
//       case DateStatus.reserved:
//         return 'محجوز ومؤكد';
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
//                     spacing: 16,
//                     runSpacing: 8,
//                     children: [
//                       _buildLegendItem('متاح للحجز', const Color(0xFF4CAF50)),
//                       _buildLegendItem('في انتظار التأكيد', const Color(0xFFFFC107)),
//                       _buildLegendItem('محجوز ومؤكد', const Color(0xFFE53935)),
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