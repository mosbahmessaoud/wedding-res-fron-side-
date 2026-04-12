// // lib/screens/clan_admin/reservations_tab.dart
// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:open_file/open_file.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:wedding_reservation_app/services/connectivity_service.dart';
// import 'package:wedding_reservation_app/utils/colors.dart';

// import '../../providers/theme_provider.dart';
// import '../../services/api_service.dart';
// class ReservationsTab extends StatefulWidget {
//   const ReservationsTab({super.key});

//   @override
//   State<ReservationsTab> createState() => ReservationsTabState();
// }

// class ReservationsTabState extends State<ReservationsTab> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   List<dynamic> _allReservations = [];
//   List<dynamic> _pendingReservations = [];
//   List<dynamic> _validatedReservations = [];
//   List<dynamic> _cancelledReservations = [];
//   List<dynamic> _archivedReservations = [];
//   bool _isLoading = false;
//   String _searchQuery = '';


//   // ADD THESE NEW VARIABLES:
//   bool _hasAccessPassword = false;
//   bool _isVerifyingAccess = false;
//   List<dynamic> _notBelongPendingReservations = [];
//   List<dynamic> _notBelongValidatedReservations = [];
//   bool _isLoadingNotBelong = false;

//   List<dynamic> _belongPendingOutsideReservations = [];
//   List<dynamic> _belongValidatedOutsideReservations = [];

//   // Add this state variable with the others
//   List<dynamic> _belongCancelledOutsideReservations = [];
//   List<dynamic> _notBelongCancelledReservations = [];
//   // Add these new ones:
//   List<dynamic> _belongArchivedOutsideReservations = [];
//   List<dynamic> _notBelongArchivedReservations = [];

//   final TextEditingController _searchController = TextEditingController();
//   Timer? _searchDebounce;
//   String _sortBy = 'date1'; // default
//   bool _sortAscending = true;   // newest first by default

//   // @override
//   // void initState() {
//   //   super.initState();
//   //   _tabController = TabController(length: 5, vsync: this);
//   //   _loadAllReservations();
//   // }
// bool _hasLoadedOnce = false;

// @override
// void initState() {
//   super.initState();
//   _tabController = TabController(length: 3, vsync: this);
//   // Do NOT load here — wait until tab is activated
// }

// void activateTab() {
//   if (!_hasLoadedOnce) {
//     _hasLoadedOnce = true;
//     _checkConnectivityAndLoad();
//   }
// }

// void refreshData() {
//   _checkConnectivityAndLoad();
//   setState(() {});
// }

// Future<void> _loadInitialData() async {
  
//   await _loadAllReservations();
  
//   if (mounted) {
//     setState(() {});
//   }
// }

//   // @override
//   // void dispose() {
//   //   _tabController.dispose();
//   //   super.dispose();
//   // }

// @override
//   void dispose() {
//     _tabController.dispose();
//     _searchController.dispose();
//     _searchDebounce?.cancel();
//     super.dispose();
//   }


// List<dynamic> _applySorting(List<dynamic> reservations) {
//   final sorted = List<dynamic>.from(reservations);

//   sorted.sort((a, b) {
//     int result = 0;

//     switch (_sortBy) {
//       case 'date1':
//         final aDate = a['date1'] ?? '';
//         final bDate = b['date1'] ?? '';
//         result = aDate.compareTo(bDate);
//         break;

//       case 'status':
//         const statusOrder = {
//           'pending_validation': 0,
//           'validated': 1,
//           'cancelled': 2,
//         };
//         final aOrder = statusOrder[a['status'] ?? ''] ?? 99;
//         final bOrder = statusOrder[b['status'] ?? ''] ?? 99;
//         result = aOrder.compareTo(bOrder);
//         break;

//       case 'payment_status':
//         const paymentOrder = {
//           'not_paid': 0,
//           'partially_paid': 1,
//           'paid': 2,
//         };
//         final aOrder = paymentOrder[a['payment_status'] ?? ''] ?? 99;
//         final bOrder = paymentOrder[b['payment_status'] ?? ''] ?? 99;
//         result = aOrder.compareTo(bOrder);
//         break;

//       case 'created_at':
//       default:
//         final aDate = a['created_at'] ?? '';
//         final bDate = b['created_at'] ?? '';
//         result = aDate.compareTo(bDate);
//         break;
//     }

//     return _sortAscending ? result : -result;
//   });

//   return sorted;
// }
// Widget _buildSortBar(bool isDark) {
//   final options = [
//     {'value': 'created_at', 'label': 'تاريخ الإنشاء'},
//     {'value': 'date1',      'label': 'تاريخ الحجز'},
//     {'value': 'status',     'label': 'الحالة'},
//     {'value': 'payment_status', 'label': 'الدفع'},
//   ];

//   return Container(
//     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//     color: isDark ? AppColors.darkCard : Colors.white,
//     child: Row(
//       children: [
//         Icon(Icons.sort_rounded,
//             size: 18,
//             color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
//         const SizedBox(width: 8),
//         Text(
//           'ترتيب:',
//           style: TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w500,
//             color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
//           ),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: options.map((opt) {
//                 final isSelected = _sortBy == opt['value'];
//                 return Padding(
//                   padding: const EdgeInsets.only(left: 6),
//                   child: GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         if (_sortBy == opt['value']) {
//                           _sortAscending = !_sortAscending;
//                         } else {
//                           _sortBy = opt['value']!;
//                           _sortAscending = false;
//                         }
//                       });
//                     },
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 200),
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 10, vertical: 6),
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? AppColors.primary.withOpacity(0.15)
//                             : (isDark
//                                 ? Colors.grey.shade800
//                                 : Colors.grey.shade100),
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(
//                           color: isSelected
//                               ? AppColors.primary.withOpacity(0.5)
//                               : Colors.transparent,
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             opt['label']!,
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: isSelected
//                                   ? FontWeight.w600
//                                   : FontWeight.normal,
//                               color: isSelected
//                                   ? AppColors.primary
//                                   : (isDark
//                                       ? Colors.grey.shade300
//                                       : Colors.grey.shade700),
//                             ),
//                           ),
//                           if (isSelected) ...[
//                             const SizedBox(width: 4),
//                             Icon(
//                               _sortAscending
//                                   ? Icons.arrow_upward_rounded
//                                   : Icons.arrow_downward_rounded,
//                               size: 13,
//                               color: AppColors.primary,
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }



// Future<void> _deleteReservation(int reservationId, String groomName) async {
//   final confirmed = await _showConfirmationDialog(
//     'حذف الحجز نهائياً',
//     'هل أنت متأكد من حذف حجز $groomName نهائياً؟\n\nلا يمكن التراجع عن هذا الإجراء.',
//     Colors.red.shade700,
//     Icons.delete_forever_rounded,
//   );

//   if (!confirmed) return;

//   // Double confirmation for permanent deletion
//   final doubleConfirmed = await showDialog<bool>(
//     context: context,
//     builder: (context) {
//       final isDark = Theme.of(context).brightness == Brightness.dark;
//       return AlertDialog(
//         backgroundColor: isDark ? AppColors.darkCard : Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(
//           children: [
//             Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 28),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 'تأكيد الحذف النهائي',
//                 style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w600),
//               ),
//             ),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.red.shade50,
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: Colors.red.shade200),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.info_outline, color: Colors.red.shade400, size: 18),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'سيتم حذف بيانات الحجز بشكل دائم ولا يمكن استعادتها.',
//                       style: TextStyle(color: Colors.red.shade700, fontSize: 13),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: Text('إلغاء', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
//           ),
//           ElevatedButton.icon(
//             onPressed: () => Navigator.of(context).pop(true),
//             icon: const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 18),
//             label: const Text('حذف نهائياً', style: TextStyle(color: Colors.white)),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red.shade700,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//           ),
//         ],
//       );
//     },
//   ) ?? false;

//   if (!doubleConfirmed) return;

//   try {
//     setState(() => _isLoading = true);
//     await ApiService.deleteReservation(reservationId);
//     await _loadAllReservations();
//     _showSnackBar('تم حذف الحجز نهائياً', Colors.red.shade700);
//   } catch (e) {
//     _showSnackBar('خطأ في حذف الحجز: $e', Colors.red.shade400);
//   } finally {
//     setState(() => _isLoading = false);
//   }
// }


// Future<void> _openWhatsApp(String phone) async {
//   String cleaned = phone.replaceAll(RegExp(r'[\s\-()]'), '');
//   if (cleaned.startsWith('0')) {
//     cleaned = '213${cleaned.substring(1)}';
//   } else if (!cleaned.startsWith('213')) {
//     cleaned = '213$cleaned';
//   }
//   final uri = Uri.parse('https://wa.me/$cleaned');
//   if (await canLaunchUrl(uri)) {
//     await launchUrl(uri, mode: LaunchMode.externalApplication);
//   } else {
//     if (mounted) _showSnackBar('تعذّر فتح واتساب', Colors.red.shade400);
//   }
// }

// Widget _whatsAppBtn(String phone, String label, bool isCompact) {
//   if (phone.isEmpty) return const SizedBox.shrink();
//   return ElevatedButton.icon(
//     onPressed: () => _openWhatsApp(phone),
//     icon: Icon(Icons.chat_rounded, size: isCompact ? 16 : 18),
//     label: Text('واتساب $label', style: TextStyle(fontSize: isCompact ? 12 : 14)),
//     style: ElevatedButton.styleFrom(
//       backgroundColor: const Color(0xFF25D366),
//       foregroundColor: Colors.white,
//       elevation: 0,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       padding: EdgeInsets.symmetric(
//         horizontal: isCompact ? 12 : 16,
//         vertical: isCompact ? 6 : 8,
//       ),
//     ),
//   );
// }


// Future<void> _showUpdateDateDialog(int reservationId, String groomName, String currentDate) async {
//   final isDark = Theme.of(context).brightness == Brightness.dark;
//   DateTime? selectedDate;

//   try {
//     selectedDate = DateTime.parse(currentDate);
//   } catch (_) {
//     selectedDate = DateTime.now().add(const Duration(days: 1));
//   }

//   final now = DateTime.now();
//   final firstDate = DateTime(now.year - 100, 1, 1);   // 100 years back
//   final lastDate = DateTime(now.year + 100, 12, 31);  // 100 years forward
//   final picked = await showDatePicker(
//     context: context,
//     initialDate: selectedDate!,
//     firstDate: firstDate,
//     lastDate: lastDate,
//     locale: const Locale('ar', 'DZ'),
//     builder: (context, child) => Theme(
//       data: Theme.of(context).copyWith(
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: AppColors.primary,
//           brightness: isDark ? Brightness.dark : Brightness.light,
//         ),
//       ),
//       child: child!,
//     ),
//   );

//   if (picked == null) return;

//   final confirmed = await _showConfirmationDialog(
//     'تحديث التاريخ',
//     'هل أنت متأكد من تغيير تاريخ حجز $groomName إلى ${_formatDate(picked.toIso8601String())}؟\n\nملاحظة: سيتم حذف اليوم الثاني إن وجد.',
//     Colors.blue.shade400,
//     Icons.edit_calendar_rounded,
//   );

//   if (!confirmed) return;

//   try {
//     setState(() => _isLoading = true);
//     await ApiService.updateReservationDate(reservationId, picked);
//     await _loadAllReservations();
//     _showSnackBar('تم تحديث تاريخ الحجز بنجاح', Colors.green.shade400);
//   } catch (e) {
//     _showSnackBar('خطأ في تحديث التاريخ: $e', Colors.red.shade400);
//   } finally {
//     setState(() => _isLoading = false);
//   }
// }

// // Widget _buildOutsideActionButtons(Map<String, dynamic> reservation, String status,
// //     int groomId, int reservationId, String groomName, int destinationClanId) {
// //   List<Widget> buttons = [];
// //   final paymentStatus = reservation['payment_status'] ?? 'not_paid';
// //   final currentPayment =
// //       double.tryParse(reservation['payment']?.toString() ?? '0') ?? 0.0;
// //   final screenWidth = MediaQuery.of(context).size.width;

// //   // Download PDF button
// //   buttons.add(
// //     _buildActionButton(
// //       onPressed: () => _downloadPdfSimple(reservationId),
// //       icon: Icons.download_rounded,
// //       label: 'تحميل PDF',
// //       color: Colors.blue.shade400,
// //       isCompact: screenWidth < 600,
// //     ),
// //   );

// //   if (status == 'pending_validation' || status == 'validated') {
// //     buttons.add(
// //       _buildActionButton(
// //         onPressed: () async {
// //           // Fetch required payment from the DESTINATION clan
// //           double requiredPayment = 0.0;
// //           try {
// //             requiredPayment = await ApiService.getRequiredPaymentByClanId(destinationClanId);
// //           } catch (e) {
// //             print('Could not fetch required payment for clan $destinationClanId: $e');
// //           }
// //           _togglePaymentStatus(
// //               reservationId, groomName, paymentStatus, currentPayment, requiredPayment);
// //         },
// //         icon: _getPaymentStatusIcon(paymentStatus),
// //         label: 'تحديث الدفع',
// //         color: _getPaymentStatusColor(paymentStatus),
// //         isCompact: screenWidth < 600,
// //       ),
// //     );
// //   }

// //   if (status == 'pending_validation') {
// //     buttons.add(
// //       _buildActionButton(
// //         onPressed: () async {
// //           double requiredPayment = 0.0;
// //           try {
// //             requiredPayment =
// //                 await ApiService.getRequiredPaymentByClanId(destinationClanId);
// //           } catch (e) {
// //             print('Could not fetch required payment: $e');
// //           }
// //           _validateReservation(reservationId, groomName, paymentStatus != 'not_paid');
// //         },
// //         icon: Icons.check_rounded,
// //         label: 'تأكيد',
// //         color: Colors.green.shade400,
// //         isCompact: screenWidth < 600,
// //       ),
// //     );
// //   }

// //   if (status == 'pending_validation' || status == 'validated') {
// //     buttons.add(
// //       _buildActionButton(
// //         onPressed: () => _cancelReservation(reservationId, groomName),
// //         icon: Icons.close_rounded,
// //         label: 'إلغاء',
// //         color: Colors.red.shade400,
// //         isCompact: screenWidth < 600,
// //       ),
// //     );
// //   }

// //   return Wrap(
// //     spacing: 8,
// //     runSpacing: 8,
// //     alignment: screenWidth < 600 ? WrapAlignment.center : WrapAlignment.start,
// //     children: buttons,
// //   );
// // }
// Widget _buildOutsideActionButtons(Map<String, dynamic> reservation, String status,
//     int groomId, int reservationId, String groomName, int destinationClanId) {
//   List<Widget> buttons = [];
//   final paymentStatus = reservation['payment_status'] ?? 'not_paid';
//   final currentPayment =
//       double.tryParse(reservation['payment']?.toString() ?? '0') ?? 0.0;
//   final screenWidth = MediaQuery.of(context).size.width;
//   final isArchived = _isReservationArchived(reservation);

//   buttons.add(
//     _buildActionButton(
//       onPressed: () => _downloadPdfSimple(reservationId),
//       icon: Icons.download_rounded,
//       label: 'تحميل PDF',
//       color: Colors.blue.shade400,
//       isCompact: screenWidth < 600,
//     ),
//   );

//   if (status == 'pending_validation' || status == 'validated') {
//     buttons.add(
//       _buildActionButton(
//         onPressed: () async {
//           double requiredPayment = 0.0;
//           try {
//             requiredPayment = await ApiService.getRequiredPaymentByClanId(destinationClanId);
//           } catch (e) {
//             print('Could not fetch required payment for clan $destinationClanId: $e');
//           }
//           _togglePaymentStatus(
//               reservationId, groomName, paymentStatus, currentPayment, requiredPayment);
//         },
//         icon: _getPaymentStatusIcon(paymentStatus),
//         label: 'تحديث الدفع',
//         color: _getPaymentStatusColor(paymentStatus),
//         isCompact: screenWidth < 600,
//       ),
//     );
//   }

//   if (status == 'pending_validation') {
//     buttons.add(
//       _buildActionButton(
//         onPressed: () async {
//           double requiredPayment = 0.0;
//           try {
//             requiredPayment =
//                 await ApiService.getRequiredPaymentByClanId(destinationClanId);
//           } catch (e) {
//             print('Could not fetch required payment: $e');
//           }
//           _validateReservation(reservationId, groomName, paymentStatus != 'not_paid');
//         },
//         icon: Icons.check_rounded,
//         label: 'تأكيد',
//         color: Colors.green.shade400,
//         isCompact: screenWidth < 600,
//       ),
//     );
//   }

//   if (status == 'pending_validation' || status == 'validated') {
//     buttons.add(
//       _buildActionButton(
//         onPressed: () => _cancelReservation(reservationId, groomName),
//         icon: Icons.close_rounded,
//         label: 'إلغاء',
//         color: Colors.red.shade400,
//         isCompact: screenWidth < 600,
//       ),
//     );
//   }

//   if (status == 'cancelled' || isArchived) {
//     buttons.add(
//       _buildActionButton(
//         onPressed: () => _deleteReservation(reservationId, groomName),
//         icon: Icons.delete_forever_rounded,
//         label: 'حذف',
//         color: Colors.red.shade700,
//         isCompact: screenWidth < 600,
//       ),
//     );
//   }

