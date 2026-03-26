// // lib/screens/home/tabs/profile_tab.dart
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
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

//   // Cache variables
//   Map<String, dynamic>? _cachedUserProfile;
//   Map<String, dynamic>? _cachedClanInfo;
//   Map<String, dynamic>? _cachedCountyInfo;
//   bool _hasLoadedOnce = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadCachedData();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadProfileInBackground();
//     });
//   }

//   Future<void> refreshData() async {
//     await _loadProfileInBackground();
//   }

//   void _loadCachedData() {
//     setState(() {
//       _userProfile = _cachedUserProfile;
//       _clanInfo = _cachedClanInfo;
//       _countyInfo = _cachedCountyInfo;
//       _isLoading = _cachedUserProfile == null && !_hasLoadedOnce;
//     });
//   }

//   Future<void> _loadProfileInBackground() async {
//     try {
//       if (_cachedUserProfile == null) {
//         setState(() => _isLoading = true);
//       }
      
//       _userProfile = await ApiService.getMyGroomProfile();
//       _cachedUserProfile = _userProfile;
      
//       await _checkUpdateEligibility();
      
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
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

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
//     _loadCachedData();
    
//     final connectivityResult = await Connectivity().checkConnectivity();
    
//     if (connectivityResult.contains(ConnectivityResult.none)) {
//       _showNoInternetDialog();
//       return;
//     }
    
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

//   Future<void> _loadClanInfo() async {
//     if (_userProfile?['clan_id'] == null) return;
    
