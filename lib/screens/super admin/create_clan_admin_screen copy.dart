// // lib/screens/super_admin/create_clan_admin_screen.dart
// import 'package:flutter/material.dart';
// import 'package:wedding_reservation_app/models/clan.dart';
// import 'package:wedding_reservation_app/services/api_service.dart';
// import '../../utils/colors.dart';

// class CreateClanAdminScreen extends StatefulWidget {
//   const CreateClanAdminScreen({super.key});

//   @override
//   _CreateClanAdminScreenState createState() => _CreateClanAdminScreenState();
// }

// class _CreateClanAdminScreenState extends State<CreateClanAdminScreen>
//     with TickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   // Form controllers
//   final _phoneController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _firstNameController = TextEditingController();
//   final _lastNameController = TextEditingController();
//   final _fatherNameController = TextEditingController();
//   final _grandfatherNameController = TextEditingController();
//   final _birthAddressController = TextEditingController();
//   final _homeAddressController = TextEditingController();

//   // Date picker
//   DateTime? _selectedBirthDate;

//   // Dropdown values
//   int? _selectedClanId;
//   int? _selectedCountyId;

//   // Data lists
//   // List<Map<String, dynamic>> _clans = [];
//   // List<Map<String, dynamic>> _counties = [];
// // Data lists
//   List<Map<String, dynamic>> _clans = [];
//   List<Map<String, dynamic>> _counties = [];
//   List<Map<String, dynamic>> _filteredClans = []; // Add this line
//   // Loading states
//   bool _isLoading = false;
//   bool _isLoadingData = true;
//   bool _passwordVisible = false;
//   bool _confirmPasswordVisible = false;

//   @override
//   void initState() {
//     super.initState();
//     _setupAnimations();
//     _loadInitialData();
//   }

//   void _setupAnimations() {
//     _animationController = AnimationController(
//       duration: Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//     _slideAnimation = Tween<Offset>(
//       begin: Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
//     _animationController.forward();
//   }

//   Future<void> _loadInitialData() async {
//     try {
//       setState(() => _isLoadingData = true);
      
//       final futures = await Future.wait([
//         _loadClans(),
//         _loadCounties(),
//       ]);

//       setState(() {
//         _clans = futures[0] as List<Map<String, dynamic>>;
//         _counties = futures[1] as List<Map<String, dynamic>>;
//         _isLoadingData = false;
//       });
//     } catch (e) {
//       setState(() => _isLoadingData = false);
//       _showErrorSnackBar('خطأ في تحميل البيانات: $e');
//     }
//   }

// Future<List<Map<String, dynamic>>> _loadClans({int? countyId}) async {
//   try {
//     List<Clan> clans;
//     if (countyId != null) {
//       clans = await ApiService.listClansByCounty(countyId);
//     } else {
//       clans = await ApiService.getAllClans();
//     }
//     return clans.map((clan) => {
//       'id': clan.id,
//       'name': clan.name,
//     }).toList();
//   } catch (e) {
//     throw Exception('فشل في تحميل العشائر');
//   }
// }
//   Future<List<Map<String, dynamic>>> _loadCounties() async {
//     try {
//       final counties = await ApiService.listCountiesAdmin();
//       return counties.map((county) => {
//         'id': county.id,
//         'name': county.name,
//       }).toList();
//     } catch (e) {
//       throw Exception('فشل في تحميل البلديات');
//     }
//   }

//   Future<void> _createClanAdmin() async {
//   if (!_formKey.currentState!.validate()) {
//     return;
//   }

//   if (_selectedClanId == null) {
//     _showErrorSnackBar('يرجى اختيار العشيرة');
//     return;
//   }

//   if (_selectedCountyId == null) {
//     _showErrorSnackBar('يرجى اختيار البلدية');
//     return;
//   }

//   if (_passwordController.text != _confirmPasswordController.text) {
//     _showErrorSnackBar('كلمات المرور غير متطابقة');
//     return;
//   }

//   try {
//     setState(() => _isLoading = true);

//     // Helper function to convert empty strings to null
//     String? nullIfEmpty(String text) {
//       return text.trim().isEmpty ? null : text.trim();
//     }