//   return Wrap(
//     spacing: 8,
//     runSpacing: 8,
//     alignment: screenWidth < 600 ? WrapAlignment.center : WrapAlignment.start,
//     children: buttons,
//   );
// }
// List<Widget> _buildDetailRows(Map<String, dynamic> reservation, bool isDark) {
//   final screenWidth = MediaQuery.of(context).size.width;
//   final labelWidth = screenWidth < 600 ? 100.0 : 140.0;

//   // Calculate days remaining
//   String? daysRemainingText;
//   if (reservation['expired_date_if_pending'] != null) {
//     try {
//       final expiredDate = DateTime.parse(reservation['expired_date_if_pending']);
//       final now = DateTime.now();
//       final diff = expiredDate.difference(now).inDays;
//       if (diff > 0) {
//         daysRemainingText = 'متبقي $diff يوم';
//       } else if (diff == 0) {
//         daysRemainingText = 'ينتهي اليوم';
//       } else {
//         daysRemainingText = 'انتهت الصلاحية (${diff.abs()} يوم)';
//       }
//     } catch (e) {
//       daysRemainingText = null;
//     }
//   }

//   final details = [
//     ['رقم الحجز:', '${reservation['id'] ?? 0}'],
//     ['اسم العريس (المستخدم):', reservation['first_name'] ?? 'غير محدد'],
//     ['لقب العريس (المستخدم):', reservation['last_name'] ?? 'غير محدد'],
//     ['اسم الولي:', reservation['guardian_name'] ?? 'غير محدد'],
//     ['اسم الأب:', reservation['father_name'] ?? 'غير محدد'],
//     ['رقم الهاتف:', reservation['phone_number'] ?? 'غير محدد'],
//     ['اليوم الأول:', _formatDate(reservation['date1'])],
//     if (reservation['date2_bool'] == true && reservation['date2'] != null)
//       ['اليوم الثاني:', _formatDate(reservation['date2'])],
//     ['حالة الدفع:', _getPaymentStatusText(reservation['payment_status'] ?? 'not_paid')],
//     ['حفل جماعي:', reservation['join_to_mass_wedding'] == true ? 'نعم' : 'لا'],
//     ['يسمح للآخرين:', reservation['allow_others'] == true ? 'نعم' : 'لا'],
//     ['تاريخ الإنشاء:', _formatDateTime(reservation['created_at'])],
//     if (reservation['expires_at'] != null)
//       ['تاريخ الانتهاء:', _formatDateTime(reservation['expires_at'])],
//     if (reservation['expired_date_if_pending'] != null)
//       ['انتهاء صلاحية المعلق:', _formatDateTime(reservation['expired_date_if_pending'])],
//   ];

//   return [
//     ...details.map((detail) => Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: labelWidth,
//             child: Text(detail[0],
//               style: TextStyle(
//                 fontWeight: FontWeight.w500,
//                 color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
//               )),
//           ),
//           Expanded(
//             child: Text(detail[1],
//               style: TextStyle(
//                 color: detail[0] == 'حالة الدفع:'
//                   ? _getPaymentStatusColor(reservation['payment_status'] ?? 'not_paid')
//                   : (isDark ? Colors.white70 : Colors.grey.shade800),
//                 fontWeight: detail[0] == 'حالة الدفع:' ? FontWeight.w600 : FontWeight.normal,
//               )),
//           ),
//         ],
//       ),
//     )),

