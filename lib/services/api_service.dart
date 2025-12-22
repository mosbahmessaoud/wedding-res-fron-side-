// lib/services/api_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:wedding_reservation_app/models/reservation.dart';
import 'package:wedding_reservation_app/services/token_manager.dart';

import '../models/clan.dart';
import '../models/county.dart';


class ApiService {
  // static const String baseUrl = 'https://f09e1a125031.ngrok-free.app'; // Replace with your actual API URL
  // static const String baseUrl = 'http://192.168.1.3:8000'; // Replace with your actual API URL
  static const String baseUrl = 'https://valiant-courtesy-production.up.railway.app'; // Replace with your actual API URL
  // static const String baseUrl = 'http://127.0.0.1:8000'; // Replace with your actual API URL
  static String? _token;

//   static void setToken(String token) {
//     _token = token;  
// }
static Future<void> setToken(String token) async {
  await TokenManager.saveToken(token);
  _token = token;
}

  // clear token
  // static void clearToken() {
  //   _token = null;
  // }
  static Future<void> clearToken() async {
  await TokenManager.clearToken();
  _token = null;
}

static Future<Map<String, String>> get _headers async {
  final headers = {
    'Content-Type': 'application/json',
  };
  
  // Get token from TokenManager
  final token = await TokenManager.getToken();
  if (token != null) {
    headers['Authorization'] = 'Bearer $token';
  }
  
  return headers;
}
// Add this method near the top of your ApiService class
static Future<void> initializeToken() async {
  _token = await TokenManager.getToken();
}
  // ==================== AUTH ENDPOINTS ====================
  
  // Get User Role
  static Future<String> getRole() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/get_role'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['role'];
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في الحصول على الدور');
      }
    } catch (e) {
      throw Exception('خطأ في الحصول على الدور: $e');
    }
  }

  // Delete User
  static Future<void> deleteUser(String phoneNumber) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/auth/delet_user/$phoneNumber'),
        headers: await _headers,
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في الحذف');
      }
    } catch (e) {
      throw Exception('خطأ في الحذف: $e');
    }
  }

  // Get Current User Info
  static Future<Map<String, dynamic>> getCurrentUserInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في الحصول على بيانات المستخدم');
      }
    } catch (e) {
      throw Exception('خطأ في الحصول على بيانات المستخدم: $e');
    }
  }

  // Login
  static Future<Map<String, dynamic>> login(String phoneNumber, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: await await _headers,
      body: json.encode({
        'phone_number': phoneNumber,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      // Save token using async method
      await setToken(data['access_token']);
      
      return data;
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في تسجيل الدخول');
    }
  } catch (e) {
    throw Exception('خطأ في تسجيل الدخول: $e');
  }
}

  // Register Groom
  static Future<Map<String, dynamic>> registerGroom(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/groom'),
        headers: await _headers,
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في التسجيل');
      }
    } catch (e) {
      throw Exception('خطأ في التسجيل: $e');
    }
  }

  // Verify Phone
  static Future<void> verifyPhone(String phoneNumber, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-phone'),
        headers: await _headers,
        body: json.encode({
          'phone_number': phoneNumber,
          'code': code,
        }),
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في التحقق من الهاتف');
      }else{
        // returne the message on the return from router 
        final data = json.decode(response.body);
        return data;
        }
    } catch (e) {
      throw Exception('خطأ في التحقق: $e');
    }
  }

  // Resend OTP
  static Future<void> resendOTP(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/resend-verification'),
        headers: await _headers,
        body: json.encode({
          'phone_number': phoneNumber,
        }),
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في إعادة إرسال الرمز');
      }
    } catch (e) {
      throw Exception('خطأ في إعادة الإرسال: $e');
    }
  }

  // Verify New Phone
  static Future<void> verifyNewPhone(String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-new-phone'),
        headers: await _headers,
        body: json.encode(code),
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في التحقق من الهاتف الجديد');
      }
    } catch (e) {
      throw Exception('خطأ في التحقق: $e');
    }
  }

// Reset Password function 
// Add this method to your ApiService class in the AUTH ENDPOINTS section

// Reset Password
static Future<Map<String, dynamic>> resetPassword(
  String phoneNumber, 
  String otpCode, 
  String newPassword
) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: await _headers,
      body: json.encode({
        'phone_number': phoneNumber,
        'otp_code': otpCode,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في إعادة تعيين كلمة المرور');
    }
  } catch (e) {
    throw Exception('خطأ في إعادة تعيين كلمة المرور: $e');
  }
}

// Request Password Reset OTP (optional - if you want a separate endpoint for this)
static Future<Map<String, dynamic>> requestPasswordReset(String phoneNumber) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/request-password-reset'),
      headers: await _headers,
      body: json.encode({
        'phone_number': phoneNumber,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في طلب إعادة تعيين كلمة المرور');
    }
  } catch (e) {
    throw Exception('خطأ في طلب إعادة تعيين كلمة المرور: $e');
  }
}

  // ==================== SUPER ADMIN ENDPOINTS ====================
  
  // County Management
  static Future<Map<String, dynamic>> createCounty(Map<String, dynamic> countyData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/super-admin/county'),
        headers: await _headers,
        body: json.encode(countyData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في إنشاء البلدية');
      }
    } catch (e) {
      throw Exception('خطأ في إنشاء البلدية: $e');
    }
  }


  static Future<List<County>> listCountiesAdmin() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/super-admin/counties'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => County.fromJson(json)).toList();
      } else {
        throw Exception('فشل في تحميل البلديات');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }
  static Future<int> CountiesCount() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/super-admin/counties'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.length; // return the number of counties
      } else {
        throw Exception('فشل في تحميل البلديات');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<Map<String, dynamic>> updateCounty(int countyId, Map<String, dynamic> countyData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/super-admin/county/$countyId'),
        headers: await _headers,
        body: json.encode(countyData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في تحديث البلدية');
      }
    } catch (e) {
      throw Exception('خطأ في تحديث البلدية: $e');
    }
  }

  static Future<void> deleteCounty(int countyId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/super-admin/county/$countyId'),
        headers: await _headers,
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في حذف البلدية');
      }
    } catch (e) {
      throw Exception('خطأ في حذف البلدية: $e');
    }
  }

  // Clan Management
  static Future<Map<String, dynamic>> createClan(Map<String, dynamic> clanData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/super-admin/clan'),
        headers: await _headers,
        body: json.encode(clanData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في إنشاء العشيرة');
      }
    } catch (e) {
      throw Exception('خطأ في إنشاء العشيرة: $e');
    }
  }

  static Future<List<Clan>> listClansByCounty(int countyId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/super-admin/clans/$countyId'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Clan.fromJson(json)).toList();
      } else {
        throw Exception('1فشل في تحميل العشائر');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<Map<String, dynamic>> updateClan(int clanId, Map<String, dynamic> clanData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/super-admin/clan/$clanId'),
        headers: await _headers,
        body: json.encode(clanData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في تحديث العشيرة');
      }
    } catch (e) {
      throw Exception('خطأ في تحديث العشيرة: $e');
    }
  }

  static Future<void> deleteClan(int clanId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/super-admin/clan/$clanId'),
        headers: await _headers,
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في حذف العشيرة');
      }
    } catch (e) {
      throw Exception('خطأ في حذف العشيرة: $e');
    }
  }



  // Get All Clans
  static Future<List<Clan>> getAllClans() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/super-admin/all_clans'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Clan.fromJson(json)).toList();
      } else {
        throw Exception('2فشل في تحميل العشائر');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

//////////////////////////////Clan Admin CRUD//////////////////////////////
///

  // Clan Admin Management
  static Future<Map<String, dynamic>> createClanAdmin(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/super-admin/create-clan-admin'),
        headers: await _headers,
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في إنشاء مدير العشيرة');
      }
    } catch (e) {
      throw Exception('خطأ في إنشاء مدير العشيرة: $e');
    }
  }
// Get clan admin by ID (additional utility method)
  static Future<Map<String, dynamic>> getClanAdminById(int adminId) async {
    try {
      // This assumes you have an endpoint to get a single admin by ID
      // If not available, you might need to get all admins and filter
      final response = await http.get(
        Uri.parse('$baseUrl/super-admin/clan-admin/$adminId'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في تحميل مدير العشيرة');
      }
    } catch (e) {
      throw Exception('خطأ في تحميل مدير العشيرة: $e');
    }
  }

  

  static Future<List<dynamic>> listClanAdmins(int countyId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/super-admin/clan-admins/$countyId'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل في تحميل مدراء العشائر');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<void> deleteClanAdmin(int adminId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/super-admin/clan-admins/$adminId'),
        headers: await _headers,
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في حذف مدير العشيرة');
      }
    } catch (e) {
      throw Exception('خطأ في حذف مدير العشيرة: $e');
    }
  }
  // Search clan admins by name or phone
  Future<List<dynamic>> searchClanAdmins(int countyId, String query) async {
    try {
      final admins = await getClanAdminsByCounty(countyId);
      
      return admins.where((admin) {
        final firstName = admin['first_name']?.toString().toLowerCase() ?? '';
        final lastName = admin['last_name']?.toString().toLowerCase() ?? '';
        final phoneNumber = admin['phone_number']?.toString() ?? '';
        final queryLower = query.toLowerCase();
        
        return firstName.contains(queryLower) || 
              lastName.contains(queryLower) || 
              phoneNumber.contains(query);
      }).toList();
    } catch (e) {
      throw Exception('خطأ في البحث عن مدراء العشائر: $e');
    }
  }
  // Get all clan admins by county ID
  static Future<List<dynamic>> getClanAdminsByCounty(int countyId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/super-admin/clan-admins/$countyId'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في تحميل مدراء العشائر');
      }
    } catch (e) {
      throw Exception('خطأ في تحميل مدراء العشائر: $e');
    }
  }

  // Check clan admin status
static Future<Map<String, dynamic>> checkClanAdminStatus() async {
  try {
    
    final response = await http.get(
      Uri.parse('$baseUrl/clan-admin/admin-status'),
      headers: await _headers,
    );

    print('Clan admin status response: ${response.statusCode}');
    print('Clan admin status body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'has_admin': data['has_admin'] ,
        'is_active': data['is_active'] ,
        'admin_name': data['admin_name'],
        'clan_name': data['clan_name'],
        'message': data['message'] ?? '',
      };
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في التحقق من حالة مدير العشيرة');
    }
  } catch (e) {
    print('Error checking clan admin status: $e');
    throw Exception('خطأ في التحقق من حالة مدير العشيرة: $e');
  }
}
static Future<bool> clanHasActiveAdmin() async {
  try {
    final status = await checkClanAdminStatus();
    return status['has_admin'] == true && status['is_active'] == true;
  } catch (e) {
    print('Error checking if clan has active admin: $e');
    return false;
  }
}

/// Get clan admin status with fallback (returns null on error)
static Future<Map<String, dynamic>?> getClanAdminStatusSafe() async {
  try {
    return await checkClanAdminStatus();
  } catch (e) {
    print('Error getting clan admin status (safe): $e');
    return null;
  }
}

/// Get user-friendly error message based on clan admin status
static String getClanAdminStatusMessage(Map<String, dynamic> status, String clanName) {
  if (!status['has_admin']) {
    return 'عذراً، عشيرة $clanName غير مشتركة حالياً في التطبيق.\n\n'
           'يرجى التواصل مع إدارة العشيرة للانضمام إلى النظام.';
  }
  
  if (!status['is_active']) {
    return 'عذراً، حساب إدارة عشيرة $clanName غير نشط حالياً.\n\n'
           'يرجى التواصل مع إدارة العشيرة لتفعيل الحساب.';
  }
  
  return 'العشيرة نشطة ويمكن إجراء الحجز';
}
  // Fixed createClanAdminWithDetails method
static Future<Map<String, dynamic>> createClanAdminWithDetails({
  required String phoneNumber,
  required String password,
  required String firstName,
  required String lastName,
  required String fatherName,
  required String grandfatherName,
  required int clanId,
  required int countyId,
  String? birthDate,
  String? birthAddress,
  String? homeAddress,
}) async {
  final userData = {
    'phone_number': phoneNumber,
    'password': password,
    'first_name': firstName,
    'last_name': lastName,
    'father_name': fatherName,
    'grandfather_name': grandfatherName,
    'clan_id': clanId,
    'county_id': countyId,
    'role': 'clan_admin', // Required by the router
  };

  // Add optional fields ONLY if they are not null and not empty
  if (birthDate != null && birthDate.isNotEmpty) {
    userData['birth_date'] = birthDate;
  }
  if (birthAddress != null && birthAddress.isNotEmpty) {
    userData['birth_address'] = birthAddress;
  }
  if (homeAddress != null && homeAddress.isNotEmpty) {
    userData['home_address'] = homeAddress;
  }

  return await createClanAdmin(userData);
}

  // Update clan admin with specific parameters (convenience method)
  static Future<Map<String, dynamic>> updateClanAdminDetails(
    int adminId, {
    String? phoneNumber,
    String? password,
    String? firstName,
    String? lastName,
    String? fatherName,
    String? grandfatherName,
    int? clanId,
    int? countyId,
    String? birthDate,
    String? birthAddress,
    String? homeAddress,
  }) async {
    final Map<String, dynamic> userData = {};

    // Only add non-null fields to the update request
    if (phoneNumber != null) userData['phone_number'] = phoneNumber;
    if (password != null) userData['password'] = password;
    if (firstName != null) userData['first_name'] = firstName;
    if (lastName != null) userData['last_name'] = lastName;
    if (fatherName != null) userData['father_name'] = fatherName;
    if (grandfatherName != null) userData['grandfather_name'] = grandfatherName;
    if (clanId != null) userData['clan_id'] = clanId;
    if (countyId != null) userData['county_id'] = countyId;
    if (birthDate != null) userData['birth_date'] = birthDate;
    if (birthAddress != null) userData['birth_address'] = birthAddress;
    if (homeAddress != null) userData['home_address'] = homeAddress;

    return await updateClanAdmin(adminId, userData);
  }

    static Future<Map<String, dynamic>> updateClanAdmin(int adminId, Map<String, dynamic> userData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/super-admin/clan-admins/$adminId'),
        headers: await _headers,
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في تحديث مدير العشيرة');
      }
    } catch (e) {
      throw Exception('خطأ في تحديث مدير العشيرة: $e');
    }
  }



  // static Future<void> deleteGroom(String groom_phone) async {
  //   try {
  //     final response = await http.delete(
  //       Uri.parse('$baseUrl/clan-admin/grooms_deleted/$groom_phone'),
  //       headers: await _headers,
  //     );
  //     if (response.statusCode != 200) {
  //       final error = json.decode(response.body);
  //       throw Exception(error['detail'] ?? 'فشل في حذف العريس');
  //     }
  //   } catch (e) {
  //     throw Exception('خطأ في حذف العريس: $e');
  //   }
  // }
  static Future<void> deleteGroom(String groomPhone) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/clan-admin/grooms_deleted/$groomPhone'),
        headers: await _headers,
      );
          // Debug logging
      print('Delete response status: ${response.statusCode}');
      print('Delete response body: ${response.body}');
      // Accept more success status codes for deletion
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success - any 2xx status code indicates success
        return;
      }
      
      // Handle error responses
      String errorMessage = 'فشل في حذف العريس';
      
      if (response.body.isNotEmpty) {
        try {
          final error = json.decode(response.body);
          errorMessage = error['detail'] ?? error['message'] ?? errorMessage;
        } catch (jsonError) {
          errorMessage = response.body.isNotEmpty ? response.body : 'خطأ غير معروف في الخادم';
        }
      }
      
      throw Exception(errorMessage);
      
    } on SocketException {
      throw Exception('خطأ في الاتصال بالشبكة');
    } on TimeoutException {
      throw Exception('انتهت مهلة الاتصال');
    } on FormatException {
      throw Exception('خطأ في تنسيق البيانات من الخادم');
    } catch (e) {
      throw Exception('خطأ غير متوقع: ${e.toString()}');
    }
  }


  // Haia (Ceremony Committee) Management
  static Future<Map<String, dynamic>> createHaia(Map<String, dynamic> haiaData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/super-admin/haia'),
        headers: await _headers,
        body: json.encode(haiaData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في إنشاء لجنة الهاية');
      }
    } catch (e) {
      throw Exception('خطأ في إنشاء لجنة الهاية: $e');
    }
  }

  static Future<Map<String, dynamic>> updateHaia(int haiaId, int countyId, Map<String, dynamic> haiaData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/super-admin/haia/$haiaId/$countyId'),
        headers: await _headers,
        body: json.encode(haiaData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في تحديث لجنة الهاية');
      }
    } catch (e) {
      throw Exception('خطأ في تحديث لجنة الهاية: $e');
    }
  }

  static Future<void> deleteHaia(int haiaId, int countyId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/super-admin/haia/$haiaId/$countyId'),
        headers: await _headers,
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في حذف لجنة الهاية');
      }
    } catch (e) {
      throw Exception('خطأ في حذف لجنة الهاية: $e');
    }
  }

  static Future<List<dynamic>> listHaia(int countyId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/super-admin/haia/$countyId'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل في تحميل لجان الهاية');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // Madaih Committee Management
  static Future<Map<String, dynamic>> createMadaihCommittee(Map<String, dynamic> madaihData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/super-admin/madaih_committe'),
        headers: await _headers,
        body: json.encode(madaihData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في إنشاء لجنة المدائح');
      }
    } catch (e) {
      throw Exception('خطأ في إنشاء لجنة المدائح: $e');
    }
  }

  static Future<Map<String, dynamic>> updateMadaihCommittee(int madaihId, int countyId, Map<String, dynamic> madaihData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/super-admin/madaih_committe/$madaihId/$countyId'),
        headers: await _headers,
        body: json.encode(madaihData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في تحديث لجنة المدائح');
      }
    } catch (e) {
      throw Exception('خطأ في تحديث لجنة المدائح: $e');
    }
  }

  static Future<void> deleteMadaihCommittee(int madaihId, int countyId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/super-admin/madaih_committe/$madaihId/$countyId'),
        headers: await _headers,
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في حذف لجنة المدائح');
      }
    } catch (e) {
      throw Exception('خطأ في حذف لجنة المدائح: $e');
    }
  }

  static Future<List<dynamic>> listMadaihCommittee(int countyId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/super-admin/madaih_committe/$countyId'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل في تحميل لجان المدائح');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

