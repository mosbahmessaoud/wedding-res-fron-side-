// // lib/screens/home/tabs/profile_tab.dart
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:wedding_reservation_app/models/clan.dart';
// import 'package:wedding_reservation_app/models/county.dart';

// import '../../../services/api_service.dart';
// import '../../../utils/colors.dart';

// class ProfileTab extends StatefulWidget {
//   const ProfileTab({super.key});

//   @override
//   State<ProfileTab> createState() => ProfileTabState();
// }

// class ProfileTabState extends State<ProfileTab> {
//   bool _isLoading = true;
//   Map<String, dynamic>? _userProfile;
//   Map<String, dynamic>? _clanInfo;
//   Map<String, dynamic>? _countyInfo;
//   bool _canUpdateProfile = false;
//   String? _updateBlockReason;

//   // ADD THESE CACHE VARIABLES:
//   Map<String, dynamic>? _cachedUserProfile;
//   Map<String, dynamic>? _cachedClanInfo;
//   Map<String, dynamic>? _cachedCountyInfo;
//   bool _hasLoadedOnce = false;

//   @override
//   void initState() {
//     super.initState();
    
//     // Show cached data immediately
//     _loadCachedData();
    
//     // Load fresh data in background
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadProfileInBackground();
//     });
//   }

//   Future<void> refreshData() async {
//     await _loadProfileInBackground();
//   }

//   // ============================================
//   // 2. ADD: Load cached data method (instant)
//   // ============================================

//   void _loadCachedData() {
//     setState(() {
//       _userProfile = _cachedUserProfile;
//       _clanInfo = _cachedClanInfo;
//       _countyInfo = _cachedCountyInfo;
//       _isLoading = _cachedUserProfile == null && !_hasLoadedOnce;
//     });
//   }


//   // ============================================
//   // 4. ADD: Background loading method (non-blocking)
//   // ============================================

//   Future<void> _loadProfileInBackground() async {
//     try {
//       // Don't show loading spinner if we have cached data
//       if (_cachedUserProfile == null) {
//         setState(() => _isLoading = true);
//       }
      
//       // ✅ CHANGED: Use new API endpoint
//       _userProfile = await ApiService.getMyGroomProfile();
//       _cachedUserProfile = _userProfile;
      
//       // Check if profile can be updated
//       await _checkUpdateEligibility();
      
//       // Load clan and county information in parallel
//       await Future.wait([
//         _loadClanInfo(),
//         _loadCountyInfo(),
//       ]);
      