//     final result = await ApiService.createClanAdminWithDetails(
//       phoneNumber: _phoneController.text.trim(),
//       password: _passwordController.text,
//       firstName: _firstNameController.text.trim(),
//       lastName: _lastNameController.text.trim(),
//       fatherName: _fatherNameController.text.trim(),
//       grandfatherName: _grandfatherNameController.text.trim(),
//       clanId: _selectedClanId!,
//       countyId: _selectedCountyId!,
//       birthDate: _selectedBirthDate?.toIso8601String().split('T')[0],
//       birthAddress: nullIfEmpty(_birthAddressController.text),
//       homeAddress: nullIfEmpty(_homeAddressController.text),
//     );

//     _showSuccessDialog();
//   } catch (e) {
//     _showErrorSnackBar('خطأ في إنشاء الحساب: $e');
//   } finally {
//     setState(() => _isLoading = false);
//   }
// }

//   void _showSuccessDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Row(
//           children: [
//             Container(
//               padding: EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.green.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(Icons.check_circle, color: Colors.green, size: 24),
//             ),
//             SizedBox(width: 12),
//             Text(
//               'تم بنجاح',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w700,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//           ],
//         ),
//         content: Text(
//           'تم إنشاء حساب مدير العشيرة بنجاح',
//           style: TextStyle(
//             fontSize: 16,
//             color: AppColors.textSecondary,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop(); // Close dialog
//               _resetForm();
//             },
//             child: Text('إنشاء آخر'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(context).pop(); // Close dialog
//               Navigator.of(context).pop(); // Go back to previous screen
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               foregroundColor: Colors.white,
//             ),
//             child: Text('العودة'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//     );
//   }

//   void _resetForm() {
//     _formKey.currentState!.reset();
//     _phoneController.clear();
//     _passwordController.clear();
//     _confirmPasswordController.clear();
//     _firstNameController.clear();
//     _lastNameController.clear();
//     _fatherNameController.clear();
//     _grandfatherNameController.clear();
//     _birthAddressController.clear();
//     _homeAddressController.clear();
//     setState(() {
//       _selectedBirthDate = null;
//       _selectedClanId = null;
//       _selectedCountyId = null;
//       _filteredClans = []; // Add this line

//     });
//   }
// Future<void> _onCountyChanged(int? countyId) async {
//   setState(() {
//     _selectedCountyId = countyId;
//     _selectedClanId = null; // Reset clan selection
//     _filteredClans = []; // Clear filtered clans
//   });

//   if (countyId != null) {
//     try {
//       final clansForCounty = await ApiService.listClansByCounty(countyId);
//       setState(() {
//         _filteredClans = clansForCounty.map((clan) => {
//           'id': clan.id,
//           'name': clan.name,
//         }).toList();
//       });
//     } catch (e) {
//       _showErrorSnackBar('خطأ في تحميل العشائر: $e');
//     }
//   }
// }
//   Future<void> _selectBirthDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedBirthDate ?? DateTime.now().subtract(Duration(days: 18 * 365)),
//       firstDate: DateTime(1950),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: AppColors.primary,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
    
//     if (picked != null && picked != _selectedBirthDate) {
//       setState(() {
//         _selectedBirthDate = picked;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _phoneController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _fatherNameController.dispose();
//     _grandfatherNameController.dispose();
//     _birthAddressController.dispose();
//     _homeAddressController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final isTablet = screenSize.width > 600;
//     final isDesktop = screenSize.width > 1200;
    
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: _buildAppBar(isTablet, isDesktop),
//       body: _isLoadingData 
//           ? _buildLoadingState()
//           : _buildBody(isTablet, isDesktop),
//     );
//   }

//   PreferredSizeWidget _buildAppBar(bool isTablet, bool isDesktop) {
//     return AppBar(
//       title: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
//               ),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(
//               Icons.person_add,
//               color: Colors.white,
//               size: isDesktop ? 24 : 20,
//             ),
//           ),
//           SizedBox(width: 12),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'إنشاء مدير عشيرة',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w700,
//                   fontSize: isDesktop ? 22 : isTablet ? 20 : 18,
//                   letterSpacing: 0.5,
//                 ),
//               ),
//               Text(
//                 'إضافة مدير جديد للعشيرة',
//                 style: TextStyle(
//                   fontSize: isDesktop ? 12 : 10,
//                   color: AppColors.textSecondary,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       backgroundColor: Colors.white,
//       foregroundColor: AppColors.primary,
//       elevation: 0,
//       shadowColor: Colors.transparent,
//       surfaceTintColor: Colors.transparent,
//     );
//   }

