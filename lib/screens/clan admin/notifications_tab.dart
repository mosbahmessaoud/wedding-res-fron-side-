// lib/screens/super_admin/notifications_tab.dart
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../utils/colors.dart';

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  NotificationsTabState createState() => NotificationsTabState();
}

class NotificationsTabState extends State<NotificationsTab> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _versionController = TextEditingController();
  bool _isLoading = false;
  String? _selectedRecipient = 'all'; // 'all', 'grooms', 'clan_admins', 'grooms_reserved'

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _versionController.dispose();
    super.dispose();
  }
  void refreshData(){
    setState((){});
  }

  Future<void> _sendNotification() async {
    if (_titleController.text.trim().isEmpty || 
        _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى ملء جميع الحقول المطلوبة'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
   
    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> result;
      
      if (_selectedRecipient == 'grooms') {
        result = await ApiService.sendNotificationToAllGrooms(
          title: _titleController.text.trim(),
          message: _messageController.text.trim(),
        );
        _showSuccessMessage(result['message']);
      
      } else if (_selectedRecipient == 'grooms_reserved') {
        // Call the reserved grooms endpoint
        result = await ApiService.createNotificationForValidReserv(
          title: _titleController.text.trim(),
          message: _messageController.text.trim(),
          isGroom: true, // Set to true for grooms with reservations
        );
        _showSuccessMessage(result['message']);
      }

      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendAppUpdateNotification() async {
    if (_versionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى إدخال رقم الإصدار'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.sendAppUpdateNotification(
        version: _versionController.text.trim(),
      );
      
      _showSuccessMessage('تم إرسال إشعار التحديث إلى ${result['total_count']} مستخدم');
      _versionController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearForm() {
    _titleController.clear();
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.textPrimary : AppColors.darkTextPrimary,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.notifications_active,
                  color: AppColors.primary,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  'إرسال الإشعارات',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Quick Action: App Update
                  // _buildQuickActionCard(isDark),
                  
                  // SizedBox(height: 24),
                  
                  // Custom Notification Form
                  _buildCustomNotificationCard(isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildQuickActionCard(bool isDark) {
  //   return Card(
  //     elevation: 2,
  //     child: Padding(
  //       padding: EdgeInsets.all(16),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             children: [
  //               Icon(Icons.system_update, color: AppColors.primary),
  //               SizedBox(width: 8),
  //               Text(
  //                 'إشعار تحديث التطبيق',
  //                 style: TextStyle(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           SizedBox(height: 16),
            
  //           TextField(
  //             controller: _versionController,
  //             decoration: InputDecoration(
  //               labelText: 'رقم الإصدار',
  //               hintText: 'مثال: 2.5.0',
  //               border: OutlineInputBorder(),
  //               prefixIcon: Icon(Icons.tag),
  //             ),
  //           ),
            
  //           SizedBox(height: 12),
            
  //           SizedBox(
  //             width: double.infinity,
  //             child: ElevatedButton.icon(
  //               onPressed: _isLoading ? null : _sendAppUpdateNotification,
  //               icon: _isLoading 
  //                   ? SizedBox(
  //                       width: 16,
  //                       height: 16,
  //                       child: CircularProgressIndicator(
  //                         strokeWidth: 2,
  //                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
  //                       ),
  //                     )
  //                   : Icon(Icons.send),
  //               label: Text('إرسال إشعار التحديث لجميع المستخدمين'),
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: AppColors.primary,
  //                 foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
  //                 padding: EdgeInsets.symmetric(vertical: 16),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildCustomNotificationCard(bool isDark) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit_notifications, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'إشعار مخصص',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Recipient Selection
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المستلمون:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildRecipientChip(' إرسال إشعار للجميع ', 'grooms', isDark),
                      _buildRecipientChip('إرسال إشعار لكل عريس لديه حجز', 'grooms_reserved', isDark),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16),
            
            // Title Field
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'العنوان',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              maxLength: 100,
            ),
            
            SizedBox(height: 16),
            
            // Message Field
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'الرسالة',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.message),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              maxLength: 500,
            ),
            
            SizedBox(height: 16),
            
            // Send Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _sendNotification,
                icon: _isLoading 
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(Icons.send),
                label: Text('إرسال الإشعار'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientChip(String label, String value, bool isDark) {
    final isSelected = _selectedRecipient == value;
    
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedRecipient = value);
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected 
            ? (isDark ? Colors.white : AppColors.textPrimary)
            : null,
      ),
    );
  }
}