// // Change Clan Admin Status (Super Admin only)
// static Future<Map<String, dynamic>> changeClanAdminStatus(int adminId) async {
//   try {
//     final response = await http.put(
//       Uri.parse('$baseUrl/super-admin/change_status/$adminId'),
//       headers: await _headers,
//     );

//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       final error = json.decode(response.body);
//       throw Exception(error['detail'] ?? 'فشل في تغيير حالة مدير العشيرة');
//     }
//   } catch (e) {
//     throw Exception('خطأ في تغيير حالة مدير العشيرة: $e');
//   }
// }

// Change Clan Admin Status (Super Admin only)
static Future<Map<String, dynamic>> changeClanAdminStatus(int adminId) async {
  try {
    final response = await http.put(
      Uri.parse('$baseUrl/super-admin/change_status/$adminId'),
      headers: await _headers,
    );
    
    print('🔍 Change clan admin status URL: $baseUrl/super-admin/change_status/$adminId');
    print('🔍 Change clan admin status response: ${response.statusCode}');
    print('🔍 Change clan admin status body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'id': data['id'],
        'phone_number': data['phone_number'],
        'first_name': data['first_name'],
        'last_name': data['last_name'],
        'status': data['status'], // 'active' or 'inactive'
      };
    } else if (response.statusCode == 404) {
      throw Exception('لم يتم العثور على مدير العشيرة');
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في تغيير حالة مدير العشيرة');
    }
  } catch (e) {
    print('❌ Error in changeClanAdminStatus: $e');
    throw Exception('خطأ في تغيير حالة مدير العشيرة: $e');
  }
}

// Get Clan Admin by ID
// static Future<Map<String, dynamic>> getClanAdminById(int adminId) async {
//   try {
//     final response = await http.get(
//       Uri.parse('$baseUrl/super-admin/clan-admins/$adminId'),
//       headers: await _headers,
//     );
    
//     print('🔍 Get clan admin URL: $baseUrl/super-admin/clan-admins/$adminId');
//     print('🔍 Get clan admin response: ${response.statusCode}');
    
//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else if (response.statusCode == 404) {
//       throw Exception('لم يتم العثور على مدير العشيرة');
//     } else {
//       final error = json.decode(response.body);
//       throw Exception(error['detail'] ?? 'فشل في جلب بيانات مدير العشيرة');
//     }
//   } catch (e) {
//     print('❌ Error in getClanAdminById: $e');
//     throw Exception('خطأ في جلب بيانات مدير العشيرة: $e');
//   }
// }

  // ==================== CLAN ADMIN ENDPOINTS ====================
  
  // // List Grooms
  // static Future<List<dynamic>> listGrooms() async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/clan-admin/grooms'),
  //       headers: await _headers,
  //     );

  //     if (response.statusCode == 200) {
  //       return json.decode(response.body);
  //     } else {
  //       throw Exception('فشل في تحميل العرسان');
  //     }
  //   } catch (e) {
  //     throw Exception('خطأ في الاتصال: $e');
  //   }
  // }

  // Hall Management
  static Future<List<dynamic>> listHalls() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/clan-admin/halls'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل في تحميل القاعات');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<Map<String, dynamic>> createHall(Map<String, dynamic> hallData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/clan-admin/halls'),
        headers: await _headers,
        body: json.encode(hallData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في إنشاء القاعة');
      }
    } catch (e) {
      throw Exception('خطأ في إنشاء القاعة: $e');
    }
  }

  static Future<void> deleteHall(int hallId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/clan-admin/hall/$hallId'),
        headers: await _headers,
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في حذف القاعة');
      }
    } catch (e) {
      throw Exception('خطأ في حذف القاعة: $e');
    }
  }

// update hall 
  static Future<Map<String, dynamic>> updateHall(int hallId, Map<String, dynamic> hallData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/clan-admin/hall/$hallId'),
        headers: await _headers,
        body: json.encode(hallData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في تحديث القاعة');
      }
    } catch (e) {
      throw Exception('خطأ في تحديث القاعة: $e');
    }
  }
  // ==================== CLAN ADMIN SETTINGS ENDPOINTS ====================
  // Settings Management
  static Future<Map<String, dynamic>> getSettings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/clan-admin/settings'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل في تحميل الإعدادات');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }
// Settings Management
static Future<Map<String, dynamic>> getSettingsByClanId(String clanId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/clan-admin/setings/$clanId'),
      headers: await _headers,
    );
    print('------------- Settings response status: ${response.statusCode}');
    print('----------- Settings response body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('فشل في تحميل الإعدادات');
    }
  } catch (e) {
    throw Exception('خطأ في الاتصال: $e');
  }
}
  static Future<Map<String, dynamic>> updateSettings(int clanId, Map<String, dynamic> settingsData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/clan-admin/settings/$clanId'),
        headers: await _headers,
        body: json.encode(settingsData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في تحديث الإعدادات');
      }
    } catch (e) {
      throw Exception('خطأ في تحديث الإعدادات: $e');
    }
  }

  // ==================== RESERVATIONS ENDPOINTS ====================
  
  // // Create Reservation
  // static Future<Map<String, dynamic>> createReservation(Map<String, dynamic> reservationData) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$baseUrl/reservations/'),
  //       headers: await _headers,
  //       body: json.encode(reservationData),
  //     );

  //     if (response.statusCode == 200) {
  //       return json.decode(response.body);
  //     } else {
  //       final error = json.decode(response.body);
  //       throw Exception(error['detail'] ?? 'فشل في إنشاء الحجز');
  //     }
  //   } catch (e) {
  //     throw Exception('خطأ في إنشاء الحجز: $e');
  //   }
  // }

  // // Download PDF
  // static Future<dynamic> downloadPdf(int reservationId) async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/reservations/download/$reservationId'),
  //       headers: await _headers,
  //     );

  //     if (response.statusCode == 200) {
  //       return response.bodyBytes;
  //     } else {
  //       final error = json.decode(response.body);
  //       throw Exception(error['detail'] ?? 'فشل في تحميل الملف');
  //     }
  //   } catch (e) {
  //     throw Exception('خطأ في تحميل الملف: $e');
  //   }
  // }

// In api_service.dart

// static Future<void> markPaymentCompleted(int groomId) async {
//   final url = Uri.parse('$baseUrl/clan_admin/reservations/payment_update/$groomId');
  
//   final response = await http.patch(
//     url,
//     headers: await_headers,
//   );

//   if (response.statusCode != 200) {
//     throw Exception('فشل في تأكيد الدفع: ${response.body}');
//   }
// }
// ==================== RESERVATION PAYMENT UPDATE ENDPOINT ====================

/// Update payment status for a groom's reservation
/// Toggles between pending_validation and validated status
/// PUT /reservations/payment_update/{groom_id}
static Future<Map<String, dynamic>> markPaymentCompleted(int groomId) async {
  try {
    final response = await http.put(
      Uri.parse('$baseUrl/clan-admin/reservations/payment_update/$groomId'),
      headers: await _headers,
    );

    print('Update payment response status: ${response.statusCode}');
    print('Update payment response body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'العريس غير موجود أو ليس في عشيرتك');
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في تحديث حالة الدفع');
    }
  } catch (e) {
    throw Exception('خطأ في تحديث حالة الدفع: $e');
  }
}

// this route can change payment status from true to false or the opposite
static Future<Map<String, dynamic>> changePaymentStatus(int reservationId) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/clan-admin/$reservationId/change_payment_status'),
      headers: await _headers,
    );

    print('Change payment status response: ${response.statusCode}');
    print('Change payment status body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'لا يوجد حجز معلق أو مصدق عليه');
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في تغيير حالة الدفع');
    }
  } catch (e) {
    throw Exception('خطأ في تغيير حالة الدفع: $e');
  }
}


// static Future<Map<String, dynamic>> createReservation(Map<String, dynamic> reservationData) async {
//   try {
//     print('Sending reservation data: $reservationData');
    
//     final response = await http.post(
//       Uri.parse('$baseUrl/reservations'), // Make sure this matches your backend route
//       headers: await _headers,
//       body: json.encode(reservationData),
//     );

//     print('Response status code: ${response.statusCode}');
//     print('Response body: ${response.body}');
//     print('Response headers: await ${response.headers}');

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       // Check if response body is not empty
//       if (response.body.isEmpty) {
//         throw Exception('Server returned empty response');
//       }
      
//       try {
//         final responseData = json.decode(response.body) as Map<String, dynamic>;
//         return responseData;
//       } catch (jsonError) {
//         print('JSON parsing error: $jsonError');
//         print('Raw response body: "${response.body}"');
//         throw FormatException('Invalid JSON response from server: $jsonError');
//       }
//     } else {
//       // Handle HTTP errors
//       String errorMessage = 'Server error (${response.statusCode})';
      
//       if (response.body.isNotEmpty) {
//         try {
//           final errorData = json.decode(response.body);
//           errorMessage = errorData['detail'] ?? errorData['message'] ?? errorMessage;
//         } catch (e) {
//           // If error response is not JSON, use the raw body
//           errorMessage = response.body.length > 200 
//               ? response.body.substring(0, 200) + '...'
//               : response.body;
//         }
//       }
      
//       throw Exception(errorMessage);
//     }
//   } catch (e) {
//     print('Error in createReservation: $e');
    
//     // Re-throw with more context if it's a FormatException
//     if (e is FormatException) {
//       throw FormatException('Failed to parse server response: ${e.message}');
//     }
    
//     rethrow;
//   }
// }


// ==================== UPDATED CREATE RESERVATION METHOD ====================
// Replace your existing createReservation method with this updated version

/// Create a new reservation and automatically notify the clan admin
/// POST /reservations
static Future<Map<String, dynamic>> createReservation(Map<String, dynamic> reservationData) async {
  try {
    print('Sending reservation data: $reservationData');
    
    final response = await http.post(
      Uri.parse('$baseUrl/reservations'),
      headers: await _headers,
      body: json.encode(reservationData),
    );

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    print('Response headers: ${response.headers}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Check if response body is not empty
      if (response.body.isEmpty) {
        throw Exception('Server returned empty response');
      }
      
      try {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        
        // ✅ AUTOMATICALLY NOTIFY CLAN ADMIN
        if (responseData.containsKey('id')) {
          final reservationId = responseData['id'] as int;
          
          print('🔔 Reservation created successfully with ID: $reservationId');
          print('📨 Fetching and notifying clan admin...');
          
          // Notify clan admin in background (don't block the UI)
          notifyClanAdminOfNewReservation(reservationId).then((success) {
            if (success) {
              print('✅ Clan admin notification sent successfully');
            } else {
              print('⚠️ Failed to send notification to clan admin');
            }
          }).catchError((error) {
            print('❌ Error sending notification: $error');
          });
        }
        
        return responseData;
      } catch (jsonError) {
        print('JSON parsing error: $jsonError');
        print('Raw response body: "${response.body}"');
        throw FormatException('Invalid JSON response from server: $jsonError');
      }
    } else {
      // Handle HTTP errors
      String errorMessage = 'Server error (${response.statusCode})';
      
      if (response.body.isNotEmpty) {
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['detail'] ?? errorData['message'] ?? errorMessage;
        } catch (e) {
          // If error response is not JSON, use the raw body
          errorMessage = response.body.length > 200 
              ? response.body.substring(0, 200) + '...'
              : response.body;
        }
      }
      
      throw Exception(errorMessage);
    }
  } catch (e) {
    print('Error in createReservation: $e');
    
    // Re-throw with more context if it's a FormatException
    if (e is FormatException) {
      throw FormatException('Failed to parse server response: ${e.message}');
    }
    
    rethrow;
  }
}

// ==================== ALTERNATIVE: SYNCHRONOUS VERSION ====================
// If you want to WAIT for the notification to be sent before returning

/// Create a new reservation and wait for notification confirmation
/// POST /reservations
static Future<Map<String, dynamic>> createReservationWithNotification(
  Map<String, dynamic> reservationData
) async {
  try {
    print('Sending reservation data: $reservationData');
    
    final response = await http.post(
      Uri.parse('$baseUrl/reservations'),
      headers: await _headers,
      body: json.encode(reservationData),
    );

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isEmpty) {
        throw Exception('Server returned empty response');
      }
      
      try {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        
        // ✅ WAIT FOR NOTIFICATION TO BE SENT
        if (responseData.containsKey('id')) {
          final reservationId = responseData['id'] as int;
          
          print('🔔 Reservation created successfully with ID: $reservationId');
          print('📨 Sending notification to clan admin...');
          
          // Wait for notification to be sent
          final notificationSent = await notifyClanAdminOfNewReservation(reservationId);
          
          if (notificationSent) {
            print('✅ Clan admin notification sent successfully');
            responseData['notification_sent'] = true;
          } else {
            print('⚠️ Failed to send notification to clan admin');
            responseData['notification_sent'] = false;
          }
        }
        
        return responseData;
      } catch (jsonError) {
        print('JSON parsing error: $jsonError');
        throw FormatException('Invalid JSON response from server: $jsonError');
      }
    } else {
      String errorMessage = 'Server error (${response.statusCode})';
      
      if (response.body.isNotEmpty) {
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['detail'] ?? errorData['message'] ?? errorMessage;
        } catch (e) {
          errorMessage = response.body.length > 200 
              ? response.body.substring(0, 200) + '...'
              : response.body;
        }
      }
      
      throw Exception(errorMessage);
    }
  } catch (e) {
    print('Error in createReservationWithNotification: $e');
    
    if (e is FormatException) {
      throw FormatException('Failed to parse server response: ${e.message}');
    }
    
    rethrow;
  }
}

// ==================== BATCH RESERVATION WITH NOTIFICATIONS ====================

/// Create multiple reservations and notify clan admins
static Future<List<Map<String, dynamic>>> createReservationsBatch(
  List<Map<String, dynamic>> reservationsData
) async {
  final results = <Map<String, dynamic>>[];
  
  for (var i = 0; i < reservationsData.length; i++) {
    try {
      print('Creating reservation ${i + 1}/${reservationsData.length}...');
      
      final result = await createReservation(reservationsData[i]);
      results.add({
        'success': true,
        'data': result,
        'index': i,
      });
      
      // Small delay between requests
      if (i < reservationsData.length - 1) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } catch (e) {
      print('Failed to create reservation ${i + 1}: $e');
      results.add({
        'success': false,
        'error': e.toString(),
        'data': reservationsData[i],
        'index': i,
      });
    }
  }
  
  return results;
}

// ==================== NOTIFICATION STATUS CHECKING ====================

/// Check if notification was successfully sent for a reservation
static Future<bool> checkReservationNotificationStatus(int reservationId) async {
  try {
    final notification = await getLatestNotificationForReservation(reservationId);
    return notification != null;
  } catch (e) {
    print('Error checking notification status: $e');
    return false;
  }
}

/// Retry sending notification if it failed initially
static Future<bool> retryNotificationForReservation(int reservationId) async {
  try {
    print('🔄 Retrying notification for reservation $reservationId...');
    
    final success = await notifyClanAdminOfNewReservation(reservationId);
    
    if (success) {
      print('✅ Notification retry successful');
    } else {
      print('❌ Notification retry failed');
    }
    
    return success;
  } catch (e) {
    print('❌ Error during notification retry: $e');
    return false;
  }
}

// Download PDF from server
static Future<Uint8List> downloadPdfFromServer(int reservationId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/reservations/download/$reservationId'), // Replace with your actual URL
    headers: await _headers,

  );
  
  if (response.statusCode == 200) {
    return response.bodyBytes;
  } else {
    throw Exception('فشل في تحميل الملف من الخادم: ${response.statusCode}');
  }
}

  // Get My Reservations
  static Future<List<dynamic>> getMyAllReservations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservations/reservations/my_all_reservations'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل في تحميل الحجوزات');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<Map<String, dynamic>> getMyPendingReservation() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservations/reservations/my_pending_reservation'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل في تحميل الحجز المعلق');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<Map<String, dynamic>> getMyValidatedReservation() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservations/reservations/my_validated_reservation'),
        headers: await _headers,
      );
 
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل في تحميل الحجز المؤكد');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<List<dynamic>> getMyCancelledReservations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservations/reservations/my_cancelled_reservation'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل في تحميل الحجوزات الملغاة');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // Reservation Actions
  static Future<Map<String, dynamic>> cancelMyReservation(int groomId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reservations/reservations/$groomId/cancel'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في إلغاء الحجز');
      }
    } catch (e) {
      throw Exception('خطأ في إلغاء الحجز: $e');
    }
  }

  static Future<Map<String, dynamic>> validateReservation(int groomId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reservations/$groomId/validate'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في تأكيد الحجز');
      }
    } catch (e) {
      throw Exception('خطأ في تأكيد الحجز: $e');
    }
  }

  //delete a reservation by reservationid 
  static Future<void> deleteReservation(int reservationId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/delete_res/$reservationId'),
        headers: await _headers,
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في حذف الحجز');
      }
    } catch (e) {
      throw Exception('خطأ في حذف الحجز: $e');
    }
  }


  static Future<Map<String, dynamic>> cancelGroomReservationByClanAdmin(int groomId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reservations/$groomId/cancel_by_clan_admin'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في إلغاء الحجز');
      }
    } catch (e) {
      throw Exception('خطأ في إلغاء الحجز: $e');
    }
  }

  // List Clan Reservations
  static Future<List<dynamic>> getAllReservations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservations/all_reservations'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل في تحميل الحجوزات');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // List All Reservations for Clan Admin (for export)