//   Widget _buildLoadingState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(
//             valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
//           ),
//           SizedBox(height: 16),
//           Text(
//             'جاري تحميل البيانات...',
//             style: TextStyle(
//               fontSize: 16,
//               color: AppColors.textSecondary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBody(bool isTablet, bool isDesktop) {
//     final padding = isDesktop ? 32.0 : isTablet ? 24.0 : 16.0;
    
//     return FadeTransition(
//       opacity: _fadeAnimation,
//       child: SlideTransition(
//         position: _slideAnimation,
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(padding),
//           child: Center(
//             child: Container(
//               constraints: BoxConstraints(maxWidth: isDesktop ? 800 : double.infinity),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     _buildWelcomeCard(isTablet, isDesktop),
//                     SizedBox(height: 32),
//                     _buildPersonalInfoSection(isTablet, isDesktop),
//                     SizedBox(height: 24),
//                     _buildLocationSection(isTablet, isDesktop),
//                     SizedBox(height: 24),
//                     _buildAccountSection(isTablet, isDesktop),
//                     SizedBox(height: 32),
//                     _buildActionButtons(isTablet, isDesktop),
//                     SizedBox(height: 24),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildWelcomeCard(bool isTablet, bool isDesktop) {
//     return Container(
//       padding: EdgeInsets.all(isDesktop ? 32 : isTablet ? 28 : 24),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topRight,
//           end: Alignment.bottomLeft,
//           colors: [
//             AppColors.primary,
//             AppColors.primary.withOpacity(0.8),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primary.withOpacity(0.3),
//             offset: Offset(0, 8),
//             blurRadius: 24,
//             spreadRadius: 0,
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Icon(
//               Icons.person_add,
//               color: Colors.white,
//               size: isDesktop ? 48 : isTablet ? 40 : 32,
//             ),
//           ),
//           SizedBox(width: 20),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'إنشاء مدير عشيرة جديد',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: isDesktop ? 28 : isTablet ? 24 : 20,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   'إضافة مدير جديد لإدارة العشيرة والحجوزات',
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.9),
//                     fontSize: isDesktop ? 16 : isTablet ? 14 : 12,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPersonalInfoSection(bool isTablet, bool isDesktop) {
//     return _buildFormSection(
//       title: 'المعلومات الشخصية',
//       icon: Icons.person_outline,
//       isTablet: isTablet,
//       isDesktop: isDesktop,
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: _buildTextFormField(
//                 controller: _firstNameController,
//                 label: 'الاسم الأول',
//                 icon: Icons.person,
//                 validator: (value) {
//                   if (value?.isEmpty ?? true) {
//                     return 'الاسم الأول مطلوب';
//                   }
//                   return null;
//                 },
//                 isTablet: isTablet,
//                 isDesktop: isDesktop,
//               ),
//             ),
//             SizedBox(width: 16),
//             Expanded(
//               child: _buildTextFormField(
//                 controller: _lastNameController,
//                 label: 'اسم العائلة',
//                 icon: Icons.family_restroom,
//                 validator: (value) {
//                   if (value?.isEmpty ?? true) {
//                     return 'اسم العائلة مطلوب';
//                   }
//                   return null;
//                 },
//                 isTablet: isTablet,
//                 isDesktop: isDesktop,
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 16),
//         Row(
//           children: [
//             Expanded(
//               child: _buildTextFormField(
//                 controller: _fatherNameController,
//                 label: 'اسم الأب',
//                 icon: Icons.man,
//                 validator: (value) {
//                   if (value?.isEmpty ?? true) {
//                     return 'اسم الأب مطلوب';
//                   }
//                   return null;
//                 },
//                 isTablet: isTablet,
//                 isDesktop: isDesktop,
//               ),
//             ),
//             SizedBox(width: 16),
//             Expanded(
//               child: _buildTextFormField(
//                 controller: _grandfatherNameController,
//                 label: 'اسم الجد',
//                 icon: Icons.elderly,
//                 validator: (value) {
//                   if (value?.isEmpty ?? true) {
//                     return 'اسم الجد مطلوب';
//                   }
//                   return null;
//                 },
//                 isTablet: isTablet,
//                 isDesktop: isDesktop,
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 16),
//         _buildDateSelector(isTablet, isDesktop),
//         SizedBox(height: 16),
//         _buildTextFormField(
//           controller: _birthAddressController,
//           label: 'عنوان الميلاد (اختياري)',
//           icon: Icons.location_on_outlined,
//           isTablet: isTablet,
//           isDesktop: isDesktop,
//         ),
//         SizedBox(height: 16),
//         _buildTextFormField(
//           controller: _homeAddressController,
//           label: 'عنوان السكن (اختياري)',
//           icon: Icons.home_outlined,
//           isTablet: isTablet,
//           isDesktop: isDesktop,
//         ),
//       ],
//     );
//   }

