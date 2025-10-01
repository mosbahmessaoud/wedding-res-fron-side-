// lib/screens/super admin/haia_tab.dart
import 'package:flutter/material.dart';
import '../../models/county.dart';
import '../../services/api_service.dart';
import '../../utils/colors.dart';

class HaiaTab extends StatefulWidget {
  const HaiaTab({super.key});

  @override
  _HaiaTabState createState() => _HaiaTabState();
}

class _HaiaTabState extends State<HaiaTab> with AutomaticKeepAliveClientMixin {
  List<dynamic> haiaCommittees = [];
  List<County> counties = [];
  bool isLoading = true;
  String? errorMessage;
  County? selectedCounty;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadCounties();
  }

  Future<void> _loadCounties() async {
    try {
      final loadedCounties = await ApiService.listCountiesAdmin();
      setState(() {
        counties = loadedCounties;
        if (counties.isNotEmpty) {
          selectedCounty = counties.first;
          _loadHaiaCommittees();
        } else {
          isLoading = false;
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'خطأ في تحميل القصور: ${e.toString()}';
      });
    }
  }

  Future<void> _loadHaiaCommittees() async {
    if (selectedCounty == null) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final loadedCommittees = await ApiService.listHaia(selectedCounty!.id);
      setState(() {
        haiaCommittees = loadedCommittees;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'خطأ في تحميل لجان الهاية: ${e.toString()}';
      });
    }
  }

  // Pull-to-refresh method
  Future<void> _refreshData() async {
    try {
      // Refresh counties first
      final loadedCounties = await ApiService.listCountiesAdmin();
      setState(() {
        counties = loadedCounties;
        // If selected county was deleted, reset it
        if (selectedCounty != null && 
            !counties.any((c) => c.id == selectedCounty!.id)) {
          selectedCounty = counties.isNotEmpty ? counties.first : null;
        }
      });

      // Then refresh committees if county is selected
      if (selectedCounty != null) {
        final loadedCommittees = await ApiService.listHaia(selectedCounty!.id);
        setState(() {
          haiaCommittees = loadedCommittees;
          errorMessage = null;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث البيانات بنجاح'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      setState(() {
        errorMessage = 'خطأ في تحديث البيانات: ${e.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحديث البيانات: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showCreateCommitteeDialog() {
    if (selectedCounty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى اختيار القصر أولاً'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _HaiaFormDialog(
        countyId: selectedCounty!.id,
        countyName: selectedCounty!.name,
        onCommitteeCreated: () {
          _loadHaiaCommittees();
        },
      ),
    );
  }

  void _showEditCommitteeDialog(Map<String, dynamic> committee) {
    showDialog(
      context: context,
      builder: (context) => _HaiaFormDialog(
        countyId: selectedCounty!.id,
        countyName: selectedCounty!.name,
        committee: committee,
        onCommitteeCreated: () {
          _loadHaiaCommittees();
        },
      ),
    );
  }

  Future<void> _deleteCommittee(Map<String, dynamic> committee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف لجنة الهاية "${committee['name']}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.deleteHaia(committee['id'], selectedCounty!.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حذف لجنة الهاية بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        _loadHaiaCommittees();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حذف لجنة الهاية: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      body: Column(
        children: [
          // Header Section
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إدارة لجان الهاية',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'اسحب للأسفل للتحديث',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _showCreateCommitteeDialog,
                      icon: Icon(Icons.add),
                      label: Text('إضافة لجنة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // County Selection
                Row(
                  children: [
                    Text(
                      'القصر:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<County>(
                        value: selectedCounty,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: counties.map((county) => DropdownMenuItem<County>(
                          value: county,
                          child: Text(county.name),
                        )).toList(),
                        onChanged: (County? value) {
                          setState(() {
                            selectedCounty = value;
                          });
                          if (value != null) {
                            _loadHaiaCommittees();
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    // ElevatedButton(
                    //   onPressed: _refreshData,
                    //   child: Text('تحديث'),
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: AppColors.secondary,
                    //     foregroundColor: Colors.white,
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),

          // Content Section with RefreshIndicator
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              color: Colors.orange,
              backgroundColor: Colors.white,
              strokeWidth: 2.5,
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (counties.isEmpty) {
      return ListView(
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_city,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد بلديات',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'يجب إضافة بلديات أولاً أو اسحب للأسفل للتحديث',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (isLoading) {
      return ListView(
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'جاري تحميل لجان الهاية...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (errorMessage != null) {
      return ListView(
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
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
                    errorMessage!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'اسحب للأسفل لإعادة المحاولة',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (haiaCommittees.isEmpty) {
      return ListView(
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.business,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد هيئات',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'ابدأ بإضافة هيئة جديدة أو اسحب للأسفل للتحديث',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showCreateCommitteeDialog,
                    icon: Icon(Icons.add),
                    label: Text('إضافة هيئة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16),
      itemCount: haiaCommittees.length,
      itemBuilder: (context, index) {
        final committee = haiaCommittees[index];
        return _buildCommitteeCard(committee);
      },
    );
  }

  Widget _buildCommitteeCard(Map<String, dynamic> committee) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        committee['name'] ?? 'غير محدد',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      if (committee['phone'] != null)
                        Text(
                          'الهاتف: ${committee['phone']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),

                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _showEditCommitteeDialog(committee),
                      icon: Icon(Icons.edit),
                      color: Colors.purple,
                    ),
                    IconButton(
                      onPressed: () => _deleteCommittee(committee),
                      icon: Icon(Icons.delete),
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
            if (committee['description'] != null && committee['description'].isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                committee['description'],
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HaiaFormDialog extends StatefulWidget {
  final int countyId;
  final String countyName;
  final Map<String, dynamic>? committee;
  final VoidCallback onCommitteeCreated;

  const _HaiaFormDialog({
    required this.countyId,
    required this.countyName,
    this.committee,
    required this.onCommitteeCreated,
  });

  @override
  _HaiaFormDialogState createState() => _HaiaFormDialogState();
}

class _HaiaFormDialogState extends State<_HaiaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.committee != null) {
      _nameController.text = widget.committee!['name'] ?? '';

    }
  }

  @override
  void dispose() {
    _nameController.dispose();

    super.dispose();
  }

  bool get isEditing => widget.committee != null;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final committeeData = {
        'name': _nameController.text.trim(),

        'county_id': widget.countyId,
      };

      if (isEditing) {
        await ApiService.updateHaia(
          widget.committee!['id'],
          widget.countyId,
          committeeData,
        );
      } else {
        await ApiService.createHaia(committeeData);
      }

      widget.onCommitteeCreated();
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'تم تحديث الهيئة بنجاح' : 'تم إنشاء الهيئة بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'تعديل الهيئة' : 'إضافة هيئة جديدة'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // County Info
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_city, color: Colors.purple),
                      SizedBox(width: 8),
                      Text(
                        'القصر: ${widget.countyName}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.purple[700],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Committee Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'اسم الهيئة',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال اسم الهيئة';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

               


               
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(isEditing ? 'تحديث' : 'إضافة'),
        ),
      ],
    );
  }
}