static Future<List<dynamic>> getAllReservationsClanAdmin() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/reservations/clan_admin/all_reservations'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 403) {
      throw Exception('غير مصرح لك بالوصول إلى هذه البيانات');
    } else {
      throw Exception('فشل في تحميل الحجوزات: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('خطأ في الاتصال: $e');
  }
}

  static Future<List<dynamic>> getPendingReservations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservations/pending_reservations'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل في تحميل الحجوزات المعلقة');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<List<dynamic>> getValidatedReservations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservations/validated_reservations'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل في تحميل الحجوزات المؤكدة');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<List<dynamic>> getCancelledReservations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservations/cancled_reservations'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل في تحميل الحجوزات الملغاة');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

// Updated ApiService methods to match your backend endpoints



  // ==================== GROOM ENDPOINTS ====================
  
  // Profile Management
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/groom/profile'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل في تحميل الملف الشخصي');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> userData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/groom/profile'),
        headers: await _headers,
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في تحديث الملف الشخصي');
      }
    } catch (e) {
      throw Exception('خطأ في تحديث الملف الشخصي: $e');
    }
  }

  static Future<void> deleteProfile() async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/groom/profile'),
        headers: await _headers,
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في حذف الملف الشخصي');
      }
    } catch (e) {
      throw Exception('خطأ في حذف الملف الشخصي: $e');
    }
  }

  // Groom Data Access
  static Future<List<dynamic>> getGroomHalls() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/groom/halls'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل في تحميل القاعات');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // Get Counties (public endpoint for groom)
  static Future<List<County>> getCounties() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/groom/counties'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => County.fromJson(json)).toList();
      } else {
        throw Exception('فشل في تحميل البلديات');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // Get Clans for Groom
  static Future<List<Clan>> getClans() async {
    try {
      final response = await http.get(
        // Uri.parse('$baseUrl/super-admin/all_clans'),
        Uri.parse('$baseUrl/groom/clans'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Clan.fromJson(json)).toList();
      } else {
        throw Exception('3فشل في تحميل العشائر');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // static Future<List<dynamic>> getGroomHaia() async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/groom/haia'),
  //       headers: await _headers,
  //     );

  //     if (response.statusCode == 200) {
  //       return json.decode(response.body);
  //     } else {
  //       throw Exception('فشل في تحميل لجان الهاية');
  //     }
  //   } catch (e) {
  //     throw Exception('خطأ في الاتصال: $e');
  //   }
  // }

  // static Future<List<dynamic>> getGroomMadaihCommittee() async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/groom/madaih_committe'),
  //       headers: await _headers,
  //     );

  //     if (response.statusCode == 200) {
  //       return json.decode(response.body);
  //     } else {
  //       throw Exception('فشل في تحميل لجان المدائح');
  //     }
  //   } catch (e) {
  //     throw Exception('خطأ في الاتصال: $e');
  //   }
  // }
static Future<List<dynamic>> getGroomHaia() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/groom/haia'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      // Ensure we always return a List
      if (decoded is List) {
        return decoded;
      } else if (decoded is Map) {
        // If it's a single object, wrap it in a list
        return [decoded];
      } else {
        // If it's something else, return empty list
        return [];
      }
    } else {
      throw Exception('فشل في تحميل لجان الهاية: ${response.statusCode}');
    }
  } catch (e) {
    print('Error in getGroomHaia: $e'); // Add logging
    throw Exception('خطأ في الاتصال: $e');
  }
}

static Future<List<dynamic>> getGroomMadaihCommittee() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/groom/madaih_committe'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      // Ensure we always return a List
      if (decoded is List) {
        return decoded;
      } else if (decoded is Map) {
        // If it's a single object, wrap it in a list
        return [decoded];
      } else {
        // If it's something else, return empty list
        return [];
      }
    } else {
      throw Exception('فشل في تحميل لجان المدائح: ${response.statusCode}');
    }
  } catch (e) {
    print('Error in getGroomMadaihCommittee: $e'); // Add logging
    throw Exception('خطأ في الاتصال: $e');
  }
}
  static Future<List<dynamic>> getGroomRules() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/groom/rules'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل في تحميل القوانين');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // ==================== FOOD MANAGEMENT ENDPOINTS ====================
  // ==================== FOOD MENU ENDPOINTS ====================


// Get Menu Details by ID
static Future<Map<String, dynamic>> getFoodMenuDetails(int menuId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/clan-admin/menu-details/$menuId'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في الحصول على تفاصيل القائمة');
    }
  } catch (e) {
    throw Exception('خطأ في الحصول على تفاصيل القائمة: $e');
  }
}

// List Food Menus (you'll need to add this endpoint to your Python backend)
static Future<List<FoodMenu>> listFoodMenus() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/clan-admin/menus'),
      headers: await _headers,
    ); 

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => FoodMenu.fromJson(json)).toList();
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في تحميل قوائم الطعام');
    }
  } catch (e) {
    throw Exception('خطأ في تحميل قوائم الطعام: $e');
  }
}

  // Get Food Types
  static Future<dynamic> getFoodTypes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/food/menu/food_types'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل في تحميل أنواع الطعام');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // Get Visitor Options
  static Future<dynamic> getVisitorOptions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/food/menu/visitor_options'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل في تحميل خيارات الزوار');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // Get Filtered Menu
  static Future<List<dynamic>> getFilteredMenu(String foodType, int visitors, int clanId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/food/menu/$foodType/$visitors/$clanId'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل في تحميل القائمة');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // Get Clan Menus
  static Future<List<dynamic>> getClanMenus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/food/my_menus'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل في تحميل القوائم');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // Create Food Menu
  static Future<Map<String, dynamic>> createFoodMenu(Map<String, dynamic> menuData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/food/menu'),
        headers: await _headers,
        body: json.encode(menuData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في إنشاء القائمة');
      }
    } catch (e) {
      throw Exception('خطأ في إنشاء القائمة: $e');
    }
  }

  // Get Menu Details
  static Future<Map<String, dynamic>> getMenuDetails(int menuId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/food/menu-details/$menuId'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل في تحميل تفاصيل القائمة');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // Update Food Menu
  static Future<Map<String, dynamic>> updateFoodMenu(int menuId, Map<String, dynamic> menuData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/food/menu/$menuId'),
        headers: await _headers,
        body: json.encode(menuData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في تحديث القائمة');
      }
    } catch (e) {
      throw Exception('خطأ في تحديث القائمة: $e');
    }
  }

  // Delete Food Menu
  static Future<void> deleteFoodMenu(int menuId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/food/menu/$menuId'),
        headers: await _headers,
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في حذف القائمة');
      }
    } catch (e) {
      throw Exception('خطأ في حذف القائمة: $e');
    }
  }
// Get unique food types from existing menus
static Future<List<String>> getUniqueFoodTypes() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/food/menu/unique-food-types'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return List<String>.from(data);
    } else {
      throw Exception('فشل في تحميل أنواع الطعام');
    }
  } catch (e) {
    throw Exception('خطأ في الاتصال: $e');
  }
}

// Get unique visitor counts from existing menus
static Future<List<int>> getUniqueVisitorCounts() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/food/menu/unique-visitor-counts'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return List<int>.from(data);
    } else {
      throw Exception('فشل في تحميل أعداد الزوار');
    }
  } catch (e) {
    throw Exception('خطأ في الاتصال: $e');
  }
}
  // ==================== LEGACY METHODS (for backward compatibility) ====================
  
// ==================== LEGACY METHODS (for backward compatibility) ====================
  
  // Keep the old method names for backward compatibility
  static Future<void> deletUserr(String phone) async {
    // Convert string phone to int and call the new method
    try {
      await deleteUser(phone);
    } catch (e) {
      throw Exception('رقم الهاتف غير صحيح: $e');
    }
  }


  // Legacy method for getting user info (alternative name)
  static Future<Map<String, dynamic>> getUserInfo() async {
    return await getCurrentUserInfo();
  }

  // Legacy method for groom registration (alternative parameters)
  static Future<Map<String, dynamic>> registerGroomLegacy({
    required String phoneNumber,
    required String firstName,
    required String lastName,
    required String fatherName,
    required String grandfatherName,
    required String password,
    required int clanId,
    required int countyId,
    String? birthDate,
    String? birthAddress,
    String? homeAddress,
    String? guardianName,
    String? guardianPhone,
    String? guardianRelation,
  }) async {
    final userData = {
      'phone_number': phoneNumber,
      'first_name': firstName,
      'last_name': lastName,
      'father_name': fatherName,
      'grandfather_name': grandfatherName,
      'password': password,
      'clan_id': clanId,
      'county_id': countyId,
      'role': 'groom',
    };

    // Add optional fields if provided
    if (birthDate != null) userData['birth_date'] = birthDate;
    if (birthAddress != null) userData['birth_address'] = birthAddress;
    if (homeAddress != null) userData['home_address'] = homeAddress;
    if (guardianName != null) userData['guardian_name'] = guardianName;
    if (guardianPhone != null) userData['guardian_phone'] = guardianPhone;
    if (guardianRelation != null) userData['guardian_relation'] = guardianRelation;

    return await registerGroom(userData);
  }

  // ==================== ADDITIONAL UTILITY METHODS ====================
  
  // Check if user is authenticated
  static bool isAuthenticated() {
    return _token != null && _token!.isNotEmpty;
  }

  // Get current token
  static String? getToken() {
    return _token;
  }

  // Refresh token if needed (placeholder for future implementation)
  static Future<bool> refreshToken() async {
    // This would be implemented when refresh token functionality is added to the API
    // For now, return false to indicate refresh is not available
    return false;
  }

  // Generic error handler for API responses
  static String handleApiError(dynamic error) {
    if (error is Map<String, dynamic>) {
      // Handle validation errors
      if (error.containsKey('detail') && error['detail'] is List) {
        List<dynamic> details = error['detail'];
        if (details.isNotEmpty && details[0] is Map<String, dynamic>) {
          String field = details[0]['loc']?.last ?? 'unknown';
          String message = details[0]['msg'] ?? 'خطأ في التحقق';
          return 'خطأ في $field: $message';
        }
      }
      // Handle single error message
      if (error.containsKey('detail') && error['detail'] is String) {
        return error['detail'];
      }
    }
    return 'حدث خطأ غير متوقع';
  }

  // Batch operations for efficiency
  static Future<List<Map<String, dynamic>>> batchCreateClans(List<Map<String, dynamic>> clansData) async {
    List<Map<String, dynamic>> results = [];
    for (var clanData in clansData) {
      try {
        final result = await createClan(clanData);
        results.add(result);
      } catch (e) {
        results.add({'error': e.toString(), 'data': clanData});
      }
    }
    return results;
  }

  static Future<List<Map<String, dynamic>>> batchCreateClanAdmins(List<Map<String, dynamic>> adminsData) async {
    List<Map<String, dynamic>> results = [];
    for (var adminData in adminsData) {
      try {
        final result = await createClanAdmin(adminData);
        results.add(result);
      } catch (e) {
        results.add({'error': e.toString(), 'data': adminData});
      }
    }
    return results;
  }

  // ==================== SEARCH AND FILTER METHODS ====================
  
  // Search methods for better user experience
  static Future<List<County>> searchCounties(String query) async {
    final counties = await getCounties();
    return counties.where((county) => 
      county.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  static Future<List<Clan>> searchClans(String query) async {
    final clans = await getClans();
    return clans.where((clan) => 
      clan.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  static Future<List<dynamic>> searchReservations(String query, List<dynamic> reservations) async {
    return reservations.where((reservation) {
      final guardianName = reservation['guardian_name']?.toLowerCase() ?? '';
      final fatherName = reservation['father_name']?.toLowerCase() ?? '';
      final phoneNumber = reservation['phone_number']?.toLowerCase() ?? '';
      final queryLower = query.toLowerCase();
      
      return guardianName.contains(queryLower) || 
             fatherName.contains(queryLower) || 
             phoneNumber.contains(queryLower);
    }).toList();
  }

  // ==================== VALIDATION HELPERS ====================
  
  // Phone number validation
  static bool isValidPhoneNumber(String phone) {
    // Iraqi phone number validation (example pattern)
    final phoneRegex = RegExp(r'^(964|0)?7[3-9]\d{8}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[^\d]'), ''));
  }

  // Date validation helpers
  static bool isValidDate(String dateString) {
    try {
      DateTime.parse(dateString);
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool isDateInFuture(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return date.isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  // ==================== CACHING METHODS ====================
  
  // Simple in-memory cache for frequently accessed data
  static final Map<String, dynamic> _cache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheTimeout = Duration(minutes: 5);

  static T? getCachedData<T>(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp != null && 
        DateTime.now().difference(timestamp) < _cacheTimeout &&
        _cache.containsKey(key)) {
      return _cache[key] as T?;
    }
    return null;
  }

  static void setCachedData<T>(String key, T data) {
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
  }

  static void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  static void removeCachedData(String key) {
    _cache.remove(key);
    _cacheTimestamps.remove(key);
  }

  // Cached versions of frequently used methods
  static Future<List<County>> getCountiesCached() async {
    const cacheKey = 'counties';
    final cached = getCachedData<List<County>>(cacheKey);
    if (cached != null) return cached;

    final counties = await getCounties();
    setCachedData(cacheKey, counties);
    return counties;
  }

  static Future<List<Clan>> getClansCached() async {
    const cacheKey = 'clans';
    final cached = getCachedData<List<Clan>>(cacheKey);
    if (cached != null) return cached;

    final clans = await getClans();
    setCachedData(cacheKey, clans);
    return clans;
  }

  // ==================== STATISTICS AND ANALYTICS METHODS ====================
  
  // Get reservation reservations
  static Future<Map<String, int>> getReservationStats() async {
    try {
      final allReservations = await getAllReservations();
      final pending = await getPendingReservations();
      final validated = await getValidatedReservations();
      final cancelled = await getCancelledReservations();

      return {
        'total': allReservations.length,
        'pending': pending.length,
        'validated': validated.length,
        'cancelled': cancelled.length,
      };
    } catch (e) {
      throw Exception('خطأ في الحصول على الإحصائيات: $e');
    }
  }

  // Get clan reservations
  static Future<Map<String, dynamic>> getClanStats(int clanId) async {
    try {
      // This would need specific endpoints on the backend
      // For now, we'll calculate from existing data
      final grooms = await listGrooms();
      final halls = await listHalls();
      final menus = await getClanMenus();

      return {
        'total_grooms': grooms.length,
        'total_halls': halls.length,
        'total_menus': menus.length,
        'clan_id': clanId,
      };
    } catch (e) {
      throw Exception('خطأ في الحصول على إحصائيات العشيرة: $e');
    }
  }

  // ==================== EXPORT/IMPORT METHODS ====================
  
  // Export data methods (would return data in a format suitable for export)
  static Future<Map<String, dynamic>> exportReservationsData() async {
    try {
      final reservations = await getAllReservations();
      return {
        'export_date': DateTime.now().toIso8601String(),
        'total_count': reservations.length,
        'reservations': reservations,
      };
    } catch (e) {
      throw Exception('خطأ في تصدير البيانات: $e');
    }
  }

  static Future<Map<String, dynamic>> exportClanData() async {
    try {
      final clans = await getAllClans();
      return {
        'export_date': DateTime.now().toIso8601String(),
        'total_count': clans.length,
        'clans': clans.map((clan) => clan.toJson()).toList(),
      };
    } catch (e) {
      throw Exception('خطأ في تصدير بيانات العشائر: $e');
    }
  }
  
  // ==================== NOTIFICATION HELPERS ====================
  
  // Helper methods for handling different types of API responses
  static Map<String, dynamic> parseSuccessResponse(Map<String, dynamic> response) {
    return {
      'success': true,
      'message': response['message'] ?? 'العملية تمت بنجاح',
      'data': response,
    };
  }

  static Map<String, dynamic> parseErrorResponse(String error) {
    return {
      'success': false,
      'message': error,
      'data': null,
    };
  }

  // ==================== CONNECTION HELPERS ====================
  
  // Check API connectivity
  static Future<bool> checkApiConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/groom/counties'),
        headers: await {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get API health status
  static Future<Map<String, dynamic>> getApiHealth() async {
    try {
      final startTime = DateTime.now();
      final isConnected = await checkApiConnection();
      final endTime = DateTime.now();
      final responseTime = endTime.difference(startTime).inMilliseconds;

      return {
        'status': isConnected ? 'healthy' : 'unhealthy',
        'response_time_ms': responseTime,
        'timestamp': DateTime.now().toIso8601String(),
        'base_url': baseUrl,
      };
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
        'base_url': baseUrl,
      };
    }
  }

 ///////public routes////////////////
  // Get clans by county
  static Future<List<dynamic>> getClansByCounty(int countyId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/public/clans/by-county/$countyId'),
        headers: await _headers,
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في تحميل العشائر');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // Get halls by clan ID
  static Future<List<dynamic>> getHallsByClan(int clanId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/public/halls/by-clan/$clanId'),
        headers: await _headers,
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'فشل في تحميل القاعات');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // Change your getCounty method from:
// static Future<List<dynamic>> getCounty(int countyId) async {

// To:
static Future<Map<String, dynamic>> getCounty(int countyId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/public/county/$countyId'), // or whatever your endpoint is
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else {
        throw Exception('استجابة غير متوقعة من الخادم');
      }
    } else {
      throw Exception('فشل في تحميل المحافظة: ${response.statusCode}');
    }
  } catch (e) {
    print('Error in getCounty: $e');
    throw Exception('خطأ في الاتصال: $e');
  }
}

// static Future<List<dynamic>> getCounty(int countyId) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/public/county/$countyId'),
//         headers: await _headers,
//       );
      
//       if (response.statusCode == 200) {
//         return json.decode(response.body) as List<dynamic>;
//       } else {
//         final error = json.decode(response.body);
//         throw Exception(error['detail'] ?? 'فشل في تحميل القصور');
//       }
//     } catch (e) {
//       throw Exception('خطأ في الاتصال: $e');
//     }
//   }
// Add these methods to your ApiService class in lib/services/api_service.dart

// ==================== CALENDAR AVAILABILITY ENDPOINTS ====================
// Add these methods to your ApiService class in lib/services/api_service.dart
// Add these methods to your ApiService class in lib/services/api_service.dart
// Place them in the RESERVATIONS ENDPOINTS section

// ==================== CALENDAR RESERVATION ENDPOINTS ====================
// ==================== CALENDAR RESERVATION ENDPOINTS ====================

// Get all dates with validated reservations for a specific clan
static Future<List<dynamic>> getValidatedDates(int clanId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/reservations/validated-dates/$clanId'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في تحميل التواريخ المؤكدة');
    }
  } catch (e) {
    throw Exception('خطأ في تحميل التواريخ المؤكدة: $e');
  }
}

