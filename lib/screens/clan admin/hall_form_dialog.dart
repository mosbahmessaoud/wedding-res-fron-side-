// lib/screens/dialogs/hall_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:wedding_reservation_app/services/api_service.dart';
import '../../utils/colors.dart';
// Add your user service import here
// import '../../services/user_service.dart';

class HallFormDialog extends StatefulWidget {
  final Map<String, dynamic>? hall;
  final int? clanId; // Keep for backwards compatibility, but will be auto-fetched

  const HallFormDialog({super.key, this.hall, this.clanId});

  @override
  _HallFormDialogState createState() => _HallFormDialogState();
}

class _HallFormDialogState extends State<HallFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController();

  bool _isSubmitting = false;
  bool _isLoadingClanId = false;
  int? _currentUserClanId;
  String? _clanIdError;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }
  void refreshData() {

    _loadInitialData();
    setState(() {
      
    });
  }

Future<void> _loadInitialData() async {
  await Future.wait([
    _fetchCurrentUserClanId(),
    
    // Load other necessary data here if needed
  ]);
  
  // Refresh the UI to update dropdown options after menus are loaded
  if (mounted) {
    setState(() {});
  }
}
  Future<void> _initializeForm() async {
    if (widget.hall != null) {
      // Editing existing hall
      _nameController.text = widget.hall!['name'] ?? '';
      _capacityController.text = widget.hall!['capacity']?.toString() ?? '';
      _currentUserClanId = widget.hall!['clan_id'];
    } else {
      // Creating new hall - fetch current user's clan_id
      await _fetchCurrentUserClanId();
    }
  }

  Future<void> _fetchCurrentUserClanId() async {
    setState(() {
      _isLoadingClanId = true;
      _clanIdError = null;
    });

    try {
      // Get current user info using your existing API service
      final userInfo = await ApiService.getCurrentUserInfo();
      
      // Extract clan_id from user info
      _currentUserClanId = userInfo['clan_id'];
      
      if (_currentUserClanId == null) {
        throw Exception('لم يتم العثور على معرف العشيرة للمستخدم الحالي');
      }
    } catch (e) {
      setState(() {
        _clanIdError = 'خطأ في جلب معرف العشيرة: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoadingClanId = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_currentUserClanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لا يمكن إضافة القاعة بدون معرف العشيرة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      final hallData = {
        'clan_id': _currentUserClanId,
        'name': _nameController.text.trim(),
        'capacity': int.tryParse(_capacityController.text.trim()) ?? 0,
      };

      // Simulate API call delay
      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          _isSubmitting = false;
        });
        Navigator.of(context).pop(hallData);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.hall != null;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: EdgeInsets.all(20),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: 500,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isEditing ? Icons.edit : Icons.add,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'تعديل القاعة' : 'إضافة قاعة جديدة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isEditing ? 'تحديث بيانات القاعة' : 'إدخال بيانات القاعة الجديدة',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Form content
            Flexible(
              child: Container(
                padding: EdgeInsets.all(24),
                child: _isLoadingClanId
                    ? _buildLoadingWidget()
                    : _clanIdError != null
                        ? _buildErrorWidget()
                        : _buildFormContent(isEditing),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16),
          Text(
            'جاري تحميل بيانات العشيرة...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
          ),
          SizedBox(height: 16),
          Text(
            _clanIdError!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchCurrentUserClanId,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent(bool isEditing) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display clan ID (read-only)
            _buildClanIdDisplay(),
            SizedBox(height: 20),

            // Hall Name
            _buildInputField(
              controller: _nameController,
              label: 'اسم القاعة',
              hint: 'أدخل اسم القاعة',
              icon: Icons.meeting_room,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'اسم القاعة مطلوب';
                }
                if (value.trim().length < 2) {
                  return 'اسم القاعة يجب أن يكون أطول من حرفين';
                }
                return null;
              },
            ),

            SizedBox(height: 20),

            // Capacity
            _buildInputField(
              controller: _capacityController,
              label: 'السعة',
              hint: '0',
              icon: Icons.people,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'السعة مطلوبة';
                }
                final capacity = int.tryParse(value.trim());
                if (capacity == null || capacity <= 0) {
                  return 'السعة يجب أن تكون رقم موجب';
                }
                if (capacity > 10000) {
                  return 'السعة كبيرة جداً';
                }
                return null;
              },
            ),

            SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            isEditing ? 'جاري التحديث...' : 'جاري الإضافة...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isEditing ? Icons.check : Icons.add,
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            isEditing ? 'تحديث القاعة' : 'إضافة القاعة',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
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

  Widget _buildClanIdDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'معرف العشيرة',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.only(right: 8),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.groups,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              SizedBox(width: 8),
              Text(
                _currentUserClanId?.toString() ?? 'غير محدد',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'تلقائي',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    TextInputAction? textInputAction,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          textInputAction: textInputAction ?? TextInputAction.next,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
            prefixIcon: Container(
              margin: EdgeInsets.all(12),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 16 : 12,
            ),
          ),
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}