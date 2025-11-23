import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../providers/theme_provider.dart';
import '../../services/api_service.dart';
import '../../utils/colors.dart';
import '../../widgets/theme_toggle_button.dart';

class ClanRulesPage extends StatefulWidget {
  const ClanRulesPage({Key? key}) : super(key: key);

  @override
  State<ClanRulesPage> createState() => ClanRulesPageState();
}

class ClanRulesPageState extends State<ClanRulesPage> {
  Map<String, dynamic>? _rules;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isDownloadingPdf = false;
  double _downloadProgress = 0.0;
  int? _clanId;
  
  final _formKey = GlobalKey<FormState>();
  final _generalRuleController = TextEditingController();
  final _groomSuppliesController = TextEditingController();
  final _clothingController = TextEditingController();
  final _kitchenwareController = TextEditingController();
  String? _pdfUrl;
  File? _pendingPdfFile;
  String? _pendingPdfFileName;
  
  @override
  void initState() {
    super.initState();
    _checkConnectivityAndLoad();
  }
  
  void refreshData() {
    _checkConnectivityAndLoad();
    setState(() {});
  }
Future<void> _checkConnectivityAndLoad() async {
    setState(() {
    _isLoading = true;
  });
  
  // Show loading for 2 seconds
  await Future.delayed(Duration(seconds: 2));
  
  final connectivityResult = await Connectivity().checkConnectivity();
  
  if (connectivityResult.contains(ConnectivityResult.none)) {
    _showNoInternetDialog();
    setState(() {
      _isLoading = false;
    });
    return;
  }
  
  await _loadData();
}

void _showNoInternetDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.orange),
          SizedBox(width: 10),
          Text('لا يوجد اتصال'),
        ],
      ),
      content: Text('يرجى التحقق من اتصالك بالإنترنت'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _checkConnectivityAndLoad();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text('إعادة المحاولة', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final clanInfo = await ApiService.getClanInfoByCurrentUser();
      _clanId = clanInfo['id'];
      
      try {
        final rules = await ApiService.getClanRulesByClanId(_clanId!);
        _populateFields(rules);
      } catch (e) {
        _rules = null;
      }
    } catch (e) {
      _showError('فشل تحميل البيانات: ${_cleanError(e)}');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void _populateFields(Map<String, dynamic> rules) {
    setState(() {
      _rules = rules;
      _generalRuleController.text = rules['general_rule'] ?? '';
      _groomSuppliesController.text = rules['groom_supplies'] ?? '';
      _clothingController.text = rules['rule_about_clothing'] ?? '';
      _kitchenwareController.text = rules['rule_about_kitchenware'] ?? '';
      
      _pdfUrl = rules['rules_book_of_clan_pdf']?.toString().isEmpty ?? true 
          ? null 
          : rules['rules_book_of_clan_pdf'];
    });
  }
  Future<void> _save() async {
  if (!_formKey.currentState!.validate()) return;
  if (_clanId == null) {
    _showError('معرف العشيرة غير موجود');
    return;
  }
  
  setState(() => _isLoading = true);
  try {
    Map<String, dynamic> result;
    
    // Step 1: Handle PDF upload first if there's a pending file
    String? uploadedPdfPath;
    if (_pendingPdfFile != null) {
      print('📤 Uploading PDF file first...');
      final uploadResult = await ApiService.uploadPdfFile(
        _pendingPdfFile!,
        clanId: _clanId!,
      );
      uploadedPdfPath = uploadResult['path']; // Use PATH, not URL
      print('✅ PDF uploaded, path: $uploadedPdfPath');
    }
    
    // Step 2: Create or update clan rules with PDF path
    if (_rules == null) {
      print('🔵 Creating clan rules...');
      result = await ApiService.createClanRulesWithDetails(
        clanId: _clanId!,
        generalRule: _generalRuleController.text.trim(),
        groomSupplies: _groomSuppliesController.text.trim().isEmpty ? null : _groomSuppliesController.text.trim(),
        ruleAboutClothing: _clothingController.text.trim().isEmpty ? null : _clothingController.text.trim(),
        ruleAboutKitchenware: _kitchenwareController.text.trim().isEmpty ? null : _kitchenwareController.text.trim(),
        rulesBookOfClanPdfs: uploadedPdfPath ?? _pdfUrl, // Use new path or existing
      );
    } else {
      print('🔵 Updating clan rules...');
      result = await ApiService.updateClanRulesDetails(
        _rules!['id'],
        generalRule: _generalRuleController.text.trim(),
        groomSupplies: _groomSuppliesController.text.trim().isEmpty ? null : _groomSuppliesController.text.trim(),
        ruleAboutClothing: _clothingController.text.trim().isEmpty ? null : _clothingController.text.trim(),
        ruleAboutKitchenware: _kitchenwareController.text.trim().isEmpty ? null : _kitchenwareController.text.trim(),
        rulesBookOfClanPdfs: uploadedPdfPath ?? _pdfUrl, // Use new path or existing
      );
    }
    
    // Clear pending file
    _pendingPdfFile = null;
    _pendingPdfFileName = null;
    
    _populateFields(result);
    setState(() => _isEditing = false);
    _showSuccess(_rules == null ? 'تم الإنشاء بنجاح' : 'تم التحديث بنجاح');
  } catch (e) {
    print('❌ Save error: $e');
    _showError('فشل الحفظ: ${_cleanError(e)}');
  } finally {
    setState(() => _isLoading = false);
  }
}
  
  Future<void> _delete() async {
    if (_rules == null) return;
    
    final confirm = await _showConfirmDialog('هل تريد حذف هذه القوانين نهائياً؟');
    if (!confirm) return;
    
    setState(() => _isLoading = true);
    try {
      await ApiService.deleteClanRules(_rules!['id']);
      _clearFields();
      setState(() => _isLoading = false);
      _showSuccess('تم الحذف بنجاح');
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('فشل الحذف: ${_cleanError(e)}');
    }
  }
  
  Future<void> _pickPdf() async {
    if (_clanId == null) {
      _showError('معرف العشيرة غير موجود');
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      
      if (result == null || result.files.single.path == null) return;
      
      final file = File(result.files.single.path!);
      
      setState(() {
        _pendingPdfFile = file;
        _pendingPdfFileName = result.files.single.name;
      });
      
      _showSuccess('تم اختيار الملف. سيتم رفعه عند الحفظ');
    } catch (e) {
      print('❌ File picker error: $e');
      _showError('فشل اختيار الملف: ${_cleanError(e)}');
    }
  }
  
  Future<void> _deletePdf() async {
  if (_pendingPdfFile != null) {
    setState(() {
      _pendingPdfFile = null;
      _pendingPdfFileName = null;
    });
    _showSuccess('تم إلغاء اختيار الملف');
    return;
  }
  
  if (_pdfUrl == null || _clanId == null) return;

  final confirm = await _showConfirmDialog('هل تريد حذف هذا الملف؟');
  if (!confirm) return;
  
  setState(() => _isLoading = true);
  try {
    // Extract filename from the stored path or URL
    final filename = _pdfUrl!.split('/').last;
    
    print('🗑️ Deleting PDF: $filename for clan: $_clanId');
    
    await ApiService.deletePdfByFilename(filename, clanId: _clanId!);
    
    setState(() {
      _pdfUrl = null;
      _isLoading = false;
    });
    _showSuccess('تم حذف الملف بنجاح');
  } catch (e) {
    print('❌ Delete PDF error: $e');
    setState(() => _isLoading = false);
    _showError('فشل حذف الملف: ${_cleanError(e)}');
  }
}
  
  Future<List<int>?> _downloadPdfUniversal(String pathOrUrl) async {
  print('🔵 Starting universal PDF download from: $pathOrUrl');
  
  // Determine if it's a path or full URL
  String filename;
  if (pathOrUrl.startsWith('http')) {
    // It's a full URL, extract filename
    filename = pathOrUrl.split('/').last;
    print('📄 Extracted filename from URL: $filename');
  } else if (pathOrUrl.contains('/')) {
    // It's a path like "uploads/pdfs/abc-123.pdf"
    filename = pathOrUrl.split('/').last;
    print('📄 Extracted filename from path: $filename');
  } else {
    // It's already just a filename
    filename = pathOrUrl;
    print('📄 Using filename directly: $filename');
  }
  
  // Method 1: Try ApiService.downloadPdfByFilename (NEW METHOD)
  try {
    print('📥 Method 1: Using ApiService.downloadPdfByFilename');
    final bytes = await ApiService.downloadPdfByFilename(filename);
    if (bytes.isNotEmpty) {
      print('✅ Method 1 succeeded: ${bytes.length} bytes');
      return bytes;
    }
  } catch (e) {
    print('⚠️ Method 1 failed: $e');
  }
  
  // Method 2: Try building full URL and using downloadPdfFromUrl
  try {
    print('📥 Method 2: Building URL and using downloadPdfFromUrl');
    final url = '${ApiService.baseUrl}/pdf/api/files/$filename';
    print('🔗 Built URL: $url');
    final bytes = await ApiService.downloadPdfFromUrl(url);
    if (bytes.isNotEmpty) {
      print('✅ Method 2 succeeded: ${bytes.length} bytes');
      return bytes;
    }
  } catch (e) {
    print('⚠️ Method 2 failed: $e');
  }
  
  // Method 3: Direct HTTP GET request
  try {
    print('📥 Method 3: Direct HTTP GET request');
    final token = ApiService.getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    
    final url = '${ApiService.baseUrl}/pdf/api/files/$filename';
    print('🔗 Direct GET URL: $url');
    
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );
    
    print('📊 HTTP Response status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      print('✅ Method 3 succeeded: ${response.bodyBytes.length} bytes');
      return response.bodyBytes;
    } else {
      print('❌ Method 3 failed with status: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('⚠️ Method 3 failed: $e');
  }
  
  print('❌ All download methods failed');
  return null;
}
  
  /// View/Open PDF (Quick preview)
  Future<void> _viewPdf(String pathOrUrl) async {
  setState(() {
    _isDownloadingPdf = true;
    _downloadProgress = 0.0;
  });
  
  try {
    print('🔵 Viewing PDF from: $pathOrUrl');
    
    final pdfBytes = await _downloadPdfUniversal(pathOrUrl);
    
    if (pdfBytes == null || pdfBytes.isEmpty) {
      throw Exception('فشل تحميل الملف من الخادم');
    }
    
    setState(() => _downloadProgress = 0.5);
    
    print('✅ PDF downloaded, size: ${pdfBytes.length} bytes');
    
    // Save to temporary directory
    final tempDir = await getTemporaryDirectory();
    final fileName = _generateFileName(pathOrUrl);
    final tempFile = File('${tempDir.path}/$fileName');
    
    await tempFile.writeAsBytes(pdfBytes);
    
    setState(() => _downloadProgress = 1.0);
    
    print('✅ PDF saved to temp: ${tempFile.path}');
    
    setState(() => _isDownloadingPdf = false);
    
    // Open the file
    final result = await OpenFile.open(tempFile.path);
    
    if (result.type != ResultType.done) {
      _showError('لا يمكن فتح الملف: ${result.message}');
    }
    
  } catch (e) {
    print('❌ View PDF error: $e');
    setState(() => _isDownloadingPdf = false);
    _showError('فشل فتح الملف: ${_cleanError(e)}');
  }
}
  
  /// Download PDF to device storage (Permanent save)
  Future<void> _downloadPdfToDevice(String pathOrUrl) async {
  // Request permissions for Android
  if (Platform.isAndroid) {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (!status.isGranted) {
        status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          _showError('يجب منح صلاحية الوصول للتخزين');
          return;
        }
      }
    }
  }

  setState(() {
    _isDownloadingPdf = true;
    _downloadProgress = 0.0;
  });

  try {
    print('🔵 Downloading PDF to device from: $pathOrUrl');
    _showSuccess('جاري التحميل...');
    
    final pdfBytes = await _downloadPdfUniversal(pathOrUrl);
    
    if (pdfBytes == null || pdfBytes.isEmpty) {
      throw Exception('فشل تحميل الملف من الخادم');
    }
    
    setState(() => _downloadProgress = 0.6);
    
    print('✅ PDF downloaded, size: ${pdfBytes.length} bytes');

    final savedFile = await _savePdfToDevice(pdfBytes, pathOrUrl);
    
    setState(() {
      _downloadProgress = 1.0;
      _isDownloadingPdf = false;
    });

    if (savedFile != null) {
      print('✅ PDF saved to: ${savedFile.path}');
      _showDownloadSuccessDialog(savedFile.path, pdfBytes);
    } else {
      throw Exception('فشل حفظ الملف في الجهاز');
    }
  } catch (e) {
    print('❌ Download error: $e');
    setState(() => _isDownloadingPdf = false);
    _showError('خطأ في التحميل: ${_cleanError(e)}');
  }
}

  /// Save PDF to device storage
  Future<File?> _savePdfToDevice(List<int> pdfBytes, String url) async {
    try {
      Directory? directory;
      
      if (Platform.isAndroid) {
        // Try Downloads folder first
        try {
          final downloadsPath = '/storage/emulated/0/Download';
          directory = Directory(downloadsPath);
          
          if (!await directory.exists()) {
            directory = await getExternalStorageDirectory();
            if (directory != null) {
              final publicPath = Directory('${directory.path}/Download');
              await publicPath.create(recursive: true);
              directory = publicPath;
            }
          }
        } catch (e) {
          print('⚠️ Could not access Downloads, using app directory');
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isWindows) {
        // Windows - use Downloads folder
        final userProfile = Platform.environment['USERPROFILE'];
        if (userProfile != null) {
          directory = Directory('$userProfile\\Downloads');
          if (!await directory.exists()) {
            directory = await getApplicationDocumentsDirectory();
          }
        } else {
          directory = await getApplicationDocumentsDirectory();
        }
      } else if (Platform.isLinux || Platform.isMacOS) {
        // Linux/Mac - try Downloads folder
        final home = Platform.environment['HOME'];
        if (home != null) {
          directory = Directory('$home/Downloads');
          if (!await directory.exists()) {
            directory = await getApplicationDocumentsDirectory();
          }
        } else {
          directory = await getApplicationDocumentsDirectory();
        }
      } else {
        // iOS or other
        directory = await getApplicationDocumentsDirectory();
      }
      
      if (directory == null) {
        throw Exception('لا يمكن الوصول إلى مجلد التخزين');
      }
      
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      
      final fileName = _generateFileName(url);
      final file = File('${directory.path}${Platform.pathSeparator}$fileName');

      await file.writeAsBytes(pdfBytes);
      
      print('✅ File saved to: ${file.path}');
      return file;
    } catch (e) {
      print('❌ Error saving file: $e');
      return null;
    }
  }

  /// Generate a proper filename
  String _generateFileName(String pathOrUrl) {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final clanName = _rules?['clan_name'] ?? 'العشيرة';
  
  // Try to preserve original filename if it exists in the path
  String originalName = 'قوانين';
  try {
    if (pathOrUrl.contains('/')) {
      final parts = pathOrUrl.split('/');
      if (parts.isNotEmpty) {
        final lastPart = parts.last;
        if (lastPart.contains('.pdf')) {
          // Keep the UUID part for uniqueness
          originalName = lastPart.replaceAll('.pdf', '');
        }
      }
    }
  } catch (e) {
    print('⚠️ Could not extract original filename: $e');
  }
  
  return 'قوانين_${clanName.replaceAll(' ', '_')}_$timestamp.pdf';
}

  /// Share PDF
  Future<void> _sharePdf(List<int> pdfBytes, String url) async {
    try {
      final fileName = _generateFileName(url);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');
      
      await tempFile.writeAsBytes(pdfBytes);
      
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: 'كتاب قوانين العشيرة',
        subject: 'قوانين العشيرة',
      );
      
      _showSuccess('تم فتح خيارات المشاركة');
    } catch (e) {
      print('❌ Share error: $e');
      _showError('خطأ في مشاركة الملف: ${_cleanError(e)}');
    }
  }

  /// Show success dialog after download
  void _showDownloadSuccessDialog(String filePath, List<int> pdfBytes) {
    if (!mounted) return;
    
    final isDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('تم التحميل بنجاح'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تم حفظ الملف في:'),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: SelectableText(
                filePath,
                style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.folder, color: Colors.blue, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isDesktop 
                        ? 'الملف محفوظ في مجلد التحميلات'
                        : 'الملف محفوظ في جهازك',
                    style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق'),
          ),
          if (!isDesktop)
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                await _sharePdf(pdfBytes, _pdfUrl!);
              },
              icon: Icon(Icons.share, size: 18),
              label: Text('مشاركة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final result = await OpenFile.open(filePath);
                if (result.type != ResultType.done) {
                  _showError('لا يمكن فتح الملف تلقائياً');
                }
              } catch (e) {
                _showError('خطأ في فتح الملف');
              }
            },
            icon: Icon(Icons.open_in_new, size: 18),
            label: Text('فتح الملف'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  void _clearFields() {
    setState(() {
      _rules = null;
      _isEditing = false;
      _generalRuleController.clear();
      _groomSuppliesController.clear();
      _clothingController.clear();
      _kitchenwareController.clear();
      _pdfUrl = null;
      _pendingPdfFile = null;
      _pendingPdfFileName = null;
    });
  }
  
  String _cleanError(dynamic error) {
    return error.toString()
        .replaceAll('Exception: ', '')
        .replaceAll('خطأ في ', '')
        .replaceAll('Failed to download PDF: ', '');
  }
  
  Future<bool> _showConfirmDialog(String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
  
  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }
  
  void _showSuccess(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('قوانين العشيرة'),
        actions: [
          const ThemeToggleButton(),
          if (_rules != null && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_rules != null && !_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _delete,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_rules == null || _isEditing) ...[
                      _buildTextField(
                        controller: _generalRuleController,
                        label: 'قواعد عامة *',
                        required: true,
                        maxLines: 5,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _groomSuppliesController,
                        label: 'ملابس ولوازم العريس',
                        maxLines: 3,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      // _buildTextField(
                      //   controller: _clothingController,
                      //   label: 'قواعد الملابس',
                      //   maxLines: 3,
                      //   isDark: isDark,
                      // ),
                      // const SizedBox(height: 16),
                      _buildTextField(
                        controller: _kitchenwareController,
                        label: 'لوازم المطبخ',
                        maxLines: 3,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildPdfSection(isDark, isEditing: true),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text(_rules == null ? 'إنشاء' : 'حفظ'),
                            ),
                          ),
                          if (_isEditing) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  if (_rules != null) _populateFields(_rules!);
                                  setState(() => _isEditing = false);
                                },
                                child: const Text('إلغاء'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ] 
                    else if (_rules != null && !_isEditing)
                      _buildViewMode(isDark),

                      const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required bool isDark,
  bool required = false,
  int maxLines = 1,
}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      alignLabelWithHint: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      filled: true,
      fillColor: isDark ? AppColors.darkInputBackground : AppColors.surface,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    ),
    maxLines: null,
    minLines: maxLines > 1 ? 5 : 1,
    keyboardType: TextInputType.multiline,
    textAlignVertical: TextAlignVertical.top,
    style: TextStyle(fontSize: 16, height: 1.5),
    expands: false,
    validator: null, // No validation - all fields optional
  );
}


  Widget _buildPdfSection(bool isDark, {bool isEditing = false}) {
    final hasPdf = _pdfUrl != null || _pendingPdfFile != null;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.picture_as_pdf, color: AppColors.error),
                const SizedBox(width: 8),
                const Text('كتاب القوانين (PDF)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                if (isEditing && !hasPdf)
                  ElevatedButton.icon(
                    onPressed: _pickPdf,
                    icon: const Icon(Icons.upload_file, size: 20),
                    label: const Text('رفع ملف'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (!hasPdf)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.insert_drive_file, size: 48, color: Colors.grey),
                      const SizedBox(height: 8),
                      const Text('لا يوجد ملف', style: TextStyle(color: Colors.grey)),
                      if (isEditing) ...[
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _pickPdf,
                          icon: const Icon(Icons.upload_file),
                          label: const Text('رفع ملف PDF'),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            else
              Card(
                margin: const EdgeInsets.only(top: 8),
                elevation: 2,
                color: _pendingPdfFile != null ? Colors.orange.withOpacity(0.1) : null,
                child: ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: AppColors.error, size: 32),
                  title: Text(
                    _pendingPdfFile != null 
                        ? _pendingPdfFileName ?? 'ملف محدد'
                        : _getFileName(_pdfUrl!), 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis
                  ),
                  subtitle: Text(
                    _pendingPdfFile != null 
                        ? 'سيتم رفع الملف عند الحفظ'
                        : 'كتاب قوانين العشيرة'
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_pdfUrl != null) ...[
                        _isDownloadingPdf
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // IconButton(
                                //   icon: const Icon(Icons.visibility, color: AppColors.primary),
                                //   onPressed: () => _downloadAndOpenPdf(_pdfUrl!),
                                //   tooltip: 'عرض الملف',
                                // ),
                                IconButton(
                                  icon: const Icon(Icons.download, color: Colors.green),
                                  onPressed: () => _downloadPdfToDevice(_pdfUrl!),
                                  tooltip: 'تحميل للجهاز',
                                ),
                              ],
                            ),
                      ],
                      if (isEditing)
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.error),
                          onPressed: _deletePdf,
                          tooltip: _pendingPdfFile != null ? 'إلغاء الاختيار' : 'حذف الملف',
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
  
  String _getFileName(String url) {
    try {
      return url.split('/').last.replaceAll(RegExp(r'[a-f0-9-]{36}'), 'rules');
    } catch (e) {
      return 'كتاب_القوانين.pdf';
    }
  }
  
  Widget _buildViewMode(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard('قواعد عامة', _rules!['general_rule'], Icons.rule),
        if (_rules!['groom_supplies']?.toString().isNotEmpty ?? false)
          _buildInfoCard('ملابس ولوازم العريس', _rules!['groom_supplies'], Icons.shopping_bag),
        if (_rules!['rule_about_clothing']?.toString().isNotEmpty ?? false)
          _buildInfoCard('قواعد الملابس', _rules!['rule_about_clothing'], Icons.checkroom),
        if (_rules!['rule_about_kitchenware']?.toString().isNotEmpty ?? false)
          _buildInfoCard('لوازم المطبخ', _rules!['rule_about_kitchenware'], Icons.kitchen),
        if (_pdfUrl != null) _buildPdfSection(isDark, isEditing: false),
      ],
    );
  }
  
  Widget _buildInfoCard(String title, String? content, IconData icon) {
    if (content == null || content.trim().isEmpty) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 16),
            Text(content),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _generalRuleController.dispose();
    _groomSuppliesController.dispose();
    _clothingController.dispose();
    _kitchenwareController.dispose();
    super.dispose();
  }
}