// Get all dates with pending_validation reservations for a specific clan  
static Future<List<dynamic>> getPendingDates(int clanId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/reservations/pending-dates/$clanId'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في تحميل التواريخ المعلقة');
    }
  } catch (e) {
    throw Exception('خطأ في تحميل التواريخ المعلقة: $e');
  }
}



// Add this method to your ApiService class in the AUTH ENDPOINTS section

// Get OTP Code for Admin
static Future<String> getOtpCode(String phoneNumber) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/get_otp/$phoneNumber'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['otp_code'];
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في الحصول على رمز التحقق');
    }
  } catch (e) {
    throw Exception('خطأ في الحصول على رمز التحقق: $e');
  }
}
// Get OTP Code for Admin
static Future<String> getOtpCodeClanAdmin(String phoneNumber) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/clan_admin/get_otp/$phoneNumber'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['otp_code'];
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في الحصول على رمز التحقق');
    }
  } catch (e) {
    throw Exception('خطأ في الحصول على رمز التحقق: $e');
  }
}

// ==================== GROOM STATUS MANAGEMENT ENDPOINTS ====================

// Update Groom Status (active/inactive)
static Future<Map<String, dynamic>> updateGroomStatus(
  String phoneNumber, 
  String status
) async {
  try {
    final response = await http.put(
      Uri.parse('$baseUrl/clan-admin/grooms/$phoneNumber/status'),
      headers: await _headers,
      body: json.encode({
        'status': status, // "active" or "inactive"
      }),
    );
  
    print('Update groom status response: ${response.statusCode}');
    print('Update groom status body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في تحديث حالة العريس');
    }
  } catch (e) {
    throw Exception('خطأ في تحديث حالة العريس: $e');
  }
}

// Get Current Groom Status
static Future<Map<String, dynamic>> getGroomStatus(String phoneNumber) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/clan-admin/grooms/$phoneNumber/status'),
      headers: await _headers,
    );

    print('Get groom status response: ${response.statusCode}');
    print('Get groom status body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في الحصول على حالة العريس');
    }
  } catch (e) {
    throw Exception('خطأ في الحصول على حالة العريس: $e');
  }
}

// Add this method to your ApiService class in the CLAN ADMIN ENDPOINTS section

// Update Groom Information
static Future<Map<String, dynamic>> updateGroom(int groomId, Map<String, dynamic> updateData) async {
  try {
    final response = await http.put(
      Uri.parse('$baseUrl/auth/update-groom/$groomId'),
      headers: await _headers,
      body: json.encode(updateData),
    );

    print('Update groom response status: ${response.statusCode}');
    print('Update groom response body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في تحديث معلومات العريس');
    }
  } catch (e) {
    throw Exception('خطأ في تحديث معلومات العريس: $e');
  }
}

// Update Groom Information with specific parameters (convenience method)
static Future<Map<String, dynamic>> updateGroomDetails(
  int groomId, {
  String? firstName,
  String? lastName,
  String? fatherName,
  String? grandfatherName,
  String? birthDate,
  String? birthAddress,
  String? homeAddress,
  String? phoneNumber,
  String? guardianName,
  String? guardianPhone,
  String? guardianHomeAddress,
  String? guardianBirthAddress,
  String? guardianBirthDate,
  String? guardianRelation,
  String? status,
}) async {
  final Map<String, dynamic> updateData = {};

  // Only add non-null fields to the update request
  if (firstName != null) updateData['first_name'] = firstName;
  if (lastName != null) updateData['last_name'] = lastName;
  if (fatherName != null) updateData['father_name'] = fatherName;
  if (grandfatherName != null) updateData['grandfather_name'] = grandfatherName;
  if (birthDate != null) updateData['birth_date'] = birthDate;
  if (birthAddress != null) updateData['birth_address'] = birthAddress;
  if (homeAddress != null) updateData['home_address'] = homeAddress;
  if (phoneNumber != null) updateData['phone_number'] = phoneNumber;
  if (guardianName != null) updateData['guardian_name'] = guardianName;
  if (guardianPhone != null) updateData['guardian_phone'] = guardianPhone;
  if (guardianHomeAddress != null) updateData['guardian_home_address'] = guardianHomeAddress;
  if (guardianBirthAddress != null) updateData['guardian_birth_address'] = guardianBirthAddress;
  if (guardianBirthDate != null) updateData['guardian_birth_date'] = guardianBirthDate;
  if (guardianRelation != null) updateData['guardian_relation'] = guardianRelation;
  if (status != null) updateData['status'] = status;

  return await updateGroom(groomId, updateData);
}










// ==================== PDF GENERATION AND DOWNLOAD ENDPOINTS ====================

/// Generate PDF for a specific reservation
/// Can be called independently after reservation creation
static Future<Map<String, dynamic>> generatePdf(int reservationId) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/pdf/generate/$reservationId'),
      headers: await _headers,
    );

    print('Generate PDF response status: ${response.statusCode}');
    print('Generate PDF response body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في إنشاء ملف PDF');
    }
  } catch (e) {
    throw Exception('خطأ في إنشاء ملف PDF: $e');
  }
}

/// Force regenerate PDF for a specific reservation (overwrites existing)
/// Useful for updates or fixes
static Future<Map<String, dynamic>> regeneratePdf(int reservationId) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/pdf/regenerate/$reservationId'),
      headers: await _headers,
    );

    print('Regenerate PDF response status: ${response.statusCode}');
    print('Regenerate PDF response body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في إعادة إنشاء ملف PDF');
    }
  } catch (e) {
    throw Exception('خطأ في إعادة إنشاء ملف PDF: $e');
  }
}

/// Download PDF for a specific reservation
/// Accessible by groom or clan admin
/// Returns the PDF file as bytes
static Future<Uint8List> downloadPdf(int reservationId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/pdf/download/$reservationId'),
      headers: await _headers,
    );

    print('Download PDF response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في تحميل ملف PDF');
    }
  } catch (e) {
    throw Exception('خطأ في تحميل ملف PDF: $e');
  }
}

/// Check if PDF exists for a reservation
/// Returns status information about the PDF
/// Returns status information about the PDF
static Future<Map<String, dynamic>> checkPdfStatus(int reservationId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/pdf/status/$reservationId'),
      headers: await _headers,
    );

    print('Check PDF status response: ${response.statusCode}');
    print('Check PDF status body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'reservation_id': data['reservation_id'],
        'pdf_exists': data['pdf_exists'] ?? false,
        'pdf_url': data['pdf_url'],
      };
    } else if (response.statusCode == 404) {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'الحجز غير موجود');
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في التحقق من حالة PDF');
    }
  } catch (e) {
    if (e is Exception) rethrow;
    throw Exception('خطأ في التحقق من حالة PDF: $e');
  }
}

// ==================== PDF CONVENIENCE METHODS ====================

/// Generate PDF and wait for completion
/// Returns the PDF URL if successful
static Future<String?> generateAndGetPdfUrl(int reservationId) async {
  try {
    final result = await generatePdf(reservationId);
    return result['pdf_url'] as String?;
  } catch (e) {
    print('Error in generateAndGetPdfUrl: $e');
    return null;
  }
}

/// Check if PDF exists and download it if available
/// Returns null if PDF doesn't exist
static Future<Uint8List?> downloadPdfIfExists(int reservationId) async {
  try {
    // First check if PDF exists
    final status = await checkPdfStatus(reservationId);
    
    if (status['pdf_exists'] == true) {
      // PDF exists, download it
      return await downloadPdf(reservationId);
    } else {
      // PDF doesn't exist
      return null;
    }
  } catch (e) {
    print('Error in downloadPdfIfExists: $e');
    return null;
  }
}

/// Generate PDF if it doesn't exist, then download it
/// This is a complete flow method
static Future<Uint8List?> ensurePdfAndDownload(int reservationId) async {
  try {
    // Check if PDF exists
    final status = await checkPdfStatus(reservationId);
    
    if (status['pdf_exists'] != true) {
      // Generate PDF if it doesn't exist
      print('PDF does not exist, generating...');
      await generatePdf(reservationId);
      
      // Wait a bit for generation to complete
      await Future.delayed(const Duration(seconds: 2));
    }
    
    // Download the PDF
    return await downloadPdf(reservationId);
  } catch (e) {
    print('Error in ensurePdfAndDownload: $e');
    throw Exception('فشل في إنشاء أو تحميل PDF: $e');
  }
}

/// Regenerate PDF and download the new version
/// Useful when reservation data has been updated
static Future<Uint8List> regenerateAndDownloadPdf(int reservationId) async {
  try {
    // Regenerate the PDF
    print('Regenerating PDF...');
    await regeneratePdf(reservationId);
    
    // Wait a bit for regeneration to complete
    await Future.delayed(const Duration(seconds: 2));
    
    // Download the new PDF
    return await downloadPdf(reservationId);
  } catch (e) {
    print('Error in regenerateAndDownloadPdf: $e');
    throw Exception('فشل في إعادة إنشاء وتحميل PDF: $e');
  }
}

/// Save PDF to device storage
/// Returns the file path if successful
static Future<String?> savePdfToDevice(
  int reservationId, 
  Uint8List pdfBytes,
  String fileName,
) async {
  try {
    // This is a placeholder - actual implementation depends on your file storage strategy
    // You might use path_provider and file system APIs here
    
    // Example implementation would be:
    // final directory = await getApplicationDocumentsDirectory();
    // final file = File('${directory.path}/$fileName');
    // await file.writeAsBytes(pdfBytes);
    // return file.path;
    
    print('Saving PDF with ${pdfBytes.length} bytes');
    print('This method needs to be implemented based on your storage strategy');
    
    return null; // Placeholder return
  } catch (e) {
    print('Error saving PDF: $e');
    throw Exception('فشل في حفظ ملف PDF: $e');
  }
}

/// Download and save PDF in one operation
// static Future<String?> downloadAndSavePdf(
//   int reservationId,
//   {String? customFileName}
// ) async {
//   try {
//     // Download the PDF
//     final pdfBytes = await downloadPdf(reservationId);
    
//     // Generate filename if not provided
//     final fileName = customFileName ?? 'reservation_$reservationId.pdf';
    
//     // Save to device
//     return await savePdfToDevice(reservationId, pdfBytes, fileName);
//   } catch (e) {
//     print('Error in downloadAndSavePdf: $e');
//     throw Exception('فشل في تحميل وحفظ PDF: $e');
//   }
// }

/// Check PDF generation status with retry
/// Useful when PDF generation might take time
static Future<bool> waitForPdfGeneration(
  int reservationId, {
  int maxRetries = 10,
  Duration retryDelay = const Duration(seconds: 2),
}) async {
  for (int i = 0; i < maxRetries; i++) {
    try {
      final status = await checkPdfStatus(reservationId);
      
      if (status['pdf_exists'] == true) {
        return true;
      }
      
      // Wait before next retry
      if (i < maxRetries - 1) {
        await Future.delayed(retryDelay);
      }
    } catch (e) {
      print('Retry $i failed: $e');
    }
  }
  
  return false;
}

/// Get PDF URL without downloading the file
static Future<String?> getPdfUrl(int reservationId) async {
  try {
    final status = await checkPdfStatus(reservationId);
    return status['pdf_url'] as String?;
  } catch (e) {
    print('Error getting PDF URL: $e');
    return null;
  }
}

/// Batch generate PDFs for multiple reservations
static Future<Map<int, bool>> batchGeneratePdfs(
  List<int> reservationIds,
) async {
  final results = <int, bool>{};
  
  for (final id in reservationIds) {
    try {
      await generatePdf(id);
      results[id] = true;
    } catch (e) {
      print('Failed to generate PDF for reservation $id: $e');
      results[id] = false;
    }
    
    // Small delay between requests to avoid overwhelming the server
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  return results;
}

/// Verify PDF generation completed successfully
static Future<bool> verifyPdfGeneration(int reservationId) async {
  try {
    final status = await checkPdfStatus(reservationId);
    return status['pdf_exists'] == true;
  } catch (e) {
    print('Error verifying PDF: $e');
    return false;
  }
}





// Add these methods to your ApiService class in lib/services/api_service.dart

// ==================== CLAN RULES ENDPOINTS ====================

// ==================== CLAN ADMIN - CRUD OPERATIONS ====================

/// Create new clan rules (Clan Admin only)
static Future<Map<String, dynamic>> createClanRules(Map<String, dynamic> rulesData) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/clan-admin/clan-rules'),
      headers: await _headers,
      body: json.encode(rulesData),
    );

    print('Create clan rules response status: ${response.statusCode}');
    print('Create clan rules response body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في إنشاء قوانين العشيرة');
    }
  } catch (e) {
    throw Exception('خطأ في إنشاء قوانين العشيرة: $e');
  }
}

/// Create clan rules with specific parameters (convenience method)
static Future<Map<String, dynamic>> createClanRulesWithDetails({
  required int clanId,
  required String generalRule,
  String? groomSupplies,
  String? ruleAboutClothing,
  String? ruleAboutKitchenware,
  String? rulesBookOfClanPdfs,
}) async {
  final rulesData = {
    'clan_id': clanId,
    'general_rule': generalRule,
  };

  // Add optional fields if provided
  if (groomSupplies != null && groomSupplies.isNotEmpty) {
    rulesData['groom_supplies'] = groomSupplies;
  }
  if (ruleAboutClothing != null && ruleAboutClothing.isNotEmpty) {
    rulesData['rule_about_clothing'] = ruleAboutClothing;
  }
  if (ruleAboutKitchenware != null && ruleAboutKitchenware.isNotEmpty) {
    rulesData['rule_about_kitchenware'] = ruleAboutKitchenware;
  }
  if (rulesBookOfClanPdfs != null && rulesBookOfClanPdfs.isNotEmpty) {
    rulesData['rules_book_of_clan_pdfs'] = rulesBookOfClanPdfs;
  }

  return await createClanRules(rulesData);
}

/// Get clan rules by rule ID (Clan Admin only)
static Future<Map<String, dynamic>> getClanRulesById(int ruleId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/clan-admin/clan-rules/$ruleId'),
      headers: await _headers,
    );

    print('Get clan rules by ID response status: ${response.statusCode}');
    print('Get clan rules by ID response body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'قوانين العشيرة غير موجودة');
    }
  } catch (e) {
    throw Exception('خطأ في جلب قوانين العشيرة: $e');
  }
}

/// Get clan rules by clan ID (Clan Admin only)
static Future<Map<String, dynamic>> getClanRulesByClanId(int clanId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/clan-admin/clan-rules/clan/$clanId'),
      headers: await _headers,
    );

    print('Get clan rules by clan ID response status: ${response.statusCode}');
    print('Get clan rules by clan ID response body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'لا توجد قوانين لهذه العشيرة');
    }
  } catch (e) {
    throw Exception('خطأ في جلب قوانين العشيرة: $e');
  }
}

/// Update clan rules (Clan Admin only)
static Future<Map<String, dynamic>> updateClanRules(
  int ruleId, 
  Map<String, dynamic> rulesData
) async {
  try {
    final response = await http.put(
      Uri.parse('$baseUrl/clan-admin/clan-rules/$ruleId'),
      headers: await _headers,
      body: json.encode(rulesData),
    );

    print('Update clan rules response status: ${response.statusCode}');
    print('Update clan rules response body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في تحديث قوانين العشيرة');
    }
  } catch (e) {
    throw Exception('خطأ في تحديث قوانين العشيرة: $e');
  }
}

/// Update clan rules with specific parameters (convenience method)
static Future<Map<String, dynamic>> updateClanRulesDetails(
  int ruleId, {
  String? generalRule,
  String? groomSupplies,
  String? ruleAboutClothing,
  String? ruleAboutKitchenware,
  String? rulesBookOfClanPdfs,
}) async {
  final Map<String, dynamic> rulesData = {};

  // Only add non-null fields to the update request
  if (generalRule != null) rulesData['general_rule'] = generalRule;
  if (groomSupplies != null) rulesData['groom_supplies'] = groomSupplies;
  if (ruleAboutClothing != null) rulesData['rule_about_clothing'] = ruleAboutClothing;
  if (ruleAboutKitchenware != null) rulesData['rule_about_kitchenware'] = ruleAboutKitchenware;
  if (rulesBookOfClanPdfs != null) rulesData['rules_book_of_clan_pdfs'] = rulesBookOfClanPdfs;

  if (rulesData.isEmpty) {
    throw Exception('لا توجد بيانات للتحديث');
  }

  return await updateClanRules(ruleId, rulesData);
}

