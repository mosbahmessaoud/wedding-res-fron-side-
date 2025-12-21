import 'dart:io';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wedding_reservation_app/services/api_service.dart';

class ClanAdminStatisticsPage extends StatefulWidget {
  const ClanAdminStatisticsPage({Key? key}) : super(key: key);

  @override
  State<ClanAdminStatisticsPage> createState() => ClanAdminStatisticsPageState();
}

class ClanAdminStatisticsPageState extends State<ClanAdminStatisticsPage> {
  String _exportType = 'grooms';
  String _reservationFilter = 'all';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;


  void refreshData() {
    // Currently no cached data to refresh
  }
  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchData() async {
    if (_exportType == 'grooms') {
      final response = await ApiService.listGroomsForClanAdmin();
      return response.map((g) {
        final groom = g as Map<String, dynamic>;
        return {
          'الاسم الأول': groom['first_name'],
          'اسم الأب': groom['father_name'],
          'اسم الجد': groom['grandfather_name'],
          'الكنية': groom['last_name'],
          'رقم الهاتف': groom['phone_number'],
          'تاريخ الميلاد': groom['birth_date'] ?? '',
          'مكان الميلاد': groom['birth_address'] ?? '',
          'العنوان': groom['home_address'] ?? '',
          'الحالة': groom['status'] ?? 'نشط',
          'تاريخ التسجيل': groom['created_at']?.toString().split('T')[0] ?? '',
        };
      }).toList();
    } else {
      final response = await ApiService.listReservationsForClanAdmin();
      List<Map<String, dynamic>> filteredReservations = response.map((r) => r as Map<String, dynamic>).where((r) {
        final date1 = r['date1'] != null ? DateTime.parse(r['date1']) : null;
        final now = DateTime.now();
        
        // Filter by date range if selected
        if (_startDate != null && _endDate != null && date1 != null) {
          if (date1.isBefore(_startDate!) || date1.isAfter(_endDate!)) {
            return false;
          }
        }
        
        // Filter by reservation type
        if (_reservationFilter == 'upcoming' && date1 != null && date1.isBefore(now)) {
          return false;
        } else if (_reservationFilter == 'past' && date1 != null && date1.isAfter(now)) {
          return false;
        }
        
        return true;
      }).toList();

      return filteredReservations.map((r) {
        return {
          'اسم العريس': '${r['first_name']} ${r['father_name']} ${r['grandfather_name']} ${r['last_name']}',
          'رقم الهاتف': r['phone_number'],
          'التاريخ الأول': r['date1'] ?? '',
          'التاريخ الثاني': r['date2'] ?? '',
          'يومين': r['date2_bool'] == true ? 'نعم' : 'لا',
          'القاعة': r['hall_name'] ?? '',
          'لجنة الهيئة': r['haia_committee_name'] ?? '',
          'لجنة المداح': r['madaeh_committee_name'] ?? '',
          'الحالة': r['status'] ?? '',
          'صالح للآخرين': r['allow_others'] == true ? 'نعم' : 'لا',
          'زواج جماعي': r['join_to_mass_wedding'] == true ? 'نعم' : 'لا',
          'الدفع': r['payment_valid'] == true ? 'مدفوع' : 'غير مدفوع',
          'تاريخ الحجز': r['created_at']?.toString().split('T')[0] ?? '',
        };
      }).toList();
    }
  }

  Future<void> _exportToExcel(List<Map<String, dynamic>> data) async {
    setState(() => _isLoading = true);
    try {
      final excel = Excel.createExcel();
      final sheet = excel['البيانات'];
      
      if (data.isEmpty) {
        _showSnackBar('لا توجد بيانات للتصدير', isError: true);
        return;
      }

      // Add headers
      final headers = data.first.keys.toList();
      for (var i = 0; i < headers.length; i++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          ..value = TextCellValue(headers[i])
          ..cellStyle = CellStyle(bold: true, backgroundColorHex: ExcelColor.blue);
      }

      // Add data rows
      for (var rowIndex = 0; rowIndex < data.length; rowIndex++) {
        final row = data[rowIndex];
        for (var colIndex = 0; colIndex < headers.length; colIndex++) {
          final value = row[headers[colIndex]]?.toString() ?? '';
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: rowIndex + 1))
            .value = TextCellValue(value);
        }
      }

