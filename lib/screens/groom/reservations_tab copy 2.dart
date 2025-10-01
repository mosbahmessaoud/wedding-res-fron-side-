// // lib/screens/home/tabs/reservations_tab.dart
// import 'package:flutter/material.dart';
// import 'dart:typed_data';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:open_file/open_file.dart';
// import 'package:wedding_reservation_app/screens/groom/create_reservation_screen.dart';
// import '../../../services/api_service.dart';
// import '../../../utils/colors.dart';

// class ReservationsTab extends StatefulWidget {
//   const ReservationsTab({super.key});

//   @override
//   State<ReservationsTab> createState() => ReservationsTabState();
// }

// class ReservationsTabState extends State<ReservationsTab> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   bool _isLoading = true;
//   bool _isRefreshing = false; // Add refresh state indicator
  
//   Map<String, dynamic>? _pendingReservation;
//   Map<String, dynamic>? _validatedReservation;
//   List<dynamic> _cancelledReservations = [];
//   List<dynamic> _allReservations = [];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//     _loadReservations();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//   void refreshData() {
//     // Add your reservations refresh logic here
//     // For example:
//     _loadReservations();
//     _refreshReservations();
//     setState(() {
//       // Trigger rebuild
//     });
//   }
//   Future<void> _loadReservations() async {
//     setState(() => _isLoading = true);
    
//     try {
//       // Load all reservation types
//       _allReservations = await ApiService.getMyAllReservations();
      
//       try {
//         _pendingReservation = await ApiService.getMyPendingReservation();
//       } catch (e) {
//         _pendingReservation = null;
//       }
      
//       try {
//         _validatedReservation = await ApiService.getMyValidatedReservation();
//       } catch (e) {
//         _validatedReservation = null;
//       }
      
//       _cancelledReservations = await ApiService.getMyCancelledReservations();
      
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('خطأ في تحميل الحجوزات: ${e.toString()}')),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   // Enhanced refresh method with better UX
//   Future<void> _refreshReservations() async {
//     if (_isRefreshing) return; // Prevent multiple simultaneous refreshes
    
//     setState(() => _isRefreshing = true);
    
//     try {
//       // Load all reservations first
//       _allReservations = await ApiService.getMyAllReservations();
      
//       // Load pending reservation with proper error handling
//       try {
//         _pendingReservation = await ApiService.getMyPendingReservation();
//       } catch (e) {
//         _pendingReservation = null;
//       }
      
//       // Load validated reservation with proper error handling
//       try {
//         _validatedReservation = await ApiService.getMyValidatedReservation();
//       } catch (e) {
//         _validatedReservation = null;
//       }
      
//       // Load cancelled reservations
//       _cancelledReservations = await ApiService.getMyCancelledReservations();
      
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('تم تحديث الحجوزات بنجاح'),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 2),
//           ),
//         );
//       }
      
//     } catch (e) {
//       if (mounted) {
//         // ScaffoldMessenger.of(context).showSnackBar(
//         //   SnackBar(
//         //     content: Text('خطأ في تحديث الحجوزات: ${e.toString()}'),
//         //     backgroundColor: Colors.red,
//         //   ),
//         // );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isRefreshing = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           color: Colors.white,
//           child: TabBar(
//             controller: _tabController,
//             labelColor: AppColors.primary,
//             unselectedLabelColor: AppColors.textSecondary,
//             indicatorColor: AppColors.primary,
//             isScrollable: true,
//             tabs: const [
//               Tab(text: 'الكل'),
//               Tab(text: 'معلق'),
//               Tab(text: 'مؤكد'),
//               Tab(text: 'ملغي'),
//             ],
//           ),
//         ),
//         Expanded(
//           child: _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : TabBarView(
//                   controller: _tabController,
//                   children: [
//                     _buildAllReservationsTab(),
//                     _buildPendingReservationTab(),
//                     _buildValidatedReservationTab(),
//                     _buildCancelledReservationsTab(),
//                   ],
//                 ),
//         ),
//       ],
//     );
//   }