//   Widget _buildLocationSection(bool isTablet, bool isDesktop) {
//     return _buildFormSection(
//       title: 'معلومات الموقع والعشيرة',
//       icon: Icons.location_city,
//       isTablet: isTablet,
//       isDesktop: isDesktop,
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: _buildDropdownField(
//                 value: _selectedCountyId,
//                 items: _counties,
//                 label: 'البلدية',
//                 icon: Icons.location_city,
//                 onChanged: _onCountyChanged, // Change this line

//                 isTablet: isTablet,
//                 isDesktop: isDesktop,
//               ),
//             ),
//             SizedBox(width: 16),
//             Expanded(
//               child: _buildDropdownField(
//                 value: _selectedClanId,
//                 items: _filteredClans, // Change from _clans to _filteredClans
//                 label: 'العشيرة',
//                 icon: Icons.groups,
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedClanId = value;
//                   });
//                 },
//                 isTablet: isTablet,
//                 isDesktop: isDesktop,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildAccountSection(bool isTablet, bool isDesktop) {
//     return _buildFormSection(
//       title: 'معلومات الحساب',
//       icon: Icons.security,
//       isTablet: isTablet,
//       isDesktop: isDesktop,
//       children: [
//         _buildTextFormField(
//           controller: _phoneController,
//           label: 'رقم الهاتف',
//           icon: Icons.phone,
//           keyboardType: TextInputType.phone,
//           validator: (value) {
//             if (value?.isEmpty ?? true) {
//               return 'رقم الهاتف مطلوب';
//             }
//             if (value!.length < 10) {
//               return 'رقم الهاتف يجب أن يكون 10 أرقام على الأقل';
//             }
//             return null;
//           },
//           isTablet: isTablet,
//           isDesktop: isDesktop,
//         ),
//         SizedBox(height: 16),
//         _buildPasswordField(
//           controller: _passwordController,
//           label: 'كلمة المرور',
//           isVisible: _passwordVisible,
//           onToggleVisibility: () {
//             setState(() {
//               _passwordVisible = !_passwordVisible;
//             });
//           },
//           validator: (value) {
//             if (value?.isEmpty ?? true) {
//               return 'كلمة المرور مطلوبة';
//             }
//             if (value!.length < 8) {
//               return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
//             }
//             return null;
//           },
//           isTablet: isTablet,
//           isDesktop: isDesktop,
//         ),
//         SizedBox(height: 16),
//         _buildPasswordField(
//           controller: _confirmPasswordController,
//           label: 'تأكيد كلمة المرور',
//           isVisible: _confirmPasswordVisible,
//           onToggleVisibility: () {
//             setState(() {
//               _confirmPasswordVisible = !_confirmPasswordVisible;
//             });
//           },
//           validator: (value) {
//             if (value?.isEmpty ?? true) {
//               return 'تأكيد كلمة المرور مطلوب';
//             }
//             if (value != _passwordController.text) {
//               return 'كلمات المرور غير متطابقة';
//             }
//             return null;
//           },
//           isTablet: isTablet,
//           isDesktop: isDesktop,
//         ),
//       ],
//     );
//   }

//   Widget _buildFormSection({
//     required String title,
//     required IconData icon,
//     required List<Widget> children,
//     required bool isTablet,
//     required bool isDesktop,
//   }) {
//     return Container(
//       padding: EdgeInsets.all(isDesktop ? 28 : isTablet ? 24 : 20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             offset: Offset(0, 4),
//             blurRadius: 16,
//             spreadRadius: 0,
//           ),
//         ],
//         border: Border.all(
//           color: Colors.grey.withOpacity(0.1),
//           width: 1,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   icon,
//                   color: AppColors.primary,
//                   size: isDesktop ? 24 : 20,
//                 ),
//               ),
//               SizedBox(width: 12),
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: isDesktop ? 20 : isTablet ? 18 : 16,
//                   fontWeight: FontWeight.w700,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 20),
//           ...children,
//         ],
//       ),
//     );
//   }

//   Widget _buildTextFormField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     TextInputType? keyboardType,
//     String? Function(String?)? validator,
//     required bool isTablet,
//     required bool isDesktop,
//   }) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: keyboardType,
//       validator: validator,
//       style: TextStyle(
//         fontSize: isDesktop ? 16 : isTablet ? 15 : 14,
//       ),
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: AppColors.primary),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: AppColors.primary, width: 2),
//         ),
//         filled: true,
//         fillColor: Colors.grey.withOpacity(0.05),
//         contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       ),
//     );
//   }

