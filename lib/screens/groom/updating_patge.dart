import 'package:flutter/material.dart';
import 'package:wedding_reservation_app/services/api_service.dart';
import 'package:wedding_reservation_app/utils/colors.dart';

class UpdateReservationInfoPage extends StatefulWidget {
  final Map<String, dynamic> reservation;

  const UpdateReservationInfoPage({
    Key? key,
    required this.reservation,
  }) : super(key: key);

  @override
  State<UpdateReservationInfoPage> createState() => _UpdateReservationInfoPageState();
}

class _UpdateReservationInfoPageState extends State<UpdateReservationInfoPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLoadingData = true;

  // Data lists
  List<dynamic> _haiaCommittees = [];
  List<dynamic> _madaehCommittees = [];

  // Selected values
  Map<String, dynamic>? _selectedHaiaCommittee;
  Map<String, dynamic>? _selectedMadaehCommittee;
  bool _allowOthers = false;
  String? _selectedFreeWay = 'non'; // 'non', 'forced', 'special_case'

  // State flags
  bool _showCustomMadaehInput = false;
  bool _isReservationValidated = false;

  // Controllers
  final TextEditingController _customMadaehCommitteeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _customMadaehCommitteeController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoadingData = true);

    try {
      // Load current reservation data
      _loadCurrentReservationData();

      // Load committees
      await _loadCommittees();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل البيانات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  void _loadCurrentReservationData() {
    // Load current values from reservation
    _allowOthers = widget.reservation['allow_others'] ?? false;
    _selectedFreeWay = widget.reservation['free_way'] ?? 'non';
    
    // Check if reservation is validated
    _isReservationValidated = widget.reservation['status'] == 'validated';

    // Store committee IDs for later matching
    final haiaId = widget.reservation['haia_committee_id'];
    final madaehId = widget.reservation['madaeh_committee_id'];

    // These will be set after loading committees
    if (haiaId != null) {
      _selectedHaiaCommittee = {'id': haiaId};
    }
    if (madaehId != null) {
      _selectedMadaehCommittee = {'id': madaehId};
    }
  }

  Future<void> _loadCommittees() async {
    try {
      // Load Haia committees
      final haiaList = await ApiService.getGroomHaia();
      
      // Load Madaeh committees
      final madaehList = await ApiService.getGroomMadaihCommittee();

      if (mounted) {
        setState(() {
          _haiaCommittees = haiaList;
          _madaehCommittees = madaehList;

          // Match selected committees with loaded data
          if (_selectedHaiaCommittee != null) {
            final haiaId = _selectedHaiaCommittee!['id'];
            _selectedHaiaCommittee = _haiaCommittees.firstWhere(
              (c) => c['id'] == haiaId,
              orElse: () => _selectedHaiaCommittee!,
            );
          }

          if (_selectedMadaehCommittee != null) {
            final madaehId = _selectedMadaehCommittee!['id'];
            _selectedMadaehCommittee = _madaehCommittees.firstWhere(
              (c) => c['id'] == madaehId,
              orElse: () => _selectedMadaehCommittee!,
            );

            // Check if custom input should be shown
            _showCustomMadaehInput = _selectedMadaehCommittee?['name']?.toString()== ' لجنة خاصة';
          }
        });
      }
    } catch (e) {
      print('Error loading committees: $e');
      rethrow;
    }
  }



  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog();
    if (!confirmed) return;

    setState(() => _isLoading = true);

    try {
      final reservationId = widget.reservation['id'];

      // Prepare update data
      final updateData = await ApiService.updateGroomReservation(
        reservationId: reservationId,
        haiaCommitteeId: _selectedHaiaCommittee?['id'],
        madaehCommitteeId: _selectedMadaehCommittee?['id'],
        allowOthers: _allowOthers,
        freeWay: _selectedFreeWay,
      );

      if (mounted) {
        // Show success message
        String message = updateData['message'] ?? 'تم تحديث الحجز بنجاح';
        
        // Add info about skipped fields if any
        if (updateData['skipped_fields'] != null && 
            (updateData['skipped_fields'] as List).isNotEmpty) {
          final skippedFields = updateData['skipped_fields'] as List;
          if (skippedFields.contains('haia_committee_id')) {
            message += '\n\n⚠️ ملاحظة: لا يمكن تعديل الهيئة لأن حجزك مؤكد';
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );

        // Return to previous screen with success flag
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحديث الحجز: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد التحديث'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('هل أنت متأكد من تحديث معلومات الحجز؟'),
            const SizedBox(height: 16),
            if (_isReservationValidated) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'لن يتم تحديث الهيئة لأن حجزك مؤكد',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحديث معلومات الحجز'),
        backgroundColor: AppColors.primary,
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info card
                    _buildInfoCard(),
                    const SizedBox(height: 24),

                    // Reservation status banner
                    if (_isReservationValidated) _buildValidatedBanner(),
                    if (_isReservationValidated) const SizedBox(height: 16),

                    // Haia Committee Selection
                    _buildHaiaCommitteeField(),
                    const SizedBox(height: 16),

                    // Madaeh Committee Selection
                    _buildMadaehCommitteeField(),
                    const SizedBox(height: 16),

                    // Custom Madaeh Committee Input
                    if (_showCustomMadaehInput) ...[
                      _buildCustomMadaehInput(),
                      const SizedBox(height: 16),
                    ],

                    // // Free Way Selection
                    // _buildFreeWayField(),
                    // const SizedBox(height: 24),

                    // Allow Others Option
                    _buildAllowOthersCard(),
                    const SizedBox(height: 24),

                    // Submit Button
                    _buildSubmitButton(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    final date1 = widget.reservation['date1'];
    final date2 = widget.reservation['date2'];
    final status = widget.reservation['status'];

    return Card(
      color: AppColors.primary.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'معلومات الحجز',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            _buildInfoRow('التاريخ الأول', date1 ?? 'غير محدد'),
            if (date2 != null) _buildInfoRow('التاريخ الثاني', date2),
            _buildInfoRow('الحالة', _getStatusText(status)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'validated':
        return '✅ مؤكد';
      case 'pending_validation':
        return '⏳ قيد المراجعة';
      case 'cancelled':
        return '❌ ملغى';
      default:
        return status ?? 'غير محدد';
    }
  }

  Widget _buildValidatedBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade300, width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 32),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تنبيه',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'حجزك مؤكد - لا يمكن تعديل الهيئة',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHaiaCommitteeField() {
    return DropdownButtonFormField<Map<String, dynamic>>(
      value: _selectedHaiaCommittee,
      decoration: InputDecoration(
        labelText: _isReservationValidated ? 'الهيئة (لا يمكن التعديل)' : 'الهيئة *',
        prefixIcon: const Icon(Icons.group),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        helperText: _isReservationValidated 
            ? 'لا يمكن تعديل الهيئة للحجوزات المؤكدة'
            : 'اختر الهيئة الدينية',
        helperStyle: TextStyle(
          color: _isReservationValidated ? Colors.orange.shade700 : null,
        ),
      ),
      isExpanded: true,
      selectedItemBuilder: (BuildContext context) {
        return _haiaCommittees.map<Widget>((committee) {
          return Text(
            committee['name']?.toString() ?? 'لجنة غير مسماة',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _isReservationValidated ? Colors.grey : null,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          );
        }).toList();
      },
      items: _haiaCommittees.map((committee) {
        return DropdownMenuItem<Map<String, dynamic>>(
          value: committee,
          enabled: !_isReservationValidated,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: constraints.maxWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      committee['name']?.toString() ?? 'لجنة غير مسماة',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    if (committee['description'] != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        committee['description'].toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      }).toList(),
      onChanged: _isReservationValidated 
          ? null 
          : (value) => setState(() => _selectedHaiaCommittee = value),
      validator: (value) => value == null ? 'الهيئة مطلوبة' : null,
    );
  }

  Widget _buildMadaehCommitteeField() {
    return DropdownButtonFormField<Map<String, dynamic>>(
      value: _selectedMadaehCommittee,
      decoration: InputDecoration(
        labelText: 'اللجنة *',
        prefixIcon: const Icon(Icons.group_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        helperText: 'اختر لجنة المدائح والإنشاد',
      ),
      isExpanded: true,
      selectedItemBuilder: (BuildContext context) {
        return _madaehCommittees.map<Widget>((committee) {
          return Text(
            committee['name']?.toString() ?? 'لجنة غير مسماة',
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          );
        }).toList();
      },
      items: _madaehCommittees.map((committee) {
        return DropdownMenuItem<Map<String, dynamic>>(
          value: committee,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: constraints.maxWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      committee['name']?.toString() ?? 'لجنة غير مسماة',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    if (committee['description'] != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        committee['description'].toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedMadaehCommittee = value;
          _showCustomMadaehInput = value?['name']?.toString() == 'لجنة خاصة';
          if (!_showCustomMadaehInput) {
            _customMadaehCommitteeController.clear();
          }
        });
      },
      validator: (value) => value == null ? 'لجنة المدائح والإنشاد مطلوبة' : null,
    );
  }

  Widget _buildCustomMadaehInput() {
    return TextFormField(
      controller: _customMadaehCommitteeController,
      decoration: InputDecoration(
        labelText: 'اسم اللجنة الخاصة (اختياري)',
        prefixIcon: const Icon(Icons.edit),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        helperText: 'أدخل اسم اللجنة الخاصة إن وجد',
        helperMaxLines: 2,
      ),
      maxLength: 100,
    );
  }


  // Widget _buildFreeWayField() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         'نوع الإعفاء',
  //         style: TextStyle(
  //           fontSize: 16,
  //           fontWeight: FontWeight.bold,
  //           color: AppColors.primary,
  //         ),
  //       ),
  //       const SizedBox(height: 12),
  //       ...['non', 'forced', 'special_case'].map((type) {
  //         return RadioListTile<String>(
  //           title: Text(_getFreeWayText(type)),
  //           value: type,
  //           groupValue: _selectedFreeWay,
  //           onChanged: (value) => setState(() => _selectedFreeWay = value),
  //           activeColor: AppColors.primary,
  //         );
  //       }).toList(),
  //     ],
  //   );
  // }

  // String _getFreeWayText(String type) {
  //   switch (type) {
  //     case 'non':
  //       return 'لا يوجد إعفاء';
  //     case 'forced':
  //       return 'إعفاء إجباري';
  //     case 'special_case':
  //       return 'حالة خاصة';
  //     default:
  //       return type;
  //   }
  // }

  Widget _buildAllowOthersCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const Text(
            //   'عرس جماعي',
            //   style: TextStyle(
            //     fontSize: 16,
            //     fontWeight: FontWeight.bold,
            //     color: AppColors.primary,
            //   ),
            // ),
            const SizedBox(height: 12),
            const Text(
              ' إمكانية إستقبال أعراس أخرى معك في نفس اليوم',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _allowOthers = true),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _allowOthers ? AppColors.primary : Colors.transparent,
                      foregroundColor: _allowOthers ? Colors.white : AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('مفتوح'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _allowOthers = false),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: !_allowOthers ? AppColors.primary : Colors.transparent,
                      foregroundColor: !_allowOthers ? Colors.white : AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('مغلق'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitUpdate,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'تحديث الحجز',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}