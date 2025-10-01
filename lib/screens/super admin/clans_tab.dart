// lib/screens/super admin/clans_tab.dart
import 'package:flutter/material.dart';
import '../../models/clan.dart';
import '../../models/county.dart';
import '../../services/api_service.dart';
import '../../utils/colors.dart';

class ClansTab extends StatefulWidget {
  const ClansTab({super.key});

  @override
  _ClansTabState createState() => _ClansTabState();
}

class _ClansTabState extends State<ClansTab> with AutomaticKeepAliveClientMixin {
  List<Clan> clans = [];
  List<County> counties = [];
  bool isLoading = true;
  String? errorMessage;
  County? selectedCounty;

  // Add this to keep the state alive when switching tabs
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // Add this method to handle when the user returns to this tab
  Future<void> _refreshDataIfNeeded() async {
    try {
      // Refresh counties list to include any newly created counties
      await _loadCounties();
      
      // Also refresh clans in case any were added/modified
      if (selectedCounty == null) {
        await _loadAllClans();
      } else {
        await _loadClansByCounty(selectedCounty!.id);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث البيانات بنجاح'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحديث البيانات: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _loadInitialData() async {
    await _loadCounties();
    await _loadAllClans();
  }

  Future<void> _loadCounties() async {
    try {
      final loadedCounties = await ApiService.listCountiesAdmin();
      setState(() {
        counties = loadedCounties;
        // If selected county was deleted, reset it
        if (selectedCounty != null && 
            !counties.any((c) => c.id == selectedCounty!.id)) {
          selectedCounty = null;
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = 'خطأ في تحميل القصور: ${e.toString()}';
      });
    }
  }

  Future<void> _loadAllClans() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final loadedClans = await ApiService.getAllClans();
      setState(() {
        clans = loadedClans;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'خطأ في تحميل العشائر: ${e.toString()}';
      });
    }
  }

  Future<void> _loadClansByCounty(int countyId) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final loadedClans = await ApiService.listClansByCounty(countyId);
      setState(() {
        clans = loadedClans;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'خطأ في تحميل العشائر: ${e.toString()}';
      });
    }
  }

  void _showCreateClanDialog() {
    showDialog(
      context: context,
      builder: (context) => _ClanFormDialog(
        counties: counties,
        onClanCreated: (clan) {
          _loadAllClans();
        },
        onCountiesRefreshNeeded: () {
          // Refresh counties when called from the dialog
          _loadCounties();
        },
      ),
    );
  }

  void _showEditClanDialog(Clan clan) {
    showDialog(
      context: context,
      builder: (context) => _ClanFormDialog(
        counties: counties,
        clan: clan,
        onClanCreated: (updatedClan) {
          _loadAllClans();
        },
        onCountiesRefreshNeeded: () {
          // Refresh counties when called from the dialog
          _loadCounties();
        },
      ),
    );
  }

  Future<void> _deleteClan(Clan clan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف عشيرة "${clan.name}"؟'),
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
        await ApiService.deleteClan(clan.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حذف العشيرة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        _loadAllClans();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حذف العشيرة: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
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
                    Text(
                      'إدارة العشائر',
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
                    ElevatedButton.icon(
                      onPressed: _showCreateClanDialog,
                      icon: Icon(Icons.add),
                      label: Text('إضافة عشيرة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // County Filter
                Row(
                  children: [
                    Text(
                      'فلترة حسب القصر:',
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
                          hintText: 'اختر القصر',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          DropdownMenuItem<County>(
                            value: null,
                            child: Text('جميع القصور'),
                          ),
                          ...counties.map((county) => DropdownMenuItem<County>(
                            value: county,
                            child: Text(county.name),
                          )),
                        ],
                        onChanged: (County? value) {
                          setState(() {
                            selectedCounty = value;
                          });
                          if (value == null) {
                            _loadAllClans();
                          } else {
                            _loadClansByCounty(value.id);
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     // Refresh both counties and clans
                    //     _refreshDataIfNeeded();
                    //   },
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
              onRefresh: _refreshDataIfNeeded,
              color: AppColors.primary,
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
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
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
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshDataIfNeeded,
              child: Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (clans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'لا توجد عشائر',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'ابدأ بإضافة عشيرة جديدة',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showCreateClanDialog,
              icon: Icon(Icons.add),
              label: Text('إضافة عشيرة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: clans.length,
      itemBuilder: (context, index) {
        final clan = clans[index];
        return _buildClanCard(clan);
      },
    );
  }

  Widget _buildClanCard(Clan clan) {
    // Find county name
    final county = counties.firstWhere(
      (c) => c.id == clan.countyId,
      orElse: () => County(id: 0, name: 'غير محدد'),
    );

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
                        clan.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'القصر: ${county.name}',
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
                      onPressed: () => _showEditClanDialog(clan),
                      icon: Icon(Icons.edit),
                      color: AppColors.primary,
                    ),
                    IconButton(
                      onPressed: () => _deleteClan(clan),
                      icon: Icon(Icons.delete),
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}
class _ClanFormDialog extends StatefulWidget {
  final List<County> counties;
  final Clan? clan;
  final Function(Clan) onClanCreated;
  final VoidCallback onCountiesRefreshNeeded;

  const _ClanFormDialog({
    required this.counties,
    this.clan,
    required this.onClanCreated,
    required this.onCountiesRefreshNeeded,
  });

  @override
  _ClanFormDialogState createState() => _ClanFormDialogState();
}

class _ClanFormDialogState extends State<_ClanFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  County? _selectedCounty;
  bool _isLoading = false;
  List<County> _currentCounties = [];

  @override
  void initState() {
    super.initState();
    _currentCounties = List.from(widget.counties);
    
    if (widget.clan != null) {
      _nameController.text = widget.clan!.name;
      // Try to find the county that matches the clan's county ID
      try {
        _selectedCounty = _currentCounties.firstWhere(
          (c) => c.id == widget.clan!.countyId,
        );
      } catch (e) {
        // If county not found, select the first available county or null
        _selectedCounty = _currentCounties.isNotEmpty ? _currentCounties.first : null;
      }
    }
    
    // Refresh counties list when dialog opens
    _refreshCounties();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get isEditing => widget.clan != null;

  Future<void> _refreshCounties() async {
    try {
      final loadedCounties = await ApiService.listCountiesAdmin();
      setState(() {
        _currentCounties = loadedCounties;
        
        // If we had a selected county but it's not in the new list, clear selection
        if (_selectedCounty != null && 
            !_currentCounties.any((c) => c.id == _selectedCounty!.id)) {
          _selectedCounty = null;
        }
      });
    } catch (e) {
      // If refresh fails, keep using the original counties list
      print('Failed to refresh counties: $e');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedCounty == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final clanData = {
        'name': _nameController.text.trim(),
        'county_id': _selectedCounty!.id,
      };

      Map<String, dynamic> result;
      if (isEditing) {
        result = await ApiService.updateClan(widget.clan!.id, clanData);
      } else {
        result = await ApiService.createClan(clanData);
      }

      // Create Clan object from result
      final clan = Clan(
        id: result['id'],
        name: result['name'],
        countyId: result['county_id'],
      );

      widget.onClanCreated(clan);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'تم تحديث العشيرة بنجاح' : 'تم إنشاء العشيرة بنجاح'),
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
      title: Text(isEditing ? 'تعديل العشيرة' : 'إضافة عشيرة جديدة'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Clan Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'اسم العشيرة',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.groups),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال اسم العشيرة';
                  }
                  if (value.trim().length < 2) {
                    return 'اسم العشيرة يجب أن يكون على الأقل حرفين';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // County Selection with refresh button
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<County>(
                      value: _selectedCounty,
                      decoration: InputDecoration(
                        labelText: 'القصر',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      items: _currentCounties.map((county) {
                        return DropdownMenuItem<County>(
                          value: county,
                          child: Text(county.name),
                        );
                      }).toList(),
                      onChanged: (County? value) {
                        setState(() {
                          _selectedCounty = value;
                        });
                      },
                      validator: (County? value) {
                        if (value == null) {
                          return 'يرجى اختيار القصر';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    onPressed: _refreshCounties,
                    icon: Icon(Icons.refresh),
                    tooltip: 'تحديث قائمة القصور',
                    color: AppColors.primary,
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Show message if no counties available
              if (_currentCounties.isEmpty)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'لا توجد قصور متاحة. يجب إنشاء قصر أولاً.',
                          style: TextStyle(color: Colors.orange[700]),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: (_isLoading || _currentCounties.isEmpty) ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
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