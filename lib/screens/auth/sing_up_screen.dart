// lib/screens/auth/multi_step_signup_screen.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/clan.dart';
import '../../models/county.dart';
import '../../services/api_service.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/common/custom_text_field.dart' hide AppColors;
import 'otp_verification_screen.dart';

enum SmsRecipient { groom, guardian, wakil }


class MultiStepSignupScreen extends StatefulWidget {
  const MultiStepSignupScreen({super.key});

  @override
  _MultiStepSignupScreenState createState() => _MultiStepSignupScreenState();
}


class _MultiStepSignupScreenState extends State<MultiStepSignupScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  // bool _SmsToGroom = false; // Default: send to guardian's phone
  int _currentStep = 0;
  final int _totalSteps = 5;
  
    // Add this with your other state variables at the top of _MultiStepSignupScreenState
  SmsRecipient _selectedSmsRecipient = SmsRecipient.guardian; // Default to guardian
    
  // Form keys for each step
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(), // Add this new one
  ];
  
  // Controllers for personal info
  final _phoneController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _grandfatherNameController = TextEditingController();
  var _birthAddressController = TextEditingController();
  final _homeAddressController = TextEditingController();
  
  // Controllers for guardian info
  final _guardianNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  final _guardianBirthAddressController = TextEditingController();
  final _guardianHomeAddressController = TextEditingController();
  
  // Controllers for security
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  

    // Add these new controllers with the other controllers
  final _familyNameController = TextEditingController();
  final _wakilFullNameController = TextEditingController();
  final _wakilPhoneNumberController = TextEditingController();




  // Form data
  DateTime? _birthDate;
  DateTime? _guardianBirthDate;
  County? _selectedCounty;
  Clan? _selectedClan;
  // String? _selectedGuardianRelation;
  
  // State
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  List<County> _counties = [];
  List<Clan> _clans = [];
  List<Clan> _filteredClans = [];
  // bool _hasInternet = true;
  bool _isLoadingClans = false;
  String? _selectedGuardianRelation = AppConstants.guardianRelations.first;

// Also update the _checkConnectivity method to be more reliable
Future<bool> _checkConnectivity() async {
  try {
    final connectivityResult = await Connectivity().checkConnectivity();
    
    // Check if it's a list (newer versions) or single value
    if (connectivityResult is List) {
      return !connectivityResult.contains(ConnectivityResult.none) && 
             connectivityResult.isNotEmpty;
    }
    
    return connectivityResult != ConnectivityResult.none;
  } catch (e) {
    print('Connectivity check error: $e');
    return false;
  }
}
// Add this method to show no internet dialog
void _showNoInternetDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final isSmallScreen = screenWidth < 360;
      
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16 : 24,
          vertical: 20,
        ),
        title: Row(
          children: [
            Icon(
              Icons.wifi_off, 
              color: AppColors.error, 
              size: isSmallScreen ? 24 : 28,
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Expanded(
              child: Text(
                'لا يوجد اتصال بالإنترنت',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى',
          style: TextStyle(
            fontSize: isSmallScreen ? 13 : 14,
          ),
        ),
        actions: [
TextButton(
  onPressed: () async {
    final nav = Navigator.of(context);
    nav.pop();
    
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (_) => Dialog(
    backgroundColor: Colors.transparent,
    child: Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width < 360 ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'جاري فحص الاتصال...',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width < 360 ? 13 : 15,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  ),
);
    
    await Future.delayed(Duration(seconds: 2));
    final hasInternet = await _checkConnectivity();
    
    nav.pop();
    
    if (hasInternet) {
      _loadCounties();
      _loadClans();
    } else {
      _showNoInternetDialog();
    }
  },
  style: TextButton.styleFrom(
    padding: EdgeInsets.symmetric(
      horizontal: isSmallScreen ? 12 : 16,
      vertical: 8,
    ),
  ),
  child: Text(
    'إعادة المحاولة',
    style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
  ),
),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to previous screen
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: 8,
              ),
            ),
            child: Text(
              'رجوع',
              style: TextStyle(
                fontSize: isSmallScreen ? 13 : 14,
              ),
            ),
          ),
        ],
      );
    },
  );
}
@override
void initState() {
  super.initState();
  
  _animationController = AnimationController(
    duration: Duration(milliseconds: 300),
    vsync: this,
  );
  _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
  );
  _animationController.forward();

  // Check connectivity after the first frame is rendered
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final hasInternet = await _checkConnectivity();
    if (!hasInternet) {
      _showNoInternetDialog();
    } else {
      _loadCounties();
      _loadClans();
    }
  });
}
// Update _loadCounties method
Future<void> _loadCounties() async {
  final hasInternet = await _checkConnectivity();
  if (!hasInternet) {
    _showNoInternetDialog();
    return;
  }
  
  try {
    final counties = await ApiService.getCounties();
    setState(() {
      _counties = counties;
    });
  } catch (e) {
    _showErrorDialog('فشل في تحميل البلديات: $e');
  }
}

// // Update _loadClans method
// Future<void> _loadClans() async {
//   if (_clans.isNotEmpty) return;
  
//   final hasInternet = await _checkConnectivity();
//   if (!hasInternet) {
//     _showNoInternetDialog();
//     return;
//   }
  
//   try {
//     final clans = await ApiService.getAllClans();
//     setState(() {
//       _clans = clans;
//     });
//   } catch (e) {
//     _showErrorDialog('فشل في تحميل العشائر: $e');
//   }
// }