//     // Days remaining badge — only if expired_date_if_pending exists
//     if (daysRemainingText != null) ...[
//       const SizedBox(height: 4),
//       Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         decoration: BoxDecoration(
//           color: _getDaysRemainingColor(reservation['expired_date_if_pending']).withOpacity(0.1),
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(
//             color: _getDaysRemainingColor(reservation['expired_date_if_pending']).withOpacity(0.4),
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.timer_outlined,
//               size: 16,
//               color: _getDaysRemainingColor(reservation['expired_date_if_pending'])),
//             const SizedBox(width: 6),
//             Text(
//               daysRemainingText,
//               style: TextStyle(
//                 color: _getDaysRemainingColor(reservation['expired_date_if_pending']),
//                 fontWeight: FontWeight.w600,
//                 fontSize: 13,
//               ),
//             ),
//           ],
//         ),
//       ),
//       const SizedBox(height: 4),
//     ],
//   ];
// }
// Color _getDaysRemainingColor(String? expiredDateStr) {
//   if (expiredDateStr == null) return Colors.grey;
//   try {
//     final expiredDate = DateTime.parse(expiredDateStr);
//     final diff = expiredDate.difference(DateTime.now()).inDays;
//     if (diff < 0) return Colors.red.shade600;
//     if (diff <= 2) return Colors.red.shade400;
//     if (diff <= 5) return Colors.orange.shade400;
//     return Colors.green.shade400;
//   } catch (_) {
//     return Colors.grey;
//   }
// }

// // ADD THIS NEW METHOD:
// Future<void> _checkAccessPassword() async {
//   try {
//     final hasPassword = await ApiService.hasAccessPassword();
//     setState(() {
//       _hasAccessPassword = hasPassword;
//     });
//   } catch (e) {
//     print('Error checking access password: $e');
//     setState(() {
//       _hasAccessPassword = false;
//     });
//   }
// }
//   // Method to verify access before navigating to protected tabs
// Future<bool> _verifyAccessForTab() async {
  

//   await _checkAccessPassword();
//   // Check if user has access password set
//   if (!_hasAccessPassword) {
//     _showAccessPasswordNotSetDialog();
//     return false;
//   }

//   // Show password verification dialog
//   return await _showAccessPasswordDialog();
// }


// // Dialog when user doesn't have access password
// void _showAccessPasswordNotSetDialog() {
//   final isDark = Theme.of(context).brightness == Brightness.dark;
  
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       title: Row(
//         children: [
//           Icon(Icons.lock_outline, color: Colors.orange),
//           SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               'كلمة مرور الوصول غير متوفرة',
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: isDark ? Colors.white : Colors.black87,
//               ),
//             ),
//           ),
//         ],
//       ),
//       // content: Text(
//       //   'لم يتم تعيين كلمة مرور وصول لحسابك.\nيرجى الاتصال بالمدير الأعلى لإنشاء كلمة مرور.',
//       //   style: TextStyle(
//       //     color: isDark ? Colors.white70 : Colors.black87,
//       //   ),
//       // ),
//       actions: [
//         ElevatedButton(
//           onPressed: () => Navigator.pop(context),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: AppColors.primary,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
//           ),
//           child: const Text('فهمت', style: TextStyle(color: Colors.white)),
//         ),
//       ],
//     ),
//   );
// }
// // Updated _showAccessPasswordDialog method with loading state

// Future<bool> _showAccessPasswordDialog() async {
//   final isDark = Theme.of(context).brightness == Brightness.dark;
//   final passwordController = TextEditingController();
//   bool obscurePassword = true;
//   String? errorMessage;
//   bool isLoading = false; // ADD THIS LINE

//   final result = await showDialog<bool>(
//     context: context,
//     barrierDismissible: false,
//     builder: (context) => StatefulBuilder(
//       builder: (context, setDialogState) => AlertDialog(
//         backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Row(
//           children: [
//             Icon(Icons.key, color: AppColors.primary),
//             SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 'أدخل كلمة مرور الوصول',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 18,
//                   color: isDark ? Colors.white : Colors.black87,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Container(
//             //   padding: const EdgeInsets.all(12),
//             //   decoration: BoxDecoration(
//             //     color: Colors.blue.shade50,
//             //     borderRadius: BorderRadius.circular(8),
//             //     border: Border.all(color: Colors.blue.shade200),
//             //   ),
//             //   child: Row(
//             //     children: const [
//             //       Icon(Icons.info_outline, color: Colors.blue, size: 20),
//             //       SizedBox(width: 8),
//             //       Expanded(
//             //         child: Text(
//             //           'هذه الصفحة محمية. يرجى إدخال كلمة المرور.',
//             //           style: TextStyle(color: Colors.blue, fontSize: 12),
//             //         ),
//             //       ),
//             //     ],
//             //   ),
//             // ),
//             // SizedBox(height: 16),
//             TextField(
//               controller: passwordController,
//               obscureText: obscurePassword,
//               autofocus: true,
//               enabled: !isLoading, // DISABLE WHEN LOADING
//               style: TextStyle(
//                 color: isDark ? Colors.white : Colors.black87,
//               ),
//               decoration: InputDecoration(
//                 labelText: 'كلمة مرور ',
//                 hintText: 'أدخل كلمة المرور',
//                 prefixIcon: const Icon(Icons.lock_outline),
//                 suffixIcon: IconButton(
//                   icon: Icon(
//                     obscurePassword ? Icons.visibility : Icons.visibility_off,
//                   ),
//                   onPressed: isLoading ? null : () { // DISABLE WHEN LOADING
//                     setDialogState(() {
//                       obscurePassword = !obscurePassword;
//                     });
//                   },
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 errorText: errorMessage,
//               ),
//               onSubmitted: isLoading ? null : (_) async { // DISABLE WHEN LOADING
//                 if (passwordController.text.isEmpty) {
//                   setDialogState(() {
//                     errorMessage = 'يرجى إدخال كلمة المرور';
//                   });
//                   return;
//                 }
                
//                 // Start loading
//                 setDialogState(() {
//                   isLoading = true;
//                   errorMessage = null;
//                 }); 
                
//                 try {
//                   final isValid = await ApiService.validateSpecialPageAccess(
//                     passwordController.text,
//                   );
//                   if (isValid) {
//                     Navigator.pop(context, true);
//                   } else {
//                     setDialogState(() {
//                       isLoading = false;
//                       errorMessage = 'كلمة المرور غير صحيحة';
//                     });
//                   }
//                 } catch (e) {
//                   setDialogState(() {
//                     isLoading = false;
//                     errorMessage = 'خطأ في التحقق من كلمة المرور';
//                   });
//                 }
//               },
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: isLoading ? null : () => Navigator.pop(context, false), // DISABLE WHEN LOADING
//             child: Text(
//               'إلغاء',
//               style: TextStyle(
//                 color: isLoading 
//                     ? Colors.grey 
//                     : (isDark ? Colors.white60 : Colors.grey[700]),
//               ),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: isLoading ? null : () async { // DISABLE WHEN LOADING
//               if (passwordController.text.isEmpty) {
//                 setDialogState(() {
//                   errorMessage = 'يرجى إدخال كلمة المرور';
//                 });
//                 return;
//               }

//               // Start loading
//               setDialogState(() {
//                 isLoading = true;
//                 errorMessage = null;
//               });

//               try {
//                 final isValid = await ApiService.validateSpecialPageAccess(
//                   passwordController.text,
//                 );

//                 if (isValid) {
//                   Navigator.pop(context, true);
//                 } else {
//                   setDialogState(() {
//                     isLoading = false;
//                     errorMessage = 'كلمة المرور غير صحيحة';
//                   });
//                 }
//               } catch (e) {
//                 setDialogState(() {
//                   isLoading = false;
//                   errorMessage = 'خطأ في التحقق من كلمة المرور';
//                 });
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: isLoading 
//                   ? Colors.grey 
//                   : AppColors.primary,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
//             ),
//             child: isLoading // UPDATED CHILD WITH LOADING INDICATOR
//                 ? Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: const [
//                       SizedBox(
//                         width: 16,
//                         height: 16,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                         ),
//                       ),
//                       SizedBox(width: 8),
//                       Text('جاري التحقق...', style: TextStyle(color: Colors.white)),
//                     ],
//                   )
//                 : const Text('تحقق', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     ),
//   );

//   passwordController.dispose();
//   return result ?? false;
// }

// Future<void> _checkConnectivityAndLoad() async {
//   setState(() => _isLoading = true);

//   final isOnline = ConnectivityService().isOnline ||
//       await ConnectivityService().checkRealInternet();

//   if (!isOnline) {
//     if (mounted) {
//       setState(() => _isLoading = false);
//       _showOfflineBanner();
//     }
//     return;
//   }

//   await _loadAllReservations();
// }


// void _showOfflineBanner() {
//   if (!mounted) return;
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       content: Row(
//         children: const [
//           Icon(Icons.wifi_off, color: Colors.white, size: 18),
//           SizedBox(width: 8),
//           Text('لا يوجد اتصال بالإنترنت'),
//         ],
//       ),
//       backgroundColor: Colors.red.shade700,
//       duration: const Duration(seconds: 3),
//       behavior: SnackBarBehavior.floating,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//     ),
//   );
// }

//   bool _isReservationArchived(Map<String, dynamic> reservation) {
//     final date2 = reservation['date2'];
//     final date2Bool = reservation['date2_bool'] ?? false;
//     final date1 = reservation['date1'];
    
//     try {
//       final now = DateTime.now();
//       final today = DateTime(now.year, now.month, now.day);
      
//       // Use date2 if it exists and date2_bool is true, otherwise use date1
//       final relevantDateStr = (date2Bool && date2 != null) ? date2 : date1;
      
//       if (relevantDateStr == null || relevantDateStr.isEmpty) {
//         return false;
//       }
      
//       final reservationDate = DateTime.parse(relevantDateStr);
//       final reservationDateOnly = DateTime(reservationDate.year, reservationDate.month, reservationDate.day);
      
//       // Archived if reservation date is before today
//       return reservationDateOnly.isBefore(today);
//     } catch (e) {
//       print('Error checking if reservation is archived: $e');
//       return false;
//     }
//   }
// Future<void> _loadAllReservations() async {
//   setState(() => _isLoading = true);

//   try {
//     final userInfo = await ApiService.getCurrentUserInfo();
//     final clanId = userInfo['clan_id'];

//     List<dynamic> validatedRes = [];
//     List<dynamic> cancelledRes = [];
//     List<dynamic> pendingRes = [];
//     List<dynamic> allRes = [];
//     List<dynamic> archivedRes = [];

//     try {
//       validatedRes = await ApiService.getOriginValidatedReservations();
//     } catch (e) {
//       print('خطأ في الحجوزات المؤكدة');
//     }

//     try {
//       cancelledRes = await ApiService.getOriginCancelledReservations();
//     } catch (e) {
//       print('خطأ في الحجوزات الملغاة: ');
//     }

//     try {
//       pendingRes = await ApiService.getOriginPendingReservations();
//     } catch (e) {
//       print('⚠️ فشل في تحميل الحجوزات المعلقة');
//       pendingRes = [];
//     }

//     // Sort pending: soonest expiry first, nulls last
//     pendingRes.sort((a, b) {
//       final aDate = a['expired_date_if_pending'];
//       final bDate = b['expired_date_if_pending'];
//       if (aDate == null && bDate == null) return 0;
//       if (aDate == null) return 1;
//       if (bDate == null) return -1;
//       return DateTime.parse(aDate).compareTo(DateTime.parse(bDate));
//     });

//     // ── Main page: split active vs archived ─────────────────────────────
//     List<dynamic> validatedActive = [];
//     List<dynamic> validatedArchived = [];
//     for (var res in validatedRes) {
//       if (_isReservationArchived(res)) {
//         validatedArchived.add(res);
//       } else {
//         validatedActive.add(res);
//       }
//     }

//     List<dynamic> pendingActive = [];
//     List<dynamic> pendingArchived = [];
//     for (var res in pendingRes) {
//       if (_isReservationArchived(res)) {
//         pendingArchived.add(res);
//       } else {
//         pendingActive.add(res);
//       }
//     }

//     List<dynamic> cancelledArchived = [];
//     for (var res in cancelledRes) {
//       if (_isReservationArchived(res)) {
//         cancelledArchived.add(res);
//       }
//     }


//     archivedRes = [...validatedArchived, ...pendingArchived, ...cancelledArchived];
//     allRes = [...validatedActive, ...pendingActive];

//     // ── Load outside/notBelong raw data ─────────────────────────────────
//     List<dynamic> notBelongPendingRes = [];
//     List<dynamic> notBelongValidatedRes = [];

//     try {
//       notBelongPendingRes = await ApiService.getGroomsWithPendingReservationsNotBelong(clanId);
//     } catch (e) {
//       print('خطأ في حجوزات العشائر الخارجية المعلقة');
//     }

//     try {
//       notBelongValidatedRes = await ApiService.getGroomsWithValidatedReservationsNotBelong(clanId);
//     } catch (e) {
//       print('خطأ في حجوزات العشائر الخارجية المؤكدة');
//     }

//     List<dynamic> belongPendingOutsideRes = [];
//     List<dynamic> belongValidatedOutsideRes = [];
//     List<dynamic> belongCancelledOutsideRes = [];
//     List<dynamic> notBelongCancelledRes = [];

//     try {
      

//       belongCancelledOutsideRes = await ApiService.getGroomsBelongWithCancelledReservationsOutside(clanId);
//       belongPendingOutsideRes = await ApiService.getGroomsBelongWithPendingReservationsOutside(clanId);
//       print('✓ تم تحميل ${belongPendingOutsideRes.length} حجز معلق خارج العشيرة (أبناء العشيرة)');

//       belongValidatedOutsideRes = await ApiService.getGroomsBelongWithValidatedReservationsOutside(clanId);
//       print('✓ تم تحميل ${belongValidatedOutsideRes.length} حجز مؤكد خارج العشيرة (أبناء العشيرة)');

//       notBelongCancelledRes = await ApiService.getGroomsNotBelongWithCancelledReservationsIntside(clanId);
//       print('✓ تم تحميل ${notBelongCancelledRes.length} حجز ملغي من خارج العشيرة');
//     } catch (e) {
//       print('خطأ في حجوزات أبناء العشيرة خارجها: $e');
//     }

//     // ── BelongOutside: split active vs archived ──────────────────────────
//     List<dynamic> belongPendingOutsideActive = [];
//     List<dynamic> belongValidatedOutsideActive = [];
//     List<dynamic> belongCancelledOutsideActive = [];
//     List<dynamic> belongOutsideArchived = [];

//     for (var r in belongPendingOutsideRes) {
//       if (_isReservationArchived(r)) {
//         belongOutsideArchived.add({...r as Map, '_nb_status': 'pending'});
//       } else {
//         belongPendingOutsideActive.add(r);
//       }
//     }
//     for (var r in belongValidatedOutsideRes) {
//       if (_isReservationArchived(r)) {
//         belongOutsideArchived.add({...r as Map, '_nb_status': 'validated'});
//       } else {
//         belongValidatedOutsideActive.add(r);
//       }
//     }
//     for (var r in belongCancelledOutsideRes) {
//       if (_isReservationArchived(r)) {
//         belongOutsideArchived.add({...r as Map, '_nb_status': 'cancelled'});
//       } else {
//         belongCancelledOutsideActive.add(r);
//       }
//     }

//     // ── NotBelong: split active vs archived ──────────────────────────────
//     List<dynamic> notBelongPendingActive = [];
//     List<dynamic> notBelongValidatedActive = [];
//     List<dynamic> notBelongCancelledActive = [];
//     List<dynamic> notBelongArchived = [];

//     for (var r in notBelongPendingRes) {
//       if (_isReservationArchived(r)) {
//         notBelongArchived.add({...r as Map, '_nb_status': 'pending'});
//       } else {
//         notBelongPendingActive.add(r);
//       }
//     }
//     for (var r in notBelongValidatedRes) {
//       if (_isReservationArchived(r)) {
//         notBelongArchived.add({...r as Map, '_nb_status': 'validated'});
//       } else {
//         notBelongValidatedActive.add(r);
//       }
//     }
//     for (var r in notBelongCancelledRes) {
//       if (_isReservationArchived(r)) {
//         notBelongArchived.add({...r as Map, '_nb_status': 'cancelled'});
//       } else {
//         notBelongCancelledActive.add(r);
//       }
//     }

//     setState(() {
//       _validatedReservations = validatedActive;
//       _cancelledReservations = cancelledRes;
//       _pendingReservations = pendingActive;
//       _allReservations = allRes;
//       _archivedReservations = archivedRes;

//       _notBelongPendingReservations = notBelongPendingActive;
//       _notBelongValidatedReservations = notBelongValidatedActive;
//       _notBelongCancelledReservations = notBelongCancelledActive;
//       _notBelongArchivedReservations = notBelongArchived;

//       _belongPendingOutsideReservations = belongPendingOutsideActive;
//       _belongValidatedOutsideReservations = belongValidatedOutsideActive;
//       _belongCancelledOutsideReservations = belongCancelledOutsideActive;
//       _belongArchivedOutsideReservations = belongOutsideArchived;
//     });

//     print('📊 إحصائيات الحجوزات:');
//     print('  - الكل (نشط): ${allRes.length}');
//     print('  - معلقة (نشطة): ${pendingActive.length}');
//     print('  - مؤكدة (نشطة): ${validatedActive.length}');
//     print('  - ملغاة: ${cancelledRes.length}');
//     print('  - أرشيف: ${archivedRes.length}');
//     print('  - حجزو خارج (نشط): ${belongPendingOutsideActive.length + belongValidatedOutsideActive.length}');
//     print('  - حجزو خارج (أرشيف): ${belongOutsideArchived.length}');
//     print('  - أتو من خارج (نشط): ${notBelongPendingActive.length + notBelongValidatedActive.length}');
//     print('  - أتو من خارج (أرشيف): ${notBelongArchived.length}');

//   } catch (e) {
//     print('خطأ عام في تحميل الحجوزات: $e');

//     setState(() {
//       _allReservations = [];
//       _pendingReservations = [];
//       _validatedReservations = [];
//       _cancelledReservations = [];
//       _archivedReservations = [];
//     });

//     _showSnackBar('فشل في تحميل الحجوزات', Colors.red.shade400);
//   } finally {
//     setState(() => _isLoading = false);
//   }
// }
//   // Future<void> _loadAllReservations() async {
//   //   setState(() => _isLoading = true);
    

  
    
//   //   try {
//   //     List<dynamic> validatedRes = [];
//   //     List<dynamic> cancelledRes = [];
//   //     List<dynamic> pendingRes = [];
//   //     List<dynamic> allRes = [];
//   //     List<dynamic> archivedRes = [];

      
      
//   //     try {
//   //       validatedRes = await ApiService.getOriginValidatedReservations();
//   //       print('✓ تم تحميل ${validatedRes.length} حجز مؤكد');
//   //     } catch (e) {
//   //       print('خطأ في الحجوزات المؤكدة: $e');
//   //     }
      
//   //     try {
//   //       cancelledRes = await ApiService.getOriginCancelledReservations();
//   //       print('✓ تم تحميل ${cancelledRes.length} حجز ملغي');
//   //     } catch (e) {
//   //       print('خطأ في الحجوزات الملغاة: $e');
//   //     }
      
//   //     try {
//   //       pendingRes = await ApiService.getOriginPendingReservations();
//   //       print('✓ تم تحميل ${pendingRes.length} حجز معلق');
//   //     } catch (e) {
//   //       print('⚠️ فشل في تحميل الحجوزات المعلقة: $e');
//   //       pendingRes = [];
//   //     }
//   //     // Sort pending: non-null expired dates first (ascending = soonest expiry first), nulls last
//   //     pendingRes.sort((a, b) {
//   //       final aDate = a['expired_date_if_pending'];
//   //       final bDate = b['expired_date_if_pending'];
//   //       if (aDate == null && bDate == null) return 0;
//   //       if (aDate == null) return 1;  // nulls go last
//   //       if (bDate == null) return -1;
//   //       return DateTime.parse(aDate).compareTo(DateTime.parse(bDate)); // soonest first
//   //     });
//   //     // Filter archived reservations from all categories
//   //     List<dynamic> validatedActive = [];
//   //     List<dynamic> validatedArchived = [];
      
//   //     for (var res in validatedRes) {
//   //       if (_isReservationArchived(res)) {
//   //         validatedArchived.add(res);
//   //       } else {
//   //         validatedActive.add(res);
//   //       }
//   //     }
      
//   //     List<dynamic> pendingActive = [];
//   //     List<dynamic> pendingArchived = [];
      
//   //     for (var res in pendingRes) {
//   //       if (_isReservationArchived(res)) {
//   //         pendingArchived.add(res);
//   //       } else {
//   //         pendingActive.add(res);
//   //       }
//   //     }
      
//   //     List<dynamic> cancelledArchived = [];
      
//   //     for (var res in cancelledRes) {
//   //       if (_isReservationArchived(res)) {
//   //         cancelledArchived.add(res);
//   //       }
//   //     }
      
      
//   //     // Combine all archived reservations
//   //     archivedRes = [...validatedArchived, ...pendingArchived, ...cancelledArchived];
      
//   //     // "All" tab excludes cancelled reservations and shows only active (non-archived) reservations
//   //     allRes = [...validatedActive, ...pendingActive];
      



//   //     List<dynamic> notBelongPendingRes = [];
//   //     List<dynamic> notBelongValidatedRes = [];

//   //     try {
//   //       notBelongPendingRes = await ApiService.getGroomsWithPendingReservationsNotBelong(
//   //         (await ApiService.getCurrentUserInfo())['clan_id'],
//   //       );
//   //       print('✓ تم تحميل ${notBelongPendingRes.length} حجز معلق خارج العشيرة');
//   //     } catch (e) {
//   //       print('خطأ في حجوزات العشائر الخارجية المعلقة: $e');
//   //     }

//   //     try {
//   //       notBelongValidatedRes = await ApiService.getGroomsWithValidatedReservationsNotBelong(
//   //         (await ApiService.getCurrentUserInfo())['clan_id'],
//   //       );
//   //       print('✓ تم تحميل ${notBelongValidatedRes.length} حجز مؤكد خارج العشيرة');
//   //     } catch (e) {
//   //       print('خطأ في حجوزات العشائر الخارجية المؤكدة: $e');
//   //     }


//   //     List<dynamic> belongPendingOutsideRes = [];
//   //     List<dynamic> belongValidatedOutsideRes = [];
//   //     List<dynamic> belongCancelledOutsideRes = []; // ← declare OUTSIDE try
//   //     List<dynamic> notBelongCancelledRes = [];

//   //    try {
//   //       final userInfo = await ApiService.getCurrentUserInfo();
//   //       final clanId = userInfo['clan_id'];

//   //       belongCancelledOutsideRes = await ApiService.getGroomsBelongWithCancelledReservationsOutside(clanId);
//   //       belongPendingOutsideRes = await ApiService.getGroomsBelongWithPendingReservationsOutside(clanId);
//   //       print('✓ تم تحميل ${belongPendingOutsideRes.length} حجز معلق خارج العشيرة (أبناء العشيرة)');
        
//   //       belongValidatedOutsideRes = await ApiService.getGroomsBelongWithValidatedReservationsOutside(clanId);
//   //       print('✓ تم تحميل ${belongValidatedOutsideRes.length} حجز مؤكد خارج العشيرة (أبناء العشيرة)');

//   //       notBelongCancelledRes = await ApiService.getGroomsNotBelongWithCancelledReservationsIntside(clanId);
//   //       print('✓ تم تحميل ${notBelongCancelledRes.length} حجز ملغي من خارج العشيرة');
//   //     } catch (e) {
//   //       print('خطأ في حجوزات أبناء العشيرة خارجها: $e');
//   //     }



//   //     setState(() {
//   //       _validatedReservations = validatedActive;
//   //       _cancelledReservations = cancelledRes; // Keep all cancelled for cancelled tab
//   //       _pendingReservations = pendingActive;
//   //       _allReservations = allRes;
//   //       _archivedReservations = archivedRes;
//   //       _notBelongPendingReservations = notBelongPendingRes;
//   //       _notBelongValidatedReservations = notBelongValidatedRes;
//   //       _belongPendingOutsideReservations = belongPendingOutsideRes;
//   //       _belongValidatedOutsideReservations = belongValidatedOutsideRes;
//   //       _belongCancelledOutsideReservations = belongCancelledOutsideRes;
//   //       _notBelongCancelledReservations = notBelongCancelledRes;
//   //             });
      
//   //     print('📊 إحصائيات الحجوزات:');
//   //     print('  - الكل (نشط): ${allRes.length}');
//   //     print('  - معلقة (نشطة): ${pendingActive.length}');
//   //     print('  - مؤكدة (نشطة): ${validatedActive.length}');
//   //     print('  - ملغاة: ${cancelledRes.length}');
//   //     print('  - أرشيف: ${archivedRes.length}');
      
//   //   } catch (e) {
//   //     print('خطأ عام في تحميل الحجوزات: $e');
      
//   //     setState(() {
//   //       _allReservations = [];
//   //       _pendingReservations = [];
//   //       _validatedReservations = [];
//   //       _cancelledReservations = [];
//   //       _archivedReservations = [];
//   //     });
      
//   //     _showSnackBar('فشل في تحميل الحجوزات', Colors.red.shade400);
//   //   } finally {
//   //     setState(() => _isLoading = false);
//   //   }
//   // }

//   // Future<void> _togglePaymentStatus(int reservationId, String groomName, bool currentPaymentStatus) async {
//   //   final action = currentPaymentStatus ? 'إلغاء تأكيد' : 'تأكيد';
//   //   final confirmed = await _showConfirmationDialog(
//   //     '$action الدفع',
//   //     'هل أنت متأكد من $action دفع $groomName؟',
//   //     currentPaymentStatus ? Colors.orange : Colors.blue,
//   //     currentPaymentStatus ? Icons.money_off_rounded : Icons.payment_rounded,
//   //   );

//   //   if (!confirmed) return;



//   //   try {
//   //     setState(() => _isLoading = true);
//   //     await ApiService.changePaymentStatus(reservationId);
//   //     await _loadAllReservations();
//   //     _showSnackBar(
//   //       currentPaymentStatus ? 'تم إلغاء تأكيد الدفع' : 'تم تأكيد الدفع بنجاح', 
//   //       currentPaymentStatus ? Colors.orange.shade400 : Colors.blue.shade400
//   //     );
//   //   } catch (e) {
//   //     _showSnackBar('خطأ في تغيير حالة الدفع: $e', Colors.red.shade400);
//   //   } finally {
//   //     setState(() => _isLoading = false);
//   //   }
//   // }
//   Future<double?> _showPaymentInputDialog(
//   String groomName,
//   double currentPayment,
//   double requiredPayment,
//   String currentStatus,
// ) async {
//   final TextEditingController amountController = TextEditingController(
//     text: currentPayment > 0 ? currentPayment.toStringAsFixed(2) : '',
//   );

//   final requiredPayment2 = await ApiService.getRequiredPayment();

//   return showDialog<double>(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade50,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(Icons.payment_rounded, color: Colors.blue.shade600, size: 28),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text('تحديث الدفع', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                   Text(groomName, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.normal)),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Current status badge
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: _getPaymentStatusColor(currentStatus).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: _getPaymentStatusColor(currentStatus).withOpacity(0.3)),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(_getPaymentStatusIcon(currentStatus), size: 16, color: _getPaymentStatusColor(currentStatus)),
//                     const SizedBox(width: 6),
//                     Text(
//                       _getPaymentStatusText(currentStatus),
//                       style: TextStyle(color: _getPaymentStatusColor(currentStatus), fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
              
//               // Payment info
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text('المبلغ الحالي:', style: TextStyle(color: Colors.grey.shade700)),
//                   Text(
//                     '${currentPayment.toStringAsFixed(2)} د.ج',
//                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text('المبلغ المطلوب:', style: TextStyle(color: Colors.grey.shade700)),
//                   Text(
//                     '${requiredPayment2.toStringAsFixed(2)} د.ج',
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue.shade700),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
              
//               // Amount input field
//               TextField(
//                 controller: amountController,
//                 keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                 decoration: InputDecoration(
//                   labelText: 'المبلغ الجديد',
//                   hintText: '0.00',
//                   suffixText: 'د.ج',
//                   prefixIcon: const Icon(Icons.attach_money),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
//                   ),
//                 ),
//               ),
//               // const SizedBox(height: 12),
              
//               // // Quick amount buttons
//               // Wrap(
//               //   spacing: 8,
//               //   runSpacing: 8,
//               //   children: [
//               //     _buildQuickAmountButton(amountController, 0, 'بدون دفع'),
//               //     _buildQuickAmountButton(amountController, requiredPayment / 2, 'نصف المبلغ'),
//               //     _buildQuickAmountButton(amountController, requiredPayment, 'كامل المبلغ'),
//               //   ],
//               // ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text('إلغاء', style: TextStyle(color: Colors.grey.shade600)),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final amount = double.tryParse(amountController.text) ?? 0.0;
//               Navigator.of(context).pop(amount);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue.shade400,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//             ),
//             child: const Text('تأكيد', style: TextStyle(fontWeight: FontWeight.bold)),
//           ),
//         ],
//       );
//     },
//   );
// }

// Widget _buildQuickAmountButton(TextEditingController controller, double amount, String label) {
//   return InkWell(
//     onTap: () => controller.text = amount.toStringAsFixed(2),
//     child: Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.blue.shade50,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.blue.shade200),
//       ),
//       child: Text(label, style: TextStyle(color: Colors.blue.shade700, fontSize: 12)),
//     ),
//   );
// }
// // Helper methods for payment status display
// Color _getPaymentStatusColor(String status) {
//   switch (status) {
//     case 'paid':
//       return Colors.green;
//     case 'partially_paid':
//       return Colors.orange;
//     case 'not_paid':
//     default:
//       return Colors.red;
//   }
// }

// IconData _getPaymentStatusIcon(String status) {
//   switch (status) {
//     case 'paid':
//       return Icons.check_circle_rounded;
//     case 'partially_paid':
//       return Icons.hourglass_bottom_rounded;
//     case 'not_paid':
//     default:
//       return Icons.cancel_rounded;
//   }
// }

// String _getPaymentStatusText(String status) {
//   switch (status) {
//     case 'paid':
//       return 'مدفوع بالكامل';
//     case 'partially_paid':
//       return 'مدفوع جزئياً';
//     case 'not_paid':
//     default:
//       return 'غير مدفوع';
//   }
// }

//   Future<void> _togglePaymentStatus(
//   int reservationId, 
//   String groomName, 
//   String currentPaymentStatus,
//   double currentPayment,
//   double requiredPayment
// ) async {
//   // Show payment input dialog
//   final paymentAmount = await _showPaymentInputDialog(
//     groomName,
//     currentPayment,
//     requiredPayment,
//     currentPaymentStatus,
//   );

//   if (paymentAmount == null) return; // User cancelled

//   try {
//     setState(() => _isLoading = true);
//     final result = await ApiService.changePaymentStatus(reservationId, paymentAmount);
    
//     await _loadAllReservations();
    
//     final newStatus = result['reservation']['payment_status'];
//     String message;
//     Color color;
    
//     switch (newStatus) {
//       case 'paid':
//         message = 'تم تأكيد دفع كامل المبلغ';
//         color = Colors.green.shade400;
//         break;
//       case 'partially_paid':
//         message = 'تم تأكيد دفع جزء من المبلغ';
//         color = Colors.orange.shade400;
//         break;
//       case 'not_paid':
//         message = 'تم تحديث حالة الدفع: لا يوجد دفع';
//         color = Colors.grey.shade400;
//         break;
//       default:
//         message = 'تم تحديث حالة الدفع';
//         color = Colors.blue.shade400;
//     }
    
//     _showSnackBar(message, color);
//   } catch (e) {
//     _showSnackBar('خطأ في تغيير حالة الدفع: $e', Colors.red.shade400);
//   } finally {
//     setState(() => _isLoading = false);
//   }
// }


//   // Future<void> _validateReservation(int groomId, String groomName, bool paymentValid) async {
//   //   if (!paymentValid) {
//   //     await _showPaymentRequiredDialog();
//   //     return;
//   //   }

//   //   final confirmed = await _showConfirmationDialog(
//   //     'تأكيد الحجز',
//   //     'هل أنت متأكد من تأكيد حجز $groomName؟',
//   //     Colors.green,
//   //     Icons.check_circle,
//   //   );

//   //   if (!confirmed) return;

//   //   try {
//   //     setState(() => _isLoading = true);
//   //     await ApiService.validateReservation(groomId);
//   //     await _loadAllReservations();
//   //     _showSnackBar('تم تأكيد الحجز بنجاح', Colors.green.shade400);
//   //   } catch (e) {
//   //     _showSnackBar('خطأ في تأكيد الحجز: $e', Colors.red.shade400);
//   //   } finally {
//   //     setState(() => _isLoading = false);
//   //   }
//   // }

// Future<void> _validateReservation(int reservationId, String groomName, bool paymentValid) async {
//   // if (!paymentValid) {
//   //   await _showPaymentRequiredDialog();
//   //   return;
//   // }

//   final confirmed = await _showConfirmationDialog(
//     'تأكيد الحجز',
//     'هل أنت متأكد من تأكيد حجز $groomName؟',
//     Colors.green,
//     Icons.check_circle,
//   );

//   if (!confirmed) return;

//   try {
//     setState(() => _isLoading = true);
//     await ApiService.ChangeReservationStatus(reservationId); // ← reservationId, not groomId
//     await _loadAllReservations();
//     _showSnackBar('تم تأكيد الحجز بنجاح', Colors.green.shade400);
//   } catch (e) {
//     _showSnackBar('خطأ في تأكيد الحجز: $e', Colors.red.shade400);
//   } finally {
//     setState(() => _isLoading = false);
//   }
// }

// Future<void> _validateReservationFromCancelledTab(int reservationId, String groomName, bool paymentValid) async {
//   // if (!paymentValid) {
//   //   await _showPaymentRequiredDialog();
//   //   return;
//   // }

//   final confirmed = await _showConfirmationDialog(
//     'تغيير حالة الحجز الى الحالة المؤقة',
//     'هل أنت متأكد من تغيير حالة الحجز الى الحالة المؤقة $groomName؟',
//     Colors.amber.shade800,
//     Icons.check_circle,
//   );

//   if (!confirmed) return;

//   try {
//     setState(() => _isLoading = true);
//     await ApiService.ChangeReservationStatusOnCancelledTab(reservationId); // ← reservationId, not groomId
//     await _loadAllReservations();
//     _showSnackBar('تم تغيير حالة الحجز بنجاح الى الحالة المؤقة', Colors.amber.shade800);
//   } catch (e) {
//     _showSnackBar('خطأ في تأكيد الحجز: $e', Colors.red.shade400);
//   } finally {
//     setState(() => _isLoading = false);
//   }
// }

//   Future<void> _showPaymentRequiredDialog() async {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
    
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: isDark ? AppColors.darkCard : Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(
//           children: [
//             Icon(Icons.warning_rounded, color: Colors.orange.shade400, size: 28),
//             const SizedBox(width: 12),
//             Text('تنبيه', style: TextStyle(color: Colors.orange.shade400, fontWeight: FontWeight.w600)),
//           ],
//         ),
//         content: Text(
//           'يجب على العريس دفع المبلغ المطلوب أولاً قبل تأكيد الحجز.\n\nالرجاء الضغط على زر "تأكيد الدفع" بعد استلام الدفع.',
//           style: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade700),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text('حسناً', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
//           ),
//         ],
//       ),
//     );
//   }

//   // Future<void> _cancelReservation(int groomId, String groomName) async {
//   //   final confirmed = await _showConfirmationDialog(
//   //     'إلغاء الحجز',
//   //     'هل أنت متأكد من إلغاء حجز $groomName؟',
//   //     Colors.red,
//   //     Icons.cancel,
//   //   );

//   //   if (!confirmed) return;

//   //   try {
//   //     setState(() => _isLoading = true);
//   //     await ApiService.cancelGroomReservationByClanAdmin(groomId);
//   //     await _loadAllReservations();
//   //     _showSnackBar('تم إلغاء الحجز بنجاح', Colors.orange.shade400);
//   //   } catch (e) {
//   //     _showSnackBar('خطأ في إلغاء الحجز: $e', Colors.red.shade400);
//   //   } finally {
//   //     setState(() => _isLoading = false);
//   //   }
//   // }



//   Future<void> _cancelReservation(int reservationId, String groomName) async {
//   final confirmed = await _showConfirmationDialog(
//     'إلغاء الحجز',
//     'هل أنت متأكد من إلغاء حجز $groomName؟',
//     Colors.red,
//     Icons.cancel,
//   );

//   if (!confirmed) return;

//   try {
//     setState(() => _isLoading = true);
//     await ApiService.ChangeReservationStatusToCancelled(reservationId); // ← reservationId, not groomId
//     await _loadAllReservations();
//     _showSnackBar('تم إلغاء الحجز بنجاح', Colors.orange.shade400);
//   } catch (e) {
//     _showSnackBar('خطأ في إلغاء الحجز: $e', Colors.red.shade400);
//   } finally {
//     setState(() => _isLoading = false);
//   }
// }


//   Future<void> _downloadPdf(int reservationId) async {
//     try {
//       setState(() => _isLoading = true);
      
//       _showSnackBar('جاري تحميل الملف...', Colors.blue.shade400);
      
//       final pdfBytes = await ApiService.downloadPdfFromServer(reservationId);
//       final savedFile = await _savePdfFile(pdfBytes, reservationId);
      
//       if (savedFile != null) {
//         _showSnackBar('تم تحميل الملف بنجاح', Colors.green.shade400);
        
//         try {
//           await OpenFile.open(savedFile.path);
//         } catch (e) {
//           print('Could not open file: $e');
//           _showFileLocationDialog(savedFile.path);
//         }
//       }
      
//     } catch (e) {
//       print('Download error: $e');
//       _showSnackBar('خطأ في تحميل الملف: $e', Colors.red.shade400);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<File?> _savePdfFile(Uint8List pdfBytes, int reservationId) async {
//     try {
//       Directory? directory;
      
//       if (Platform.isAndroid) {
//         directory = await getExternalStorageDirectory();
//         if (directory != null) {
//           String publicPath = directory.path.replaceAll('Android/data/com.yourapp.name/files', 'Download');
//           directory = Directory(publicPath);
          
//           if (!await directory.exists()) {
//             directory = await getExternalStorageDirectory();
//           }
//         }
//       } else {
//         directory = await getApplicationDocumentsDirectory();
//       }
      
//       if (directory == null) {
//         throw Exception('لا يمكن الوصول إلى مجلد التخزين');
//       }
      
//       final fileName = 'reservation_$reservationId.pdf';
//       final file = File('${directory.path}/$fileName');
      
//       await file.writeAsBytes(pdfBytes);
      
//       return file;
//     } catch (e) {
//       print('Error saving file: $e');
//       return null;
//     }
//   }

//   void _showFileLocationDialog(String filePath) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
    
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: isDark ? AppColors.darkCard : Colors.white,
//         title: Text('تم حفظ الملف', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('تم حفظ الملف في:', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
//             SizedBox(height: 8),
//             Text(
//               filePath,
//               style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
//             ),
//             SizedBox(height: 16),
//             Text('يمكنك العثور على الملف في تطبيق مدير الملفات', 
//               style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('موافق', style: TextStyle(color: AppColors.primary)),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _downloadPdfSimple(int reservationId) async {
//     try {
//       setState(() => _isLoading = true);
      
//       _showSnackBar('جاري تحميل الملف...', Colors.blue.shade400);
      
//       final pdfBytes = await ApiService.downloadPdfFromServer(reservationId);
      
//       final directory = await getApplicationDocumentsDirectory();
//       final fileName = 'reservation_$reservationId.pdf';
//       final file = File('${directory.path}/$fileName');
      
//       await file.writeAsBytes(pdfBytes);
      
//       _showSnackBar('تم تحميل الملف بنجاح', Colors.green.shade400);
      
//       final result = await OpenFile.open(file.path);
//       if (result.type != ResultType.done) {
//         _showFileLocationDialog(file.path);
//       }
      
//     } catch (e) {
//       _showSnackBar('خطأ في تحميل الملف: $e', Colors.red.shade400);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   List<dynamic> _getFilteredReservations(List<dynamic> reservations) {
//     if (_searchQuery.isEmpty) return reservations;
    
//     return reservations.where((reservation) {
//       final first_name = reservation['first_name']?.toString().toLowerCase() ?? '';
//       final last_name = reservation['last_name']?.toString().toLowerCase() ?? '';
//       final guardianName = reservation['guardian_name']?.toString().toLowerCase() ?? '';
//       final fatherName = reservation['father_name']?.toString().toLowerCase() ?? '';
//       final phoneNumber = reservation['phone_number']?.toString() ?? '';
//       final query = _searchQuery.toLowerCase();
      
//       return first_name.contains(query) || 
//              last_name.contains(query) || 
//              guardianName.contains(query) || 
//              fatherName.contains(query) || 
//              phoneNumber.contains(query);
//     }).toList();
//   }

//   Future<bool> _showConfirmationDialog(String title, String content, Color color, IconData icon) async {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
    
//     return await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: isDark ? AppColors.darkCard : Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(
//           children: [
//             Icon(icon, color: color, size: 28),
//             const SizedBox(width: 12),
//             Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
//           ],
//         ),
//         content: Text(content, style: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade700)),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: Text('إلغاء', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: color,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//             child: const Text('تأكيد', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     ) ?? false;
//   }

//   void _showSnackBar(String message, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: color,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }


// PreferredSizeWidget _buildModernAppBar() {
//   final isDark = Theme.of(context).brightness == Brightness.dark;
//   return AppBar(
//     elevation: 0,
//     backgroundColor: Colors.transparent,
//     flexibleSpace: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     isDark ? AppColors.primary.withOpacity(0.4):AppColors.primary.withOpacity(0.8) ,
//                     AppColors.primary,
//                     AppColors.primary,
//                     isDark ? AppColors.primary.withOpacity(0.4):AppColors.primary.withOpacity(0.8) ,
//                     // isDark ? AppColors.primary.withOpacity(0.4):const Color.fromARGB(255, 130, 161, 112).withOpacity(0.9),
                    
//                   ],
//                 ),
//               ),
//             ),
//     title: LayoutBuilder(
//       builder: (context, constraints) {
//         final isSmallScreen = MediaQuery.of(context).size.width < 600;
//         return Text(
//           'إدارة الحجوزات',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: isSmallScreen ? 18 : 20,
//           ),
//         );
//       },
//     ),
//     foregroundColor: Colors.white,
//     leading: IconButton(
//       icon: Icon(Icons.arrow_back_ios_new, size: 20),
//       onPressed: () {
//         Navigator.pushReplacementNamed(context, '/clan_admin_home');
//       },
//     ),
//     actions: [
//       LayoutBuilder(
//         builder: (context, constraints) {
//           final screenWidth = MediaQuery.of(context).size.width;
//           final isSmallScreen = screenWidth < 600;
          
//           return Row(
//             children: [
//               Container(
//                 margin: EdgeInsets.only(right: isSmallScreen ? 4 : 8),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: IconButton(
//                   onPressed: () async {
//                     final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
//                     themeProvider.toggleTheme();
//                   },
//                   icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode , size: isSmallScreen ? 18 : 20),
//                   tooltip: isDark ? 'الوضع الفاتح' : 'الوضع الداكن',
//                   padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
//                 ),
//               ),
//               Container(
//                 margin: EdgeInsets.only(
//                   right: isSmallScreen ? 4 : 8, 
//                   left: isSmallScreen ? 8 : 16
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: IconButton(
//                   onPressed: _checkConnectivityAndLoad,
//                   icon: Icon(Icons.refresh, size: isSmallScreen ? 18 : 20),
//                   tooltip: 'تحديث القائمة',
//                   padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     ],
//   );
// }


//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
    
//     return Scaffold(
//       appBar: _buildModernAppBar(),
//       backgroundColor: isDark ?  Colors.grey.shade900: Colors.grey.shade50,
//       body: Column(
//         children: [
//           // Modern Header with Search
//           Container(
//             padding: EdgeInsets.fromLTRB(
//               MediaQuery.of(context).size.width < 600 ? 16 : 20,
//               MediaQuery.of(context).size.width < 600 ? 16 : 20,
//               MediaQuery.of(context).size.width < 600 ? 16 : 20,
//               MediaQuery.of(context).size.width < 600 ? 12 : 16,
//             ),
//             decoration: BoxDecoration(
//               color: isDark ? AppColors.darkCard : Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 // Search Bar
//                 Container(
//                   decoration: BoxDecoration(
//                     color: isDark ? AppColors.darkInputBackground : Colors.grey.shade100,
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: TextField(
//                     controller: _searchController,
//                     onChanged: (value) {
//                       _searchDebounce?.cancel();
//                       _searchDebounce = Timer(const Duration(milliseconds: 300), () {
//                         if (mounted) setState(() => _searchQuery = value);
//                       });
//                     },
//                     style: TextStyle(color: isDark ? Colors.white : Colors.black87),
//                     decoration: InputDecoration(
//                       hintText: 'البحث بالاسم أو رقم الهاتف...',
//                       hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade500),
//                       prefixIcon: Icon(Icons.search_rounded,
//                         color: isDark ? Colors.grey.shade500 : Colors.grey.shade400, size: 22),
//                       suffixIcon: _searchQuery.isNotEmpty
//                           ? IconButton(
//                               icon: Icon(Icons.clear_rounded,
//                                 color: isDark ? Colors.grey.shade500 : Colors.grey.shade400, size: 20),
//                               onPressed: () {
//                                 _searchController.clear();
//                                 _searchDebounce?.cancel();
//                                 setState(() => _searchQuery = '');
//                               },
//                             )
//                           : null,
//                       border: InputBorder.none,
//                       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                     ),
//                   ),
//                 ),
                
//                 const SizedBox(height: 20),
                
//                 // Statistics Cards
//                 _buildModernStatistics(isDark),
//               ],
//             ),
//           ),
                      
//             Container(
//               color: isDark ? AppColors.darkCard : Colors.white,
//               child: TabBar(
//                 controller: _tabController,
//                 isScrollable: true,
//                 tabAlignment: TabAlignment.start, // Ensures tabs start from the right (RTL)
//                 indicatorColor: AppColors.primary,
//                 indicatorWeight: 3,
//                 labelColor: AppColors.primary,
//                 unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
//                 labelStyle: TextStyle(
//                   fontWeight: FontWeight.w600, 
//                   fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 14
//                 ),
//                 unselectedLabelStyle: TextStyle(
//                   fontWeight: FontWeight.w500,
//                   fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 14
//                 ),
//                 labelPadding: EdgeInsets.symmetric(
//                   horizontal: MediaQuery.of(context).size.width < 600 ? 12 : 16
//                 ),
//                 padding: EdgeInsets.symmetric(
//                   horizontal: MediaQuery.of(context).size.width < 600 ? 8 : 12
//                 ),
//                 tabs: [
//   Tab(text: 'الحجوزات الداخلية'),
//   Tab(
//     child: Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(Icons.output, size: 14, color: Colors.teal),
//         SizedBox(width: 4),
//         Text('حجزو خارج '),
//       ],
//     ),
//   ),
//   Tab(
//     child: Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(Icons.swap_horiz, size: 14, color: Colors.purple),
//         SizedBox(width: 4),
//         Text('أتو من خارج '),
//       ],
//     ),
//   ),
// ],
//               ),
//             ),
//           // Tab Views
//           Expanded(
//             child: _isLoading
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         CircularProgressIndicator(color: AppColors.primary),
//                         const SizedBox(height: 16),
//                         Text('جاري التحميل...', 
//                           style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
//                       ],
//                     ),
//                   )
//                 : TabBarView(
//                     controller: _tabController,
//                     children: [
//                               _buildBelongReservationsPage(isDark),         // من داخل العشيرة وحجزو داخل العشيرة
//                               _buildBelongOutsideReservationsPage(isDark),  // حجزو خارج العشيرة
//                               _buildNotBelongReservationsPage(isDark),       // أتو من خارج العشيرة
//                             ],
//                   ),
//           ),
//           SizedBox(height: 1), 
//         ],
//       ),
//     );
//   }



// Widget _buildModernStatistics(bool isDark) {
//   final stats = [
//     {'title': 'الإجمالي', 'count': _allReservations.length, 'color': Colors.blue.shade400, 'icon': Icons.event_note_rounded},
//     {'title': 'معلقة', 'count': _pendingReservations.length, 'color': Colors.orange.shade400, 'icon': Icons.hourglass_empty_rounded},
//     {'title': 'حجزو في خارج العشيرة', 'count': _belongPendingOutsideReservations.length + _belongValidatedOutsideReservations.length, 'color': Colors.teal.shade400, 'icon': Icons.output},
//     {'title': 'أتو من خارج العشيرة', 'count': _notBelongPendingReservations.length + _notBelongValidatedReservations.length, 'color': Colors.purple.shade400, 'icon': Icons.swap_horiz},
//     {'title': 'مؤكدة', 'count': _validatedReservations.length, 'color': Colors.green.shade400, 'icon': Icons.check_circle_rounded},
//     {'title': 'ملغاة', 'count': _cancelledReservations.length, 'color': Colors.red.shade400, 'icon': Icons.cancel_rounded},
//     {'title': 'أرشيف', 'count': _archivedReservations.length, 'color': Colors.purple.shade400, 'icon': Icons.archive_rounded},
//   ];

//   // Make it responsive based on screen width
//   final screenWidth = MediaQuery.of(context).size.width;
//   final cardWidth = screenWidth < 600 ? 95.0 : 120.0;
//   final cardHeight = screenWidth < 600 ? 90.0 : 100.0;

//   return SizedBox(
//     height: cardHeight,
//     child: ListView.builder(
//       scrollDirection: Axis.horizontal,
//       itemCount: stats.length,
//       itemBuilder: (context, index) {
//         final stat = stats[index];
//         return Container(
//           width: cardWidth,
//           margin: EdgeInsets.only(left: index < stats.length - 1 ? 12 : 0),
//           padding: EdgeInsets.all(screenWidth < 600 ? 10 : 12),
//           decoration: BoxDecoration(
//             color: (stat['color'] as Color).withOpacity(isDark ? 0.2 : 0.1),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: (stat['color'] as Color).withOpacity(isDark ? 0.3 : 0.2)),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(stat['icon'] as IconData, color: stat['color'] as Color, 
//                 size: screenWidth < 600 ? 22 : 26),
//               SizedBox(height: screenWidth < 600 ? 2 : 4),
//               Text(
//                 '${stat['count']}',
//                 style: TextStyle(
//                   fontSize: screenWidth < 600 ? 15 : 18,
//                   fontWeight: FontWeight.bold,
//                   color: stat['color'] as Color,
//                 ),
//               ),
//               Flexible(
//                 child: Text(
//                   stat['title'] as String,
//                   style: TextStyle(
//                     fontSize: screenWidth < 600 ? 9 : 11, 
//                     color: isDark ? Colors.grey.shade400 : Colors.grey.shade600
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     ),
//   );
// }


//   // Widget _buildReservationsList(List<dynamic> reservations, String type, bool isDark) {
//   //   if (reservations.isEmpty) {
//   //     return _buildEmptyState(type, isDark);
//   //   }

//   //   return RefreshIndicator(
//   //     onRefresh: _loadAllReservations,
//   //     color: AppColors.primary,
//   //     child: ListView.builder(
//   //       padding: EdgeInsets.all(MediaQuery.of(context).size.width < 600 ? 12 : 20),
//   //       itemCount: reservations.length,
//   //       itemBuilder: (context, index) {
//   //         return _buildModernReservationCard(reservations[index], type, isDark);
//   //       },
//   //     ),
//   //   );
//   // }
//   Widget _buildReservationsList(List<dynamic> reservations, String type, bool isDark) {
//   final sorted = _applySorting(reservations);

//   if (sorted.isEmpty) {
//     return _buildEmptyState(type, isDark);
//   }

//   return Column(
//     children: [
//       _buildSortBar(isDark),
//       Expanded(
//         child: RefreshIndicator(
//           onRefresh: _loadAllReservations,
//           color: AppColors.primary,
//           child: ListView.builder(
//             padding: EdgeInsets.all(
//                 MediaQuery.of(context).size.width < 600 ? 12 : 20),
//             itemCount: sorted.length,
//             itemBuilder: (context, index) =>
//                 _buildModernReservationCard(sorted[index], type, isDark),
//           ),
//         ),
//       ),
//     ],
//   );
// }

//   Widget _buildEmptyState(String type, bool isDark) {
//     final emptyStates = {
//       'pending': {'icon': Icons.hourglass_empty_rounded, 'message': 'لا توجد حجوزات معلقة'},
//       'validated': {'icon': Icons.check_circle_outline_rounded, 'message': 'لا توجد حجوزات مؤكدة'},
//       'cancelled': {'icon': Icons.cancel_outlined, 'message': 'لا توجد حجوزات ملغاة'},
//       'archived': {'icon': Icons.archive_outlined, 'message': 'لا توجد حجوزات في الأرشيف'},
//       'all': {'icon': Icons.event_note_outlined, 'message': 'لا توجد حجوزات'},
//     };

//     final state = emptyStates[type] ?? emptyStates['all']!;

//     return RefreshIndicator(
//       onRefresh: _loadAllReservations,
//       color: AppColors.primary,
//       child: SingleChildScrollView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         child: Container(
//           height: 400,
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(state['icon'] as IconData, size: 64, 
//                   color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
//                 const SizedBox(height: 16),
//                 Text(
//                   state['message'] as String,
//                   style: TextStyle(fontSize: 16, 
//                     color: isDark ? Colors.grey.shade400 : Colors.grey.shade500, 
//                     fontWeight: FontWeight.w500),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Widget _buildModernReservationCard(Map<String, dynamic> reservation, String type, bool isDark) {
//   //   final status = reservation['status'] ?? '';
//   //   final groomId = reservation['groom_id'] ?? 0;
//   //   final reservationId = reservation['id'] ?? 0;
//   //   final first_name = reservation['first_name'] ?? 'غير محدد';
//   //   final last_name = reservation['last_name'] ?? 'غير محدد';
//   //   final guardianName = reservation['guardian_name'] ?? 'غير محدد';
//   //   final fatherName = reservation['father_name'] ?? 'غير محدد';
//   //   final phoneNumber = reservation['phone_number'] ?? 'غير محدد';
//   //   final date1 = reservation['date1'] ?? '';
//   //   final date2 = reservation['date2'];
//   //   final date2Bool = reservation['date2_bool'] ?? false;
//   //   final isArchived = _isReservationArchived(reservation);


//   Widget _buildModernReservationCard(Map<String, dynamic> reservation, String type, bool isDark) {
//   // Use reservation status, but fall back to type for cancelled cards
//   final status = reservation['status'] ?? type;
//   final groomId = reservation['groom_id'] ?? 0;
//   final reservationId = reservation['id'] ?? 0;
//   final first_name = reservation['first_name'] ?? 'غير محدد';
//   final last_name = reservation['last_name'] ?? 'غير محدد';
//   final guardianName = reservation['guardian_name'] ?? 'غير محدد';
//   final fatherName = reservation['father_name'] ?? 'غير محدد';
//   final phoneNumber = reservation['phone_number'] ?? 'غير محدد';
//   final date1 = reservation['date1'] ?? '';
//   final date2 = reservation['date2'];
//   final date2Bool = reservation['date2_bool'] ?? false;
//   final isArchived = _isReservationArchived(reservation);

//     return Container(
//         margin: EdgeInsets.only(
//           bottom: MediaQuery.of(context).size.width < 600 ? 12 : 16
//         ),      decoration: BoxDecoration(
//         color: isDark ? AppColors.darkCard : Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Theme(
//         data: Theme.of(context).copyWith(
//           dividerColor: Colors.transparent,
//         ),
//         child: ExpansionTile(
//           tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//           childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
//           backgroundColor: isDark ? AppColors.darkCard : Colors.white,
//           collapsedBackgroundColor: isDark ? AppColors.darkCard : Colors.white,
//           iconColor: isDark ? Colors.white70 : Colors.black87,
//           collapsedIconColor: isDark ? Colors.white70 : Colors.black87,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           leading: CircleAvatar(
//             backgroundColor: isArchived 
//               ? Colors.purple.shade400.withOpacity(isDark ? 0.2 : 0.1)
//               : _getStatusColor(status).withOpacity(isDark ? 0.2 : 0.1),
//             child: Icon(
//               isArchived ? Icons.archive_rounded : _getStatusIcon(status), 
//               color: isArchived ? Colors.purple.shade400 : _getStatusColor(status), 
//               size: 20
//             ),
//           ),
//           title: Text(
//             '$first_name - $last_name',
//             style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, 
//               color: isDark ? Colors.white : Colors.black87),
//           ),
//           subtitle: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 4),
//               Row(
//                 children: [
//                   Icon(Icons.phone_rounded, size: 16, 
//                     color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
//                   const SizedBox(width: 4),
//                   Text(phoneNumber, 
//                     style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               Row(
//                 children: [
//                   Icon(Icons.calendar_today_rounded, size: 16, 
//                     color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
//                   const SizedBox(width: 4),
//                   Text(
//                     '${_formatDate(date1)}${date2Bool && date2 != null ? ' - ${_formatDate(date2)}' : ''}',
//                     style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   _buildModernStatusChip(status, isDark),
//                   if (isArchived) ...[
//                     const SizedBox(width: 8),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.purple.shade400.withOpacity(isDark ? 0.2 : 0.1),
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.purple.shade400.withOpacity(isDark ? 0.4 : 0.3)),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(Icons.archive_rounded, size: 12, color: Colors.purple.shade400),
//                           const SizedBox(width: 4),
//                           Text(
//                             'أرشيف',
//                             style: TextStyle(color: Colors.purple.shade400, fontWeight: FontWeight.w500, fontSize: 12),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ],
//           ),
//           children: [
//             _buildReservationDetails(reservation, status, groomId, reservationId, guardianName, isDark),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildReservationDetails(Map<String, dynamic> reservation, String status, int groomId, 
//       int reservationId, String guardianName, bool isDark) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: isDark ? AppColors.darkInputBackground : Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           ..._buildDetailRows(reservation, isDark),
//           const SizedBox(height: 16),
//           _buildModernActionButtons(reservation, status, groomId, reservationId, guardianName),
//         ],
//       ),
//     );
//   }


// // List<Widget> _buildDetailRows(Map<String, dynamic> reservation, bool isDark) {
// //   final screenWidth = MediaQuery.of(context).size.width;
// //   final labelWidth = screenWidth < 600 ? 100.0 : 140.0;
  
// //   final details = [
// //     ['رقم الحجز:', '${reservation['id'] ?? 0}'],
// //     ['اسم العريس (المستخدم):', reservation['first_name'] ?? 'غير محدد'],
// //     ['لقب العريس (المستخدم):', reservation['last_name'] ?? 'غير محدد'],
// //     ['اسم الولي:', reservation['guardian_name'] ?? 'غير محدد'],
// //     ['اسم الأب:', reservation['father_name'] ?? 'غير محدد'],
// //     ['رقم الهاتف:', reservation['phone_number'] ?? 'غير محدد'],
// //     ['اليوم الأول:', _formatDate(reservation['date1'])],
// //     if (reservation['date2_bool'] == true && reservation['date2'] != null)
// //       ['اليوم الثاني:', _formatDate(reservation['date2'])],
// //     ['حالة الدفع:', _getPaymentStatusText(reservation['payment_status'] ?? 'not_paid')],
// //     ['حفل جماعي:', reservation['join_to_mass_wedding'] == true ? 'نعم' : 'لا'],
// //     ['يسمح للآخرين:', reservation['allow_others'] == true ? 'نعم' : 'لا'],
// //     ['تاريخ الإنشاء:', _formatDateTime(reservation['created_at'])],
// //     if (reservation['expires_at'] != null)
// //       ['تاريخ الانتهاء:', _formatDateTime(reservation['expires_at'])],
// //   ];

// //   return details.map((detail) => Padding(
// //     padding: const EdgeInsets.only(bottom: 8),
// //     child:  Row(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             SizedBox(
// //               width: labelWidth,
// //               child: Text(detail[0], 
// //                 style: TextStyle(
// //                   fontWeight: FontWeight.w500, 
// //                   color: isDark ? Colors.grey.shade400 : Colors.grey.shade700
// //                 )
// //               ),
// //             ),
// //            Expanded(
// //   child: Text(detail[1], 
// //     style: TextStyle(
// //       color: detail[0] == 'حالة الدفع:' 
// //         ? _getPaymentStatusColor(reservation['payment_status'] ?? 'not_paid')
// //         : (isDark ? Colors.white70 : Colors.grey.shade800),
// //       fontWeight: detail[0] == 'حالة الدفع:' ? FontWeight.w600 : FontWeight.normal,
// //     )
// //   ),
// // ),
// //           ],
// //         ),
// //   )).toList();
// // }
//   Widget _buildModernStatusChip(String status, bool isDark) {
//     final color = _getStatusColor(status);
//     final displayText = _getStatusDisplayText(status);
    
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(isDark ? 0.2 : 0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(isDark ? 0.4 : 0.3)),
//       ),
//       child: Text(
//         displayText,
//         style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 12),
//       ),
//     );
//   }


// // Widget _buildModernActionButtons(Map<String, dynamic> reservation, String status, int groomId, int reservationId, String groomName) {
// //   List<Widget> buttons = [];
// //   final paymentValid = reservation['payment_valid'] ?? false;
// //   final screenWidth = MediaQuery.of(context).size.width;

// //   // Download PDF button
// //   buttons.add(
// //     _buildActionButton(
// //       onPressed: () => _downloadPdfSimple(reservationId),
// //       icon: Icons.download_rounded,
// //       label: 'تحميل PDF',
// //       color: Colors.blue.shade400,
// //       isCompact: screenWidth < 600,
// //     ),
// //   );

// //   // Status-specific buttons
// //   if (status == 'pending_validation') {
// //     buttons.add(
// //       _buildActionButton(
// //         onPressed: () => _togglePaymentStatus(reservationId, groomName, paymentValid),
// //         icon: paymentValid ? Icons.money_off_rounded : Icons.payment_rounded,
// //         label: paymentValid ? 'إلغاء الدفع' : 'تأكيد الدفع',
// //         color: paymentValid ? Colors.orange.shade400 : Colors.indigo.shade400,
// //         isCompact: screenWidth < 600,
// //       ),
// //     );
    
// //     buttons.add(
// //       _buildActionButton(
// //         onPressed: () => _validateReservation(groomId, groomName, paymentValid),
// //         icon: Icons.check_rounded,
// //         label: 'تأكيد',
// //         color: Colors.green.shade400,
// //         isCompact: screenWidth < 600,
// //       ),
// //     );
// //     buttons.add(
// //       _buildActionButton(
// //         onPressed: () => _cancelReservation(groomId, groomName),
// //         // onPressed:() async {
// //         //            // Check if tab requires access verification
// //         //   bool hasAccess = await _verifyAccessForTab();
          
// //         //   if (!hasAccess) {
// //         //     return; // Don't navigate if access is denied
// //         //   }
// //         //   _cancelReservation(groomId, groomName);
// //         // },
// //         icon: Icons.close_rounded,
// //         label: 'إلغاء',
// //         color: Colors.red.shade400,
// //         isCompact: screenWidth < 600,
// //       ),
// //     );
// //   } else if (status == 'validated') {
// //     buttons.add(
// //       _buildActionButton(
// //         onPressed: () => _togglePaymentStatus(reservationId, groomName, paymentValid),
// //         icon: paymentValid ? Icons.money_off_rounded : Icons.payment_rounded,
// //         label: paymentValid ? 'إلغاء الدفع' : 'تأكيد الدفع',
// //         color: paymentValid ? Colors.orange.shade400 : Colors.indigo.shade400,
// //         isCompact: screenWidth < 600,
// //       ),
// //     );
    
// //     buttons.add(
// //       _buildActionButton(
// //         // onPressed: () => _cancelReservation(groomId, groomName),
// //         onPressed:() async {
// //                    // Check if tab requires access verification
// //           bool hasAccess = await _verifyAccessForTab();
          
// //           if (!hasAccess) {
// //             return; // Don't navigate if access is denied
// //           }
// //           _cancelReservation(groomId, groomName);
// //         },
// //         icon: Icons.close_rounded,
// //         label: 'إلغاء',
// //         color: Colors.red.shade400,
// //         isCompact: screenWidth < 600,
// //       ),
// //     );
// //   }

// //   return Wrap(
// //     spacing: 8,
// //     runSpacing: 8,
// //     alignment: screenWidth < 600 ? WrapAlignment.center : WrapAlignment.start,
// //     children: buttons,
// //   );
// // }

// // Widget _buildModernActionButtons(Map<String, dynamic> reservation, String status, int groomId, int reservationId, String groomName) {
// //   List<Widget> buttons = [];
// //   final paymentStatus = reservation['payment_status'] ?? 'not_paid';
// //   final currentPayment = double.tryParse(reservation['payment']?.toString() ?? '0') ?? 0.0;  
// //   final requiredPayment = double.tryParse(reservation['required_payment']?.toString() ?? '0') ?? 0.0; // You'll need to add this to your reservation data
// //   final screenWidth = MediaQuery.of(context).size.width;

// //   // Download PDF button
// //   buttons.add(
// //     _buildActionButton(
// //       onPressed: () => _downloadPdfSimple(reservationId),
// //       icon: Icons.download_rounded,
// //       label: 'تحميل PDF',
// //       color: Colors.blue.shade400,
// //       isCompact: screenWidth < 600,
// //     ),
// //   );

// //   // Status-specific buttons
// //   if (status == 'pending_validation') {
// //     buttons.add(
// //       _buildActionButton(
// //         onPressed: () => _togglePaymentStatus(reservationId, groomName, paymentStatus, currentPayment, requiredPayment),
// //         icon: _getPaymentStatusIcon(paymentStatus),
// //         label: 'تحديث الدفع',
// //         color: _getPaymentStatusColor(paymentStatus),
// //         isCompact: screenWidth < 600,
// //       ),
// //     );
    
// //     buttons.add(
// //       _buildActionButton(
// //         onPressed: () => _validateReservation(reservationId, groomName, paymentStatus != 'not_paid'),
// //         icon: Icons.check_rounded,
// //         label: 'تأكيد',
// //         color: Colors.green.shade400,
// //         isCompact: screenWidth < 600,
// //       ),
// //     );
// //     buttons.add(
// //       _buildActionButton(
// //         onPressed: () => _cancelReservation(reservationId, groomName),
// //         icon: Icons.close_rounded,
// //         label: 'إلغاء',
// //         color: Colors.red.shade400,
// //         isCompact: screenWidth < 600,
// //       ),
// //     );
// //   } else if (status == 'validated') {
// //     buttons.add(
// //       _buildActionButton(
// //         onPressed: () => _togglePaymentStatus(reservationId, groomName, paymentStatus, currentPayment, requiredPayment),
// //         icon: _getPaymentStatusIcon(paymentStatus),
// //         label: 'تحديث الدفع',
// //         color: _getPaymentStatusColor(paymentStatus),
// //         isCompact: screenWidth < 600,
// //       ),
// //     );
    
// //     buttons.add(
// //       _buildActionButton(
// //         onPressed: () async {
// //           _cancelReservation(reservationId, groomName);
// //         },
// //         icon: Icons.close_rounded,
// //         label: 'إلغاء',
// //         color: Colors.red.shade400,
// //         isCompact: screenWidth < 600,
// //       ),
// //     );
// //   }

// //   return Wrap(
// //     spacing: 8,
// //     runSpacing: 8,
// //     alignment: screenWidth < 600 ? WrapAlignment.center : WrapAlignment.start,
// //     children: buttons,
// //   );
// // }


// // Widget _buildModernActionButtons(Map<String, dynamic> reservation, String status, int groomId, int reservationId, String groomName) {
// //   List<Widget> buttons = [];
// //   final paymentStatus = reservation['payment_status'] ?? 'not_paid';
// //   final currentPayment = double.tryParse(reservation['payment']?.toString() ?? '0') ?? 0.0;
// //   final requiredPayment = double.tryParse(reservation['required_payment']?.toString() ?? '0') ?? 0.0;
// //   final screenWidth = MediaQuery.of(context).size.width;
// //   final currentDate = reservation['date1'] ?? '';

// //   // // Download PDF — always shown
// //   // buttons.add(
// //   //   _buildActionButton(
// //   //     onPressed: () => _downloadPdfSimple(reservationId),
// //   //     icon: Icons.download_rounded,
// //   //     label: 'تحميل PDF',
// //   //     color: Colors.blue.shade400,
// //   //     isCompact: screenWidth < 600,
// //   //   ),
// //   // );

// //   if (status == 'pending_validation') {
// //     buttons.add(
// //       _buildActionButton(
// //         onPressed: () => _togglePaymentStatus(reservationId, groomName, paymentStatus, currentPayment, requiredPayment),
// //         icon: _getPaymentStatusIcon(paymentStatus),
// //         label: 'تحديث الدفع',
// //         color: _getPaymentStatusColor(paymentStatus),
// //         isCompact: screenWidth < 600,
// //       ),
// //     );
// //     buttons.add(
// //       _buildActionButton(
// //         onPressed: () => _showUpdateDateDialog(reservationId, groomName, currentDate), // NEW
// //         icon: Icons.edit_calendar_rounded,
// //         label: 'تعديل التاريخ',
// //         color: Colors.indigo.shade400,
// //         isCompact: screenWidth < 600,
// //       ),
// //     );
// //     buttons.add(
// //       _buildActionButton(
// //         onPressed: () => _validateReservation(reservationId, groomName, paymentStatus != 'not_paid'),
// //         icon: Icons.check_rounded,
// //         label: 'تأكيد',
// //         color: Colors.green.shade400,
// //         isCompact: screenWidth < 600,
// //       ),
// //     );
// //     buttons.add(
// //       _buildActionButton(
// //         onPressed: () => _cancelReservation(reservationId, groomName),
// //         icon: Icons.close_rounded,
// //         label: 'إلغاء',
// //         color: Colors.red.shade400,
// //         isCompact: screenWidth < 600,
// //       ),
// //     );
// //   } else if (status == 'validated') {
// //     buttons.add(
// //       _buildActionButton(
// //         onPressed: () => _togglePaymentStatus(reservationId, groomName, paymentStatus, currentPayment, requiredPayment),
// //         icon: _getPaymentStatusIcon(paymentStatus),
// //         label: 'تحديث الدفع',
// //         color: _getPaymentStatusColor(paymentStatus),
// //         isCompact: screenWidth < 600,
// //       ),
// //     );
// //     buttons.add(
// //       _buildActionButton(
// //         onPressed: () => _showUpdateDateDialog(reservationId, groomName, currentDate), // NEW
// //         icon: Icons.edit_calendar_rounded,
// //         label: 'تعديل التاريخ',
// //         color: Colors.indigo.shade400,
// //         isCompact: screenWidth < 600,
// //       ),
// //     );
// //     buttons.add(
// //       _buildActionButton(
// //         onPressed: () => _cancelReservation(reservationId, groomName),
// //         icon: Icons.close_rounded,
// //         label: 'إلغاء',
// //         color: Colors.red.shade400,
// //         isCompact: screenWidth < 600,
// //       ),
// //     );
// //   } else if (status == 'cancelled') {
// //     buttons.add(
// //       _buildActionButton(
// //         onPressed: () => _validateReservationFromCancelledTab(reservationId, groomName, paymentStatus != 'not_paid'),
// //         icon: Icons.restore_rounded,
// //         label: 'استعادة',
// //         color: Colors.amber.shade900,
// //         isCompact: screenWidth < 600,
// //       ),
// //     );
// //     buttons.add(
// //       _buildActionButton(
// //         onPressed: () => _showUpdateDateDialog(reservationId, groomName, currentDate), // NEW
// //         icon: Icons.edit_calendar_rounded,
// //         label: 'تعديل التاريخ',
// //         color: Colors.indigo.shade400,
// //         isCompact: screenWidth < 600,
// //       ),
// //     );
// //   }

// //   return Wrap(
// //     spacing: 8,
// //     runSpacing: 8,
// //     alignment: screenWidth < 600 ? WrapAlignment.center : WrapAlignment.start,
// //     children: buttons,
// //   );
// // }

// // Widget _buildModernActionButtons(Map<String, dynamic> reservation, String status, int groomId, int reservationId, String groomName) {
// //   List<Widget> buttons = [];
// //   final paymentStatus = reservation['payment_status'] ?? 'not_paid';
// //   final currentPayment = double.tryParse(reservation['payment']?.toString() ?? '0') ?? 0.0;
// //   final requiredPayment = double.tryParse(reservation['required_payment']?.toString() ?? '0') ?? 0.0;
// //   final screenWidth = MediaQuery.of(context).size.width;
// //   final isCompact = screenWidth < 600;
// //   final currentDate = reservation['date1'] ?? '';

// //   // WhatsApp buttons — always shown if phones exist
// //   final groomPhone = reservation['phone_number'] ?? '';
// //   final guardianPhone = reservation['guardian_phone'] ?? '';
// //   buttons.add(_whatsAppBtn(groomPhone, 'العريس', isCompact));
// //   buttons.add(_whatsAppBtn(guardianPhone, 'الولي', isCompact));

// //   if (status == 'pending_validation') {
// //     buttons.add(
// //       _buildActionButton(
// //         onPressed: () => _togglePaymentStatus(reservationId, groomName, paymentStatus, currentPayment, requiredPayment),
// //         icon: _getPaymentStatusIcon(paymentStatus),
// //         label: 'تحديث الدفع',
// //         color: _getPaymentStatusColor(paymentStatus),
// //         isCompact: isCompact,
// //       ),
// //     );
// //     buttons.add(
// //       _buildActionButton(
// //         onPressed: () => _showUpdateDateDialog(reservationId, groomName, currentDate),
// //         icon: Icons.edit_calendar_rounded,
// //         label: 'تعديل التاريخ',
// //         color: Colors.indigo.shade400,
// //         isCompact: isCompact,
// //       ),
// //     );
// //     buttons.add(
// //       _buildActionButton(
// //         onPressed: () => _validateReservation(reservationId, groomName, paymentStatus != 'not_paid'),
// //         icon: Icons.check_rounded,
// //         label: 'تأكيد',
// //         color: Colors.green.shade400,
// //         isCompact: isCompact,
// //       ),
// //     );
// //     buttons.add(
// //       _buildActionButton(
// //         onPressed: () => _cancelReservation(reservationId, groomName),
// //         icon: Icons.close_rounded,
// //         label: 'إلغاء',
// //         color: Colors.red.shade400,
// //         isCompact: isCompact,
// //       ),
// //     );
// //   } else if (status == 'validated') {
// //     buttons.add(
// //       _buildActionButton(
// //         onPressed: () => _togglePaymentStatus(reservationId, groomName, paymentStatus, currentPayment, requiredPayment),
// //         icon: _getPaymentStatusIcon(paymentStatus),
// //         label: 'تحديث الدفع',
// //         color: _getPaymentStatusColor(paymentStatus),
// //         isCompact: isCompact,
// //       ),
// //     );
// //     buttons.add(
// //       _buildActionButton(
// //         onPressed: () => _showUpdateDateDialog(reservationId, groomName, currentDate),
// //         icon: Icons.edit_calendar_rounded,
// //         label: 'تعديل التاريخ',
// //         color: Colors.indigo.shade400,
// //         isCompact: isCompact,
// //       ),
// //     );
// //     buttons.add(
// //       _buildActionButton(
// //         onPressed: () => _cancelReservation(reservationId, groomName),
// //         icon: Icons.close_rounded,
// //         label: 'إلغاء',
// //         color: Colors.red.shade400,
// //         isCompact: isCompact,
// //       ),
// //     );
// //   } else if (status == 'cancelled') {
// //     buttons.add(
// //       _buildActionButton(
// //         onPressed: () => _validateReservationFromCancelledTab(reservationId, groomName, paymentStatus != 'not_paid'),
// //         icon: Icons.restore_rounded,
// //         label: 'استعادة',
// //         color: Colors.amber.shade900,
// //         isCompact: isCompact,
// //       ),
// //     );
// //     buttons.add(
// //       _buildActionButton(
// //         onPressed: () => _showUpdateDateDialog(reservationId, groomName, currentDate),
// //         icon: Icons.edit_calendar_rounded,
// //         label: 'تعديل التاريخ',
// //         color: Colors.indigo.shade400,
// //         isCompact: isCompact,
// //       ),
// //     );
// //   }

// //   return Wrap(
// //     spacing: 8,
// //     runSpacing: 8,
// //     alignment: isCompact ? WrapAlignment.center : WrapAlignment.start,
// //     children: buttons,
// //   );
// // }

// Widget _buildModernActionButtons(Map<String, dynamic> reservation, String status, int groomId, int reservationId, String groomName) {
//   List<Widget> buttons = [];
//   final paymentStatus = reservation['payment_status'] ?? 'not_paid';
//   final currentPayment = double.tryParse(reservation['payment']?.toString() ?? '0') ?? 0.0;
//   final requiredPayment = double.tryParse(reservation['required_payment']?.toString() ?? '0') ?? 0.0;
//   final screenWidth = MediaQuery.of(context).size.width;
//   final isCompact = screenWidth < 600;
//   final currentDate = reservation['date1'] ?? '';
//   final isArchived = _isReservationArchived(reservation);

//   // WhatsApp buttons — always shown if phones exist
//   final groomPhone = reservation['phone_number'] ?? '';
//   final guardianPhone = reservation['guardian_phone'] ?? '';
//   buttons.add(_whatsAppBtn(groomPhone, 'العريس', isCompact));
//   buttons.add(_whatsAppBtn(guardianPhone, 'الولي', isCompact));

//   if (status == 'pending_validation') {
//     buttons.add(
//       _buildActionButton(
//         onPressed: () => _togglePaymentStatus(reservationId, groomName, paymentStatus, currentPayment, requiredPayment),
//         icon: _getPaymentStatusIcon(paymentStatus),
//         label: 'تحديث الدفع',
//         color: _getPaymentStatusColor(paymentStatus),
//         isCompact: isCompact,
//       ),
//     );
//     buttons.add(
//       _buildActionButton(
//         onPressed: () => _showUpdateDateDialog(reservationId, groomName, currentDate),
//         icon: Icons.edit_calendar_rounded,
//         label: 'تعديل التاريخ',
//         color: Colors.indigo.shade400,
//         isCompact: isCompact,
//       ),
//     );
//     buttons.add(
//       _buildActionButton(
//         onPressed: () => _validateReservation(reservationId, groomName, paymentStatus != 'not_paid'),
//         icon: Icons.check_rounded,
//         label: 'تأكيد',
//         color: Colors.green.shade400,
//         isCompact: isCompact,
//       ),
//     );
//     buttons.add(
//       _buildActionButton(
//         onPressed: () => _cancelReservation(reservationId, groomName),
//         icon: Icons.close_rounded,
//         label: 'إلغاء',
//         color: Colors.red.shade400,
//         isCompact: isCompact,
//       ),
//     );
//   } else if (status == 'validated') {
//     buttons.add(
//       _buildActionButton(
//         onPressed: () => _togglePaymentStatus(reservationId, groomName, paymentStatus, currentPayment, requiredPayment),
//         icon: _getPaymentStatusIcon(paymentStatus),
//         label: 'تحديث الدفع',
//         color: _getPaymentStatusColor(paymentStatus),
//         isCompact: isCompact,
//       ),
//     );
//     buttons.add(
//       _buildActionButton(
//         onPressed: () => _showUpdateDateDialog(reservationId, groomName, currentDate),
//         icon: Icons.edit_calendar_rounded,
//         label: 'تعديل التاريخ',
//         color: Colors.indigo.shade400,
//         isCompact: isCompact,
//       ),
//     );
//     buttons.add(
//       _buildActionButton(
//         onPressed: () => _cancelReservation(reservationId, groomName),
//         icon: Icons.close_rounded,
//         label: 'إلغاء',
//         color: Colors.red.shade400,
//         isCompact: isCompact,
//       ),
//     );
//   } else if (status == 'cancelled') {
//     buttons.add(
//       _buildActionButton(
//         onPressed: () => _validateReservationFromCancelledTab(reservationId, groomName, paymentStatus != 'not_paid'),
//         icon: Icons.restore_rounded,
//         label: 'استعادة',
//         color: Colors.amber.shade900,
//         isCompact: isCompact,
//       ),
//     );
//     buttons.add(
//       _buildActionButton(
//         onPressed: () => _showUpdateDateDialog(reservationId, groomName, currentDate),
//         icon: Icons.edit_calendar_rounded,
//         label: 'تعديل التاريخ',
//         color: Colors.indigo.shade400,
//         isCompact: isCompact,
//       ),
//     );
//     buttons.add(
//       _buildActionButton(
//         onPressed: () => _deleteReservation(reservationId, groomName),
//         icon: Icons.delete_forever_rounded,
//         label: 'حذف',
//         color: Colors.red.shade700,
//         isCompact: isCompact,
//       ),
//     );
//   }

//   // Show delete for archived reservations regardless of status
//   if (isArchived) {
//     buttons.add(
//       _buildActionButton(
//         onPressed: () => _deleteReservation(reservationId, groomName),
//         icon: Icons.delete_forever_rounded,
//         label: 'حذف',
//         color: Colors.red.shade700,
//         isCompact: isCompact,
//       ),
//     );
//   }

//   return Wrap(
//     spacing: 8,
//     runSpacing: 8,
//     alignment: isCompact ? WrapAlignment.center : WrapAlignment.start,
//     children: buttons,
//   );
// }
// Widget _buildActionButton({
//   required VoidCallback onPressed,
//   required IconData icon,
//   required String label,
//   required Color color,
//   bool isCompact = false,
// }) {
//   return ElevatedButton.icon(
//     onPressed: onPressed,
//     icon: Icon(icon, size: isCompact ? 16 : 18),
//     label: Text(
//       label,
//       style: TextStyle(fontSize: isCompact ? 12 : 14),
//     ),
//     style: ElevatedButton.styleFrom(
//       backgroundColor: color,
//       foregroundColor: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       padding: EdgeInsets.symmetric(
//         horizontal: isCompact ? 12 : 16, 
//         vertical: isCompact ? 6 : 8
//       ),
//       elevation: 0,
//     ),
//   );
// }


//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'pending_validation':
//         return Colors.orange.shade400;
//       case 'validated':
//         return Colors.green.shade400;
//       case 'cancelled':
//         return Colors.red.shade400;
//       default:
//         return Colors.grey.shade400;
//     }
//   }

//   IconData _getStatusIcon(String status) {
//     switch (status.toLowerCase()) {
//       case 'pending_validation':
//         return Icons.hourglass_empty_rounded;
//       case 'validated':
//         return Icons.check_circle_rounded;
//       case 'cancelled':
//         return Icons.cancel_rounded;
//       default:
//         return Icons.event_note_rounded;
//     }
//   }

//   String _getStatusDisplayText(String status) {
//     switch (status.toLowerCase()) {
//       case 'pending_validation':
//         return 'معلق';
//       case 'validated':
//         return 'مؤكد';
//       case 'cancelled':
//         return 'ملغي';
//       default:
//         return status;
//     }
//   }

//   String _formatDate(String? dateString) {
//     if (dateString == null || dateString.isEmpty) return 'غير محدد';
//     try {
//       final date = DateTime.parse(dateString);
//       return DateFormat('yyyy/MM/dd', 'fr').format(date);
//     } catch (e) {
//       return dateString;
//     }
//   }

//   String _formatDateTime(String? dateTimeString) {
//     if (dateTimeString == null || dateTimeString.isEmpty) return 'غير محدد';
//     try {
//       final dateTime = DateTime.parse(dateTimeString);
//       return DateFormat('yyyy/MM/dd HH:mm', 'fr').format(dateTime);
//     } catch (e) {
//       return dateTimeString;
//     }
//   }

// Widget _buildNotBelongReservationsPage(bool isDark) {
//   final allPending = _notBelongPendingReservations
//       .map((r) => Map<String, dynamic>.from({...r as Map, '_nb_status': 'pending'}))
//       .toList();
//   final allValidated = _notBelongValidatedReservations
//       .map((r) => Map<String, dynamic>.from({...r as Map, '_nb_status': 'validated'}))
//       .toList();
//   final allNotBelong = [...allValidated, ...allPending];
// final allCancelled = _notBelongCancelledReservations
//       .map((r) => Map<String, dynamic>.from({...r as Map, '_nb_status': 'cancelled'}))
//       .toList();

//   final allArchived = _notBelongArchivedReservations
//       .map((r) => Map<String, dynamic>.from(r as Map))
//       .toList();
//   final allActive = [...allValidated, ...allPending]
//       .where((r) => !_isReservationArchived(r))
//       .toList();
//   final allActiveValidated = allValidated
//       .where((r) => !_isReservationArchived(r))
//       .toList();
//   final allActivePending = allPending
//       .where((r) => !_isReservationArchived(r))
//       .toList();

//   List<Map<String, dynamic>> applySearch(List<Map<String, dynamic>> list) {
//     if (_searchQuery.isEmpty) return list;
//     final q = _searchQuery.toLowerCase();
//     return list.where((r) {
//       return (r['first_name']?.toString().toLowerCase() ?? '').contains(q) ||
//           (r['last_name']?.toString().toLowerCase() ?? '').contains(q) ||
//           (r['guardian_name']?.toString().toLowerCase() ?? '').contains(q) ||
//           (r['phone_number']?.toString() ?? '').contains(q);
//     }).toList();
//   }

//   final filteredAll = applySearch(allActive);
//   final filteredValidated = applySearch(allActiveValidated);
//   final filteredPending = applySearch(allActivePending);
//   final filteredCancelled = applySearch(allCancelled);
//   final filteredArchived = applySearch(allArchived);

//   return DefaultTabController(
//     length: 5,
//     child: Column(
//       children: [
//         // Header banner
//         Container(
//           margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
//           padding: const EdgeInsets.all(14),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.purple.shade600, Colors.purple.shade800],
//             ),
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(Icons.swap_horiz, color: Colors.white, size: 22),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'أتو من خارج العشيرة',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 15,
//                           fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       'عرسان من عشائر أخرى يحجزون في قاعات عشيرتنا',
//                       style: TextStyle(
//                           color: Colors.white.withOpacity(0.85), fontSize: 11),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // Inner tabs
//         Container(
//           color: isDark ? AppColors.darkCard : Colors.white,
//           margin: const EdgeInsets.only(top: 8),
//           child: TabBar(
//             isScrollable: true,
//             tabAlignment: TabAlignment.start,
//             indicatorColor: Colors.purple.shade400,
//             labelColor: Colors.purple.shade400,
//             unselectedLabelColor:
//                 isDark ? Colors.grey.shade400 : Colors.grey.shade600,
//             labelStyle: TextStyle(
//               fontWeight: FontWeight.w600,
//               fontSize: MediaQuery.of(context).size.width < 600 ? 11 : 13,
//             ),
//             tabs: [
//               Tab(text: 'الكل (${filteredAll.length})'),
//               Tab(text: 'مؤكدة (${filteredValidated.length})'),
//               Tab(text: 'معلقة (${filteredPending.length})'),
//               Tab(text: 'ملغاة (${filteredCancelled.length})'),
//               Tab(text: 'أرشيف (${filteredArchived.length})'),
//             ],
//           ),
//         ),

//         Expanded(
//           child: TabBarView(
//             children: [
//               _buildNotBelongList(filteredAll, isDark),
//               _buildNotBelongList(filteredValidated, isDark),
//               _buildNotBelongList(filteredPending, isDark),
//               _buildNotBelongList(filteredCancelled, isDark),
//               _buildNotBelongList(filteredArchived, isDark),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }

// // Widget _buildNotBelongList(List<Map<String, dynamic>> items, bool isDark) {
// //   if (items.isEmpty) {
// //     return RefreshIndicator(
// //       onRefresh: _loadAllReservations,
// //       color: AppColors.primary,
// //       child: SingleChildScrollView(
// //         physics: const AlwaysScrollableScrollPhysics(),
// //         child: SizedBox(
// //           height: 350,
// //           child: Center(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Icon(Icons.swap_horiz, size: 56,
// //                     color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
// //                 const SizedBox(height: 12),
// //                 Text(
// //                   'لا توجد حجوزات',
// //                   style: TextStyle(
// //                     fontSize: 15,
// //                     color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
// //                     fontWeight: FontWeight.w500,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   return RefreshIndicator(
// //     onRefresh: _loadAllReservations,
// //     color: AppColors.primary,
// //     child: ListView.builder(
// //       padding: EdgeInsets.all(MediaQuery.of(context).size.width < 600 ? 12 : 16),
// //       itemCount: items.length,
// //       itemBuilder: (context, index) => _buildNotBelongReservationCard(items[index], isDark),
// //     ),
// //   );
// // }

// Widget _buildNotBelongList(List<Map<String, dynamic>> items, bool isDark) {
//   final sorted = _applySorting(items).cast<Map<String, dynamic>>();

//   if (sorted.isEmpty) {
//     return RefreshIndicator(
//       onRefresh: _loadAllReservations,
//       color: AppColors.primary,
//       child: SingleChildScrollView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         child: SizedBox(
//           height: 350,
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.swap_horiz,
//                     size: 56,
//                     color:
//                         isDark ? Colors.grey.shade700 : Colors.grey.shade300),
//                 const SizedBox(height: 12),
//                 Text(
//                   'لا توجد حجوزات',
//                   style: TextStyle(
//                     fontSize: 15,
//                     color: isDark
//                         ? Colors.grey.shade400
//                         : Colors.grey.shade500,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   return Column(
//     children: [
//       _buildSortBar(isDark),
//       Expanded(
//         child: RefreshIndicator(
//           onRefresh: _loadAllReservations,
//           color: AppColors.primary,
//           child: ListView.builder(
//             padding: EdgeInsets.all(
//                 MediaQuery.of(context).size.width < 600 ? 12 : 16),
//             itemCount: sorted.length,
//             itemBuilder: (context, index) =>
//                 _buildNotBelongReservationCard(sorted[index], isDark),
//           ),
//         ),
//       ),
//     ],
//   );
// }


// Widget _buildNotBelongStatCard(
//     String label, int count, Color color, IconData icon, bool isDark) {
//   return Container(
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: color.withOpacity(isDark ? 0.2 : 0.1),
//       borderRadius: BorderRadius.circular(12),
//       border: Border.all(color: color.withOpacity(0.3)),
//     ),
//     child: Row(
//       children: [
//         Icon(icon, color: color, size: 28),
//         const SizedBox(width: 12),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               '$count',
//               style: TextStyle(
//                   fontSize: 22, fontWeight: FontWeight.bold, color: color),
//             ),
//             Text(
//               label,
//               style: TextStyle(
//                   fontSize: 12,
//                   color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
// }

// Widget _buildNotBelongReservationCard(Map<String, dynamic> reservation, bool isDark) {
//   final nbStatus = reservation['_nb_status'] ?? 'pending';
//   final isCancelled = nbStatus == 'cancelled';
//   final isValidated = nbStatus == 'validated';

//   final statusColor = isCancelled
//       ? Colors.red.shade400
//       : isValidated
//           ? Colors.green.shade400
//           : Colors.orange.shade400;
//   final statusLabel = isCancelled ? 'ملغي' : isValidated ? 'مؤكد' : 'معلق';
//   final statusIcon = isCancelled
//       ? Icons.cancel_rounded
//       : isValidated
//           ? Icons.check_circle_rounded
//           : Icons.hourglass_empty_rounded;

//   final groomData = reservation['groom'] ?? {};
//   final firstName = groomData['first_name'] ?? reservation['first_name'] ?? 'غير محدد';
//   final lastName = groomData['last_name'] ?? reservation['last_name'] ?? '';
//   final fatherName = groomData['father_name'] ?? reservation['father_name'] ?? '';
//   final phone = groomData['phone_number'] ?? reservation['phone_number'] ?? '';
//   final guardianName = reservation['guardian_name'] ?? '';
//   final guardianPhone = reservation['guardian_phone'] ?? '';
//   final date1 = reservation['date1'] ?? '';
//   final date2 = reservation['date2'];
//   final date2Bool = reservation['date2_bool'] ?? false;
//   final reservationId = reservation['id'] ?? 0;
//   final groomId = reservation['groom_id'] ?? 0;

//   return Container(
//     margin: const EdgeInsets.only(bottom: 14),
//     decoration: BoxDecoration(
//       color: isDark ? AppColors.darkCard : Colors.white,
//       borderRadius: BorderRadius.circular(20),
//       border: Border.all(color: Colors.purple.shade200, width: 1.5),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.purple.withOpacity(0.08),
//           blurRadius: 10,
//           offset: const Offset(0, 3),
//         ),
//       ],
//     ),
//     child: Theme(
//       data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//       child: ExpansionTile(
//         tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//         childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
//         backgroundColor: isDark ? AppColors.darkCard : Colors.white,
//         collapsedBackgroundColor: isDark ? AppColors.darkCard : Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         leading: CircleAvatar(
//           backgroundColor: Colors.purple.shade100,
//           child: Icon(Icons.swap_horiz, color: Colors.purple.shade700, size: 20),
//         ),
//         title: Row(
//           children: [
//             Expanded(
//               child: Text(
//                 '$firstName $lastName',
//                 style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 16,
//                     color: isDark ? Colors.white : Colors.black87),
//               ),
//             ),
//           ],
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 4),
//             if (phone.isNotEmpty)
//               Row(
//                 children: [
//                   Icon(Icons.phone_rounded, size: 14,
//                       color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
//                   const SizedBox(width: 4),
//                   Text(phone,
//                       style: TextStyle(
//                           color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
//                           fontSize: 13)),
//                 ],
//               ),
//             const SizedBox(height: 4),
//             Row(
//               children: [
//                 Icon(Icons.calendar_today_rounded, size: 14,
//                     color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
//                 const SizedBox(width: 4),
//                 Text(
//                   '${_formatDate(date1)}${date2Bool && date2 != null ? ' - ${_formatDate(date2)}' : ''}',
//                   style: TextStyle(
//                       color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
//                       fontSize: 13),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                   decoration: BoxDecoration(
//                     color: Colors.purple.shade100,
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(color: Colors.purple.shade300),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.swap_horiz, size: 12, color: Colors.purple.shade700),
//                       const SizedBox(width: 4),
//                       Text('عشيرة أخرى',
//                           style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
//                               color: Colors.purple.shade700)),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                   decoration: BoxDecoration(
//                     color: statusColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(color: statusColor.withOpacity(0.4)),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(statusIcon, size: 12, color: statusColor),
//                       const SizedBox(width: 4),
//                       Text(statusLabel,
//                           style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
//                               color: statusColor)),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//        children: [
//   Container(
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: isDark ? AppColors.darkInputBackground : Colors.grey.shade50,
//       borderRadius: BorderRadius.circular(12),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Clan info
//         if (reservationId != null)
//           FutureBuilder<Map<String, dynamic>?>(
//             future: _getClanInfo(reservationId),
//             builder: (context, snapshot) {
//               if (!snapshot.hasData) return const SizedBox.shrink();
//               final clanInfo = snapshot.data!;
//               return Container(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.purple.shade50,
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: Colors.purple.shade200),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.groups, color: Colors.purple.shade600, size: 20),
//                     const SizedBox(width: 10),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('العشيرة الأصلية للعريس',
//                             style: TextStyle(
//                                 fontSize: 11,
//                                 color: Colors.purple.shade400,
//                                 fontWeight: FontWeight.w500)),
//                         Text(
//                           clanInfo['clan_name'] ?? 'غير محدد',
//                           style: TextStyle(
//                               fontSize: 15,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.purple.shade800),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),

