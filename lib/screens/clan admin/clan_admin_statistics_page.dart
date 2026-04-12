import 'dart:io';
import 'dart:ui';

import 'package:excel/excel.dart' as excel_lib;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wedding_reservation_app/screens/clan admin/home_screen.dart';
import 'package:wedding_reservation_app/services/api_service.dart';
import 'package:wedding_reservation_app/services/connectivity_service.dart';
import 'package:wedding_reservation_app/utils/colors.dart';

// ─── Design tokens ───────────────────────────────────────────────────────────
class _C {
  // Calm sage-slate palette
  static const bg         = Color(0xFF1C2333); // deep navy
  static const surface    = Color(0xFF232D42); // card base
  static const glass      = Color(0x18FFFFFF); // frosted glass fill
  static const glassBorder= Color(0x28FFFFFF); // glass border
  static const primary    = Color(0xFF6EAF8B); // sage green
  static const secondary  = Color(0xFF7BA7BC); // muted teal-blue
  static const accent     = Color(0xFFE8C07D); // warm sand
  static const danger     = Color(0xFFE07070); // muted red
  static const textPrimary= Color(0xFFEAEEF4);
  static const textMuted  = Color(0xFF8A96AA);
  static const divider    = Color(0x20FFFFFF);
}
// ─────────────────────────────────────────────────────────────────────────────

class ClanAdminStatisticsPage extends StatefulWidget {
  const ClanAdminStatisticsPage({Key? key}) : super(key: key);

  @override
  State<ClanAdminStatisticsPage> createState() => ClanAdminStatisticsPageState();
}

class ClanAdminStatisticsPageState extends State<ClanAdminStatisticsPage> {
  String _exportType            = 'reservations';
  String _reservationFilter     = 'all';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading               = false;
  String _reservationStatusFilter = 'all';

  void refreshData() {}

  // ─── Date range picker ────────────────────────────────────────────────────
  Future<void> _selectDateRange() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: _GlassContainer(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 460, maxHeight: MediaQuery.of(ctx).size.height * 0.8),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('اختر الفترة الزمنية',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                          fontFamily: 'Cairo', color: _C.textPrimary),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  ..._buildPresetButtons(ctx),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: _C.divider),
                  ),
                  _GlassButton(
                    color: _C.accent,
                    icon: Icons.edit_calendar,
                    label: 'تحديد فترة مخصصة',
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        initialDateRange: _startDate != null && _endDate != null
                            ? DateTimeRange(start: _startDate!, end: _endDate!)
                            : null,
                      );
                      if (picked != null) setState(() { _startDate = picked.start; _endDate = picked.end; });
                    },
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: _C.textMuted)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPresetButtons(BuildContext ctx) {
    final now = DateTime.now();
    final presets = [
      ('الشهر الحالي',   Icons.calendar_today,      DateTime(now.year, now.month, 1),     DateTime(now.year, now.month + 1, 0, 23, 59, 59)),
      ('الشهر الماضي',   Icons.calendar_month,       DateTime(now.year, now.month - 1, 1), DateTime(now.year, now.month, 0, 23, 59, 59)),
      ('آخر 3 أشهر',    Icons.date_range,            now.subtract(const Duration(days: 90)), now),
      ('السنة الحالية',  Icons.calendar_month,        DateTime(now.year, 1, 1),             DateTime(now.year, 12, 31, 23, 59, 59)),
      ('السنة الماضية',  Icons.calendar_view_month,   DateTime(now.year - 1, 1, 1),         DateTime(now.year - 1, 12, 31, 23, 59, 59)),
    ];
    return presets.map((p) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _GlassButton(
        color: _C.secondary,
        icon: p.$2,
        label: p.$1,
        onPressed: () { setState(() { _startDate = p.$3; _endDate = p.$4; }); Navigator.pop(ctx); },
      ),
    )).toList();
  }