Future<void> _loadClans() async {
  if (_clans.isNotEmpty) return;
  
  final hasInternet = await _checkConnectivity();
  if (!hasInternet) {
    _showNoInternetDialog();
    return;
  }
  
  setState(() {
    _isLoadingClans = true;
  });
  


  try {
    final clans = await ApiService.getAllClans();
    setState(() {
      _clans = clans;
      _isLoadingClans = false;
    });
  } catch (e) {
    setState(() {
      _isLoadingClans = false;
    });
    _showErrorDialog('فشل في تحميل العشائر: $e');
  }
}



  // void _filterClansByCounty() {
  //   if (_selectedCounty != null) {
  //     _filteredClans = _clans.where((clan) => 
  //       clan.countyId == _selectedCounty!.id
  //     ).toList();
  //     _selectedClan = null;
  //   } else {
  //     _filteredClans = [];
  //   }
  // }

  void _filterClansByCounty() {
  if (_selectedCounty != null) {
    _filteredClans = _clans.where((clan) => 
      clan.countyId == _selectedCounty!.id
    ).toList();
    
    // Sort clans by ID in ascending order
    _filteredClans.sort((a, b) => a.id.compareTo(b.id));
    
    _selectedClan = null;
  } else {
    _filteredClans = [];
  }
}

  void _onCountyChanged(County? county) {
    setState(() {
      _selectedCounty = county;
      _filterClansByCounty();
    });
  }

  // void _showErrorDialog(String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       backgroundColor: AppColors.error,
  //       behavior: SnackBarBehavior.floating,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     ),
  //   );
  // }

//   void _showErrorDialog(String message) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         title: Row(
//           children: [
//             Icon(Icons.error_outline, color: AppColors.error, size: 28),
//             const SizedBox(width: 12),
//             const Text('خطأ'),
//           ],
//         ),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('حسناً'),
//           ),
//         ],
//       );
//     },
//   );
// }
void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final isSmallScreen = screenWidth < 360;
      
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16 : 24,
          vertical: 20,
        ),
        title: Row(
          children: [
            Icon(
              Icons.error_outline, 
              color: AppColors.error, 
              size: isSmallScreen ? 24 : 28,
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Expanded(
              child: Text(
                'تنبيه',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: isSmallScreen ? 13 : 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: 8,
              ),
            ),
            child: Text(
              'حسناً',
              style: TextStyle(
                fontSize: isSmallScreen ? 13 : 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    },
  );
}

  Future<void> _selectDate({required bool isGuardian}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale('ar', 'DZ'), 
      initialDate: DateTime.now().subtract(Duration(days: isGuardian ? 40 * 365 : 21 * 365)),
      firstDate: DateTime.now().subtract(Duration(days: isGuardian ? 100 * 365 : 80 * 365)),
      lastDate: DateTime.now().subtract(Duration(days: isGuardian ? 15 * 365 : 5 * 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isGuardian) {
          _guardianBirthDate = picked;
        } else {
          _birthDate = picked;
        }
      });
    }
  }

  // String? _validatePhone(String? value) {
  //   if (value == null || value.isEmpty) {
  //     return 'رقم الهاتف مطلوب';
  //   }
  //   if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
  //     return 'رقم الهاتف يجب أن يكون 10 أرقام';
  //   }
  //   return null;
  // }

String? _validatePhone(String? value) {

  if (value == null || value.isEmpty) {
    return 'رقم الهاتف مطلوب';
  }
  
  String phone = value.trim();
  
  if (phone.length != 10) {
    return 'رقم الهاتف يجب أن يتكون من 10 أرقام بالضبط';
  }
  
  if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
    return 'رقم الهاتف يجب أن يحتوي على أرقام فقط';
  }
  
  if (!phone.startsWith('05') && !phone.startsWith('06') && !phone.startsWith('07')) {
    return 'رقم الهاتف يجب أن يبدأ بـ 05 أو 06 أو 07';
  }
  
  return null;
}

String? _validateGuardianPhone(String? value) {
  if (value == null || value.isEmpty) {
    return 'رقم هاتف ولي الأمر مطلوب';
  }
  
  String phone = value.trim();
  
  if (phone.length != 10) {
    return 'رقم هاتف ولي الأمر يجب أن يتكون من 10 أرقام بالضبط';
  }
  
  if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
    return 'رقم الهاتف يجب أن يحتوي على أرقام فقط';
  }
  
  if (!phone.startsWith('05') && !phone.startsWith('06') && !phone.startsWith('07')) {
    return 'رقم هاتف ولي الأمر يجب أن يبدأ بـ 05 أو 06 أو 07';
  }
  
  return null;
}



Future<String?> _validateGroomPhoneAsync(String? value) async {
  // First do basic validation
  String? basicValidation = _validatePhone(value);
  if (basicValidation != null) {
    return basicValidation;
  }
  
  // Skip API check if phone is optional (SMS NOT going to groom)
  if (_selectedSmsRecipient != SmsRecipient.groom && (value == null || value.isEmpty)) {
    return null;
  }
  
  // Check if phone exists in database
  try {
    String? existenceError = await ApiService.validateGroomPhoneAvailability(value!.trim());
    return existenceError; // Returns error message if exists, null if available
  } catch (e) {
    print('Error checking groom phone: $e');
    return null; // Don't block registration on API error
  }
}

// /// Async validation for guardian phone - checks API for existing phone
// Future<String?> _validateGuardianPhoneAsync(String? value) async {
//   // First do basic validation
//   String? basicValidation = _validateGuardianPhone(value);
//   if (basicValidation != null) {
//     return basicValidation;
//   }
  
//   // Check if phone exists in database
//   try {
//     String? existenceError = await ApiService.validateGuardianPhoneAvailability(value!.trim());
//     return existenceError; // Returns error message if exists, null if available
//   } catch (e) {
//     print('Error checking guardian phone: $e');
//     return null; // Don't block registration on API error
//   }
// }


  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName مطلوب';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) {
      return 'كلمتا المرور غير متطابقتان';
    }
    return null;
  }