/// Delete clan rules (Clan Admin only)
static Future<void> deleteClanRules(int ruleId) async {
  try {
    final response = await http.delete(
      Uri.parse('$baseUrl/clan-admin/clan-rules/$ruleId'),
      headers: await _headers,
    );

    print('Delete clan rules response status: ${response.statusCode}');
    print('Delete clan rules response body: ${response.body}');

    // Accept 204 No Content or 200 OK as success
    if (response.statusCode == 204 || response.statusCode == 200) {
      return;
    } else {
      String errorMessage = 'فشل في حذف قوانين العشيرة';
      
      if (response.body.isNotEmpty) {
        try {
          final error = json.decode(response.body);
          errorMessage = error['detail'] ?? errorMessage;
        } catch (e) {
          // If parsing fails, use default message
        }
      }
      
      throw Exception(errorMessage);
    }
  } catch (e) {
    throw Exception('خطأ في حذف قوانين العشيرة: $e');
  }
}

// ==================== GROOM - READ ONLY ACCESS ====================

/// Get clan rules for groom's clan (Read-only for grooms)
static Future<Map<String, dynamic>> getGroomClanRules() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/groom/clan-rules'),
      headers: await _headers,
    );

    print('Get groom clan rules response status: ${response.statusCode}');
    print('Get groom clan rules response body: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      // Handle both single object and list responses
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else if (decoded is List && decoded.isNotEmpty) {
        return decoded[0] as Map<String, dynamic>;
      } else {
        throw Exception('لا توجد قوانين لهذه العشيرة');
      }
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في تحميل قوانين العشيرة');
    }
  } catch (e) {
    throw Exception('خطأ في تحميل قوانين العشيرة: $e');
  }
}

/// Get clan rules by clan ID (Public/Groom access)
/// Alternative method that allows grooms to view rules by clan ID


//##################### clan rules  ###########################

static Future<Map<String, dynamic>> getGroomClanRulesByClanId(int clanId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/groom/clan-rules/clan/$clanId'),
      headers: await _headers,
    );

    print('Get groom clan rules by clan ID response status: ${response.statusCode}');
    print('Get groom clan rules by clan ID response body: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else if (decoded is List && decoded.isNotEmpty) {
        return decoded[0] as Map<String, dynamic>;
      } else {
        throw Exception('لا توجد قوانين لهذه العشيرة');
      }
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في تحميل قوانين العشيرة');
    }
  } catch (e) {
    throw Exception('خطأ في تحميل قوانين العشيرة: $e');
  }
}

// ==================== CLAN INFO ====================

static Future<Map<String,dynamic>> getClanInfoByCurrentUser() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/clan-admin/clan_info'),
      headers: await _headers,
    );

    print('Get groom clan info response status: ${response.statusCode}');
    print('Get groom clan info response body: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else if (decoded is List && decoded.isNotEmpty) {
        return decoded[0] as Map<String, dynamic>;
      } else {
        throw Exception('لا توجد معلومات لهذه العشيرة');
      }
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في تحميل معلومات العشيرة');
    }
  } catch (e) {
    throw Exception('خطأ في تحميل معلومات العشيرة: $e');
  }
}

// ==================== UTILITY METHODS FOR CLAN RULES ====================

/// Check if clan rules exist for a specific clan
static Future<bool> clanRulesExist(int clanId) async {
  try {
    await getClanRulesByClanId(clanId);
    return true;
  } catch (e) {
    return false;
  }
}

/// Get clan rules with fallback (returns null if not found instead of throwing)
static Future<Map<String, dynamic>?> getClanRulesSafe(int clanId) async {
  try {
    return await getClanRulesByClanId(clanId);
  } catch (e) {
    print('No rules found for clan $clanId: $e');
    return null;
  }
}

/// Validate clan rules data before creating/updating
static Map<String, String> validateClanRulesData({
  required String generalRule,
  int? clanId,
  String? groomSupplies,
  String? ruleAboutClothing,
  String? ruleAboutKitchenware,
  String? rulesBookOfClanPdfs,
}) {
  final errors = <String, String>{};

  // Validate general rule (required)
  if (generalRule.trim().isEmpty) {
    errors['general_rule'] = 'القاعدة العامة مطلوبة';
  } else if (generalRule.trim().length < 10) {
    errors['general_rule'] = 'القاعدة العامة قصيرة جداً (الحد الأدنى 10 أحرف)';
  } else if (generalRule.trim().length > 5000) {
    errors['general_rule'] = 'القاعدة العامة طويلة جداً (الحد الأقصى 5000 حرف)';
  }

  // Validate optional fields (if provided)
  if (groomSupplies != null && groomSupplies.trim().isNotEmpty) {
    if (groomSupplies.trim().length > 3000) {
      errors['groom_supplies'] = 'قاعدة لوازم العريس طويلة جداً (الحد الأقصى 3000 حرف)';
    }
  }

  if (ruleAboutClothing != null && ruleAboutClothing.trim().isNotEmpty) {
    if (ruleAboutClothing.trim().length > 3000) {
      errors['rule_about_clothing'] = 'قاعدة الملابس طويلة جداً (الحد الأقصى 3000 حرف)';
    }
  }

  if (ruleAboutKitchenware != null && ruleAboutKitchenware.trim().isNotEmpty) {
    if (ruleAboutKitchenware.trim().length > 3000) {
      errors['rule_about_kitchenware'] = 'قاعدة أدوات المطبخ طويلة جداً (الحد الأقصى 3000 حرف)';
    }
  }

  // Validate PDF URLs if provided
  if (rulesBookOfClanPdfs != null && rulesBookOfClanPdfs.trim().isNotEmpty) {
    // Basic URL validation (can be enhanced based on requirements)
    final urls = rulesBookOfClanPdfs.split(',').map((url) => url.trim()).toList();
    for (final url in urls) {
      if (url.isNotEmpty && !_isValidUrl(url)) {
        errors['rules_book_of_clan_pdfs'] = 'رابط PDF غير صالح: $url';
        break;
      }
    }
  }

  // Validate clan ID if provided
  if (clanId != null && clanId <= 0) {
    errors['clan_id'] = 'معرف العشيرة غير صحيح';
  }

  return errors;
}

/// Helper method to validate URL format
static bool _isValidUrl(String url) {
  try {
    final uri = Uri.parse(url);
    return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
  } catch (e) {
    return false;
  }
}

/// Format clan rules for display
static String formatClanRulesForDisplay(Map<String, dynamic> rules) {
  final buffer = StringBuffer();
  
  buffer.writeln('قوانين العشيرة');
  buffer.writeln('=' * 50);
  buffer.writeln();
  
  // General Rule
  if (rules.containsKey('general_rule') && rules['general_rule'] != null) {
    buffer.writeln('القاعدة العامة:');
    buffer.writeln(rules['general_rule']);
    buffer.writeln();
  }
  
  // Groom Supplies
  if (rules.containsKey('groom_supplies') && 
      rules['groom_supplies'] != null && 
      rules['groom_supplies'].toString().isNotEmpty) {
    buffer.writeln('لوازم العريس:');
    buffer.writeln(rules['groom_supplies']);
    buffer.writeln();
  }
  
  // Rule about Clothing
  if (rules.containsKey('rule_about_clothing') && 
      rules['rule_about_clothing'] != null && 
      rules['rule_about_clothing'].toString().isNotEmpty) {
    buffer.writeln('قواعد الملابس:');
    buffer.writeln(rules['rule_about_clothing']);
    buffer.writeln();
  }
  
  // Rule about Kitchenware
  if (rules.containsKey('rule_about_kitchenware') && 
      rules['rule_about_kitchenware'] != null && 
      rules['rule_about_kitchenware'].toString().isNotEmpty) {
    buffer.writeln('قواعد أدوات المطبخ:');
    buffer.writeln(rules['rule_about_kitchenware']);
    buffer.writeln();
  }
  
  // Rules Book PDFs
  if (rules.containsKey('rules_book_of_clan_pdfs') && 
      rules['rules_book_of_clan_pdfs'] != null && 
      rules['rules_book_of_clan_pdfs'].toString().isNotEmpty) {
    buffer.writeln('كتاب قوانين العشيرة (PDFs):');
    buffer.writeln(rules['rules_book_of_clan_pdfs']);
    buffer.writeln();
  }
  
  // Timestamps
  if (rules.containsKey('created_at')) {
    buffer.writeln('تاريخ الإنشاء: ${rules['created_at']}');
  }
  
  if (rules.containsKey('updated_at')) {
    buffer.writeln('آخر تحديث: ${rules['updated_at']}');
  }
  
  return buffer.toString();
}

/// Extract PDF URLs from rules
static List<String> extractPdfUrls(Map<String, dynamic> rules) {
  if (!rules.containsKey('rules_book_of_clan_pdfs') || 
      rules['rules_book_of_clan_pdfs'] == null) {
    return [];
  }
  
  final pdfString = rules['rules_book_of_clan_pdfs'].toString();
  if (pdfString.isEmpty) {
    return [];
  }
  
  return pdfString
      .split(',')
      .map((url) => url.trim())
      .where((url) => url.isNotEmpty)
      .toList();
}

/// Check if clan rules have PDF attachments
static bool hasPdfAttachments(Map<String, dynamic> rules) {
  return extractPdfUrls(rules).isNotEmpty;
}

/// Cache key for clan rules
static String _getClanRulesCacheKey(int clanId) {
  return 'clan_rules_$clanId';
}

/// Get clan rules with caching
static Future<Map<String, dynamic>> getClanRulesCached(int clanId) async {
  final cacheKey = _getClanRulesCacheKey(clanId);
  final cached = getCachedData<Map<String, dynamic>>(cacheKey);
  
  if (cached != null) {
    return cached;
  }

  final rules = await getClanRulesByClanId(clanId);
  setCachedData(cacheKey, rules);
  return rules;
}

/// Clear clan rules cache
static void clearClanRulesCache(int clanId) {
  final cacheKey = _getClanRulesCacheKey(clanId);
  removeCachedData(cacheKey);
}

/// Refresh clan rules cache
static Future<Map<String, dynamic>> refreshClanRulesCache(int clanId) async {
  clearClanRulesCache(clanId);
  return await getClanRulesCached(clanId);
}

/// rules pdf routes  

/// Upload PDF file to backend with optional clan association
/// 
/// [file] - The PDF file to upload
/// [clanId] - Optional clan ID to save PDF URL to ClanRules table
/// 
/// Returns a map containing:
/// - success: bool
/// - url: String (PDF access URL)
/// - filename: String
/// - file_id: String
/// - size: int
/// - clan_id: int? (if provided)
// static Future<Map<String, dynamic>> uploadPdfFile(
//   File file, {
//   int? clanId,
// }) async {
//   try {
//     final fileName = path.basename(file.path);
//     final fileSize = await file.length();

//     print('=== Upload Debug ===');
//     print('Base URL: $baseUrl');
//     print('File: $fileName');
//     print('Size: $fileSize bytes');
//     if (clanId != null) print('Clan ID: $clanId');

//     // FIXED: Create multipart request with optional clan_id as FORM FIELD, not query parameter
//     var uri = Uri.parse('$baseUrl/pdf/api/upload/pdf/');
//     var request = http.MultipartRequest('POST', uri);

//     // Add auth header
//     if (_token != null) {
//       request.headers['Authorization'] = 'Bearer $_token';
//     }

//     // FIXED: Add clan_id as a form field if provided
//     if (clanId != null) {
//       request.fields['clan_id'] = clanId.toString();
//     }

//     // Add file
//     request.files.add(await http.MultipartFile.fromPath(
//       'file',
//       file.path,
//       filename: fileName,
//     ));

//     print('Sending request to: ${request.url}');
//     if (clanId != null) print('With clan_id field: $clanId');

//     // Send request with longer timeout for file upload
//     var streamedResponse = await request.send().timeout(
//       const Duration(seconds: 60), // Increased timeout
//     );

//     var response = await http.Response.fromStream(streamedResponse);

//     print('Response status: ${response.statusCode}');
//     print('Response body: ${response.body}');

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data['success'] == true) {
//         return {
//           'success': data['success'],
//           'url': data['url'],
//           'filename': data['filename'],
//           'file_id': data['file_id'],
//           'size': data['size'],
//           'clan_id': data['clan_id'],
//         };
//       }
//       throw Exception(data['detail'] ?? 'فشل التحميل');
//     } else {
//       final error = json.decode(response.body);
//       throw Exception(error['detail'] ?? 'خطأ في التحميل');
//     }
//   } catch (e) {
//     print('Upload error: $e');
//     rethrow;
//   }
// }

// static Future<Map<String, dynamic>> uploadPdfFile(
//   File file, {
//   int? clanId,
// }) async {
//   try {
//     final fileName = path.basename(file.path);
//     final fileSize = await file.length();

//     print('=== Upload Debug ===');
//     print('Base URL: $baseUrl');
//     print('File: $fileName');
//     print('Size: $fileSize bytes');
//     if (clanId != null) print('Clan ID: $clanId');

//     // Create multipart request with optional clan_id as FORM FIELD
//     var uri = Uri.parse('$baseUrl/pdf/api/upload/pdf/');
//     var request = http.MultipartRequest('POST', uri);

//     // Add auth header
//     if (_token != null) {
//       request.headers['Authorization'] = 'Bearer $_token';
//     }

//     // Add clan_id as a form field if provided
//     if (clanId != null) {
//       request.fields['clan_id'] = clanId.toString();
//     }

//     // Add file
//     request.files.add(await http.MultipartFile.fromPath(
//       'file',
//       file.path,
//       filename: fileName,
//     ));

//     print('Sending request to: ${request.url}');
//     if (clanId != null) print('With clan_id field: $clanId');

//     // Send request with longer timeout for file upload
//     var streamedResponse = await request.send().timeout(
//       const Duration(seconds: 60),
//     );

//     var response = await http.Response.fromStream(streamedResponse);

//     print('Response status: ${response.statusCode}');
//     print('Response body: ${response.body}');

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data['success'] == true) {
//         print('✅ Upload successful!');
//         print('📄 Full URL: ${data['url']}');
//         print('💾 Saved to DB: ${data['saved_to_database']}');
        
//         // IMPORTANT: Return the full URL exactly as provided by backend
//         // Don't modify or reconstruct it
//         return {
//           'success': true,
//           'url': data['url'], // Use this exact URL
//           'filename': data['filename'],
//           'file_id': data['file_id'],
//           'size': data['size'],
//           'clan_id': data['clan_id'],
//           'saved_to_database': data['saved_to_database'],
//         };
//       }
//       throw Exception(data['detail'] ?? 'فشل التحميل');
//     } else {
//       final error = json.decode(response.body);
//       throw Exception(error['detail'] ?? 'خطأ في التحميل');
//     }
//   } catch (e) {
//     print('❌ Upload error: $e');
//     rethrow;
//   }
// }

/// Delete PDF file and optionally remove from ClanRules
/// 
/// [url] - The full URL of the PDF file
/// [clanId] - Optional clan ID to remove PDF URL from ClanRules table
// static Future<void> deletePdfByUrl(String url, {int? clanId}) async {
//   try {
//     final fileId = url.split('/').last;

//     // Keep using query parameters for DELETE requests - this is correct
//     var uri = Uri.parse('$baseUrl/pdf/api/upload/pdf/$fileId');
//     if (clanId != null) {
//       uri = uri.replace(queryParameters: {'clan_id': clanId.toString()});
//     }

//     print('Delete URL: $uri');

//     final response = await http.delete(
//       uri,
//       headers: await _headers,
//     ).timeout(const Duration(seconds: 30));

//     print('Delete response: ${response.statusCode}');
//     print('Delete response body: ${response.body}');

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data['success'] != true) {
//         throw Exception('فشل الحذف');
//       }
//     } else {
//       final error = json.decode(response.body);
//       throw Exception(error['detail'] ?? 'فشل حذف الملف');
//     }
//   } catch (e) {
//     print('Delete error: $e');
//     rethrow;
//   }
// }

/// Delete PDF file by file ID
/// 
/// [fileId] - The unique file identifier
/// [clanId] - Optional clan ID to remove PDF URL from ClanRules table
static Future<void> deletePdfById(String fileId, {int? clanId}) async {
  try {
    var uri = Uri.parse('$baseUrl/pdf/api/upload/pdf/$fileId');
    if (clanId != null) {
      uri = uri.replace(queryParameters: {'clan_id': clanId.toString()});
    }

    print('Delete URL: $uri');

    final response = await http.delete(
      uri,
      headers: await _headers,
    ).timeout(const Duration(seconds: 30));

    print('Delete response: ${response.statusCode}');
    print('Delete response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] != true) {
        throw Exception('فشل الحذف');
      }
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل حذف الملف');
    }
  } catch (e) {
    print('Delete error: $e');
    rethrow;
  }
}

/// Get the PDF URL for a specific clan's rules book
/// 
/// [clanId] - The clan ID
/// 
/// Returns a map containing:
/// - success: bool
/// - pdf_url: String
/// - clan_id: int
// static Future<Map<String, dynamic>> getClanRulesPdf(int clanId) async {
//   try {
//     print('Fetching clan rules PDF for clan: $clanId');

//     final response = await http.get(
//       Uri.parse('$baseUrl/pdf/api/clan/$clanId/rules/pdf'),
//       headers: await _headers,
//     ).timeout(const Duration(seconds: 30));

