// //client\lib\screens\clan admin\grooms_tab.dart
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:wedding_reservation_app/screens/auth/signup_screen.dart';
// import 'package:wedding_reservation_app/screens/super%20admin/otp_verification_screen.dart';
// import 'package:wedding_reservation_app/services/api_service.dart';
// // Add your AdminOTPScreen import here
// // import 'admin_otp_screen.dart';

// class GroomManagementScreen extends StatefulWidget {
//   const GroomManagementScreen({Key? key}) : super(key: key);

//   @override
//   State<GroomManagementScreen> createState() => GroomManagementScreenState();
// }

// class GroomManagementScreenState extends State<GroomManagementScreen> {
//   List<Map<String, dynamic>> grooms = [];
//   bool isLoading = true;
//   String? errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _loadGrooms();
//   }

//  void refreshData() {
//     // Add your refresh logic here
//     _loadGrooms();
//     setState(() {
//       // Trigger rebuild
//     });
//   }
//   void _showViewGroomDialog(Map<String, dynamic> groom) {
//     showDialog(
//       context: context,
//       builder: (context) => ViewGroomDetailsDialog(groom: groom),
//     );
//   }


//   Future<Map<String, dynamic>?> _getGroomReservationStatus(int groomId) async {
//   try {
//     // First check for validated reservation (highest priority)
//     try {
//       final validated = await ApiService.getMyValidatedReservation();
//       if (validated.isNotEmpty && validated['groom_id'] == groomId) {
//         return {
//           'status': 'validated',
//           'reservation': validated,
//           'priority': 1
//         };
//       }
//     } catch (e) {
//       // No validated reservation found, continue checking
//     }

//     // Check for pending reservation (second priority)
//     try {
//       final pending = await ApiService.getMyPendingReservation();
//       if (pending.isNotEmpty && pending['groom_id'] == groomId) {
//         return {
//           'status': 'pending_validation',
//           'reservation': pending,
//           'priority': 2
//         };
//       }
//     } catch (e) {
//       // No pending reservation found, continue checking
//     }

//     // Check for cancelled reservations (lowest priority)
//     try {
//       final cancelled = await ApiService.getMyCancelledReservations();
//       if (cancelled.isNotEmpty) {
//         // Find the most recent cancelled reservation for this groom
//         final groomCancelled = cancelled.where((res) => res['groom_id'] == groomId).toList();
//         if (groomCancelled.isNotEmpty) {
//           // Sort by date and get the most recent
//           groomCancelled.sort((a, b) => 
//             DateTime.parse(b['created_at'] ?? '').compareTo(DateTime.parse(a['created_at'] ?? ''))
//           );
//           return {
//             'status': 'cancelled',
//             'reservation': groomCancelled.first,
//             'priority': 3
//           };
//         }
//       }
//     } catch (e) {
//       // No cancelled reservations found
//     }

//     // No reservation found
//     return null;
//   } catch (e) {
//     print('Error getting reservation status: $e');
//     return null;
//   }
// }



//   Future<void> _loadGrooms() async {
//     setState(() {
//       isLoading = true;
//       errorMessage = null;
//     });

