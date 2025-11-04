// lib/screens/clan_admin/special_reservations_tab.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../utils/colors.dart';

class SpecialReservationsTab extends StatefulWidget {
  const SpecialReservationsTab({super.key});

  @override
  State<SpecialReservationsTab> createState() => SpecialReservationsTabState();
}

class SpecialReservationsTabState extends State<SpecialReservationsTab> {
  List<Map<String, dynamic>> _specialReservations = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterStatus = 'all'; // all, validated, cancelled, archive

  @override
  void initState() {
    super.initState();
    _checkConnectivityAndLoad();
  }
    void refreshData() {
    _checkConnectivityAndLoad();
  }


Future<void> _checkConnectivityAndLoad() async {
  setState(() {
    _isLoading = true;
  });
  
  // Show loading for 2 seconds
  await Future.delayed(Duration(seconds: 2));
  final connectivityResult = await Connectivity().checkConnectivity();
  
  if (connectivityResult.contains(ConnectivityResult.none)) {
    _showNoInternetDialog();
    setState(() {
      _isLoading = false;
    });
    return;
  }
  
  await _loadSpecialReservations();
}

void _showNoInternetDialog() {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.orange),
          SizedBox(width: 10),
          Text('لا يوجد اتصال', 
            style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        ],
      ),
      content: Text('يرجى التحقق من اتصالك بالإنترنت',
        style: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade700)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _checkConnectivityAndLoad();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text('إعادة المحاولة', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
  Future<void> _loadSpecialReservations() async {

    setState(() => _isLoading = true);
    try {
      final reservations = await ApiService.getAllSpecialReservations();
      setState(() {
        _specialReservations = reservations.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('فشل في تحميل الحجوزات الخاصة: $e');
    }
  }


  List<Map<String, dynamic>> get _filteredReservations {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    var filtered = _specialReservations.where((reserv) {
      // Search by name, date, full name, or phone
      final searchLower = _searchQuery.toLowerCase();
      final matchesName = reserv['reserv_name']
          .toString()
          .toLowerCase()
          .contains(searchLower);
      final matchesDate = _formatDate(reserv['date'] ?? '')
          .toLowerCase()
          .contains(searchLower);
      final matchesFullName = (reserv['full_name'] ?? '')
          .toString()
          .toLowerCase()
          .contains(searchLower);
      final matchesPhone = (reserv['phone_number'] ?? '')
          .toString()
          .toLowerCase()
          .contains(searchLower);
      final matchesSearch = matchesName || matchesDate || matchesFullName || matchesPhone;
      
      // Parse reservation date
      DateTime? reservDate;
      try {
        reservDate = DateTime.parse(reserv['date'] ?? '');
        reservDate = DateTime(reservDate.year, reservDate.month, reservDate.day);
      } catch (e) {
        reservDate = null;
      }
      
      // Filter based on status and archive
      bool matchesFilter = false;
      
      if (_filterStatus == 'archive') {
        // Archive: only past reservations
        matchesFilter = reservDate != null && reservDate.isBefore(today);
      } else if (_filterStatus == 'all') {
        // All: only current and future reservations
        matchesFilter = reservDate != null && !reservDate.isBefore(today);
      } else {
        // Validated or Cancelled: only current and future + matching status
        final statusMatch = reserv['status'].toString().toLowerCase() == _filterStatus;
        matchesFilter = reservDate != null && !reservDate.isBefore(today) && statusMatch;
      }
      
      return matchesSearch && matchesFilter;
    }).toList();

    // Sort by date - closest to current time first
    filtered.sort((a, b) {
      try {
        final dateA = DateTime.parse(a['date'] ?? '');
        final dateB = DateTime.parse(b['date'] ?? '');
        
        if (_filterStatus == 'archive') {
          // For archive, show most recent past dates first
          return dateB.compareTo(dateA);
        } else {
          // For current/future, show closest upcoming dates first
          final diffA = dateA.difference(now).abs();
          final diffB = dateB.difference(now).abs();
          return diffA.compareTo(diffB);
        }
      } catch (e) {
        return 0;
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 1024;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1024;
    final isPhone = screenSize.width <= 600;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: _loadSpecialReservations,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // Custom App Bar
            SliverAppBar(
              expandedHeight: isPhone ? 140 : 180,
              floating: false,
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: isDark
                  ? const Color(0xFF2D2D2D)
                  : Colors.white,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        AppColors.primary.withOpacity(0.8),
                        AppColors.primary.withOpacity(0.6),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(isPhone ? 16 : 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(isPhone ? 8 : 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.event_busy_rounded,
                                  color: Colors.white,
                                  size: isPhone ? 24 : 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'الحجوزات الخاصة',
                                      style: TextStyle(
                                        fontSize: isPhone ? 22 : 28,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'إدارة التواريخ المحجوزة للعشيرة',
                                      style: TextStyle(
                                        fontSize: isPhone ? 12 : 14,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Search and Filter Section
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(isPhone ? 12 : 16),
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) => setState(() => _searchQuery = value),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: isPhone ? 14 : 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'البحث بالاسم، التاريخ، الاسم الكامل أو الهاتف...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.white38 : Colors.grey,
                            fontSize: isPhone ? 14 : 16,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: isDark ? Colors.white60 : Colors.grey,
                            size: isPhone ? 20 : 24,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isPhone ? 12 : 20,
                            vertical: isPhone ? 12 : 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('الحالية', 'all', isDark, isPhone),
                          const SizedBox(width: 8),
                          _buildFilterChip('مفعّل', 'validated', isDark, isPhone),
                          const SizedBox(width: 8),
                          _buildFilterChip('ملغي', 'cancelled', isDark, isPhone),
                          const SizedBox(width: 8),
                          _buildFilterChip('الأرشيف', 'archive', isDark, isPhone),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Statistics Card
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isPhone ? 12 : 16),
                child: _buildStatisticsCard(isDark, isPhone),
              ),
            ),

            // Reservations List
            _isLoading
                ? SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : _filteredReservations.isEmpty
                    ? SliverFillRemaining(
                        child: _buildEmptyState(isDark, isPhone),
                      )
                    : SliverPadding(
                        padding: EdgeInsets.all(isPhone ? 12 : 16),
                        sliver: isPhone
                            ? SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final reservation = _filteredReservations[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: _buildReservationCard(
                                        reservation,
                                        isDark,
                                        isPhone,
                                      ),
                                    );
                                  },
                                  childCount: _filteredReservations.length,
                                ),
                              )
                            : SliverGrid(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isLargeScreen ? 3 : 2,
                                  childAspectRatio: isLargeScreen ? 1.4 : 1.2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final reservation = _filteredReservations[index];
                                    return _buildReservationCard(
                                      reservation,
                                      isDark,
                                      isPhone,
                                    );
                                  },
                                  childCount: _filteredReservations.length,
                                ),
                              ),
                      ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 120),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddReservationDialog(isDark),
          backgroundColor: AppColors.primary,
          icon: Icon(Icons.add, color: Colors.white, size: isPhone ? 20 : 24),
          label: Text(
            'حجز جديد',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: isPhone ? 14 : 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool isDark, bool isPhone) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterStatus = value);
      },
      backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? AppColors.primary
            : (isDark ? Colors.white70 : Colors.black87),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: isPhone ? 13 : 14,
      ),
      side: BorderSide(
        color: isSelected
            ? AppColors.primary
            : (isDark ? Colors.white12 : Colors.grey.shade300),
      ),
      padding: EdgeInsets.symmetric(horizontal: isPhone ? 8 : 12, vertical: isPhone ? 4 : 8),
    );
  }

  Widget _buildStatisticsCard(bool isDark, bool isPhone) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final currentCount = _specialReservations.where((r) {
      try {
        final date = DateTime.parse(r['date'] ?? '');
        final reservDate = DateTime(date.year, date.month, date.day);
        return !reservDate.isBefore(today);
      } catch (e) {
        return false;
      }
    }).length;
    
    final archiveCount = _specialReservations.where((r) {
      try {
        final date = DateTime.parse(r['date'] ?? '');
        final reservDate = DateTime(date.year, date.month, date.day);
        return reservDate.isBefore(today);
      } catch (e) {
        return false;
      }
    }).length;
    
    final validatedCount = _specialReservations
        .where((r) => r['status'] == 'validated')
        .length;
    final cancelledCount = _specialReservations
        .where((r) => r['status'] == 'cancelled')
        .length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(isPhone ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('الحالية', currentCount.toString(), Icons.event_available, isDark, isPhone),
              _buildStatItem('الأرشيف', archiveCount.toString(), Icons.archive, isDark, isPhone),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: isDark ? Colors.white12 : Colors.grey.shade200,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('مفعّل', validatedCount.toString(), Icons.check_circle, isDark, isPhone),
              _buildStatItem('ملغي', cancelledCount.toString(), Icons.cancel, isDark, isPhone),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, bool isDark, bool isPhone) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: isPhone ? 24 : 28),
        SizedBox(height: isPhone ? 6 : 8),
        Text(
          value,
          style: TextStyle(
            fontSize: isPhone ? 20 : 24,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: isPhone ? 11 : 12,
            color: isDark ? Colors.white60 : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildReservationCard(
    Map<String, dynamic> reservation,
    bool isDark,
    bool isPhone,
  ) {
    final isValidated = reservation['status'] == 'validated';
    final date = reservation['date'] ?? '';
    final name = reservation['reserv_name'] ?? 'بدون اسم';
    final description = reservation['reserv_desctiption'] ?? '';
    final fullName = reservation['full_name'] ?? '';
    final homeAddress = reservation['home_address'] ?? '';
    final phoneNumber = reservation['phone_number'] ?? '';

    return InkWell(
      onTap: () => _showReservationDetailsDialog(reservation, isDark),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isValidated
                ? AppColors.primary.withOpacity(0.3)
                : Colors.red.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Status Badge
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isPhone ? 10 : 12,
                  vertical: isPhone ? 5 : 6,
                ),
                decoration: BoxDecoration(
                  color: isValidated
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isValidated ? Colors.green : Colors.red,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isValidated ? Icons.check_circle : Icons.cancel,
                      color: isValidated ? Colors.green : Colors.red,
                      size: isPhone ? 12 : 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isValidated ? 'مفعّل' : 'ملغي',
                      style: TextStyle(
                        color: isValidated ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: isPhone ? 10 : 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(isPhone ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: isPhone ? 28 : 32),

                  // Date Section
                  Container(
                    padding: EdgeInsets.all(isPhone ? 10 : 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: AppColors.primary,
                          size: isPhone ? 18 : 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _formatDate(date),
                            style: TextStyle(
                              fontSize: isPhone ? 14 : 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isPhone ? 10 : 12),

                  // Name
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: isPhone ? 16 : 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Full Name
                  if (fullName.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: isPhone ? 14 : 16,
                          color: isDark ? Colors.white60 : Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            fullName,
                            style: TextStyle(
                              fontSize: isPhone ? 12 : 13,
                              color: isDark ? Colors.white60 : Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Phone Number
                  if (phoneNumber.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: isPhone ? 14 : 16,
                          color: isDark ? Colors.white60 : Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            phoneNumber,
                            style: TextStyle(
                              fontSize: isPhone ? 12 : 13,
                              color: isDark ? Colors.white60 : Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: isPhone ? 12 : 13,
                        color: isDark ? Colors.white60 : Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  SizedBox(height: isPhone ? 10 : 12),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _toggleReservationStatus(reservation),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isValidated
                                ? Colors.red.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                            foregroundColor: isValidated ? Colors.red : Colors.green,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isValidated ? Colors.red : Colors.green,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: isPhone ? 10 : 12,
                            ),
                          ),
                          icon: Icon(
                            isValidated ? Icons.block : Icons.check_circle,
                            size: isPhone ? 16 : 18,
                          ),
                          label: Text(
                            isValidated ? 'إلغاء' : 'تفعيل',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: isPhone ? 12 : 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, bool isPhone) {
    final isArchive = _filterStatus == 'archive';
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isPhone ? 24 : 32),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isArchive ? Icons.archive : Icons.event_busy_rounded,
              size: isPhone ? 48 : 64,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          SizedBox(height: isPhone ? 16 : 24),
          Text(
            isArchive ? 'لا توجد حجوزات في الأرشيف' : 'لا توجد حجوزات حالية',
            style: TextStyle(
              fontSize: isPhone ? 18 : 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isArchive
                ? 'الحجوزات القديمة ستظهر هنا'
                : 'قم بإضافة حجز خاص لحجب تاريخ معين',
            style: TextStyle(
              fontSize: isPhone ? 13 : 14,
              color: isDark ? Colors.white60 : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showReservationDetailsDialog(Map<String, dynamic> reservation, bool isDark) {
    final screenSize = MediaQuery.of(context).size;
    final isPhone = screenSize.width <= 600;
    final isValidated = reservation['status'] == 'validated';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: isPhone ? 20 : 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'تفاصيل الحجز',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w700,
                  fontSize: isPhone ? 16 : 18,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status Badge
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isValidated
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isValidated ? Colors.green : Colors.red,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isValidated ? Icons.check_circle : Icons.cancel,
                        color: isValidated ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isValidated ? 'مفعّل' : 'ملغي',
                        style: TextStyle(
                          color: isValidated ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              _buildDetailRow(
                'التاريخ',
                _formatDate(reservation['date'] ?? ''),
                Icons.calendar_today,
                isDark,
              ),
              const SizedBox(height: 12),
              
              _buildDetailRow(
                'اسم الحجز',
                reservation['reserv_name'] ?? 'بدون اسم',
                Icons.event_note,
                isDark,
              ),
              
              if (reservation['full_name'] != null && reservation['full_name'].toString().isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  'الاسم الكامل',
                  reservation['full_name'],
                  Icons.person,
                  isDark,
                ),
              ],
              
              if (reservation['phone_number'] != null && reservation['phone_number'].toString().isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  'رقم الهاتف',
                  reservation['phone_number'],
                  Icons.phone,
                  isDark,
                ),
              ],
              
              if (reservation['home_address'] != null && reservation['home_address'].toString().isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  'العنوان',
                  reservation['home_address'],
                  Icons.location_on,
                  isDark,
                ),
              ],
              
              if (reservation['reserv_desctiption'] != null && reservation['reserv_desctiption'].toString().isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  'الوصف',
                  reservation['reserv_desctiption'],
                  Icons.description,
                  isDark,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إغلاق',
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.grey,
                fontSize: isPhone ? 14 : 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddReservationDialog(bool isDark) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final fullNameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    DateTime? selectedDate;
    final formKey = GlobalKey<FormState>();
    final screenSize = MediaQuery.of(context).size;
    final isPhone = screenSize.width <= 600;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.event_busy_rounded,
                  color: AppColors.primary,
                  size: isPhone ? 20 : 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'حجز تاريخ خاص',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: isPhone ? 16 : 18,
                  ),
                ),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Picker
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        locale: const Locale('ar', 'DZ'),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: AppColors.primary,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (date != null) {
                        setDialogState(() => selectedDate = date);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(isPhone ? 14 : 16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: AppColors.primary,
                            size: isPhone ? 20 : 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            selectedDate != null
                                ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                                : 'اختر التاريخ',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: isPhone ? 14 : 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name Field
                  TextFormField(
                    controller: nameController,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: isPhone ? 14 : 16,
                    ),
                    decoration: InputDecoration(
                      labelText: 'اسم الحجز *',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white60 : Colors.grey,
                        fontSize: isPhone ? 13 : 14,
                      ),
                      hintText: 'مثال: حفل عشيرة، اجتماع عام',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white38 : Colors.grey.shade400,
                        fontSize: isPhone ? 13 : 14,
                      ),
                      prefixIcon: Icon(
                        Icons.event_note,
                        color: AppColors.primary,
                        size: isPhone ? 20 : 24,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white12 : Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'اسم الحجز مطلوب';
                      }
                      if (value.trim().length < 3) {
                        return 'الاسم قصير جداً (الحد الأدنى 3 أحرف)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Full Name Field
                  TextFormField(
                    controller: fullNameController,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: isPhone ? 14 : 16,
                    ),
                    decoration: InputDecoration(
                      labelText: 'الاسم الكامل (اختياري)',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white60 : Colors.grey,
                        fontSize: isPhone ? 13 : 14,
                      ),
                      hintText: 'اسم الشخص أو المسؤول',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white38 : Colors.grey.shade400,
                        fontSize: isPhone ? 13 : 14,
                      ),
                      prefixIcon: Icon(
                        Icons.person,
                        color: AppColors.primary,
                        size: isPhone ? 20 : 24,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white12 : Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Phone Number Field
                  TextFormField(
                    controller: phoneController,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: isPhone ? 14 : 16,
                    ),
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'رقم الهاتف (اختياري)',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white60 : Colors.grey,
                        fontSize: isPhone ? 13 : 14,
                      ),
                      hintText: 'مثال: 0555123456',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white38 : Colors.grey.shade400,
                        fontSize: isPhone ? 13 : 14,
                      ),
                      prefixIcon: Icon(
                        Icons.phone,
                        color: AppColors.primary,
                        size: isPhone ? 20 : 24,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white12 : Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Address Field
                  TextFormField(
                    controller: addressController,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: isPhone ? 14 : 16,
                    ),
                    decoration: InputDecoration(
                      labelText: 'العنوان (اختياري)',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white60 : Colors.grey,
                        fontSize: isPhone ? 13 : 14,
                      ),
                      hintText: 'عنوان السكن',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white38 : Colors.grey.shade400,
                        fontSize: isPhone ? 13 : 14,
                      ),
                      prefixIcon: Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: isPhone ? 20 : 24,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white12 : Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description Field
                  TextFormField(
                    controller: descriptionController,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: isPhone ? 14 : 16,
                    ),
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'الوصف (اختياري)',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white60 : Colors.grey,
                        fontSize: isPhone ? 13 : 14,
                      ),
                      hintText: 'أضف تفاصيل إضافية...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white38 : Colors.grey.shade400,
                        fontSize: isPhone ? 13 : 14,
                      ),
                      prefixIcon: Icon(
                        Icons.description,
                        color: AppColors.primary,
                        size: isPhone ? 20 : 24,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white12 : Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.grey,
                  fontSize: isPhone ? 14 : 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate() && selectedDate != null) {
                  try {
                    await ApiService.createSpecialReservation(
                      date: selectedDate!.toString().split(' ')[0],
                      reservName: nameController.text.trim(),
                      reservDescription: descriptionController.text.trim().isEmpty
                          ? null
                          : descriptionController.text.trim(),
                      fullName: fullNameController.text.trim().isEmpty
                          ? null
                          : fullNameController.text.trim(),
                      phoneNumber: phoneController.text.trim().isEmpty
                          ? null
                          : phoneController.text.trim(),
                      homeAddress: addressController.text.trim().isEmpty
                          ? null
                          : addressController.text.trim(),
                    );
                    Navigator.pop(context);
                    _showSuccessSnackBar('تم إضافة الحجز الخاص بنجاح');
                    _loadSpecialReservations();
                  } catch (e) {
                    Navigator.pop(context);
                    _showErrorDialog('فشل في إضافة الحجز: $e');
                  }
                } else if (selectedDate == null) {
                  _showErrorDialog('يرجى اختيار التاريخ');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isPhone ? 20 : 24,
                  vertical: isPhone ? 10 : 12,
                ),
              ),
              child: Text(
                'إضافة',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: isPhone ? 14 : 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleReservationStatus(Map<String, dynamic> reservation) async {
    try {
      await ApiService.updateSpecialReservationStatus(reservation['id']);
      _showSuccessSnackBar('تم تحديث حالة الحجز بنجاح');
      _loadSpecialReservations();
    } catch (e) {
      _showErrorDialog('فشل في تحديث حالة الحجز: $e');
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('yyyy/MM/dd', 'fr').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorDialog(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isPhone = screenSize.width <= 600;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: isPhone ? 24 : 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'خطأ',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: isPhone ? 16 : 18,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              message,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: isPhone ? 14 : 16,
                height: 1.5,
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isPhone ? 20 : 24,
                  vertical: isPhone ? 10 : 12,
                ),
              ),
              child: Text(
                'حسناً',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: isPhone ? 14 : 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}