
// // lib/screens/clan_admin/clan_rules_management_page.dart

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:file_picker/file_picker.dart';
// import 'dart:io';
// import '../../utils/colors.dart';
// import '../../services/api_service.dart';
// import '../../widgets/common/custom_text_field.dart';
// import '../../widgets/theme_toggle_button.dart';
// import '../../providers/theme_provider.dart';
// import 'package:flutter/services.dart'; // For PlatformException

// class ClanRulesManagementPage extends StatefulWidget {
//   final int clanId;
//   final String clanName;

//   const ClanRulesManagementPage({
//     Key? key,
//     required this.clanId,
//     required this.clanName,
//   }) : super(key: key);

//   @override
//   State<ClanRulesManagementPage> createState() => ClanRulesManagementPageState();
// }

// class ClanRulesManagementPageState extends State<ClanRulesManagementPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _generalRuleController = TextEditingController();
//   final _groomSuppliesController = TextEditingController();
//   final _clothingRuleController = TextEditingController();
//   final _kitchenwareRuleController = TextEditingController();
  
//   bool _isLoading = false;
//   bool _hasExistingRules = false;
//   int? _existingRuleId;
//   Map<String, dynamic>? _currentRules;
//   List<String> _existingPdfUrls = [];
//   List<File> _selectedPdfFiles = [];
//   List<String> _selectedPdfNames = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadExistingRules();
//   }

//   // Public method to refresh data from parent
//   void refreshData() {
//     _loadExistingRules();
//     setState(() {
//       // Trigger rebuild
//     });
//   }

//   @override
//   void dispose() {
//     _generalRuleController.dispose();
//     _groomSuppliesController.dispose();
//     _clothingRuleController.dispose();
//     _kitchenwareRuleController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadExistingRules() async {
//     setState(() => _isLoading = true);
    
//     try {
//       final rules = await ApiService.getClanRulesByClanId(widget.clanId);
      
//       setState(() {
//         _hasExistingRules = true;
//         _currentRules = rules;
//         _existingRuleId = rules['id'];
//         _generalRuleController.text = rules['general_rule'] ?? '';
//         _groomSuppliesController.text = rules['groom_supplies'] ?? '';
//         _clothingRuleController.text = rules['rule_about_clothing'] ?? '';
//         _kitchenwareRuleController.text = rules['rule_about_kitchenware'] ?? '';
        