//       _hasLoadedOnce = true;
      
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     } catch (e) {
//       print('Error loading profile: $e');
//       // Keep cached data on error
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   // ✅ NEW: Check if profile can be updated
//   Future<void> _checkUpdateEligibility() async {
//     try {
//       final result = await ApiService.canUpdateGroomProfile();
      
//       if (mounted) {
//         setState(() {
//           _canUpdateProfile = result['can_update'] == true;
//           _updateBlockReason = result['reason'];
//         });
//       }
//     } catch (e) {
//       print('Error checking update eligibility: $e');
//       if (mounted) {
//         setState(() {
//           _canUpdateProfile = false;
//           _updateBlockReason = 'خطأ في التحقق من إمكانية التحديث';
//         });
//       }
//     }
//   }

//   Future<void> _checkConnectivityAndLoad() async {
//     // Show cached data first
//     _loadCachedData();
    
//     final connectivityResult = await Connectivity().checkConnectivity();
    
//     if (connectivityResult.contains(ConnectivityResult.none)) {
//       _showNoInternetDialog();
//       return;
//     }
    
//     // Load fresh data in background
//     await _loadProfileInBackground();
//   }

//   void _showNoInternetDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(
//           children: [
//             Icon(Icons.wifi_off, color: Colors.orange),
//             SizedBox(width: 10),
//             Text('لا يوجد اتصال'),
//           ],
//         ),
//         content: Text('يرجى التحقق من اتصالك بالإنترنت'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _checkConnectivityAndLoad();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//             child: Text('إعادة المحاولة', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _loadProfile() async {
//     await _loadProfileInBackground();
//   }

//   Future<void> _loadClanInfo() async {
//     if (_userProfile?['clan_id'] == null) return;
    
//     try {
//       final clans = await ApiService.getClans();
//       final foundClan = clans.cast<Clan?>().firstWhere(
//         (clan) => clan?.id == _userProfile?['clan_id'],
//         orElse: () => null,
//       );
//       _clanInfo = foundClan?.toJson();
//       _cachedClanInfo = _clanInfo; // Cache it
//     } catch (e) {
//       // Keep cached data on error
//     }
//   }

//   Future<void> _loadCountyInfo() async {
//     if (_userProfile?['county_id'] == null) return;
    
//     try {
//       final counties = await ApiService.getCounties();
//       final foundCounty = counties.cast<County?>().firstWhere(
//         (county) => county?.id == _userProfile?['county_id'],
//         orElse: () => null,
//       );
//       _countyInfo = foundCounty?.toJson();
//       _cachedCountyInfo = _countyInfo; // Cache it
//     } catch (e) {
//       // Keep cached data on error
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Show loading only on first load with no cache
//     if (_isLoading && _cachedUserProfile == null) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     // Show cached or fresh data
//     return PopScope(
//       canPop: false,
//       onPopInvokedWithResult: (bool didPop, Object? result) {
//         // Do nothing - completely block back navigation
//         return;
//       },
//       child: RefreshIndicator(
//         onRefresh: _loadProfileInBackground,
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildProfileHeader(),
//               const SizedBox(height: 24),
//               _buildLocationInfo(),
//               const SizedBox(height: 24),
//               // ✅ THREE SECTIONS
//               _buildGroomInfoSection(),
//               const SizedBox(height: 24),
//               _buildGuardianInfoSection(),
//               const SizedBox(height: 24),
//               _buildWakilInfoSection(),
//               const SizedBox(height: 24),
//               _buildActionButtons(),
//               const SizedBox(height: 60),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProfileHeader() {
//     final fullName = '${_userProfile?['first_name'] ?? ''} ${_userProfile?['last_name'] ?? ''}'.trim();    
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             AppColors.primary,
//             AppColors.primary.withOpacity(0.8),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         children: [
//           CircleAvatar(
//             radius: 40,
//             backgroundColor: Colors.white.withOpacity(0.2),
//             child: Icon(
//               Icons.person,
//               size: 40,
//               color: Colors.white,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             fullName.isNotEmpty ? fullName : 'العريس',
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             _userProfile?['phone_number'] ?? '',
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.9),
//               fontSize: 16,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLocationInfo() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'معلومات الموقع',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.primary,
//               ),
//             ),
//             const SizedBox(height: 16),
//             _buildInfoRow(
//               Icons.location_city,
//               'القصر',
//               _countyInfo?['name'] ?? 'غير محدد',
//             ),
//             const SizedBox(height: 12),
//             _buildInfoRow(
//               Icons.group,
//               'العشيرة',
//               _clanInfo?['name'] ?? 'غير محدد',
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ✅ NEW: Groom Personal Information Section
//   Widget _buildGroomInfoSection() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'معلومات العريس',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.primary,
//                   ),
//                 ),
//                 // ✅ Edit button with update eligibility check
//                 IconButton(
//                   icon: Icon(
//                     Icons.edit,
//                     color: _canUpdateProfile ? AppColors.primary : Colors.grey,
//                   ),
//                   onPressed: _canUpdateProfile ? () => _showEditGroomDialog() : _showCannotEditDialog,
//                   tooltip: _canUpdateProfile ? 'تعديل معلومات العريس' : 'لا يمكن التعديل',
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
            
//             _buildInfoRow(
//               Icons.person,
//               'الاسم الأول',
//               _userProfile?['first_name'] ?? 'غير محدد',
//             ),
//             const SizedBox(height: 12),
            
//             _buildInfoRow(
//               Icons.person_outline,
//               'اسم العائلة',
//               _userProfile?['last_name'] ?? 'غير محدد',
//             ),
//             const SizedBox(height: 12),
            
//             _buildInfoRow(
//               Icons.person,
//               'اسم الأب',
//               _userProfile?['father_name'] ?? 'غير محدد',
//             ),
//             const SizedBox(height: 12),
            
//             _buildInfoRow(
//               Icons.person,
//               'اسم الجد',
//               _userProfile?['grandfather_name'] ?? 'غير محدد',
//             ),
//             const SizedBox(height: 12),
            
//             _buildInfoRow(
//               Icons.phone,
//               'رقم الهاتف',
//               _userProfile?['phone_number'] ?? 'غير محدد',
//             ),
//             const SizedBox(height: 12),
            
//             _buildInfoRow(
//               Icons.calendar_today,
//               'تاريخ الميلاد',
//               _userProfile?['birth_date'] ?? 'غير محدد',
//             ),
//             const SizedBox(height: 12),
            
//             _buildInfoRow(
//               Icons.location_on,
//               'مكان الميلاد',
//               _userProfile?['birth_address'] ?? 'غير محدد',
//             ),
//             const SizedBox(height: 12),
            
//             _buildInfoRow(
//               Icons.home,
//               'عنوان السكن',
//               _userProfile?['home_address'] ?? 'غير محدد',
//             ),
            
//             // ✅ NEW: Family name field
//             if (_userProfile?['family_name'] != null && _userProfile!['family_name'].toString().isNotEmpty) ...[
//               const SizedBox(height: 12),
//               _buildInfoRow(
//                 Icons.family_restroom,
//                 'اسم العائلة',
//                 _userProfile?['family_name'] ?? 'غير محدد',
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   } 

//   // ✅ NEW: Guardian Information Section
//   Widget _buildGuardianInfoSection() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'معلومات ولي الأمر',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.primary,
//                   ),
//                 ),
//                 // ✅ Edit button
//                 IconButton(
//                   icon: Icon(
//                     Icons.edit,
//                     color: _canUpdateProfile ? AppColors.primary : Colors.grey,
//                   ),
//                   onPressed: _canUpdateProfile ? () => _showEditGuardianDialog() : _showCannotEditDialog,
//                   tooltip: _canUpdateProfile ? 'تعديل معلومات الولي' : 'لا يمكن التعديل',
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
            
//             _buildInfoRow(
//               Icons.person,
//               'اسم الولي',
//               _userProfile?['guardian_name'] ?? 'غير محدد',
//             ),
//             const SizedBox(height: 12),
            
//             _buildInfoRow(
//               Icons.phone,
//               'هاتف الولي',
//               _userProfile?['guardian_phone'] ?? 'غير محدد',
//             ),
//             const SizedBox(height: 12),
            
//             _buildInfoRow(
//               Icons.calendar_today,
//               'تاريخ ميلاد الولي',
//               _userProfile?['guardian_birth_date'] ?? 'غير محدد',
//             ),
//             const SizedBox(height: 12),
            
//             _buildInfoRow(
//               Icons.location_on,
//               'مكان ميلاد الولي',
//               _userProfile?['guardian_birth_address'] ?? 'غير محدد',
//             ),
//             const SizedBox(height: 12),
            
//             _buildInfoRow(
//               Icons.home,
//               'عنوان سكن الولي',
//               _userProfile?['guardian_home_address'] ?? 'غير محدد',
//             ),
//             const SizedBox(height: 12),
            
//             _buildInfoRow(
//               Icons.family_restroom,
//               'صلة القرابة',
//               _userProfile?['guardian_relation'] ?? 'غير محدد',
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ✅ NEW: Wakil (Wedding Representative) Information Section
//   Widget _buildWakilInfoSection() {
//     // Only show if wakil info exists
//     final hasWakilInfo = _userProfile?['wakil_full_name'] != null && 
//                          _userProfile!['wakil_full_name'].toString().isNotEmpty;
    