// // Replace the existing _validateCurrentStep method
// bool _validateCurrentStep() {
//   switch (_currentStep) {
//     case 0:
//       return _formKeys[0].currentState!.validate() && 
//             _guardianBirthDate != null && 
//             _selectedGuardianRelation != null;
//     case 1:
//       return _formKeys[1].currentState!.validate() && _birthDate != null;
//     case 2:
//       return _selectedCounty != null && _selectedClan != null;
//     case 3:
//       return _formKeys[3].currentState!.validate();
//     case 4:
//       // Validate that at least one phone number is available
//       return _SmsToGroom 
//           ? _phoneController.text.trim().isNotEmpty
//           : _guardianPhoneController.text.trim().isNotEmpty;
//     default:
//       return false;
//   }
// }

// bool _validateCurrentStep() {
//   switch (_currentStep) {
//     case 0:
//       // Explicitly validate guardian phone before form validation
//       if (_guardianPhoneController.text.trim().isEmpty) {
//         return false;
//       }
//       String? guardianPhoneError = _validateGuardianPhone(_guardianPhoneController.text);
//       if (guardianPhoneError != null) {
//         return false;
//       }
//       return _formKeys[0].currentState!.validate() && 
//             _guardianBirthDate != null && 
//             _selectedGuardianRelation != null;
//     case 1:
//       return _formKeys[1].currentState!.validate() && _birthDate != null;
//     case 2:
//       return _selectedCounty != null && _selectedClan != null;
//     case 3:
//       return _formKeys[3].currentState!.validate();
//     case 4:
//       // Validate that the selected phone number is valid
//       if (_SmsToGroom) {
//         return _validatePhone(_phoneController.text) == null;
//       } else {
//         return _validateGuardianPhone(_guardianPhoneController.text) == null;
//       }
//     default:
//       return false;
//   }
// }
Future<bool> _validateCurrentStepAsync() async {
  switch (_currentStep) {
    case 0:
      // Location step validation
      if (_selectedCounty == null) {
        _showErrorDialog('يرجى اختيار القصر');
        return false;
      }
      if (_selectedClan == null) {
        _showErrorDialog('يرجى اختيار العشيرة');
        return false;
      }
      return true;
      
    case 1:
      // Guardian info validation
      if (_guardianPhoneController.text.trim().isEmpty) {
        _showErrorDialog('رقم هاتف الولي مطلوب');
        return false;
      }
      
      // Check basic validation
      String? guardianPhoneError = _validateGuardianPhone(_guardianPhoneController.text);
      if (guardianPhoneError != null) {
        _showErrorDialog(guardianPhoneError);
        return false;
      }
      
      // // Check if phone exists in database
      // String? guardianExistenceError = await _validateGuardianPhoneAsync(_guardianPhoneController.text);
      // if (guardianExistenceError != null) {
      //   _showErrorDialog(guardianExistenceError);
      //   return false;
      // }
      
      // Validate rest of the form
      if (!_formKeys[0].currentState!.validate()) {
        return false;
      }
      
      if (_guardianBirthDate == null) {
        _showErrorDialog('يرجى اختيار تاريخ ميلاد ولي العريس');
        return false;
      }
      
      if (_selectedGuardianRelation == null) {
        _showErrorDialog('يرجى اختيار صلة القرابة');
        return false;
      }
      
      return true;
      
    case 2:
      // Personal info validation (Groom)
      if (_phoneController.text.trim().isNotEmpty || _selectedSmsRecipient == SmsRecipient.groom) {
        String? groomPhoneError = await _validateGroomPhoneAsync(_phoneController.text);
        if (groomPhoneError != null) {
          _showErrorDialog(groomPhoneError);
          return false;
        }
      }
      
      if (!_formKeys[1].currentState!.validate()) {
        return false;
      }
      
      if (_birthDate == null) {
        _showErrorDialog('يرجى اختيار تاريخ الميلاد');
        return false;
      }
      
      return true;
      
    case 3:
      // Security step validation
      return _formKeys[3].currentState!.validate();
      
    case 4:
      // Phone selection validation
      switch (_selectedSmsRecipient) {
        case SmsRecipient.groom:
          String? phoneError = await _validateGroomPhoneAsync(_phoneController.text);
          if (phoneError != null) {
            _showErrorDialog(phoneError);
            return false;
          }
          break;
        case SmsRecipient.guardian:
          // String? guardianError = await _validateGuardianPhoneAsync(_guardianPhoneController.text);
          // if (guardianError != null) {
          //   _showErrorDialog(guardianError);
          //   return false;
          // }
          break;
        case SmsRecipient.wakil:
          // String? wakilError = await _validateGroomPhoneAsync(_wakilPhoneNumberController.text);
          // if (wakilError != null) {
          //   _showErrorDialog(wakilError);
          //   return false;
          // }
          break;
      }
      return true;
      
    default:
      return false;
  }
}


//   void _nextStep() {
//   if (_validateCurrentStep()) {
//     if (_currentStep < _totalSteps - 1) {
//       setState(() {
//         _currentStep++;
//       });
//       _pageController.animateToPage(
//         _currentStep,
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     } else {
//       _signup();
//     }
//   } else {
//     if (_currentStep == 0) {
//       if (_guardianBirthDate == null) {
//         _showErrorDialog('يرجى اختيار تاريخ ميلاد ولي العريس');
//       } else if (_selectedGuardianRelation == null) {
//         _showErrorDialog('يرجى اختيار صلة القرابة');
//       }
//     } else if (_currentStep == 1 && _birthDate == null) {
//       _showErrorDialog('يرجى اختيار تاريخ الميلاد');
//     } else if (_currentStep == 2 && (_selectedCounty == null || _selectedClan == null)) {
//       _showErrorDialog('يرجى اختيار القصر والعشيرة');
//     }
//   }
// }


Future<void> _nextStep() async {
  // Show loading indicator during validation
  setState(() {
    _isLoading = true;
  });
  
  bool isValid = await _validateCurrentStepAsync();
  
  setState(() {
    _isLoading = false;
  });
  
  if (isValid) {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _signup();
    }
  }
}

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

