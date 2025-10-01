// lib/models/auth.dart

// Token model for authentication responses
import 'package:wedding_reservation_app/models/user.dart';

class Token {
  final String accessToken;
  final String tokenType;

  Token({
    required this.accessToken,
    required this.tokenType,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
    };
  }

  @override
  String toString() {
    return 'Token{accessToken: ${accessToken.substring(0, 20)}..., tokenType: $tokenType}';
  }
}

// LoginRequest model for login requests
class LoginRequest {
  final String phoneNumber;
  final String password;

  LoginRequest({
    required this.phoneNumber,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'password': password,
    };
  }

  // Validation
  bool get isValid {
    return phoneNumber.isNotEmpty && 
           password.isNotEmpty && 
           password.length >= 6;
  }

  List<String> get validationErrors {
    List<String> errors = [];
    
    if (phoneNumber.isEmpty) {
      errors.add('رقم الهاتف مطلوب');
    }
    
    if (password.isEmpty) {
      errors.add('كلمة المرور مطلوبة');
    } else if (password.length < 6) {
      errors.add('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
    }
    
    return errors;
  }
}

// RegisterResponse model for registration responses
class RegisterResponse {
  final String message;
  final User user;

  RegisterResponse({
    required this.message,
    required this.user,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'],
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'user': user.toJson(),
    };
  }
}

// PhoneVerificationRequest model for phone verification
class PhoneVerificationRequest {
  final String phoneNumber;
  final String code;

  PhoneVerificationRequest({
    required this.phoneNumber,
    required this.code,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'code': code,
    };
  }

  // Validation
  bool get isValid {
    return phoneNumber.isNotEmpty && 
           code.isNotEmpty && 
           code.length == 6;
  }

  List<String> get validationErrors {
    List<String> errors = [];
    
    if (phoneNumber.isEmpty) {
      errors.add('رقم الهاتف مطلوب');
    }
    
    if (code.isEmpty) {
      errors.add('رمز التحقق مطلوب');
    } else if (code.length != 6) {
      errors.add('رمز التحقق يجب أن يكون 6 أرقام');
    }
    
    return errors;
  }
}

// PhoneRequest model for phone-only requests (like resend OTP)
class PhoneRequest {
  final String phoneNumber;

  PhoneRequest({
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
    };
  }

  bool get isValid => phoneNumber.isNotEmpty;
}

// AuthState enum for managing authentication states
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  phoneVerificationRequired,
  error,
}

// AuthResult class for handling authentication results
class AuthResult {
  final bool success;
  final String? message;
  final dynamic data;
  final AuthState state;

  AuthResult({
    required this.success,
    this.message,
    this.data,
    required this.state,
  });

  factory AuthResult.success({
    String? message,
    dynamic data,
    AuthState state = AuthState.authenticated,
  }) {
    return AuthResult(
      success: true,
      message: message,
      data: data,
      state: state,
    );
  }

  factory AuthResult.failure({
    String? message,
    dynamic data,
    AuthState state = AuthState.error,
  }) {
    return AuthResult(
      success: false,
      message: message,
      data: data,
      state: state,
    );
  }

  factory AuthResult.loading() {
    return AuthResult(
      success: false,
      state: AuthState.loading,
    );
  }

  factory AuthResult.phoneVerificationRequired({String? message}) {
    return AuthResult(
      success: false,
      message: message,
      state: AuthState.phoneVerificationRequired,
    );
  }

  @override
  String toString() {
    return 'AuthResult{success: $success, message: $message, state: $state}';
  }
}

// UserRole enum for different user roles
enum UserRole {
  groom,
  clanAdmin,
  superAdmin,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.groom:
        return 'عريس';
      case UserRole.clanAdmin:
        return 'مدير العشيرة';
      case UserRole.superAdmin:
        return 'المدير العام';
    }
  }

  String get value {
    switch (this) {
      case UserRole.groom:
        return 'groom';
      case UserRole.clanAdmin:
        return 'clan_admin';
      case UserRole.superAdmin:
        return 'super_admin';
    }
  }

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'groom':
        return UserRole.groom;
      case 'clan_admin':
        return UserRole.clanAdmin;
      case 'super_admin':
        return UserRole.superAdmin;
      default:
        return UserRole.groom;
    }
  }

  // Permission checks
  bool get canManageReservations {
    return this == UserRole.clanAdmin || this == UserRole.superAdmin;
  }

  bool get canManageClans {
    return this == UserRole.superAdmin;
  }

  bool get canManageCounties {
    return this == UserRole.superAdmin;
  }

  bool get canManageUsers {
    return this == UserRole.clanAdmin || this == UserRole.superAdmin;
  }

  bool get canCreateReservation {
    return this == UserRole.groom;
  }

  bool get canManageHalls {
    return this == UserRole.clanAdmin || this == UserRole.superAdmin;
  }

  bool get canManageFoodMenus {
    return this == UserRole.clanAdmin || this == UserRole.superAdmin;
  }

  bool get canManageCommittees {
    return this == UserRole.superAdmin;
  }
}