//         // Load existing PDF URLs
//         _existingPdfUrls = ApiService.extractPdfUrls(rules);
//       });
//     } catch (e) {
//       // No existing rules found
//       setState(() {
//         _hasExistingRules = false;
//         _currentRules = null;
//         _existingRuleId = null;
//         _existingPdfUrls = [];
//       });
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _pickPdfFiles() async {
//   try {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['pdf'],
//       allowMultiple: true,
//       dialogTitle: 'اختر ملفات PDF',
//       lockParentWindow: true,
//       withData: true, // Important: Load file data into memory
//     ).timeout(
//       const Duration(seconds: 30),
//       onTimeout: () => null,
//     );

//     if (result == null) {
//       // User cancelled the picker
//       return;
//     }

//     if (result.files.isEmpty) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('لم يتم اختيار أي ملفات'),
//             backgroundColor: Colors.orange,
//           ),
//         );
//       }
//       return;
//     }

//     final validFiles = <File>[];
//     final validNames = <String>[];
//     final errors = <String>[];

//     for (var pickedFile in result.files) {
//       try {
//         // Check if we have bytes (for web/mobile) or path (for desktop)
//         if (pickedFile.bytes == null && (pickedFile.path == null || pickedFile.path!.isEmpty)) {
//           errors.add('${pickedFile.name}: لا يمكن قراءة الملف');
//           continue;
//         }

//         // Create file from bytes or path
//         File file;
//         if (pickedFile.bytes != null) {
//           // For web/mobile - create temp file from bytes
//           final tempDir = Directory.systemTemp;
//           final tempFile = File('${tempDir.path}/${pickedFile.name}');
//           await tempFile.writeAsBytes(pickedFile.bytes!);
//           file = tempFile;
//         } else {
//           // For desktop - use path directly
//           file = File(pickedFile.path!);
          
//           // Verify file exists
//           if (!file.existsSync()) {
//             errors.add('${pickedFile.name}: الملف غير موجود');
//             continue;
//           }
//         }

//         // Verify it's actually a PDF
//         if (!pickedFile.name.toLowerCase().endsWith('.pdf')) {
//           errors.add('${pickedFile.name}: ليس ملف PDF');
//           continue;
//         }

//         // Check file size (10MB limit)
//         final fileSize = await file.length();
//         final maxSize = 10 * 1024 * 1024;
        
//         if (fileSize > maxSize) {
//           final sizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);
//           errors.add('${pickedFile.name}: حجم الملف كبير جداً ($sizeMB MB)');
//           continue;
//         }

//         if (fileSize == 0) {
//           errors.add('${pickedFile.name}: الملف فارغ');
//           continue;
//         }

//         validFiles.add(file);
//         validNames.add(pickedFile.name);
        
//       } catch (e) {
//         errors.add('${pickedFile.name}: خطأ - ${e.toString()}');
//       }
//     }

//     if (validFiles.isNotEmpty) {
//       setState(() {
//         _selectedPdfFiles = validFiles;
//         _selectedPdfNames = validNames;
//       });

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('تم اختيار ${validFiles.length} ملف بنجاح'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     }

//     // Show errors if any
//     if (errors.isNotEmpty && mounted) {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('تحذيرات'),
//           content: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 if (validFiles.isNotEmpty)
//                   Text('تم اختيار ${validFiles.length} ملف بنجاح\n'),
//                 const Text('الملفات التالية بها مشاكل:\n',
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//                 ...errors.map((error) => Padding(
//                       padding: const EdgeInsets.only(bottom: 4),
//                       child: Text('• $error', style: const TextStyle(fontSize: 13)),
//                     )),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('حسناً'),
//             ),
//           ],
//         ),
//       );
//     }

//     if (validFiles.isEmpty && errors.isEmpty) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('لم يتم اختيار ملفات صالحة'),
//             backgroundColor: Colors.orange,
//           ),
//         );
//       }
//     }
    
//   } on PlatformException catch (e) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('خطأ في النظام: ${e.message ?? e.toString()}'),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 4),
//         ),
//       );
//     }
//     print('PlatformException in _pickPdfFiles: $e');
//   } catch (e) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('خطأ في اختيار الملفات: ${e.toString()}'),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 4),
//         ),
//       );
//     }
//     print('Error in _pickPdfFiles: $e');
//   }
// }


//   void _removePdfFile(int index) {
//     setState(() {
//       _selectedPdfFiles.removeAt(index);
//       _selectedPdfNames.removeAt(index);
//     });
//   }

//   Future<void> _removeExistingPdf(String url) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('تأكيد الحذف'),
//         content: const Text('هل أنت متأكد من حذف هذا الملف؟'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('إلغاء'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('حذف'),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       setState(() {
//         _existingPdfUrls.remove(url);
//       });
//     }
//   }

//   Future<void> _createRules() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     try {
//       // Upload PDFs first if any selected
//       List<String> uploadedPdfUrls = [];
//       if (_selectedPdfFiles.isNotEmpty) {
//         for (int i = 0; i < _selectedPdfFiles.length; i++) {
//           try {
//             final file = _selectedPdfFiles[i];
//             final fileName = _selectedPdfNames[i];
            
//             print('Uploading PDF: $fileName');
//             final response = await ApiService.uploadPdfFile(file);
            
//             // Handle different response formats
//             String? url;
//             if (response is Map<String, dynamic>) {
//               url = response['url'] as String?;
//             } else if (response is String) {
//               url = response as String?;
//             }
            
//             if (url == null || url.isEmpty) {
//               throw Exception('لم يتم الحصول على رابط الملف من الخادم');
//             }
            
//             uploadedPdfUrls.add(url);
//             print('Successfully uploaded: $fileName -> $url');
            
//           } catch (e) {
//             print('Error uploading ${_selectedPdfNames[i]}: $e');
//             if (mounted) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('فشل رفع ${_selectedPdfNames[i]}: ${e.toString()}'),
//                   backgroundColor: Colors.orange,
//                 ),
//               );
//             }
//             // Continue with other files
//           }
//         }
        
//         if (uploadedPdfUrls.isEmpty && _selectedPdfFiles.isNotEmpty) {
//           throw Exception('فشل رفع جميع الملفات');
//         }
//       }

//       // Combine uploaded PDFs with existing ones (if any)
//       final allPdfUrls = [..._existingPdfUrls, ...uploadedPdfUrls];
//       final pdfUrlsString = allPdfUrls.isNotEmpty ? allPdfUrls.join(',') : null;

//       await ApiService.createClanRulesWithDetails(
//         clanId: widget.clanId,
//         generalRule: _generalRuleController.text.trim(),
//         groomSupplies: _groomSuppliesController.text.trim().isNotEmpty 
//             ? _groomSuppliesController.text.trim() 
//             : null,
//         ruleAboutClothing: _clothingRuleController.text.trim().isNotEmpty 
//             ? _clothingRuleController.text.trim() 
//             : null,
//         ruleAboutKitchenware: _kitchenwareRuleController.text.trim().isNotEmpty 
//             ? _kitchenwareRuleController.text.trim() 
//             : null,
//         rulesBookOfClanPdfs: pdfUrlsString,
//       );

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('تم إنشاء القوانين بنجاح'),
//             backgroundColor: Colors.green,
//           ),
//         );
        
//         // Clear selected files
//         setState(() {
//           _selectedPdfFiles.clear();
//           _selectedPdfNames.clear();
//         });
        
//         await _loadExistingRules();
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('خطأ: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   Future<void> _updateRules() async {
//     if (!_formKey.currentState!.validate() || _existingRuleId == null) return;

//     setState(() => _isLoading = true);

//     try {
//       // Upload new PDFs if any selected
//       List<String> uploadedPdfUrls = [];
//       if (_selectedPdfFiles.isNotEmpty) {
//         for (int i = 0; i < _selectedPdfFiles.length; i++) {
//           try {
//             final file = _selectedPdfFiles[i];
//             final fileName = _selectedPdfNames[i];
            
//             print('Uploading PDF: $fileName');
//             final response = await ApiService.uploadPdfFile(file);
            
//             // Handle different response formats
//             String? url;
//             if (response is Map<String, dynamic>) {
//               url = response['url'] as String?;
//             } else if (response is String) {
//               url = response as String?;
//             }
            
//             if (url == null || url.isEmpty) {
//               throw Exception('لم يتم الحصول على رابط الملف من الخادم');
//             }
            
//             uploadedPdfUrls.add(url);
//             print('Successfully uploaded: $fileName -> $url');
            
//           } catch (e) {
//             print('Error uploading ${_selectedPdfNames[i]}: $e');
//             if (mounted) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('فشل رفع ${_selectedPdfNames[i]}: ${e.toString()}'),
//                   backgroundColor: Colors.orange,
//                 ),
//               );
//             }
//             // Continue with other files
//           }
//         }
//       }

//       // Combine existing PDFs with newly uploaded ones
//       final allPdfUrls = [..._existingPdfUrls, ...uploadedPdfUrls];
//       final pdfUrlsString = allPdfUrls.isNotEmpty ? allPdfUrls.join(',') : null;

//       await ApiService.updateClanRulesDetails(
//         _existingRuleId!,
//         generalRule: _generalRuleController.text.trim(),
//         groomSupplies: _groomSuppliesController.text.trim().isNotEmpty 
//             ? _groomSuppliesController.text.trim() 
//             : null,
//         ruleAboutClothing: _clothingRuleController.text.trim().isNotEmpty 
//             ? _clothingRuleController.text.trim() 
//             : null,
//         ruleAboutKitchenware: _kitchenwareRuleController.text.trim().isNotEmpty 
//             ? _kitchenwareRuleController.text.trim() 
//             : null,
//         rulesBookOfClanPdfs: pdfUrlsString,
//       );

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('تم تحديث القوانين بنجاح'),
//             backgroundColor: Colors.green,
//           ),
//         );
        
//         // Clear selected files
//         setState(() {
//           _selectedPdfFiles.clear();
//           _selectedPdfNames.clear();
//         });
        
//         await _loadExistingRules();
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('خطأ: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   Future<void> _deleteRules() async {
//     if (_existingRuleId == null) return;

//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('تأكيد الحذف'),
//         content: const Text('هل أنت متأكد من حذف القوانين؟ لا يمكن التراجع عن هذا الإجراء.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('إلغاء'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('حذف'),
//           ),
//         ],
//       ),
//     );

//     if (confirm != true) return;

//     setState(() => _isLoading = true);

//     try {
//       await ApiService.deleteClanRules(_existingRuleId!);

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('تم حذف القوانين بنجاح'),
//             backgroundColor: Colors.orange,
//           ),
//         );
        
//         // Clear form and state
//         _generalRuleController.clear();
//         _groomSuppliesController.clear();
//         _clothingRuleController.clear();
//         _kitchenwareRuleController.clear();
//         setState(() {
//           _hasExistingRules = false;
//           _currentRules = null;
//           _existingRuleId = null;
//           _existingPdfUrls = [];
//           _selectedPdfFiles.clear();
//           _selectedPdfNames.clear();
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('خطأ: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   void _showPdfUploadInfo() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('معلومات رفع ملفات PDF'),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 'كيفية إضافة ملفات PDF:',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8),
//               const Text('• اضغط على زر "اختيار ملفات PDF"'),
//               const Text('• اختر ملف PDF واحد أو عدة ملفات من جهازك'),
//               const Text('• يمكنك مراجعة الملفات المختارة قبل الحفظ'),
//               const Text('• يمكنك حذف أي ملف من القائمة قبل الرفع'),
//               const SizedBox(height: 12),
//               const Text(
//                 'ملاحظات:',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 4),
//               const Text('• يجب أن تكون الملفات بصيغة PDF فقط'),
//               const Text('• سيتم رفع الملفات عند حفظ القوانين'),
//               const Text('• الملفات الموجودة مسبقاً ستبقى محفوظة'),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('فهمت'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     final isDark = themeProvider.isDarkMode;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('إدارة قوانين ${widget.clanName}'),
//         actions: [
//           ThemeToggleButton(),
//           const SizedBox(width: 8),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     // Status Card
//                     Card(
//                       color: _hasExistingRules 
//                           ? (isDark ? Colors.green.shade900 : Colors.green.shade50)
//                           : (isDark ? Colors.orange.shade900 : Colors.orange.shade50),
//                       child: Padding(
//                         padding: const EdgeInsets.all(16),
//                         child: Row(
//                           children: [
//                             Icon(
//                               _hasExistingRules ? Icons.check_circle : Icons.info,
//                               color: _hasExistingRules ? Colors.green : Colors.orange,
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Text(
//                                 _hasExistingRules
//                                     ? 'توجد قوانين حالية لهذه العشيرة'
//                                     : 'لا توجد قوانين حالية - قم بإنشاء قوانين جديدة',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: _hasExistingRules ? Colors.green : Colors.orange,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
                    
//                     const SizedBox(height: 24),

//                     // General Rule Field (Required)
//                     _buildSectionHeader(context, 'القاعدة العامة *'),
//                     const SizedBox(height: 8),
//                     TextFormField(
//                       controller: _generalRuleController,
//                       maxLines: 8,
//                       decoration: InputDecoration(
//                         hintText: 'أدخل القاعدة العامة للعشيرة...\n\nمثال:\n- القواعد الأساسية التي يجب على جميع الأعضاء اتباعها\n- المبادئ العامة للعشيرة',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         filled: true,
//                         fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
//                       ),
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) {
//                           return 'القاعدة العامة مطلوبة';
//                         }
//                         if (value.trim().length < 10) {
//                           return 'القاعدة العامة قصيرة جداً (الحد الأدنى 10 أحرف)';
//                         }
//                         if (value.trim().length > 5000) {
//                           return 'القاعدة العامة طويلة جداً (الحد الأقصى 5000 حرف)';
//                         }
//                         return null;
//                       },
//                     ),
                    
//                     const SizedBox(height: 24),

//                     // Groom Supplies Field (Optional)
//                     _buildSectionHeader(context, 'لوازم العريس (اختياري)'),
//                     const SizedBox(height: 8),
//                     TextFormField(
//                       controller: _groomSuppliesController,
//                       maxLines: 6,
//                       decoration: InputDecoration(
//                         hintText: 'قواعد خاصة بلوازم العريس...\n\nمثال:\n- المتطلبات المادية\n- الهدايا المطلوبة\n- التجهيزات اللازمة',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         filled: true,
//                         fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
//                       ),
//                       validator: (value) {
//                         if (value != null && value.trim().isNotEmpty && value.trim().length > 3000) {
//                           return 'النص طويل جداً (الحد الأقصى 3000 حرف)';
//                         }
//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 24),

//                     // Clothing Rule Field (Optional)
//                     _buildSectionHeader(context, 'قواعد الملابس (اختياري)'),
//                     const SizedBox(height: 8),
//                     TextFormField(
//                       controller: _clothingRuleController,
//                       maxLines: 6,
//                       decoration: InputDecoration(
//                         hintText: 'قواعد خاصة بالملابس والأزياء...\n\nمثال:\n- نوع الملابس المطلوبة\n- الألوان المفضلة\n- الأزياء التقليدية',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         filled: true,
//                         fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
//                       ),
//                       validator: (value) {
//                         if (value != null && value.trim().isNotEmpty && value.trim().length > 3000) {
//                           return 'النص طويل جداً (الحد الأقصى 3000 حرف)';
//                         }
//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 24),

//                     // Kitchenware Rule Field (Optional)
//                     _buildSectionHeader(context, 'قواعد أدوات المطبخ (اختياري)'),
//                     const SizedBox(height: 8),
//                     TextFormField(
//                       controller: _kitchenwareRuleController,
//                       maxLines: 6,
//                       decoration: InputDecoration(
//                         hintText: 'قواعد خاصة بأدوات المطبخ والمنزل...\n\nمثال:\n- أدوات المطبخ المطلوبة\n- الأجهزة المنزلية\n- التجهيزات المنزلية',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         filled: true,
//                         fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
//                       ),
//                       validator: (value) {
//                         if (value != null && value.trim().isNotEmpty && value.trim().length > 3000) {
//                           return 'النص طويل جداً (الحد الأقصى 3000 حرف)';
//                         }
//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 24),

//                     // PDF Upload Section
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _buildSectionHeader(context, 'كتاب قوانين العشيرة - ملفات PDF (اختياري)'),
//                         ),
//                         IconButton(
//                           onPressed: _showPdfUploadInfo,
//                           icon: const Icon(Icons.help_outline),
//                           tooltip: 'مساعدة',
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),

//                     // Existing PDFs (if any)
//                     if (_existingPdfUrls.isNotEmpty) ...[
//                       Card(
//                         color: isDark ? Colors.blue.shade900.withOpacity(0.3) : Colors.blue.shade50,
//                         child: Padding(
//                           padding: const EdgeInsets.all(12),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Icon(Icons.cloud_done, color: Colors.blue, size: 20),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     'ملفات PDF المحفوظة (${_existingPdfUrls.length})',
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.blue.shade700,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const Divider(height: 16),
//                               ..._existingPdfUrls.asMap().entries.map((entry) {
//                                 final index = entry.key;
//                                 final url = entry.value;
//                                 final fileName = url.split('/').last;
//                                 return Padding(
//                                   padding: const EdgeInsets.only(bottom: 8),
//                                   child: Row(
//                                     children: [
//                                       const Icon(Icons.picture_as_pdf, size: 20, color: Colors.red),
//                                       const SizedBox(width: 8),
//                                       Expanded(
//                                         child: Text(
//                                           fileName,
//                                           style: const TextStyle(fontSize: 14),
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                       IconButton(
//                                         icon: const Icon(Icons.delete, size: 20, color: Colors.red),
//                                         onPressed: () => _removeExistingPdf(url),
//                                         tooltip: 'حذف',
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               }).toList(),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                     ],

//                     // PDF Upload Button
//                     OutlinedButton.icon(
//                       onPressed: _pickPdfFiles,
//                       icon: const Icon(Icons.upload_file),
//                       label: const Text('اختيار ملفات PDF'),
//                       style: OutlinedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                     ),

//                     // Selected PDFs Preview
//                     if (_selectedPdfNames.isNotEmpty) ...[
//                       const SizedBox(height: 12),
//                       Card(
//                         color: isDark ? Colors.green.shade900.withOpacity(0.3) : Colors.green.shade50,
//                         child: Padding(
//                           padding: const EdgeInsets.all(12),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Icon(Icons.new_releases, color: Colors.green, size: 20),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     'ملفات جديدة محددة (${_selectedPdfNames.length})',
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.green.shade700,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const Divider(height: 16),
//                               ..._selectedPdfNames.asMap().entries.map((entry) {
//                                 final index = entry.key;
//                                 final name = entry.value;
//                                 return Padding(
//                                   padding: const EdgeInsets.only(bottom: 8),
//                                   child: Row(
//                                     children: [
//                                       const Icon(Icons.insert_drive_file, size: 20, color: Colors.green),
//                                       const SizedBox(width: 8),
//                                       Expanded(
//                                         child: Text(
//                                           name,
//                                           style: const TextStyle(fontSize: 14),
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                       IconButton(
//                                         icon: const Icon(Icons.close, size: 20, color: Colors.red),
//                                         onPressed: () => _removePdfFile(index),
//                                         tooltip: 'إزالة',
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               }).toList(),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],

