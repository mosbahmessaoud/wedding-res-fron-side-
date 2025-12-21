// lib/screens/super_admin/access_password_management_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/api_service.dart';

class SuperAdminAccessPasswordPage extends StatefulWidget {
  const SuperAdminAccessPasswordPage({Key? key}) : super(key: key);

  @override
  State<SuperAdminAccessPasswordPage> createState() => _SuperAdminAccessPasswordPageState();
}

class _SuperAdminAccessPasswordPageState extends State<SuperAdminAccessPasswordPage> {
  List<dynamic> _clanAdmins = [];
  List<dynamic> _filteredAdmins = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int? _selectedCountyId;
  List<dynamic> _counties = [];

  @override
  void initState() {
    super.initState();
    _loadCounties();
  }

  Future<void> _loadCounties() async {
    try {
      final counties = await ApiService.listCountiesAdmin();
      setState(() {
        _counties = counties;
        if (_counties.isNotEmpty) {
          _selectedCountyId = _counties[0].id;
          _loadClanAdmins();
        }
      });
    } catch (e) {
      _showError('فشل في تحميل البلديات: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadClanAdmins() async {
    if (_selectedCountyId == null) return;

    setState(() => _isLoading = true);

    try {
      final admins = await ApiService.getClanAdminsWithAccessStatus(_selectedCountyId!);
      setState(() {
        _clanAdmins = admins;
        _filterAdmins();
        _isLoading = false;
      });
    } catch (e) {
      _showError('فشل في تحميل مدراء العشائر: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterAdmins() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredAdmins = _clanAdmins;
      } else {
        _filteredAdmins = _clanAdmins.where((admin) {
          final firstName = admin['first_name']?.toString().toLowerCase() ?? '';
          final lastName = admin['last_name']?.toString().toLowerCase() ?? '';
          final phoneNumber = admin['phone_number']?.toString() ?? '';
          final query = _searchQuery.toLowerCase();
          
          return firstName.contains(query) || 
                 lastName.contains(query) || 
                 phoneNumber.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _generateAccessPassword(int adminId, String adminName) async {
    final confirmed = await _showConfirmDialog(
      'إنشاء كلمة مرور الوصول',
      'هل أنت متأكد من إنشاء كلمة مرور وصول جديدة لـ $adminName؟\nسيتم إلغاء كلمة المرور القديمة إن وجدت.',
    );

    if (!confirmed) return;

    try {
      _showLoadingDialog();
      
      final result = await ApiService.generateClanAdminAccessPassword(adminId);
      
      Navigator.pop(context); // Close loading dialog
      
      _showGeneratedPasswordDialog(
        result['generated_password'],
        adminName,
      );

      // Reload to update status
      _loadClanAdmins();
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showError('فشل في إنشاء كلمة مرور الوصول: $e');
    }
  }

  Future<void> _setCustomPassword(int adminId, String adminName) async {
    final controller = TextEditingController();
    
    final password = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعيين كلمة مرور مخصصة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تعيين كلمة مرور وصول لـ: $adminName'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'كلمة مرور الوصول',
                hintText: 'أدخل كلمة المرور',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context, controller.text);
              }
            },
            child: const Text('تعيين'),
          ),
        ],
      ),
    );

    if (password == null || password.isEmpty) return;

    try {
      _showLoadingDialog();
      
      await ApiService.setClanAdminAccessPassword(adminId, password);
      
      Navigator.pop(context); // Close loading dialog
      
      _showSuccess('تم تعيين كلمة مرور الوصول بنجاح لـ $adminName');
      _loadClanAdmins();
    } catch (e) {
      Navigator.pop(context);
      _showError('فشل في تعيين كلمة مرور الوصول: $e');
    }
  }

  void _showGeneratedPasswordDialog(String password, String adminName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.key, color: Colors.green),
            const SizedBox(width: 8),
            const Expanded(child: Text('كلمة مرور الوصول')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'تم إنشاء كلمة مرور الوصول لـ:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              adminName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: SelectableText(
                password,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: const [
                  Icon(Icons.warning_amber, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'انسخ هذه الكلمة الآن - لن تظهر مرة أخرى!',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: password));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم نسخ كلمة المرور'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('نسخ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة كلمات مرور الوصول'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // County Selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(Icons.location_city),
                const SizedBox(width: 8),
                const Text('البلدية: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: DropdownButton<int>(
                    value: _selectedCountyId,
                    isExpanded: true,
                    items: _counties.map((county) {
                      return DropdownMenuItem<int>(
                        value: county.id,
                        child: Text(county.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCountyId = value;
                        _loadClanAdmins();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'البحث عن مدير عشيرة...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _filterAdmins();
                });
              },
            ),
          ),

          // Admin List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAdmins.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.person_off, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'لا توجد نتائج',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredAdmins.length,
                        itemBuilder: (context, index) {
                          final admin = _filteredAdmins[index];
                          // DEBUG: Print the admin data
                          print('Admin data: $admin');
                          print('Has password hash: ${admin['access_pages_password_hash']}');
                          
                          // Safely check for password
                          final hasPassword = admin['access_pages_password_hash'] != null;
                         
                          final fullName = '${admin['first_name']} ${admin['last_name']}';
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: hasPassword ? Colors.green : Colors.orange,
                                child: Icon(
                                  hasPassword ? Icons.verified_user : Icons.lock_open,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                fullName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('هاتف: ${admin['phone_number']}'),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        hasPassword ? Icons.check_circle : Icons.warning,
                                        size: 16,
                                        color: hasPassword ? Colors.green : Colors.orange,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        hasPassword ? 'لديه كلمة مرور' : 'لا توجد كلمة مرور',
                                        style: TextStyle(
                                          color: hasPassword ? Colors.green : Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) {
                                  if (value == 'generate') {
                                    _generateAccessPassword(admin['id'], fullName);
                                  } else if (value == 'custom') {
                                    _setCustomPassword(admin['id'], fullName);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'generate',
                                    child: Row(
                                      children: [
                                        Icon(Icons.auto_awesome),
                                        SizedBox(width: 8),
                                        Text('إنشاء تلقائي'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'custom',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit),
                                        SizedBox(width: 8),
                                        Text('تعيين مخصص'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}