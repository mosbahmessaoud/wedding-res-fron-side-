import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/colors.dart';
import '../../services/api_service.dart';
import '../../widgets/theme_toggle_button.dart';
import '../../providers/theme_provider.dart';

class ClanRulesPage extends StatefulWidget {
  const ClanRulesPage({Key? key}) : super(key: key);

  @override
  State<ClanRulesPage> createState() => ClanRulesPageState();
}

class ClanRulesPageState extends State<ClanRulesPage> {
  Map<String, dynamic>? _rules;
  bool _isLoading = true;
  bool _isEditing = false;
  int? _clanId;
  
  final _formKey = GlobalKey<FormState>();
  final _generalRuleController = TextEditingController();
  final _groomSuppliesController = TextEditingController();
  final _clothingController = TextEditingController();
  final _kitchenwareController = TextEditingController();
  String? _pdfUrl; // Changed from List to single URL
  File? _pendingPdfFile; // Store the file temporarily until save
  String? _pendingPdfFileName; // Store filename for display
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  void refreshData() {
    _loadData();
    setState(() {});
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
      
      // Get single PDF URL
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
      
      // Step 1: Create/Update clan rules WITHOUT PDF first
      if (_rules == null) {
        print('🔵 Step 1: Creating clan rules...');
        result = await ApiService.createClanRulesWithDetails(
          clanId: _clanId!,
          generalRule: _generalRuleController.text.trim(),
          groomSupplies: _groomSuppliesController.text.trim().isEmpty ? null : _groomSuppliesController.text.trim(),
          ruleAboutClothing: _clothingController.text.trim().isEmpty ? null : _clothingController.text.trim(),
          ruleAboutKitchenware: _kitchenwareController.text.trim().isEmpty ? null : _kitchenwareController.text.trim(),
          rulesBookOfClanPdfs: _pdfUrl, // Keep existing PDF if any
        );
        print('✅ Clan rules created successfully');
      } else {
        print('🔵 Step 1: Updating clan rules...');
        result = await ApiService.updateClanRulesDetails(
          _rules!['id'],
          generalRule: _generalRuleController.text.trim(),
          groomSupplies: _groomSuppliesController.text.trim().isEmpty ? null : _groomSuppliesController.text.trim(),
          ruleAboutClothing: _clothingController.text.trim().isEmpty ? null : _clothingController.text.trim(),
          ruleAboutKitchenware: _kitchenwareController.text.trim().isEmpty ? null : _kitchenwareController.text.trim(),
          rulesBookOfClanPdfs: _pdfUrl, // Keep existing PDF if any
        );
        print('✅ Clan rules updated successfully');
      }
      
      // Step 2: Upload PDF AFTER clan rules are created (if there's a pending file)
      if (_pendingPdfFile != null) {
        print('🔵 Step 2: Uploading PDF file...');
        final uploadResult = await ApiService.uploadPdfFile(
          _pendingPdfFile!,
          clanId: _clanId!,
        );
        final uploadedPdfUrl = uploadResult['url'];
        print('✅ PDF uploaded: $uploadedPdfUrl');
        
        // Step 3: Update the clan rules with the new PDF URL
        print('🔵 Step 3: Updating clan rules with PDF URL...');
        result = await ApiService.updateClanRulesDetails(
          result['id'],
          generalRule: _generalRuleController.text.trim(),
          groomSupplies: _groomSuppliesController.text.trim().isEmpty ? null : _groomSuppliesController.text.trim(),
          ruleAboutClothing: _clothingController.text.trim().isEmpty ? null : _clothingController.text.trim(),
          ruleAboutKitchenware: _kitchenwareController.text.trim().isEmpty ? null : _kitchenwareController.text.trim(),
          rulesBookOfClanPdfs: uploadedPdfUrl,
        );
        print('✅ Clan rules updated with PDF URL');
      }
      
      // Clear pending file after successful save
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
      
      // Store the file temporarily, don't upload yet
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
    // If it's a pending file (not yet uploaded), just clear it
    if (_pendingPdfFile != null) {
      setState(() {
        _pendingPdfFile = null;
        _pendingPdfFileName = null;
      });
      _showSuccess('تم إلغاء اختيار الملف');
      return;
    }
    
    // If it's an uploaded file, delete from server
    if (_pdfUrl == null || _clanId == null) return;

    final confirm = await _showConfirmDialog('هل تريد حذف هذا الملف؟');
    if (!confirm) return;
    
    setState(() => _isLoading = true);
    try {
      await ApiService.deletePdfByUrl(_pdfUrl!, clanId: _clanId!);
      setState(() {
        _pdfUrl = null;
        _isLoading = false;
      });
      _showSuccess('تم حذف الملف بنجاح');
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('فشل حذف الملف: ${_cleanError(e)}');
    }
  }
  
  Future<void> _openPdf(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showError('لا يمكن فتح الملف');
      }
    } catch (e) {
      _showError('خطأ في فتح الملف');
    }
  }

  Future<void> _loadClanPdf() async {
    if (_clanId == null) return;
    
    try {
      final result = await ApiService.getClanRulesPdf(_clanId!);
      setState(() => _pdfUrl = result['pdf_url']);
    } catch (e) {
      // No PDF found, that's okay
      setState(() => _pdfUrl = null);
    }
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
    return error.toString().replaceAll('Exception: ', '').replaceAll('خطأ في ', '');
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
  
  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: AppColors.error),
  );
  
  void _showSuccess(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: AppColors.success),
  );
  
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
                    // Show edit/create mode when: rules is null OR editing is true
                    if (_rules == null || _isEditing) ...[
                      _buildTextField(
                        controller: _generalRuleController,
                        label: 'القاعدة العامة *',
                        required: true,
                        maxLines: 5,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _groomSuppliesController,
                        label: 'لوازم العريس',
                        maxLines: 3,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _clothingController,
                        label: 'قواعد الملابس',
                        maxLines: 3,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _kitchenwareController,
                        label: 'قواعد أدوات المطبخ',
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
                    // Show view mode only when rules exist AND not editing
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: isDark ? AppColors.darkInputBackground : AppColors.surface,
      ),
      maxLines: maxLines,
      validator: required ? (v) => v?.trim().isEmpty ?? true ? 'هذا الحقل مطلوب' : null : null,
    );
  }
  
  Widget _buildPdfSection(bool isDark, {bool isEditing = false}) {
    // Check if there's a PDF (either uploaded or pending)
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
                      // Show open button only for uploaded PDFs
                      if (_pdfUrl != null)
                        IconButton(
                          icon: const Icon(Icons.open_in_new, color: AppColors.primary),
                          onPressed: () => _openPdf(_pdfUrl!),
                          tooltip: 'فتح الملف',
                        ),
                      // Only show delete button in edit mode
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
      return 'كتاب القوانين.pdf';
    }
  }
  
  Widget _buildViewMode(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard('القاعدة العامة', _rules!['general_rule'], Icons.rule),
        if (_rules!['groom_supplies']?.toString().isNotEmpty ?? false)
          _buildInfoCard('لوازم العريس', _rules!['groom_supplies'], Icons.shopping_bag),
        if (_rules!['rule_about_clothing']?.toString().isNotEmpty ?? false)
          _buildInfoCard('قواعد الملابس', _rules!['rule_about_clothing'], Icons.checkroom),
        if (_rules!['rule_about_kitchenware']?.toString().isNotEmpty ?? false)
          _buildInfoCard('قواعد أدوات المطبخ', _rules!['rule_about_kitchenware'], Icons.kitchen),
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