//     try {
//       final response = await ApiService.listGrooms();
//       setState(() {
//         grooms = List<Map<String, dynamic>>.from(response);
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         errorMessage = e.toString();
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> _updateGroomStatus(String phoneNumber, String currentStatus) async {
//     try {
//       final newStatus = currentStatus == 'active' ? 'inactive' : 'active';
//       await ApiService.updateGroomStatus(phoneNumber, newStatus);
      
//       // Update local state
//       setState(() {
//         final groomIndex = grooms.indexWhere((g) => g['phone_number']?.toString() == phoneNumber);
//         if (groomIndex != -1) {
//           grooms[groomIndex]['status'] = newStatus;
//         }
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('تم تحديث حالة العريس بنجاح'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('خطأ في تحديث الحالة: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Future<void> _deleteGroom(String phoneNumber) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('تأكيد الحذف'),
//         content: Text('هل أنت متأكد من حذف هذا العريس؟'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: Text('إلغاء'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: Text('حذف', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true) {
//       try {
//         await ApiService.deleteGroom(phoneNumber);
//         setState(() {
//           grooms.removeWhere((g) => g['phone_number'] == phoneNumber);
//         });
        
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('تم حذف العريس بنجاح'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('خطأ في الحذف: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   void _showEditGroomDialog(Map<String, dynamic> groom) {
//     showDialog(
//       context: context,
//       builder: (context) => EditGroomDialog(
//         groom: groom,
//         onUpdate: (updatedGroom) {
//           setState(() {
//             final index = grooms.indexWhere((g) => g['id'] == groom['id']);
//             if (index != -1) {
//               grooms[index] = {...grooms[index], ...updatedGroom};
//             }
//           });
//         },
//       ),
//     );
//   }

// Widget _buildGroomCard(Map<String, dynamic> groom) {
//   final status = groom['status']?.toString() ?? 'inactive';
//   final isActive = status == 'active';
//   final groomId = groom['id'] as int?;
  
//   return Card(
//     margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//     elevation: 2,
//     child: Padding(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header with name and status
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Text(
//                   '${groom['first_name'] ?? ''} ${groom['last_name'] ?? ''}',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(16),
//                       border: Border.all(
//                         color: isActive ? Colors.green : Colors.red,
//                       ),
//                     ),
//                     child: Text(
//                       isActive ? 'نشط' : 'غير نشط',
//                       style: TextStyle(
//                         color: isActive ? Colors.green : Colors.red,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ),
//                   // Reservation Status
//                   if (groomId != null)
//                     FutureBuilder<Map<String, dynamic>?>(
//                       future: _getGroomReservationStatus(groomId),
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState == ConnectionState.waiting) {
//                           return Container(
//                             margin: EdgeInsets.only(top: 4),
//                             padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                             child: SizedBox(
//                               width: 12,
//                               height: 12,
//                               child: CircularProgressIndicator(strokeWidth: 1),
//                             ),
//                           );
//                         }
                        
//                         if (snapshot.hasData && snapshot.data != null) {
//                           final reservationData = snapshot.data!;
//                           final reservationStatus = reservationData['status'] as String;
                          
//                           Color statusColor;
//                           String statusText;
                          
//                           switch (reservationStatus) {
//                             case 'validated':
//                               statusColor = Colors.green;
//                               statusText = 'حجز مؤكد';
//                               break;
//                             case 'pending_validation':
//                               statusColor = Colors.orange;
//                               statusText = 'حجز معلق';
//                               break;
//                             case 'cancelled':
//                               statusColor = Colors.red;
//                               statusText = 'حجز ملغى';
//                               break;
//                             default:
//                               statusColor = Colors.grey;
//                               statusText = 'حالة غير معروفة';
//                           }
                          
//                           return Container(
//                             margin: EdgeInsets.only(top: 4),
//                             padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                             decoration: BoxDecoration(
//                               color: statusColor.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(color: statusColor, width: 0.5),
//                             ),
//                             child: Text(
//                               statusText,
//                               style: TextStyle(
//                                 color: statusColor,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 10,
//                               ),
//                             ),
//                           );
//                         }
                        
//                         return Container(
//                           margin: EdgeInsets.only(top: 4),
//                           padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                           decoration: BoxDecoration(
//                             color: Colors.grey.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(color: Colors.grey, width: 0.5),
//                           ),
//                           child: Text(
//                             'لا يوجد حجز',
//                             style: TextStyle(
//                               color: Colors.grey,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 10,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                 ],
//               ),
//             ],
//           ),
          
//           SizedBox(height: 12),
          
//           // Basic Information
//           _buildInfoRow('رقم الهاتف', groom['phone_number']?.toString() ?? ''),
//           _buildInfoRow('اسم الأب', groom['father_name'] ?? ''),
//           _buildInfoRow('اسم الجد', groom['grandfather_name'] ?? ''),
//           _buildInfoRow('تاريخ الميلاد', groom['birth_date'] ?? ''),
//           _buildInfoRow('عنوان السكن', groom['home_address'] ?? ''),
          
//           // Guardian Information (if available)
//           if (groom['guardian_name'] != null && groom['guardian_name'].toString().isNotEmpty) ...[
//             SizedBox(height: 8),
//             Text(
//               'معلومات الولي',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue[800],
//               ),
//             ),
//             _buildInfoRow('اسم الولي', groom['guardian_name'] ?? ''),
//             _buildInfoRow('هاتف الولي', groom['guardian_phone'] ?? ''),
//             _buildInfoRow('صلة القرابة', groom['guardian_relation'] ?? ''),
//           ],
          
//           SizedBox(height: 16),
          
//           // Action Buttons (same as before)
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               ElevatedButton.icon(
//                 onPressed: () => _showViewGroomDialog(groom),
//                 icon: Icon(Icons.visibility, size: 16),
//                 label: Text('عرض التفاصيل'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.purple,
//                   foregroundColor: Colors.white,
//                 ),
//               ),
//               ElevatedButton.icon(
//                 onPressed: () => _showEditGroomDialog(groom),
//                 icon: Icon(Icons.edit, size: 16),
//                 label: Text('تعديل'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   foregroundColor: Colors.white,
//                 ),
//               ),
//               ElevatedButton.icon(
//                 onPressed: () => _updateGroomStatus(
//                   groom['phone_number']?.toString() ?? '', 
//                   status
//                 ),
//                 icon: Icon(
//                   isActive ? Icons.visibility_off : Icons.visibility,
//                   size: 16,
//                 ),
//                 label: Text(isActive ? 'إلغاء التفعيل' : 'تفعيل'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: isActive ? Colors.orange : Colors.green,
//                   foregroundColor: Colors.white,
//                 ),
//               ),
//               ElevatedButton.icon(
//                 onPressed: () => _deleteGroom(groom['phone_number']?.toString() ?? ''),
//                 icon: Icon(Icons.delete, size: 16),
//                 label: Text('حذف'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red,
//                   foregroundColor: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//   );
// }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(
//               '$label:',
//               style: TextStyle(
//                 fontWeight: FontWeight.w500,
//                 color: Colors.grey[700],
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value.isNotEmpty ? value : 'غير محدد',
//               style: TextStyle(
//                 color: value.isNotEmpty ? Colors.black87 : Colors.grey,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('إدارة العرسان'),
//         backgroundColor: Colors.blue[800],
//         foregroundColor: Colors.white,
//         leading: IconButton(
//             icon: Icon(Icons.arrow_back),
//             onPressed: () {
//               Navigator.pushReplacementNamed(context, '/clan_admin_home');
//             },
//           ),
//         actions: [
//         IconButton(
//           onPressed: () async {
//             // Navigate to MultiStepSignupScreen and refresh when returning
//             final result = await Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => MultiStepSignupScreen(),
//               ),
//             );
            
//             // Refresh the grooms list when returning from signup
//             if (result != null) {
//               _loadGrooms();
//             }
//           },
//           icon: Icon(Icons.person_add),
//           tooltip: 'إضافة عريس جديد',
//         ),
//         IconButton(
//           onPressed: _loadGrooms,
//           icon: Icon(Icons.refresh),
//           tooltip:' تحديث القائمة',
//         ),
//       ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: _loadGrooms,
//         child: isLoading
//             ? Center(child: CircularProgressIndicator())
//             : errorMessage != null
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.error, size: 64, color: Colors.red),
//                         SizedBox(height: 16),
//                         Text(
//                           'خطأ في تحميل البيانات',
//                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                         SizedBox(height: 8),
//                         Text(errorMessage!),
//                         SizedBox(height: 16),
//                         ElevatedButton(
//                           onPressed: _loadGrooms,
//                           child: Text('إعادة المحاولة'),
//                         ),
//                       ],
//                     ),
//                   )
//                 : grooms.isEmpty
//                     ? Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.people_outline, size: 64, color: Colors.grey),
//                             SizedBox(height: 16),
//                             Text(
//                               'لا توجد عرسان مسجلين',
//                               style: TextStyle(fontSize: 18, color: Colors.grey),
//                             ),
//                           ],
//                         ),
//                       )
//                     : ListView.builder(
//                         itemCount: grooms.length,
//                         itemBuilder: (context, index) => _buildGroomCard(grooms[index]),
//                       ),
//       ),
//     );
//   }
// }

// class EditGroomDialog extends StatefulWidget {
//   final Map<String, dynamic> groom;
//   final Function(Map<String, dynamic>) onUpdate;

//   const EditGroomDialog({
//     Key? key,
//     required this.groom,
//     required this.onUpdate,
//   }) : super(key: key);

//   @override
//   State<EditGroomDialog> createState() => _EditGroomDialogState();
// }

// class _EditGroomDialogState extends State<EditGroomDialog> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _firstNameController;
//   late TextEditingController _lastNameController;
//   late TextEditingController _fatherNameController;
//   late TextEditingController _grandfatherNameController;
//   late TextEditingController _phoneController;
//   late TextEditingController _birthDateController;
//   late TextEditingController _birthAddressController;
//   late TextEditingController _homeAddressController;
//   late TextEditingController _guardianNameController;
//   late TextEditingController _guardianPhoneController;
//   late TextEditingController _guardianHomeAddressController;
//   late TextEditingController _guardianBirthAddressController;
//   late TextEditingController _guardianBirthDateController;
//   late TextEditingController _guardianRelationController;
  
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeControllers();
//   }

//   void _initializeControllers() {
//     _firstNameController = TextEditingController(text: widget.groom['first_name'] ?? '');
//     _lastNameController = TextEditingController(text: widget.groom['last_name'] ?? '');
//     _fatherNameController = TextEditingController(text: widget.groom['father_name'] ?? '');
//     _grandfatherNameController = TextEditingController(text: widget.groom['grandfather_name'] ?? '');
//     _phoneController = TextEditingController(text: widget.groom['phone_number']?.toString() ?? '');
//     _birthDateController = TextEditingController(text: widget.groom['birth_date'] ?? '');
//     _birthAddressController = TextEditingController(text: widget.groom['birth_address'] ?? '');
//     _homeAddressController = TextEditingController(text: widget.groom['home_address'] ?? '');
//     _guardianNameController = TextEditingController(text: widget.groom['guardian_name'] ?? '');
//     _guardianPhoneController = TextEditingController(text: widget.groom['guardian_phone'] ?? '');
//     _guardianHomeAddressController = TextEditingController(text: widget.groom['guardian_home_address'] ?? '');
//     _guardianBirthAddressController = TextEditingController(text: widget.groom['guardian_birth_address'] ?? '');
//     _guardianBirthDateController = TextEditingController(text: widget.groom['guardian_birth_date'] ?? '');
//     _guardianRelationController = TextEditingController(text: widget.groom['guardian_relation'] ?? '');
//   }

//   @override
//   void dispose() {
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _fatherNameController.dispose();
//     _grandfatherNameController.dispose();
//     _phoneController.dispose();
//     _birthDateController.dispose();
//     _birthAddressController.dispose();
//     _homeAddressController.dispose();
//     _guardianNameController.dispose();
//     _guardianPhoneController.dispose();
//     _guardianHomeAddressController.dispose();
//     _guardianBirthAddressController.dispose();
//     _guardianBirthDateController.dispose();
//     _guardianRelationController.dispose();
//     super.dispose();
//   }

//   Future<void> _updateGroom() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       // Check if phone number has changed
//       final originalPhoneNumber = widget.groom['phone_number']?.toString() ?? '';
//       final newPhoneNumber = _phoneController.text.trim();
//       final phoneNumberChanged = originalPhoneNumber != newPhoneNumber && newPhoneNumber.isNotEmpty;

//       final updatedData = await ApiService.updateGroomDetails(
//         widget.groom['id'],
//         firstName: _firstNameController.text.trim().isEmpty ? null : _firstNameController.text.trim(),
//         lastName: _lastNameController.text.trim().isEmpty ? null : _lastNameController.text.trim(),
//         fatherName: _fatherNameController.text.trim().isEmpty ? null : _fatherNameController.text.trim(),
//         grandfatherName: _grandfatherNameController.text.trim().isEmpty ? null : _grandfatherNameController.text.trim(),
//         phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
//         birthDate: _birthDateController.text.trim().isEmpty ? null : _birthDateController.text.trim(),
//         birthAddress: _birthAddressController.text.trim().isEmpty ? null : _birthAddressController.text.trim(),
//         homeAddress: _homeAddressController.text.trim().isEmpty ? null : _homeAddressController.text.trim(),
//         guardianName: _guardianNameController.text.trim().isEmpty ? null : _guardianNameController.text.trim(),
//         guardianPhone: _guardianPhoneController.text.trim().isEmpty ? null : _guardianPhoneController.text.trim(),
//         guardianHomeAddress: _guardianHomeAddressController.text.trim().isEmpty ? null : _guardianHomeAddressController.text.trim(),
//         guardianBirthAddress: _guardianBirthAddressController.text.trim().isEmpty ? null : _guardianBirthAddressController.text.trim(),
//         guardianBirthDate: _guardianBirthDateController.text.trim().isEmpty ? null : _guardianBirthDateController.text.trim(),
//         guardianRelation: _guardianRelationController.text.trim().isEmpty ? null : _guardianRelationController.text.trim(),
//       );

//       widget.onUpdate({
//         'first_name': _firstNameController.text.trim(),
//         'last_name': _lastNameController.text.trim(),
//         'father_name': _fatherNameController.text.trim(),
//         'grandfather_name': _grandfatherNameController.text.trim(),
//         'phone_number': _phoneController.text.trim(),
//         'birth_date': _birthDateController.text.trim(),
//         'birth_address': _birthAddressController.text.trim(),
//         'home_address': _homeAddressController.text.trim(),
//         'guardian_name': _guardianNameController.text.trim(),
//         'guardian_phone': _guardianPhoneController.text.trim(),
//         'guardian_home_address': _guardianHomeAddressController.text.trim(),
//         'guardian_birth_address': _guardianBirthAddressController.text.trim(),
//         'guardian_birth_date': _guardianBirthDateController.text.trim(),
//         'guardian_relation': _guardianRelationController.text.trim(),
//       });

//       Navigator.pop(context);

//       // If phone number was changed, redirect to OTP screen
//       if (phoneNumberChanged) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('تم تحديث رقم الهاتف. يجب التحقق من الرقم الجديد'),
//             backgroundColor: Colors.orange,
//           ),
//         );
        
//         // send OTP to new phone number
//         await ApiService.resendOTP(newPhoneNumber);


//         // Navigate to OTP screen for phone verification
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => OTPVerificationScreenE(
//               phoneNumber: newPhoneNumber,
//               isClanadmin:true
//             ),
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('تم تحديث معلومات العريس بنجاح'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('خطأ في التحديث: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Widget _buildTextField(TextEditingController controller, String label, {bool required = false}) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 8),
//       child: TextFormField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(),
//           contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         ),
//         validator: required
//             ? (value) {
//                 if (value == null || value.trim().isEmpty) {
//                   return 'هذا الحقل مطلوب';
//                 }
//                 return null;
//               }
//             : null,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       child: Container(
//         width: MediaQuery.of(context).size.width * 0.9,
//         height: MediaQuery.of(context).size.height * 0.8,
//         padding: EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               Text(
//                 'تعديل معلومات العريس',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 16),
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       // Basic Information Section
//                       Text(
//                         'المعلومات الأساسية',
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[800]),
//                       ),
//                       _buildTextField(_firstNameController, 'الاسم الأول', required: true),
//                       _buildTextField(_lastNameController, 'اسم العائلة', required: true),
//                       _buildTextField(_fatherNameController, 'اسم الأب'),
//                       _buildTextField(_grandfatherNameController, 'اسم الجد'),
//                       _buildTextField(_phoneController, 'رقم الهاتف', required: true),
//                       _buildTextField(_birthDateController, 'تاريخ الميلاد'),
//                       _buildTextField(_birthAddressController, 'مكان الميلاد'),
//                       _buildTextField(_homeAddressController, 'عنوان السكن'),
                      
//                       SizedBox(height: 16),
                      
//                       // Guardian Information Section
//                       Text(
//                         'معلومات الولي',
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[800]),
//                       ),
//                       _buildTextField(_guardianNameController, 'اسم الولي'),
//                       _buildTextField(_guardianPhoneController, 'هاتف الولي'),
//                       _buildTextField(_guardianHomeAddressController, 'عنوان سكن الولي'),
//                       _buildTextField(_guardianBirthAddressController, 'مكان ميلاد الولي'),
//                       _buildTextField(_guardianBirthDateController, 'تاريخ ميلاد الولي'),
//                       _buildTextField(_guardianRelationController, 'صلة القرابة'),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: Text('إلغاء'),
//                   ),
//                   ElevatedButton(
//                     onPressed: isLoading ? null : _updateGroom,
//                     child: isLoading
//                         ? SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           )
//                         : Text('حفظ التغييرات'),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ViewGroomDetailsDialog extends StatelessWidget {
//   final Map<String, dynamic> groom;

//   const ViewGroomDetailsDialog({
//     Key? key,
//     required this.groom,
//   }) : super(key: key);
// // Add this static method to ViewGroomDetailsDialog class
// static Future<Map<String, dynamic>?> _getGroomReservationStatus(int groomId) async {
//   try {
//     // First check for validated reservation (highest priority)
//     try {
//       final validated = await ApiService.getMyValidatedReservation();
//       if (validated.isNotEmpty && validated['groom_id'] == groomId) {
//         return {
//           'status': 'validated',
//           'reservation': validated,
//           'priority': 1
//         };
//       }
//     } catch (e) {
//       // No validated reservation found, continue checking
//     }

//     // Check for pending reservation (second priority)
//     try {
//       final pending = await ApiService.getMyPendingReservation();
//       if (pending.isNotEmpty && pending['groom_id'] == groomId) {
//         return {
//           'status': 'pending_validation',
//           'reservation': pending,
//           'priority': 2
//         };
//       }
//     } catch (e) {
//       // No pending reservation found, continue checking
//     }

//     // Check for cancelled reservations (lowest priority)
//     try {
//       final cancelled = await ApiService.getMyCancelledReservations();
//       if (cancelled.isNotEmpty) {
//         // Find the most recent cancelled reservation for this groom
//         final groomCancelled = cancelled.where((res) => res['groom_id'] == groomId).toList();
//         if (groomCancelled.isNotEmpty) {
//           // Sort by date and get the most recent
//           groomCancelled.sort((a, b) => 
//             DateTime.parse(b['created_at'] ?? '').compareTo(DateTime.parse(a['created_at'] ?? ''))
//           );
//           return {
//             'status': 'cancelled',
//             'reservation': groomCancelled.first,
//             'priority': 3
//           };
//         }
//       }
//     } catch (e) {
//       // No cancelled reservations found
//     }

//     // No reservation found
//     return null;
//   } catch (e) {
//     print('Error getting reservation status: $e');
//     return null;
//   }  
// }
//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 140,
//             child: Text(
//               '$label:',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey[700],
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value.isNotEmpty ? value : 'غير محدد',
//               style: TextStyle(
//                 color: value.isNotEmpty ? Colors.black87 : Colors.grey,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: EdgeInsets.only(top: 16, bottom: 8),
//       child: Text(
//         title,
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//           color: Colors.blue[800],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final status = groom['status']?.toString() ?? 'inactive';
//     final isActive = status == 'active';

//     return Dialog(
//       child: Container(
//         width: MediaQuery.of(context).size.width * 0.9,
//         height: MediaQuery.of(context).size.height * 0.8,
//         padding: EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // Header
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'تفاصيل العريس',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                       color: isActive ? Colors.green : Colors.red,
//                     ),
//                   ),
//                   child: Text(
//                     isActive ? 'نشط' : 'غير نشط',
//                     style: TextStyle(
//                       color: isActive ? Colors.green : Colors.red,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
            
//             SizedBox(height: 16),
            
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Basic Information
//                     _buildSectionTitle('المعلومات الأساسية'),
//                     _buildDetailRow('الاسم الأول', groom['first_name'] ?? ''),
//                     _buildDetailRow('اسم العائلة', groom['last_name'] ?? ''),
//                     _buildDetailRow('اسم الأب', groom['father_name'] ?? ''),
//                     _buildDetailRow('اسم الجد', groom['grandfather_name'] ?? ''),
//                     _buildDetailRow('رقم الهاتف', groom['phone_number']?.toString() ?? ''),
//                     _buildDetailRow('تاريخ الميلاد', groom['birth_date'] ?? ''),
//                     _buildDetailRow('مكان الميلاد', groom['birth_address'] ?? ''),
//                     _buildDetailRow('عنوان السكن', groom['home_address'] ?? ''),
                    
//                     // Guardian Information
//                     _buildSectionTitle('معلومات الولي'),
//                     _buildDetailRow('اسم الولي', groom['guardian_name'] ?? ''),
//                     _buildDetailRow('هاتف الولي', groom['guardian_phone'] ?? ''),
//                     _buildDetailRow('عنوان سكن الولي', groom['guardian_home_address'] ?? ''),
//                     _buildDetailRow('مكان ميلاد الولي', groom['guardian_birth_address'] ?? ''),
//                     _buildDetailRow('تاريخ ميلاد الولي', groom['guardian_birth_date'] ?? ''),
//                     _buildDetailRow('صلة القرابة', groom['guardian_relation'] ?? ''),
                    
//                     // Additional Information
//                     _buildSectionTitle('معلومات إضافية'),
//                     _buildDetailRow('تاريخ الإنشاء', groom['created_at'] ?? ''),
//                     _buildDetailRow('تاريخ آخر تحديث', groom['updated_at'] ?? ''),
//                     _buildDetailRow('معرف العريس', groom['id']?.toString() ?? ''),

//                     // reservation info if available
//                     _buildSectionTitle('معلومات الحجز'),
//                     if (groom['id'] != null)
//                       FutureBuilder<Map<String, dynamic>?>(
//                         future: _getGroomReservationStatus(groom['id'] as int),
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState == ConnectionState.waiting) {
//                             return Padding(
//                               padding: EdgeInsets.symmetric(vertical: 8),
//                               child: Row(
//                                 children: [
//                                   SizedBox(width: 140, child: Text('حالة الحجز:', style: TextStyle(fontWeight: FontWeight.bold))),
//                                   SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
//                                 ],
//                               ),
//                             );
//                           }
                          
//                           if (snapshot.hasData && snapshot.data != null) {
//                             final reservationData = snapshot.data!;
//                             final reservation = reservationData['reservation'] as Map<String, dynamic>;
//                             final status = reservationData['status'] as String;
                            
//                             String statusText;
//                             Color statusColor;
                            
//                             switch (status) {
//                               case 'validated':
//                                 statusText = 'حجز مؤكد';
//                                 statusColor = Colors.green;
//                                 break;
//                               case 'pending_validation':
//                                 statusText = 'حجز معلق';
//                                 statusColor = Colors.orange;
//                                 break;
//                               case 'cancelled':
//                                 statusText = 'حجز ملغى';
//                                 statusColor = Colors.red;
//                                 break;
//                               default:
//                                 statusText = 'حالة غير معروفة';
//                                 statusColor = Colors.grey;
//                             }
                            
//                             return Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 _buildDetailRow('حالة الحجز', statusText),
//                                 if (reservation['hall_name'] != null)
//                                   _buildDetailRow('اسم القاعة', reservation['hall_name'] ?? ''),
//                                 if (reservation['event_date'] != null)
//                                   _buildDetailRow('تاريخ الحدث', reservation['event_date'] ?? ''),
//                                 if (reservation['created_at'] != null)
//                                   _buildDetailRow('تاريخ الحجز', reservation['created_at'] ?? ''),
//                                 if (reservation['total_cost'] != null)
//                                   _buildDetailRow('التكلفة الإجمالية', '${reservation['total_cost']} دينار'),
//                               ],
//                             );
//                           }
                          
//                           return _buildDetailRow('حالة الحجز', 'لا يوجد حجز');
//                         },
//                       ),          
//                   ],
//                 ),
//               ),
//             ),
            
//             SizedBox(height: 16),
            
//             ElevatedButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('إغلاق'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue[800],
//                 foregroundColor: Colors.white,
//                 minimumSize: Size(double.infinity, 45),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }