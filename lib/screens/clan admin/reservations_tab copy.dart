// // lib/screens/clan_admin/reservations_tab.dart
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../services/api_service.dart';

// class ReservationsTab extends StatefulWidget {
//   const ReservationsTab({super.key});

//   @override
//   State<ReservationsTab> createState() => _ReservationsTabState();
// }

// class _ReservationsTabState extends State<ReservationsTab> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   List<dynamic> _allReservations = [];
//   List<dynamic> _pendingReservations = [];
//   List<dynamic> _validatedReservations = [];
//   List<dynamic> _cancelledReservations = [];
//   bool _isLoading = false;
//   String _searchQuery = '';

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//     _loadAllReservations();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadAllReservations() async {
//     setState(() => _isLoading = true);
//     try {
//       final results = await Future.wait([
//         ApiService.getAllReservations(),
//         ApiService.getPendingReservations(),
//         ApiService.getValidatedReservations(),
//         ApiService.getCancelledReservations(),
//       ]);


//       setState(() {
//         _allReservations = results[0];
//         _pendingReservations = results[1];
//         _validatedReservations = results[2];
//         _cancelledReservations = results[3];
//       });
//     } catch (e) {
//       _showErrorSnackBar('خطأ في تحميل الحجوزات: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _validateReservation(int groomId, String groomName) async {
//     final confirmed = await _showConfirmationDialog(
//       'تأكيد الحجز',
//       'هل أنت متأكد من تأكيد حجز $groomName؟',
//     );

//     if (!confirmed) return;

//     try {
//       setState(() => _isLoading = true);
//       await ApiService.validateReservation(groomId);
//       await _loadAllReservations();
//       _showSuccessSnackBar('تم تأكيد الحجز بنجاح');
//     } catch (e) {
//       _showErrorSnackBar('خطأ في تأكيد الحجز: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _cancelReservation(int groomId, String groomName) async {
//     final confirmed = await _showConfirmationDialog(
//       'إلغاء الحجز',
//       'هل أنت متأكد من إلغاء حجز $groomName؟',
//     );

//     if (!confirmed) return;

//     try {
//       setState(() => _isLoading = true);
//       await ApiService.cancelGroomReservationByClanAdmin(groomId);
//       await _loadAllReservations();
//       _showSuccessSnackBar('تم إلغاء الحجز بنجاح');
//     } catch (e) {
//       _showErrorSnackBar('خطأ في إلغاء الحجز: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _downloadPdf(int reservationId) async {
//     try {
//       setState(() => _isLoading = true);
//       final pdfData = await ApiService.downloadPdf(reservationId);
//       // Handle PDF download - this would typically save to device or open in viewer
//       _showSuccessSnackBar('تم تحميل الملف بنجاح');
//     } catch (e) {
//       _showErrorSnackBar('خطأ في تحميل الملف: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   List<dynamic> _getFilteredReservations(List<dynamic> reservations) {
//     if (_searchQuery.isEmpty) return reservations;
    
//     return reservations.where((reservation) {
//       final guardianName = reservation['guardian_name']?.toString().toLowerCase() ?? '';
//       final fatherName = reservation['father_name']?.toString().toLowerCase() ?? '';
//       final phoneNumber = reservation['phone_number']?.toString() ?? '';
//       final query = _searchQuery.toLowerCase();
      
//       return guardianName.contains(query) || 
//              fatherName.contains(query) || 
//              phoneNumber.contains(query);
//     }).toList();
//   }

//   Future<bool> _showConfirmationDialog(String title, String content) async {
//     return await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(title),
//         content: Text(content),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('إلغاء'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             style: TextButton.styleFrom(foregroundColor: Colors.blue),
//             child: const Text('تأكيد'),
//           ),
//         ],
//       ),
//     ) ?? false;
//   }

//   void _showSuccessSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.green),
//     );
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.red),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // Search Bar
//         Padding(
//           padding: const EdgeInsets.all(16),
//           child: TextField(
//             onChanged: (value) => setState(() => _searchQuery = value),
//             decoration: InputDecoration(
//               hintText: 'البحث بالاسم أو رقم الهاتف...',
//               prefixIcon: const Icon(Icons.search),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               suffixIcon: _searchQuery.isNotEmpty
//                   ? IconButton(
//                       icon: const Icon(Icons.clear),
//                       onPressed: () => setState(() => _searchQuery = ''),
//                     )
//                   : null,
//             ),
//           ),
//         ),
        
//         // Statistics Cards
//         _buildStatisticsCards(),
        
//         // Tab Bar
//         TabBar(
//           controller: _tabController,
//           isScrollable: true,
//           tabs: [
//             Tab(text: 'الكل (${_allReservations.length})'),
//             Tab(text: 'معلقة (${_pendingReservations.length})'),
//             Tab(text: 'مؤكدة (${_validatedReservations.length})'),
//             Tab(text: 'ملغاة (${_cancelledReservations.length})'),
//           ],
//         ),
        
//         // Tab Views
//         Expanded(
//           child: _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : TabBarView(
//                   controller: _tabController,
//                   children: [
//                     _buildReservationsList(_getFilteredReservations(_allReservations), 'all'),
//                     _buildReservationsList(_getFilteredReservations(_pendingReservations), 'pending'),
//                     _buildReservationsList(_getFilteredReservations(_validatedReservations), 'validated'),
//                     _buildReservationsList(_getFilteredReservations(_cancelledReservations), 'cancelled'),
//                   ],
//                 ),
//         ),
//       ],
//     );
//   }

//   Widget _buildStatisticsCards() {
//     return Container(
//       height: 100,
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       child: Row(
//         children: [
//           Expanded(child: _buildStatCard('الإجمالي', _allReservations.length, Colors.blue)),
//           const SizedBox(width: 8),
//           Expanded(child: _buildStatCard('معلقة', _pendingReservations.length, Colors.orange)),
//           const SizedBox(width: 8),
//           Expanded(child: _buildStatCard('مؤكدة', _validatedReservations.length, Colors.green)),
//           const SizedBox(width: 8),
//           Expanded(child: _buildStatCard('ملغاة', _cancelledReservations.length, Colors.red)),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatCard(String title, int count, Color color) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               count.toString(),
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//             Text(
//               title,
//               style: const TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildReservationsList(List<dynamic> reservations, String type) {
//     if (reservations.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               _getEmptyIcon(type),
//               size: 64,
//               color: Colors.grey,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               _getEmptyMessage(type),
//               style: const TextStyle(fontSize: 18, color: Colors.grey),
//             ),
//           ],
//         ),
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: _loadAllReservations,
//       child: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: reservations.length,
//         itemBuilder: (context, index) {
//           return _buildReservationCard(reservations[index], type);
//         },
//       ),
//     );
//   }

//   Widget _buildReservationCard(Map<String, dynamic> reservation, String type) {
//     final status = reservation['status'] ?? '';
//     final groomId = reservation['groom_id'] ?? 0;
//     final reservationId = reservation['id'] ?? 0;
//     final guardianName = reservation['guardian_name'] ?? 'غير محدد';
//     final fatherName = reservation['father_name'] ?? 'غير محدد';
//     final phoneNumber = reservation['phone_number'] ?? 'غير محدد';
//     final date1 = reservation['date1'] ?? '';
//     final date2 = reservation['date2'];
//     final date2Bool = reservation['date2_bool'] ?? false;
//     final joinToMass = reservation['join_to_mass_wedding'] ?? false;
//     final allowOthers = reservation['allow_others'] ?? false;
//     final createdAt = reservation['created_at'] ?? '';
//     final expiresAt = reservation['expires_at'];

//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: ExpansionTile(
//         title: Text(
//           '$guardianName - $fatherName',
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('الهاتف: $phoneNumber'),
//             Text('التاريخ: ${_formatDate(date1)}${date2Bool && date2 != null ? ' - ${_formatDate(date2)}' : ''}'),
//             _buildStatusChip(status),
//           ],
//         ),
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildDetailRow('رقم الحجز:', reservationId.toString()),
//                 _buildDetailRow('اسم الولي:', guardianName),
//                 _buildDetailRow('اسم الأب:', fatherName),
//                 _buildDetailRow('رقم الهاتف:', phoneNumber),
//                 _buildDetailRow('اليوم الأول:', _formatDate(date1)),
//                 if (date2Bool && date2 != null)
//                   _buildDetailRow('اليوم الثاني:', _formatDate(date2)),
//                 _buildDetailRow('حفل جماعي:', joinToMass ? 'نعم' : 'لا'),
//                 _buildDetailRow('يسمح للآخرين بالانضمام:', allowOthers ? 'نعم' : 'لا'),
//                 _buildDetailRow('تاريخ الإنشاء:', _formatDateTime(createdAt)),
//                 if (expiresAt != null)
//                   _buildDetailRow('تاريخ انتهاء الصلاحية:', _formatDateTime(expiresAt)),
                
//                 const SizedBox(height: 16),
//                 _buildActionButtons(reservation, status, groomId, reservationId, guardianName),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 140,
//             child: Text(
//               label,
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(child: Text(value)),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusChip(String status) {
//     Color color;
//     String displayText;
    
//     switch (status.toLowerCase()) {
//       case 'pending_validation':
//         color = Colors.orange;
//         displayText = 'معلق';
//         break;
//       case 'validated':
//         color = Colors.green;
//         displayText = 'مؤكد';
//         break;
//       case 'cancelled':
//         color = Colors.red;
//         displayText = 'ملغي';
//         break;
//       default:
//         color = Colors.grey;
//         displayText = status;
//     }

//     return Container(
//       margin: const EdgeInsets.only(top: 4),
//       child: Chip(
//         label: Text(displayText, style: const TextStyle(color: Colors.white)),
//         backgroundColor: color,
//         materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//       ),
//     );
//   }

//   Widget _buildActionButtons(Map<String, dynamic> reservation, String status, int groomId, int reservationId, String groomName) {
//     List<Widget> buttons = [];

//     // Download PDF button (always available)
//     buttons.add(
//       ElevatedButton.icon(
//         onPressed: () => _downloadPdf(reservationId),
//         icon: const Icon(Icons.download),
//         label: const Text('تحميل PDF'),
//         style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
//       ),
//     );

//     // Status-specific action buttons
//     if (status == 'pending_validation') {
//       buttons.add(
//         ElevatedButton.icon(
//           onPressed: () => _validateReservation(groomId, groomName),
//           icon: const Icon(Icons.check),
//           label: const Text('تأكيد'),
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//         ),
//       );
//       buttons.add(
//         ElevatedButton.icon(
//           onPressed: () => _cancelReservation(groomId, groomName),
//           icon: const Icon(Icons.cancel),
//           label: const Text('إلغاء'),
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//         ),
//       );
//     } else if (status == 'validated') {
//       buttons.add(
//         ElevatedButton.icon(
//           onPressed: () => _cancelReservation(groomId, groomName),
//           icon: const Icon(Icons.cancel),
//           label: const Text('إلغاء'),
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//         ),
//       );
//     }

//     return Wrap(
//       spacing: 8,
//       runSpacing: 8,
//       children: buttons,
//     );
//   }

//   IconData _getEmptyIcon(String type) {
//     switch (type) {
//       case 'pending':
//         return Icons.hourglass_empty;
//       case 'validated':
//         return Icons.check_circle_outline;
//       case 'cancelled':
//         return Icons.cancel_outlined;
//       default:
//         return Icons.event_note;
//     }
//   }

//   String _getEmptyMessage(String type) {
//     switch (type) {
//       case 'pending':
//         return 'لا توجد حجوزات معلقة';
//       case 'validated':
//         return 'لا توجد حجوزات مؤكدة';
//       case 'cancelled':
//         return 'لا توجد حجوزات ملغاة';
//       default:
//         return 'لا توجد حجوزات';
//     }
//   }

//   String _formatDate(String? dateString) {
//     if (dateString == null || dateString.isEmpty) return 'غير محدد';
//     try {
//       final date = DateTime.parse(dateString);
//       return DateFormat('yyyy/MM/dd', 'ar').format(date);
//     } catch (e) {
//       return dateString;
//     }
//   }

//   String _formatDateTime(String? dateTimeString) {
//     if (dateTimeString == null || dateTimeString.isEmpty) return 'غير محدد';
//     try {
//       final dateTime = DateTime.parse(dateTimeString);
//       return DateFormat('yyyy/MM/dd HH:mm', 'ar').format(dateTime);
//     } catch (e) {
//       return dateTimeString;
//     }
//   }
// }