//     try {
//       final clans = await ApiService.getClans();
//       final foundClan = clans.cast<Clan?>().firstWhere(
//         (clan) => clan?.id == _userProfile?['clan_id'],
//         orElse: () => null,
//       );
//       _clanInfo = foundClan?.toJson();
//       _cachedClanInfo = _clanInfo;
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
//       _cachedCountyInfo = _countyInfo;
//     } catch (e) {
//       // Keep cached data on error
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading && _cachedUserProfile == null) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return PopScope(
//       canPop: false,
//       onPopInvokedWithResult: (bool didPop, Object? result) {
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
//             child: Icon(Icons.person, size: 40, color: Colors.white),
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
//             _buildInfoRow(Icons.location_city, 'القصر', _countyInfo?['name'] ?? 'غير محدد'),
//             const SizedBox(height: 12),
//             _buildInfoRow(Icons.group, 'العشيرة', _clanInfo?['name'] ?? 'غير محدد'),
//           ],
//         ),
//       ),
//     );
//   }

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
//                 const Text('معلومات العريس', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
//                 IconButton(
//                   icon: Icon(Icons.edit, color: _canUpdateProfile ? AppColors.primary : Colors.grey),
//                   onPressed: _canUpdateProfile ? _showEditGroomDialog : _showCannotEditDialog,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             _buildInfoRow(Icons.person, 'الاسم الأول', _userProfile?['first_name'] ?? 'غير محدد'),
//             const SizedBox(height: 12),
//             _buildInfoRow(Icons.person_outline, 'اسم العائلة', _userProfile?['last_name'] ?? 'غير محدد'),
//             const SizedBox(height: 12),
//             _buildInfoRow(Icons.person, 'اسم الأب', _userProfile?['father_name'] ?? 'غير محدد'),
//             const SizedBox(height: 12),
//             _buildInfoRow(Icons.person, 'اسم الجد', _userProfile?['grandfather_name'] ?? 'غير محدد'),
//             const SizedBox(height: 12),
//             _buildInfoRow(Icons.phone, 'رقم الهاتف', _userProfile?['phone_number'] ?? 'غير محدد'),
//             const SizedBox(height: 12),
//             _buildInfoRow(Icons.calendar_today, 'تاريخ الميلاد', _userProfile?['birth_date'] ?? 'غير محدد'),
//             const SizedBox(height: 12),
//             _buildInfoRow(Icons.location_on, 'مكان الميلاد', _userProfile?['birth_address'] ?? 'غير محدد'),
//             const SizedBox(height: 12),
//             _buildInfoRow(Icons.home, 'عنوان السكن', _userProfile?['home_address'] ?? 'غير محدد'),
//             if (_userProfile?['family_name'] != null && _userProfile!['family_name'].toString().isNotEmpty) ...[
//               const SizedBox(height: 12),
//               _buildInfoRow(Icons.family_restroom, 'اسم العائلة', _userProfile?['family_name']),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

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
//                 const Text('معلومات ولي الأمر', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
//                 IconButton(
//                   icon: Icon(Icons.edit, color: _canUpdateProfile ? AppColors.primary : Colors.grey),
//                   onPressed: _canUpdateProfile ? _showEditGuardianDialog : _showCannotEditDialog,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             _buildInfoRow(Icons.person, 'اسم الولي', _userProfile?['guardian_name'] ?? 'غير محدد'),
//             const SizedBox(height: 12),
//             _buildInfoRow(Icons.phone, 'هاتف الولي', _userProfile?['guardian_phone'] ?? 'غير محدد'),
//             const SizedBox(height: 12),
//             _buildInfoRow(Icons.calendar_today, 'تاريخ ميلاد الولي', _userProfile?['guardian_birth_date'] ?? 'غير محدد'),
//             const SizedBox(height: 12),
//             _buildInfoRow(Icons.location_on, 'مكان ميلاد الولي', _userProfile?['guardian_birth_address'] ?? 'غير محدد'),
//             const SizedBox(height: 12),
//             _buildInfoRow(Icons.home, 'عنوان سكن الولي', _userProfile?['guardian_home_address'] ?? 'غير محدد'),
//             const SizedBox(height: 12),
//             _buildInfoRow(Icons.family_restroom, 'صلة القرابة', _userProfile?['guardian_relation'] ?? 'غير محدد'),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildWakilInfoSection() {
//     final hasWakilInfo = _userProfile?['wakil_full_name'] != null && 
//                          _userProfile!['wakil_full_name'].toString().isNotEmpty;
    
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text('معلومات وكيل العرس', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
//                 IconButton(
//                   icon: Icon(hasWakilInfo ? Icons.edit : Icons.add, color: _canUpdateProfile ? AppColors.primary : Colors.grey),
//                   onPressed: _canUpdateProfile ? _showEditWakilDialog : _showCannotEditDialog,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             if (hasWakilInfo) ...[
//               _buildInfoRow(Icons.person_pin, 'الاسم الكامل', _userProfile?['wakil_full_name'] ?? 'غير محدد'),
//               const SizedBox(height: 12),
//               _buildInfoRow(Icons.phone, 'رقم الهاتف', _userProfile?['wakil_phone_number'] ?? 'غير محدد'),
//             ] else
//               Center(child: Text('لم يتم إضافة معلومات وكيل العرس', style: TextStyle(color: Colors.grey[600], fontSize: 14))),
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
//         Text('$label: ', style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
//         Expanded(child: Text(value, style: TextStyle(color: isDark ? AppColors.darkTextHint : AppColors.darkCard, fontWeight: FontWeight.w500))),
//       ],
//     );
//   }

//   void _showCannotEditDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(children: [Icon(Icons.block, color: Colors.orange), SizedBox(width: 10), Text('لا يمكن التعديل')]),
//         content: Text(_updateBlockReason ?? 'لا يمكن تعديل الملف الشخصي في الوقت الحالي', textAlign: TextAlign.right),
//         actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('حسناً'))],
//       ),
//     );
//   }

//   void _showEditGroomDialog() {
//     final controllers = {
//       'first_name': TextEditingController(text: _userProfile?['first_name']),
//       'last_name': TextEditingController(text: _userProfile?['last_name']),
//       'birth_address': TextEditingController(text: _userProfile?['birth_address']),
//       'home_address': TextEditingController(text: _userProfile?['home_address']),
//       'family_name': TextEditingController(text: _userProfile?['family_name']),
//     };
    
//     DateTime? selectedBirthDate = _parseDate(_userProfile?['birth_date']);

//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setState) => AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           title: Row(children: [Icon(Icons.edit, color: AppColors.primary), SizedBox(width: 10), Text('تعديل معلومات العريس')]),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildTextField(controllers['first_name']!, 'الاسم الأول'),
//                 SizedBox(height: 12),
//                 _buildTextField(controllers['last_name']!, 'اسم العائلة'),
//                 SizedBox(height: 12),
//                 _buildDateField(
//                   label: 'تاريخ الميلاد',
//                   selectedDate: selectedBirthDate,
//                   onTap: () async {
//                     final date = await _selectDate(context, selectedBirthDate);
//                     if (date != null) setState(() => selectedBirthDate = date);
//                   },
//                 ),
//                 SizedBox(height: 12),
//                 _buildTextField(controllers['birth_address']!, 'مكان الميلاد'),
//                 SizedBox(height: 12),
//                 _buildTextField(controllers['home_address']!, 'عنوان السكن'),
//                 SizedBox(height: 12),
//                 _buildTextField(controllers['family_name']!, 'اسم العائلة (اختياري)'),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء')),
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.pop(context);
//                 await _updateProfile(
//                   firstName: controllers['first_name']!.text.trim(),
//                   lastName: controllers['last_name']!.text.trim(),
//                   birthDate: selectedBirthDate != null ? DateFormat('yyyy-MM-dd').format(selectedBirthDate!) : null,
//                   birthAddress: controllers['birth_address']!.text.trim(),
//                   homeAddress: controllers['home_address']!.text.trim(),
//                   familyName: controllers['family_name']!.text.trim().isEmpty ? null : controllers['family_name']!.text.trim(),
//                 );
//               },
//               style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
//               child: Text('حفظ', style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showEditGuardianDialog() {
//     final controllers = {
//       'name': TextEditingController(text: _userProfile?['guardian_name']),
//       'phone': TextEditingController(text: _userProfile?['guardian_phone']),
//       'birth_address': TextEditingController(text: _userProfile?['guardian_birth_address']),
//       'home_address': TextEditingController(text: _userProfile?['guardian_home_address']),
//       'relation': TextEditingController(text: _userProfile?['guardian_relation']),
//     };
    
//     DateTime? selectedBirthDate = _parseDate(_userProfile?['guardian_birth_date']);

//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setState) => AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           title: Row(children: [Icon(Icons.edit, color: AppColors.primary), SizedBox(width: 10), Text('تعديل معلومات الولي')]),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildTextField(controllers['name']!, 'اسم الولي'),
//                 SizedBox(height: 12),
//                 _buildTextField(controllers['phone']!, 'هاتف الولي', keyboardType: TextInputType.phone),
//                 SizedBox(height: 12),
//                 _buildDateField(
//                   label: 'تاريخ ميلاد الولي',
//                   selectedDate: selectedBirthDate,
//                   onTap: () async {
//                     final date = await _selectDate(context, selectedBirthDate);
//                     if (date != null) setState(() => selectedBirthDate = date);
//                   },
//                 ),
//                 SizedBox(height: 12),
//                 _buildTextField(controllers['birth_address']!, 'مكان ميلاد الولي'),
//                 SizedBox(height: 12),
//                 _buildTextField(controllers['home_address']!, 'عنوان سكن الولي'),
//                 SizedBox(height: 12),
//                 _buildTextField(controllers['relation']!, 'صلة القرابة'),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء')),
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.pop(context);
//                 await _updateProfile(
//                   guardianName: controllers['name']!.text.trim(),
//                   guardianPhone: controllers['phone']!.text.trim(),
//                   guardianBirthDate: selectedBirthDate != null ? DateFormat('yyyy-MM-dd').format(selectedBirthDate!) : null,
//                   guardianBirthAddress: controllers['birth_address']!.text.trim(),
//                   guardianHomeAddress: controllers['home_address']!.text.trim(),
//                   guardianRelation: controllers['relation']!.text.trim(),
//                 );
//               },
//               style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
//               child: Text('حفظ', style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showEditWakilDialog() {
//     final controllers = {
//       'name': TextEditingController(text: _userProfile?['wakil_full_name']),
//       'phone': TextEditingController(text: _userProfile?['wakil_phone_number']),
//     };

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(children: [Icon(Icons.edit, color: AppColors.primary), SizedBox(width: 10), Text('تعديل معلومات الوكيل')]),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _buildTextField(controllers['name']!, 'الاسم الكامل للوكيل'),
//             SizedBox(height: 12),
//             _buildTextField(controllers['phone']!, 'رقم هاتف الوكيل', keyboardType: TextInputType.phone),
//           ],
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء')),
//           ElevatedButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await _updateProfile(
//                 wakilFullName: controllers['name']!.text.trim().isEmpty ? null : controllers['name']!.text.trim(),
//                 wakilPhoneNumber: controllers['phone']!.text.trim().isEmpty ? null : controllers['phone']!.text.trim(),
//               );
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
//             child: Text('حفظ', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextField(TextEditingController controller, String label, {TextInputType? keyboardType}) {
//     return TextField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: label,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//         contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       ),
//       keyboardType: keyboardType,
//     );
//   }

//   Widget _buildDateField({required String label, DateTime? selectedDate, required VoidCallback onTap}) {
//     return InkWell(
//       onTap: onTap,
//       child: InputDecorator(
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//           contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           suffixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
//         ),
//         child: Text(selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate) : 'اختر التاريخ'),
//       ),
//     );
//   }

//   Future<DateTime?> _selectDate(BuildContext context, DateTime? initialDate) async {
//     return await showDatePicker(
//       context: context,
//       initialDate: initialDate ?? DateTime.now(),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(primary: AppColors.primary),
//           ),
//           child: child!,
//         );
//       },
//     );
//   }

//   DateTime? _parseDate(String? dateStr) {
//     if (dateStr == null || dateStr.isEmpty) return null;
//     try {
//       return DateTime.parse(dateStr);
//     } catch (e) {
//       return null;
//     }
//   }

//   Future<void> _updateProfile({
//     String? firstName,
//     String? lastName,
//     String? birthDate,
//     String? birthAddress,
//     String? homeAddress,
//     String? guardianName,
//     String? guardianPhone,
//     String? guardianBirthDate,
//     String? guardianBirthAddress,
//     String? guardianHomeAddress,
//     String? guardianRelation,
//     String? wakilFullName,
//     String? wakilPhoneNumber,
//     String? familyName,
//   }) async {
//     showDialog(context: context, barrierDismissible: false, builder: (context) => Center(child: CircularProgressIndicator()));

//     try {
//       await ApiService.updateGroomProfileDetails(
//         firstName: firstName,
//         lastName: lastName,
//         birthDate: birthDate,
//         birthAddress: birthAddress,
//         homeAddress: homeAddress,
//         guardianName: guardianName,
//         guardianPhone: guardianPhone,
//         guardianBirthDate: guardianBirthDate,
//         guardianBirthAddress: guardianBirthAddress,
//         guardianHomeAddress: guardianHomeAddress,
//         guardianRelation: guardianRelation,
//         wakilFullName: wakilFullName,
//         wakilPhoneNumber: wakilPhoneNumber,
//         familyName: familyName,
//       );

//       Navigator.pop(context);
//       await _loadProfileInBackground();

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم تحديث الملف الشخصي بنجاح'), backgroundColor: Colors.green));
//       }
//     } catch (e) {
//       Navigator.pop(context);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في تحديث الملف الشخصي: ${e.toString()}'), backgroundColor: Colors.red));
//       }
//     }
//   }

//   Widget _buildActionButtons() {
//     return Column(
//       children: [
//         Card(
//           child: Column(
//             children: [
//               ListTile(leading: const Icon(Icons.notifications, color: AppColors.primary), title: const Text('الإشعارات'), trailing: const Icon(Icons.chevron_right), onTap: _showNotificationSettings),
//               const Divider(height: 1),
//               ListTile(leading: const Icon(Icons.security, color: AppColors.primary), title: const Text('اخر اخبار العشيرة'), trailing: const Icon(Icons.chevron_right), onTap: _showNewsClan),
//               const Divider(height: 1),
//               ListTile(leading: const Icon(Icons.help, color: AppColors.primary), title: const Text('المساعدة والدعم'), trailing: const Icon(Icons.chevron_right), onTap: _showHelpSupport),
//               const Divider(height: 1),
//               ListTile(leading: const Icon(Icons.info, color: AppColors.primary), title: const Text('حول التطبيق'), trailing: const Icon(Icons.chevron_right), onTap: _showAboutApp),
//             ],
//           ),
//         ),
//         const SizedBox(height: 16),
//         Card(
//           child: Column(
//             children: [
//               ListTile(leading: const Icon(Icons.logout, color: Colors.orange), title: const Text('تسجيل الخروج'), onTap: _showLogoutDialog),
//               const Divider(height: 1),
//               ListTile(leading: const Icon(Icons.delete_forever, color: Colors.red), title: const Text('حذف الحساب'), onTap: _showDeleteAccountDialog),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   void _showNotificationSettings() => showDialog(context: context, builder: (context) => AlertDialog(title: const Text('إعدادات الإشعارات', textAlign: TextAlign.right), content: const Text('هذه الميزة قيد التطوير حالياً. سيتم إضافتها قريباً.', textAlign: TextAlign.right), actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('حسناً'))]));

//   void _showNewsClan() => showDialog(context: context, builder: (context) => AlertDialog(title: const Text('أخبار العشيرة', textAlign: TextAlign.right), content: const Text('هذه الصفحة قيد التطوير حالياً. سيتم إضافتها قريباً.', textAlign: TextAlign.right), actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('حسناً'))]));

//   Future<void> _launchWhatsApp() async {
//     final Uri whatsappUri = Uri.parse('https://wa.me/213542951750');
//     if (!await launchUrl(whatsappUri, mode: LaunchMode.externalApplication)) throw Exception('Could not launch WhatsApp');
//   }

//   Future<void> _launchEmail() async {
//     final Uri emailUri = Uri.parse('mailto:itridev.soft@gmail.com');
//     if (!await launchUrl(emailUri)) throw Exception('Could not launch email');
//   }

//   void _showAboutApp() {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(children: [Container(padding: const EdgeInsets.all(2), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.info, color: AppColors.primary, size: 24)), const SizedBox(width: 12), const Text('حول التطبيق', style: TextStyle(fontSize: 20))]),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('تطبيق حجوزات الأعراس الخاص بجميع العشائر', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 12),
//               Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.grey[100], borderRadius: BorderRadius.circular(8)), child: const Text('الإصدار: 1.0.5', style: TextStyle(fontSize: 14))),
//               const SizedBox(height: 16),
//               Text('يسرّنا أن نرحب بكم في تطبيق الأعراس، ونضع بين أيديكم وسيلة ميسرة لتنظيم وحجز العرس الخاص بكم', style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[300] : Colors.grey[700], height: 1.5)),
//               const SizedBox(height: 20),
//               const Divider(),
//               const SizedBox(height: 16),
//               const Text('برعاية:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
//               const SizedBox(height: 8),
//               Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.1), AppColors.primary.withOpacity(0.05)]), borderRadius: BorderRadius.circular(12)), child: const Text('عشيرة آت الشيخ الحاج مسعود', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
//               const SizedBox(height: 20),
//               const Divider(),
//               const SizedBox(height: 16),
//               const Text('فريق التطوير', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
//               const SizedBox(height: 12),
//               InkWell(onTap: _launchEmail, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isDark ? Colors.blue[900]?.withOpacity(0.3) : Colors.blue[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.withOpacity(0.3))), child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.email, size: 18, color: Colors.white)), const SizedBox(width: 12), const Expanded(child: Text('itridev.soft@gmail.com', style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.w500))), const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.blue)]))),
//               const SizedBox(height: 12),
//               InkWell(onTap: _launchWhatsApp, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isDark ? Colors.green[900]?.withOpacity(0.3) : Colors.green[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.withOpacity(0.3))), child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.green[700], borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.phone, size: 18, color: Colors.white)), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('واتساب', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)), Text('0542951750', style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold))])), const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.green)]))),
//               const SizedBox(height: 16),
//               Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isDark ? Colors.green[900]?.withOpacity(0.2) : Colors.green[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? Colors.green[700]! : Colors.green[200]!)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.info_outline, color: Colors.green[700], size: 20), const SizedBox(width: 10), Expanded(child: Text('لأي استفسارات أو ملاحظات، نسعد بتواصلكم معنا', style: TextStyle(fontSize: 13, color: isDark ? Colors.green[100] : Colors.green[900], height: 1.4)))])),
//             ],
//           ),
//         ),
//         actions: [TextButton(onPressed: () => Navigator.pop(context), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)), child: const Text('إغلاق', style: TextStyle(fontSize: 15)))],
//       ),
//     );
//   }

//   void _showHelpSupport() {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         title: Row(children: [Container(padding: const EdgeInsets.all(2), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.support_agent, color: AppColors.primary, size: 24)), const SizedBox(width: 12), const Text('الدعم والمساعدة', style: TextStyle(fontSize: 20))]),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('نحن هنا لمساعدتك! تواصل معنا عبر:', style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[300] : Colors.grey[700])),
//               const SizedBox(height: 20),
//               InkWell(onTap: _launchEmail, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: isDark ? Colors.blue[900]?.withOpacity(0.3) : Colors.blue[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.withOpacity(0.3))), child: Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.email_outlined, size: 24, color: Colors.white)), const SizedBox(width: 16), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('البريد الإلكتروني', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)), SizedBox(height: 4), Text('itridev.soft@gmail.com', style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.w600))])), const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue)]))),
//               const SizedBox(height: 16),
//               InkWell(onTap: _launchWhatsApp, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: LinearGradient(colors: [isDark ? Colors.green[900]!.withOpacity(0.4) : Colors.green[50]!, isDark ? Colors.green[800]!.withOpacity(0.3) : Colors.green[100]!]), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.withOpacity(0.4), width: 1.5)), child: Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.green[700], borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.chat, size: 24, color: Colors.white)), const SizedBox(width: 16), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('واتساب', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)), SizedBox(height: 4), Text('0542951750', style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold))])), const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.green)]))),
//               const SizedBox(height: 20),
//               Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: isDark ? Colors.orange[900]?.withOpacity(0.2) : Colors.orange[50], borderRadius: BorderRadius.circular(12)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.schedule, color: Colors.orange[700], size: 22), const SizedBox(width: 12), Expanded(child: Text('نستجيب لاستفساراتكم في أقرب وقت ممكن', style: TextStyle(fontSize: 13, color: isDark ? Colors.orange[100] : Colors.orange[900], height: 1.4)))])),
//             ],
//           ),
//         ),
//         actions: [TextButton(onPressed: () => Navigator.pop(context), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)), child: const Text('إغلاق', style: TextStyle(fontSize: 15)))],
//       ),
//     );
//   }

//   void _showLogoutDialog() => showDialog(context: context, builder: (context) => AlertDialog(title: const Text('تسجيل الخروج'), content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')), ElevatedButton(onPressed: () { ApiService.clearToken(); Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), child: const Text('تسجيل الخروج'))]));

//   void _showDeleteAccountDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('حذف الحساب'),
//         content: const Text('تحذير: هذا الإجراء لا يمكن التراجع عنه. سيتم حذف جميع بياناتك نهائياً.'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
//           ElevatedButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               final navigator = Navigator.of(context);
//               showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
//               final hasReservations = await _hasActiveReservations();
//               navigator.pop();
//               if (hasReservations) {
//                 if (mounted) _showCannotDeleteDialog();
//               } else {
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

//   void _showCannotDeleteDialog() => showDialog(context: context, builder: (context) => AlertDialog(title: const Row(children: [Icon(Icons.warning, color: Colors.orange), SizedBox(width: 10), Text('لا يمكن حذف الحساب')]), content: const Text('لديك حجز نشط (معلق أو مؤكد). يجب إلغاء الحجز أولاً قبل حذف الحساب.', textAlign: TextAlign.right), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسناً'))]));

//   Future<bool> _hasActiveReservations() async {
//     try {
//       final pendingReservation = await ApiService.getMyPendingReservation();
//       if (pendingReservation.isNotEmpty) return true;
//     } catch (e) {
//       print('No pending reservation: $e');
//     }
//     try {
//       final validatedReservation = await ApiService.getMyValidatedReservation();
//       if (validatedReservation.isNotEmpty) return true;
//     } catch (e) {
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
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف الحساب بنجاح'), backgroundColor: Colors.green));
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في حذف الحساب: ${e.toString()}'), backgroundColor: Colors.red));
//       }
//     }
//   }
// }