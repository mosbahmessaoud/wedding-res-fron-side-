// // lib/screens/clan_admin/expiring_reservations_page.dart
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:wedding_reservation_app/utils/colors.dart';

// import '../../providers/theme_provider.dart';
// import '../../services/api_service.dart';

// class ExpiringReservationsPage extends StatefulWidget {
//   const ExpiringReservationsPage({super.key});

//   @override
//   State<ExpiringReservationsPage> createState() => _ExpiringReservationsPageState();
// }

// class _ExpiringReservationsPageState extends State<ExpiringReservationsPage>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   List<dynamic> _expiring10 = [];
//   List<dynamic> _expiring20 = [];
//   List<dynamic> _expiring30 = [];
//   List<dynamic> _expiredReservations = [];
//   bool _isLoading = false;
//   String _searchQuery = '';

//   // ── Sort state ──────────────────────────────────────────────────────────────
//   String _sortBy = 'expired_date_if_pending'; // default: soonest expiry
//   bool _sortAscending = true;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//     _loadExpiringReservations();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   // ── Sort ────────────────────────────────────────────────────────────────────

//   List<dynamic> _applySorting(List<dynamic> list) {
//     final sorted = List<dynamic>.from(list);
//     sorted.sort((a, b) {
//       final aVal = a[_sortBy]?.toString() ?? '';
//       final bVal = b[_sortBy]?.toString() ?? '';
//       if (aVal.isEmpty && bVal.isEmpty) return 0;
//       if (aVal.isEmpty) return 1;
//       if (bVal.isEmpty) return -1;
//       final result = aVal.compareTo(bVal);
//       return _sortAscending ? result : -result;
//     });
//     return sorted;
//   }