//                     const SizedBox(height: 32),

//                     // Action Buttons
//                     if (_hasExistingRules) ...[
//                       // Update Button
//                       ElevatedButton(
//                         onPressed: _isLoading ? null : _updateRules,
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: _isLoading
//                             ? const SizedBox(
//                                 height: 20,
//                                 width: 20,
//                                 child: CircularProgressIndicator(strokeWidth: 2),
//                               )
//                             : const Text(
//                                 'تحديث القوانين',
//                                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                               ),
//                       ),
                      
//                       const SizedBox(height: 12),
                      
//                       // Delete Button
//                       OutlinedButton(
//                         onPressed: _isLoading ? null : _deleteRules,
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: Colors.red,
//                           side: const BorderSide(color: Colors.red),
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: const Text(
//                           'حذف القوانين',
//                           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                     ] else ...[
//                       // Create Button
//                       ElevatedButton(
//                         onPressed: _isLoading ? null : _createRules,
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: _isLoading
//                             ? const SizedBox(
//                                 height: 20,
//                                 width: 20,
//                                 child: CircularProgressIndicator(strokeWidth: 2),
//                               )
//                             : const Text(
//                                 'إنشاء القوانين',
//                                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                               ),
//                       ),
//                     ],

//                     const SizedBox(height: 16),

//                     // Preview Card
//                     if (_currentRules != null) ...[
//                       const Divider(height: 32),
                      
//                       Text(
//                         'معاينة القوانين الحالية',
//                         style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
                      
//                       const SizedBox(height: 12),
                      
//                       Card(
//                         color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
//                         child: Padding(
//                           padding: const EdgeInsets.all(16),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // General Rule
//                               _buildPreviewSection(
//                                 context,
//                                 'القاعدة العامة',
//                                 _currentRules!['general_rule'],
//                               ),
                              
//                               // Groom Supplies
//                               if (_currentRules!['groom_supplies'] != null &&
//                                   _currentRules!['groom_supplies'].toString().isNotEmpty)
//                                 _buildPreviewSection(
//                                   context,
//                                   'لوازم العريس',
//                                   _currentRules!['groom_supplies'],
//                                 ),
                              
//                               // Clothing Rule
//                               if (_currentRules!['rule_about_clothing'] != null &&
//                                   _currentRules!['rule_about_clothing'].toString().isNotEmpty)
//                                 _buildPreviewSection(
//                                   context,
//                                   'قواعد الملابس',
//                                   _currentRules!['rule_about_clothing'],
//                                 ),
                              
//                               // Kitchenware Rule
//                               if (_currentRules!['rule_about_kitchenware'] != null &&
//                                   _currentRules!['rule_about_kitchenware'].toString().isNotEmpty)
//                                 _buildPreviewSection(
//                                   context,
//                                   'قواعد أدوات المطبخ',
//                                   _currentRules!['rule_about_kitchenware'],
//                                 ),
                              
//                               // PDF URLs
//                               if (_existingPdfUrls.isNotEmpty) ...[
//                                 const SizedBox(height: 12),
//                                 Text(
//                                   'كتاب قوانين العشيرة (PDFs)',
//                                   style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                                     fontWeight: FontWeight.bold,
//                                     color: Theme.of(context).primaryColor,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 ..._existingPdfUrls.asMap().entries.map((entry) {
//                                   final index = entry.key;
//                                   final url = entry.value;
//                                   final fileName = url.split('/').last;
//                                   return Padding(
//                                     padding: const EdgeInsets.only(bottom: 8),
//                                     child: Row(
//                                       children: [
//                                         const Icon(Icons.picture_as_pdf, size: 20, color: Colors.red),
//                                         const SizedBox(width: 8),
//                                         Expanded(
//                                           child: InkWell(
//                                             onTap: () {
//                                               // TODO: Open PDF URL in browser or PDF viewer
//                                               ScaffoldMessenger.of(context).showSnackBar(
//                                                 SnackBar(content: Text('فتح: $fileName')),
//                                               );
//                                             },
//                                             child: Text(
//                                               'ملف PDF ${index + 1}: $fileName',
//                                               style: const TextStyle(
//                                                 fontSize: 14,
//                                                 color: Colors.blue,
//                                                 decoration: TextDecoration.underline,
//                                               ),
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 }).toList(),
//                                 const SizedBox(height: 12),
//                               ],
                              
//                               const Divider(height: 24),
                              
//                               // Timestamps
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   if (_currentRules!['created_at'] != null)
//                                     Text(
//                                       'تاريخ الإنشاء: ${_formatDate(_currentRules!['created_at'])}',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.grey.shade600,
//                                       ),
//                                     ),
//                                   if (_currentRules!['updated_at'] != null)
//                                     Text(
//                                       'آخر تحديث: ${_formatDate(_currentRules!['updated_at'])}',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.grey.shade600,
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }

//   Widget _buildSectionHeader(BuildContext context, String title) {
//     return Text(
//       title,
//       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//         fontWeight: FontWeight.bold,
//       ),
//     );
//   }

//   Widget _buildPreviewSection(BuildContext context, String title, String? content) {
//     if (content == null || content.isEmpty) return const SizedBox.shrink();
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 12),
//         Text(
//           title,
//           style: Theme.of(context).textTheme.titleSmall?.copyWith(
//             fontWeight: FontWeight.bold,
//             color: Theme.of(context).primaryColor,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           content,
//           style: const TextStyle(fontSize: 14, height: 1.5),
//         ),
//         const SizedBox(height: 12),
//       ],
//     );
//   }

//   String _formatDate(String? dateStr) {
//     if (dateStr == null) return 'غير محدد';
//     try {
//       final date = DateTime.parse(dateStr);
//       return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
//     } catch (e) {
//       return dateStr;
//     }
//   }
// }