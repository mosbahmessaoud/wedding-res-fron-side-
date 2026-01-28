//lib\screens\clan admin\bulk_upload_grooms_screen.dart
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../models/bulk_registration_result.dart';
import '../../services/api_service.dart';

class BulkUploadGroomsScreen extends StatefulWidget {
  const BulkUploadGroomsScreen({Key? key}) : super(key: key);

  @override
  State<BulkUploadGroomsScreen> createState() => _BulkUploadGroomsScreenState();
}

class _BulkUploadGroomsScreenState extends State<BulkUploadGroomsScreen> {
  File? _selectedFile;
  bool _isUploading = false;
  BulkRegistrationResult? _result;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _result = null; // Clear previous results
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في اختيار الملف: $e')),
      );
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار ملف أولاً')),
      );
      return;
    }

    // Validate file
    final errors = ApiService.validateExcelFile(_selectedFile!);
    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errors.values.first)),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final response = await ApiService.uploadGroomsExcel(_selectedFile!);
      
      setState(() {
        _result = BulkRegistrationResult.fromJson(response['result']);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message']),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في رفع الملف: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل العرسان الجماعي'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'تعليمات:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('1. يجب أن يحتوي ملف Excel على الأعمدة التالية:'),
                    const Text('   • phone_number (مطلوب)'),
                    const Text('   • first_name (مطلوب)'),
                    const Text('   • last_name (مطلوب)'),
                    const Text('   • father_name (مطلوب)'),
                    const Text('   • grandfather_name (مطلوب)'),
                    const Text('   • birth_date (اختياري)'),
                    const Text('   • birth_address (اختياري)'),
                    const Text('   • home_address (اختياري)'),
                    const Text('   • guardian_name (اختياري)'),
                    const Text('   • guardian_phone (اختياري)'),
                    const Text('   • clan_id (اختياري - افتراضي: عشيرتك)'),
                    const Text('   • county_id (اختياري - افتراضي: مقاطعتك)'),
                    const SizedBox(height: 8),
                    const Text('2. سيتم تخطي المستخدمين الموجودين مسبقاً'),
                    const Text('3. كلمة المرور الافتراضية هي رقم الهاتف'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // File Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (_selectedFile != null) ...[
                      ListTile(
                        leading: const Icon(Icons.description, color: Colors.green),
                        title: Text(_selectedFile!.path.split('/').last),
                        subtitle: Text(
                          '${(_selectedFile!.lengthSync() / 1024).toStringAsFixed(2)} KB',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _selectedFile = null;
                              _result = null;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isUploading ? null : _pickFile,
                            icon: const Icon(Icons.file_upload),
                            label: Text(_selectedFile == null 
                                ? 'اختر ملف Excel' 
                                : 'اختر ملف آخر'),
                          ),
                        ),
                        if (_selectedFile != null) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isUploading ? null : _uploadFile,
                              icon: _isUploading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Icon(Icons.cloud_upload),
                              label: Text(_isUploading ? 'جاري الرفع...' : 'رفع الملف'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Results
            if (_result != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'النتائج:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard(
                            'المجموع',
                            _result!.totalRows.toString(),
                            Colors.blue,
                          ),
                          _buildStatCard(
                            'نجح',
                            _result!.successful.toString(),
                            Colors.green,
                          ),
                          _buildStatCard(
                            'تم تخطيه',
                            _result!.skipped.toString(),
                            Colors.orange,
                          ),
                          _buildStatCard(
                            'فشل',
                            _result!.failed.toString(),
                            Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text(
                        'التفاصيل:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _result!.details.length,
                        itemBuilder: (context, index) {
                          final detail = _result!.details[index];
                          return _buildDetailTile(detail);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
Widget _buildDetailTile(RegistrationDetail detail) {
  IconData icon;
  Color color;
  String subtitle = detail.name ?? detail.reason ?? detail.status;
  
  if (detail.isSuccess) {
    icon = Icons.check_circle;
    color = Colors.green;
    if (detail.hasReservation) {
      subtitle = '${detail.name} - ✓ تم إنشاء حجز';
    }
  } else if (detail.isSkipped) {
    icon = Icons.skip_next;
    color = Colors.orange;
  } else {
    icon = Icons.error;
    color = Colors.red;
  }

  return ListTile(
    dense: true,
    leading: Icon(icon, color: color, size: 20),
    title: Text('صف ${detail.row}${detail.phone != null ? ' - ${detail.phone}' : ''}'),
    subtitle: Text(subtitle, style: TextStyle(fontSize: 12)),
  );
}
}