// // Update _signup method
// Future<void> _signup() async {
//   final hasInternet = await _checkConnectivity();
//   if (!hasInternet) {
//     _showNoInternetDialog();
//     return;
//   }
  
//   setState(() {
//     _isLoading = true;
//   });

//   try {
//     final userData = {
//       'phone_number': _phoneController.text.trim(),
//       'first_name': _firstNameController.text.trim(),
//       'last_name': _lastNameController.text.trim(),
//       'father_name': _fatherNameController.text.trim(),
//       'grandfather_name': _grandfatherNameController.text.trim(),
//       'birth_date': DateFormat('yyyy-MM-dd').format(_birthDate!),
//       'birth_address': _birthAddressController.text.trim(),
//       'home_address': _homeAddressController.text.trim(),
//       'clan_id': _selectedClan!.id,
//       'county_id': _selectedCounty!.id,
//       'password': _passwordController.text,
//       'role': 'groom',
//       'guardian_name': _guardianNameController.text.trim(),
//       'guardian_phone': _guardianPhoneController.text.trim(),
//       'guardian_birth_date': DateFormat('yyyy-MM-dd').format(_guardianBirthDate!),
//       'guardian_birth_address': _guardianBirthAddressController.text.trim(),
//       'guardian_home_address': _guardianHomeAddressController.text.trim(),
//       'guardian_relation': _selectedGuardianRelation,
//       'sms_to_groom_phone' : _SmsToGroom,
//       'family_name': _familyNameController.text.trim(), // new column optional input
//       'wakil_full_name' : _wakilFullNameController.text.trim(),// new column optional input
//       'wakil_phone_number' : _wakilPhoneNumberController.text.trim(),// new column optional input
//     };

//     await ApiService.registerGroom(userData);
    
//     if (_SmsToGroom){
//       Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => OTPVerificationScreen(
//                 phoneNumber: _phoneController.text.trim(),
//               ),
//             ),
//           );

//     }else{
//       Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => OTPVerificationScreen(
//                 phoneNumber: _guardianPhoneController.text.trim(),
//               ),
//             ),
//           );
//     }
    

//   } catch (e) {
//     _showErrorDialog('فشل في التسجيل: $e');
//   } finally {
//     setState(() {
//       _isLoading = false;
//     });
//   }
// }

Future<void> _signup() async {
  final hasInternet = await _checkConnectivity();
  if (!hasInternet) {
    _showNoInternetDialog();
    return;
  }
  
  setState(() {
    _isLoading = true;
  });

  try {
    // Determine which phone receives SMS based on enum selection
    String smsRecipient;
    switch (_selectedSmsRecipient) {
      case SmsRecipient.groom:
        smsRecipient = 'groom';
        break;
      case SmsRecipient.wakil:
        smsRecipient = 'wakil';
        break;
      case SmsRecipient.guardian:
      default:
        smsRecipient = 'guardian';
        break;
    }

    final userData = {
      'phone_number': _phoneController.text.trim(),
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'father_name': _fatherNameController.text.trim(),
      'grandfather_name': _grandfatherNameController.text.trim(),
      'birth_date': DateFormat('yyyy-MM-dd').format(_birthDate!),
      'birth_address': _birthAddressController.text.trim(),
      'home_address': _homeAddressController.text.trim(),
      'clan_id': _selectedClan!.id,
      'county_id': _selectedCounty!.id,
      'password': _passwordController.text,
      'role': 'groom',
      'guardian_name': _guardianNameController.text.trim(),
      'guardian_phone': _guardianPhoneController.text.trim(),
      'guardian_birth_date': DateFormat('yyyy-MM-dd').format(_guardianBirthDate!),
      'guardian_birth_address': _guardianBirthAddressController.text.trim(),
      'guardian_home_address': _guardianHomeAddressController.text.trim(),
      'guardian_relation': _selectedGuardianRelation,
      'sms_to_groom_phone': smsRecipient, // Changed to string: 'groom', 'guardian', or 'wakil'
      'family_name': _familyNameController.text.trim(),
      'wakil_full_name': _wakilFullNameController.text.trim(),
      'wakil_phone_number': _wakilPhoneNumberController.text.trim(),
    };

    await ApiService.registerGroom(userData);
    
    // Navigate based on recipient
    String otpPhoneNumber;
    String originPhone;
    originPhone = _phoneController.text.trim();
    if (smsRecipient == 'groom') {
      otpPhoneNumber = _phoneController.text.trim();
    } else if (smsRecipient == 'wakil') {
      otpPhoneNumber = _wakilPhoneNumberController.text.trim();
    } else {
      otpPhoneNumber = _guardianPhoneController.text.trim();
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OTPVerificationScreen(
          phoneNumber: otpPhoneNumber,
          originPhone:originPhone,
        ),
      ),
    );

  } catch (e) {
    _showErrorDialog('فشل في التسجيل: $e');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}
  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          Row(
            children: List.generate(_totalSteps, (index) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: index <= _currentStep 
                        ? AppColors.primary 
                        : AppColors.primary.withOpacity(0.2),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الخطوة ${_currentStep + 1} من $_totalSteps',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${((_currentStep + 1) / _totalSteps * 100).round()}% مكتمل',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    selectedDate != null
                        ? DateFormat('dd/MM/yyyy').format(selectedDate)
                        : 'اختر التاريخ',
                    style: TextStyle(
                      color: selectedDate != null 
                          ? AppColors.textPrimary 
                          : AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTitle(String title, [String subtitle = '']) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
           
          SizedBox(height: 8),
          if (subtitle.isNotEmpty) ...[
            Text(
              subtitle,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }
// Replace the build method's AppBar section with this:
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey[50],
    appBar: AppBar(
      title: Text(
        'إنشاء حساب جديد',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      foregroundColor: AppColors.primary,
      centerTitle: true,
      automaticallyImplyLeading: _currentStep == 0,
      leading: _currentStep > 0 ? SizedBox.shrink() : null,
    ),
    body: FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildLocationStep(),        // Step 0 - Location (was step 2)
                _buildGuardianInfoStep(),    // Step 1 - Guardian (was step 0)
                _buildPersonalInfoStep(),    // Step 2 - Personal (was step 1)
                _buildSecurityStep(),        // Step 3 - Security (was step 3)
                _buildPhoneSelectionStep(),  // Step 4 - Phone Selection (was step 4)
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    ),
  );
}


  // Widget _buildPersonalInfoStep() {
  //   return SingleChildScrollView(
  //     padding: EdgeInsets.all(10),
  //     child: Form(
  //       key: _formKeys[1],
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           _buildStepTitle('المعلومات الشخصية للعريس'),
  //           SizedBox(height: 32),

  //           CustomTextField(
  //             controller: _phoneController,
  //             label: 'رقم الهاتف ',
  //             keyboardType: TextInputType.phone,
  //             validator: _validatePhone,
  //             prefixIcon: Icons.phone,
  //             hint: ' رقم هاتف العريس',
  //           ),
  //           SizedBox(height: 20),

  //           // In _buildPersonalInfoStep method, replace the phone field section with:

  //           // _AnimatedUnderlineTextField(
  //           //   controller: _phoneController,
  //           //   label: 'رقم الهاتف',
  //           //   labelColor: AppColors.textPrimary,
  //           //   boxcolor: Colors.green,
  //           //   keyboardType: TextInputType.phone,
  //           //   validator: _validatePhone,
  //           //   prefixIcon: Icons.phone,
  //           //   hint: '0xxxxxxxxx',
  //           // ),
  //           SizedBox(height: 20),


  //           Row(
  //             children: [
  //               Expanded(
  //                 child: CustomTextField(
  //                   controller: _firstNameController,
  //                   label: 'الإسم ',
  //                   validator: (value) => _validateRequired(value, 'الإسم '),
  //                   prefixIcon: Icons.person,
  //                 ),
  //               ),
  //               SizedBox(width: 16),
  //               Expanded(
  //                 child: CustomTextField(
  //                   controller: _lastNameController,
  //                   label: 'اللقب',
  //                   validator: (value) => _validateRequired(value, 'اللقب'),
  //                   prefixIcon: Icons.person_outline,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           SizedBox(height: 20),

  //           CustomTextField(
  //             controller: _fatherNameController,
  //             label: 'إسم الأب',
  //             validator: (value) => _validateRequired(value, 'إسم الأب'),
  //             prefixIcon: Icons.family_restroom,
  //           ),
  //           SizedBox(height: 20),

  //           CustomTextField(
  //             controller: _grandfatherNameController,
  //             label: 'إسم الجد الاول و الثاني',
  //             validator: (value) => _validateRequired(value, 'إسم الجد'),
  //             prefixIcon: Icons.elderly,
  //           ),
  //           SizedBox(height: 20),

  //           _buildDateSelector(
  //             label: 'تاريخ الميلاد',
  //             selectedDate: _birthDate,
  //             onTap: () => _selectDate(isGuardian: false),
  //             icon: Icons.calendar_today,
  //           ),
  //           SizedBox(height: 20),

  //           CustomTextField(
  //             controller: _birthAddressController,
  //             label: 'مكان الميلاد',
  //             validator: (value) => _validateRequired(value, 'مكان الميلاد'),
  //             prefixIcon: Icons.location_on,
  //             // hint: _birthAddressController.text,
  //           ),
  //           SizedBox(height: 20),

  //           CustomTextField(
  //             controller: _homeAddressController,
  //             label: 'عنوان السكن',
  //             validator: (value) => _validateRequired(value, 'عنوان السكن'),
  //             prefixIcon: Icons.home,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
Widget _buildPersonalInfoStep() {
  return SingleChildScrollView(
    padding: EdgeInsets.all(10),
    child: Form(
      key: _formKeys[1],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle('المعلومات الشخصية للعريس'),
          SizedBox(height: 32),

          CustomTextField(
            controller: _phoneController,
            label: 'رقم الهاتف ',
            keyboardType: TextInputType.phone,
            validator: _validatePhone,
            prefixIcon: Icons.phone,
            hint: ' رقم هاتف العريس',
          ),
          SizedBox(height: 20),

          CustomTextField(
            controller: _lastNameController,
            label: 'اللقب',
            validator: (value) => _validateRequired(value, 'اللقب'),
            prefixIcon: Icons.person_outline,
            hint: ' لقب العريس',

          ),
        
          SizedBox(height: 20),

          CustomTextField(
            controller: _firstNameController,
            label: 'الإسم ',
            validator: (value) => _validateRequired(value, 'الإسم '),
            hint: ' إسم العريس',

            prefixIcon: Icons.person,
          ),
        
          SizedBox(height: 20),

          CustomTextField(
            controller: _fatherNameController,
            label: 'إسم الأب',
            validator: (value) => _validateRequired(value, 'إسم الأب'),
            prefixIcon: Icons.family_restroom,
            hint: ' إسم أب العريس',

          ),
          SizedBox(height: 20),

          CustomTextField(
            controller: _grandfatherNameController,
            label: 'إسم الجد الاول و الثاني',
            validator: (value) => _validateRequired(value, 'إسم الجد'),
            prefixIcon: Icons.elderly,
          ),
          SizedBox(height: 20),

          // NEW FIELD: Family Name (optional)
          CustomTextField(
            controller: _familyNameController,
            label: 'اسم العائلة (اختياري)',
            prefixIcon: Icons.family_restroom_outlined,
          ),
          SizedBox(height: 20),

          _buildDateSelector(
            label: 'تاريخ الميلاد',
            selectedDate: _birthDate,
            onTap: () => _selectDate(isGuardian: false),
            icon: Icons.calendar_today,
          ),
          SizedBox(height: 20),

          CustomTextField(
            controller: _birthAddressController,
            label: 'مكان الميلاد',
            validator: (value) => _validateRequired(value, 'مكان الميلاد'),
            prefixIcon: Icons.location_on,
          ),
          SizedBox(height: 20),

          CustomTextField(
            controller: _homeAddressController,
            label: 'عنوان السكن',
            validator: (value) => _validateRequired(value, 'عنوان السكن'),
            prefixIcon: Icons.home,
          ),
        ],
      ),
    ),
  );
}
  