//   Widget _buildAllReservationsTab() {
//     if (_allReservations.isEmpty) {
//       return RefreshIndicator(
//         onRefresh: _refreshReservations,
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           child: Container(
//             height: MediaQuery.of(context).size.height * 0.6,
//             child: _buildEmptyState(
//               icon: Icons.calendar_today,
//               title: 'لا توجد حجوزات',
//               subtitle: 'لم تقم بأي حجوزات حتى الآن\nاسحب لأسفل للتحديث',
//             ),
//           ),
//         ),
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: _refreshReservations,
//       child: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         physics: const AlwaysScrollableScrollPhysics(),
//         itemCount: _allReservations.length + 1, // +1 for refresh indicator space
//         itemBuilder: (context, index) {
//           if (index == _allReservations.length) {
//             // Add some space at the bottom for better pull-to-refresh experience
//             return const SizedBox(height: 80);
//           }
//           final reservation = _allReservations[index];
//           return _buildReservationCard(reservation);
//         },
//       ),
//     );
//   }

//   Widget _buildPendingReservationTab() {
//     if (_pendingReservation == null) {
//       return RefreshIndicator(
//         onRefresh: _refreshReservations,
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           child: Container(
//             height: MediaQuery.of(context).size.height * 0.6,
//             child: _buildEmptyState(
//               icon: Icons.pending_actions,
//               title: 'لا توجد حجوزات معلقة',
//               subtitle: 'جميع حجوزاتك تم التعامل معها\nاسحب لأسفل للتحديث',
//               actionButton: ElevatedButton(
//                 onPressed: _navigateToNewReservation,
//                 child: const Text('حجز جديد'),
//               ),
//             ),
//           ),
//         ),
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: _refreshReservations,
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         physics: const AlwaysScrollableScrollPhysics(),
//         child: Column(
//           children: [
//             _buildDetailedReservationCard(
//               _pendingReservation!,
//               showActions: true,
//               actions: [
//                 ElevatedButton.icon(
//                   onPressed: () => _cancelReservation(_pendingReservation!['id']),
//                   icon: const Icon(Icons.cancel),
//                   label: const Text('إلغاء الحجز'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red,
//                     foregroundColor: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 80), // Space for refresh indicator
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildValidatedReservationTab() {
//     if (_validatedReservation == null) {
//       return RefreshIndicator(
//         onRefresh: _refreshReservations,
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           child: Container(
//             height: MediaQuery.of(context).size.height * 0.6,
//             child: _buildEmptyState(
//               icon: Icons.check_circle,
//               title: 'لا توجد حجوزات مؤكدة',
//               subtitle: 'لم يتم تأكيد أي حجوزات حتى الآن\nاسحب لأسفل للتحديث',
//             ),
//           ),
//         ),
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: _refreshReservations,
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         physics: const AlwaysScrollableScrollPhysics(),
//         child: Column(
//           children: [
//             _buildDetailedReservationCard(
//               _validatedReservation!,
//               showActions: true,
//               actions: [
//                 ElevatedButton.icon(
//                   onPressed: () => _downloadPdf(_validatedReservation!['id']),
//                   icon: const Icon(Icons.download),
//                   label: const Text('تحميل الملف'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     foregroundColor: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 80), // Space for refresh indicator
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCancelledReservationsTab() {
//     if (_cancelledReservations.isEmpty) {
//       return RefreshIndicator(
//         onRefresh: _refreshReservations,
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           child: Container(
//             height: MediaQuery.of(context).size.height * 0.6,
//             child: _buildEmptyState(
//               icon: Icons.cancel,
//               title: 'لا توجد حجوزات ملغاة',
//               subtitle: 'لم تقم بإلغاء أي حجوزات\nاسحب لأسفل للتحديث',
//             ),
//           ),
//         ),
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: _refreshReservations,
//       child: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         physics: const AlwaysScrollableScrollPhysics(),
//         itemCount: _cancelledReservations.length + 1, // +1 for refresh indicator space
//         itemBuilder: (context, index) {
//           if (index == _cancelledReservations.length) {
//             // Add some space at the bottom for better pull-to-refresh experience
//             return const SizedBox(height: 80);
//           }
//           final reservation = _cancelledReservations[index];
//           return _buildReservationCard(reservation, showStatus: true);
//         },
//       ),
//     );
//   }

//   Widget _buildReservationCard(Map<String, dynamic> reservation, {bool showStatus = false}) {
//     // Format dates properly
//     String formatDates(Map<String, dynamic> reservation) {
//       final date1 = reservation['date1'];
//       final date2 = reservation['date2'];
//       final date2Bool = reservation['date2_bool'] ?? false;
      
//       if (date1 == null) return 'غير محدد';
      
//       if (date2Bool && date2 != null) {
//         return '$date1 - $date2';
//       }
//       return date1;
//     }

//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'حجز رقم: ${reservation['id']}',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 _buildStatusChip(reservation['status']),
//               ],
//             ),
//             const SizedBox(height: 12),
//             _buildInfoRow(Icons.event, 'التاريخ', formatDates(reservation)),
//             const SizedBox(height: 8),
//             _buildInfoRow(Icons.family_restroom, 'العشيرة', _getClanName(reservation)),
//             const SizedBox(height: 8),
//             _buildInfoRow(Icons.location_city, 'المحافظة', _getCountyName(reservation)),
//             const SizedBox(height: 8),
//             _buildInfoRow(Icons.home, 'القاعة', _getHallName(reservation)),
//             const SizedBox(height: 8),
//             _buildInfoRow(Icons.access_time, 'تاريخ الإنشاء', _formatDateTime(reservation['created_at'])),
//             const SizedBox(height: 12),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 TextButton(
//                   onPressed: () => _showReservationDetails(reservation),
//                   child: const Text('عرض التفاصيل'),
//                 ),
//                 Row(
//                   children: [
//                     // PDF Download button - always show for validated reservations
//                     // if (reservation['status'] == 'validated')
//                       Container(
//                         margin: const EdgeInsets.only(left: 8),
//                         child: ElevatedButton.icon(
//                           onPressed: () => _downloadPdf(reservation['id']),
//                           icon: const Icon(Icons.picture_as_pdf, size: 16),
//                           label: const Text('PDF', style: TextStyle(fontSize: 12)),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.primary,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                             minimumSize: const Size(0, 32),
//                           ),
//                         ),
//                       ),
//                     // Alternative: Icon button for smaller footprint
//                       IconButton(
//                         onPressed: () => _downloadPdf(reservation['id']),
//                         icon: const Icon(Icons.download),
//                         color: AppColors.primary,
//                         tooltip: 'تحميل PDF',
//                       ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailedReservationCard(
//     Map<String, dynamic> reservation, {
//     bool showActions = false,
//     List<Widget> actions = const [],
//   }) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'تفاصيل الحجز #${reservation['id']}',
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 _buildStatusChip(reservation['status']),
//               ],
//             ),
//             const Divider(height: 24),
            
//             // Reservation Basic Information
//             _buildDetailSection('معلومات أساسية', [
//               _buildInfoRow(Icons.event, 'التاريخ الأول', reservation['date1'] ?? 'غير محدد'),
//               if (reservation['date2_bool'] == true && reservation['date2'] != null)
//                 _buildInfoRow(Icons.event_available, 'التاريخ الثاني', reservation['date2']),
//               _buildInfoRow(Icons.family_restroom, 'العشيرة', _getClanName(reservation)),
//               _buildInfoRow(Icons.location_city, 'المحافظة', _getCountyName(reservation)),
//               _buildInfoRow(Icons.access_time, 'تاريخ الإنشاء', _formatDateTime(reservation['created_at'])),
//               if (reservation['expires_at'] != null)
//                 _buildInfoRow(Icons.schedule, 'تاريخ الانتهاء', _formatDateTime(reservation['expires_at'])),
//             ]),
            
//             const SizedBox(height: 16),
            
//             // Location and Committees Information
//             _buildDetailSection('معلومات المكان واللجان', [
//               _buildInfoRow(Icons.home, 'القاعة', _getHallName(reservation)),
//               _buildInfoRow(Icons.group, 'لجنة الهيئة', _getCommitteeName(reservation, 'haia_committee')),
//               _buildInfoRow(Icons.restaurant_menu, 'لجنة المذائح', _getCommitteeName(reservation, 'madaeh_committee')),
//             ]),
            
//             const SizedBox(height: 16),
            
//             // Personal Information
//             _buildDetailSection('المعلومات الشخصية', [
//               _buildInfoRow(Icons.person, 'الاسم الكامل', _getFullName(reservation)),
//               _buildInfoRow(Icons.cake, 'تاريخ الميلاد', reservation['birth_date'] ?? 'غير محدد'),
//               _buildInfoRow(Icons.location_on, 'مكان الميلاد', reservation['birth_address'] ?? 'غير محدد'),
//               _buildInfoRow(Icons.home_outlined, 'عنوان السكن', reservation['home_address'] ?? 'غير محدد'),
//               _buildInfoRow(Icons.phone, 'رقم الهاتف', reservation['phone_number'] ?? 'غير محدد'),
//             ]),
            
//             const SizedBox(height: 16),
            
//             // Guardian Information
//             if (_hasGuardianInfo(reservation))
//               _buildDetailSection('معلومات ولي الأمر', [
//                 _buildInfoRow(Icons.person_outline, 'اسم ولي الأمر', reservation['guardian_name'] ?? 'غير محدد'),
//                 _buildInfoRow(Icons.phone_android, 'هاتف ولي الأمر', reservation['guardian_phone'] ?? 'غير محدد'),
//                 _buildInfoRow(Icons.home_work, 'عنوان ولي الأمر', reservation['guardian_home_address'] ?? 'غير محدد'),
//                 _buildInfoRow(Icons.location_searching, 'مكان ولادة ولي الأمر', reservation['guardian_birth_address'] ?? 'غير محدد'),
//                 _buildInfoRow(Icons.calendar_today, 'تاريخ ولادة ولي الأمر', reservation['guardian_birth_date'] ?? 'غير محدد'),
//               ]),
            
//             const SizedBox(height: 16),
            
//             // Options and Settings
//             _buildDetailSection('الخيارات والإعدادات', [
//               _buildInfoRow(
//                 Icons.people_alt, 
//                 'السماح للآخرين بالانضمام', 
//                 (reservation['allow_others'] == true) ? 'نعم' : 'لا'
//               ),
//               _buildInfoRow(
//                 Icons.groups, 
//                 'الانضمام للزفاف الجماعي', 
//                 (reservation['join_to_mass_wedding'] == true) ? 'نعم' : 'لا'
//               ),
//             ]),

//             // Important Note for Pending Reservations            
//             if (reservation['status'] == 'pending_validation') ...[
//               const SizedBox(height: 16),
              
//               // Important Note for Pending Reservations
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: const Color.fromARGB(255, 253, 227, 227),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: const Color.fromARGB(255, 249, 144, 144)),
//                 ),
//                 child: Directionality(
//                   textDirection: TextDirection.rtl, // النصوص من اليمين لليسار
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch, // النصوص تلتزم بالـ RTL
//                     children: [
//                       // الجزء اللي في الوسط
//                       Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             Icons.info,
//                             color: const Color.fromARGB(255, 249, 144, 144),
//                             size: 32,
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             'ملاحظة مهمة',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: const Color.fromARGB(255, 0, 0, 0),
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),

//                     // النص الرئيسي RTL
//                     Text(
//                       'للحصول على الموافقة النهائية، يجب طباعة الحجز وختمه وتوقيعه من:\n'
//                       '- الهيئة الدينية\n'
//                       '- (يتم الاستقبال يوم ${} في الساعة ${})الدار المضيفة (في حالة الحجز في عشيرة أخرى)\n'// so if the clan origin and clan selected to reservation the same hiden this line oky . // and also on this line you can get the selected clan to reserv in from the reservation table on this column 'groom_id' by the 'groom_id' you can get the user table then on the User table you can get the clan_id then by the clan_id you can get the clan name
//                       '- (يتم الاستقبال يوم ${} في الساعة ${}) إدارة عشيرتك\n\n' // on this line you can get clan origin of the user from the reservation table on this column 'clan_id' by the 'clan_id' you can get the clan name
//                       'يجب استكمال هذه الإجراءات خلال 10 أيام كحد أقصى، وإلا يُلغى الحجز تلقائيًا.\n\n'
//                       'بعد ختم وتوقيع جميع الجهات، توجّه إلى إدارة عشيرتك ليؤكد حجزك في النظام.',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Color.fromARGB(255, 0, 0, 0),
//                         height: 1.5,
//                       ),
//                       textAlign: TextAlign.start,
//                     ),

//                     ],
//                   ),
//                 ),
//               ),
//             ],

//             // Enhanced PDF Download Section for validated reservations
//             // if (reservation['status'] == 'validated') ...[
//               const SizedBox(height: 16),
//               _buildDetailSection('تحميل الملفات', [
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.green.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.green.withOpacity(0.3)),
//                   ),
//                   child: Column(
//                     children: [
//                       Icon(
//                         Icons.picture_as_pdf,
//                         size: 48,
//                         color: Colors.green,
//                       ),
//                       const SizedBox(height: 12),
//                       const Text(
//                         'ملف الحجز جاهز للتحميل',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.green,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       const Text(
//                         'يمكنك تحميل ملف PDF الخاص بحجزك المؤكد',
//                         style: TextStyle(fontSize: 14),
//                       ),
//                       const SizedBox(height: 16),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton.icon(
//                           onPressed: () => _downloadPdf(reservation['id']),
//                           icon: const Icon(Icons.download),
//                           label: const Text('تحميل ملف PDF'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ]),
//             // ],
            
//             if (showActions && actions.isNotEmpty) ...[
//               const SizedBox(height: 20),
//               Wrap(
//                 spacing: 8,
//                 runSpacing: 8,
//                 children: actions,
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailSection(String title, List<Widget> children) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//           decoration: BoxDecoration(
//             color: AppColors.primary.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: AppColors.primary.withOpacity(0.3)),
//           ),
//           child: Text(
//             title,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: AppColors.primary,
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),
//         ...children,
//       ],
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 20, color: AppColors.textSecondary),
//           const SizedBox(width: 12),
//           Expanded(
//             flex: 2,
//             child: Text(
//               '$label:',
//               style: const TextStyle(
//                 fontWeight: FontWeight.w500,
//                 color: AppColors.textSecondary,
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Text(
//               value,
//               style: const TextStyle(
//                 color: AppColors.textPrimary,
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusChip(String? status) {
//     Color color;
//     String text;
    
//     switch (status?.toLowerCase()) {
//       case 'pending_validation':
//         color = Colors.orange;
//         text = 'معلق التأكيد';
//         break;
//       case 'validated':
//         color = Colors.green;
//         text = 'مؤكد';
//         break;
//       case 'cancelled':
//         color = Colors.red;
//         text = 'ملغي';
//         break;
//       default:
//         color = Colors.grey;
//         text = status ?? 'غير محدد';
//     }

//     return Chip(
//       label: Text(
//         text,
//         style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
//       ),
//       backgroundColor: color.withOpacity(0.1),
//       side: BorderSide(color: color.withOpacity(0.5)),
//     );
//   }

//   Widget _buildEmptyState({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     Widget? actionButton,
//   }) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             icon,
//             size: 64,
//             color: AppColors.textSecondary,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: AppColors.textPrimary,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             subtitle,
//             style: const TextStyle(
//               fontSize: 16,
//               color: AppColors.textSecondary,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           if (actionButton != null) ...[
//             const SizedBox(height: 24),
//             actionButton,
//           ],
//         ],
//       ),
//     );
//   }

//   void _showReservationDetails(Map<String, dynamic> reservation) {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         insetPadding: const EdgeInsets.all(16),
//         child: Container(
//           constraints: const BoxConstraints(maxHeight: 700, maxWidth: 500),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               AppBar(
//                 title: const Text('تفاصيل الحجز'),
//                 automaticallyImplyLeading: false,
//                 actions: [
//                   // Add PDF download button in the app bar for validated reservations
//                   // if (reservation['status'] == 'validated')
//                     IconButton(
//                       icon: const Icon(Icons.picture_as_pdf),
//                       onPressed: () => _downloadPdf(reservation['id']),
//                       tooltip: 'تحميل PDF',
//                     ),
//                   // Add refresh button in dialog
//                   IconButton(
//                     icon: const Icon(Icons.refresh),
//                     onPressed: () {
//                       Navigator.pop(context);
//                       _refreshReservations();
//                     },
//                     tooltip: 'تحديث',
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ],
//               ),
//               Flexible(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.all(16),
//                   child: _buildDetailedReservationCard(reservation),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _cancelReservation(int reservationId) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('تأكيد الإلغاء'),
//         content: const Text('هل أنت متأكد من رغبتك في إلغاء هذا الحجز؟\nلا يمكن التراجع عن هذا الإجراء.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('تأكيد الإلغاء'),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true) {
//       try {
//         await ApiService.cancelMyReservation(reservationId);
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('تم إلغاء الحجز بنجاح'),
//               backgroundColor: Colors.green,
//             ),
//           );
//           _refreshReservations(); // Use enhanced refresh method
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('خطأ في إلغاء الحجز: ${e.toString()}'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     }
//   }

//   // Updated _downloadPdf method with improved functionality
//   Future<void> _downloadPdf(int reservationId) async {
//     try {
//       setState(() => _isLoading = true);
//       _showSnackBar('جاري تحميل الملف...', Colors.blue.shade400);
      
//       // Download the PDF
//       final pdfBytes = await ApiService.downloadPdfFromServer(reservationId);
      
//       // Save the file
//       final savedFile = await _savePdfFile(pdfBytes, reservationId);
      
//       if (savedFile != null) {
//         _showSnackBar('تم تحميل الملف بنجاح', Colors.green.shade400);
        
//         // Try to open the file
//         try {
//           await OpenFile.open(savedFile.path);
//         } catch (e) {
//           print('Could not open file: $e');
//           // Show dialog with file location
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

//   // Save PDF file to device
//   Future<File?> _savePdfFile(Uint8List pdfBytes, int reservationId) async {
//     try {
//       Directory? directory;
      
//       if (Platform.isAndroid) {
//         // Request storage permission first
//         var status = await Permission.storage.status;
//         if (!status.isGranted) {
//           status = await Permission.storage.request();
//           if (!status.isGranted) {
//             // Try with manage external storage permission for Android 11+
//             status = await Permission.manageExternalStorage.request();
//             if (!status.isGranted) {
//               throw Exception('يجب منح صلاحية الوصول للتخزين لحفظ الملف');
//             }
//           }
//         }
        
//         // Try to get external storage directory
//         directory = await getExternalStorageDirectory();
//         if (directory != null) {
//           // Create a public folder path
//           String publicPath = directory.path.replaceAll(
//             RegExp(r'Android/data/[^/]+/files'), 
//             'Download'
//           );
//           directory = Directory(publicPath);
          
//           // If public path doesn't exist, use app directory
//           if (!await directory.exists()) {
//             directory = await getExternalStorageDirectory();
//           }
//         }
//       } else {
//         // iOS
//         directory = await getApplicationDocumentsDirectory();
//       }
      
//       if (directory == null) {
//         throw Exception('لا يمكن الوصول إلى مجلد التخزين');
//       }
      
//       // Ensure directory exists
//       if (!await directory.exists()) {
//         await directory.create(recursive: true);
//       }
      
//       // Create file with timestamp for uniqueness
//       final timestamp = DateTime.now().millisecondsSinceEpoch;
//       final fileName = 'reservation_${reservationId}_$timestamp.pdf';
//       final file = File('${directory.path}/$fileName');
      
//       // Write bytes to file
//       await file.writeAsBytes(pdfBytes);
      
//       return file;
//     } catch (e) {
//       print('Error saving file: $e');
//       return null;
//     }
//   }

//   // Helper method to show snack bar
//   void _showSnackBar(String message, Color backgroundColor) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: backgroundColor,
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     }
//   }

//   // Show dialog with file location when auto-open fails
//   void _showFileLocationDialog(String filePath) {
//     if (!mounted) return;
    
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('تم حفظ الملف'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('تم حفظ ملف PDF بنجاح في:'),
//             const SizedBox(height: 8),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.grey.shade300),
//               ),
//               child: Text(
//                 filePath,
//                 style: const TextStyle(
//                   fontSize: 12,
//                   fontFamily: 'monospace',
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),
//             const Text(
//               'يمكنك العثور على الملف في مجلد التحميلات أو في مدير الملفات.',
//               style: TextStyle(fontSize: 14),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('موافق'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               // Try to open file again
//               try {
//                 await OpenFile.open(filePath);
//               } catch (e) {
//                 _showSnackBar('لا يمكن فتح الملف تلقائياً', Colors.orange);
//               }
//             },
//             child: const Text('فتح الملف'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _navigateToNewReservation() {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => const CreateReservationScreen(),
//       ),
//     ).then((_) {
//       // Refresh reservations when returning from create screen
//       _refreshReservations(); // Use enhanced refresh method
//     });
//   }

//   // Helper methods for getting proper names
//   String _getClanName(Map<String, dynamic> reservation) {
//     // Try different possible field names for clan
//     return reservation['clan_name'] ?? 
//            reservation['clan']?['name'] ?? 
//            reservation['clanName'] ?? 
//            'لم يتم الاختيار بعد';
//   }

//   String _getCountyName(Map<String, dynamic> reservation) {
//     // Try different possible field names for county
//     return reservation['county_name'] ?? 
//            reservation['county']?['name'] ?? 
//            reservation['countyName'] ?? 
//            'لم يتم الاختيار بعد';
//   }

//   String _getHallName(Map<String, dynamic> reservation) {
//     // Try different possible field names for hall
//     return reservation['hall_name'] ?? 
//            reservation['hall']?['name'] ?? 
//            reservation['hallName'] ?? 
//            'لم يتم الاختيار بعد';
//   }

//   String _getCommitteeName(Map<String, dynamic> reservation, String type) {
//     // Try different possible field names for committees
//     final fieldName = '${type}_name';
//     final nestedName = '${type}Name';
    
//     return reservation[fieldName] ?? 
//            reservation[type]?['name'] ?? 
//            reservation[nestedName] ?? 
//            'لم يتم الاختيار بعد';
//   }

//   String _getFullName(Map<String, dynamic> reservation) {
//     final firstName = reservation['first_name'] ?? '';
//     final lastName = reservation['last_name'] ?? '';
//     final fatherName = reservation['father_name'] ?? '';
//     final grandfatherName = reservation['grandfather_name'] ?? '';
    
//     final List nameParts = [firstName, fatherName, grandfatherName, lastName]
//         .where((part) => part.isNotEmpty)
//         .toList();
    
//     return nameParts.isEmpty ? 'غير محدد' : nameParts.join(' ');
//   }

//   String _formatDateTime(dynamic dateTime) {
//     if (dateTime == null) return 'غير محدد';
    
//     try {
//       DateTime parsedDate;
//       if (dateTime is String) {
//         parsedDate = DateTime.parse(dateTime);
//       } else if (dateTime is DateTime) {
//         parsedDate = dateTime;
//       } else {
//         return 'غير محدد';
//       }
      
//       return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year} ${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}';
//     } catch (e) {
//       return dateTime.toString();
//     }
//   }

//   bool _hasGuardianInfo(Map<String, dynamic> reservation) {
//     return reservation['guardian_name'] != null ||
//            reservation['guardian_phone'] != null ||
//            reservation['guardian_home_address'] != null ||
//            reservation['guardian_birth_address'] != null ||
//            reservation['guardian_birth_date'] != null;
//   }
// }