//   Widget _buildSortBar(bool isDark) {
//     final options = [
//       {'value': 'expired_date_if_pending', 'label': 'تاريخ الانتهاء'},
//       {'value': 'date1', 'label': 'تاريخ الحجز'},
//       {'value': 'created_at', 'label': 'تاريخ الإنشاء'},
//     ];

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       color: isDark ? AppColors.darkCard : Colors.white,
//       child: Row(
//         children: [
//           Icon(Icons.sort_rounded,
//               size: 18,
//               color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
//           const SizedBox(width: 6),
//           Text('ترتيب:',
//               style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w500,
//                   color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
//           const SizedBox(width: 8),
//           Expanded(
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: options.map((opt) {
//                   final isSelected = _sortBy == opt['value'];
//                   return Padding(
//                     padding: const EdgeInsets.only(left: 6),
//                     child: GestureDetector(
//                       onTap: () => setState(() {
//                         if (_sortBy == opt['value']) {
//                           _sortAscending = !_sortAscending;
//                         } else {
//                           _sortBy = opt['value']!;
//                           _sortAscending = true;
//                         }
//                       }),
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 200),
//                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: isSelected
//                               ? AppColors.primary.withOpacity(0.15)
//                               : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(
//                             color: isSelected
//                                 ? AppColors.primary.withOpacity(0.5)
//                                 : Colors.transparent,
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               opt['label']!,
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//                                 color: isSelected
//                                     ? AppColors.primary
//                                     : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
//                               ),
//                             ),
//                             if (isSelected) ...[
//                               const SizedBox(width: 4),
//                               Icon(
//                                 _sortAscending
//                                     ? Icons.arrow_upward_rounded
//                                     : Icons.arrow_downward_rounded,
//                                 size: 13,
//                                 color: AppColors.primary,
//                               ),
//                             ],
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── WhatsApp ────────────────────────────────────────────────────────────────

//   Future<void> _openWhatsApp(String phone) async {
//     String cleaned = phone.replaceAll(RegExp(r'[\s\-()]'), '');
//     if (cleaned.startsWith('0')) {
//       cleaned = '213${cleaned.substring(1)}';
//     } else if (!cleaned.startsWith('213')) {
//       cleaned = '213$cleaned';
//     }
//     final uri = Uri.parse('https://wa.me/$cleaned');
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     } else {
//       if (mounted) _showSnackBar('تعذّر فتح واتساب', Colors.red.shade400);
//     }
//   }

//   Widget _whatsAppBtn(String phone, String label, bool isSmall) {
//     if (phone.isEmpty) return const SizedBox.shrink();
//     return ElevatedButton.icon(
//       onPressed: () => _openWhatsApp(phone),
//       icon: Icon(Icons.chat_rounded, size: isSmall ? 16 : 18),
//       label: Text('واتساب $label', style: TextStyle(fontSize: isSmall ? 12 : 14)),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: const Color(0xFF25D366),
//         foregroundColor: Colors.white,
//         elevation: 0,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         padding: EdgeInsets.symmetric(horizontal: isSmall ? 12 : 16, vertical: isSmall ? 6 : 8),
//       ),
//     );
//   }

//   // ── Data Loading ─────────────────────────────────────────────────────────────

//   Future<void> _loadExpiringReservations() async {
//     setState(() => _isLoading = true);
//     try {
//       final pending = await ApiService.getPendingReservations();
//       final now = DateTime.now();

//       final List<dynamic> ten = [], twenty = [], thirty = [], expired = [];

//       for (final res in pending) {
//         final expStr = res['expired_date_if_pending'];
//         if (expStr == null) continue;
//         DateTime expDate;
//         try {
//           expDate = DateTime.parse(expStr);
//         } catch (_) {
//           continue;
//         }
//         final diff = expDate.difference(now).inDays;
//         if (diff < 0) {
//           expired.add(res);
//           continue;
//         }
//         if (diff < 10) ten.add(res);
//         if (diff < 20) twenty.add(res);
//         if (diff < 30) thirty.add(res);
//       }

//       _sortByExpiry(ten);
//       _sortByExpiry(twenty);
//       _sortByExpiry(thirty);
//       expired.sort((a, b) {
//         final aDate = a['expired_date_if_pending'];
//         final bDate = b['expired_date_if_pending'];
//         if (aDate == null && bDate == null) return 0;
//         if (aDate == null) return 1;
//         if (bDate == null) return -1;
//         return DateTime.parse(bDate).compareTo(DateTime.parse(aDate));
//       });

//       setState(() {
//         _expiring10 = ten;
//         _expiring20 = twenty;
//         _expiring30 = thirty;
//         _expiredReservations = expired;
//       });
//     } catch (e) {
//       _showSnackBar('فشل في تحميل البيانات: $e', Colors.red.shade400);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   void _sortByExpiry(List<dynamic> list) {
//     list.sort((a, b) {
//       final aDate = a['expired_date_if_pending'];
//       final bDate = b['expired_date_if_pending'];
//       if (aDate == null && bDate == null) return 0;
//       if (aDate == null) return 1;
//       if (bDate == null) return -1;
//       return DateTime.parse(aDate).compareTo(DateTime.parse(bDate));
//     });
//   }

//   // ── Helpers ──────────────────────────────────────────────────────────────────

//   List<dynamic> _filtered(List<dynamic> source) {
//     final base = _applySorting(source);
//     if (_searchQuery.isEmpty) return base;
//     final q = _searchQuery.toLowerCase();
//     return base.where((r) {
//       return (r['first_name']?.toString().toLowerCase() ?? '').contains(q) ||
//           (r['last_name']?.toString().toLowerCase() ?? '').contains(q) ||
//           (r['guardian_name']?.toString().toLowerCase() ?? '').contains(q) ||
//           (r['father_name']?.toString().toLowerCase() ?? '').contains(q) ||
//           (r['phone_number']?.toString() ?? '').contains(q);
//     }).toList();
//   }

//   int _daysRemaining(String? expStr) {
//     if (expStr == null) return 999;
//     try {
//       return DateTime.parse(expStr).difference(DateTime.now()).inDays;
//     } catch (_) {
//       return 999;
//     }
//   }

//   Color _urgencyColor(int days) {
//     if (days <= 3) return Colors.red.shade500;
//     if (days <= 7) return Colors.orange.shade500;
//     if (days <= 14) return Colors.amber.shade600;
//     return Colors.green.shade500;
//   }

//   String _urgencyLabel(int days) {
//     if (days == 0) return 'ينتهي اليوم!';
//     if (days == 1) return 'غداً!';
//     return 'متبقي $days يوم';
//   }

//   String _formatDate(String? s) {
//     if (s == null || s.isEmpty) return 'غير محدد';
//     try {
//       return DateFormat('yyyy/MM/dd', 'fr').format(DateTime.parse(s));
//     } catch (_) {
//       return s;
//     }
//   }

//   String _formatDateTime(String? s) {
//     if (s == null || s.isEmpty) return 'غير محدد';
//     try {
//       return DateFormat('yyyy/MM/dd HH:mm', 'fr').format(DateTime.parse(s));
//     } catch (_) {
//       return s;
//     }
//   }

//   void _showSnackBar(String msg, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text(msg),
//       backgroundColor: color,
//       behavior: SnackBarBehavior.floating,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       margin: const EdgeInsets.all(16),
//     ));
//   }

//   // ── Actions ──────────────────────────────────────────────────────────────────

//   Future<void> _validateReservation(int reservationId, String groomName) async {
//     final confirmed = await _showConfirmDialog(
//         'تأكيد الحجز', 'هل أنت متأكد من تأكيد حجز $groomName؟', Colors.green, Icons.check_circle);
//     if (!confirmed) return;
//     try {
//       setState(() => _isLoading = true);
//       await ApiService.ChangeReservationStatus(reservationId);
//       await _loadExpiringReservations();
//       _showSnackBar('تم تأكيد الحجز بنجاح', Colors.green.shade400);
//     } catch (e) {
//       _showSnackBar('خطأ في تأكيد الحجز: $e', Colors.red.shade400);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _cancelReservation(int reservationId, String groomName) async {
//     final confirmed = await _showConfirmDialog(
//         'إلغاء الحجز', 'هل أنت متأكد من إلغاء حجز $groomName؟', Colors.red, Icons.cancel);
//     if (!confirmed) return;
//     try {
//       setState(() => _isLoading = true);
//       await ApiService.ChangeReservationStatus(reservationId);
//       await _loadExpiringReservations();
//       _showSnackBar('تم إلغاء الحجز بنجاح', Colors.orange.shade400);
//     } catch (e) {
//       _showSnackBar('خطأ في إلغاء الحجز: $e', Colors.red.shade400);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _togglePayment(int reservationId, String groomName, String currentStatus) async {
//     double requiredPayment = 0.0;
//     try {
//       requiredPayment = await ApiService.getRequiredPayment();
//     } catch (_) {}
//     final amount = await _showPaymentDialog(groomName, 0.0, requiredPayment, currentStatus);
//     if (amount == null) return;
//     try {
//       setState(() => _isLoading = true);
//       await ApiService.changePaymentStatus(reservationId, amount);
//       await _loadExpiringReservations();
//       _showSnackBar('تم تحديث حالة الدفع', Colors.blue.shade400);
//     } catch (e) {
//       _showSnackBar('خطأ في تحديث الدفع: $e', Colors.red.shade400);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   // ── Dialogs ──────────────────────────────────────────────────────────────────

//   Future<bool> _showConfirmDialog(String title, String content, Color color, IconData icon) async {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return await showDialog<bool>(
//           context: context,
//           builder: (ctx) => AlertDialog(
//             backgroundColor: isDark ? AppColors.darkCard : Colors.white,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//             title: Row(children: [
//               Icon(icon, color: color, size: 28),
//               const SizedBox(width: 12),
//               Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
//             ]),
//             content: Text(content,
//                 style: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade700)),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(ctx, false),
//                 child: Text('إلغاء',
//                     style: TextStyle(
//                         color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
//               ),
//               ElevatedButton(
//                 onPressed: () => Navigator.pop(ctx, true),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: color,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//                 child: const Text('تأكيد', style: TextStyle(color: Colors.white)),
//               ),
//             ],
//           ),
//         ) ??
//         false;
//   }

//   Future<double?> _showPaymentDialog(
//       String groomName, double current, double required, String currentStatus) async {
//     final ctrl =
//         TextEditingController(text: current > 0 ? current.toStringAsFixed(2) : '');
//     return showDialog<double>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(children: [
//           Icon(Icons.payment_rounded, color: Colors.blue.shade600, size: 28),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               const Text('تحديث الدفع',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               Text(groomName,
//                   style: TextStyle(
//                       fontSize: 13,
//                       color: Colors.grey.shade600,
//                       fontWeight: FontWeight.normal)),
//             ]),
//           ),
//         ]),
//         content: Column(mainAxisSize: MainAxisSize.min, children: [
//           Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//             Text('المبلغ المطلوب:', style: TextStyle(color: Colors.grey.shade700)),
//             Text('${required.toStringAsFixed(2)} د.ج',
//                 style:
//                     TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
//           ]),
//           const SizedBox(height: 12),
//           TextField(
//             controller: ctrl,
//             keyboardType: const TextInputType.numberWithOptions(decimal: true),
//             decoration: InputDecoration(
//               labelText: 'المبلغ الجديد',
//               suffixText: 'د.ج',
//               prefixIcon: const Icon(Icons.attach_money),
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//           ),
//         ]),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(ctx),
//               child: Text('إلغاء', style: TextStyle(color: Colors.grey.shade600))),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(ctx, double.tryParse(ctrl.text) ?? 0.0),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue.shade400,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//             child: const Text('تأكيد', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── UI ────────────────────────────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return Scaffold(
//       backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
//       appBar: _buildAppBar(isDark),
//       body: Column(
//         children: [
//           _buildSearchAndStats(isDark),
//           _buildTabBar(isDark),
//           Expanded(
//             child: _isLoading
//                 ? Center(
//                     child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//                       CircularProgressIndicator(color: AppColors.primary),
//                       const SizedBox(height: 16),
//                       Text('جاري التحميل...',
//                           style: TextStyle(
//                               color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
//                     ]),
//                   )
//                 : TabBarView(
//                     controller: _tabController,
//                     children: [
//                       _buildList(_filtered(_expiring10), 10, isDark),
//                       _buildList(_filtered(_expiring20), 20, isDark),
//                       _buildList(_filtered(_expiring30), 30, isDark),
//                       _buildExpiredList(_filtered(_expiredReservations), isDark),
//                     ],
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── AppBar ────────────────────────────────────────────────────────────────────

//   PreferredSizeWidget _buildAppBar(bool isDark) {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: Colors.transparent,
//       flexibleSpace: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               isDark ? AppColors.primary.withOpacity(0.4) : AppColors.primary.withOpacity(0.8),
//               AppColors.primary,
//               AppColors.primary,
//               isDark ? AppColors.primary.withOpacity(0.4) : AppColors.primary.withOpacity(0.8),
//             ],
//           ),
//         ),
//       ),
//       foregroundColor: Colors.white,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back_ios_new, size: 20),
//         onPressed: () => Navigator.pop(context),
//       ),
//       title: const Text('الحجوزات قاربت على الانتهاء',
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//       actions: [
//         Container(
//           margin: const EdgeInsets.only(right: 4),
//           decoration:
//               BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
//           child: IconButton(
//             onPressed: () =>
//                 Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
//             icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode, size: 20),
//           ),
//         ),
//         Container(
//           margin: const EdgeInsets.only(right: 12, left: 4),
//           decoration:
//               BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
//           child: IconButton(
//             onPressed: _loadExpiringReservations,
//             icon: const Icon(Icons.refresh, size: 20),
//             tooltip: 'تحديث',
//           ),
//         ),
//       ],
//     );
//   }

//   // ── Search + Stats ────────────────────────────────────────────────────────────

//   Widget _buildSearchAndStats(bool isDark) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
//       decoration: BoxDecoration(
//         color: isDark ? AppColors.darkCard : Colors.white,
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 2))
//         ],
//       ),
//       child: Column(
//         children: [
//           // Urgency banner
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(colors: [
//                 Colors.deepOrange.shade600.withOpacity(0.15),
//                 Colors.amber.shade600.withOpacity(0.1),
//               ]),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.deepOrange.shade300.withOpacity(0.4)),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.warning_amber_rounded, color: Colors.deepOrange.shade600, size: 22),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     'هذه الحجوزات ستنتهي صلاحيتها قريباً وتحتاج إلى متابعة عاجلة',
//                     style: TextStyle(
//                         color: isDark ? Colors.orange.shade300 : Colors.deepOrange.shade700,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 12),
//           // Search
//           Container(
//             decoration: BoxDecoration(
//               color: isDark ? AppColors.darkInputBackground : Colors.grey.shade100,
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: TextField(
//               onChanged: (v) => setState(() => _searchQuery = v),
//               style: TextStyle(color: isDark ? Colors.white : Colors.black87),
//               decoration: InputDecoration(
//                 hintText: 'البحث بالاسم أو رقم الهاتف...',
//                 hintStyle: TextStyle(
//                     color: isDark ? Colors.grey.shade600 : Colors.grey.shade500),
//                 prefixIcon: Icon(Icons.search_rounded,
//                     color: isDark ? Colors.grey.shade500 : Colors.grey.shade400, size: 22),
//                 suffixIcon: _searchQuery.isNotEmpty
//                     ? IconButton(
//                         icon: Icon(Icons.clear_rounded,
//                             color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
//                             size: 20),
//                         onPressed: () => setState(() => _searchQuery = ''),
//                       )
//                     : null,
//                 border: InputBorder.none,
//                 contentPadding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//               ),
//             ),
//           ),
//           const SizedBox(height: 14),
//           // Stats
//           Row(
//             children: [
//               _buildStatCard('أقل من 10 أيام', _expiring10.length,
//                   Colors.red.shade500, Icons.alarm, isDark),
//               const SizedBox(width: 8),
//               _buildStatCard('أقل من 20 يوم', _expiring20.length,
//                   Colors.orange.shade500, Icons.schedule, isDark),
//               const SizedBox(width: 8),
//               _buildStatCard('أقل من 30 يوم', _expiring30.length,
//                   Colors.amber.shade600, Icons.hourglass_bottom, isDark),
//               const SizedBox(width: 8),
//               _buildStatCard('منتهية', _expiredReservations.length,
//                   Colors.grey.shade600, Icons.block_rounded, isDark),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatCard(String label, int count, Color color, IconData icon, bool isDark) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
//         decoration: BoxDecoration(
//           color: color.withOpacity(isDark ? 0.2 : 0.08),
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: color.withOpacity(0.3)),
//         ),
//         child: Column(mainAxisSize: MainAxisSize.min, children: [
//           Icon(icon, color: color, size: 22),
//           const SizedBox(height: 4),
//           Text('$count',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
//           const SizedBox(height: 2),
//           Text(label,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                   fontSize: 9,
//                   color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis),
//         ]),
//       ),
//     );
//   }

//   // ── TabBar ────────────────────────────────────────────────────────────────────

//   Widget _buildTabBar(bool isDark) {
//     return Container(
//       color: isDark ? AppColors.darkCard : Colors.white,
//       child: TabBar(
//         controller: _tabController,
//         isScrollable: true,
//         tabAlignment: TabAlignment.start,
//         indicatorColor: Colors.deepOrange.shade500,
//         indicatorWeight: 3,
//         labelColor: Colors.deepOrange.shade500,
//         unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
//         labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
//         unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
//         tabs: [
//           _buildTab('أقل من 10 أيام', _expiring10.length, Colors.red.shade500),
//           _buildTab('أقل من 20 يوم', _expiring20.length, Colors.orange.shade500),
//           _buildTab('أقل من 30 يوم', _expiring30.length, Colors.amber.shade600),
//           _buildTab('منتهية', _expiredReservations.length, Colors.grey.shade600),
//         ],
//       ),
//     );
//   }

//   Tab _buildTab(String label, int count, Color badgeColor) {
//     return Tab(
//       child: Row(mainAxisSize: MainAxisSize.min, children: [
//         Flexible(child: Text(label, overflow: TextOverflow.ellipsis, maxLines: 1)),
//         const SizedBox(width: 6),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
//           decoration:
//               BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(10)),
//           child: Text('$count',
//               style: const TextStyle(
//                   color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
//         ),
//       ]),
//     );
//   }

//   // ── List ──────────────────────────────────────────────────────────────────────

//   Widget _buildList(List<dynamic> reservations, int threshold, bool isDark) {
//     if (reservations.isEmpty) {
//       return RefreshIndicator(
//         onRefresh: _loadExpiringReservations,
//         color: AppColors.primary,
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           child: SizedBox(
//             height: 400,
//             child: Center(
//               child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//                 Icon(Icons.check_circle_outline_rounded,
//                     size: 64,
//                     color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
//                 const SizedBox(height: 16),
//                 Text('لا توجد حجوزات تنتهي خلال $threshold يوم',
//                     style: TextStyle(
//                         fontSize: 15,
//                         color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
//                         fontWeight: FontWeight.w500)),
//               ]),
//             ),
//           ),
//         ),
//       );
//     }

//     return Column(
//       children: [
//         _buildSortBar(isDark),
//         Expanded(
//           child: RefreshIndicator(
//             onRefresh: _loadExpiringReservations,
//             color: AppColors.primary,
//             child: ListView.builder(
//               padding: const EdgeInsets.all(14),
//               itemCount: reservations.length,
//               itemBuilder: (ctx, i) => _buildCard(reservations[i], isDark),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ── Card ──────────────────────────────────────────────────────────────────────

//   Widget _buildCard(Map<String, dynamic> res, bool isDark) {
//     final firstName = res['first_name'] ?? 'غير محدد';
//     final lastName = res['last_name'] ?? '';
//     final phone = res['phone_number'] ?? '';
//     final date1 = res['date1'] ?? '';
//     final date2 = res['date2'];
//     final date2Bool = res['date2_bool'] ?? false;
//     final expStr = res['expired_date_if_pending'];
//     final days = _daysRemaining(expStr);
//     final urgColor = _urgencyColor(days);
//     final reservationId = res['id'] ?? 0;
//     final groomId = res['groom_id'] ?? 0;
//     final paymentStatus = res['payment_status'] ?? 'not_paid';

//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       decoration: BoxDecoration(
//         color: isDark ? AppColors.darkCard : Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: urgColor.withOpacity(0.35), width: 1.5),
//         boxShadow: [
//           BoxShadow(color: urgColor.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 3))
//         ],
//       ),
//       child: Theme(
//         data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//         child: ExpansionTile(
//           tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
//           childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
//           backgroundColor: isDark ? AppColors.darkCard : Colors.white,
//           collapsedBackgroundColor: isDark ? AppColors.darkCard : Colors.white,
//           iconColor: isDark ? Colors.white70 : Colors.black87,
//           collapsedIconColor: isDark ? Colors.white70 : Colors.black87,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           leading: Container(
//             width: 52,
//             height: 52,
//             decoration: BoxDecoration(
//               color: urgColor.withOpacity(isDark ? 0.25 : 0.12),
//               shape: BoxShape.circle,
//               border: Border.all(color: urgColor.withOpacity(0.5)),
//             ),
//             child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//               Text('$days',
//                   style:
//                       TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: urgColor)),
//               Text('يوم', style: TextStyle(fontSize: 9, color: urgColor)),
//             ]),
//           ),
//           title: Text('$firstName $lastName',
//               style: TextStyle(
//                   fontWeight: FontWeight.w700,
//                   fontSize: 15,
//                   color: isDark ? Colors.white : Colors.black87)),
//           subtitle: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 4),
//               if (phone.isNotEmpty)
//                 Row(children: [
//                   Icon(Icons.phone_rounded,
//                       size: 14,
//                       color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
//                   const SizedBox(width: 4),
//                   Text(phone,
//                       style: TextStyle(
//                           color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
//                           fontSize: 12)),
//                 ]),
//               const SizedBox(height: 4),
//               Row(children: [
//                 Icon(Icons.calendar_today_rounded,
//                     size: 14,
//                     color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
//                 const SizedBox(width: 4),
//                 Text(
//                   '${_formatDate(date1)}${date2Bool && date2 != null ? ' - ${_formatDate(date2)}' : ''}',
//                   style: TextStyle(
//                       color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
//                       fontSize: 12),
//                 ),
//               ]),
//               const SizedBox(height: 6),
//               Wrap(spacing: 6, runSpacing: 4, children: [
//                 _urgencyBadge(days, urgColor),
//                 _paymentChip(paymentStatus, isDark),
//               ]),
//             ],
//           ),
//           children: [
//             _buildDetails(res, reservationId, groomId, '$firstName $lastName',
//                 paymentStatus, isDark),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _urgencyBadge(int days, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: color.withOpacity(0.4)),
//       ),
//       child: Row(mainAxisSize: MainAxisSize.min, children: [
//         Icon(Icons.timer_outlined, size: 12, color: color),
//         const SizedBox(width: 4),
//         Text(_urgencyLabel(days),
//             style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
//       ]),
//     );
//   }

//   Widget _paymentChip(String status, bool isDark) {
//     Color c;
//     String label;
//     IconData icon;
//     switch (status) {
//       case 'paid':
//         c = Colors.green;
//         label = 'مدفوع';
//         icon = Icons.check_circle_rounded;
//         break;
//       case 'partially_paid':
//         c = Colors.orange;
//         label = 'جزئي';
//         icon = Icons.hourglass_bottom_rounded;
//         break;
//       default:
//         c = Colors.red;
//         label = 'غير مدفوع';
//         icon = Icons.cancel_rounded;
//     }
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//       decoration: BoxDecoration(
//         color: c.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: c.withOpacity(0.35)),
//       ),
//       child: Row(mainAxisSize: MainAxisSize.min, children: [
//         Icon(icon, size: 11, color: c),
//         const SizedBox(width: 4),
//         Text(label,
//             style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c)),
//       ]),
//     );
//   }

//   // ── Details Panel ─────────────────────────────────────────────────────────────

//   Widget _buildDetails(Map<String, dynamic> res, int reservationId, int groomId,
//       String groomName, String paymentStatus, bool isDark) {
//     final expStr = res['expired_date_if_pending'];
//     final reservedInsideOwnClan = res['reserved_inside_own_clan'] ?? true;
//     final reservationClanName = res['reservation_clan_name'] ?? 'غير محدد';
//     final groomClanName = res['groom_clan_name'] ?? 'غير محدد';

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: isDark ? AppColors.darkInputBackground : Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (expStr != null) _buildExpiryHighlight(expStr, isDark),
//           const SizedBox(height: 12),

//           // Clan info banner
//           Container(
//             margin: const EdgeInsets.only(bottom: 12),
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: reservedInsideOwnClan
//                   ? Colors.blue.shade50.withOpacity(isDark ? 0.1 : 1)
//                   : Colors.orange.shade50.withOpacity(isDark ? 0.1 : 1),
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(
//                 color: reservedInsideOwnClan
//                     ? Colors.blue.shade200
//                     : Colors.orange.shade200,
//               ),
//             ),
//             child: Column(children: [
//               Row(children: [
//                 Icon(Icons.groups,
//                     color: reservedInsideOwnClan
//                         ? Colors.blue.shade600
//                         : Colors.orange.shade600,
//                     size: 18),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                     Text('عشيرة العريس الأصلية',
//                         style: TextStyle(
//                             fontSize: 10,
//                             color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
//                     Text(groomClanName,
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14,
//                             color: isDark ? Colors.white : Colors.black87)),
//                   ]),
//                 ),
//               ]),
//               const SizedBox(height: 8),
//               Row(children: [
//                 Icon(Icons.location_on,
//                     color: reservedInsideOwnClan
//                         ? Colors.blue.shade600
//                         : Colors.orange.shade600,
//                     size: 18),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                     Text('حجز في عشيرة',
//                         style: TextStyle(
//                             fontSize: 10,
//                             color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
//                     Text(reservationClanName,
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14,
//                             color: isDark ? Colors.white : Colors.black87)),
//                   ]),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: reservedInsideOwnClan
//                         ? Colors.blue.shade100
//                         : Colors.orange.shade100,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     reservedInsideOwnClan ? 'داخل العشيرة' : 'خارج العشيرة',
//                     style: TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.w600,
//                         color: reservedInsideOwnClan
//                             ? Colors.blue.shade700
//                             : Colors.orange.shade700),
//                   ),
//                 ),
//               ]),
//             ]),
//           ),

//           _detailRow('رقم الحجز:', '${res['id'] ?? 0}', isDark),
//           _detailRow('حالة الحجز:', _statusText(res['status'] ?? ''), isDark,
//               valueColor: _statusColor(res['status'] ?? '')),
//           _detailRow('اسم الولي:', res['guardian_name'] ?? 'غير محدد', isDark),
//           _detailRow('اسم الأب:', res['father_name'] ?? 'غير محدد', isDark),
//           _detailRow('رقم الهاتف:', res['phone_number'] ?? 'غير محدد', isDark),
//           if ((res['guardian_phone'] ?? '').isNotEmpty)
//             _detailRow('هاتف الولي:', res['guardian_phone'], isDark),
//           _detailRow('تاريخ العرس:', _formatDate(res['date1']), isDark),
//           if (res['date2_bool'] == true && res['date2'] != null)
//             _detailRow('اليوم الثاني:', _formatDate(res['date2']), isDark),
//           _detailRow('حالة الدفع:', _paymentText(paymentStatus), isDark,
//               valueColor: _paymentColor(paymentStatus)),
//           if (res['hall_name'] != null)
//             _detailRow('القاعة:', res['hall_name'], isDark),
//           _detailRow('تاريخ الإنشاء:', _formatDateTime(res['created_at']), isDark),
//           if (expStr != null)
//             _detailRow('ينتهي في:', _formatDateTime(expStr), isDark,
//                 valueColor: _urgencyColor(_daysRemaining(expStr))),

//           const SizedBox(height: 16),
//           _buildActionButtons(reservationId, groomId, groomName, paymentStatus,
//               res['phone_number'] ?? '', res['guardian_phone'] ?? ''),
//         ],
//       ),
//     );
//   }

//   Widget _buildExpiryHighlight(String expStr, bool isDark) {
//     final days = _daysRemaining(expStr);
//     final color = _urgencyColor(days);
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: color.withOpacity(isDark ? 0.2 : 0.08),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.4)),
//       ),
//       child: Row(children: [
//         Icon(Icons.alarm, color: color, size: 22),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(
//               days == 0
//                   ? 'ينتهي اليوم!'
//                   : days == 1
//                       ? 'ينتهي غداً!'
//                       : 'متبقي $days يوم على انتهاء الصلاحية',
//               style:
//                   TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14),
//             ),
//             Text('تاريخ الانتهاء: ${_formatDate(expStr)}',
//                 style: TextStyle(color: color.withOpacity(0.8), fontSize: 12)),
//           ]),
//         ),
//       ]),
//     );
//   }

//   Widget _detailRow(String label, String value, bool isDark, {Color? valueColor}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(label,
//                 style: TextStyle(
//                     fontWeight: FontWeight.w500,
//                     color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
//                     fontSize: 13)),
//           ),
//           Expanded(
//             child: Text(value,
//                 style: TextStyle(
//                     color: valueColor ?? (isDark ? Colors.white70 : Colors.grey.shade800),
//                     fontWeight:
//                         valueColor != null ? FontWeight.w600 : FontWeight.normal,
//                     fontSize: 13)),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Action Buttons ────────────────────────────────────────────────────────────

//   Widget _buildActionButtons(int reservationId, int groomId, String groomName,
//       String paymentStatus, String groomPhone, String guardianPhone) {
//     final isSmall = MediaQuery.of(context).size.width < 600;
//     return Wrap(
//       spacing: 8,
//       runSpacing: 8,
//       alignment: isSmall ? WrapAlignment.center : WrapAlignment.start,
//       children: [
//         _whatsAppBtn(groomPhone, 'العريس', isSmall),
//         _whatsAppBtn(guardianPhone, 'الولي', isSmall),
//       ],
//     );
//   }

//   Widget _actionBtn({
//     required VoidCallback onPressed,
//     required IconData icon,
//     required String label,
//     required Color color,
//     bool isSmall = false,
//   }) {
//     return ElevatedButton.icon(
//       onPressed: onPressed,
//       icon: Icon(icon, size: isSmall ? 16 : 18),
//       label: Text(label, style: TextStyle(fontSize: isSmall ? 12 : 14)),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         padding: EdgeInsets.symmetric(
//             horizontal: isSmall ? 12 : 16, vertical: isSmall ? 6 : 8),
//       ),
//     );
//   }

//   // ── Payment helpers ───────────────────────────────────────────────────────────

//   String _paymentText(String s) {
//     switch (s) {
//       case 'paid': return 'مدفوع بالكامل';
//       case 'partially_paid': return 'مدفوع جزئياً';
//       default: return 'غير مدفوع';
//     }
//   }

//   Color _paymentColor(String s) {
//     switch (s) {
//       case 'paid': return Colors.green;
//       case 'partially_paid': return Colors.orange;
//       default: return Colors.red;
//     }
//   }

//   IconData _paymentIcon(String s) {
//     switch (s) {
//       case 'paid': return Icons.check_circle_rounded;
//       case 'partially_paid': return Icons.hourglass_bottom_rounded;
//       default: return Icons.cancel_rounded;
//     }
//   }

//   String _statusText(String status) {
//     switch (status) {
//       case 'pending_validation': return 'معلق';
//       case 'validated': return 'مؤكد';
//       case 'cancelled': return 'ملغي';
//       default: return 'غير محدد';
//     }
//   }

//   Color _statusColor(String status) {
//     switch (status) {
//       case 'pending_validation': return Colors.orange.shade500;
//       case 'validated': return Colors.green.shade500;
//       case 'cancelled': return Colors.red.shade500;
//       default: return Colors.grey.shade500;
//     }
//   }

//   // ── Expired List ──────────────────────────────────────────────────────────────

//   Widget _buildExpiredList(List<dynamic> reservations, bool isDark) {
//     if (reservations.isEmpty) {
//       return RefreshIndicator(
//         onRefresh: _loadExpiringReservations,
//         color: AppColors.primary,
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           child: SizedBox(
//             height: 400,
//             child: Center(
//               child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//                 Icon(Icons.check_circle_outline_rounded,
//                     size: 64,
//                     color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
//                 const SizedBox(height: 16),
//                 Text('لا توجد حجوزات منتهية الصلاحية',
//                     style: TextStyle(
//                         fontSize: 15,
//                         color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
//                         fontWeight: FontWeight.w500)),
//               ]),
//             ),
//           ),
//         ),
//       );
//     }

//     return Column(
//       children: [
//         _buildSortBar(isDark),
//         // Warning banner
//         Container(
//           margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade600.withOpacity(isDark ? 0.2 : 0.08),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey.shade400.withOpacity(0.4)),
//           ),
//           child: Row(children: [
//             Icon(Icons.block_rounded, color: Colors.grey.shade600, size: 20),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 'هذه الحجوزات انتهت صلاحيتها ولم يتم تأكيدها في الوقت المحدد',
//                 style: TextStyle(
//                     color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500),
//               ),
//             ),
//           ]),
//         ),
//         Expanded(
//           child: RefreshIndicator(
//             onRefresh: _loadExpiringReservations,
//             color: AppColors.primary,
//             child: ListView.builder(
//               padding: const EdgeInsets.all(14),
//               itemCount: reservations.length,
//               itemBuilder: (ctx, i) => _buildExpiredCard(reservations[i], isDark),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildExpiredCard(Map<String, dynamic> res, bool isDark) {
//     final firstName = res['first_name'] ?? 'غير محدد';
//     final lastName = res['last_name'] ?? '';
//     final phone = res['phone_number'] ?? '';
//     final date1 = res['date1'] ?? '';
//     final date2 = res['date2'];
//     final date2Bool = res['date2_bool'] ?? false;
//     final expStr = res['expired_date_if_pending'];
//     final reservationId = res['id'] ?? 0;
//     final groomId = res['groom_id'] ?? 0;
//     final paymentStatus = res['payment_status'] ?? 'not_paid';

//     int daysAgo = 0;
//     if (expStr != null) {
//       try {
//         daysAgo = DateTime.now().difference(DateTime.parse(expStr)).inDays;
//       } catch (_) {}
//     }

//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       decoration: BoxDecoration(
//         color: isDark ? AppColors.darkCard : Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.grey.shade400.withOpacity(0.4), width: 1.5),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
//               blurRadius: 8,
//               offset: const Offset(0, 2))
//         ],
//       ),
//       child: Theme(
//         data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//         child: ExpansionTile(
//           tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
//           childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
//           backgroundColor: isDark ? AppColors.darkCard : Colors.white,
//           collapsedBackgroundColor: isDark ? AppColors.darkCard : Colors.white,
//           iconColor: isDark ? Colors.white70 : Colors.black87,
//           collapsedIconColor: isDark ? Colors.white70 : Colors.black87,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           leading: Container(
//             width: 52,
//             height: 52,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade400.withOpacity(isDark ? 0.25 : 0.12),
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.grey.shade400.withOpacity(0.5)),
//             ),
//             child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//               Icon(Icons.block_rounded, color: Colors.grey.shade500, size: 20),
//               Text('منتهي',
//                   style: TextStyle(fontSize: 8, color: Colors.grey.shade500)),
//             ]),
//           ),
//           title: Text('$firstName $lastName',
//               style: TextStyle(
//                   fontWeight: FontWeight.w700,
//                   fontSize: 15,
//                   color: isDark ? Colors.white70 : Colors.black54)),
//           subtitle: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 4),
//               if (phone.isNotEmpty)
//                 Row(children: [
//                   Icon(Icons.phone_rounded,
//                       size: 14,
//                       color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
//                   const SizedBox(width: 4),
//                   Text(phone,
//                       style: TextStyle(
//                           color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
//                           fontSize: 12)),
//                 ]),
//               const SizedBox(height: 4),
//               Row(children: [
//                 Icon(Icons.calendar_today_rounded,
//                     size: 14,
//                     color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
//                 const SizedBox(width: 4),
//                 Text(
//                   '${_formatDate(date1)}${date2Bool && date2 != null ? ' - ${_formatDate(date2)}' : ''}',
//                   style: TextStyle(
//                       color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
//                       fontSize: 12),
//                 ),
//               ]),
//               const SizedBox(height: 6),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade400.withOpacity(0.15),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.grey.shade400.withOpacity(0.3)),
//                 ),
//                 child: Text('انتهت منذ $daysAgo يوم',
//                     style: TextStyle(
//                         fontSize: 11,
//                         color: Colors.grey.shade500,
//                         fontWeight: FontWeight.w500)),
//               ),
//             ],
//           ),
//           children: [
//             _buildDetails(res, reservationId, groomId, '$firstName $lastName',
//                 paymentStatus, isDark),
//           ],
//         ),
//       ),
//     );
//   }
// }