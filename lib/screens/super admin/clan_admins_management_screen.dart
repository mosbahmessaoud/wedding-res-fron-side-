// lib/screens/super_admin/clan_admins_management_screen.dart
import 'package:flutter/material.dart';
import 'package:wedding_reservation_app/models/county.dart';
import 'package:wedding_reservation_app/services/api_service.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import 'package:wedding_reservation_app/models/clan.dart';
class ClanAdminsManagementScreen extends StatefulWidget {
  const ClanAdminsManagementScreen({super.key});

  @override
  _ClanAdminsManagementScreenState createState() => _ClanAdminsManagementScreenState();
}

class _ClanAdminsManagementScreenState extends State<ClanAdminsManagementScreen>
    with TickerProviderStateMixin {
  
  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Data management
  List<dynamic> _counties = [];
  List<dynamic> _clans = [];
  List<dynamic> _clanAdmins = [];
  List<dynamic> _filteredAdmins = [];
  
  // State management
  bool _isLoading = true;
  String _errorMessage = '';
  int? _selectedCountyId;
  String _searchQuery = '';
  
  // Controllers
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadInitialData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    _animationController.forward();
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Load counties and clans in parallel
      final futures = await Future.wait([
        ApiService.listCountiesAdmin(),
        ApiService.getAllClans(),
      ]);

      setState(() {
        _counties = futures[0];
        _clans = futures[1];
        _isLoading = false;
      });

      // If there's only one county, auto-select it
// If there's only one county, auto-select it
    if (_counties.length == 1) {
      _selectedCountyId = _counties.first.id;  // Changed from _counties.first['id']
      _loadClanAdmins();
    }
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ في تحميل البيانات: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadClanAdmins() async {
    if (_selectedCountyId == null) return;

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final admins = await ApiService.getClanAdminsByCounty(_selectedCountyId!);
      
      setState(() {
        _clanAdmins = admins;
        _filteredAdmins = admins;
        _isLoading = false;
      });

      _applyFilters();
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ في تحميل مدراء العشائر: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredAdmins = _clanAdmins.where((admin) {
        if (_searchQuery.isEmpty) return true;
        
        final firstName = admin['first_name']?.toString().toLowerCase() ?? '';
        final lastName = admin['last_name']?.toString().toLowerCase() ?? '';
        final phoneNumber = admin['phone_number']?.toString() ?? '';
        final queryLower = _searchQuery.toLowerCase();
        
        return firstName.contains(queryLower) || 
               lastName.contains(queryLower) || 
               phoneNumber.contains(_searchQuery);
      }).toList();
    });
  }

  Future<void> _deleteClanAdmin(int adminId, String adminName) async {
    final confirmed = await _showDeleteConfirmationDialog(adminName);
    if (!confirmed) return;

    try {
      await ApiService.deleteClanAdmin(adminId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حذف مدير العشيرة بنجاح'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      _loadClanAdmins(); // Reload data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في حذف مدير العشيرة: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
Future<void> _updateClanAdmin(Map<String, dynamic> admin) async {
  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) => _buildUpdateAdminDialog(admin),
  );

  if (result != null) {
    try {
      await ApiService.updateClanAdmin(admin['id'], result);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث مدير العشيرة بنجاح'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      _loadClanAdmins(); // Reload data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحديث مدير العشيرة: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

  Future<bool> _showDeleteConfirmationDialog(String adminName) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('تأكيد الحذف'),
          ],
        ),
        content: Text(
          'هل أنت متأكد من حذف مدير العشيرة "$adminName"؟\n\nهذا الإجراء لا يمكن التراجع عنه.',
          style: TextStyle(fontSize: 16),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('حذف'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showAdminDetails(Map<String, dynamic> admin) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAdminDetailsSheet(admin),
    );
  }
Widget _buildUpdateAdminDialog(Map<String, dynamic> admin) {
  final formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController(text: admin['first_name']);
  final lastNameController = TextEditingController(text: admin['last_name']);
  final phoneController = TextEditingController(text: admin['phone_number']);
  final fatherNameController = TextEditingController(text: admin['father_name']);
  final grandfatherNameController = TextEditingController(text: admin['grandfather_name']);
  final birthAddressController = TextEditingController(text: admin['birth_address']);
  final homeAddressController = TextEditingController(text: admin['home_address']);
  final birthDateController = TextEditingController(text: admin['birth_date']);

  return Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
        maxWidth: MediaQuery.of(context).size.width * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(Icons.edit, color: AppColors.primary, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'تحديث بيانات مدير العشيرة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          
          // Form
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: firstNameController,
                            decoration: InputDecoration(
                              labelText: 'الاسم الأول',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) => value?.isEmpty == true ? 'الاسم الأول مطلوب' : null,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: lastNameController,
                            decoration: InputDecoration(
                              labelText: 'اسم العائلة',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) => value?.isEmpty == true ? 'اسم العائلة مطلوب' : null,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'رقم الهاتف',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) => value?.isEmpty == true ? 'رقم الهاتف مطلوب' : null,
                    ),
                    SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: fatherNameController,
                            decoration: InputDecoration(
                              labelText: 'اسم الأب',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: grandfatherNameController,
                            decoration: InputDecoration(
                              labelText: 'اسم الجد',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    TextFormField(
                      controller: birthDateController,
                      decoration: InputDecoration(
                        labelText: 'تاريخ الميلاد',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          birthDateController.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    
                    TextFormField(
                      controller: birthAddressController,
                      decoration: InputDecoration(
                        labelText: 'مكان الميلاد',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    TextFormField(
                      controller: homeAddressController,
                      decoration: InputDecoration(
                        labelText: 'عنوان السكن',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Buttons
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('إلغاء'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final updatedData = {
                          'first_name': firstNameController.text,
                          'last_name': lastNameController.text,
                          'phone_number': phoneController.text,
                          'father_name': fatherNameController.text,
                          'grandfather_name': grandfatherNameController.text,
                          'birth_date': birthDateController.text,
                          'birth_address': birthAddressController.text,
                          'home_address': homeAddressController.text,
                        };
                        Navigator.of(context).pop(updatedData);
                      }
                    },
                    child: Text('تحديث'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isDesktop = screenSize.width > 1200;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(isTablet, isDesktop),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _buildBody(isTablet, isDesktop),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isTablet, bool isDesktop) {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.admin_panel_settings,
              color: Colors.white,
              size: isDesktop ? 24 : 20,
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'إدارة مدراء العشائر',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: isDesktop ? 22 : isTablet ? 20 : 18,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'إدارة حسابات مدراء العشائر',
                style: TextStyle(
                  fontSize: isDesktop ? 12 : 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.white,
      foregroundColor: AppColors.primary,
      elevation: 0,
      shadowColor: Colors.transparent,
      actions: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.primary.withOpacity(0.05),
          ),
          child: IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadClanAdmins,
            style: IconButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.all(12),
            ),
          ),
        ),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody(bool isTablet, bool isDesktop) {
    final padding = isDesktop ? 32.0 : isTablet ? 24.0 : 16.0;

    if (_isLoading && _counties.isEmpty) {
      return _buildLoadingState(padding);
    }

    if (_errorMessage.isNotEmpty && _counties.isEmpty) {
      return _buildErrorState(padding);
    }

    return Column(
      children: [
        _buildFiltersSection(padding, isTablet, isDesktop),
        Expanded(
          child: _buildAdminsList(padding, isTablet, isDesktop),
        ),
      ],
    );
  }

  Widget _buildLoadingState(double padding) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            SizedBox(height: 16),
            Text(
              'جاري تحميل البيانات...',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(double padding) {
    return RefreshIndicator(
      onRefresh: _loadInitialData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height - 200,
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                _errorMessage,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadInitialData,
                icon: Icon(Icons.refresh),
                label: Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersSection(double padding, bool isTablet, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // County Selection
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedCountyId,
                hint: Text(
                  'اختر البلدية',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: isDesktop ? 16 : 14,
                ),
items: _counties.map<DropdownMenuItem<int>>((county) {
  return DropdownMenuItem<int>(
    value: county.id,  // Changed from county['id']
    child: Row(
      children: [
        Icon(
          Icons.location_city,
          color: AppColors.primary,
          size: 20,
        ),
        SizedBox(width: 12),
        Text(county.name),  // Changed from county['name']
      ],
    ),
  );
}).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCountyId = value;
                    _clanAdmins.clear();
                    _filteredAdmins.clear();
                  });
                  if (value != null) {
                    _loadClanAdmins();
                  }
                },
              ),
            ),
          ),
          
          if (_selectedCountyId != null) ...[
            SizedBox(height: 16),
            
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'البحث بالاسم أو رقم الهاتف...',
                  prefixIcon: Icon(Icons.search, color: AppColors.primary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                            _applyFilters();
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  _applyFilters();
                },
              ),
            ),
            
            // Results Count
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'عدد النتائج: ${_filteredAdmins.length}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: isDesktop ? 14 : 12,
                  ),
                ),
                if (_isLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdminsList(double padding, bool isTablet, bool isDesktop) {
    if (_selectedCountyId == null) {
      return _buildEmptyState(
        'اختر البلدية',
        'يرجى اختيار البلدية لعرض مدراء العشائر',
        Icons.location_city_outlined,
      );
    }

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return _buildEmptyState(
        'خطأ في التحميل',
        _errorMessage,
        Icons.error_outline,
      );
    }

    if (_filteredAdmins.isEmpty) {
      if (_searchQuery.isNotEmpty) {
        return _buildEmptyState(
          'لا توجد نتائج',
          'لم يتم العثور على مدراء عشائر بهذا البحث',
          Icons.search_off,
        );
      }
      return _buildEmptyState(
        'لا يوجد مدراء عشائر',
        'لم يتم تسجيل أي مدير عشيرة في هذه البلدية بعد',
        Icons.person_off_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadClanAdmins,
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(padding),
        itemCount: _filteredAdmins.length,
        itemBuilder: (context, index) {
          final admin = _filteredAdmins[index];
          return _buildAdminCard(admin, isTablet, isDesktop);
        },
      ),
    );
  }

  Widget _buildEmptyState(String title, String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

Widget _buildAdminCard(Map<String, dynamic> admin, bool isTablet, bool isDesktop) {
  final clan = _clans.firstWhere(
    (c) => c.id == admin['clan_id'],  // Changed from c['id'] to c.id
    orElse: () => Clan(id: 0, name: 'غير محدد', countyId: 0),  // Return a Clan object instead of Map
  );

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(isDesktop ? 20 : isTablet ? 18 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: Offset(0, 4),
            blurRadius: 16,
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: isDesktop ? 24 : 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${admin['first_name'] ?? ''} ${admin['last_name'] ?? ''}'.trim(),
                      style: TextStyle(
                        fontSize: isDesktop ? 18 : isTablet ? 16 : 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'مدير عشيرة ${clan.name}',  // Changed from clan['name'] to clan.name
                      style: TextStyle(
                        fontSize: isDesktop ? 14 : 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.visibility, color: AppColors.primary, size: 20),
                        SizedBox(width: 12),
                        Text('عرض التفاصيل'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: AppColors.primary, size: 20),
                        SizedBox(width: 12),
                        Text('تعديل البيانات'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 20),
                        SizedBox(width: 12),
                        Text('حذف', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'view':
                      _showAdminDetails(admin);
                      break;
                    case 'edit':
                      _updateClanAdmin(admin);
                      break;
                    case 'delete':
                      final adminName = '${admin['first_name']} ${admin['last_name']}';
                      _deleteClanAdmin(admin['id'], adminName);
                      break;
                  }
                },
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Info Grid
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.phone,
                  'رقم الهاتف',
                  admin['phone_number'] ?? 'غير محدد',
                  isTablet,
                  isDesktop,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildInfoItem(
                  Icons.location_on,
                  'عنوان السكن',
                  admin['home_address'] ?? 'غير محدد',
                  isTablet,
                  isDesktop,
                ),
              ),
            ],
          ),
          
          if (admin['father_name'] != null || admin['grandfather_name'] != null) ...[
            SizedBox(height: 12),
            Row(
              children: [
                if (admin['father_name'] != null)
                  Expanded(
                    child: _buildInfoItem(
                      Icons.person_outline,
                      'اسم الأب',
                      admin['father_name'],
                      isTablet,
                      isDesktop,
                    ),
                  ),
                if (admin['father_name'] != null && admin['grandfather_name'] != null)
                  SizedBox(width: 16),
                if (admin['grandfather_name'] != null)
                  Expanded(
                    child: _buildInfoItem(
                      Icons.family_restroom,
                      'اسم الجد',
                      admin['grandfather_name'],
                      isTablet,
                      isDesktop,
                    ),
                  ),
              ],
            ),
          ],
          
          // Action Buttons
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showAdminDetails(admin),
                  icon: Icon(Icons.visibility),
                  label: Text('عرض التفاصيل'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  final adminName = '${admin['first_name']} ${admin['last_name']}';
                  _deleteClanAdmin(admin['id'], adminName);
                },
                icon: Icon(Icons.delete),
                label: Text('حذف'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
    bool isTablet,
    bool isDesktop,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: isDesktop ? 12 : 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isDesktop ? 14 : isTablet ? 13 : 12,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAdminDetailsSheet(Map<String, dynamic> admin) {
    final clan = _clans.firstWhere(
      (c) => c.id == admin['clan_id'],  // Changed from c['id'] to c.id
      orElse: () => Clan(id: 0, name: 'غير محدد', countyId: 0),  // Return a Clan object instead of Map
    );

final county = _counties.firstWhere(
     (c) => c.id == admin['county_id'],  // Changed from c['id']
     orElse: () => County(id: 0, name: 'غير محدد'),  // Return County object
   );
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${admin['first_name'] ?? ''} ${admin['last_name'] ?? ''}'.trim(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'مدير عشيرة ${clan.name}',  // Changed from clan['name'] to clan.name
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          // Details
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailSection('المعلومات الشخصية', [
                    _buildDetailRow('رقم الهاتف', admin['phone_number'] ?? 'غير محدد'),
                    _buildDetailRow('اسم الأب', admin['father_name'] ?? 'غير محدد'),
                    _buildDetailRow('اسم الجد', admin['grandfather_name'] ?? 'غير محدد'),
                    _buildDetailRow('تاريخ الميلاد', admin['birth_date'] ?? 'غير محدد'),
                    _buildDetailRow('مكان الميلاد', admin['birth_address'] ?? 'غير محدد'),
                    _buildDetailRow('عنوان السكن', admin['home_address'] ?? 'غير محدد'),
                  ]),
                  
                  SizedBox(height: 24),
                  
                  _buildDetailSection('معلومات العشيرة والبلدية', [
                    _buildDetailRow('العشيرة', clan.name ?? 'غير محدد'),  // Changed from clan['name'] to clan.name
                    _buildDetailRow('البلدية', county.name ?? 'غير محدد'),  // Changed from county['name']
                    _buildDetailRow('رقم المعرف', admin['id']?.toString() ?? 'غير محدد'),
                  ]),
                  
                  SizedBox(height: 32),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _updateClanAdmin(admin);
                          },
                          icon: Icon(Icons.edit),
                          label: Text('تعديل البيانات'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            side: BorderSide(color: Colors.orange),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            final adminName = '${admin['first_name']} ${admin['last_name']}';
                            _deleteClanAdmin(admin['id'], adminName);
                          },
                          icon: Icon(Icons.delete),
                          label: Text('حذف الحساب'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}