void _showOfflineBanner() {
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(children: const [
        Icon(Icons.wifi_off, color: Colors.white, size: 18),
        SizedBox(width: 8),
        Text('لا يوجد اتصال بالإنترنت - لا يمكن تصدير البيانات'),
      ]),
      backgroundColor: Colors.red.shade700,
      duration: const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
  // ─── Fetch data (unchanged logic) ─────────────────────────────────────────
Future<Map<String, List<Map<String, dynamic>>>> _fetchData() async {
  final isOnline = ConnectivityService().isOnline ||
      await ConnectivityService().checkRealInternet();

  if (!isOnline) {
    _showOfflineBanner();
    return {'belongs': [], 'not_belongs': [], 'all': []};
  }
    if (_exportType == 'grooms') {
      final response = await ApiService.listGroomsForClanAdmin();
      final data = response.map((g) {
        final groom = g as Map<String, dynamic>;
        return {
          'اسم العريس': groom['first_name'] ?? '',
          'اسم الأب': groom['father_name'] ?? '',
          'اسم الجد': groom['grandfather_name'] ?? '',
          'رقم الهاتف': groom['phone_number'] ?? '',
          'تاريخ الميلاد': groom['birth_date'] ?? '',
          'مكان الميلاد': groom['birth_address'] ?? '',
          'العنوان': groom['home_address'] ?? '',
          'اسم ولي الأمر': groom['guardian_name'] ?? '',
          'هاتف ولي الأمر': groom['guardian_phone'] ?? '',
          'صلة القرابة': groom['guardian_relation'] ?? '',
          'تاريخ ميلاد ولي الأمر': groom['guardian_birth_date'] ?? '',
          'مكان ميلاد ولي الأمر': groom['guardian_birth_address'] ?? '',
          'عنوان ولي الأمر': groom['guardian_home_address'] ?? '',
        };
      }).toList();
      return {'all': data};
    } else {
      try {
        List<dynamic> response;
        if (_reservationStatusFilter == 'validated') {
          response = await ApiService.getAllReservationsValidatedClanAdmin();
        } else if (_reservationStatusFilter == 'pending') {
          response = await ApiService.getAllReservationsPendingClanAdmin();
        } else {
          response = await ApiService.getAllReservationsClanAdmin();
        }

        final now = DateTime.now();
        final filtered = response.map((r) => r as Map<String, dynamic>).where((r) {
          final date1 = r['date1'] != null ? DateTime.parse(r['date1']) : null;
          if (_startDate != null && _endDate != null && date1 != null &&
              (date1.isBefore(_startDate!) || date1.isAfter(_endDate!))) return false;
          if (_reservationFilter == 'upcoming' && date1 != null && date1.isBefore(now)) return false;
          if (_reservationFilter == 'past'     && date1 != null && date1.isAfter(now))  return false;
          return true;
        }).toList();

        String formatDaysRemain(dynamic daysRaw) {
          if (daysRaw == null) return '—';
          final days = int.tryParse(daysRaw.toString());
          if (days == null) return '—';
          if (days > 0)  return 'متبقي $days يوم';
          if (days == 0) return 'ينتهي اليوم';
          return 'انتهت الصلاحية قبل ${days.abs()} يوم';
        }

        Map<String, dynamic> mapReservation(Map<String, dynamic> r) => {
          'تاريخ اقامة العرس': r['date1'] ?? '',
          'الاسم الكامل للعريس': '${r['first_name']} ${r['father_name']} ${r['grandfather_name']} ${r['last_name']}',
          'اسم العريس': r['first_name'] ?? '',
          'اسم الأب': r['father_name'] ?? '',
          'اسم الجد': r['grandfather_name'] ?? '',
          'رقم الهاتف': r['phone_number'] ?? '',
          'تاريخ الميلاد': r['birth_date'] ?? '',
          'مكان الميلاد': r['birth_address'] ?? '',
          'العنوان': r['home_address'] ?? '',
          'اسم ولي الأمر': r['guardian_name'] ?? '',
          'هاتف ولي الأمر': r['guardian_phone'] ?? '',
          'عنوان ولي الأمر': r['guardian_home_address'] ?? '',
          'مكان ميلاد ولي الأمر': r['guardian_birth_address'] ?? '',
          'تاريخ ميلاد ولي الأمر': r['guardian_birth_date'] ?? '',
          'القاعة': r['hall_name'] ?? '',
          'الهيئة': r['haia_committee_name'] ?? '',
          'لجنة المداح': r['madaeh_committee_name'] ?? '',
          'الدفع': r['payment_valid']  ?? '', // the payment_valid is one of these "paid" , "not_paid" , "partially_paid"
          'المبلغ المدفوع': r['payment'] != null ? '${r['payment']} دج' : '—',

          'انتماء العريس': r['belongs_to_clan'] ?? '',
          'نوع الحجز': r['reserved_incide'] ?? '',
          'صلاحية الوثيقة': formatDaysRemain(r['days_remain']),
          if (_reservationStatusFilter == 'all') 'حالة الحجز': r['status'] ?? '',
          '__raw_payment': r['payment_valid']?.toString() ?? '',
          '__raw_reserved_incide': r['reserved_incide'] ?? '',
          '__raw_status': r['status'] ?? '',
          '__raw_days_remain': r['days_remain']?.toString() ?? '',
          '__raw_hall': r['hall_name']?.toString() ?? '',
        };

        final belongs    = filtered.where((r) => r['belongs_to_clan'] == 'ينتمي إلى عشيرتنا').map(mapReservation).toList();
        final notBelongs = filtered.where((r) => r['belongs_to_clan'] == 'لا ينتمي إلى عشيرتنا').map(mapReservation).toList();
        debugPrint('✅ Belongs: ${belongs.length}  ❌ Not belongs: ${notBelongs.length}');
        return {'belongs': belongs, 'not_belongs': notBelongs};
      } catch (e) {
        _showSnackBar('خطأ في جلب البيانات: $e', isError: true);
        return {'belongs': [], 'not_belongs': []};
      }
    }
  }

  // ─── Export to Excel (unchanged logic, fixed default sheet) ───────────────
  Future<void> _exportToExcel(Map<String, List<Map<String, dynamic>>> dataMap) async {
    setState(() => _isLoading = true);
    try {
      final allData = dataMap.values.expand((e) => e).toList();
      if (allData.isEmpty) { _showSnackBar('لا توجد بيانات للتصدير', isError: true); return; }

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now());

      List<String> buildHeaders(List<Map<String, dynamic>> data) =>
          data.isEmpty ? [] : data.first.keys.where((k) => !k.startsWith('__')).toList();

      if (_exportType == 'grooms') {
        final data        = dataMap['all'] ?? [];
        final groomHeaders = buildHeaders(data);
        final excelFile   = excel_lib.Excel.createExcel();
        final sheet       = excelFile['البيانات'];
        excelFile.setDefaultSheet('البيانات');
        excelFile.delete('Sheet1');

        for (var i = 0; i < groomHeaders.length; i++) {
          final cell = sheet.cell(excel_lib.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
          cell.value = excel_lib.TextCellValue(groomHeaders[i]);
          cell.cellStyle = excel_lib.CellStyle(bold: true,
              backgroundColorHex: excel_lib.ExcelColor.blue, fontColorHex: excel_lib.ExcelColor.white);
        }
        for (var r = 0; r < data.length; r++) {
          for (var c = 0; c < groomHeaders.length; c++) {
            sheet.cell(excel_lib.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1))
                .value = excel_lib.TextCellValue(data[r][groomHeaders[c]]?.toString() ?? '');
          }
        }
        for (var i = 0; i < groomHeaders.length; i++) sheet.setColumnWidth(i, 22);

        final bytes = excelFile.save();
        if (bytes != null) {
          final path = '${directory.path}/قائمة_العرسان_$timestamp.xlsx';
          await File(path).writeAsBytes(bytes);
          _showSnackBar('تم حفظ الملف بنجاح');
          _showFileOptionsDialog(path);
        }
      } else {
        final belongs    = dataMap['belongs']     ?? [];
        final notBelongs = dataMap['not_belongs'] ?? [];
        final excelFile  = excel_lib.Excel.createExcel();
        final sheetName  = switch (_reservationStatusFilter) {
          'validated' => 'الحجوزات المؤكدة',
          'pending'   => 'الحجوزات المعلقة',
          _           => 'جميع الحجوزات',
        };
        final sheet = excelFile[sheetName];
        excelFile.setDefaultSheet(sheetName);
        excelFile.delete('Sheet1');

        final headers = buildHeaders(belongs.isNotEmpty ? belongs : notBelongs);
        int currentRow = 0;

        void writeSectionTitle(String title, excel_lib.ExcelColor bg) {
          final cell = sheet.cell(excel_lib.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
          cell.value = excel_lib.TextCellValue(title);
          cell.cellStyle = excel_lib.CellStyle(bold: true, fontSize: 16, backgroundColorHex: bg,
              fontColorHex: excel_lib.ExcelColor.white, horizontalAlign: excel_lib.HorizontalAlign.Center);
          sheet.merge(
            excel_lib.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
            excel_lib.CellIndex.indexByColumnRow(columnIndex: headers.length - 1, rowIndex: currentRow),
          );
          currentRow++;
        }

        void writeHeaders(excel_lib.ExcelColor bg) {
          for (var i = 0; i < headers.length; i++) {
            final cell = sheet.cell(excel_lib.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow));
            cell.value = excel_lib.TextCellValue(headers[i]);
            cell.cellStyle = excel_lib.CellStyle(bold: true, backgroundColorHex: bg, fontColorHex: excel_lib.ExcelColor.white);
          }
          currentRow++;
        }

        // void writeRows(List<Map<String, dynamic>> data) {
        //   for (final row in data) {
        //     final rawRI   = row['__raw_reserved_incide']?.toString() ?? '';
        //     final rawSt   = row['__raw_status']?.toString() ?? '';
        //     final rawDays = row['__raw_days_remain']?.toString() ?? '';
        //     final daysInt = int.tryParse(rawDays);
        //     for (var c = 0; c < headers.length; c++) {
        //       final col  = headers[c];
        //       final cell = sheet.cell(excel_lib.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: currentRow));
        //       if (col == 'نوع الحجز' && rawRI == 'الحجز في خارج العشيرة') {
        //         cell.value = excel_lib.TextCellValue(row[col]?.toString() ?? '');
        //         cell.cellStyle = excel_lib.CellStyle(backgroundColorHex: excel_lib.ExcelColor.fromHexString('#C62828'),
        //             fontColorHex: excel_lib.ExcelColor.white, bold: true);
        //       } else if (col == 'حالة الحجز') {
        //         final ok = rawSt == 'validated' || rawSt == 'confirmed';
        //         cell.value = excel_lib.TextCellValue(ok ? 'مؤكد ✅' : 'معلق ⏳');
        //         cell.cellStyle = excel_lib.CellStyle(
        //             backgroundColorHex: excel_lib.ExcelColor.fromHexString(ok ? '#388E3C' : '#F57C00'),
        //             fontColorHex: excel_lib.ExcelColor.white, bold: true);
        //       } else if (col == 'صلاحية الوثيقة') {
        //         cell.value = excel_lib.TextCellValue(row[col]?.toString() ?? '—');
        //         if (daysInt != null) {
        //           final hex = daysInt < 0 ? '#B71C1C' : daysInt == 0 ? '#E65100' : daysInt <= 3 ? '#F9A825' : '#2E7D32';
        //           cell.cellStyle = excel_lib.CellStyle(backgroundColorHex: excel_lib.ExcelColor.fromHexString(hex),
        //               fontColorHex: excel_lib.ExcelColor.white, bold: daysInt <= 3);
        //         }
        //       } else if (col == 'الدفع') {
        //         final raw = row['__raw_payment']?.toString() ?? '';
        //         final (label, hex) = switch (raw) {
        //           'paid'            => ('مدفوع ✅',        '#2E7D32'),
        //           'not_paid'        => ('غير مدفوع ❌',    '#B71C1C'),
        //           'partially_paid'  => ('مدفوع جزئياً ⚠️', '#E65100'),
        //           _                 => (raw, '#607D8B'),
        //         };
        //         cell.value = excel_lib.TextCellValue(label);
        //         cell.cellStyle = excel_lib.CellStyle(
        //           backgroundColorHex: excel_lib.ExcelColor.fromHexString(hex),
        //           fontColorHex: excel_lib.ExcelColor.white,
        //           bold: true,
        //         ); 
        //         } else {
        //         cell.value = excel_lib.TextCellValue(row[col]?.toString() ?? '');
        //       }
        //     }
        //     currentRow++;
        //   }
        // }
        void writeRows(List<Map<String, dynamic>> data) {
          for (final row in data) {
            final rawRI   = row['__raw_reserved_incide']?.toString() ?? '';
            final rawSt   = row['__raw_status']?.toString() ?? '';
            final rawDays = row['__raw_days_remain']?.toString() ?? '';
            final daysInt = int.tryParse(rawDays);
            for (var c = 0; c < headers.length; c++) {
              final col  = headers[c];
              final cell = sheet.cell(excel_lib.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: currentRow));

              if (col == 'نوع الحجز') {
  final (label, hex) = switch (rawRI) {
    'الحجز في داخل العشيرة' => ('الحجز في داخل العشيرة', ''),
    'الحجز في خارج العشيرة' => ('الحجز في خارج العشيرة', '#C62828'),
    _                       => (rawRI.isEmpty ? '—' : rawRI, '#455A64'),
  };
  cell.value = excel_lib.TextCellValue(label);
  if (hex.isNotEmpty) {
    cell.cellStyle = excel_lib.CellStyle(
      backgroundColorHex: excel_lib.ExcelColor.fromHexString(hex),
      fontColorHex: excel_lib.ExcelColor.white,
      bold: true,
    );
  }

} else if (col == 'القاعة') {
  final raw = row['__raw_hall']?.toString() ?? '';
  final rawReserved = row['__raw_reserved_incide']?.toString() ?? '';
  final (label, hex) = raw.isEmpty
      ? ('—', '#455A64')
      : rawReserved == 'الحجز في خارج العشيرة'
          ? (raw, '#C62828')
          : (raw, '');
  cell.value = excel_lib.TextCellValue(label);
  if (hex.isNotEmpty) {
    cell.cellStyle = excel_lib.CellStyle(
      backgroundColorHex: excel_lib.ExcelColor.fromHexString(hex),
      fontColorHex: excel_lib.ExcelColor.white,
      bold: true,
    );
  }} else if (col == 'حالة الحجز') {
                final ok = rawSt == 'validated' || rawSt == 'confirmed';
                cell.value = excel_lib.TextCellValue(ok ? 'مؤكد ✅' : 'معلق ');
                cell.cellStyle = excel_lib.CellStyle(
                  backgroundColorHex: excel_lib.ExcelColor.fromHexString(ok ? '#388E3C' : '#F57C00'),
                  fontColorHex: excel_lib.ExcelColor.white,
                  bold: true,
                );

              } else if (col == 'صلاحية الوثيقة') {
                cell.value = excel_lib.TextCellValue(row[col]?.toString() ?? '—');
                if (daysInt != null) {
                  final hex = daysInt < 0 ? '#B71C1C' : daysInt == 0 ? '#E65100' : daysInt <= 3 ? '#F9A825' : '#2E7D32';
                  cell.cellStyle = excel_lib.CellStyle(
                    backgroundColorHex: excel_lib.ExcelColor.fromHexString(hex),
                    fontColorHex: excel_lib.ExcelColor.white,
                    bold: daysInt <= 3,
                  );
                }

              } else if (col == 'الدفع') {
                final raw = row['__raw_payment']?.toString() ?? '';
                final (label, hex) = switch (raw) {
                  'paid'           => ('مدفوع ✅',         '#2E7D32'),
                  'not_paid'       => ('غير مدفوع ',     ''),
                  'partially_paid' => ('مدفوع جزئياً ',  '#E65100'),
                  _                => (raw.isEmpty ? '—' : raw, ''),
                };
                cell.value = excel_lib.TextCellValue(label);
                if (hex.isNotEmpty) {
                  cell.cellStyle = excel_lib.CellStyle(
                    backgroundColorHex: excel_lib.ExcelColor.fromHexString(hex),
                    fontColorHex: excel_lib.ExcelColor.white,
                    bold: true,
                  );
                }
                

              } else if (col == 'المبلغ المدفوع') {
                final rawPayment = row['__raw_payment']?.toString() ?? '';
                final amount = row[col]?.toString() ?? '—';
                final hex = switch (rawPayment) {
                  'paid'           => '#2E7D32',
                  'not_paid'       => '#B71C1C',
                  'partially_paid' => '#E65100',
                  _                => '#607D8B',
                };
                cell.value = excel_lib.TextCellValue(amount);
                cell.cellStyle = excel_lib.CellStyle(
                  backgroundColorHex: excel_lib.ExcelColor.fromHexString(hex),
                  fontColorHex: excel_lib.ExcelColor.white,
                  bold: true,
                );
                } else {
                cell.value = excel_lib.TextCellValue(row[col]?.toString() ?? '');
              }
            }
            currentRow++;
          }
        }

        writeSectionTitle('◆  حجوزات من أبناء العشيرة  ◆', excel_lib.ExcelColor.green);
        writeHeaders(excel_lib.ExcelColor.fromHexString('#1B5E20'));
        writeRows(belongs);
        currentRow += 2;
        writeSectionTitle('◆  حجوزات من غير أبناء العشيرة  ◆', excel_lib.ExcelColor.orange);
        writeHeaders(excel_lib.ExcelColor.fromHexString('#E65100'));
        writeRows(notBelongs);
        for (var i = 0; i < headers.length; i++) sheet.setColumnWidth(i, 22);

        final bytes = excelFile.save();
        if (bytes != null) {
          final fn = switch (_reservationStatusFilter) {
            'validated' => 'الحجوزات_المؤكدة', 'pending' => 'الحجوزات_المعلقة', _ => 'جميع_الحجوزات',
          };
          final path = '${directory.path}/${fn}_$timestamp.xlsx';
          await File(path).writeAsBytes(bytes);
          _showSnackBar('تم حفظ الملف بنجاح (${belongs.length} عشيرة + ${notBelongs.length} خارج) ✅');
          _showFileOptionsDialog(path);
        } else {
          _showSnackBar('فشل إنشاء الملف', isError: true);
        }
      }
    } catch (e) {
      _showSnackBar('فشل التصدير: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ─── File options dialog ──────────────────────────────────────────────────
  void _showFileOptionsDialog(String filePath) {
    final fileName = filePath.split('/').last;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: _GlassContainer(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, color: _C.primary, size: 48),
                const SizedBox(height: 12),
                const Text('الملف جاهز', style: TextStyle(fontFamily: 'Cairo', fontSize: 18,
                    fontWeight: FontWeight.w600, color: _C.textPrimary)),
                const SizedBox(height: 6),
                Text(fileName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: _C.textMuted),
                    textAlign: TextAlign.center),
                const SizedBox(height: 20),
                Row(
                  children: [
                    if (!Platform.isWindows) ...[
                      Expanded(child: _GlassButton(
                        color: _C.secondary, icon: Icons.share, label: 'مشاركة',
                        onPressed: () async { Navigator.pop(ctx); await Share.shareXFiles([XFile(filePath)], text: 'تصدير البيانات'); },
                      )),
                      const SizedBox(width: 8),
                    ],
                    Expanded(child: _GlassButton(
                      color: _C.primary, icon: Icons.open_in_new, label: 'فتح',
                      onPressed: () async { Navigator.pop(ctx); await OpenFile.open(filePath); },
                    )),
                    if (Platform.isWindows) ...[
                      const SizedBox(width: 8),
                      Expanded(child: _GlassButton(
                        color: _C.accent, icon: Icons.folder_open, label: 'المجلد',
                        onPressed: () async { Navigator.pop(ctx); await Process.run('explorer', [File(filePath).parent.path]); },
                      )),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('إغلاق', style: TextStyle(fontFamily: 'Cairo', color: _C.textMuted)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
      backgroundColor: isError ? _C.danger : _C.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 33, 82, 42),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? AppColors.primary.withOpacity(0.4):AppColors.primary.withOpacity(0.8) ,
            AppColors.primary,
            AppColors.primary,
            isDark ? AppColors.primary.withOpacity(0.4):AppColors.primary.withOpacity(0.8) ,
            // isDark ? AppColors.primary.withOpacity(0.4):const Color.fromARGB(255, 130, 161, 112).withOpacity(0.9),
            
          ],
        ),
      ),
            ),
          ),
        ),
        title: const Text('الإحصائيات والتصدير',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600,
                color: _C.textPrimary, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _C.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ClanAdminHomeScreen())),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _C.primary))
          : Stack(
              children: [
                // Background ambient blobs
                Positioned(top: -80, right: -60, child: _blob(const Color.fromARGB(255, 89, 148, 115).withOpacity(0.18), 280)),
                Positioned(bottom: 100, left: -80, child: _blob(const Color.fromARGB(255, 38, 163, 88).withOpacity(0.14), 320)),
                Positioned(top: 200, left: 40,    child: _blob(const Color.fromARGB(255, 108, 159, 45).withOpacity(0.08), 180)),
                // Scrollable content
                SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: isWide ? 760 : double.infinity),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(isWide ? 24 : 16, 20, isWide ? 24 : 16, 60),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Data type card
                            _GlassCard(
                              title: 'نوع البيانات',
                              icon: Icons.dataset_outlined,
                              child: _glassRadio('الحجوزات', 'reservations', _exportType,
                                  'تشمل تفاصيل الحجز ومعلومات العريس وولي الأمر',
                                  (v) => setState(() => _exportType = v!)),
                            ),

                            if (_exportType == 'reservations') ...[
                              const SizedBox(height: 14),

                              // Reservation filter card
                              _GlassCard(
                                title: 'تصفية الحجوزات',
                                icon: Icons.filter_list_rounded,
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  _sectionLabel('حالة الحجز'),
                                  _glassRadio('الكل',         'all',       _reservationStatusFilter, null, (v) => setState(() => _reservationStatusFilter = v!)),
                                  _glassRadio('المعلقة فقط',  'pending',   _reservationStatusFilter, null, (v) => setState(() => _reservationStatusFilter = v!)),
                                  _glassRadio('المؤكدة فقط',  'validated', _reservationStatusFilter, null, (v) => setState(() => _reservationStatusFilter = v!)),
                                  const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(color: _C.divider)),
                                  _sectionLabel('موعد العرس'),
                                  _glassRadio('جميع الحجوزات', 'all',      _reservationFilter, null, (v) => setState(() => _reservationFilter = v!)),
                                  _glassRadio('القادمة',        'upcoming', _reservationFilter, null, (v) => setState(() => _reservationFilter = v!)),
                                  _glassRadio('الماضية',        'past',     _reservationFilter, null, (v) => setState(() => _reservationFilter = v!)),
                                ]),
                              ),

                              const SizedBox(height: 14),

                              // Date range card
                              _GlassCard(
                                title: 'الفترة الزمنية (اختياري)',
                                icon: Icons.date_range_rounded,
                                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                                  if (_startDate != null && _endDate != null)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _C.secondary.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: _C.secondary.withOpacity(0.3)),
                                      ),
                                      child: Row(children: [
                                        const Icon(Icons.event_available, color: _C.secondary, size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          'من ${DateFormat('yyyy/MM/dd').format(_startDate!)} إلى ${DateFormat('yyyy/MM/dd').format(_endDate!)}',
                                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: _C.textPrimary),
                                        ),
                                      ]),
                                    ),
                                  Row(children: [
                                    Expanded(child: _GlassButton(
                                      color: _C.secondary,
                                      icon: Icons.calendar_today,
                                      label: _startDate == null ? 'اختر الفترة' : 'تغيير الفترة',
                                      onPressed: _selectDateRange,
                                    )),
                                    if (_startDate != null) ...[
                                      const SizedBox(width: 8),
                                      _circleIconBtn(Icons.close_rounded, _C.danger,
                                          () => setState(() { _startDate = null; _endDate = null; })),
                                    ],
                                  ]),
                                ]),
                              ),
                            ],

                            const SizedBox(height: 20),

                            // Export button
                            _GlassButton(
                              color: _C.primary,
                              icon: Icons.table_chart_rounded,
                              label: 'تصدير Excel',
                              large: true,
                              onPressed: () async {
                                final data = await _fetchData();
                                await _exportToExcel(data);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // ─── Small helpers ────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4, top: 2),
    child: Text(text, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13,
        fontWeight: FontWeight.w600, color: _C.textMuted)),
  );

  Widget _glassRadio(String title, String value, String groupValue,
      String? subtitle, ValueChanged<String?> onChanged) =>
    RadioListTile<String>(
      dense: true,
      title: Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: _C.textPrimary)),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: _C.textMuted))
          : null,
      value: value, groupValue: groupValue, onChanged: onChanged,
      activeColor: _C.primary,
      contentPadding: EdgeInsets.zero,
    );

  Widget _circleIconBtn(IconData icon, Color color, VoidCallback onPressed) =>
    Material(
      color: color.withOpacity(0.15),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(padding: const EdgeInsets.all(10), child: Icon(icon, color: color, size: 18)),
      ),
    );

  Widget _blob(Color color, double size) =>
    Container(width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle,
            color: color, boxShadow: [BoxShadow(color: color, blurRadius: 80, spreadRadius: 20)]));
}

// ─── Reusable glass widgets ───────────────────────────────────────────────────

class _GlassContainer extends StatelessWidget {
  final Widget child;
  const _GlassContainer({required this.child});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        decoration: BoxDecoration(
          color: _C.glass,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _C.glassBorder),
        ),
        child: child,
      ),
    ),
  );
}

class _GlassCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _GlassCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Container(
        decoration: BoxDecoration(
          color: _C.glass,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _C.glassBorder),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: _C.primary, size: 18),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 15,
                fontWeight: FontWeight.w600, color: _C.textPrimary)),
          ]),
          const SizedBox(height: 10),
          const Divider(color: _C.divider, height: 1),
          const SizedBox(height: 10),
          child,
        ]),
      ),
    ),
  );
}

class _GlassButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool large;
  const _GlassButton({required this.color, required this.icon,
      required this.label, required this.onPressed, this.large = false});

  @override
  Widget build(BuildContext context) => Material(
    color: color.withOpacity(0.18),
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: large ? 16 : 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: large ? 20 : 17),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: large ? 16 : 14,
                fontWeight: FontWeight.w600, color: _C.textPrimary)),
          ],
        ),
      ),
    ),
  );
}