Widget _buildLocationStep() {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final isNotDarkMode = !isDark;
  return SingleChildScrollView(
    padding: EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle('معلومات الجهة'),
        SizedBox(height: 32),

        Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.white,
          ),
          child: DropdownButtonFormField<County>(
            value: _selectedCounty,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'القصر *',
              labelStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Container(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.location_city,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            ),
            items: _counties.map((county) {
              return DropdownMenuItem<County>(
                value: county,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      width: constraints.maxWidth,
                      child: Text(
                        county.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  },
                ),
              );
            }).toList(),
            onChanged: _onCountyChanged,
            hint: Text(
              'اختر القصر الذي تنتمي اليه',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textSecondary,
            ),
            dropdownColor: Colors.white,
          ),
        ),
        SizedBox(height: 20),
        // Replace the entire clan CustomDropdown Theme widget with this:
        Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.white,
          ),
          child: DropdownButtonFormField<Clan>(
            value: _selectedClan,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'العشيرة *',
              labelStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Container(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.groups,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              helperText: _filteredClans.isEmpty 
                  ? null 
                  : 'العشائر المتاحة في القصر المختار',
              helperStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            ),
            items: _filteredClans.map((clan) {
              return DropdownMenuItem<Clan>(
                value: clan,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      width: constraints.maxWidth,
                      child: Text(
                        clan.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  },
                ),
              );
            }).toList(),
            onChanged: _filteredClans.isEmpty 
                ? null 
                : (clan) {
                    setState(() {
                      _selectedClan = clan;
                    });
                  },
            hint: Text(
              'اختر العشيرة التي تنتمي اليها',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            icon: _isLoadingClans 
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
            dropdownColor: Colors.white,
          ),
        ),
        if (_selectedCounty != null && _filteredClans.isEmpty) ...[
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isNotDarkMode 
                  ? Colors.grey.shade800.withOpacity(0.5)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isNotDarkMode 
                    ? Colors.grey.shade700
                    : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline, 
                  color: isNotDarkMode 
                      ? Colors.grey.shade400
                      : Colors.grey.shade700,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'لا توجد عشائر مسجلة في هذه القصر حالياً',
                    style: TextStyle(
                      color: 
                          Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}


// Widget _buildGuardianInfoStep() {
//   return SingleChildScrollView(
//     padding: EdgeInsets.all(24),
//     child: Form(
//       key: _formKeys[0],
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildStepTitle('المعلومات الشخصية لولي العريس'),
//           SizedBox(height: 32),

//           CustomTextField(
//             controller: _guardianNameController,
//             label: 'الإسم الكامل',
//             hint: "الإسم اللقب, إسم الاب, الجد الاول و الثاني",
//             validator: (value) => _validateRequired(value, 'الإسم الكامل'),
//             prefixIcon: Icons.person_4,
//           ),
//           SizedBox(height: 20),

//           CustomTextField(
//             controller: _guardianPhoneController,
//             label: 'رقم الهاتف ',
//             keyboardType: TextInputType.phone,
//             validator: _validateGuardianPhone,
//             prefixIcon: Icons.phone,
//             hint: 'رقم هاتف الولي ',
//           ),
//           SizedBox(height: 20),

//           CustomDropdown<String>(
//             label: 'صلة القرابة بالعريس',
//             value: _selectedGuardianRelation,
//             hint: ' صلة القرابة بالعريس ',
//             items: AppConstants.guardianRelations.map((relation) => 
//               DropdownMenuItem<String>(
//                 value: relation,
//                 child: Text(relation),
//               )
//             ).toList(),
//             onChanged: (relation) {
//               setState(() {
//                 _selectedGuardianRelation = relation;
//               });
//             },
//             prefixIcon: Icons.family_restroom,
//           ),
//           SizedBox(height: 20),

//           _buildDateSelector(
//             label: 'تاريخ ميلاد ',
//             selectedDate: _guardianBirthDate,
//             onTap: () => _selectDate(isGuardian: true),
//             icon: Icons.calendar_today,
//           ),
//           SizedBox(height: 20),

//           CustomTextField(
//             controller: _guardianBirthAddressController,
//             label: 'مكان الميلاد ',
//             validator: (value) => _validateRequired(value, 'مكان الميلاد '),
//             prefixIcon: Icons.location_on,
//           ),
//           SizedBox(height: 20),

//           CustomTextField(
//             controller: _guardianHomeAddressController,
//             label: 'عنوان السكن ',
//             validator: (value) => _validateRequired(value, 'عنوان السكن '),
//             prefixIcon: Icons.home,
//           ),
//         ],
//       ),
//     ),
//   );
// }

Widget _buildGuardianInfoStep() {
  return SingleChildScrollView(
    padding: EdgeInsets.all(24),
    child: Form(
      key: _formKeys[0],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle('المعلومات الشخصية لولي العريس'),
          SizedBox(height: 32),

          CustomTextField(
            controller: _guardianNameController,
            label: 'الإسم الكامل',
            hint: "الإسم اللقب, إسم الاب, الجد الاول و الثاني",
            validator: (value) => _validateRequired(value, 'الإسم الكامل'),
            prefixIcon: Icons.person_4,
          ),
          SizedBox(height: 20),

          CustomTextField(
            controller: _guardianPhoneController,
            label: 'رقم الهاتف ',
            keyboardType: TextInputType.phone,
            validator: _validateGuardianPhone,
            prefixIcon: Icons.phone,
            hint: 'رقم هاتف الولي ',
          ),
          SizedBox(height: 20),

          CustomDropdown<String>(
            label: 'صلة القرابة بالعريس',
            value: _selectedGuardianRelation,
            hint: ' صلة القرابة بالعريس ',
            items: AppConstants.guardianRelations.map((relation) => 
              DropdownMenuItem<String>(
                value: relation,
                child: Text(relation),
              )
            ).toList(),
            onChanged: (relation) {
              setState(() {
                _selectedGuardianRelation = relation;
              });
            },
            prefixIcon: Icons.family_restroom,
          ),
          SizedBox(height: 20),

          _buildDateSelector(
            label: 'تاريخ ميلاد ',
            selectedDate: _guardianBirthDate,
            onTap: () => _selectDate(isGuardian: true),
            icon: Icons.calendar_today,
          ),
          SizedBox(height: 20),

          CustomTextField(
            controller: _guardianBirthAddressController,
            label: 'مكان الميلاد ',
            validator: (value) => _validateRequired(value, 'مكان الميلاد '),
            prefixIcon: Icons.location_on,
          ),
          SizedBox(height: 20),

          CustomTextField(
            controller: _guardianHomeAddressController,
            label: 'عنوان السكن ',
            validator: (value) => _validateRequired(value, 'عنوان السكن '),
            prefixIcon: Icons.home,
          ),
          
          SizedBox(height: 32),
          
          // Section header for Wakil (Representative) info
          Divider(color: AppColors.primary.withOpacity(0.3)),
          SizedBox(height: 16),
          
          Text(
            'معلومات الوكيل (اختياري)',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),

          // NEW FIELD: Wakil Full Name (optional)
          CustomTextField(
            controller: _wakilFullNameController,
            label: 'الاسم الكامل للوكيل',
            prefixIcon: Icons.person_pin,
            hint: 'أدخل الاسم الكامل للوكيل',
          ),
          SizedBox(height: 20),

          // NEW FIELD: Wakil Phone Number (optional)
          CustomTextField(
            controller: _wakilPhoneNumberController,
            label: 'رقم هاتف الوكيل',
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_android,
            hint: '05xxxxxxxx',
            validator: (value) {
              // Only validate if user entered something
              if (value != null && value.trim().isNotEmpty) {
                return _validatePhone(value);
              }
              return null; // Valid if empty (optional field)
            },
          ),
        ],
      ),
    ),
  );
}

  Widget _buildSecurityStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Form(
        key: _formKeys[3],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepTitle('معلومات الأمان', 'أنشئ كلمة مرور لحسابك , تحتاجها في كل مرة تسجل الدخول '), 
            SizedBox(height: 32),

            CustomTextField(
              controller: _passwordController,
              label: 'كلمة المرور',
              obscureText: _obscurePassword,
              validator: _validatePassword,
              prefixIcon: Icons.lock,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            SizedBox(height: 20),

            CustomTextField(
              controller: _confirmPasswordController,
              label: 'تأكيد كلمة المرور',
              obscureText: _obscureConfirmPassword,
              validator: _validateConfirmPassword,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
            SizedBox(height: 24),

            // Container(
            //   padding: EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     color: AppColors.primary.withOpacity(0.05),
            //     borderRadius: BorderRadius.circular(12),
            //     border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Row(
            //         children: [
            //           Icon(Icons.security, color: AppColors.primary),
            //           SizedBox(width: 8),
            //           Text(
            //             'متطلبات كلمة المرور',
            //             style: TextStyle(
            //               fontWeight: FontWeight.w600,
            //               color: AppColors.primary,
            //             ),
            //           ),
            //         ],
            //       ),
            //       SizedBox(height: 12),
            //       _buildPasswordRequirement('على الأقل 6 أحرف', _passwordController.text.length >= 6),
            //       _buildPasswordRequirement('تحتوي على أرقام', RegExp(r'[0-9]').hasMatch(_passwordController.text)),
            //       _buildPasswordRequirement('تحتوي على أحرف', RegExp(r'[a-zA-Z]').hasMatch(_passwordController.text)),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordRequirement(String requirement, bool isMet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isMet ? Colors.green : AppColors.textSecondary,
          ),
          SizedBox(width: 8),
          Text(
            requirement,
            style: TextStyle(
              fontSize: 14,
              color: isMet ? Colors.green : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }


// // Add this new widget method after _buildPasswordRequirement
// Widget _buildPhoneSelectionStep() {
//   return SingleChildScrollView(
//     padding: EdgeInsets.all(24),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildStepTitle(
//           'اختيار رقم الهاتف لاستقبال رمز التحقق',
//           'حدد الرقم الذي سيستقبل رسالة SMS',
//         ),
//         SizedBox(height: 32),

//         Container(
//           padding: EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: AppColors.primary.withOpacity(0.05),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(
//               color: AppColors.primary.withOpacity(0.2),
//             ),
//           ),
//           child: Column(
//             children: [
//               _buildPhoneOption(
//                 title: 'رقم هاتف الولي',
//                 phoneNumber: _guardianPhoneController.text.trim(),
//                 isSelected: !_SmsToGroom,
//                 onTap: () {
//                   setState(() {
//                     _SmsToGroom = false;
//                   });
//                 },
//                 icon: Icons.supervisor_account,
//               ),
//               SizedBox(height: 16),
//               _buildPhoneOption(
//                 title: 'رقم هاتف العريس',
//                 phoneNumber: _phoneController.text.trim(),
//                 isSelected: _SmsToGroom,
//                 onTap: () {
//                   setState(() {
//                     _SmsToGroom = true;
//                   });
//                 },
//                 icon: Icons.person,
//               ),
//             ],
//           ),
//         ),

//         SizedBox(height: 24),
        
//         Container(
//           padding: EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.blue.shade50,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.blue.shade200),
//           ),
//           child: Row(
//             children: [
//               Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
//               SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   'سيتم إرسال رمز التحقق SMS إلى الرقم المحدد',
//                   style: TextStyle(
//                     color: Colors.blue.shade900,
//                     fontSize: 13,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }

Widget _buildPhoneSelectionStep() {
  return SingleChildScrollView(
    padding: EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle(
          'اختيار رقم الهاتف لاستقبال رمز التحقق',
          'حدد الرقم الذي سيستقبل رسالة SMS',
        ),
        SizedBox(height: 32),

        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              _buildPhoneOption(
                title: 'رقم هاتف الولي',
                phoneNumber: _guardianPhoneController.text.trim(),
                isSelected: _selectedSmsRecipient == SmsRecipient.guardian,
                onTap: () {
                  setState(() {
                    _selectedSmsRecipient = SmsRecipient.guardian;
                  });
                },
                icon: Icons.supervisor_account,
              ),
              SizedBox(height: 16),
              _buildPhoneOption(
                title: 'رقم هاتف العريس',
                phoneNumber: _phoneController.text.trim(),
                isSelected: _selectedSmsRecipient == SmsRecipient.groom,
                onTap: () {
                  setState(() {
                    _selectedSmsRecipient = SmsRecipient.groom;
                  });
                },
                icon: Icons.person,
              ),
              // Show wakil option only if wakil phone is provided
              if (_wakilPhoneNumberController.text.trim().isNotEmpty) ...[
                SizedBox(height: 16),
                _buildPhoneOption(
                  title: 'رقم هاتف الوكيل',
                  phoneNumber: _wakilPhoneNumberController.text.trim(),
                  isSelected: _selectedSmsRecipient == SmsRecipient.wakil,
                  onTap: () {
                    setState(() {
                      _selectedSmsRecipient = SmsRecipient.wakil;
                    });
                  },
                  icon: Icons.person_pin,
                ),
              ],
            ],
          ),
        ),

        SizedBox(height: 24),
        
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'سيتم إرسال رمز التحقق SMS إلى الرقم المحدد',
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


Widget _buildPhoneOption({
  required String title,
  required String phoneNumber,
  required bool isSelected,
  required VoidCallback onTap,
  required IconData icon,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppColors.primary 
                  : AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.primary,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  phoneNumber.isNotEmpty ? phoneNumber : 'غير محدد',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Radio<bool>(
            value: true,
            groupValue: isSelected,
            onChanged: (_) => onTap(),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    ),
  );
}

  Widget _buildNavigationButtons() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0) ...[
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: _previousStep,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: AppColors.primary),
                  ),
                  child: Text(
                    'السابق',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: LoadingButton(
                onPressed: _nextStep,
                isLoading: _isLoading,
                text: _currentStep == _totalSteps - 1 ? 'إنشاء الحساب' : 'التالي',
                icon: Icons.arrow_forward,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    
    // Dispose all controllers
    _phoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _fatherNameController.dispose();
    _grandfatherNameController.dispose();
    _birthAddressController.dispose();
    _homeAddressController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    _guardianBirthAddressController.dispose();
    _guardianHomeAddressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    
        // NEW: Dispose new controllers
    _familyNameController.dispose();
    _wakilFullNameController.dispose();
    _wakilPhoneNumberController.dispose();

    super.dispose();
  }





}

// Add these widget classes at the end of your file

class _AnimatedUnderlineTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final Color labelColor;
  final Color boxcolor;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final IconData prefixIcon;
  final String hint;

  const _AnimatedUnderlineTextField({
    required this.controller,
    required this.label,
    required this.labelColor,
    required this.boxcolor,
    required this.keyboardType,
    this.validator,
    required this.prefixIcon,
    required this.hint,
  });

  @override
  State<_AnimatedUnderlineTextField> createState() => _AnimatedUnderlineTextFieldState();
}

class _AnimatedUnderlineTextFieldState extends State<_AnimatedUnderlineTextField> 
    with SingleTickerProviderStateMixin {
  late AnimationController _underlineController;
  late Animation<double> _underlineAnimation;
  final GlobalKey _labelKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _underlineController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _underlineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _underlineController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _underlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Text(
              widget.label,
              key: _labelKey,
              style: TextStyle(
                color: widget.labelColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Positioned(
              bottom: -4,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _underlineAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(double.infinity, 3),
                    painter: _MovingUnderlinePainter(
                      progress: _underlineAnimation.value,
                      color: Colors.green,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: widget.controller,
          label: '',
          labelColor: widget.labelColor,
          boxcolor: widget.boxcolor,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          prefixIcon: widget.prefixIcon,
          hint: widget.hint,
        ),
      ],
    );
  }
}

class _MovingUnderlinePainter extends CustomPainter {
  final double progress;
  final Color color;

  _MovingUnderlinePainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final lineWidth = size.width * 0.3;
    final startX = (size.width - lineWidth) * progress;
    final endX = startX + lineWidth;

    canvas.drawLine(
      Offset(startX, size.height / 2),
      Offset(endX, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(_MovingUnderlinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}