// lib/screens/clan admin/notifications_tab.dart
import 'package:flutter/material.dart';
import 'package:wedding_reservation_app/services/connectivity_service.dart';

import '../../services/api_service.dart';
import '../../utils/colors.dart';

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  NotificationsTabState createState() => NotificationsTabState();
}

class NotificationsTabState extends State<NotificationsTab> with SingleTickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _versionController = TextEditingController();
  bool _isLoading = false;
  String? _selectedRecipient = 'grooms_reserved';
  
  late TabController _tabController;
  List<dynamic> _notifications = [];
  bool _isLoadingNotifications = false;

//   @override
// void initState() {
//   super.initState();
//   _tabController = TabController(length: 2, vsync: this);
//   _checkConnectivityAndLoad();
// }

bool _hasLoadedOnce = false;

@override
void initState() {
  super.initState();
  _tabController = TabController(length: 2, vsync: this);
  // Do NOT load here — wait until tab is activated
}

void activateTab() {
  if (!_hasLoadedOnce) {
    _hasLoadedOnce = true;
    _checkConnectivityAndLoad();
  }
}

void refreshData() {
  _checkConnectivityAndLoad();
}
Future<void> _checkConnectivityAndLoad() async {
  final isOnline = ConnectivityService().isOnline ||
      await ConnectivityService().checkRealInternet();

  if (!isOnline) {
    if (mounted) {
      setState(() => _isLoadingNotifications = false);
      _showOfflineSnackbar();
    }
    return;
  }

  await Future.wait([
    _loadNotifications(),
    _loadSendedNotifications(),
    _markAllAsReadOnOpen(),
  ]);
}

void _showOfflineSnackbar() {
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: const [
          Icon(Icons.wifi_off, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text('لا يوجد اتصال بالإنترنت'),
        ],
      ),
      backgroundColor: Colors.red.shade700,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

/// Mark all notifications as read when opening the page
Future<void> _markAllAsReadOnOpen() async {
  try {
    await ApiService.markAllNotificationsAsRead();
    print('✅ All notifications marked as read');
    
    // Refresh notification list after marking as read
    if (mounted) {
      _loadNotifications();
    }
  } catch (e) {
    print('⚠️ Failed to mark all as read: $e');
  }
}

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _versionController.dispose();
    _tabController.dispose();
    super.dispose();
  }

// void refreshData() {
//   _checkConnectivityAndLoad();
// }


Future<void> _loadNotifications() async {
  if (!mounted) return;
  setState(() => _isLoadingNotifications = true);
  try {
    final notifications = await ApiService.getNotifications(limit: 100);
    if (mounted) setState(() => _notifications = notifications);
  } catch (e) {
    // Silent — error already surfaced by the offline banner or is a transient API error
    print('Error loading notifications: $e');
  } finally {
    if (mounted) setState(() => _isLoadingNotifications = false);
  }
}