//     print('Response status: ${response.statusCode}');
//     print('Response body: ${response.body}');

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data['success'] == true) {
//         return {
//           'success': data['success'],
//           'pdf_url': data['pdf_url'],
//           'clan_id': data['clan_id'],
//         };
//       }
//       throw Exception('فشل في جلب ملف PDF');
//     } else if (response.statusCode == 404) {
//       throw Exception('لا يوجد ملف PDF لقواعد هذه العشيرة');
//     } else {
//       final error = json.decode(response.body);
//       throw Exception(error['detail'] ?? 'خطأ في جلب الملف');
//     }
//   } catch (e) {
//     print('Get clan rules PDF error: $e');
//     rethrow;
//   }
// }

/// Check if a clan has a rules PDF
/// 
/// [clanId] - The clan ID
/// 
/// Returns true if clan has a PDF, false otherwise
// static Future<bool> clanHasRulesPdf(int clanId) async {
//   try {
//     await getClanRulesPdf(clanId);
//     return true;
//   } catch (e) {
//     return false;
//   }
// }

/// Download and open PDF file
/// 
/// [fileId] - The unique file identifier
/// 
/// Returns the PDF file bytes
static Future<List<int>> downloadPdfe(String filename) async {
  try {
    print('Downloading PDF: $filename');

    final response = await http.get(
      Uri.parse('$baseUrl/pdf/api/upload/pdf/$filename'),
      headers: await _headers,
    ).timeout(const Duration(seconds: 60));

    print('Download response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل تحميل الملف');
    }
  } catch (e) {
    print('Download error: $e');
    rethrow;
  }
}

/// Check storage health
// static Future<Map<String, dynamic>> checkStorageHealth() async {
//   try {
//     final response = await http.get(
//       Uri.parse('$baseUrl/pdf/api/upload/health'),
//       headers: await _headers,
//     ).timeout(const Duration(seconds: 30));

//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception('فشل فحص حالة التخزين');
//     }
//   } catch (e) {
//     print('Health check error: $e');
//     rethrow;
//   }
// }

/// Debug: Check what's saved in ClanRules table for a specific clan
/// 
/// [clanId] - The clan ID to check
/// 
/// Returns the complete ClanRules data including the PDF URL
// static Future<Map<String, dynamic>> debugClanRules(int clanId) async {
//   try {
//     print('🔍 DEBUG: Checking ClanRules for clan: $clanId');

//     final response = await http.get(
//       Uri.parse('$baseUrl/pdf/api/debug/clan/$clanId/rules'),
//       headers: await _headers,
//     ).timeout(const Duration(seconds: 30));

//     print('Debug response status: ${response.statusCode}');
//     print('Debug response body: ${response.body}');

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       return data;
//     } else {
//       throw Exception('فشل في جلب بيانات التصحيح');
//     }
//   } catch (e) {
//     print('Debug error: $e');
//     rethrow;
//   }
// }



// ==================== SPECIAL RESERVATIONS ENDPOINTS ====================

/// Create a special reservation (block a date for clan events)
/// POST /clan-admin/reserv_some_dates
static Future<Map<String, dynamic>> createSpecialReservation({
  required String date,
  required String reservName,
  String? fullName,
  String? phoneNumber,
  String? homeAddress,
  String? reservDescription,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/clan-admin/reserv_some_dates'),
      headers: await _headers,
      body: json.encode({
        'date': date,
        'reserv_name': reservName,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'home_address': homeAddress,
        'reserv_desctiption': reservDescription, // Note: typo matches backend
      }),
    );

    print('Create special reservation response: ${response.statusCode}');
    print('Create special reservation body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في إنشاء الحجز الخاص');
    }
  } catch (e) {
    throw Exception('خطأ في إنشاء الحجز الخاص: $e');
  }
}

/// Get all special reservations for current clan admin
/// GET /clan-admin/special_reserv
static Future<List<dynamic>> getAllSpecialReservations() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/clan-admin/special_reservrations'),
      headers: await _headers,
    );

    print('Get special reservations response: ${response.statusCode}');
    print('Get special reservations body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في تحميل الحجوزات الخاصة');
    }
  } catch (e) {
    throw Exception('خطأ في تحميل الحجوزات الخاصة: $e');
  }
}

/// Toggle special reservation status (validated <-> cancelled)
/// PUT /clan-admin/update_status_special_reserv/{reserv_id}
static Future<Map<String, dynamic>> updateSpecialReservationStatus(int reservId) async {
  try {
    final response = await http.put(
      Uri.parse('$baseUrl/clan-admin/update_status_special_reserv/$reservId'),
      headers: await _headers,
    );

    print('Update special reservation status response: ${response.statusCode}');
    print('Update special reservation status body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في تحديث حالة الحجز الخاص');
    }
  } catch (e) {
    throw Exception('خطأ في تحديث حالة الحجز الخاص: $e');
  }
}

// ==================== SPECIAL RESERVATIONS UTILITY METHODS ====================

/// Check if a date has a special reservation
static Future<bool> hasSpecialReservation(String date) async {
  try {
    final specialReservations = await getAllSpecialReservations();
    return specialReservations.any((reserv) => 
      reserv['date'] == date && 
      reserv['status'] == 'validated'
    );
  } catch (e) {
    print('Error checking special reservation: $e');
    return false;
  }
}

/// Get special reservation details for a specific date
static Future<Map<String, dynamic>?> getSpecialReservationByDate(String date) async {
  try {
    final specialReservations = await getAllSpecialReservations();
    final filtered = specialReservations.where((reserv) => 
      reserv['date'] == date && 
      reserv['status'] == 'validated'
    ).toList();
    
    return filtered.isNotEmpty ? filtered.first : null;
  } catch (e) {
    print('Error getting special reservation by date: $e');
    return null;
  }
}

/// Validate special reservation data before creating
static Map<String, String> validateSpecialReservationData({
  required String date,
  required String reservName,
}) {
  final errors = <String, String>{};

  // Validate date
  if (date.trim().isEmpty) {
    errors['date'] = 'التاريخ مطلوب';
  } else if (!isValidDate(date)) {
    errors['date'] = 'صيغة التاريخ غير صحيحة';
  } else if (!isDateInFuture(date)) {
    errors['date'] = 'يجب أن يكون التاريخ في المستقبل';
  }

  // Validate reservation name
  if (reservName.trim().isEmpty) {
    errors['reserv_name'] = 'اسم الحجز مطلوب';
  } else if (reservName.trim().length < 3) {
    errors['reserv_name'] = 'اسم الحجز قصير جداً (الحد الأدنى 3 أحرف)';
  } else if (reservName.trim().length > 100) {
    errors['reserv_name'] = 'اسم الحجز طويل جداً (الحد الأقصى 100 حرف)';
  }

  return errors;
}


/// get all special reservation 

// Get special reservations for the current county
static Future<List<dynamic>> getSpecialReservations() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/clan-admin/special_reservations'),
      headers: await _headers,
    );

    print('Get special reservations response: ${response.statusCode}');
    print('Get special reservations body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data;
    } else if (response.statusCode == 401) {
      throw Exception('غير مصرح. يرجى تسجيل الدخول مرة أخرى');
    } else if (response.statusCode == 403) {
      throw Exception('ليس لديك صلاحية للوصول إلى هذه البيانات');
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في تحميل الحجوزات الخاصة');
    }
  } catch (e) {
    print('Error fetching special reservations: $e');
    throw Exception('خطأ في تحميل الحجوزات الخاصة: $e');
  }
}

// Add this to your ApiService class
// static Future<Uint8List?> downloadPdfFromUrl(String pdfUrl) async {
//   try {
//     final response = await http.get(
//       Uri.parse(pdfUrl),
//       headers: await _headers,
//     );

//     if (response.statusCode == 200) {
//       return response.bodyBytes;
//     } else {
//       print('Failed to download PDF: ${response.statusCode}');
//       return null;
//     }
//   } catch (e) {
//     print('Error downloading PDF: $e');
//     return null;
//   }
// }




// ==================== STATISTICS ENDPOINTS ====================

// ========== CLAN-SPECIFIC STATISTICS ==========

/// Get validated reservations for today for specific clan
/// Returns: {count, reservations: [{id, date1}], date, clan_id}
static Future<Map<String, dynamic>> getValidatedReservationsToday() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/reservations/valid_reservations_today'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في جلب الحجوزات');
    }
  } catch (e) {
    throw Exception('خطأ في جلب الحجوزات: $e');
  }
}

/// Get validated reservations for current month for specific clan
/// Returns: {count, reservations: [{id, date1}], month, year, clan_id}
static Future<Map<String, dynamic>> getValidatedReservationsMonth() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/reservations/valid_reservations_month'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في جلب الحجوزات');
    }
  } catch (e) {
    throw Exception('خطأ في جلب الحجوزات: $e');
  }
}

/// Get validated reservations for current year for specific clan
/// Returns: {count, reservations: [{id, date1}], year, clan_id}
static Future<Map<String, dynamic>> getValidatedReservationsYear() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/reservations/valid_reservations_year'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في جلب الحجوزات');
    }
  } catch (e) {
    throw Exception('خطأ في جلب الحجوزات: $e');
  }
}

// ========== COUNTY-WIDE STATISTICS ==========

/// Get validated reservations for today for entire county
/// Returns: {count, reservations: [{id, date1}], date}
static Future<Map<String, dynamic>> getValidatedReservationsTodayCounty() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/reservations/valid_reservations_today_county'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في جلب الحجوزات');
    }
  } catch (e) {
    throw Exception('خطأ في جلب الحجوزات: $e');
  }
}

/// Get validated reservations for current month for entire county
/// Returns: {count, reservations: [{id, date1}], month, year}
static Future<Map<String, dynamic>> getValidatedReservationsMonthCounty() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/reservations/valid_reservations_month_county'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في جلب الحجوزات');
    }
  } catch (e) {
    throw Exception('خطأ في جلب الحجوزات: $e');
  }
}

/// Get validated reservations for current year for entire county
/// Returns: {count, reservations: [{id, date1}], year}
static Future<Map<String, dynamic>> getValidatedReservationsYearCounty() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/reservations/valid_reservations_year_county'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في جلب الحجوزات');
    }
  } catch (e) {
    throw Exception('خطأ في جلب الحجوزات: $e');
  }
}

// ========== UTILITY METHODS ==========

/// Get just the count from today's reservations
static Future<int> getValidatedReservationsTodayCount() async {
  final data = await getValidatedReservationsToday();
  return data['count'] as int;
}

/// Get just the count from this month's reservations
static Future<int> getValidatedReservationsMonthCount() async {
  final data = await getValidatedReservationsMonth();
  return data['count'] as int;
}

/// Get just the count from this year's reservations
static Future<int> getValidatedReservationsYearCount() async {
  final data = await getValidatedReservationsYear();
  return data['count'] as int;
}

/// Get just the count from today's county reservations
static Future<int> getValidatedReservationsTodayCountyCount() async {
  final data = await getValidatedReservationsTodayCounty();
  return data['count'] as int;
}

/// Get just the count from this month's county reservations
static Future<int> getValidatedReservationsMonthCountyCount() async {
  final data = await getValidatedReservationsMonthCounty();
  return data['count'] as int;
}

/// Get just the count from this year's county reservations
static Future<int> getValidatedReservationsYearCountyCount() async {
  final data = await getValidatedReservationsYearCounty();
  return data['count'] as int;
}










/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// ==================== NOTIFICATION ENDPOINTS ====================
// Add these methods to your ApiService class in lib/services/api_service.dart

// ========== NOTIFICATION HELPER FOR RESERVATIONS ==========

/// Get the latest notification for a specific reservation
/// This is called after creating a reservation to fetch the auto-generated notification
static Future<Map<String, dynamic>?> getLatestNotificationForReservation(int reservationId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/by-reservation/$reservationId'),
      headers: await _headers,
    );

    print('Get latest notification for reservation response: ${response.statusCode}');
    print('Get latest notification body: ${response.body}');

    if (response.statusCode == 200) {
      final notifications = json.decode(response.body) as List<dynamic>;
      if (notifications.isNotEmpty) {
        // Return the most recent notification
        return notifications.first as Map<String, dynamic>;
      }
      return null;
    } else {
      print('No notification found for reservation $reservationId');
      return null;
    }
  } catch (e) {
    print('Error getting notification for reservation: $e');
    return null;
  }
}

/// Trigger notification to clan admin after reservation creation
/// This fetches the auto-generated notification and ensures it's delivered
static Future<bool> notifyClanAdminOfNewReservation(int reservationId) async {
  try {
    // Wait a moment for backend to create the notification
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Fetch the notification that was auto-generated
    final notification = await getLatestNotificationForReservation(reservationId);
    
    if (notification != null) {
      print('✅ Notification found and ready for clan admin');
      print('Notification ID: ${notification['id']}');
      print('Title: ${notification['title']}');
      print('Message: ${notification['message']}');
      
      // Clear notifications cache so clan admin sees the new notification
      clearNotificationsCache();
      
      return true;
    } else {
      print('⚠️ No notification found for reservation $reservationId');
      return false;
    }
  } catch (e) {
    print('❌ Error notifying clan admin: $e');
    return false;
  }
}

// ========== GET NOTIFICATIONS ==========

/// Get all notifications for the current user
/// GET /notifications
/// 
/// Parameters:
/// - unread_only: Filter to show only unread notifications (default: false)
/// - limit: Maximum number of notifications to return (1-100, default: 50)
static Future<List<dynamic>> getNotifications({
  bool unreadOnly = false,
  int limit = 50,
}) async {
  try {
    final queryParams = {
      'unread_only': unreadOnly.toString(),
      'limit': limit.toString(),
    };

    final uri = Uri.parse('$baseUrl/notifications')
        .replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: await _headers,
    );

    print('Get notifications response: ${response.statusCode}');
    print('Get notifications body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في جلب الإشعارات');
    }
  } catch (e) {
    throw Exception('خطأ في جلب الإشعارات: $e');
  }
}
static Future<List<dynamic>> getSendedNotifications({
  bool unreadOnly = false,
  int limit = 50,
}) async {
  try {
    final queryParams = {
      'unread_only': unreadOnly.toString(),
      'limit': limit.toString(),
    };

    final uri = Uri.parse('$baseUrl/notifications/sended')
        .replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: await _headers,
    );

    print('Get notifications response: ${response.statusCode}');
    print('Get notifications body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في جلب الإشعارات');
    }
  } catch (e) {
    throw Exception('خطأ في جلب الإشعارات: $e');
  }
}

/// Get notification statistics for the current user
/// GET /notifications/stats
/// 
/// Returns:
/// - unread_count: Total count of unread notifications
/// - total_count: Total count of all notifications
/// - by_type: Breakdown by notification type
static Future<Map<String, dynamic>> getNotificationStats() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/stats'),
      headers: await _headers,
    );

    print('Get notification stats response: ${response.statusCode}');
    print('Get notification stats body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في جلب إحصائيات الإشعارات');
    }
  } catch (e) {
    throw Exception('خطأ في جلب إحصائيات الإشعارات: $e');
  }
}

/// Get the count of unread notifications for quick polling
/// GET /notifications/unread-count
/// 
/// Returns:
/// - count: Number of unread notifications
static Future<int> getUnreadNotificationCount() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/unread-count'),
      headers: await _headers,
    );

    print('Get unread count response: ${response.statusCode}');
    print('Get unread count body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['count'] as int;
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في جلب عدد الإشعارات');
    }
  } catch (e) {
    throw Exception('خطأ في جلب عدد الإشعارات: $e');
  }
}

/// Get a specific notification by ID
/// GET /notifications/{notification_id}
static Future<Map<String, dynamic>> getNotificationById(int notificationId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/$notificationId'),
      headers: await _headers,
    );

    print('Get notification by ID response: ${response.statusCode}');
    print('Get notification by ID body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('الإشعار غير موجود');
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في جلب الإشعار');
    }
  } catch (e) {
    throw Exception('خطأ في جلب الإشعار: $e');
  }
}

/// Get notifications filtered by type
/// GET /notifications/by-type/{notification_type}
/// 
/// Parameters:
/// - notificationType: Type of notifications to retrieve
///   (reservation_approved, reservation_rejected, reservation_cancelled, 
///    reservation_reminder, payment_reminder, general_announcement, system_update)
/// - limit: Maximum number of notifications to return (1-100, default: 50)
static Future<List<dynamic>> getNotificationsByType({
  required String notificationType,
  int limit = 50,
}) async {
  try {
    final uri = Uri.parse('$baseUrl/notifications/by-type/$notificationType')
        .replace(queryParameters: {'limit': limit.toString()});

    final response = await http.get(
      uri,
      headers: await _headers,
    );

    print('Get notifications by type response: ${response.statusCode}');
    print('Get notifications by type body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في جلب الإشعارات');
    }
  } catch (e) {
    throw Exception('خطأ في جلب الإشعارات: $e');
  }
}

// ========== UPDATE NOTIFICATIONS ==========

/// Mark a specific notification as read
/// PATCH /notifications/{notification_id}/read
static Future<Map<String, dynamic>> markNotificationAsRead(int notificationId) async {
  try {
    final response = await http.patch(
      Uri.parse('$baseUrl/notifications/$notificationId/read'),
      headers: await _headers,
    );

    print('Mark notification as read response: ${response.statusCode}');
    print('Mark notification as read body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('الإشعار غير موجود');
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في تعليم الإشعار كمقروء');
    }
  } catch (e) {
    throw Exception('خطأ في تعليم الإشعار كمقروء: $e');
  }
}

/// Mark all notifications as read for the current user
/// PATCH /notifications/mark-all-read
static Future<Map<String, dynamic>> markAllNotificationsAsRead() async {
  try {
    final response = await http.patch(
      Uri.parse('$baseUrl/notifications/mark-all-read'),
      headers: await _headers,
    );

    print('Mark all notifications as read response: ${response.statusCode}');
    print('Mark all notifications as read body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في تعليم الإشعارات كمقروءة');
    }
  } catch (e) {
    throw Exception('خطأ في تعليم الإشعارات كمقروءة: $e');
  }
}

// ========== DELETE NOTIFICATIONS ==========

/// Delete a specific notification
/// DELETE /notifications/{notification_id}
static Future<Map<String, dynamic>> deleteNotification(int notificationId) async {
  try {
    final response = await http.delete(
      Uri.parse('$baseUrl/notifications/$notificationId'),
      headers: await _headers,
    );


    print('Delete notification response: ${response.statusCode}');
    print('Delete notification body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('الإشعار غير موجود');
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في حذف الإشعار');
    }
  } catch (e) {
    throw Exception('خطأ في حذف الإشعار: $e');
  }
}

