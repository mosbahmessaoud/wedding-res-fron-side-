// import 'dart:io';
// import 'dart:typed_data';

// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:open_file/open_file.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:wedding_reservation_app/services/api_service.dart';

// class GroomClanRulesPage extends StatefulWidget {
//   final int? clanId;
//   final String? clanName;

//   const GroomClanRulesPage({
//     Key? key,
//     this.clanId,
//     this.clanName,
//   }) : super(key: key);

//   @override
//   State<GroomClanRulesPage> createState() => GroomClanRulesPageState();
// }

// class GroomClanRulesPageState extends State<GroomClanRulesPage> {
//   bool _isLoading = true;
//   bool _hasError = false;
//   String _errorMessage = '';
//   Map<String, dynamic>? _clanRules;
//   List<String> _pdfUrls = [];
//   int? _resolvedClanId;
  
//   // PDF-related state
//   String? _clanRulesPdfUrl;
//   bool _hasClanRulesPdf = false;
//   bool _isDownloading = false;
//   double _downloadProgress = 0.0;

//   // Reservation check state
//   bool _hasValidReservation = false;
//   bool _isCheckingReservation = true;

//   @override
//   void initState() {
//     super.initState();
//     _initializeClanId();
//   }

//   Future<void> _initializeClanId() async {
//     await _checkReservationStatus();
//     if (_hasValidReservation) {
//       await _checkConnectivityAndLoad();
//     } else {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _checkReservationStatus() async {
//     setState(() {
//       _isCheckingReservation = true;
//     });

//     try {
//       // Check for validated reservation
//       final validatedReservation = await ApiService.getMyValidatedReservation();
      
//       if (validatedReservation != null && validatedReservation.isNotEmpty) {
//         setState(() {
//           _hasValidReservation = true;
//           _isCheckingReservation = false;
//         });
//         return;
//       }
//     } catch (e) {
//       print('No validated reservation found: $e');
//     }

//     setState(() {
//       _hasValidReservation = false;
//       _isCheckingReservation = false;
//     });
//   }

//   void refreshData() {
//     _initializeClanId();
//   }

//   Future<void> _checkConnectivityAndLoad() async {
//     setState(() {
//       _isLoading = true;
//       _hasError = false;
//     });
    
//     // Show loading for 2 seconds
//     await Future.delayed(Duration(seconds: 2));
    
//     final connectivityResult = await Connectivity().checkConnectivity();
    
//     if (connectivityResult.contains(ConnectivityResult.none)) {
//       setState(() {
//         _isLoading = false;
//         _clanRules = null; // Set to null to show empty state
//       });
//       return;
//     }
    
//     await _loadInitialData();
//   }

//   Future<void> _loadInitialData() async {
//     if (widget.clanId != null) {
//       _resolvedClanId = widget.clanId;
//       await _loadClanRules();
//       await _checkForClanRulesPdf();
//     } else {
//       await _fetchUserClanId();
//     }
//   }

//   void _showNoInternetDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(
//           children: [
//             Icon(Icons.wifi_off, color: Colors.orange),
//             SizedBox(width: 10),
//             Text('لا يوجد اتصال'),
//           ],
//         ),
//         content: Text('يرجى التحقق من اتصالك بالإنترنت'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _checkConnectivityAndLoad();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Theme.of(context).primaryColor,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//             child: Text('إعادة المحاولة', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _fetchUserClanId() async {
//     setState(() {
//       _isLoading = true;
//       _hasError = false;
//     });

//     try {
//       final profile = await ApiService.getProfile();
      