Future<void> _loadSendedNotifications() async {
  if (!mounted) return;
  setState(() => _isLoadingNotifications = true);
  try {
    final notifications = await ApiService.getSendedNotifications(limit: 100);
    if (mounted) setState(() => _notifications = notifications);
  } catch (e) {
    print('Error loading sent notifications: $e');
  } finally {
    if (mounted) setState(() => _isLoadingNotifications = false);
  }
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
      
      // if (_selectedRecipient == 'grooms') {
      //   result = await ApiService.sendNotificationToAllGrooms(
      //     title: _titleController.text.trim(),
      //     message: _messageController.text.trim(),
      //   );
      //   _showSuccessMessage(result['message']);
      
      // } else 
      if (_selectedRecipient == 'grooms_reserved') {
        result = await ApiService.createNotificationForValidReserv(
          title: _titleController.text.trim(),
          message: _messageController.text.trim(),
          isGroom: true,
        );
        _showSuccessMessage(result['message']);
      }

      _clearForm();
      _loadNotifications();
      _loadSendedNotifications(); // Reload notifications after sending
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

  Future<void> _editNotification(Map<String, dynamic> notification) async {
    final titleController = TextEditingController(text: notification['title']);
    final messageController = TextEditingController(text: notification['message']);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: AppColors.primary),
            SizedBox(width: 8),
            Text('تعديل الإشعار'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'العنوان',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                maxLength: 100,
              ),
              SizedBox(height: 16),
              TextField(
                controller: messageController,
                decoration: InputDecoration(
                  labelText: 'الرسالة',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.message),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                maxLength: 500,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty || 
                  messageController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('يرجى ملء جميع الحقول'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text('حفظ'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        setState(() => _isLoading = true);
        
        // Note: You'll need to implement updateNotification in ApiService
        // For now, we'll delete and recreate (as a workaround)
        await ApiService.deleteNotification(notification['id']);
        
        // Resend the notification with updated content
        if (notification['user_id'] != null) {
          await ApiService.sendNotificationToAllGrooms(

            title: titleController.text.trim(),
            message: messageController.text.trim(),
          );
        }

        _showSuccessMessage('تم تحديث الإشعار بنجاح');
        _loadNotifications();
        _loadSendedNotifications();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحديث الإشعار: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }

    titleController.dispose();
    messageController.dispose();
  }

  Future<void> _deleteNotification(int notificationId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('تأكيد الحذف'),
          ],
        ),
        content: Text('هل أنت متأكد من حذف هذا الإشعار؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('حذف '),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);
        await ApiService.bulkDeleteNotifications();
        _showSuccessMessage('تم حذف الإشعار بنجاح');
        _loadNotifications();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حذف الإشعار: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  // Future<void> _deleteMultipleNotifications(List<int> notificationIds) async {
  //   final confirmed = await showDialog<bool>(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Row(
  //         children: [
  //           Icon(Icons.warning, color: Colors.orange),
  //           SizedBox(width: 8),
  //           Text('تأكيد الحذف'),
  //         ],
  //       ),
  //       content: Text('هل أنت متأكد من حذف ${notificationIds.length} إشعار؟'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, false),
  //           child: Text('إلغاء'),
  //         ),
  //         ElevatedButton(
  //           onPressed: () => Navigator.pop(context, true),
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: Colors.red,
  //           ),
  //           child: Text('حذف الكل'),
  //         ),
  //       ],
  //     ),
  //   );

  //   if (confirmed == true) {
  //     try {
  //       setState(() => _isLoading = true);
  //       final result = await ApiService.bulkDeleteNotifications();
  //       _showSuccessMessage('تم حذف ${result['count']} إشعار بنجاح');
  //       _loadNotifications();
  //     } catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('خطأ في حذف الإشعارات: ${e.toString()}'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     } finally {
  //       setState(() => _isLoading = false);
  //     }
  //   }
  // }

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
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.notifications_active,
                      color: AppColors.primary,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'إدارة الإشعارات',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
                  indicatorColor: AppColors.primary,
                  tabs: [
                    Tab(
                      icon: Icon(Icons.send),
                      text: 'إرسال جديد',
                    ),
                    Tab(
                      icon: Icon(Icons.list),
                      text: 'الإشعارات المرسلة',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Send Notification Tab
                _buildSendNotificationTab(isDark),
                
                // Notifications List Tab
                _buildNotificationsListTab(isDark),
                // const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendNotificationTab(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 50),
      child: _buildCustomNotificationCard(isDark),
    );
    
  }

  Widget _buildNotificationsListTab(bool isDark) {
    if (_isLoadingNotifications) {
      return Center(child: CircularProgressIndicator());
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'لا توجد إشعارات',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Action buttons
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _loadSendedNotifications,
                  icon: Icon(Icons.refresh),
                  label: Text('تحديث'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ),
             
            ],
          ),
        ),

        // Notifications list
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: _notifications.length,
            itemBuilder: (context, index) {
              final notification = _notifications[index];
              return _buildNotificationCard(notification, isDark);
            },
          ),
        ),
        const SizedBox(height: 70),
      ],
      
    );
  }
Widget _buildNotificationCard(Map<String, dynamic> notification, bool isDark) {
  // Show original read status for visual reference, but they're all marked as read in backend
  final wasUnread = notification['is_read'] == false;
  final createdAt = DateTime.parse(notification['created_at']);
  
  // Extract user information
  final userPhone = notification['user_phone_number'] ?? 'غير متوفر';
  final userName = _buildUserName(notification);
  
  return Card(
    margin: EdgeInsets.only(bottom: 12),
    elevation: wasUnread ? 2 : 1,
    color: wasUnread 
        ? null // Keep normal card color for originally unread
        : (isDark ? Colors.grey[850] : Colors.grey[100]),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: wasUnread ? AppColors.primary.withOpacity(0.7) : Colors.grey,
        child: Icon(
          wasUnread ? Icons.notifications_active : Icons.notifications,
          color: Colors.white,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              notification['title'] ?? 'بدون عنوان',
              style: TextStyle(
                fontWeight: wasUnread ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          // Optional: Show a small indicator that it was recently unread
          if (wasUnread)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'جديد',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 4),
          Text(
            notification['message'] ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8),
          // User info section
          Container(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_outline,
                  size: 14,
                  color: AppColors.primary,
                ),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    userName,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.phone_outlined,
                  size: 14,
                  color: AppColors.primary,
                ),
                SizedBox(width: 4),
                Text(
                  userPhone,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4),
          Text(
            _formatDateTime(createdAt),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        icon: Icon(Icons.more_vert),
        onSelected: (value) {
          if (value == 'edit') {
            _editNotification(notification);
          } else if (value == 'delete') {
            _deleteNotification(notification['id']);
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 20),
                SizedBox(width: 8),
                Text('تعديل'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 20, color: Colors.red),
                SizedBox(width: 8),
                Text('حذف', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
      isThreeLine: true,
    ),
  );
}

// Helper method to build user name from notification data
String _buildUserName(Map<String, dynamic> notification) {
  final firstName = notification['user_first_name'] ?? '';
  final lastName = notification['user_last_name'] ?? '';
  
  if (firstName.isEmpty && lastName.isEmpty) {
    return 'مستخدم غير معروف';
  }
  
  return '$firstName $lastName'.trim();
}

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
                    'المستلمون:  جميع العرسان (بما فيذالك الذين لم يقيمو العرس بعد)',
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
                      // _buildRecipientChip('إرسال للجميع', 'grooms', isDark),
                      _buildRecipientChip(' ', 'grooms_reserved', isDark),
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

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
    } else {
      return 'الآن';
    }
  }
}