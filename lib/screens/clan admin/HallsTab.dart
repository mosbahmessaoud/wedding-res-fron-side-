// lib/screens/home/tabs/halls_tab.dart
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/api_service.dart';
import '../../../utils/colors.dart';
import 'hall_form_dialog.dart';

class HallsTab extends StatefulWidget {
  final int? clanId; // Add clan ID parameter

  const HallsTab({super.key, this.clanId});

  @override
  HallsTabState createState() => HallsTabState();
}

class HallsTabState extends State<HallsTab> {
  List<dynamic> halls = [];
  bool isLoading = true;
  String errorMessage = '';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _checkConnectivityAndLoad();
  }
 void refreshData() {

    _checkConnectivityAndLoad();
    setState(() {
      
    });
  }
// Add this method in HallsTabState class

Future<void> _checkConnectivityAndLoad() async {
  setState(() {
    isLoading = true;
  });
  
  // Show loading for 2 seconds
  await Future.delayed(Duration(seconds: 2));
  final connectivityResult = await Connectivity().checkConnectivity();
  
  if (connectivityResult.contains(ConnectivityResult.none)) {
    _showNoInternetDialog();
    setState(() {
      isLoading = false;
    });
    return;
  }
  
  try {
    await _loadInitialData();
  } catch (e) {
    setState(() {
      errorMessage = e.toString();
      isLoading = false;
    });
  }
}
void _showNoInternetDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.orange),
          SizedBox(width: 10),
          Text('لا يوجد اتصال'),
        ],
      ),
      content: Text('يرجى التحقق من اتصالك بالإنترنت'),
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
          child: Text('إعادة المحاولة'),
        ),
      ],
    ),
  );
}