//       if (profile != null && profile['clan_id'] != null) {
//         setState(() {
//           _resolvedClanId = profile['clan_id'];
//         });
//         await _loadClanRules();
//         await _checkForClanRulesPdf();
//       } else {
//         setState(() {
//           _clanRules = null; // Show empty state instead of error
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       print('Error fetching clan ID: $e');
//       setState(() {
//         _clanRules = null; // Show empty state instead of error
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _checkForClanRulesPdf() async {
//     if (_resolvedClanId == null) return;

//     try {
//       final hasPdf = await ApiService.clanHasRulesPdf(_resolvedClanId!);
      
//       if (hasPdf) {
//         final pdfData = await ApiService.getClanRulesPdf(_resolvedClanId!);
//         setState(() {
//           _hasClanRulesPdf = true;
//           _clanRulesPdfUrl = pdfData['pdf_url'];
//         });
//       } else {
//         setState(() {
//           _hasClanRulesPdf = false;
//           _clanRulesPdfUrl = null;
//         });
//       }
//     } catch (e) {
//       print('Error checking for clan rules PDF: $e');
//       setState(() {
//         _hasClanRulesPdf = false;
//         _clanRulesPdfUrl = null;
//       });
//     }
//   }

//   Future<void> _loadClanRules() async {
//     setState(() {
//       _isLoading = true;
//       _hasError = false;
//     });
    
//     // Show loading for 2 seconds
//     await Future.delayed(Duration(seconds: 2));
    
//     final connectivityResult = await Connectivity().checkConnectivity();
    
//     if (connectivityResult.contains(ConnectivityResult.none)) {
//       setState(() {
//         _isLoading = false;
//         _clanRules = null; // Show empty state instead of error
//       });
//       return;
//     }

//     if (_resolvedClanId == null) {
//       setState(() {
//         _isLoading = false;
//         _clanRules = null; // Show empty state instead of error
//       });
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _hasError = false;
//       _errorMessage = '';
//     });

//     try {
//       final rules = await ApiService.getGroomClanRulesByClanId(_resolvedClanId!);
      
//       if (rules != null) {
//         setState(() {
//           _clanRules = rules;
//           _pdfUrls = ApiService.extractPdfUrls(rules);
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _clanRules = null; // Show empty state instead of error
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       print('Error loading clan rules: $e');
//       setState(() {
//         _clanRules = null; // Show empty state instead of error
//         _isLoading = false;
//       });
//     }
//   }

//   /// Extract file ID from the full PDF URL
//   String? _extractFileIdFromUrl(String pdfUrl) {
//     try {
//       final uri = Uri.parse(pdfUrl);
//       final segments = uri.pathSegments;
      
//       if (segments.isNotEmpty) {
//         return segments.last;
//       }
//       return null;
//     } catch (e) {
//       print('Error extracting file ID: $e');
//       return null;
//     }
//   }

//   Future<void> _openPdf(String pdfUrl) async {
//     try {
//       _showSnackBar('جاري فتح الملف...', Colors.blue.shade400);
      
//       // Download and open the PDF
//       final pdfBytes = await ApiService.downloadPdfFromUrl(pdfUrl);
      
//       if (pdfBytes == null || pdfBytes.isEmpty) {
//         throw Exception('فشل تحميل الملف');
//       }

//       // Save to temporary directory
//       final tempDir = await getTemporaryDirectory();
//       final fileName = pdfUrl.split('/').last;
//       final tempFile = File('${tempDir.path}/$fileName');
      
//       await tempFile.writeAsBytes(pdfBytes);

//       // Open the file
//       final result = await OpenFile.open(tempFile.path);
      
//       if (result.type != ResultType.done) {
//         _showSnackBar('لا يوجد تطبيق لفتح ملفات PDF', Colors.orange);
//       }
//     } catch (e) {
//       print('Error opening PDF: $e');
//       _showSnackBar('خطأ في فتح الملف: $e', Colors.red);
//     }
//   }

//   Future<void> _openClanRulesPdf() async {
//     if (_clanRulesPdfUrl == null) {
//       _showSnackBar('لا يوجد رابط PDF', Colors.red);
//       return;
//     }

//     setState(() {
//       _isDownloading = true;
//       _downloadProgress = 0.0;
//     });

//     try {
//       // Download the PDF first
//       final pdfBytes = await ApiService.downloadPdfFromUrl(_clanRulesPdfUrl!);
      
//       if (pdfBytes == null || pdfBytes.isEmpty) {
//         throw Exception('فشل تحميل البيانات');
//       }

//       // Save to temporary directory
//       final tempDir = await getTemporaryDirectory();
//       final fileName = _generatePdfFileName();
//       final tempFile = File('${tempDir.path}/$fileName');
      
//       await tempFile.writeAsBytes(pdfBytes);
      
//       setState(() {
//         _isDownloading = false;
//         _downloadProgress = 0.0;
//       });

//       // Open the file using the system's default PDF viewer
//       final result = await OpenFile.open(tempFile.path);
      
//       if (result.type != ResultType.done) {
//         _showSnackBar('لا يوجد تطبيق لفتح ملفات PDF', Colors.orange);
//       }
//     } catch (e) {
//       print('Error opening PDF: $e');
//       setState(() {
//         _isDownloading = false;
//         _downloadProgress = 0.0;
//       });
//       _showSnackBar('خطأ في فتح الملف: $e', Colors.red);
//     }
//   }

//   Future<void> _downloadClanRulesPdf() async {
//     if (_clanRulesPdfUrl == null) {
//       _showSnackBar('لا يوجد رابط PDF', Colors.red);
//       return;
//     }

//     // Request storage permission first
//     if (Platform.isAndroid) {
//       var status = await Permission.storage.status;
//       if (!status.isGranted) {
//         status = await Permission.storage.request();
//         if (!status.isGranted) {
//           // Try manage external storage for Android 11+
//           status = await Permission.manageExternalStorage.request();
//           if (!status.isGranted) {
//             _showSnackBar('يجب منح صلاحية الوصول للتخزين', Colors.red);
//             return;
//           }
//         }
//       }
//     }

//     setState(() {
//       _isDownloading = true;
//       _downloadProgress = 0.0;
//     });

//     try {
//       _showSnackBar('جاري التحميل...', Colors.blue.shade400);
      
//       // Download the PDF
//       final pdfBytes = await ApiService.downloadPdfFromUrl(_clanRulesPdfUrl!);
      
//       if (pdfBytes == null || pdfBytes.isEmpty) {
//         throw Exception('فشل تحميل البيانات');
//       }

//       setState(() {
//         _downloadProgress = 0.5;
//       });

//       // Save to device storage
//       final savedFile = await _savePdfFile(pdfBytes);
      
//       setState(() {
//         _isDownloading = false;
//         _downloadProgress = 0.0;
//       });

//       if (savedFile != null) {
//         _showPdfActionsDialog(savedFile.path, pdfBytes);
//       } else {
//         throw Exception('فشل حفظ الملف');
//       }
//     } catch (e) {
//       print('Download error: $e');
//       setState(() {
//         _isDownloading = false;
//         _downloadProgress = 0.0;
//       });
//       _showSnackBar('خطأ في التحميل: $e', Colors.red);
//     }
//   }

//   String _generatePdfFileName() {
//     final clanName = widget.clanName ?? _clanRules?['clan_name'] ?? 'العشيرة';
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     return 'قوانين_${clanName.replaceAll(' ', '_')}_$timestamp.pdf';
//   }

//   Future<File?> _savePdfFile(Uint8List pdfBytes) async {
//     try {
//       Directory? directory;
      
//       if (Platform.isAndroid) {
//         // Request storage permission first
//         var status = await Permission.storage.status;
//         if (!status.isGranted) {
//           status = await Permission.storage.request();
//           if (!status.isGranted) {
//             // Try with manage external storage permission for Android 11+
//             status = await Permission.manageExternalStorage.request();
//             if (!status.isGranted) {
//               throw Exception('يجب منح صلاحية الوصول للتخزين لحفظ الملف');
//             }
//           }
//         }
        
//         // Try to save to Downloads folder (public directory)
//         try {
//           final downloadsPath = '/storage/emulated/0/Download';
//           directory = Directory(downloadsPath);
          
//           if (!await directory.exists()) {
//             // Fallback to external storage directory
//             directory = await getExternalStorageDirectory();
//             if (directory != null) {
//               // Try to create a public-like path
//               final publicPath = Directory('/storage/emulated/0/Android/data/${directory.path.split('/').last}/files/Download');
//               await publicPath.create(recursive: true);
//               directory = publicPath;
//             }
//           }
//         } catch (e) {
//           // Final fallback to app directory
//           directory = await getExternalStorageDirectory();
//         }
//       } else {
//         // iOS - use documents directory
//         directory = await getApplicationDocumentsDirectory();
//       }
      
//       if (directory == null) {
//         throw Exception('لا يمكن الوصول إلى مجلد التخزين');
//       }
      
//       // Ensure directory exists
//       if (!await directory.exists()) {
//         await directory.create(recursive: true);
//       }
      
//       // Create file with custom name
//       final fileName = _generatePdfFileName();
//       final file = File('${directory.path}/$fileName');

//       // Write bytes to file
//       await file.writeAsBytes(pdfBytes);
      
//       return file;
//     } catch (e) {
//       print('Error saving file: $e');
//       return null;
//     }
//   }

//   Future<void> _sharePdf(Uint8List pdfBytes) async {
//     try {
//       // Generate custom filename
//       final fileName = _generatePdfFileName();
      
//       // Create a temporary file for sharing
//       final tempDir = await getTemporaryDirectory();
//       final tempFile = File('${tempDir.path}/$fileName');
      
//       await tempFile.writeAsBytes(pdfBytes);
      
//       // Share the file
//       await Share.shareXFiles(
//         [XFile(tempFile.path)],
//         text: 'اللوازم - ${widget.clanName ?? "العشيرة"}',
//         subject: 'اللوازم',
//       );
      
//       _showSnackBar('تم فتح خيارات المشاركة', Colors.green.shade400);
//     } catch (e) {
//       print('Share error: $e');
//       _showSnackBar('خطأ في مشاركة الملف: $e', Colors.red);
//     }
//   }

//   // void _showPdfActionsDialog(String filePath, Uint8List pdfBytes) {
//   //   if (!mounted) return;
    
//   //   showDialog(
//   //     context: context,
//   //     builder: (context) => AlertDialog(
//   //       title: const Text('تم تحميل الملف'),
//   //       content: Column(
//   //         mainAxisSize: MainAxisSize.min,
//   //         crossAxisAlignment: CrossAxisAlignment.start,
//   //         children: [
//   //           const Text('تم حفظ ملف PDF بنجاح.'),
//   //           const SizedBox(height: 16),
//   //           Row(
//   //             children: [
//   //               Icon(Icons.info, color: Colors.blue, size: 16),
//   //               SizedBox(width: 8),
//   //               Expanded(
//   //                 child: Text(
//   //                   'الملف محفوظ في مجلد التحميلات',
//   //                   style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
//   //                 ),
//   //               ),
//   //             ],
//   //           ),
//   //         ],
//   //       ),
//   //       actions: [
//   //         TextButton(
//   //           onPressed: () => Navigator.pop(context),
//   //           child: const Text('إغلاق'),
//   //         ),
//   //         ElevatedButton.icon(
//   //           onPressed: () async {
//   //             Navigator.pop(context);
//   //             await _sharePdf(pdfBytes);
//   //           },
//   //           icon: const Icon(Icons.share),
//   //           label: const Text('مشاركة'),
//   //           style: ElevatedButton.styleFrom(
//   //             backgroundColor: Colors.blue,
//   //             foregroundColor: Colors.white,
//   //           ),
//   //         ),
//   //         ElevatedButton.icon(
//   //           onPressed: () async {
//   //             Navigator.pop(context);
//   //             try {
//   //               await OpenFile.open(filePath);
//   //             } catch (e) {
//   //               _showSnackBar('لا يمكن فتح الملف تلقائياً', Colors.orange);
//   //             }
//   //           },
//   //           icon: const Icon(Icons.open_in_new),
//   //           label: const Text('فتح'),
//   //           style: ElevatedButton.styleFrom(
//   //             backgroundColor: Colors.green,
//   //             foregroundColor: Colors.white,
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

// // Replace the _showPdfActionsDialog method with this updated version:
// void _showPdfActionsDialog(String filePath, Uint8List pdfBytes) {
//   if (!mounted) return;
  
//   final isDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
//   final isDark = Theme.of(context).brightness == Brightness.dark;
  
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       title: Row(
//         children: [
//           Icon(Icons.check_circle, color: Colors.green, size: 28),
//           SizedBox(width: 8),
//           Text('تم التحميل بنجاح'),
//         ],
//       ),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'تم حفظ الملف في:',
//             style: TextStyle(
//               color: isDark ? Colors.white : Colors.black87,
//             ),
//           ),
//           SizedBox(height: 8),
//           Container(
//             padding: EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: isDark ? Colors.grey[800] : Colors.grey[200],
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(
//                 color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
//               ),
//             ),
//             child: SelectableText(
//               filePath,
//               style: TextStyle(
//                 fontSize: 12,
//                 fontFamily: 'monospace',
//                 color: isDark ? Colors.white70 : Colors.black87,
//               ),
//             ),
//           ),
//           SizedBox(height: 16),
//           Row(
//             children: [
//               Icon(Icons.folder, color: Colors.blue, size: 18),
//               SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   isDesktop 
//                       ? 'الملف محفوظ في مجلد التحميلات'
//                       : 'الملف محفوظ في مجلد التحميلات',
//                   style: TextStyle(fontSize: 12, color: Colors.blue[700]),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('إغلاق'),
//         ),
//         if (!isDesktop)
//           ElevatedButton.icon(
//             onPressed: () async {
//               Navigator.pop(context);
//               await _sharePdf(pdfBytes);
//             },
//             icon: const Icon(Icons.share, size: 18),
//             label: const Text('مشاركة'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//         ElevatedButton.icon(
//           onPressed: () async {
//             Navigator.pop(context);
//             try {
//               final result = await OpenFile.open(filePath);
//               if (result.type != ResultType.done) {
//                 _showSnackBar('لا يمكن فتح الملف تلقائياً', Colors.orange);
//               }
//             } catch (e) {
//               _showSnackBar('خطأ في فتح الملف', Colors.red);
//             }
//           },
//           icon: const Icon(Icons.open_in_new, size: 18),
//           label: const Text('فتح الملف'),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.green,
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }

//   void _showSnackBar(String message, Color backgroundColor) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: backgroundColor,
//           duration: const Duration(seconds: 3),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }

//   Widget _buildRuleSection({
//     required String title,
//     required IconData icon,
//     required String? content,
//     Color? iconColor,
//   }) {
//     if (content == null || content.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return Card(
//       elevation: 2,
//       margin: const EdgeInsets.only(bottom: 16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   icon,
//                   color: iconColor ?? Theme.of(context).primaryColor,
//                   size: 24,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const Divider(height: 24),
//             Text(
//               content,
//               style: const TextStyle(
//                 fontSize: 15,
//                 height: 1.6,
//               ),
//               textAlign: TextAlign.justify,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildClanRulesPdfCard() {
//     if (!_hasClanRulesPdf) {
//       return const SizedBox.shrink();
//     }

//     return Card(
//       elevation: 3,
//       margin: const EdgeInsets.only(bottom: 16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//                const Color(0xFF1E1E1E) ,
//                const Color.fromARGB(145, 73, 73, 73) 
//             ],
//           ),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   const Icon(
//                     Icons.picture_as_pdf,
//                     color: Colors.white,
//                     size: 32,
//                   ),
//                   const SizedBox(width: 12),
//                   const Expanded(
//                     child: Text(
//                       'كتاب اللوازم الرسمي',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               const Text(
//                 'الكتاب الرسمي لاللوازم متاح للعرض والتحميل',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.white70,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               if (_isDownloading)
//                 Column(
//                   children: [
//                     LinearProgressIndicator(
//                       value: _downloadProgress > 0 ? _downloadProgress : null,
//                       backgroundColor: Colors.white30,
//                       valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       _downloadProgress > 0
//                           ? 'جاري التحميل: ${(_downloadProgress * 100).toInt()}%'
//                           : 'جاري التحميل...',
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: Colors.white70,
//                       ),
//                     ),
//                   ],
//                 )
//               else
//                 Row(
//                   children: [
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: _downloadClanRulesPdf,
//                         icon: const Icon(Icons.download, size: 20),
//                         label: const Text('تحميل'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.white,
//                           foregroundColor: Colors.red[700],
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPdfSection() {
//     if (_pdfUrls.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return Card(
//       elevation: 2,
//       margin: const EdgeInsets.only(bottom: 16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   Icons.picture_as_pdf,
//                   color: Colors.red[700],
//                   size: 24,
//                 ),
//                 const SizedBox(width: 12),
//                 const Expanded(
//                   child: Text(
//                     'مستندات إضافية (PDF)',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const Divider(height: 24),
//             ListView.separated(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: _pdfUrls.length,
//               separatorBuilder: (context, index) => const SizedBox(height: 8),
//               itemBuilder: (context, index) {
//                 final pdfUrl = _pdfUrls[index];
//                 final fileName = pdfUrl.split('/').last;
                
//                 return InkWell(
//                   onTap: () => _openPdf(pdfUrl),
//                   borderRadius: BorderRadius.circular(8),
//                   child: Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.red[50],
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.red[200]!),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.insert_drive_file,
//                           color: Colors.red[700],
//                           size: 32,
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 fileName,
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.red[900],
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 'اضغط للفتح',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Icon(
//                           Icons.arrow_forward_ios,
//                           color: Colors.red[700],
//                           size: 16,
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLoadingState() {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(),
//           SizedBox(height: 16),
//           Text(
//             'جاري تحميل اللوازم...',
//             style: TextStyle(fontSize: 16),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCheckingReservationState() {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(),
//           SizedBox(height: 16),
//           Text(
//             'جاري التحقق من حالة الحجز...',
//             style: TextStyle(fontSize: 16),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.error_outline,
//               size: 64,
//               color: Colors.red[300],
//             ),
//             const SizedBox(height: 16),
//             Text(
//               _errorMessage,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Colors.red,
//               ),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: _loadClanRules,
//               icon: const Icon(Icons.refresh),
//               label: const Text('إعادة المحاولة'),
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 24,
//                   vertical: 12,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.description_outlined,
//               size: 80,
//               color: Colors.grey[300],
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'لا توجد قوانين متاحة حالياً',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'سيتم إضافة اللوازم قريباً',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 15,
//                 color: Colors.grey[600],
//                 height: 1.5,
//               ),
//             ),
//             const SizedBox(height: 32),
//             ElevatedButton.icon(
//               onPressed: () async {
//                 await _loadClanRules();
//                 await _checkForClanRulesPdf();
//               },
//               icon: const Icon(Icons.refresh),
//               label: const Text('تحديث'),
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 32,
//                   vertical: 14,
//                 ),
//                 backgroundColor: Theme.of(context).primaryColor,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNoReservationState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.lock_outline,
//               size: 100,
//               color: Colors.orange[300],
//             ),
//             const SizedBox(height: 32),
//             const Text(
//               'يجب أن يكون لديك حجز مؤكد',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'لعرض اللوازم، يجب أن يكون لديك حجز مؤكد .',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey[700],
//                 height: 1.6,
//               ),
//             ),
//             // const SizedBox(height: 40),
//             // Container(
//             //   padding: const EdgeInsets.all(20),
//             //   decoration: BoxDecoration(
//             //     color: Colors.orange[50],
//             //     borderRadius: BorderRadius.circular(16),
//             //     border: Border.all(color: Colors.orange[200]!),
//             //   ),
//             //   child: Column(
//             //     children: [
//             //       Icon(
//             //         Icons.info_outline,
//             //         color: Colors.orange[700],
//             //         size: 32,
//             //       ),
//             //       const SizedBox(height: 12),
//             //       Text(
//             //         'للوصول إلى هذه الصفحة:',
//             //         style: TextStyle(
//             //           fontSize: 16,
//             //           fontWeight: FontWeight.bold,
//             //           color: Colors.orange[900],
//             //         ),
//             //       ),
//             //       const SizedBox(height: 8),
//             //       Text(
//             //         '1. قم بإنشاء حجز جديد\n'
//             //         '2. انتظر موافقة إدارة العشيرة\n'
//             //         '3. بعد التأكيد، ستتمكن من عرض اللوازم',
//             //         textAlign: TextAlign.center,
//             //         style: TextStyle(
//             //           fontSize: 14,
//             //           color: Colors.grey[800],
//             //           height: 1.5,
//             //         ),
//             //       ),
//             //     ],
//             //   ),
//             // ),
//             const SizedBox(height: 32),
//             ElevatedButton.icon(
//   onPressed: () {
//     Navigator.pushNamed(
//       context,
//       '/groom_home',
//     );
//   },
//   icon: const Icon(Icons.arrow_back),
//   label: const Text('العودة للرئيسية'),
//   style: ElevatedButton.styleFrom(
//     padding: const EdgeInsets.symmetric(
//       horizontal: 32,
//       vertical: 16,
//     ),
//     backgroundColor: Colors.transparent,
//     foregroundColor: Theme.of(context).primaryColor,
//     elevation: 0,
//     side: BorderSide(
//       color: Theme.of(context).primaryColor,
//       width: 2,
//     ),
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(12),
//     ),
//   ),
// ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildContent() {
//     if (_clanRules == null) {
//       return _buildEmptyState();
//     }

//     return RefreshIndicator(
//       onRefresh: () async {
//         await _loadClanRules();
//         await _checkForClanRulesPdf();
//       },
//       child: SingleChildScrollView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Clan Info Card
//             Card(
//               elevation: 3,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Theme.of(context).primaryColor,
//                       Theme.of(context).primaryColor.withOpacity(0.7),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   children: [
//                     const Icon(
//                       Icons.gavel,
//                       color: Colors.white,
//                       size: 48,
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       widget.clanName ?? 'اللوازم',
//                       style: const TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 4),
//                     const Text(
//                       'يرجى قراءة اللوازم بعناية',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.white70,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),

//             // Clan Rules PDF Card (Prominent)
//             _buildClanRulesPdfCard(),

//             // General Rule
//             _buildRuleSection(
//               title: 'القاعدة العامة',
//               icon: Icons.rule,
//               content: _clanRules!['general_rule']?.toString(),
//               iconColor: Colors.blue[700],
//             ),

//             // Groom Supplies
//             _buildRuleSection(
//               title: 'لوازم العريس',
//               icon: Icons.shopping_bag,
//               content: _clanRules!['groom_supplies']?.toString(),
//               iconColor: Colors.orange[700],
//             ),

//             // Clothing Rules
//             _buildRuleSection(
//               title: 'قواعد الملابس',
//               icon: Icons.checkroom,
//               content: _clanRules!['rule_about_clothing']?.toString(),
//               iconColor: Colors.purple[700],
//             ),

//             // Kitchenware Rules
//             _buildRuleSection(
//               title: 'قواعد أدوات المطبخ',
//               icon: Icons.kitchen,
//               content: _clanRules!['rule_about_kitchenware']?.toString(),
//               iconColor: Colors.green[700],
//             ),

//             // Additional PDF Section (from extracted URLs)
//             _buildPdfSection(),

//             // Timestamps
//             if (_clanRules!['updated_at'] != null)
//               Padding(
//                 padding: const EdgeInsets.only(top: 8, bottom: 16),
//                 child: Center(
//                   child: Text(
//                     'آخر تحديث: ${_formatDate(_clanRules!['updated_at'])}',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey[600],
//                       fontStyle: FontStyle.italic,
//                     ),
//                   ),
//                 ),
//               ),
//             const SizedBox(height: 150),
//           ],
//         ),
//       ),
//     );
//   }

//   String _formatDate(dynamic dateString) {
//     try {
//       final date = DateTime.parse(dateString.toString());
//       return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
//     } catch (e) {
//       return dateString.toString();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       onPopInvokedWithResult: (bool didPop, dynamic result) {
//         return;
//       },
//       child: Directionality(
//         textDirection: TextDirection.rtl,
//         child: Scaffold(
//           body: _isCheckingReservation
//               ? _buildCheckingReservationState()
//               : !_hasValidReservation
//                   ? _buildNoReservationState()
//                   : _isLoading
//                       ? _buildLoadingState()
//                       : _hasError
//                           ? _buildErrorState()
//                           : _buildContent(),
//         ),
//       ),
//     );
//   }
// }