//         // Details
//         _buildDetailRow('الاسم الكامل:', '$firstName $lastName', isDark),
//         if (fatherName.isNotEmpty)
//           _buildDetailRow('اسم الأب:', fatherName, isDark),
//         if (phone.isNotEmpty)
//           _buildDetailRow('رقم الهاتف:', phone, isDark),
//         if (guardianName.isNotEmpty)
//           _buildDetailRow('ولي الأمر:', guardianName, isDark),
//         if (guardianPhone.isNotEmpty)
//           _buildDetailRow('هاتف الولي:', guardianPhone, isDark),
//         _buildDetailRow('اليوم الأول:', _formatDate(date1), isDark),
//         if (date2Bool && date2 != null)
//           _buildDetailRow('اليوم الثاني:', _formatDate(date2), isDark),
//         _buildDetailRow('حالة الحجز:', statusLabel, isDark, valueColor: statusColor),
//         _buildDetailRow(
//           'حالة الدفع:',
//           _getPaymentStatusText(reservation['payment_status'] ?? 'not_paid'),
//           isDark,
//           valueColor: _getPaymentStatusColor(reservation['payment_status'] ?? 'not_paid'),
//         ),
//         if (reservation['allow_others'] != null)
//           _buildDetailRow(
//             'يسمح للآخرين:',
//             reservation['allow_others'] == true ? 'نعم' : 'لا',
//             isDark,
//           ),
//         // const SizedBox(height: 16),
//         // // ACTION BUTTONS
//         // _buildModernActionButtons(
//         //   reservation,
//         //   nbStatus == 'validated' ? 'validated' : 'pending_validation',
//         //   (reservation['groom']?['id'] ?? reservation['groom_id'] ?? 0) as int,
//         //   reservationId as int,
//         //   '$firstName $lastName',
//         // ),
//         const SizedBox(height: 16),
//         _buildModernActionButtons(
//           {
//             ...reservation,
//             'phone_number': phone,
//             'guardian_phone': guardianPhone,
//           },
//           isCancelled ? 'cancelled' : isValidated ? 'validated' : 'pending_validation',
//           (reservation['groom']?['id'] ?? reservation['groom_id'] ?? 0) as int,
//           reservationId as int,
//           '$firstName $lastName',
//         ),
//       ],
//     ),
//   ),
// ],
//       ),
//     ),
//   );
// }
// // Helper for detail rows in not-belong card
// Widget _buildDetailRow(String label, String value, bool isDark, {Color? valueColor}) {
//   return Padding(
//     padding: const EdgeInsets.only(bottom: 8),
//     child: Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           width: 120,
//           child: Text(
//             label,
//             style: TextStyle(
//               fontWeight: FontWeight.w500,
//               color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
//               fontSize: 13,
//             ),
//           ),
//         ),
//         Expanded(
//           child: Text(
//             value,
//             style: TextStyle(
//               color: valueColor ?? (isDark ? Colors.white70 : Colors.grey.shade800),
//               fontWeight: valueColor != null ? FontWeight.w600 : FontWeight.normal,
//               fontSize: 13,
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }



// Future<Map<String, dynamic>?> _getClanInfo(int reservationId) async {
//   try {
//     // Step 1: get the groom's original clan_id using reservation id
//     final clanId = await ApiService.getUserClanIdByReservation(reservationId);
//     if (clanId == null) return null;

//     // Step 2: get clan name from all clans
//     final clans = await ApiService.getAllClans();
//     final clan = clans.firstWhere(
//       (c) => c.id == clanId,
//       orElse: () => throw Exception('Clan not found'),
//     );
//     return {'clan_id': clan.id, 'clan_name': clan.name};
//   } catch (e) {
//     print('Error getting clan info: $e');
//     return null;
//   }
// }

// Widget _buildBelongOutsideReservationsPage(bool isDark) {
//   final allPending = _belongPendingOutsideReservations
//       .map((r) => Map<String, dynamic>.from({...r as Map, '_nb_status': 'pending'}))
//       .toList();
//   final allValidated = _belongValidatedOutsideReservations
//       .map((r) => Map<String, dynamic>.from({...r as Map, '_nb_status': 'validated'}))
//       .toList();
//   final allBelongOutside = [...allValidated, ...allPending];

//   // REMOVE this line:
//   // final allCancelled = allBelongOutside
//   //     .where((r) => (r['status'] ?? '') == 'cancelled')
//   //     .toList();

//   final allCancelled = _belongCancelledOutsideReservations
//       .map((r) => Map<String, dynamic>.from({...r as Map, '_nb_status': 'cancelled'}))
//       .toList();

//   final allArchived = _belongArchivedOutsideReservations
//       .map((r) => Map<String, dynamic>.from(r as Map))
//       .toList();  
//   final allActive = [...allValidated, ...allPending]
//       .where((r) => !_isReservationArchived(r))
//       .toList();
//   final allActiveValidated = allValidated
//       .where((r) => !_isReservationArchived(r))
//       .toList();
//   final allActivePending = allPending
//       .where((r) => !_isReservationArchived(r))
//       .toList();

//   List<Map<String, dynamic>> applySearch(List<Map<String, dynamic>> list) {
//     if (_searchQuery.isEmpty) return list;
//     final q = _searchQuery.toLowerCase();
//     return list.where((r) {
//       final groomData = r['groom'] ?? {};
//       return (groomData['first_name']?.toString().toLowerCase() ?? '').contains(q) ||
//           (groomData['last_name']?.toString().toLowerCase() ?? '').contains(q) ||
//           (r['first_name']?.toString().toLowerCase() ?? '').contains(q) ||
//           (r['last_name']?.toString().toLowerCase() ?? '').contains(q) ||
//           (groomData['phone_number']?.toString() ?? '').contains(q);
//     }).toList();
//   }