      // Auto-fit columns
      for (var i = 0; i < headers.length; i++) {
        sheet.setColumnWidth(i, 20);
      }

      final fileBytes = excel.save();
      if (fileBytes != null) {
        await _saveAndShareFile(
          fileBytes,
          '${_exportType}_${DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now())}.xlsx',
        );
      }
    } catch (e) {
      _showSnackBar('فشل التصدير: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportToCSV(List<Map<String, dynamic>> data) async {
    setState(() => _isLoading = true);
    try {
      if (data.isEmpty) {
        _showSnackBar('لا توجد بيانات للتصدير', isError: true);
        return;
      }

      final headers = data.first.keys.toList();
      final rows = data.map((row) => headers.map((h) => row[h]?.toString() ?? '').toList()).toList();
      
      final csvData = const ListToCsvConverter().convert([headers, ...rows]);
      final bytes = csvData.codeUnits;
      
      await _saveAndShareFile(
        bytes,
        '${_exportType}_${DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now())}.csv',
      );
    } catch (e) {
      _showSnackBar('فشل التصدير: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAndShareFile(List<int> bytes, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);
      
      await Share.shareXFiles([XFile(file.path)], text: 'تصدير البيانات');
      _showSnackBar('تم التصدير بنجاح');
    } catch (e) {
      _showSnackBar('فشل حفظ الملف: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('الإحصائيات والتصدير', style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: Colors.teal,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCard(
                      title: 'نوع البيانات',
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            title: const Text('العرسان', style: TextStyle(fontFamily: 'Cairo')),
                            value: 'grooms',
                            groupValue: _exportType,
                            onChanged: (v) => setState(() => _exportType = v!),
                          ),
                          RadioListTile<String>(
                            title: const Text('الحجوزات', style: TextStyle(fontFamily: 'Cairo')),
                            value: 'reservations',
                            groupValue: _exportType,
                            onChanged: (v) => setState(() => _exportType = v!),
                          ),
                        ],
                      ),
                    ),
                    if (_exportType == 'reservations') ...[
                      const SizedBox(height: 16),
                      _buildCard(
                        title: 'تصفية الحجوزات',
                        child: Column(
                          children: [
                            RadioListTile<String>(
                              title: const Text('جميع الحجوزات', style: TextStyle(fontFamily: 'Cairo')),
                              value: 'all',
                              groupValue: _reservationFilter,
                              onChanged: (v) => setState(() => _reservationFilter = v!),
                            ),
                            RadioListTile<String>(
                              title: const Text('القادمة', style: TextStyle(fontFamily: 'Cairo')),
                              value: 'upcoming',
                              groupValue: _reservationFilter,
                              onChanged: (v) => setState(() => _reservationFilter = v!),
                            ),
                            RadioListTile<String>(
                              title: const Text('الماضية', style: TextStyle(fontFamily: 'Cairo')),
                              value: 'past',
                              groupValue: _reservationFilter,
                              onChanged: (v) => setState(() => _reservationFilter = v!),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCard(
                        title: 'تحديد الفترة الزمنية (اختياري)',
                        child: Column(
                          children: [
                            if (_startDate != null && _endDate != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  'من ${DateFormat('yyyy-MM-dd').format(_startDate!)} إلى ${DateFormat('yyyy-MM-dd').format(_endDate!)}',
                                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 16),
                                ),
                              ),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _selectDateRange,
                                    icon: const Icon(Icons.calendar_today),
                                    label: Text(
                                      _startDate == null ? 'اختر الفترة' : 'تغيير الفترة',
                                      style: const TextStyle(fontFamily: 'Cairo'),
                                    ),
                                  ),
                                ),
                                if (_startDate != null) ...[
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () => setState(() {
                                      _startDate = null;
                                      _endDate = null;
                                    }),
                                    icon: const Icon(Icons.clear),
                                    tooltip: 'مسح',
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    _buildCard(
                      title: 'التصدير',
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final data = await _fetchData();
                                await _exportToExcel(data);
                              },
                              icon: const Icon(Icons.table_chart),
                              label: const Text('تصدير Excel', style: TextStyle(fontFamily: 'Cairo', fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final data = await _fetchData();
                                await _exportToCSV(data);
                              },
                              icon: const Icon(Icons.description),
                              label: const Text('تصدير CSV', style: TextStyle(fontFamily: 'Cairo', fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(16),
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

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }
}