//   Widget _buildPasswordField({
//     required TextEditingController controller,
//     required String label,
//     required bool isVisible,
//     required VoidCallback onToggleVisibility,
//     String? Function(String?)? validator,
//     required bool isTablet,
//     required bool isDesktop,
//   }) {
//     return TextFormField(
//       controller: controller,
//       obscureText: !isVisible,
//       validator: validator,
//       style: TextStyle(
//         fontSize: isDesktop ? 16 : isTablet ? 15 : 14,
//       ),
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
//         suffixIcon: IconButton(
//           icon: Icon(
//             isVisible ? Icons.visibility_off : Icons.visibility,
//             color: AppColors.primary,
//           ),
//           onPressed: onToggleVisibility,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: AppColors.primary, width: 2),
//         ),
//         filled: true,
//         fillColor: Colors.grey.withOpacity(0.05),
//         contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       ),
//     );
//   }

//   Widget _buildDropdownField({
//     required int? value,
//     required List<Map<String, dynamic>> items,
//     required String label,
//     required IconData icon,
//     required ValueChanged<int?> onChanged,
//     required bool isTablet,
//     required bool isDesktop,
//   }) {
//     return DropdownButtonFormField<int>(
//       value: value,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: AppColors.primary),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: AppColors.primary, width: 2),
//         ),
//         filled: true,
//         fillColor: Colors.grey.withOpacity(0.05),
//         contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       ),
//       items: items.map((item) {
//         return DropdownMenuItem<int>(
//           value: item['id'],
//           child: Text(
//             item['name'],
//             style: TextStyle(
//               fontSize: isDesktop ? 16 : isTablet ? 15 : 14,
//             ),
//           ),
//         );
//       }).toList(),
//       onChanged: onChanged,
//       validator: (value) {
//         if (value == null) {
//           return 'يرجى اختيار $label';
//         }
//         return null;
//       },
//     );
//   }

//   Widget _buildDateSelector(bool isTablet, bool isDesktop) {
//     return InkWell(
//       onTap: _selectBirthDate,
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey.withOpacity(0.3)),
//           borderRadius: BorderRadius.circular(12),
//           color: Colors.grey.withOpacity(0.05),
//         ),
//         child: Row(
//           children: [
//             Icon(Icons.calendar_today, color: AppColors.primary),
//             SizedBox(width: 16),
//             Expanded(
//               child: Text(
//                 _selectedBirthDate == null
//                     ? 'تاريخ الميلاد (اختياري)'
//                     : '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}',
//                 style: TextStyle(
//                   fontSize: isDesktop ? 16 : isTablet ? 15 : 14,
//                   color: _selectedBirthDate == null
//                       ? Colors.grey[600]
//                       : AppColors.textPrimary,
//                 ),
//               ),
//             ),
//             Icon(Icons.arrow_drop_down, color: AppColors.primary),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButtons(bool isTablet, bool isDesktop) {
//     return Row(
//       children: [
//         Expanded(
//           child: OutlinedButton.icon(
//             onPressed: _isLoading ? null : () {
//               Navigator.of(context).pop();
//             },
//             icon: Icon(Icons.arrow_back),
//             label: Text('العودة'),
//             style: OutlinedButton.styleFrom(
//               padding: EdgeInsets.symmetric(vertical: 16),
//               side: BorderSide(color: AppColors.primary),
//               foregroundColor: AppColors.primary,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               textStyle: TextStyle(
//                 fontSize: isDesktop ? 18 : isTablet ? 16 : 14,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ),
//         SizedBox(width: 16),
//         Expanded(
//           flex: 2,
//           child: ElevatedButton.icon(
//             onPressed: _isLoading ? null : _createClanAdmin,
//             icon: _isLoading
//                 ? SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                     ),
//                   )
//                 : Icon(Icons.person_add),
//             label: Text(_isLoading ? 'جاري الإنشاء...' : 'إنشاء المدير'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               foregroundColor: Colors.white,
//               padding: EdgeInsets.symmetric(vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               elevation: 2,
//               shadowColor: AppColors.primary.withOpacity(0.3),
//               textStyle: TextStyle(
//                 fontSize: isDesktop ? 18 : isTablet ? 16 : 14,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }