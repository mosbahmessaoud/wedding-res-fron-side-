// import 'dart:io';

// import 'package:excel/excel.dart' as excel_lib;
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:open_file/open_file.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:wedding_reservation_app/screens/clan admin/home_screen.dart';
// import 'package:wedding_reservation_app/services/api_service.dart';
// import 'package:wedding_reservation_app/widgets/common/custom_text_field.dart';
// class ClanAdminStatisticsPage extends StatefulWidget {
//   const ClanAdminStatisticsPage({Key? key}) : super(key: key);

//   @override
//   State<ClanAdminStatisticsPage> createState() => ClanAdminStatisticsPageState();
// }

// class ClanAdminStatisticsPageState extends State<ClanAdminStatisticsPage> {
//   String _exportType = 'reservations';
//   String _reservationFilter = 'all';
//   DateTime? _startDate;
//   DateTime? _endDate;
//   bool _isLoading = false;
//   String _reservationStatusFilter = 'all'; // 'all' | 'pending' | 'validated'
//   void refreshData() {}

//   Future<void> _selectDateRange() async {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     await showDialog<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           child: ConstrainedBox(
//             constraints: BoxConstraints(maxWidth: 500, maxHeight: MediaQuery.of(context).size.height * 0.8),
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Text('اختر الفترة الزمنية', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Cairo'), textAlign: TextAlign.center),
//                   const SizedBox(height: 20),
//                   ..._buildPresetButtons(context, isDark),
//                   const Divider(height: 32),
//                   ElevatedButton.icon(
//                     onPressed: () async {
//                       Navigator.pop(context);
//                       final picked = await showDateRangePicker(
//                         context: context,
//                         firstDate: DateTime(2020),
//                         lastDate: DateTime(2030),
//                         initialDateRange: _startDate != null && _endDate != null ? DateTimeRange(start: _startDate!, end: _endDate!) : null,
//                       );
//                       if (picked != null) setState(() { _startDate = picked.start; _endDate = picked.end; });
//                     },
//                     icon: const Icon(Icons.edit_calendar),
//                     label: const Text('تحديد فترة مخصصة', style: TextStyle(fontFamily: 'Cairo')),
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
//                   ),
//                   const SizedBox(height: 8),
//                   TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   List<Widget> _buildPresetButtons(BuildContext context, bool isDark) {
//     final now = DateTime.now();
//     final presets = [
//       ('الشهر الحالي', Icons.calendar_today, DateTime(now.year, now.month, 1), DateTime(now.year, now.month + 1, 0, 23, 59, 59)),
//       ('الشهر الماضي', Icons.calendar_month, DateTime(now.year, now.month - 1, 1), DateTime(now.year, now.month, 0, 23, 59, 59)),
//       ('آخر 3 أشهر', Icons.date_range, now.subtract(const Duration(days: 90)), now),
//       ('السنة الحالية', Icons.calendar_month, DateTime(now.year, 1, 1), DateTime(now.year, 12, 31, 23, 59, 59)),
//       ('السنة الماضية', Icons.calendar_view_month, DateTime(now.year - 1, 1, 1), DateTime(now.year - 1, 12, 31, 23, 59, 59)),
//     ];
    
//     return presets.map((p) => Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: ElevatedButton.icon(
//         onPressed: () { setState(() { _startDate = p.$3; _endDate = p.$4; }); Navigator.pop(context); },
//         icon: Icon(p.$2),
//         label: Text(p.$1, style: const TextStyle(fontFamily: 'Cairo')),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: isDark ? Colors.teal.shade700 : Colors.teal.shade100,
//           foregroundColor: isDark ? Colors.white : Colors.teal.shade900,
//           padding: const EdgeInsets.all(16),
//           alignment: Alignment.centerRight,
//         ),
//       ),
//     )).toList();
//   }

// //   Future<List<Map<String, dynamic>>> _fetchData() async {
// //     if (_exportType == 'grooms') {
// //       final response = await ApiService.listGroomsForClanAdmin();
// //       return response.map((g) {
// //         final groom = g as Map<String, dynamic>;
// //         return {
// //           'اسم العريس': groom['first_name'] ?? '',
// //            'اسم الأب': groom['father_name'] ?? '',
// //            'اسم الجد': groom['grandfather_name'] ?? '',
// //           // 'اللقب': groom['last_name'] ?? '',
// //            'رقم الهاتف': groom['phone_number'] ?? '',
// //            'تاريخ الميلاد': groom['birth_date'] ?? '',
// //           'مكان الميلاد': groom['birth_address'] ?? '',
// //            'العنوان': groom['home_address'] ?? '',
// //            'اسم ولي الأمر': groom['guardian_name'] ?? '',
// //           'هاتف ولي الأمر': groom['guardian_phone'] ?? '',
// //            'صلة القرابة': groom['guardian_relation'] ?? '',
// //           'تاريخ ميلاد ولي الأمر': groom['guardian_birth_date'] ?? '',
// //            'مكان ميلاد ولي الأمر': groom['guardian_birth_address'] ?? '',
// //           'عنوان ولي الأمر': groom['guardian_home_address'] ?? '',
// //           //  'الحالة': groom['status'] ?? 'نشط',
// //           // 'تاريخ التسجيل': groom['created_at']?.toString().split('T')[0] ?? '',
// //         };
// //       }).toList();
// //     } else {
// //       try {
// //         final response = await ApiService.getAllReservationsClanAdmin();
// //         final now = DateTime.now();
// //         return response.map((r) => r as Map<String, dynamic>).where((r) {
// //           final date1 = r['date1'] != null ? DateTime.parse(r['date1']) : null;
// //           if (_startDate != null && _endDate != null && date1 != null && (date1.isBefore(_startDate!) || date1.isAfter(_endDate!))) return false;
// //           if (_reservationFilter == 'upcoming' && date1 != null && date1.isBefore(now)) return false;
// //           if (_reservationFilter == 'past' && date1 != null && date1.isAfter(now)) return false;
// //           return true;
// //         }).map((r) => {
// //           'تاريخ اقامة العرس': r['date1'] ?? '','الاسم الكامل للعريس': '${r['first_name']} ${r['father_name']} ${r['grandfather_name']} ${r['last_name']}',
// //           'اسم العريس': r['first_name'] ?? '', 'اسم الأب': r['father_name'] ?? '', 'اسم الجد': r['grandfather_name'] ?? '',
// //           // 'اللقب': r['last_name'] ?? '', 
// //           'رقم الهاتف': r['phone_number'] ?? '', 'تاريخ الميلاد': r['birth_date'] ?? '',
// //           'مكان الميلاد': r['birth_address'] ?? '', 'العنوان': r['home_address'] ?? '', 'اسم ولي الأمر': r['guardian_name'] ?? '',
// //           'هاتف ولي الأمر': r['guardian_phone'] ?? '', 'عنوان ولي الأمر': r['guardian_home_address'] ?? '',
// //           'مكان ميلاد ولي الأمر': r['guardian_birth_address'] ?? '', 'تاريخ ميلاد ولي الأمر': r['guardian_birth_date'] ?? '',
// //           //  'يومين': r['date2_bool'] == true ? 'نعم' : 'لا',
// //           'القاعة': r['hall_name'] ?? '', ' الهيئة': r['haia_committee_name'] ?? '', 'لجنة المداح': r['madaeh_committee_name'] ?? '',
// //           // 'الحالة': r['status'] ?? '', 
// //           // ' يقبل عرس جماعي': r['join_to_mass_wedding'] == true ? 'نعم' : 'لا',
// //            'الدفع': r['payment_valid'] == true ? 'مدفوع' : 'غير مدفوع',
// //           // 'تاريخ إنشاء الحجز': r['created_at']?.toString().split('T')[0] ?? '',
// //         }).toList();
// //       } catch (e) {
// //         _showSnackBar('خطأ في جلب البيانات: $e', isError: true);
// //         return [];
// //       }
// //     }
// //   }
// // Future<void> _exportToExcel(List<Map<String, dynamic>> data) async {
// //   setState(() => _isLoading = true);
// //   try {
// //     if (data.isEmpty) { _showSnackBar('لا توجد بيانات للتصدير', isError: true); return; }
    
// //     final excel = excel_lib.Excel.createExcel();
// //     final sheet = excel['البيانات'];
// //     final headers = data.first.keys.toList();
    
// //     for (var i = 0; i < headers.length; i++) {
// //       final cell = sheet.cell(excel_lib.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
// //       cell.value = excel_lib.TextCellValue(headers[i]);
// //       cell.cellStyle = excel_lib.CellStyle(bold: true, backgroundColorHex: excel_lib.ExcelColor.blue, fontColorHex: excel_lib.ExcelColor.white);
// //     }

// //     for (var rowIndex = 0; rowIndex < data.length; rowIndex++) {
// //       for (var colIndex = 0; colIndex < headers.length; colIndex++) {
// //         sheet.cell(excel_lib.CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: rowIndex + 1))
// //           .value = excel_lib.TextCellValue(data[rowIndex][headers[colIndex]]?.toString() ?? '');
// //       }
// //     }

// //     for (var i = 0; i < headers.length; i++) sheet.setColumnWidth(i, 20);

// //     final fileBytes = excel.save();
// //     if (fileBytes != null) {
// //       final directory = await getApplicationDocumentsDirectory();
// //       final filePath = '${directory.path}/${_exportType}_${DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now())}.xlsx';
// //       final file = File(filePath);
// //       await file.writeAsBytes(fileBytes);
      
// //       _showSnackBar('تم حفظ الملف بنجاح');
// //       _showFileOptionsDialog(filePath);
// //     }
// //   } catch (e) {
// //     _showSnackBar('فشل التصدير: $e', isError: true);
// //   } finally {
// //     setState(() => _isLoading = false);
// //   }
// // }

// Future<Map<String, List<Map<String, dynamic>>>> _fetchData() async {
//   if (_exportType == 'grooms') {
//     final response = await ApiService.listGroomsForClanAdmin();
//     final data = response.map((g) {
//       final groom = g as Map<String, dynamic>;
//       return {
//         'اسم العريس': groom['first_name'] ?? '',
//         'اسم الأب': groom['father_name'] ?? '',
//         'اسم الجد': groom['grandfather_name'] ?? '',
//         'رقم الهاتف': groom['phone_number'] ?? '',
//         'تاريخ الميلاد': groom['birth_date'] ?? '',
//         'مكان الميلاد': groom['birth_address'] ?? '',
//         'العنوان': groom['home_address'] ?? '',
//         'اسم ولي الأمر': groom['guardian_name'] ?? '',
//         'هاتف ولي الأمر': groom['guardian_phone'] ?? '',
//         'صلة القرابة': groom['guardian_relation'] ?? '',
//         'تاريخ ميلاد ولي الأمر': groom['guardian_birth_date'] ?? '',
//         'مكان ميلاد ولي الأمر': groom['guardian_birth_address'] ?? '',
//         'عنوان ولي الأمر': groom['guardian_home_address'] ?? '',
//       };
//     }).toList();
//     return {'all': data};
//   } else {
//     try {
//       List<dynamic> response;

//       if (_reservationStatusFilter == 'validated') {
//         response = await ApiService.getAllReservationsValidatedClanAdmin();
//       } else if (_reservationStatusFilter == 'pending') {
//         response = await ApiService.getAllReservationsPendingClanAdmin();
//       } else {
//         response = await ApiService.getAllReservationsClanAdmin();
//       }

//       final now = DateTime.now();

//       final filtered = response.map((r) => r as Map<String, dynamic>).where((r) {
//         final date1 = r['date1'] != null ? DateTime.parse(r['date1']) : null;
//         if (_startDate != null && _endDate != null && date1 != null &&
//             (date1.isBefore(_startDate!) || date1.isAfter(_endDate!))) return false;
//         if (_reservationFilter == 'upcoming' && date1 != null && date1.isBefore(now)) return false;
//         if (_reservationFilter == 'past' && date1 != null && date1.isAfter(now)) return false;
//         return true;
//       }).toList();

//       // ✅ Helper: convert days_remain int → human readable Arabic string
//       String formatDaysRemain(dynamic daysRaw) {
//         if (daysRaw == null) return '—';
//         final days = int.tryParse(daysRaw.toString());
//         if (days == null) return '—';
//         if (days > 0) return 'متبقي $days يوم';
//         if (days == 0) return 'ينتهي اليوم';
//         return 'انتهت الصلاحية قبل ${days.abs()} يوم';
//       }

//       Map<String, dynamic> mapReservation(Map<String, dynamic> r) => {
//         'تاريخ اقامة العرس': r['date1'] ?? '',
//         'الاسم الكامل للعريس': '${r['first_name']} ${r['father_name']} ${r['grandfather_name']} ${r['last_name']}',
//         'اسم العريس': r['first_name'] ?? '',
//         'اسم الأب': r['father_name'] ?? '',
//         'اسم الجد': r['grandfather_name'] ?? '',
//         'رقم الهاتف': r['phone_number'] ?? '',
//         'تاريخ الميلاد': r['birth_date'] ?? '',
//         'مكان الميلاد': r['birth_address'] ?? '',
//         'العنوان': r['home_address'] ?? '',
//         'اسم ولي الأمر': r['guardian_name'] ?? '',
//         'هاتف ولي الأمر': r['guardian_phone'] ?? '',
//         'عنوان ولي الأمر': r['guardian_home_address'] ?? '',
//         'مكان ميلاد ولي الأمر': r['guardian_birth_address'] ?? '',
//         'تاريخ ميلاد ولي الأمر': r['guardian_birth_date'] ?? '',
//         'القاعة': r['hall_name'] ?? '',
//         'الهيئة': r['haia_committee_name'] ?? '',
//         'لجنة المداح': r['madaeh_committee_name'] ?? '',
//         'الدفع': r['payment_valid'] == true ? 'مدفوع' : 'غير مدفوع',
//         'انتماء العريس': r['belongs_to_clan'] ?? '',
//         'نوع الحجز': r['reserved_incide'] ?? '',
//         'صلاحية الوثيقة': formatDaysRemain(r['days_remain']), // ✅ new column
//         if (_reservationStatusFilter == 'all') 'حالة الحجز': r['status'] ?? '',
//         '__raw_reserved_incide': r['reserved_incide'] ?? '',
//         '__raw_status': r['status'] ?? '',
//         '__raw_days_remain': r['days_remain']?.toString() ?? '', // ✅ for coloring
//       };

//       final belongs = filtered
//           .where((r) => r['belongs_to_clan'] == 'ينتمي إلى عشيرتنا')
//           .map(mapReservation)
//           .toList();
//       final notBelongs = filtered
//           .where((r) => r['belongs_to_clan'] == 'لا ينتمي إلى عشيرتنا')
//           .map(mapReservation)
//           .toList();

//       debugPrint('✅ Belongs count: ${belongs.length}');
//       debugPrint('❌ Not belongs count: ${notBelongs.length}');

//       return {'belongs': belongs, 'not_belongs': notBelongs};
//     } catch (e) {
//       _showSnackBar('خطأ في جلب البيانات: $e', isError: true);
//       return {'belongs': [], 'not_belongs': []};
//     }
//   }
// }
// Future<void> _exportToExcel(Map<String, List<Map<String, dynamic>>> dataMap) async {
//   setState(() => _isLoading = true);
//   try {
//     final allData = dataMap.values.expand((e) => e).toList();
//     if (allData.isEmpty) {
//       _showSnackBar('لا توجد بيانات للتصدير', isError: true);
//       return;
//     }

//     final directory = await getApplicationDocumentsDirectory();
//     final timestamp = DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now());

//     List<String> buildHeaders(List<Map<String, dynamic>> data) {
//       if (data.isEmpty) return [];
//       return data.first.keys.where((k) => !k.startsWith('__')).toList();
//     }

//     if (_exportType == 'grooms') {
//       final data = dataMap['all'] ?? [];
//       final groomHeaders = buildHeaders(data);
//       final excelFile = excel_lib.Excel.createExcel();

//       // ✅ FIX: set default before deleting Sheet1
//       final sheet = excelFile['البيانات'];
//       excelFile.setDefaultSheet('البيانات');
//       excelFile.delete('Sheet1');

//       for (var i = 0; i < groomHeaders.length; i++) {
//         final cell = sheet.cell(
//           excel_lib.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
//         );
//         cell.value = excel_lib.TextCellValue(groomHeaders[i]);
//         cell.cellStyle = excel_lib.CellStyle(
//           bold: true,
//           backgroundColorHex: excel_lib.ExcelColor.blue,
//           fontColorHex: excel_lib.ExcelColor.white,
//         );
//       }

//       for (var rowIndex = 0; rowIndex < data.length; rowIndex++) {
//         for (var colIndex = 0; colIndex < groomHeaders.length; colIndex++) {
//           sheet
//               .cell(excel_lib.CellIndex.indexByColumnRow(
//                 columnIndex: colIndex,
//                 rowIndex: rowIndex + 1,
//               ))
//               .value = excel_lib.TextCellValue(
//             data[rowIndex][groomHeaders[colIndex]]?.toString() ?? '',
//           );
//         }
//       }

//       for (var i = 0; i < groomHeaders.length; i++) sheet.setColumnWidth(i, 22);

//       final fileBytes = excelFile.save();
//       if (fileBytes != null) {
//         final path = '${directory.path}/قائمة_العرسان_$timestamp.xlsx';
//         await File(path).writeAsBytes(fileBytes);
//         _showSnackBar('تم حفظ الملف بنجاح');
//         _showFileOptionsDialog(path);
//       }
//     } else {
//       final belongs    = dataMap['belongs']     ?? [];
//       final notBelongs = dataMap['not_belongs'] ?? [];

//       final excelFile = excel_lib.Excel.createExcel();

//       final sheetName = switch (_reservationStatusFilter) {
//         'validated' => 'الحجوزات المؤكدة',
//         'pending'   => 'الحجوزات المعلقة',
//         _           => 'جميع الحجوزات',
//       };

//       // ✅ FIX: set default before deleting Sheet1
//       final sheet = excelFile[sheetName];
//       excelFile.setDefaultSheet(sheetName);
//       excelFile.delete('Sheet1');

//       final headers = buildHeaders(belongs.isNotEmpty ? belongs : notBelongs);

//       int currentRow = 0;

//       void writeSectionTitle(String title, excel_lib.ExcelColor bgColor) {
//         final cell = sheet.cell(
//           excel_lib.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
//         );
//         cell.value = excel_lib.TextCellValue(title);
//         cell.cellStyle = excel_lib.CellStyle(
//           bold: true,
//           fontSize: 16,
//           backgroundColorHex: bgColor,
//           fontColorHex: excel_lib.ExcelColor.white,
//           horizontalAlign: excel_lib.HorizontalAlign.Center,
//         );
//         sheet.merge(
//           excel_lib.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
//           excel_lib.CellIndex.indexByColumnRow(columnIndex: headers.length - 1, rowIndex: currentRow),
//         );
//         currentRow++;
//       }

//       void writeHeaders(excel_lib.ExcelColor bgColor) {
//         for (var i = 0; i < headers.length; i++) {
//           final cell = sheet.cell(
//             excel_lib.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow),
//           );
//           cell.value = excel_lib.TextCellValue(headers[i]);
//           cell.cellStyle = excel_lib.CellStyle(
//             bold: true,
//             backgroundColorHex: bgColor,
//             fontColorHex: excel_lib.ExcelColor.white,
//           );
//         }
//         currentRow++;
//       }

//       void writeRows(List<Map<String, dynamic>> data) {
//         for (final row in data) {
//           final rawReservedIncide = row['__raw_reserved_incide']?.toString() ?? '';
//           final rawStatus         = row['__raw_status']?.toString() ?? '';
//           final rawDaysRemain     = row['__raw_days_remain']?.toString() ?? '';
//           final daysRemainInt     = int.tryParse(rawDaysRemain);

//           for (var colIndex = 0; colIndex < headers.length; colIndex++) {
//             final colName = headers[colIndex];
//             final cell = sheet.cell(
//               excel_lib.CellIndex.indexByColumnRow(
//                 columnIndex: colIndex,
//                 rowIndex: currentRow,
//               ),
//             );

//             if (colName == 'نوع الحجز' && rawReservedIncide == 'الحجز في خارج العشيرة') {
//               cell.value = excel_lib.TextCellValue(row[colName]?.toString() ?? '');
//               cell.cellStyle = excel_lib.CellStyle(
//                 backgroundColorHex: excel_lib.ExcelColor.fromHexString('#C62828'),
//                 fontColorHex: excel_lib.ExcelColor.white,
//                 bold: true,
//               );
//             } else if (colName == 'حالة الحجز') {
//               final isValidated = rawStatus == 'validated' || rawStatus == 'confirmed';
//               cell.value = excel_lib.TextCellValue(isValidated ? 'مؤكد ✅' : 'معلق ⏳');
//               cell.cellStyle = excel_lib.CellStyle(
//                 backgroundColorHex: isValidated
//                     ? excel_lib.ExcelColor.fromHexString('#388E3C')
//                     : excel_lib.ExcelColor.fromHexString('#F57C00'),
//                 fontColorHex: excel_lib.ExcelColor.white,
//                 bold: true,
//               );
//             } else if (colName == 'صلاحية الوثيقة') {
//               cell.value = excel_lib.TextCellValue(row[colName]?.toString() ?? '—');
//               if (daysRemainInt != null) {
//                 if (daysRemainInt < 0) {
//                   cell.cellStyle = excel_lib.CellStyle(
//                     backgroundColorHex: excel_lib.ExcelColor.fromHexString('#B71C1C'),
//                     fontColorHex: excel_lib.ExcelColor.white,
//                     bold: true,
//                   );
//                 } else if (daysRemainInt == 0) {
//                   cell.cellStyle = excel_lib.CellStyle(
//                     backgroundColorHex: excel_lib.ExcelColor.fromHexString('#E65100'),
//                     fontColorHex: excel_lib.ExcelColor.white,
//                     bold: true,
//                   );
//                 } else if (daysRemainInt <= 3) {
//                   cell.cellStyle = excel_lib.CellStyle(
//                     backgroundColorHex: excel_lib.ExcelColor.fromHexString('#F9A825'),
//                     fontColorHex: excel_lib.ExcelColor.white,
//                     bold: true,
//                   );
//                 } else {
//                   cell.cellStyle = excel_lib.CellStyle(
//                     backgroundColorHex: excel_lib.ExcelColor.fromHexString('#2E7D32'),
//                     fontColorHex: excel_lib.ExcelColor.white,
//                   );
//                 }
//               }
//             } else {
//               cell.value = excel_lib.TextCellValue(row[colName]?.toString() ?? '');
//             }
//           }
//           currentRow++;
//         }
//       }

//       writeSectionTitle('◆  حجوزات من أبناء العشيرة  ◆', excel_lib.ExcelColor.green);
//       writeHeaders(excel_lib.ExcelColor.fromHexString('#1B5E20'));
//       writeRows(belongs);

//       currentRow += 2;

//       writeSectionTitle('◆  حجوزات من غير أبناء العشيرة  ◆', excel_lib.ExcelColor.orange);
//       writeHeaders(excel_lib.ExcelColor.fromHexString('#E65100'));
//       writeRows(notBelongs);

//       for (var i = 0; i < headers.length; i++) sheet.setColumnWidth(i, 22);

//       final fileBytes = excelFile.save();
//       if (fileBytes != null) {
//         final fileName = switch (_reservationStatusFilter) {
//           'validated' => 'الحجوزات_المؤكدة',
//           'pending'   => 'الحجوزات_المعلقة',
//           _           => 'جميع_الحجوزات',
//         };
//         final path = '${directory.path}/${fileName}_$timestamp.xlsx';
//         await File(path).writeAsBytes(fileBytes);
//         _showSnackBar(
//           'تم حفظ الملف بنجاح (${belongs.length} عشيرة + ${notBelongs.length} خارج) ✅',
//         );
//         _showFileOptionsDialog(path);
//       } else {
//         _showSnackBar('فشل إنشاء الملف', isError: true);
//       }
//     }
//   } catch (e) {
//     _showSnackBar('فشل التصدير: $e', isError: true);
//   } finally {
//     setState(() => _isLoading = false);
//   }
// }
// void _showFileOptionsDialog(String filePath) {
//   final fileName = filePath.split('/').last;
  
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: const Text('الملف جاهز', style: TextStyle(fontFamily: 'Cairo'), textAlign: TextAlign.center),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Text('ماذا تريد أن تفعل؟', style: TextStyle(fontFamily: 'Cairo'), textAlign: TextAlign.center),
//           const SizedBox(height: 8),
//           Text(fileName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
//         ],
//       ),
//       actions: [
//         if (!Platform.isWindows)
//           TextButton.icon(
//             onPressed: () async {
//               Navigator.pop(context);
//               await Share.shareXFiles([XFile(filePath)], text: 'تصدير البيانات');
//             },
//             icon: const Icon(Icons.share),
//             label: const Text('مشاركة', style: TextStyle(fontFamily: 'Cairo')),
//           ),
//         TextButton.icon(
//           onPressed: () async {
//             Navigator.pop(context);
//             if (Platform.isWindows) {
//               await OpenFile.open(filePath);
//             } else {
//               await OpenFile.open(filePath);
//             }
//           },
//           icon: const Icon(Icons.open_in_new),
//           label: const Text('فتح', style: TextStyle(fontFamily: 'Cairo')),
//         ),
//         if (Platform.isWindows)
//           TextButton.icon(
//             onPressed: () async {
//               Navigator.pop(context);
//               final directory = File(filePath).parent.path;
//               await Process.run('explorer', [directory]);
//             },
//             icon: const Icon(Icons.folder_open),
//             label: const Text('فتح المجلد', style: TextStyle(fontFamily: 'Cairo')),
//           ),
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('إغلاق', style: TextStyle(fontFamily: 'Cairo')),
//         ),
//       ],
//     ),
//   );
// }
//   void _showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
//       backgroundColor: isError ? Colors.red : Colors.green,
//     ));
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final isWide = MediaQuery.of(context).size.width > 600;
    
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('الإحصائيات والتصدير', style: TextStyle(fontFamily: 'Cairo')),
//         flexibleSpace: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     isDark ? AppColors.primary.withOpacity(0.4):AppColors.primary.withOpacity(0.8) ,
//                     AppColors.primary,
//                     AppColors.primary,
//                     isDark ? AppColors.primary.withOpacity(0.4):AppColors.primary.withOpacity(0.8) ,
//                     // isDark ? AppColors.primary.withOpacity(0.4):const Color.fromARGB(255, 130, 161, 112).withOpacity(0.9),
                    
//                   ],
//                 ),
//               ),
//             ),        
//           leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.of(context).pushReplacement(
//               MaterialPageRoute(
//                 builder: (context) => const ClanAdminHomeScreen(),
//               ),
//             );
//           },
//         ),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Center(
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(maxWidth: isWide ? 800 : double.infinity),
//                 child: SingleChildScrollView(
//                   padding: EdgeInsets.all(isWide ? 24 : 16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       _buildCard(isDark, 'نوع البيانات', Column(children: [
//                         // RadioListTile<String>(
//                         //   title: const Text('العرسان', style: TextStyle(fontFamily: 'Cairo')),
//                         //   subtitle: const Text('تشمل كافة المعلومات الشخصية ومعلومات ولي الأمر', style: TextStyle(fontFamily: 'Cairo', fontSize: 12)),
//                         //   value: 'grooms', groupValue: _exportType, onChanged: (v) => setState(() => _exportType = v!),
//                         // ),
//                         RadioListTile<String>(
//                           title: const Text('الحجوزات', style: TextStyle(fontFamily: 'Cairo')),
//                           subtitle: const Text('تشمل تفاصيل الحجز ومعلومات العريس وولي الأمر', style: TextStyle(fontFamily: 'Cairo', fontSize: 12)),
//                           value: 'reservations', groupValue: _exportType, onChanged: (v) => setState(() => _exportType = v!),
//                         ),
//                       ])),
//                       if (_exportType == 'reservations') ...[
//                         const SizedBox(height: 16),
//                         _buildCard(isDark, 'تصفية الحجوزات', Column(children: [
//                         // --- Status filter ---
//                         const Align(
//                           alignment: Alignment.centerRight,
//                           child: Text('حالة الحجز', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
//                         ),
//                         RadioListTile<String>(
//                           title: const Text('الكل', style: TextStyle(fontFamily: 'Cairo')),
//                           value: 'all', groupValue: _reservationStatusFilter,
//                           onChanged: (v) => setState(() => _reservationStatusFilter = v!),
//                         ),
//                         RadioListTile<String>(
//                           title: const Text('المعلقة فقط', style: TextStyle(fontFamily: 'Cairo')),
//                           value: 'pending', groupValue: _reservationStatusFilter,
//                           onChanged: (v) => setState(() => _reservationStatusFilter = v!),
//                         ),
//                         RadioListTile<String>(
//                           title: const Text('المؤكدة فقط', style: TextStyle(fontFamily: 'Cairo')),
//                           value: 'validated', groupValue: _reservationStatusFilter,
//                           onChanged: (v) => setState(() => _reservationStatusFilter = v!),
//                         ),
//                         const Divider(),
//                         // --- Date filter ---
//                         const Align(
//                           alignment: Alignment.centerRight,
//                           child: Text('موعد العرس', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
//                         ),
//                         RadioListTile<String>(title: const Text('جميع الحجوزات', style: TextStyle(fontFamily: 'Cairo')), value: 'all', groupValue: _reservationFilter, onChanged: (v) => setState(() => _reservationFilter = v!)),
//                         RadioListTile<String>(title: const Text('القادمة', style: TextStyle(fontFamily: 'Cairo')), value: 'upcoming', groupValue: _reservationFilter, onChanged: (v) => setState(() => _reservationFilter = v!)),
//                         RadioListTile<String>(title: const Text('الماضية', style: TextStyle(fontFamily: 'Cairo')), value: 'past', groupValue: _reservationFilter, onChanged: (v) => setState(() => _reservationFilter = v!)),
//                       ])),
//                         const SizedBox(height: 16),
//                         _buildCard(isDark, 'تحديد الفترة الزمنية (اختياري)', Column(children: [
//                           if (_startDate != null && _endDate != null)
//                             Container(
//                               padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 12),
//                               decoration: BoxDecoration(color: isDark ? Colors.teal.shade900.withOpacity(0.3) : Colors.teal.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: isDark ? Colors.teal.shade700 : Colors.teal.shade200)),
//                               child: Row(children: [
//                                 Icon(Icons.date_range, color: isDark ? Colors.teal.shade300 : Colors.teal),
//                                 const SizedBox(width: 8),
//                                 Expanded(child: Text('من ${DateFormat('yyyy/MM/dd').format(_startDate!)} إلى ${DateFormat('yyyy/MM/dd').format(_endDate!)}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold))),
//                               ]),
//                             ),
//                           Row(children: [
//                             Expanded(child: ElevatedButton.icon(
//                               onPressed: _selectDateRange,
//                               icon: const Icon(Icons.calendar_today),
//                               label: Text(_startDate == null ? 'اختر الفترة' : 'تغيير الفترة', style: const TextStyle(fontFamily: 'Cairo')),
//                               style: ElevatedButton.styleFrom(backgroundColor: isDark ? Colors.teal.shade700 : Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
//                             )),
//                             if (_startDate != null) ...[
//                               const SizedBox(width: 8),
//                               IconButton(onPressed: () => setState(() { _startDate = null; _endDate = null; }), icon: const Icon(Icons.clear), tooltip: 'مسح', style: IconButton.styleFrom(backgroundColor: isDark ? Colors.red.shade900.withOpacity(0.3) : Colors.red.shade50, foregroundColor: Colors.red)),
//                             ],
//                           ]),
//                         ])),
//                       ],
//                       const SizedBox(height: 24),
//                       _buildCard(isDark, 'التصدير', SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton.icon(
//                           // onPressed: () async { final data = await _fetchData(); await _exportToExcel(data); },
//                           onPressed: () async {
//                               final data = await _fetchData();
//                               await _exportToExcel(data);
//                             },
//                           icon: const Icon(Icons.table_chart),
//                           label: const Text('تصدير Excel', style: TextStyle(fontFamily: 'Cairo', fontSize: 16)),
//                           style: ElevatedButton.styleFrom(backgroundColor: isDark ? Colors.green.shade700 : Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
//                         ),
//                       )),
//                       const SizedBox(height: 50),

//                     ],
//                   ),
//                 ),
//               ),
//             ),
//     );
//   }

//   Widget _buildCard(bool isDark, String title, Widget child) {
//     return Card(
//       elevation: 3,
//       color: isDark ? Colors.grey.shade900 : Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
//             Divider(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
//             child,
//           ],
//         ),
//       ),
//     );
//   }
// }