//     if (!hasWakilInfo) {
//       return Card(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'معلومات وكيل العرس',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.primary,
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(
//                       Icons.add,
//                       color: _canUpdateProfile ? AppColors.primary : Colors.grey,
//                     ),
//                     onPressed: _canUpdateProfile ? () => _showEditWakilDialog() : _showCannotEditDialog,
//                     tooltip: _canUpdateProfile ? 'إضافة معلومات الوكيل' : 'لا يمكن الإضافة',
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Center(
//                 child: Text(
//                   'لم يتم إضافة معلومات وكيل العرس',
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'معلومات وكيل العرس',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.primary,
//                   ),
//                 ),
//                 // ✅ Edit button
//                 IconButton(
//                   icon: Icon(
//                     Icons.edit,
//                     color: _canUpdateProfile ? AppColors.primary : Colors.grey,
//                   ),
//                   onPressed: _canUpdateProfile ? () => _showEditWakilDialog() : _showCannotEditDialog,
//                   tooltip: _canUpdateProfile ? 'تعديل معلومات الوكيل' : 'لا يمكن التعديل',
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
            
//             _buildInfoRow(
//               Icons.person_pin,
//               'الاسم الكامل',
//               _userProfile?['wakil_full_name'] ?? 'غير محدد',
//             ),
//             const SizedBox(height: 12),
            
//             _buildInfoRow(
//               Icons.phone,
//               'رقم الهاتف',
//               _userProfile?['wakil_phone_number'] ?? 'غير محدد',
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String label, String value) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Row(
//       children: [
//         Icon(icon, size: 20, color: isDark ? AppColors.primaryLight : AppColors.primary),
//         const SizedBox(width: 12),
//         Text(
//           '$label: ',
//           style: TextStyle(
//             fontWeight: FontWeight.w500,
//             color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
//           ),
//         ),
//         Expanded(
//           child: Text(
//             value,
//             style: TextStyle(
//               color: isDark ? AppColors.darkTextHint : AppColors.darkCard,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ✅ NEW: Show dialog explaining why profile cannot be edited
//   void _showCannotEditDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(
//           children: [
//             Icon(Icons.block, color: Colors.orange),
//             SizedBox(width: 10),
//             Text('لا يمكن التعديل'),
//           ],
//         ),
//         content: Text(
//           _updateBlockReason ?? 'لا يمكن تعديل الملف الشخصي في الوقت الحالي',
//           textAlign: TextAlign.right,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('حسناً'),
//           ),
//         ],
//       ),
//     );
//   }

//   // ✅ NEW: Edit Groom Info Dialog
//   void _showEditGroomDialog() {
//     final firstNameController = TextEditingController(text: _userProfile?['first_name']);
//     final lastNameController = TextEditingController(text: _userProfile?['last_name']);
//     final birthAddressController = TextEditingController(text: _userProfile?['birth_address']);
//     final homeAddressController = TextEditingController(text: _userProfile?['home_address']);
//     final familyNameController = TextEditingController(text: _userProfile?['family_name']);

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(
//           children: [
//             Icon(Icons.edit, color: AppColors.primary),
//             SizedBox(width: 10),
//             Text('تعديل معلومات العريس'),
//           ],
//         ),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: firstNameController,
//                 decoration: InputDecoration(
//                   labelText: 'الاسم الأول',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//               SizedBox(height: 12),
//               TextField(
//                 controller: lastNameController,
//                 decoration: InputDecoration(
//                   labelText: 'اسم العائلة',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//               SizedBox(height: 12),
//               TextField(
//                 controller: birthAddressController,
//                 decoration: InputDecoration(
//                   labelText: 'مكان الميلاد',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//               SizedBox(height: 12),
//               TextField(
//                 controller: homeAddressController,
//                 decoration: InputDecoration(
//                   labelText: 'عنوان السكن',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//               SizedBox(height: 12),
//               TextField(
//                 controller: familyNameController,
//                 decoration: InputDecoration(
//                   labelText: 'اسم العائلة (اختياري)',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await _updateProfile(
//                 firstName: firstNameController.text.trim(),
//                 lastName: lastNameController.text.trim(),
//                 birthAddress: birthAddressController.text.trim(),
//                 homeAddress: homeAddressController.text.trim(),
//                 familyName: familyNameController.text.trim().isEmpty ? null : familyNameController.text.trim(),
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//             child: Text('حفظ', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   // ✅ NEW: Edit Guardian Info Dialog
//   void _showEditGuardianDialog() {
//     final guardianNameController = TextEditingController(text: _userProfile?['guardian_name']);
//     final guardianPhoneController = TextEditingController(text: _userProfile?['guardian_phone']);
//     final guardianBirthAddressController = TextEditingController(text: _userProfile?['guardian_birth_address']);
//     final guardianHomeAddressController = TextEditingController(text: _userProfile?['guardian_home_address']);
//     final guardianRelationController = TextEditingController(text: _userProfile?['guardian_relation']);

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(
//           children: [
//             Icon(Icons.edit, color: AppColors.primary),
//             SizedBox(width: 10),
//             Text('تعديل معلومات الولي'),
//           ],
//         ),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: guardianNameController,
//                 decoration: InputDecoration(
//                   labelText: 'اسم الولي',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//               SizedBox(height: 12),
//               TextField(
//                 controller: guardianPhoneController,
//                 decoration: InputDecoration(
//                   labelText: 'هاتف الولي',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//                 keyboardType: TextInputType.phone,
//               ),
//               SizedBox(height: 12),
//               TextField(
//                 controller: guardianBirthAddressController,
//                 decoration: InputDecoration(
//                   labelText: 'مكان ميلاد الولي',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//               SizedBox(height: 12),
//               TextField(
//                 controller: guardianHomeAddressController,
//                 decoration: InputDecoration(
//                   labelText: 'عنوان سكن الولي',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//               SizedBox(height: 12),
//               TextField(
//                 controller: guardianRelationController,
//                 decoration: InputDecoration(
//                   labelText: 'صلة القرابة',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await _updateProfile(
//                 guardianName: guardianNameController.text.trim(),
//                 guardianPhone: guardianPhoneController.text.trim(),
//                 guardianBirthAddress: guardianBirthAddressController.text.trim(),
//                 guardianHomeAddress: guardianHomeAddressController.text.trim(),
//                 guardianRelation: guardianRelationController.text.trim(),
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//             child: Text('حفظ', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   // ✅ NEW: Edit Wakil Info Dialog
//   void _showEditWakilDialog() {
//     final wakilNameController = TextEditingController(text: _userProfile?['wakil_full_name']);
//     final wakilPhoneController = TextEditingController(text: _userProfile?['wakil_phone_number']);

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(
//           children: [
//             Icon(Icons.edit, color: AppColors.primary),
//             SizedBox(width: 10),
//             Text('تعديل معلومات الوكيل'),
//           ],
//         ),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: wakilNameController,
//                 decoration: InputDecoration(
//                   labelText: 'الاسم الكامل للوكيل',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//               SizedBox(height: 12),
//               TextField(
//                 controller: wakilPhoneController,
//                 decoration: InputDecoration(
//                   labelText: 'رقم هاتف الوكيل',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//                 keyboardType: TextInputType.phone,
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await _updateProfile(
//                 wakilFullName: wakilNameController.text.trim().isEmpty ? null : wakilNameController.text.trim(),
//                 wakilPhoneNumber: wakilPhoneController.text.trim().isEmpty ? null : wakilPhoneController.text.trim(),
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//             child: Text('حفظ', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   // ✅ NEW: Update profile method
//   Future<void> _updateProfile({
//     String? firstName,
//     String? lastName,
//     String? birthAddress,
//     String? homeAddress,
//     String? guardianName,
//     String? guardianPhone,
//     String? guardianBirthAddress,
//     String? guardianHomeAddress,
//     String? guardianRelation,
//     String? wakilFullName,
//     String? wakilPhoneNumber,
//     String? familyName,
//   }) async {
//     // Show loading
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => Center(child: CircularProgressIndicator()),
//     );

//     try {
//       // Call API to update profile
//       await ApiService.updateGroomProfileDetails(
//         firstName: firstName,
//         lastName: lastName,
//         birthAddress: birthAddress,
//         homeAddress: homeAddress,
//         guardianName: guardianName,
//         guardianPhone: guardianPhone,
//         guardianBirthAddress: guardianBirthAddress,
//         guardianHomeAddress: guardianHomeAddress,
//         guardianRelation: guardianRelation,
//         wakilFullName: wakilFullName,
//         wakilPhoneNumber: wakilPhoneNumber,
//         familyName: familyName,
//       );

//       // Hide loading
//       Navigator.pop(context);

//       // Refresh profile data
//       await _loadProfileInBackground();

//       // Show success message
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('تم تحديث الملف الشخصي بنجاح'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       // Hide loading
//       Navigator.pop(context);

//       // Show error message
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('خطأ في تحديث الملف الشخصي: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   Widget _buildActionButtons() {
//     return Column(
//       children: [
//         // Account Actions
//         Card(
//           child: Column(
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.notifications, color: AppColors.primary),
//                 title: const Text('الإشعارات'),
//                 trailing: const Icon(Icons.chevron_right),
//                 onTap: _showNotificationSettings,
//               ),
//               const Divider(height: 1),
//               ListTile(
//                 leading: const Icon(Icons.security, color: AppColors.primary),
//                 title: const Text('اخر اخبار العشيرة'),
//                 trailing: const Icon(Icons.chevron_right),
//                 onTap: _showNewsClan,
//               ),
//               const Divider(height: 1),
//               ListTile(
//                 leading: const Icon(Icons.help, color: AppColors.primary),
//                 title: const Text('المساعدة والدعم'),
//                 trailing: const Icon(Icons.chevron_right),
//                 onTap: _showHelpSupport,
//               ),
//               const Divider(height: 1),
//               ListTile(
//                 leading: const Icon(Icons.info, color: AppColors.primary),
//                 title: const Text('حول التطبيق'),
//                 trailing: const Icon(Icons.chevron_right),
//                 onTap: _showAboutApp,
//               ),
//             ],
//           ),
//         ),
        
//         const SizedBox(height: 16),
        
//         // Danger Zone
//         Card(
//           child: Column(
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.logout, color: Colors.orange),
//                 title: const Text('تسجيل الخروج'),
//                 onTap: _showLogoutDialog,
//               ),
//               const Divider(height: 1),
//               ListTile(
//                 leading: const Icon(Icons.delete_forever, color: Colors.red),
//                 title: const Text('حذف الحساب'),
//                 onTap: _showDeleteAccountDialog,
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   void _showNotificationSettings() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text(
//             'إعدادات الإشعارات',
//             textAlign: TextAlign.right,
//           ),
//           content: const Text(
//             'هذه الميزة قيد التطوير حالياً. سيتم إضافتها قريباً.',
//             textAlign: TextAlign.right,
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('حسناً'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showNewsClan() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text(
//             'أخبار العشيرة',
//             textAlign: TextAlign.right,
//           ),
//           content: const Text(
//             'هذه الصفحة قيد التطوير حالياً. سيتم إضافتها قريباً.',
//             textAlign: TextAlign.right,
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('حسناً'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Helper functions
//   Future<void> _launchWhatsApp() async {
//     final Uri whatsappUri = Uri.parse('https://wa.me/213542951750');
//     if (!await launchUrl(whatsappUri, mode: LaunchMode.externalApplication)) {
//       throw Exception('Could not launch WhatsApp');
//     }
//   }

//   Future<void> _launchEmail() async {
//     final Uri emailUri = Uri.parse('mailto:itridev.soft@gmail.com');
//     if (!await launchUrl(emailUri)) {
//       throw Exception('Could not launch email');
//     }
//   }

//   Future<void> _launchPhone() async {
//     final Uri phoneUri = Uri.parse('tel:+213542951750');
//     if (!await launchUrl(phoneUri)) {
//       throw Exception('Could not launch phone');
//     }
//   }

//   void _showAboutApp() {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(2),
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(Icons.info, color: AppColors.primary, size: 24),
//             ),
//             const SizedBox(width: 12),
//             const Text('حول التطبيق', style: TextStyle(fontSize: 20)),
//           ],
//         ),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'تطبيق حجوزات الأعراس الخاص بجميع العشائر',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 12),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: isDark ? Colors.grey[800] : Colors.grey[100],
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Text('الإصدار: 1.0.5', style: TextStyle(fontSize: 14)),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'يسرّنا أن نرحب بكم في تطبيق الأعراس، ونضع بين أيديكم وسيلة ميسرة لتنظيم وحجز العرس الخاص بكم',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: isDark ? Colors.grey[300] : Colors.grey[700],
//                   height: 1.5,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               const Divider(),
//               const SizedBox(height: 16),
//               const Text(
//                 'برعاية:',
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//               ),
//               const SizedBox(height: 8),
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       AppColors.primary.withOpacity(0.1),
//                       AppColors.primary.withOpacity(0.05),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Text(
//                   'عشيرة آت الشيخ الحاج مسعود',
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               const Divider(),
//               const SizedBox(height: 16),
//               const Text(
//                 'فريق التطوير',
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//               ),
//               const SizedBox(height: 12),
              
//               // Email Button
//               InkWell(
//                 onTap: _launchEmail,
//                 borderRadius: BorderRadius.circular(12),
//                 child: Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: isDark ? Colors.blue[900]?.withOpacity(0.3) : Colors.blue[50],
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: Colors.blue.withOpacity(0.3),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: Colors.blue,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: const Icon(Icons.email, size: 18, color: Colors.white),
//                       ),
//                       const SizedBox(width: 12),
//                       const Expanded(
//                         child: Text(
//                           'itridev.soft@gmail.com',
//                           style: TextStyle(
//                             color: Colors.blue,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                       const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.blue),
//                     ],
//                   ),
//                 ),
//               ),
              
//               const SizedBox(height: 12),
              
//               // WhatsApp Button
//               InkWell(
//                 onTap: _launchWhatsApp,
//                 borderRadius: BorderRadius.circular(12),
//                 child: Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: isDark ? Colors.green[900]?.withOpacity(0.3) : Colors.green[50],
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: Colors.green.withOpacity(0.3),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: Colors.green[700],
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: const Icon(Icons.phone, size: 18, color: Colors.white),
//                       ),
//                       const SizedBox(width: 12),
//                       const Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'واتساب',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w400,
//                               ),
//                             ),
//                             Text(
//                               '0542951750',
//                               style: TextStyle(
//                                 color: Colors.green,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.green),
//                     ],
//                   ),
//                 ),
//               ),
              
//               const SizedBox(height: 16),
              
//               // Info Box
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: isDark ? Colors.green[900]?.withOpacity(0.2) : Colors.green[50],
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: isDark ? Colors.green[700]! : Colors.green[200]!,
//                   ),
//                 ),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Icon(Icons.info_outline, color: Colors.green[700], size: 20),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: Text(
//                         'لأي استفسارات أو ملاحظات، نسعد بتواصلكم معنا',
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: isDark ? Colors.green[100] : Colors.green[900],
//                           height: 1.4,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             style: TextButton.styleFrom(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//             ),
//             child: const Text('إغلاق', style: TextStyle(fontSize: 15)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showHelpSupport() {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         title: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(2),
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(Icons.support_agent, color: AppColors.primary, size: 24),
//             ),
//             const SizedBox(width: 12),
//             const Text('الدعم والمساعدة', style: TextStyle(fontSize: 20)),
//           ],
//         ),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'نحن هنا لمساعدتك! تواصل معنا عبر:',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: isDark ? Colors.grey[300] : Colors.grey[700],
//                 ),
//               ),
//               const SizedBox(height: 20),
              
//               // Email Button
//               InkWell(
//                 onTap: _launchEmail,
//                 borderRadius: BorderRadius.circular(12),
//                 child: Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: isDark ? Colors.blue[900]?.withOpacity(0.3) : Colors.blue[50],
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: Colors.blue.withOpacity(0.3),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: Colors.blue,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: const Icon(Icons.email_outlined, size: 24, color: Colors.white),
//                       ),
//                       const SizedBox(width: 16),
//                       const Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'البريد الإلكتروني',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w400,
//                               ),
//                             ),
//                             SizedBox(height: 4),
//                             Text(
//                               'itridev.soft@gmail.com',
//                               style: TextStyle(
//                                 color: Colors.blue,
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
//                     ],
//                   ),
//                 ),
//               ),
              
//               const SizedBox(height: 16),
              
//               // WhatsApp Button
//               InkWell(
//                 onTap: _launchWhatsApp,
//                 borderRadius: BorderRadius.circular(12),
//                 child: Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         isDark ? Colors.green[900]!.withOpacity(0.4) : Colors.green[50]!,
//                         isDark ? Colors.green[800]!.withOpacity(0.3) : Colors.green[100]!,
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: Colors.green.withOpacity(0.4),
//                       width: 1.5,
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: Colors.green[700],
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: const Icon(Icons.chat, size: 24, color: Colors.white),
//                       ),
//                       const SizedBox(width: 16),
//                       const Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'واتساب',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w400,
//                               ),
//                             ),
//                             SizedBox(height: 4),
//                             Text(
//                               '0542951750',
//                               style: TextStyle(
//                                 color: Colors.green,
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.green),
//                     ],
//                   ),
//                 ),
//               ),
              
//               const SizedBox(height: 20),
              
//               // Help Info
//               Container(
//                 padding: const EdgeInsets.all(14),
//                 decoration: BoxDecoration(
//                   color: isDark ? Colors.orange[900]?.withOpacity(0.2) : Colors.orange[50],
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Icon(Icons.schedule, color: Colors.orange[700], size: 22),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         'نستجيب لاستفساراتكم في أقرب وقت ممكن',
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: isDark ? Colors.orange[100] : Colors.orange[900],
//                           height: 1.4,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             style: TextButton.styleFrom(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//             ),
//             child: const Text('إغلاق', style: TextStyle(fontSize: 15)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showLogoutDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('تسجيل الخروج'),
//         content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               ApiService.clearToken();
//               Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
//             child: const Text('تسجيل الخروج'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showDeleteAccountDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('حذف الحساب'),
//         content: const Text('تحذير: هذا الإجراء لا يمكن التراجع عنه. سيتم حذف جميع بياناتك نهائياً.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               Navigator.pop(context);
              
//               // Capture the navigator and mounted check BEFORE showing loading dialog
//               final navigator = Navigator.of(context);
              
//               // Show loading indicator
//               showDialog(
//                 context: context,
//                 barrierDismissible: false,
//                 builder: (context) => const Center(
//                   child: CircularProgressIndicator(),
//                 ),
//               );

//               // Check for active reservations
//               final hasReservations = await _hasActiveReservations();
              
//               // Hide loading using the captured navigator
//               navigator.pop();

//               if (hasReservations) {
//                 // Show error dialog
//                 if (mounted) {
//                   _showCannotDeleteDialog();
//                 }
//               } else {
//                 // Proceed with deletion
//                 await _deleteAccount();
//               }
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('حذف الحساب'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showCannotDeleteDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Row(
//           children: [
//             Icon(Icons.warning, color: Colors.orange),
//             SizedBox(width: 10),
//             Text('لا يمكن حذف الحساب'),
//           ],
//         ),
//         content: const Text(
//           'لديك حجز نشط (معلق أو مؤكد). يجب إلغاء الحجز أولاً قبل حذف الحساب.',
//           textAlign: TextAlign.right,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('حسناً'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<bool> _hasActiveReservations() async {
//     try {
//       // Check for pending reservation
//       final pendingReservation = await ApiService.getMyPendingReservation();
//       if (pendingReservation.isNotEmpty) {
//         return true;
//       }
//     } catch (e) {
//       // No pending reservation found
//       print('No pending reservation: $e');
//     }

//     try {
//       // Check for validated reservation
//       final validatedReservation = await ApiService.getMyValidatedReservation();
//       if (validatedReservation.isNotEmpty) {
//         return true;
//       }
//     } catch (e) {
//       // No validated reservation found
//       print('No validated reservation: $e');
//     }

//     return false;
//   }

//   Future<void> _deleteAccount() async {
//     try {
//       await ApiService.deleteProfile();
//       await ApiService.clearToken();
      
//       if (mounted) {
//         Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('تم حذف الحساب بنجاح'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('خطأ في حذف الحساب: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
// }