//   final filteredAll = applySearch(allActive);
//   final filteredValidated = applySearch(allActiveValidated);
//   final filteredPending = applySearch(allActivePending);
//   final filteredCancelled = applySearch(allCancelled);
//   final filteredArchived = applySearch(allArchived);

//   return DefaultTabController(
//     length: 5,
//     child: Column(
//       children: [
//         // Header banner
//         Container(
//           margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
//           padding: const EdgeInsets.all(14),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.teal.shade600, Colors.teal.shade800],
//             ),
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(Icons.output, color: Colors.white, size: 22),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'حجزو في خارج العشيرة',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 15,
//                           fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       'عرسان من عشيرتنا يحجزون في قاعات عشائر أخرى',
//                       style: TextStyle(
//                           color: Colors.white.withOpacity(0.85), fontSize: 11),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // Inner tabs
//         Container(
//           color: isDark ? AppColors.darkCard : Colors.white,
//           margin: const EdgeInsets.only(top: 8),
//           child: TabBar(
//             isScrollable: true,
//             tabAlignment: TabAlignment.start,
//             indicatorColor: Colors.teal.shade400,
//             labelColor: Colors.teal.shade400,
//             unselectedLabelColor:
//                 isDark ? Colors.grey.shade400 : Colors.grey.shade600,
//             labelStyle: TextStyle(
//               fontWeight: FontWeight.w600,
//               fontSize: MediaQuery.of(context).size.width < 600 ? 11 : 13,
//             ),
//             tabs: [
//               Tab(text: 'الكل (${filteredAll.length})'),
//               Tab(text: 'مؤكدة (${filteredValidated.length})'),
//               Tab(text: 'معلقة (${filteredPending.length})'),
//               Tab(text: 'ملغاة (${filteredCancelled.length})'),
//               Tab(text: 'أرشيف (${filteredArchived.length})'),
//             ],
//           ),
//         ),

//         Expanded(
//           child: TabBarView(
//             children: [
//               _buildBelongOutsideList(filteredAll, isDark),
//               _buildBelongOutsideList(filteredValidated, isDark),
//               _buildBelongOutsideList(filteredPending, isDark),
//               _buildBelongOutsideList(filteredCancelled, isDark),
//               _buildBelongOutsideList(filteredArchived, isDark),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }

// // Widget _buildBelongOutsideList(List<Map<String, dynamic>> items, bool isDark) {
// //   if (items.isEmpty) {
// //     return RefreshIndicator(
// //       onRefresh: _loadAllReservations,
// //       color: AppColors.primary,
// //       child: SingleChildScrollView(
// //         physics: const AlwaysScrollableScrollPhysics(),
// //         child: SizedBox(
// //           height: 350,
// //           child: Center(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Icon(Icons.output, size: 56,
// //                     color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
// //                 const SizedBox(height: 12),
// //                 Text(
// //                   'لا توجد حجوزات',
// //                   style: TextStyle(
// //                     fontSize: 15,
// //                     color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
// //                     fontWeight: FontWeight.w500,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   return RefreshIndicator(
// //     onRefresh: _loadAllReservations,
// //     color: AppColors.primary,
// //     child: ListView.builder(
// //       padding: EdgeInsets.all(MediaQuery.of(context).size.width < 600 ? 12 : 16),
// //       itemCount: items.length,
// //       itemBuilder: (context, index) => _buildBelongOutsideReservationCard(items[index], isDark),
// //     ),
// //   );
// // }

// Widget _buildBelongOutsideList(List<Map<String, dynamic>> items, bool isDark) {
//   final sorted = _applySorting(items).cast<Map<String, dynamic>>();

//   if (sorted.isEmpty) {
//     return RefreshIndicator(
//       onRefresh: _loadAllReservations,
//       color: AppColors.primary,
//       child: SingleChildScrollView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         child: SizedBox(
//           height: 350,
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.output,
//                     size: 56,
//                     color:
//                         isDark ? Colors.grey.shade700 : Colors.grey.shade300),
//                 const SizedBox(height: 12),
//                 Text(
//                   'لا توجد حجوزات',
//                   style: TextStyle(
//                     fontSize: 15,
//                     color: isDark
//                         ? Colors.grey.shade400
//                         : Colors.grey.shade500,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   return Column(
//     children: [
//       _buildSortBar(isDark),
//       Expanded(
//         child: RefreshIndicator(
//           onRefresh: _loadAllReservations,
//           color: AppColors.primary,
//           child: ListView.builder(
//             padding: EdgeInsets.all(
//                 MediaQuery.of(context).size.width < 600 ? 12 : 16),
//             itemCount: sorted.length,
//             itemBuilder: (context, index) =>
//                 _buildBelongOutsideReservationCard(sorted[index], isDark),
//           ),
//         ),
//       ),
//     ],
//   );
// }

// Widget _buildBelongOutsideReservationCard(Map<String, dynamic> reservation, bool isDark) {
//   final nbStatus = reservation['_nb_status'] ?? 'pending';
//   final isCancelled = nbStatus == 'cancelled';
//   final isValidated = nbStatus == 'validated';
  
//   final statusColor = isCancelled
//       ? Colors.red.shade400
//       : isValidated
//           ? Colors.green.shade400
//           : Colors.orange.shade400;
//   final statusLabel = isCancelled ? 'ملغي' : isValidated ? 'مؤكد' : 'معلق';
//   final statusIcon = isCancelled
//       ? Icons.cancel_rounded
//       : isValidated
//           ? Icons.check_circle_rounded
//           : Icons.hourglass_empty_rounded;

//   final groomData = reservation['groom'] ?? {};
//   final firstName = groomData['first_name'] ?? reservation['first_name'] ?? 'غير محدد';
//   final lastName = groomData['last_name'] ?? reservation['last_name'] ?? '';
//   final fatherName = groomData['father_name'] ?? reservation['father_name'] ?? '';
//   final phone = groomData['phone_number'] ?? reservation['phone_number'] ?? '';
//   final date1 = reservation['date1'] ?? '';
//   final date2 = reservation['date2'];
//   final date2Bool = reservation['date2_bool'] ?? false;
//   final reservationClanId = reservation['clan_id'];
//   final reservationId = reservation['id'] ?? 0;
//   final groomId = reservation['groom_id'] ?? 0;
//   final guardianName = groomData['guardian_name'] ?? reservation['guardian_name'] ?? '';

//   return Container(
//     margin: const EdgeInsets.only(bottom: 14),
//     decoration: BoxDecoration(
//       color: isDark ? AppColors.darkCard : Colors.white,
//       borderRadius: BorderRadius.circular(20),
//       border: Border.all(color: Colors.teal.shade200, width: 1.5),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.teal.withOpacity(0.08),
//           blurRadius: 10,
//           offset: const Offset(0, 3),
//         ),
//       ],
//     ),
//     child: Theme(
//       data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//       child: ExpansionTile(
//         tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//         childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
//         backgroundColor: isDark ? AppColors.darkCard : Colors.white,
//         collapsedBackgroundColor: isDark ? AppColors.darkCard : Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         leading: CircleAvatar(
//           backgroundColor: Colors.teal.shade100,
//           child: Icon(Icons.output, color: Colors.teal.shade700, size: 20),
//         ),
//         title: Text(
//           '$firstName $lastName',
//           style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16,
//               color: isDark ? Colors.white : Colors.black87),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 4),
//             if (phone.isNotEmpty)
//               Row(
//                 children: [
//                   Icon(Icons.phone_rounded, size: 14,
//                       color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
//                   const SizedBox(width: 4),
//                   Text(phone,
//                       style: TextStyle(
//                           color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
//                           fontSize: 13)),
//                 ],
//               ),
//             const SizedBox(height: 4),
//             Row(
//               children: [
//                 Icon(Icons.calendar_today_rounded, size: 14,
//                     color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
//                 const SizedBox(width: 4),
//                 Text(
//                   '${_formatDate(date1)}${date2Bool && date2 != null ? ' - ${_formatDate(date2)}' : ''}',
//                   style: TextStyle(
//                       color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
//                       fontSize: 13),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                   decoration: BoxDecoration(
//                     color: Colors.teal.shade100,
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(color: Colors.teal.shade300),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.output, size: 12, color: Colors.teal.shade700),
//                       const SizedBox(width: 4),
//                       Text('حجز خارج العشيرة',
//                           style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
//                               color: Colors.teal.shade700)),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                   decoration: BoxDecoration(
//                     color: statusColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(color: statusColor.withOpacity(0.4)),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(statusIcon, size: 12, color: statusColor),
//                       const SizedBox(width: 4),
//                       Text(statusLabel,
//                           style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
//                               color: statusColor)),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         children: [
//   Container(
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: isDark ? AppColors.darkInputBackground : Colors.grey.shade50,
//       borderRadius: BorderRadius.circular(12),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Destination clan info (where they reserved)
//         if (reservationClanId != null)
//           FutureBuilder<Map<String, dynamic>?>(
//             future: _getDestinationClanInfo(reservationClanId),
//             builder: (context, snapshot) {
//               if (!snapshot.hasData) return const SizedBox.shrink();
//               final clanInfo = snapshot.data!;
//               return Container(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.teal.shade50,
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: Colors.teal.shade200),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.location_on, color: Colors.teal.shade600, size: 20),
//                     const SizedBox(width: 10),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('العشيرة التي حجز فيها',
//                             style: TextStyle(
//                                 fontSize: 11,
//                                 color: Colors.teal.shade400,
//                                 fontWeight: FontWeight.w500)),
//                         Text(
//                           clanInfo['clan_name'] ?? 'غير محدد',
//                           style: TextStyle(
//                               fontSize: 15,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.teal.shade800),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),

//         _buildDetailRow('الاسم الكامل:', '$firstName $lastName', isDark),
//         if (fatherName.isNotEmpty)
//           _buildDetailRow('اسم الأب:', fatherName, isDark),
//         if (phone.isNotEmpty)
//           _buildDetailRow('رقم الهاتف:', phone, isDark),
//         _buildDetailRow('اليوم الأول:', _formatDate(date1), isDark),
//         if (date2Bool && date2 != null)
//           _buildDetailRow('اليوم الثاني:', _formatDate(date2), isDark),
//         _buildDetailRow('حالة الحجز:', statusLabel, isDark, valueColor: statusColor),
//         _buildDetailRow(
//           'حالة الدفع:',
//           _getPaymentStatusText(reservation['payment_status'] ?? 'not_paid'),
//           isDark,
//           valueColor: _getPaymentStatusColor(reservation['payment_status'] ?? 'not_paid'),
//         ),
//         if (reservation['allow_others'] != null)
//           _buildDetailRow(
//             'يسمح للآخرين:',
//             reservation['allow_others'] == true ? 'نعم' : 'لا',
//             isDark,
//           ),
//         const SizedBox(height: 16),
//         _buildModernActionButtons(
//           {
//             ...reservation,
//             'phone_number': phone,
//             'guardian_phone': guardianName,
//           },
//           isCancelled ? 'cancelled' : isValidated ? 'validated' : 'pending_validation',
//           (reservation['groom']?['id'] ?? reservation['groom_id'] ?? 0) as int,
//           reservationId as int,
//           '$firstName $lastName',
//         ),
//       ],
//     ),
//   ),
// ],
//       ),
//     ),
//   );
// }

// // Gets the destination clan name directly by clan_id (no reservation lookup needed here)
// Future<Map<String, dynamic>?> _getDestinationClanInfo(int clanId) async {
//   try {
//     final clans = await ApiService.getAllClans();
//     final clan = clans.firstWhere(
//       (c) => c.id == clanId,
//       orElse: () => throw Exception('Clan not found'),
//     );
//     return {'clan_id': clan.id, 'clan_name': clan.name};
//   } catch (e) {
//     return null;
//   }
// }



// // Widget _buildBelongReservationsPage(bool isDark) {
// //   return DefaultTabController(
// //     length: 4,
// //     child: Column(
// //       children: [
// //         Container(
// //           color: isDark ? AppColors.darkCard : Colors.white,
// //           child: TabBar(
// //             isScrollable: true,
// //             tabAlignment: TabAlignment.start,
// //             indicatorColor: Colors.blue.shade400,
// //             labelColor: Colors.blue.shade400,
// //             unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
// //             labelStyle: TextStyle(
// //               fontWeight: FontWeight.w600,
// //               fontSize: MediaQuery.of(context).size.width < 600 ? 11 : 13,
// //             ),
// //             tabs: [
// //               Tab(text: 'الكل (${_allReservations.length})'),
// //               Tab(text: 'معلقة (${_pendingReservations.length})'),
// //               Tab(text: 'ملغاة (${_cancelledReservations.length})'),
// //               Tab(text: 'أرشيف (${_archivedReservations.length})'),
// //             ],
// //           ),
// //         ),
// //         Expanded(
// //           child: TabBarView(
// //             children: [
// //               _buildReservationsList(_getFilteredReservations(_allReservations), 'all', isDark),
// //               _buildReservationsList(_getFilteredReservations(_pendingReservations), 'pending', isDark),
// //               _buildReservationsList(_getFilteredReservations(_cancelledReservations), 'cancelled', isDark),
// //               _buildReservationsList(_getFilteredReservations(_archivedReservations), 'archived', isDark),
// //             ],
// //           ),
// //         ),
// //       ],
// //     ),
// //   );
// // }
// Widget _buildBelongReservationsPage(bool isDark) {
//   // Exclude archived items from the cancelled tab display
//   final cancelledActive = _getFilteredReservations(
//     _cancelledReservations.where((r) => !_isReservationArchived(r)).toList(),
//   );

//   return DefaultTabController(
//     length: 4,
//     child: Column(
//       children: [
//         Container(
//           color: isDark ? AppColors.darkCard : Colors.white,
//           child: TabBar(
//             isScrollable: true,
//             tabAlignment: TabAlignment.start,
//             indicatorColor: Colors.blue.shade400,
//             labelColor: Colors.blue.shade400,
//             unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
//             labelStyle: TextStyle(
//               fontWeight: FontWeight.w600,
//               fontSize: MediaQuery.of(context).size.width < 600 ? 11 : 13,
//             ),
//             tabs: [
//               Tab(text: 'الكل (${_allReservations.length})'),
//               Tab(text: 'معلقة (${_pendingReservations.length})'),
//               Tab(text: 'ملغاة (${cancelledActive.length})'),
//               Tab(text: 'أرشيف (${_archivedReservations.length})'),
//             ],
//           ),
//         ),
//         Expanded(
//           child: TabBarView(
//             children: [
//               _buildReservationsList(_getFilteredReservations(_allReservations), 'all', isDark),
//               _buildReservationsList(_getFilteredReservations(_pendingReservations), 'pending', isDark),
//               _buildReservationsList(cancelledActive, 'cancelled', isDark),
//               _buildReservationsList(_getFilteredReservations(_archivedReservations), 'archived', isDark),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }
// }