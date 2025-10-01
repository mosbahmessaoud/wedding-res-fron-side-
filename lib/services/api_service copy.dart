// // lib/services/api_service.dart
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/user.dart';
// import '../models/county.dart';
// import '../models/clan.dart';
// import '../utils/constants.dart';

// class ApiService {
//   // static const String baseUrl = 'https://f09e1a125031.ngrok-free.app'; // Replace with your actual API URL
//   static const String baseUrl = 'http://192.168.1.11:8000'; // Replace with your actual API URL
//   // static const String baseUrl = 'http://127.0.0.1:8000'; // Replace with your actual API URL
//   static String? _token;

//   static void setToken(String token) {
//     _token = token;
//   }
//   // clear token
//   static void clearToken() {
//     _token = null;
//   }


//   static Map<String, String> get _headers {
//     final headers = {
//       'Content-Type': 'application/json',
//     };
//     if (_token != null) {
//       headers['Authorization'] = 'Bearer $_token';
//     }
//     return headers;
//   }

//   // Get Counties
//   static Future<List<County>> getCounties() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/groom/counties'),
//         headers: _headers,
//       );

//       if (response.statusCode == 200) {
//         List<dynamic> data = json.decode(response.body);
//         return data.map((json) => County.fromJson(json)).toList();
//       } else {
//         throw Exception('فشل في تحميل البلديات');
//       }
//     } catch (e) {
//       throw Exception('خطأ في الاتصال: $e');
//     }
//   }

//   // Get Clans
//   static Future<List<Clan>> getClans() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/super-admin/all_clans'),
//         headers: _headers,
//       );

//       if (response.statusCode == 200) {
//         List<dynamic> data = json.decode(response.body);
//         return data.map((json) => Clan.fromJson(json)).toList();
//       } else {
//         throw Exception('فشل في تحميل العشائر');
//       }
//     } catch (e) {
//       throw Exception('خطأ في الاتصال: $e');
//     }
//   }

//   // delet user using this api /delet_user/{phone__number}
//   static Future<void> deletUserr(String phone) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/delet_user/$phone'),
//         headers: _headers,
//       );

//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         final error = json.decode(response.body);
//         throw Exception(error['detail'] ?? 'فشل في الحذف');
//       }
//     } catch (e) {
//       throw Exception('خطأ في الحذف: $e');
//     }
//   }
//   // Register Groom
//   static Future<Map<String, dynamic>> registerGroom(Map<String, dynamic> userData) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/register/groom'),
//         headers: _headers,
//         body: json.encode(userData),
//       );

//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         final error = json.decode(response.body);
//         throw Exception(error['detail'] ?? 'فشل في التسجيل');
//       }
//     } catch (e) {
//       throw Exception('خطأ في التسجيل: $e');
//     }
//   }

//   // Verify Phone
//   static Future<void> verifyPhone(String phoneNumber, String code) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/verify-phone'),
//         headers: _headers,
//         body: json.encode({
//           'phone_number': phoneNumber,
//           'code': code,
//         }),
//       );

//       if (response.statusCode != 200) {
//         final error = json.decode(response.body);
//         throw Exception(error['detail'] ?? 'فشل في التحقق من الهاتف');
//       }
//     } catch (e) {
//       throw Exception('خطأ في التحقق: $e');
//     }
//   }

//   // Resend OTP
//   static Future<void> resendOTP(String phoneNumber) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/resend-verification'),
//         headers: _headers,
//         body: json.encode({
//           'phone_number': phoneNumber,
//         }),
//       );

//       if (response.statusCode != 200) {
//         final error = json.decode(response.body);
//         throw Exception(error['detail'] ?? 'فشل في إعادة إرسال الرمز');
//       }
//     } catch (e) {
//       throw Exception('خطأ في إعادة الإرسال: $e');
//     }
//   }

//   // get_role 
//   static Future<String> getRole() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/auth/get_role'),
//         headers: _headers,
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         return data['role'];
//       } else {
//         final error = json.decode(response.body);
//         throw Exception(error['detail'] ?? 'فشل في الحصول على الدور');
//       }
//     } catch (e) {
//       throw Exception('خطأ في الحصول على الدور: $e');
//     }
//   }
//   // Login
//   static Future<Map<String, dynamic>> login(String phoneNumber, String password) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/login'),
//         headers: _headers,
//         body: json.encode({
//           'phone_number': phoneNumber,
//           'password': password,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setToken(data['access_token']);
//         return data;
//       } else {
//         final error = json.decode(response.body);
//         throw Exception(error['detail'] ?? 'فشل في تسجيل الدخول');
//       }
//     } catch (e) {
//       throw Exception('خطأ في تسجيل الدخول: $e');
//     }
//   }
// }