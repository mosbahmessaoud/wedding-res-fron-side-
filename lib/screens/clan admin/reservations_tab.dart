// lib/screens/clan_admin/reservations_tab.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;
import 'package:wedding_reservation_app/utils/colors.dart';
import '../../providers/theme_provider.dart';

import '../../services/api_service.dart';

class ReservationsTab extends StatefulWidget {
  const ReservationsTab({super.key});

  @override
  State<ReservationsTab> createState() => ReservationsTabState();
}

class ReservationsTabState extends State<ReservationsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _allReservations = [];
  List<dynamic> _pendingReservations = [];
  List<dynamic> _validatedReservations = [];
  List<dynamic> _cancelledReservations = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllReservations();
  }
  
  void refreshData() {
    _loadInitialData();
    setState(() {});
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadAllReservations(),
    ]);
    
    if (mounted) {
      setState(() {});
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllReservations() async {
    setState(() => _isLoading = true);
    
    try {
      List<dynamic> validatedRes = [];
      List<dynamic> cancelledRes = [];
      List<dynamic> pendingRes = [];
      List<dynamic> allRes = [];
      
      try {
        validatedRes = await ApiService.getValidatedReservations();
        print('✓ تم تحميل ${validatedRes.length} حجز مؤكد');
      } catch (e) {
        print('خطأ في الحجوزات المؤكدة: $e');
      }
      
      try {
        cancelledRes = await ApiService.getCancelledReservations();
        print('✓ تم تحميل ${cancelledRes.length} حجز ملغي');
      } catch (e) {
        print('خطأ في الحجوزات الملغاة: $e');
      }
      
      try {
        pendingRes = await ApiService.getPendingReservations();
        print('✓ تم تحميل ${pendingRes.length} حجز معلق');
      } catch (e) {
        print('⚠️ فشل في تحميل الحجوزات المعلقة: $e');
        pendingRes = [];
      }
      
      allRes = [...validatedRes, ...cancelledRes, ...pendingRes];
      
      setState(() {
        _validatedReservations = validatedRes;
        _cancelledReservations = cancelledRes;
        _pendingReservations = pendingRes;
        _allReservations = allRes;
      });
      
    } catch (e) {
      print('خطأ عام في تحميل الحجوزات: $e');
      
      setState(() {
        _allReservations = [];
        _pendingReservations = [];
        _validatedReservations = [];
        _cancelledReservations = [];
      });
      
      _showSnackBar('فشل في تحميل الحجوزات', Colors.red.shade400);
    } finally {
      setState(() => _isLoading = false);
    }
  }
Future<void> _togglePaymentStatus(int reservationId, String groomName, bool currentPaymentStatus) async {
  final action = currentPaymentStatus ? 'إلغاء تأكيد' : 'تأكيد';
  final confirmed = await _showConfirmationDialog(
    '$action الدفع',
    'هل أنت متأكد من $action دفع $groomName؟',
    currentPaymentStatus ? Colors.orange : Colors.blue,
    currentPaymentStatus ? Icons.money_off_rounded : Icons.payment_rounded,
  );

  if (!confirmed) return;

  try {
    setState(() => _isLoading = true);
    await ApiService.changePaymentStatus(reservationId);
    await _loadAllReservations();
    _showSnackBar(
      currentPaymentStatus ? 'تم إلغاء تأكيد الدفع' : 'تم تأكيد الدفع بنجاح', 
      currentPaymentStatus ? Colors.orange.shade400 : Colors.blue.shade400
    );
  } catch (e) {
    _showSnackBar('خطأ في تغيير حالة الدفع: $e', Colors.red.shade400);
  } finally {
    setState(() => _isLoading = false);
  }
}

// Update _validateReservation to check payment first
Future<void> _validateReservation(int groomId, String groomName, bool paymentValid) async {
  // Check if payment is completed first
  if (!paymentValid) {
    await _showPaymentRequiredDialog();
    return;
  }

  final confirmed = await _showConfirmationDialog(
    'تأكيد الحجز',
    'هل أنت متأكد من تأكيد حجز $groomName؟',
    Colors.green,
    Icons.check_circle,
  );

  if (!confirmed) return;

  try {
    setState(() => _isLoading = true);
    await ApiService.validateReservation(groomId);
    await _loadAllReservations();
    _showSnackBar('تم تأكيد الحجز بنجاح', Colors.green.shade400);
  } catch (e) {
    _showSnackBar('خطأ في تأكيد الحجز: $e', Colors.red.shade400);
  } finally {
    setState(() => _isLoading = false);
  }
}


// Add payment required dialog
Future<void> _showPaymentRequiredDialog() async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.warning_rounded, color: Colors.orange.shade400, size: 28),
          const SizedBox(width: 12),
          Text('تنبيه', style: TextStyle(color: Colors.orange.shade400, fontWeight: FontWeight.w600)),
        ],
      ),
      content: Text(
        'يجب على العريس دفع المبلغ المطلوب أولاً قبل تأكيد الحجز.\n\nالرجاء الضغط على زر "تأكيد الدفع" بعد استلام الدفع.',
        style: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade700),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('حسناً', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
        ),
      ],
    ),
  );
}
  Future<void> _cancelReservation(int groomId, String groomName) async {
    final confirmed = await _showConfirmationDialog(
      'إلغاء الحجز',
      'هل أنت متأكد من إلغاء حجز $groomName؟',
      Colors.red,
      Icons.cancel,
    );

    if (!confirmed) return;

    try {
      setState(() => _isLoading = true);
      await ApiService.cancelGroomReservationByClanAdmin(groomId);
      await _loadAllReservations();
      _showSnackBar('تم إلغاء الحجز بنجاح', Colors.orange.shade400);
    } catch (e) {
      _showSnackBar('خطأ في إلغاء الحجز: $e', Colors.red.shade400);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadPdf(int reservationId) async {
    try {
      setState(() => _isLoading = true);
      
      _showSnackBar('جاري تحميل الملف...', Colors.blue.shade400);
      
      final pdfBytes = await ApiService.downloadPdfFromServer(reservationId);
      final savedFile = await _savePdfFile(pdfBytes, reservationId);
      
      if (savedFile != null) {
        _showSnackBar('تم تحميل الملف بنجاح', Colors.green.shade400);
        
        try {
          await OpenFile.open(savedFile.path);
        } catch (e) {
          print('Could not open file: $e');
          _showFileLocationDialog(savedFile.path);
        }
      }
      
    } catch (e) {
      print('Download error: $e');
      _showSnackBar('خطأ في تحميل الملف: $e', Colors.red.shade400);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<File?> _savePdfFile(Uint8List pdfBytes, int reservationId) async {
    try {
      Directory? directory;
      
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        if (directory != null) {
          String publicPath = directory.path.replaceAll('Android/data/com.yourapp.name/files', 'Download');
          directory = Directory(publicPath);
          
          if (!await directory.exists()) {
            directory = await getExternalStorageDirectory();
          }
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      
      if (directory == null) {
        throw Exception('لا يمكن الوصول إلى مجلد التخزين');
      }
      
      final fileName = 'reservation_$reservationId.pdf';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsBytes(pdfBytes);
      
      return file;
    } catch (e) {
      print('Error saving file: $e');
      return null;
    }
  }

  void _showFileLocationDialog(String filePath) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        title: Text('تم حفظ الملف', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تم حفظ الملف في:', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
            SizedBox(height: 8),
            Text(
              filePath,
              style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            SizedBox(height: 16),
            Text('يمكنك العثور على الملف في تطبيق مدير الملفات', 
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('موافق', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPdfSimple(int reservationId) async {
    try {
      setState(() => _isLoading = true);
      
      _showSnackBar('جاري تحميل الملف...', Colors.blue.shade400);
      
      final pdfBytes = await ApiService.downloadPdfFromServer(reservationId);
      
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'reservation_$reservationId.pdf';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsBytes(pdfBytes);
      
      _showSnackBar('تم تحميل الملف بنجاح', Colors.green.shade400);
      
      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done) {
        _showFileLocationDialog(file.path);
      }
      
    } catch (e) {
      _showSnackBar('خطأ في تحميل الملف: $e', Colors.red.shade400);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<dynamic> _getFilteredReservations(List<dynamic> reservations) {
    if (_searchQuery.isEmpty) return reservations;
    
    return reservations.where((reservation) {
      final first_name = reservation['first_name']?.toString().toLowerCase() ?? '';
      final last_name = reservation['last_name']?.toString().toLowerCase() ?? '';
      final guardianName = reservation['guardian_name']?.toString().toLowerCase() ?? '';
      final fatherName = reservation['father_name']?.toString().toLowerCase() ?? '';
      final phoneNumber = reservation['phone_number']?.toString() ?? '';
      final query = _searchQuery.toLowerCase();
      
      return first_name.contains(query) || 
             last_name.contains(query) || 
             guardianName.contains(query) || 
             fatherName.contains(query) || 
             phoneNumber.contains(query);
    }).toList();
  }

  Future<bool> _showConfirmationDialog(String title, String content, Color color, IconData icon) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
        content: Text(content, style: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade700)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('إلغاء', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('تأكيد', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('الحجوزات',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/clan_admin_home');
          },
        ),
        actions: [
          const SizedBox(width: 8),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                size: 20,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            onPressed: () {
              final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
              themeProvider.toggleTheme();
            },
            tooltip: isDark ? 'الوضع الفاتح' : 'الوضع الداكن',
          ),
          const SizedBox(width: 8),
        ],
      ),
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey.shade50,
      body: Column(
        children: [
          // Modern Header with Search
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkInputBackground : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'البحث بالاسم أو رقم الهاتف...',
                      hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade500),
                      prefixIcon: Icon(Icons.search_rounded, 
                        color: isDark ? Colors.grey.shade500 : Colors.grey.shade400, size: 22),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear_rounded, 
                                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400, size: 20),
                              onPressed: () => setState(() => _searchQuery = ''),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Statistics Cards
                _buildModernStatistics(isDark),
              ],
            ),
          ),
          
          // Tab Bar
          Container(
            color: isDark ? AppColors.darkCard : Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              tabs: [
                Tab(text: 'الكل (${_allReservations.length})'),
                Tab(text: 'معلقة (${_pendingReservations.length})'),
                Tab(text: 'مؤكدة (${_validatedReservations.length})'),
                Tab(text: 'ملغاة (${_cancelledReservations.length})'),
              ],
            ),
          ),
          
          // Tab Views
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        const SizedBox(height: 16),
                        Text('جاري التحميل...', 
                          style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                      ],
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildReservationsList(_getFilteredReservations(_allReservations), 'all', isDark),
                      _buildReservationsList(_getFilteredReservations(_pendingReservations), 'pending', isDark),
                      _buildReservationsList(_getFilteredReservations(_validatedReservations), 'validated', isDark),
                      _buildReservationsList(_getFilteredReservations(_cancelledReservations), 'cancelled', isDark),
                    ],
                  ),
          ),
          SizedBox(height: 80), 
        ],
      ),
    );
  }

  Widget _buildModernStatistics(bool isDark) {
    final stats = [
      {'title': 'الإجمالي', 'count': _allReservations.length, 'color': Colors.blue.shade400, 'icon': Icons.event_note_rounded},
      {'title': 'معلقة', 'count': _pendingReservations.length, 'color': Colors.orange.shade400, 'icon': Icons.hourglass_empty_rounded},
      {'title': 'مؤكدة', 'count': _validatedReservations.length, 'color': Colors.green.shade400, 'icon': Icons.check_circle_rounded},
      {'title': 'ملغاة', 'count': _cancelledReservations.length, 'color': Colors.red.shade400, 'icon': Icons.cancel_rounded},
    ];

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];
          return Container(
            width: 95,
            margin: EdgeInsets.only(left: index < stats.length - 1 ? 12 : 0),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (stat['color'] as Color).withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: (stat['color'] as Color).withOpacity(isDark ? 0.3 : 0.2)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(stat['icon'] as IconData, color: stat['color'] as Color, size: 22),
                const SizedBox(height: 2),
                Text(
                  '${stat['count']}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: stat['color'] as Color,
                  ),
                ),
                Flexible(
                  child: Text(
                    stat['title'] as String,
                    style: TextStyle(fontSize: 9, 
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReservationsList(List<dynamic> reservations, String type, bool isDark) {
    if (reservations.isEmpty) {
      return _buildEmptyState(type, isDark);
    }

    return RefreshIndicator(
      onRefresh: _loadAllReservations,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: reservations.length,
        itemBuilder: (context, index) {
          return _buildModernReservationCard(reservations[index], type, isDark);
        },
      ),
    );
  }

  Widget _buildEmptyState(String type, bool isDark) {
    final emptyStates = {
      'pending': {'icon': Icons.hourglass_empty_rounded, 'message': 'لا توجد حجوزات معلقة'},
      'validated': {'icon': Icons.check_circle_outline_rounded, 'message': 'لا توجد حجوزات مؤكدة'},
      'cancelled': {'icon': Icons.cancel_outlined, 'message': 'لا توجد حجوزات ملغاة'},
      'all': {'icon': Icons.event_note_outlined, 'message': 'لا توجد حجوزات'},
    };

    final state = emptyStates[type] ?? emptyStates['all']!;

    return RefreshIndicator(
      onRefresh: _loadAllReservations,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: 400,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(state['icon'] as IconData, size: 64, 
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  state['message'] as String,
                  style: TextStyle(fontSize: 16, 
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade500, 
                    fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernReservationCard(Map<String, dynamic> reservation, String type, bool isDark) {
    final status = reservation['status'] ?? '';
    final groomId = reservation['groom_id'] ?? 0;
    final reservationId = reservation['id'] ?? 0;
    final first_name = reservation['first_name'] ?? 'غير محدد';
    final last_name = reservation['last_name'] ?? 'غير محدد';
    final guardianName = reservation['guardian_name'] ?? 'غير محدد';
    final fatherName = reservation['father_name'] ?? 'غير محدد';
    final phoneNumber = reservation['phone_number'] ?? 'غير محدد';
    final date1 = reservation['date1'] ?? '';
    final date2 = reservation['date2'];
    final date2Bool = reservation['date2_bool'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          collapsedBackgroundColor: isDark ? AppColors.darkCard : Colors.white,
          iconColor: isDark ? Colors.white70 : Colors.black87,
          collapsedIconColor: isDark ? Colors.white70 : Colors.black87,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          leading: CircleAvatar(
            backgroundColor: _getStatusColor(status).withOpacity(isDark ? 0.2 : 0.1),
            child: Icon(_getStatusIcon(status), color: _getStatusColor(status), size: 20),
          ),
          title: Text(
            '$first_name - $last_name',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, 
              color: isDark ? Colors.white : Colors.black87),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.phone_rounded, size: 16, 
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(phoneNumber, 
                    style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 16, 
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatDate(date1)}${date2Bool && date2 != null ? ' - ${_formatDate(date2)}' : ''}',
                    style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildModernStatusChip(status, isDark),
            ],
          ),
          children: [
            _buildReservationDetails(reservation, status, groomId, reservationId, guardianName, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationDetails(Map<String, dynamic> reservation, String status, int groomId, 
      int reservationId, String guardianName, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkInputBackground : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ..._buildDetailRows(reservation, isDark),
          const SizedBox(height: 16),
          _buildModernActionButtons(reservation, status, groomId, reservationId, guardianName),
        ],
      ),
    );
  }
List<Widget> _buildDetailRows(Map<String, dynamic> reservation, bool isDark) {
  final details = [
    ['رقم الحجز:', '${reservation['id'] ?? 0}'],
    ['اسم العريس (المستخدم):', reservation['first_name'] ?? 'غير محدد'],
    ['لقب العريس (المستخدم):', reservation['last_name'] ?? 'غير محدد'],
    ['اسم الولي:', reservation['guardian_name'] ?? 'غير محدد'],
    ['اسم الأب:', reservation['father_name'] ?? 'غير محدد'],
    ['رقم الهاتف:', reservation['phone_number'] ?? 'غير محدد'],
    ['اليوم الأول:', _formatDate(reservation['date1'])],
    if (reservation['date2_bool'] == true && reservation['date2'] != null)
      ['اليوم الثاني:', _formatDate(reservation['date2'])],
    ['حالة الدفع:', reservation['payment_valid'] == true ? '✓ مكتمل' : '✗ غير مكتمل'],  // ADDED
    ['حفل جماعي:', reservation['join_to_mass_wedding'] == true ? 'نعم' : 'لا'],
    ['يسمح للآخرين:', reservation['allow_others'] == true ? 'نعم' : 'لا'],
    ['تاريخ الإنشاء:', _formatDateTime(reservation['created_at'])],
    if (reservation['expires_at'] != null)
      ['تاريخ الانتهاء:', _formatDateTime(reservation['expires_at'])],
  ];

  return details.map((detail) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(detail[0], 
            style: TextStyle(fontWeight: FontWeight.w500, 
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700)),
        ),
        Expanded(
          child: Text(detail[1], 
            style: TextStyle(
              color: detail[0] == 'حالة الدفع:' 
                ? (reservation['payment_valid'] == true ? Colors.green : Colors.red)
                : (isDark ? Colors.white70 : Colors.grey.shade800),
              fontWeight: detail[0] == 'حالة الدفع:' ? FontWeight.w600 : FontWeight.normal,
            )),
        ),
      ],
    ),
  )).toList();
}

  Widget _buildModernStatusChip(String status, bool isDark) {
    final color = _getStatusColor(status);
    final displayText = _getStatusDisplayText(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(isDark ? 0.4 : 0.3)),
      ),
      child: Text(
        displayText,
        style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 12),
      ),
    );
  }