/// Delete multiple notifications at once
/// DELETE /notifications/bulk-delete
/// 
/// Parameters:
/// - notificationIds: List of notification IDs to delete
static Future<Map<String, dynamic>> bulkDeleteNotifications(List<int> notificationIds) async {
  try {
    if (notificationIds.isEmpty) {
      throw Exception('قائمة معرفات الإشعارات فارغة');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/notifications/bulk-delete'),
      headers: await _headers,
      body: json.encode(notificationIds),
    );

    print('Bulk delete notifications response: ${response.statusCode}');
    print('Bulk delete notifications body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في حذف الإشعارات');
    }
  } catch (e) {
    throw Exception('خطأ في حذف الإشعارات: $e');
  }
}

// ========== ADMIN-ONLY ENDPOINTS ==========

/// Create a general notification (Clan Admin only)
/// POST /notifications/create-general
/// 
/// Parameters:
/// - userId: Target user ID
/// - reservationId: Associated reservation ID
/// - title: Notification title
/// - message: Notification message
static Future<Map<String, dynamic>> createGeneralNotification({
  required int userId,
  required int reservationId,
  required String title,
  required String message,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/notifications/create-general'),
      headers: await _headers,
      body: json.encode({
        'user_id': userId,
        'reservation_id': reservationId,
        'title': title,
        'message': message,
      }),
    );

    print('Create general notification response: ${response.statusCode}');
    print('Create general notification body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'الحجز أو المستخدم غير موجود');
    } else if (response.statusCode == 403) {
      throw Exception('غير مصرح لك بإرسال إشعارات لهذا الحجز');
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في إنشاء الإشعار');
    }
  } catch (e) {
    throw Exception('خطأ في إنشاء الإشعار: $e');
  }
}

/// Send validation notification to groom (Clan Admin only)
/// POST /notifications/notify-validation/{reservation_id}
/// 
/// Parameters:
/// - reservationId: The ID of the reservation
/// - isApproved: Whether the reservation was approved or rejected
static Future<Map<String, dynamic>> notifyReservationValidation({
  required int reservationId,
  required bool isApproved,
}) async {
  try {
    final uri = Uri.parse('$baseUrl/notifications/notify-validation/$reservationId')
        .replace(queryParameters: {'is_approved': isApproved.toString()});

    final response = await http.post(
      uri,
      headers: await _headers,
    );

    print('Notify reservation validation response: ${response.statusCode}');
    print('Notify reservation validation body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('الحجز غير موجود');
    } else if (response.statusCode == 403) {
      throw Exception('غير مصرح لك بالتعامل مع هذا الحجز');
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في إرسال إشعار التحقق');
    }
  } catch (e) {
    throw Exception('خطأ في إرسال إشعار التحقق: $e');
  }
}

// ========== UTILITY METHODS ==========

/// Get notifications with caching support
static Future<List<dynamic>> getNotificationsCached({
  bool unreadOnly = false,
  int limit = 50,
  bool forceRefresh = false,
}) async {
  final cacheKey = 'notifications_${unreadOnly}_$limit';
  
  if (!forceRefresh) {
    final cached = getCachedData<List<dynamic>>(cacheKey);
    if (cached != null) {
      return cached;
    }
  }

  final notifications = await getNotifications(
    unreadOnly: unreadOnly,
    limit: limit,
  );
  
  setCachedData(cacheKey, notifications);
  return notifications;
}

/// Clear notifications cache
static void clearNotificationsCache() {
  // Clear all notification-related cache entries
  final keys = _cache.keys.where((key) => key.startsWith('notifications_')).toList();
  for (final key in keys) {
    removeCachedData(key);
  }
}

/// Poll for new notifications
/// Returns true if there are new unread notifications
static Future<bool> hasNewNotifications({int? lastCount}) async {
  try {
    final currentCount = await getUnreadNotificationCount();
    
    if (lastCount == null) {
      return currentCount > 0;
    }
    
    return currentCount > lastCount;
  } catch (e) {
    print('Error checking for new notifications: $e');
    return false;
  }
}

/// Get unread notifications only (convenience method)
static Future<List<dynamic>> getUnreadNotifications({int limit = 50}) async {
  return await getNotifications(unreadOnly: true, limit: limit);
}

/// Get read notifications only (convenience method)
static Future<List<dynamic>> getReadNotifications({int limit = 50}) async {
  final allNotifications = await getNotifications(limit: limit);
  return allNotifications.where((notif) => notif['is_read'] == true).toList();
}

/// Check if notification exists and is unread
static Future<bool> isNotificationUnread(int notificationId) async {
  try {
    final notification = await getNotificationById(notificationId);
    return notification['is_read'] == false;
  } catch (e) {
    print('Error checking notification read status: $e');
    return false;
  }
}

/// Get notifications by multiple types
static Future<List<dynamic>> getNotificationsByTypes({
  required List<String> notificationTypes,
  int limit = 50,
}) async {
  final allNotifications = <dynamic>[];
  
  for (final type in notificationTypes) {
    try {
      final notifications = await getNotificationsByType(
        notificationType: type,
        limit: limit,
      );
      allNotifications.addAll(notifications);
    } catch (e) {
      print('Error getting notifications of type $type: $e');
    }
  }
  
  // Sort by created_at descending
  allNotifications.sort((a, b) {
    final aTime = DateTime.parse(a['created_at']);
    final bTime = DateTime.parse(b['created_at']);
    return bTime.compareTo(aTime);
  });
  
  return allNotifications.take(limit).toList();
}

/// Mark multiple notifications as read
static Future<List<bool>> markMultipleNotificationsAsRead(List<int> notificationIds) async {
  final results = <bool>[];
  
  for (final id in notificationIds) {
    try {
      await markNotificationAsRead(id);
      results.add(true);
    } catch (e) {
      print('Error marking notification $id as read: $e');
      results.add(false);
    }
  }
  
  return results;
}

/// Delete all read notifications
static Future<int> deleteAllReadNotifications() async {
  try {
    final notifications = await getNotifications(limit: 100);
    final readNotificationIds = notifications
        .where((notif) => notif['is_read'] == true)
        .map((notif) => notif['id'] as int)
        .toList();
    
    if (readNotificationIds.isEmpty) {
      return 0;
    }
    
    final result = await bulkDeleteNotifications(readNotificationIds);
    return result['count'] as int;
  } catch (e) {
    print('Error deleting read notifications: $e');
    return 0;
  }
}

/// Get notification count by type
static Future<Map<String, int>> getNotificationCountByType() async {
  try {
    final stats = await getNotificationStats();
    return Map<String, int>.from(stats['by_type'] ?? {});
  } catch (e) {
    print('Error getting notification count by type: $e');
    return {};
  }  
}

/// Check if user has unread reservation notifications
static Future<bool> hasUnreadReservationNotifications() async {
  try {
    final reservationTypes = [
      'reservation_approved',
      'reservation_rejected',
      'reservation_cancelled',
    ];
    
    for (final type in reservationTypes) {
      final notifications = await getNotificationsByType(
        notificationType: type,
        limit: 1,
      );
      
      if (notifications.isNotEmpty && notifications[0]['is_read'] == false) {
        return true;
      }
    }
    
    return false;
  } catch (e) {
    print('Error checking unread reservation notifications: $e');
    return false;
  }
}

/// Format notification for display
static String formatNotificationMessage(Map<String, dynamic> notification) {
  final title = notification['title'] ?? 'إشعار';
  final message = notification['message'] ?? '';
  final createdAt = DateTime.parse(notification['created_at']);
  final timeAgo = _getTimeAgo(createdAt);
  
  return '$title\n$message\n$timeAgo';
}

/// Helper method to get relative time string
static String _getTimeAgo(DateTime dateTime) {
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
}

/// Validate notification data before sending (for admin)
static Map<String, String> validateNotificationData({
  required String title,
  required String message,
}) {
  final errors = <String, String>{};

  if (title.trim().isEmpty) {
    errors['title'] = 'العنوان مطلوب';
  } else if (title.trim().length < 3) {
    errors['title'] = 'العنوان قصير جداً (الحد الأدنى 3 أحرف)';
  } else if (title.trim().length > 100) {
    errors['title'] = 'العنوان طويل جداً (الحد الأقصى 100 حرف)';
  }

  if (message.trim().isEmpty) {
    errors['message'] = 'الرسالة مطلوبة';
  } else if (message.trim().length < 10) {
    errors['message'] = 'الرسالة قصيرة جداً (الحد الأدنى 10 أحرف)';
  } else if (message.trim().length > 500) {
    errors['message'] = 'الرسالة طويلة جداً (الحد الأقصى 500 حرف)';
  }

  return errors;
}











// ==================== SUPER ADMIN NOTIFICATION ENDPOINTS ====================

/// Create and send notification to all users of a specific role
/// POST /notifications/create_notification
/// 
/// Parameters:
/// - title: Notification title
/// - message: Notification message
/// - isGroom: If true, sends to all grooms. If false, sends to all clan admins
/// 
/// Returns:
/// - message: Success message with count of users notified
// static Future<Map<String, dynamic>> createNotificationForRole_grooms_reserved({
//   required String title,
//   required String message,
//   required bool isGroom,
// }) async {
//   try {
//     final response = await http.post(
//       Uri.parse('$baseUrl/notifications/create_notification_grooms_reserved'),
//       headers: await _headers,
//       body: json.encode({
//         'title': title,
//         'message': message,
//         'is_groom': isGroom,
//       }),
//     );

//     print('Create notification for role response: ${response.statusCode}');
//     print('Create notification for role body: ${response.body}');

//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else if (response.statusCode == 403) {
//       throw Exception('غير مصرح لك بإرسال الإشعارات');
//     } else {
//       final error = json.decode(response.body);
//       throw Exception(error['detail'] ?? 'فشل في إرسال الإشعار');
//     }
//   } catch (e) {
//     throw Exception('خطأ في إرسال الإشعار: $e');
//   }
// }



static Future<Map<String, dynamic>> createNotificationForRole({
  required String title,
  required String message,
  required bool isGroom,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/notifications/create_notification'),
      headers: await _headers,
      body: json.encode({
        'title': title,
        'message': message,
        'is_groom': isGroom,
      }),
    );

    print('Create notification for role response: ${response.statusCode}');
    print('Create notification for role body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 403) {
      throw Exception('غير مصرح لك بإرسال الإشعارات');
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في إرسال الإشعار');
    }
  } catch (e) {
    throw Exception('خطأ في إرسال الإشعار: $e');
  }
}

static Future<Map<String, dynamic>> createNotificationForValidReserv({
  required String title,
  required String message,
  required bool isGroom,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/notifications/create_notification_grooms_reserved'),
      headers: await _headers,
      body: json.encode({
        'title': title,
        'message': message,
        'is_groom': isGroom,
      }),
    );

    print('Create notification for role response: ${response.statusCode}');
    print('Create notification for role body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 403) {
      throw Exception('غير مصرح لك بإرسال الإشعارات');
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في إرسال الإشعار');
    }
  } catch (e) {
    throw Exception('خطأ في إرسال الإشعار: $e');
  }
}

// ========== CONVENIENCE METHODS ==========

/// Send notification to all grooms
static Future<Map<String, dynamic>> sendNotificationToAllGrooms({
  required String title,
  required String message,
}) async {
  return await createNotificationForRole(
    title: title,
    message: message,
    isGroom: true,
  );
}

/// Send notification to all clan admins
static Future<Map<String, dynamic>> sendNotificationToAllClanAdmins({
  required String title,
  required String message,
}) async {
  return await createNotificationForRole(
    title: title,
    message: message,
    isGroom: false,
  );
}

/// Send notification to ALL users (both grooms and clan admins)
static Future<Map<String, int>> sendNotificationToAllUsers({
  required String title,
  required String message,
}) async {
  try {
    // Send to grooms
    final groomResult = await sendNotificationToAllGrooms(
      title: title,
      message: message,
    );
    
    // Send to clan admins
    final adminResult = await sendNotificationToAllClanAdmins(
      title: title,
      message: message,
    );
    
    // Extract counts from messages
    final groomCount = _extractCountFromMessage(groomResult['message']);
    final adminCount = _extractCountFromMessage(adminResult['message']);
    
    return {
      'groom_count': groomCount,
      'clan_admin_count': adminCount,
      'total_count': groomCount + adminCount,
    };
  } catch (e) {
    throw Exception('خطأ في إرسال الإشعار لجميع المستخدمين: $e');
  }
}

/// Helper method to extract user count from success message
static int _extractCountFromMessage(String message) {
  // Expected format: "Notification sent to X users successfully"
  final regex = RegExp(r'(\d+)\s+users?');
  final match = regex.firstMatch(message);
  
  if (match != null && match.groupCount >= 1) {
    return int.tryParse(match.group(1) ?? '0') ?? 0;
  }
  
  return 0;
}

// ========== APP UPDATE NOTIFICATION ==========

/// Send app update notification to all users
/// This is a specific use case for notifying about new app versions
static Future<Map<String, int>> sendAppUpdateNotification({
  required String version,
  String? updateMessage,
}) async {
  final title = 'تحديث جديد متاح 📱';
  final message = updateMessage ?? 
      'يتوفر إصدار جديد من التطبيق (الإصدار $version).\n'
      'يرجى التحديث للحصول على أحدث الميزات والتحسينات.';
  
  return await sendNotificationToAllUsers(
    title: title,
    message: message,
  );
}

/// Send maintenance notification to all users
static Future<Map<String, int>> sendMaintenanceNotification({
  required String maintenanceTime,
  String? additionalInfo,
}) async {
  final title = 'صيانة مجدولة ⚙️';
  final message = additionalInfo ?? 
      'سيخضع التطبيق لصيانة مجدولة في $maintenanceTime.\n'
      'قد تواجه بعض الانقطاعات المؤقتة في الخدمة.';
  
  return await sendNotificationToAllUsers(
    title: title,
    message: message,
  );
}

/// Send general announcement to all users
static Future<Map<String, int>> sendGeneralAnnouncement({
  required String title,
  required String message,
}) async {
  return await sendNotificationToAllUsers(
    title: title,
    message: message,
  );
}

/// Send urgent notification to all users
static Future<Map<String, int>> sendUrgentNotification({
  required String title,
  required String message,
}) async {
  final urgentTitle = '⚠️ عاجل: $title';
  
  return await sendNotificationToAllUsers(
    title: urgentTitle,
    message: message,
  );
}

// ========== VALIDATION METHODS ==========

/// Validate notification data before sending to multiple users
static Map<String, String> validateBulkNotificationData({
  required String title,
  required String message,
}) {
  final errors = <String, String>{};

  // Title validation
  if (title.trim().isEmpty) {
    errors['title'] = 'العنوان مطلوب';
  } else if (title.trim().length < 3) {
    errors['title'] = 'العنوان قصير جداً (الحد الأدنى 3 أحرف)';
  } else if (title.trim().length > 200) {
    errors['title'] = 'العنوان طويل جداً (الحد الأقصى 200 حرف)';
  }

  // Message validation
  if (message.trim().isEmpty) {
    errors['message'] = 'الرسالة مطلوبة';
  } else if (message.trim().length < 10) {
    errors['message'] = 'الرسالة قصيرة جداً (الحد الأدنى 10 أحرف)';
  } else if (message.trim().length > 1000) {
    errors['message'] = 'الرسالة طويلة جداً (الحد الأقصى 1000 حرف)';
  }

  return errors;
}

// ========== STATISTICS METHODS ==========

/// Get notification sending history (for admin dashboard)
/// This would need a backend endpoint to work
static Future<List<Map<String, dynamic>>> getNotificationHistory({
  int limit = 50,
}) async {
  // Placeholder - implement when backend endpoint is available
  // This could track all bulk notifications sent
  throw UnimplementedError('Notification history endpoint not yet implemented');
}






//////////////////// pdf routes /////////////////////
///
// ==================== UPDATED PDF UPLOAD/MANAGEMENT ENDPOINTS ====================
// Replace the existing PDF methods in your api_service.dart with these updated versions

/// Upload PDF file to backend with optional clan association
/// Now saves file PATH to database instead of URL
/// 
/// [file] - The PDF file to upload
/// [clanId] - Optional clan ID to save PDF path to ClanRules table
/// 
/// Returns a map containing:
/// - success: bool
/// - url: String (PDF access URL for viewing)
/// - path: String (relative path saved in database)
/// - filename: String
/// - file_id: String
/// - size: int
/// - clan_id: int? (if provided)
/// - saved_to_database: bool
static Future<Map<String, dynamic>> uploadPdfFile(
  File file, {
  int? clanId,
}) async {
  try {
    final fileName = path.basename(file.path);
    final fileSize = await file.length();

    print('=== Upload Debug ===');
    print('Base URL: $baseUrl');
    print('File: $fileName');
    print('Size: $fileSize bytes');
    if (clanId != null) print('Clan ID: $clanId');

    // Create multipart request - clan_id as FORM FIELD
    var uri = Uri.parse('$baseUrl/pdf/api/upload/pdf/');
    var request = http.MultipartRequest('POST', uri);

    // Add auth header
    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }

    // Add clan_id as a form field if provided
    if (clanId != null) {
      request.fields['clan_id'] = clanId.toString();
    }

    // Add file
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      file.path,
      filename: fileName,
    ));

    print('Sending request to: ${request.url}');
    if (clanId != null) print('With clan_id field: $clanId');

    // Send request with timeout
    var streamedResponse = await request.send().timeout(
      const Duration(seconds: 60),
    );

    var response = await http.Response.fromStream(streamedResponse);

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        print('✅ Upload successful!');
        print('📄 Access URL: ${data['url']}');
        print('💾 Database Path: ${data['path']}');
        print('🔗 Saved to DB: ${data['saved_to_database']}');
        
        return {
          'success': true,
          'url': data['url'],              // URL for accessing the file
          'path': data['path'],            // Path saved in database
          'filename': data['filename'],
          'file_id': data['file_id'],
          'size': data['size'],
          'clan_id': data['clan_id'],
          'saved_to_database': data['saved_to_database'],
        };
      }
      throw Exception(data['detail'] ?? 'فشل التحميل');
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'خطأ في التحميل');
    }
  } catch (e) {
    print('❌ Upload error: $e');
    rethrow;
  }
}

