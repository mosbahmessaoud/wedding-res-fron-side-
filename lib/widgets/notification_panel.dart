// lib/widgets/notification_panel.dart
import 'package:flutter/material.dart';
import 'package:wedding_reservation_app/services/api_service.dart';
import 'package:wedding_reservation_app/utils/colors.dart';

class NotificationPanel extends StatefulWidget {
  const NotificationPanel({super.key});

  @override
  State<NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<NotificationPanel> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;
  String _error = '';
  String _filterType = 'all'; // all, unread, read
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Load unread count
      final unreadCount = await ApiService.getUnreadNotificationCount();
      
      // Load notifications based on filter
      List<dynamic> notifications;
      if (_filterType == 'unread') {
        notifications = await ApiService.getUnreadNotifications(limit: 100);
      } else {
        notifications = await ApiService.getNotifications(limit: 100);
        if (_filterType == 'read') {
          notifications = notifications.where((n) => n['is_read'] == true).toList();
        }
      }

      setState(() {
        _notifications = notifications;
        _unreadCount = unreadCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(int notificationId) async {
    try {
      await ApiService.markNotificationAsRead(notificationId);
      _loadNotifications();
    } catch (e) {
      _showErrorSnackBar('فشل في تعليم الإشعار كمقروء: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await ApiService.markAllNotificationsAsRead();
      _loadNotifications();
      _showSuccessSnackBar('تم تعليم جميع الإشعارات كمقروءة');
    } catch (e) {
      _showErrorSnackBar('فشل في تعليم الإشعارات: $e');
    }
  }

  Future<void> _deleteNotification(int notificationId) async {
    try {
      await ApiService.deleteNotification(notificationId);
      _loadNotifications();
      _showSuccessSnackBar('تم حذف الإشعار');
    } catch (e) {
      _showErrorSnackBar('فشل في حذف الإشعار: $e');
    }
  }

  Future<void> _deleteAllRead() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الإشعارات المقروءة'),
        content: const Text('هل أنت متأكد من حذف جميع الإشعارات المقروءة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final count = await ApiService.deleteAllReadNotifications();
        _loadNotifications();
        _showSuccessSnackBar('تم حذف $count إشعار');
      } catch (e) {
        _showErrorSnackBar('فشل في حذف الإشعارات: $e');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'reservation_approved':
        return Colors.green;
      case 'reservation_rejected':
        return Colors.red;
      case 'reservation_cancelled':
        return Colors.orange;
      case 'payment_reminder':
        return Colors.blue;
      case 'reservation_reminder':
        return Colors.purple;
      case 'general_announcement':
        return AppColors.primary;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'reservation_approved':
        return Icons.check_circle;
      case 'reservation_rejected':
        return Icons.cancel;
      case 'reservation_cancelled':
        return Icons.event_busy;
      case 'payment_reminder':
        return Icons.payment;
      case 'reservation_reminder':
        return Icons.event;
      case 'general_announcement':
        return Icons.announcement;
      default:
        return Icons.notifications;
    }
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 365) {
        final years = (difference.inDays / 365).floor();
        return 'منذ $years ${years == 1 ? 'سنة' : 'سنوات'}';
      } else if (difference.inDays > 30) {
        final months = (difference.inDays / 30).floor();
        return 'منذ $months ${months == 1 ? 'شهر' : 'أشهر'}';
      } else if (difference.inDays > 0) {
        return 'منذ ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}';
      } else if (difference.inHours > 0) {
        return 'منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
      } else if (difference.inMinutes > 0) {
        return 'منذ ${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
      } else {
        return 'الآن';
      }
    } catch (e) {
      return dateTimeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'الإشعارات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark 
            ? const Color(0xFF1E1E1E)
            : Colors.white,
        elevation: 0,
        actions: [
          if (_unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'تعليم الكل كمقروء',
              onPressed: _markAllAsRead,
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'delete_read') {
                _deleteAllRead();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete_read',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: Colors.red),
                    SizedBox(width: 8),
                    Text('حذف المقروء'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.8),
                  AppColors.primary.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('الكل', _notifications.length),
                _buildStatItem('غير مقروء', _unreadCount),
                _buildStatItem('مقروء', _notifications.length - _unreadCount),
              ],
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('الكل', 'all', isDark),
                const SizedBox(width: 8),
                _buildFilterChip('غير مقروء', 'unread', isDark),
                const SizedBox(width: 8),
                _buildFilterChip('مقروء', 'read', isDark),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Notifications List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'حدث خطأ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _error,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _loadNotifications,
                              icon: const Icon(Icons.refresh),
                              label: const Text('إعادة المحاولة'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _notifications.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_none,
                                  size: 64,
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'لا توجد إشعارات',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadNotifications,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _notifications.length,
                              itemBuilder: (context, index) {
                                final notification = _notifications[index];
                                return _buildNotificationCard(notification, isDark);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value, bool isDark) {
    final isSelected = _filterType == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterType = value;
        });
        _loadNotifications();
      },
      selectedColor: AppColors.primary,
      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, bool isDark) {
    final isRead = notification['is_read'] ?? false;
    final type = notification['notification_type'] ?? 'general';
    final color = _getNotificationColor(type);
    final icon = _getNotificationIcon(type);

    return Dismissible(
      key: Key(notification['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification['id']);
      },
      child: GestureDetector(
        onTap: () {
          if (!isRead) {
            _markAsRead(notification['id']);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark 
                ? (isRead ? Colors.grey[850] : Colors.grey[800])
                : (isRead ? Colors.white : Colors.blue[50]),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isRead 
                  ? Colors.transparent 
                  : color.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'] ?? 'إشعار',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification['message'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDateTime(notification['created_at'] ?? ''),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}