Widget _buildModernActionButtons(Map<String, dynamic> reservation, String status, int groomId, int reservationId, String groomName) {
  List<Widget> buttons = [];
  final paymentValid = reservation['payment_valid'] ?? false;

  // Download PDF button
  buttons.add(
    _buildActionButton(
      onPressed: () => _downloadPdfSimple(reservationId),
      icon: Icons.download_rounded,
      label: 'تحميل PDF',
      color: Colors.blue.shade400,
    ),
  );

  // Status-specific buttons
  if (status == 'pending_validation') {
    // Payment toggle button - shows appropriate action based on current status
    buttons.add(
      _buildActionButton(
        onPressed: () => _togglePaymentStatus(reservationId, groomName, paymentValid),
        icon: paymentValid ? Icons.money_off_rounded : Icons.payment_rounded,
        label: paymentValid ? 'إلغاء الدفع' : 'تأكيد الدفع',
        color: paymentValid ? Colors.orange.shade400 : Colors.indigo.shade400,
      ),
    );
    
    buttons.add(
      _buildActionButton(
        onPressed: () => _validateReservation(groomId, groomName, paymentValid),
        icon: Icons.check_rounded,
        label: 'تأكيد',
        color: Colors.green.shade400,
      ),
    );
    buttons.add(
      _buildActionButton(
        onPressed: () => _cancelReservation(groomId, groomName),
        icon: Icons.close_rounded,
        label: 'إلغاء',
        color: Colors.red.shade400,
      ),
    );
  } else if (status == 'validated') {
    // Payment toggle button - available in validated state too
    buttons.add(
      _buildActionButton(
        onPressed: () => _togglePaymentStatus(reservationId, groomName, paymentValid),
        icon: paymentValid ? Icons.money_off_rounded : Icons.payment_rounded,
        label: paymentValid ? 'إلغاء الدفع' : 'تأكيد الدفع',
        color: paymentValid ? Colors.orange.shade400 : Colors.indigo.shade400,
      ),
    );
    
    buttons.add(
      _buildActionButton(
        onPressed: () => _cancelReservation(groomId, groomName),
        icon: Icons.close_rounded,
        label: 'إلغاء',
        color: Colors.red.shade400,
      ),
    );
  }

  return Wrap(
    spacing: 8,
    runSpacing: 8,
    children: buttons,
  );
}



  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 0,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending_validation':
        return Colors.orange.shade400;
      case 'validated':
        return Colors.green.shade400;
      case 'cancelled':
        return Colors.red.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending_validation':
        return Icons.hourglass_empty_rounded;
      case 'validated':
        return Icons.check_circle_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.event_note_rounded;
    }
  }

  String _getStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'pending_validation':
        return 'معلق';
      case 'validated':
        return 'مؤكد';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'غير محدد';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy/MM/dd', 'fr').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return 'غير محدد';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('yyyy/MM/dd HH:mm', 'fr').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }
}