/// Delete PDF file by filename and optionally remove from ClanRules
/// 
/// [filename] - The PDF filename to delete
/// [clanId] - Optional clan ID to remove PDF path from ClanRules table
static Future<void> deletePdfByFilename(String filename, {int? clanId}) async {
  try {
    var uri = Uri.parse('$baseUrl/pdf/api/upload/pdf/$filename');
    if (clanId != null) {
      uri = uri.replace(queryParameters: {'clan_id': clanId.toString()});
    }

    print('Delete URL: $uri');

    final response = await http.delete(
      uri,
      headers: await _headers,
    ).timeout(const Duration(seconds: 30));

    print('Delete response: ${response.statusCode}');
    print('Delete response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] != true) {
        throw Exception('فشل الحذف');
      }
      print('✅ PDF deleted successfully');
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل حذف الملف');
    }
  } catch (e) {
    print('Delete error: $e');
    rethrow;
  }
}

/// Delete PDF file by extracting filename from URL
/// 
/// [url] - The full URL of the PDF file
/// [clanId] - Optional clan ID to remove PDF path from ClanRules table
static Future<void> deletePdfByUrl(String url, {int? clanId}) async {
  try {
    // Extract filename from URL (last segment)
    final filename = url.split('/').last;
    await deletePdfByFilename(filename, clanId: clanId);
  } catch (e) {
    print('Delete by URL error: $e');
    rethrow;
  }
}

/// Get the PDF information for a specific clan's rules book
/// Returns both the URL (for viewing) and path (from database)
/// 
/// [clanId] - The clan ID
/// 
/// Returns a map containing:
/// - success: bool
/// - pdf_url: String (URL to access the file)
/// - pdf_path: String (path stored in database)
/// - clan_id: int
/// - file_exists: bool
static Future<Map<String, dynamic>> getClanRulesPdf(int clanId) async {
  try {
    print('Fetching clan rules PDF for clan: $clanId');

    final response = await http.get(
      Uri.parse('$baseUrl/pdf/api/clan/$clanId/rules/pdf'),
      headers: await _headers,
    ).timeout(const Duration(seconds: 30));

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return {
          'success': data['success'],
          'pdf_url': data['pdf_url'],           // URL for viewing
          'pdf_path': data['pdf_path'],         // Path from database
          'clan_id': data['clan_id'],
          'file_exists': data['file_exists'],
        };
      }
      throw Exception('فشل في جلب ملف PDF');
    } else if (response.statusCode == 404) {
      throw Exception('لا يوجد ملف PDF لقواعد هذه العشيرة');
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'خطأ في جلب الملف');
    }
  } catch (e) {
    print('Get clan rules PDF error: $e');
    rethrow;
  }
}

/// Check if a clan has a rules PDF
/// 
/// [clanId] - The clan ID
/// 
/// Returns true if clan has a PDF, false otherwise
static Future<bool> clanHasRulesPdf(int clanId) async {
  try {
    final result = await getClanRulesPdf(clanId);
    return result['file_exists'] == true;
  } catch (e) {
    return false;
  }
}

/// Download PDF file by filename
/// 
/// [filename] - The unique filename
/// 
/// Returns the PDF file bytes
static Future<Uint8List> downloadPdfByFilename(String filename) async {
  try {
    print('Downloading PDF: $filename');

    final response = await http.get(
      Uri.parse('$baseUrl/pdf/api/files/$filename'),
      headers: await _headers,
    ).timeout(const Duration(seconds: 60));

    print('Download response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل تحميل الملف');
    }
  } catch (e) {
    print('Download error: $e');
    rethrow;
  }
}

/// Download PDF from full URL
/// Extracts filename and downloads
static Future<Uint8List> downloadPdfFromUrl(String url) async {
  try {
    final filename = url.split('/').last;
    return await downloadPdfByFilename(filename);
  } catch (e) {
    print('Download from URL error: $e');
    rethrow;
  }
}

/// Check storage health
static Future<Map<String, dynamic>> checkStorageHealth() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/pdf/api/upload/health'),
      headers: await _headers,
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('فشل فحص حالة التخزين');
    }
  } catch (e) {
    print('Health check error: $e');
    rethrow;
  }
}

/// Debug: Check what's saved in ClanRules table for a specific clan
/// 
/// [clanId] - The clan ID to check
/// 
/// Returns the complete ClanRules data including the PDF path
static Future<Map<String, dynamic>> debugClanRules(int clanId) async {
  try {
    print('🔍 DEBUG: Checking ClanRules for clan: $clanId');

    final response = await http.get(
      Uri.parse('$baseUrl/pdf/api/debug/clan/$clanId/rules'),
      headers: await _headers,
    ).timeout(const Duration(seconds: 30));

    print('Debug response status: ${response.statusCode}');
    print('Debug response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      // Log detailed debug information
      if (data['status'] == 'found') {
        final rules = data['clan_rules'];
        print('📋 ClanRules found:');
        print('  - ID: ${rules['id']}');
        print('  - Clan ID: ${rules['clan_id']}');
        print('  - PDF Path: ${rules['rules_book_of_clan_pdf']}');
        print('  - PDF in DB: ${rules['pdf_exists_in_db']}');
        print('  - PDF on Disk: ${rules['pdf_exists_on_disk']}');
        print('  - Full File Path: ${rules['full_file_path']}');
      }
      
      return data;
    } else {
      throw Exception('فشل في جلب بيانات التصحيح');
    }
  } catch (e) {
    print('Debug error: $e');
    rethrow;
  }
}

// ==================== CONVENIENCE METHODS ====================

/// Upload PDF and get just the URL for immediate display
static Future<String?> uploadPdfAndGetUrl(
  File file, {
  int? clanId,
}) async {
  try {
    final result = await uploadPdfFile(file, clanId: clanId);
    return result['url'] as String?;
  } catch (e) {
    print('Error uploading PDF and getting URL: $e');
    return null;
  }
}

/// Upload PDF and get the database path
static Future<String?> uploadPdfAndGetPath(
  File file, {
  int? clanId,
}) async {
  try {
    final result = await uploadPdfFile(file, clanId: clanId);
    return result['path'] as String?;
  } catch (e) {
    print('Error uploading PDF and getting path: $e');
    return null;
  }
}

/// Get just the URL for a clan's rules PDF
static Future<String?> getClanRulesPdfUrl(int clanId) async {
  try {
    final result = await getClanRulesPdf(clanId);
    return result['pdf_url'] as String?;
  } catch (e) {
    print('Error getting clan rules PDF URL: $e');
    return null;
  }
}

/// Get just the path for a clan's rules PDF (from database)
static Future<String?> getClanRulesPdfPath(int clanId) async {
  try {
    final result = await getClanRulesPdf(clanId);
    return result['pdf_path'] as String?;
  } catch (e) {
    print('Error getting clan rules PDF path: $e');
    return null;
  }
}

/// Download and save PDF to device
/// 
/// [url] - PDF URL to download
/// [savePath] - Local path to save the file
static Future<File?> downloadAndSavePdf(String url, String savePath) async {
  try {
    final bytes = await downloadPdfFromUrl(url);
    final file = File(savePath);
    await file.writeAsBytes(bytes);
    print('✅ PDF saved to: $savePath');
    return file;
  } catch (e) {
    print('Error downloading and saving PDF: $e');
    return null;
  }
}

/// Replace existing PDF for a clan
/// Deletes old PDF and uploads new one
static Future<Map<String, dynamic>?> replaceClanRulesPdf(
  int clanId,
  File newFile,
) async {
  try {
    // Get existing PDF info
    final existingPdf = await getClanRulesPdf(clanId);
    
    if (existingPdf['file_exists'] == true) {
      // Delete old PDF
      final oldUrl = existingPdf['pdf_url'] as String;
      await deletePdfByUrl(oldUrl, clanId: clanId);
      print('🗑️ Deleted old PDF');
    }
    
    // Upload new PDF
    final result = await uploadPdfFile(newFile, clanId: clanId);
    print('✅ Uploaded new PDF');
    
    return result;
  } catch (e) {
    print('Error replacing clan rules PDF: $e');
    return null;
  }
}

/// Validate PDF file before upload
static Map<String, String> validatePdfFile(File file) {
  final errors = <String, String>{};
  
  // Check if file exists
  if (!file.existsSync()) {
    errors['file'] = 'الملف غير موجود';
    return errors;
  }
  
  // Check file extension
  final extension = path.extension(file.path).toLowerCase();
  if (extension != '.pdf') {
    errors['file'] = 'يجب أن يكون الملف بصيغة PDF';
  }
  
  // Check file size (10MB max)
  final fileSize = file.lengthSync();
  const maxSize = 10 * 1024 * 1024; // 10MB
  if (fileSize > maxSize) {
    errors['file'] = 'حجم الملف كبير جداً (الحد الأقصى 10 ميجابايت)';
  }
  
  if (fileSize == 0) {
    errors['file'] = 'الملف فارغ';
  }
  
  return errors;
}

/// Batch upload multiple PDFs
static Future<List<Map<String, dynamic>>> batchUploadPdfs(
  List<File> files, {
  List<int?>? clanIds,
}) async {
  final results = <Map<String, dynamic>>[];
  
  for (int i = 0; i < files.length; i++) {
    try {
      final clanId = clanIds != null && i < clanIds.length ? clanIds[i] : null;
      final result = await uploadPdfFile(files[i], clanId: clanId);
      
      results.add({
        'success': true,
        'index': i,
        'data': result,
      });
    } catch (e) {
      print('Failed to upload PDF at index $i: $e');
      results.add({
        'success': false,
        'index': i,
        'error': e.toString(),
      });
    }
    
    // Small delay between uploads
    if (i < files.length - 1) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
  
  return results;
}

/// Get storage statistics
static Future<Map<String, dynamic>> getStorageStats() async {
  try {
    final health = await checkStorageHealth();
    
    return {
      'status': health['status'],
      'files_count': health['files_stored'],
      'total_size_mb': health['total_size_mb'],
      'max_file_size_mb': health['max_file_size_mb'],
      'volume_mounted': health['volume_mounted'],
      'upload_dir_exists': health['upload_dir_exists'],
    };
  } catch (e) {
    print('Error getting storage stats: $e');
    return {
      'status': 'error',
      'error': e.toString(),
    };
  }
}

/// Extract filename from URL or path
static String extractFilename(String urlOrPath) {
  return urlOrPath.split('/').last;
}

/// Build full PDF URL from filename
static String buildPdfUrl(String filename) {
  return '$baseUrl/pdf/api/files/$filename';
}

/// Check if URL/path is a valid PDF
static bool isValidPdfUrl(String url) {
  return url.toLowerCase().endsWith('.pdf') && url.contains('/pdf/api/files/');
}

/// Format file size for display
static String formatFileSize(int bytes) {
  if (bytes < 1024) {
    return '$bytes بايت';
  } else if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} كيلوبايت';
  } else {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} ميجابايت';
  }
}








/////////////// new part // so this part is for password access pages apis 
///
// ==================== ACCESS PASSWORD MANAGEMENT (SUPER ADMIN) ====================

// Generate access password for clan admin
static Future<Map<String, dynamic>> generateClanAdminAccessPassword(int adminId) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/super-admin/clan-admin/$adminId/generate-access-password'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في إنشاء كلمة مرور الوصول');
    }
  } catch (e) {
    throw Exception('خطأ في إنشاء كلمة مرور الوصول: $e');
  }
}

// Manually set access password for clan admin
static Future<Map<String, dynamic>> setClanAdminAccessPassword(
  int adminId, 
  String accessPassword
) async {
  try {
    final response = await http.put(
      Uri.parse('$baseUrl/super-admin/clan-admin/$adminId/set-access-password'),
      headers: await _headers,
      body: json.encode({
        'access_password': accessPassword,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في تعيين كلمة مرور الوصول');
    }
  } catch (e) {
    throw Exception('خطأ في تعيين كلمة مرور الوصول: $e');
  }
}



// ==================== CLAN ADMIN ENDPOINTS ====================

// Generate access password for groom (Clan Admin)
static Future<Map<String, dynamic>> generateGroomAccessPassword(int groomId) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/clan-admin/groom/$groomId/generate-access-password'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في إنشاء كلمة مرور الوصول للعريس');
    }
  } catch (e) {
    throw Exception('خطأ في إنشاء كلمة مرور الوصول: $e');
  }
}

// Manually set access password for groom (Clan Admin)
static Future<Map<String, dynamic>> setGroomAccessPassword(
  int groomId, 
  String accessPassword
) async {
  try {
    final response = await http.put(
      Uri.parse('$baseUrl/clan-admin/groom/$groomId/set-access-password'),
      headers: await _headers,
      body: json.encode({
        'access_password': accessPassword,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في تعيين كلمة مرور الوصول للعريس');
    }
  } catch (e) {
    throw Exception('خطأ في تعيين كلمة مرور الوصول: $e');
  }
}

// Get list of grooms (if not already present)
static Future<List<dynamic>> listGrooms() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/clan-admin/grooms'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في تحميل العرسان');
    }
  } catch (e) {
    throw Exception('خطأ في تحميل العرسان: $e');
  }
}

// ==================== ACCESS PASSWORD VERIFICATION ====================

// Verify access password for special pages
static Future<Map<String, dynamic>> verifyAccessPassword(
  int userId, 
  String accessPassword
) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-access-password'),
      headers: await _headers,
      body: json.encode({
        'user_id': userId,
        'access_password': accessPassword,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'كلمة مرور الوصول غير صحيحة');
    }
  } catch (e) {
    throw Exception('خطأ في التحقق من كلمة مرور الوصول: $e');
  }
}

// Check if user has access password set
static Future<bool> hasAccessPassword() async {
  try {
    final userInfo = await getCurrentUserInfo();
    // Assuming the API returns access_pages_password_hash or a flag
    return userInfo['access_pages_password_hash'] != null;
  } catch (e) {
    return false;
  }
}


// ==================== ACCESS PASSWORD UTILITIES ====================

/// Validates access to special pages
/// Returns true if user has access (Super Admin always has access)
/// Throws exception if access is denied
static Future<bool> validateSpecialPageAccess(String accessPassword) async {
  try {
    // Get current user info
    final userInfo = await getCurrentUserInfo();
    final role = userInfo['role'];
    
    // Super admins don't need access password
    if (role == 'super_admin') {
      return true;
    }
    
    // Check if user has access password set
    if (userInfo['access_pages_password_hash'] == null) {
      throw Exception('لم يتم تعيين كلمة مرور الوصول. يرجى الاتصال بالمسؤول.');
    }
    
    // Verify the access password
    final userId = userInfo['id'];
    final result = await verifyAccessPassword(userId, accessPassword);
    
    return result['valid'] == true;
  } catch (e) {
    throw Exception('فشل التحقق من الوصول: $e');
  }
}

/// Check user's role without requiring access password
static Future<String> getUserRole() async {
  try {
    final userInfo = await getCurrentUserInfo();
    return userInfo['role'];
  } catch (e) {
    throw Exception('فشل في الحصول على دور المستخدم: $e');
  }
}



// ==================== ACCESS PASSWORD STATUS CHECK ====================

/// Get clan admins with their access password status
static Future<List<Map<String, dynamic>>> getClanAdminsWithAccessStatus(int countyId) async {
  try {
    final admins = await listClanAdmins(countyId);
    
    // Add access password status to each admin
    return admins.map<Map<String, dynamic>>((admin) {
      // Create a mutable map from the admin data
      final Map<String, dynamic> adminMap = Map<String, dynamic>.from(admin);
      
      // Add the has_access_password flag
      adminMap['has_access_password'] = adminMap['access_pages_password_hash'] != null;
      
      return adminMap;
    }).toList();
  } catch (e) {
    throw Exception('خطأ في تحميل حالة كلمات مرور الوصول: $e');
  }
}


/// Get grooms with their access password status
static Future<List<Map<String, dynamic>>> getGroomsWithAccessStatus() async {
  try {
    final grooms = await listGrooms();
    


        // Add access password status to each admin
    return grooms.map<Map<String, dynamic>>((groom) {
      // Create a mutable map from the admin data
      final Map<String, dynamic> groomMap = Map<String, dynamic>.from(groom);
      
      // Add the has_access_password flag
      groomMap['has_access_password'] = groomMap['access_pages_password_hash'] != null;

      return groomMap;
    }).toList();
  } catch (e) {
    throw Exception('خطأ في تحميل حالة كلمات مرور الوصول: $e');
  }
}




///// to dfownload statistics 
///
// Add these methods to your ApiService class (lib/services/api_service.dart)
// Add them in the CLAN ADMIN section

// ==================== CLAN ADMIN STATISTICS ENDPOINTS ====================

// List all grooms for clan admin
static Future<List<dynamic>> listGroomsForClanAdmin() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/clan-admin/grooms'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في تحميل العرسان');
    }
  } catch (e) {
    throw Exception('خطأ في تحميل العرسان: $e');
  }
}

// List all reservations for clan admin
static Future<List<dynamic>> listReservationsForClanAdmin() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/clan-admin/reservations'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'فشل في تحميل الحجوزات');
    }
  } catch (e) {
    throw Exception('خطأ في تحميل الحجوزات: $e');
  }
}


}