Future<void> _loadInitialData() async {
  await Future.wait([
    _loadHalls(),
    
    
    // Load other necessary data here if needed
  ]);
  
  // Refresh the UI to update dropdown options after menus are loaded
  if (mounted) {
    setState(() {});
  }
}
  Future<void> _loadHalls() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final response = await ApiService.listHalls();
      setState(() {
        // Filter halls by clan_id if provided
        if (widget.clanId != null) {
          halls = response.where((hall) => hall['clan_id'] == widget.clanId).toList();
        } else {
          halls = response;
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _createHall() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => HallFormDialog(clanId: widget.clanId),
    );
    print("result================== ${json.encode(result)}");
    if (result != null) {
      try {
        await ApiService.createHall(result);
        _showSnackBar('تم إنشاء القاعة بنجاح', Colors.green);
        _loadHalls();
      } catch (e) {
        _showSnackBar('فشل في إنشاء القاعة: ${e.toString()}', Colors.red);
      }
    }
  }

  Future<void> _editHall(Map<String, dynamic> hall) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => HallFormDialog(hall: hall),
    );
    
    if (result != null) {
      try {
        await ApiService.updateHall(hall['id'], result);
        _showSnackBar('تم تحديث القاعة بنجاح', Colors.green);
        _loadHalls();
      } catch (e) {
        _showSnackBar('فشل في تحديث القاعة: ${e.toString()}', Colors.red);
      }
    }
  }

  Future<void> _deleteHall(int hallId, String hallName) async {
    final confirmed = await _showDeleteConfirmation(hallName);
    if (confirmed) {
      try {
        await ApiService.deleteHall(hallId);
        _showSnackBar('تم حذف القاعة بنجاح', Colors.green);
        _loadHalls();
      } catch (e) {
        _showSnackBar('فشل في حذف القاعة: ${e.toString()}', Colors.red);
      }
    }
  }

  Future<bool> _showDeleteConfirmation(String hallName) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'تأكيد الحذف',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'هل أنت متأكد من حذف القاعة "$hallName"؟',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'إلغاء',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'حذف',
              style: TextStyle(color: Colors.white),
            ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  List<dynamic> get filteredHalls {
    if (searchQuery.isEmpty) return halls;
    return halls.where((hall) {
      final name = hall['name']?.toString().toLowerCase() ?? '';
      final clanId = hall['clan_id']?.toString().toLowerCase() ?? '';
      final query = searchQuery.toLowerCase();
      return name.contains(query) || clanId.contains(query);
    }).toList();
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('إدارة القاعات',
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
    ),
    body: LayoutBuilder(
      
      builder: (context, constraints) {
        Padding(padding: EdgeInsetsGeometry.directional(bottom: 80));
        bool isSmallScreen = constraints.maxWidth < 800;
        
        if (isSmallScreen) {
          // Small screens - Vertical layout
          return Column(
            children: [
              // Compact header for small screens
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Clan info section (full width)
                    if (widget.clanId != null)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.groups, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'العشيرة: ${widget.clanId}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Add button (full width)
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 16),
                      child: ElevatedButton.icon(
                        onPressed: _createHall,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        icon: Icon(Icons.add_circle_outline, size: 20),
                        label: Text(
                          'إضافة قاعة جديدة',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    // Search bar (full width)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'البحث في القاعات...',
                          hintStyle: TextStyle(color: AppColors.textSecondary),
                          prefixIcon: Container(
                            margin: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.search, color: AppColors.primary, size: 20),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: Container(
                  color: Colors.grey[50],
                  child: _buildContent(),
                ),
              ),
            ],
          );
        } else {
          // Large screens - Horizontal layout
          return Row(
            children: [
              // Left Section - Sidebar
              Container(
                width: constraints.maxWidth < 1200 
                    ? constraints.maxWidth * 0.3  // 30% for medium screens
                    : 350,  // Fixed width for large screens
                constraints: BoxConstraints(
                  minWidth: 280,
                  maxWidth: 400,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Clan info section
                      if (widget.clanId != null)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.groups,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'معلومات العشيرة',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Text(
                                'العشيرة: ${widget.clanId}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      SizedBox(height: 32),
                      
                      // Add new hall button section
                      Container(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _createHall,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 4,
                            shadowColor: Colors.black.withOpacity(0.3),
                          ),
                          icon: Icon(Icons.add_circle_outline, size: 24),
                          label: Text(
                            'إضافة قاعة جديدة',
                            style: TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 32),
                      
                      // Search section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'البحث',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 12,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'البحث في القاعات...',
                                hintStyle: TextStyle(color: AppColors.textSecondary),
                                prefixIcon: Container(
                                  margin: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.search, color: AppColors.primary),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      Spacer(),
                      
                      // Footer info for large screens
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.white.withOpacity(0.8), size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'إدارة القاعات',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Right Section - Main Content
              Expanded(
                child: Container(
                  color: Colors.grey[50],
                  child: _buildContent(),
                ),
              ),
            ],
          );
        }
        

      },
      
    ),
  );
}

  Widget _buildContent() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 3,
            ),
            SizedBox(height: 20),
            Text(
              'جاري تحميل القاعات...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            SizedBox(height: 20),
            Text(
              'حدث خطأ في تحميل البيانات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 10),
            Text(
              errorMessage,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _checkConnectivityAndLoad,
              icon: Icon(Icons.refresh),
              label: Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      );
    }

    if (filteredHalls.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              searchQuery.isNotEmpty ? Icons.search_off : Icons.meeting_room_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 20),
            Text(
              searchQuery.isNotEmpty 
                ? 'لا توجد نتائج للبحث'
                : widget.clanId != null
                  ? 'لا توجد قاعات لهذه العشيرة'
                  : 'لا توجد قاعات حالياً',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 10),
            Text(
              searchQuery.isNotEmpty
                ? 'جرب البحث بكلمات مختلفة'
                : 'ابدأ بإضافة قاعة جديدة',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            if (searchQuery.isEmpty) ...[
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _createHall,
                icon: Icon(Icons.add),
                label: Text('إضافة قاعة جديدة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHalls,
      color: AppColors.primary,
      child: ListView.builder(
        padding: EdgeInsets.all(20),
        itemCount: filteredHalls.length,
        itemBuilder: (context, index) {
          final hall = filteredHalls[index];
          return _buildHallCard(hall, index);
        },
      ),
    );
  }

  Widget _buildHallCard(dynamic hall, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showHallDetails(hall),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Hall icon
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.meeting_room,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      // Hall info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hall['name'] ?? 'اسم غير محدد',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            if (widget.clanId == null)
                              Text(
                                'العشيرة: ${hall['clan_id'] ?? 'غير محدد'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Action buttons
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _editHall(hall);
                          } else if (value == 'delete') {
                            _deleteHall(hall['id'], hall['name']);
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: AppColors.primary, size: 20),
                                SizedBox(width: 8),
                                Text('تعديل', style: TextStyle(color: AppColors.primary)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red, size: 20),
                                SizedBox(width: 8),
                                Text('حذف', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.more_vert,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Hall details
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.people,
                        'السعة: ${hall['capacity'] ?? 'غير محدد'}',
                        Colors.blue,
                      ),
                      if (widget.clanId == null) ...[
                        SizedBox(width: 8),
                        _buildInfoChip(
                          Icons.groups,
                          'العشيرة: ${hall['clan_id'] ?? 'غير محدد'}',
                          Colors.purple,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showHallDetails(dynamic hall) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 4,
              width: 40,
              margin: EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hall['name'] ?? 'اسم غير محدد',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 10),
                    if (widget.clanId == null)
                      Text(
                        'العشيرة: ${hall['clan_id'] ?? 'غير محدد'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailItem(
                            'السعة',
                            hall['capacity']?.toString() ?? 'غير محدد',
                            Icons.people,
                            Colors.blue,
                          ),
                        ),
                        if (widget.clanId == null) ...[
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildDetailItem(
                              'العشيرة',
                              hall['clan_id']?.toString() ?? 'غير محدد',
                              Icons.groups,
                              Colors.purple,
                            ),
                          ),
                        ],
                      ],
                    ),

                    SizedBox(height: 30),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _editHall(hall);
                            },
                            icon: Icon(Icons.edit),
                            label: Text('تعديل القاعة'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _deleteHall(hall['id'], hall['name']);
                            },
                            icon: Icon(Icons.delete),
                            label: Text('حذف القاعة'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
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
}