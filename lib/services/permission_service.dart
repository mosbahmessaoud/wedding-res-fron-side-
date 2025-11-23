// lib/services/permission_service.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  // Check if all required permissions are granted
  Future<bool> checkAllPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.photos, // For Android 13+
      Permission.notification,
    ].request();

    return statuses.values.every((status) => 
      status.isGranted || status.isLimited
    );
  }

  // Request all necessary permissions
  Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    Map<Permission, PermissionStatus> statuses = {};

    // For Android 13+ (API 33+), use photos permission
    if (await Permission.photos.isPermanentlyDenied == false) {
      statuses[Permission.photos] = await Permission.photos.request();
    }
    
    // For older Android versions
    if (await Permission.storage.isPermanentlyDenied == false) {
      statuses[Permission.storage] = await Permission.storage.request();
    }

    // Notification permission
    if (await Permission.notification.isPermanentlyDenied == false) {
      statuses[Permission.notification] = await Permission.notification.request();
    }

    return statuses;
  }

  // Check individual permission status
  Future<PermissionStatus> checkPermission(Permission permission) async {
    return await permission.status;
  }

  // Request individual permission
  Future<PermissionStatus> requestPermission(Permission permission) async {
    return await permission.request();
  }

  // Open app settings if permission is permanently denied
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  // Show permission dialog with explanation
  Future<bool> showPermissionDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'الأذونات المطلوبة',
            textAlign: TextAlign.right,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'يحتاج التطبيق إلى الأذونات التالية للعمل بشكل صحيح:',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),

                PermissionItem(
                  icon: Icons.notifications,
                  title: 'الإشعارات',
                  description: 'لإرسال تنبيهات حول الحجوزات والمواعيد',
                ),
                SizedBox(height: 12),
                PermissionItem(
                  icon: Icons.storage,
                  title: 'التخزين',
                  description: 'لحفظ البيانات والملفات محلياً',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'رفض',
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('السماح'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  // Show settings dialog when permission is permanently denied
  Future<void> showSettingsDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'الأذونات مطلوبة',
            textAlign: TextAlign.right,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'تم رفض بعض الأذونات بشكل دائم. يرجى السماح بها من إعدادات التطبيق.',
            textAlign: TextAlign.right,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('فتح الإعدادات'),
            ),
          ],
        );
      },
    );
  }
}

// Widget for permission item in dialog
class PermissionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const PermissionItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: TextDirection.rtl,
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}