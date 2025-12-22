
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:wedding_reservation_app/providers/theme_provider.dart';
// import 'package:wedding_reservation_app/screens/auth/sing_up_screen.dart';
// import 'package:wedding_reservation_app/screens/super%20admin/otp_verification_screen.dart';
// import 'package:wedding_reservation_app/services/api_service.dart';
// import 'package:wedding_reservation_app/utils/colors.dart';
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
//   // ADD THESE NEW VARIABLES:
//   bool _hasAccessPassword = false;
//   bool _isVerifyingAccess = false;




//   @override
//   void initState() {
//     super.initState();
//     _checkConnectivityAndLoad();
//     _checkAccessPassword();
//   }

//  void refreshData() {
//     // Add your refresh logic here
//     _checkConnectivityAndLoad();
//     _checkAccessPassword();
//     setState(() {
//       // Trigger rebuild

//     });
//   }


// // ADD THIS NEW METHOD:
// Future<void> _checkAccessPassword() async {
//   try {
//     final hasPassword = await ApiService.hasAccessPassword();
//     setState(() {
//       _hasAccessPassword = hasPassword;
//     });
//   } catch (e) {
//     print('Error checking access password: $e');
//     setState(() {
//       _hasAccessPassword = false;
//     });
//   }
// }
//   // Method to verify access before navigating to protected tabs
// Future<bool> _verifyAccessForTab() async {
  

//   await _checkAccessPassword();
//   // Check if user has access password set
//   if (!_hasAccessPassword) {
//     _showAccessPasswordNotSetDialog();
//     return false;
//   }

//   // Show password verification dialog
//   return await _showAccessPasswordDialog();
// }


// // Dialog when user doesn't have access password
// void _showAccessPasswordNotSetDialog() {
//   final isDark = Theme.of(context).brightness == Brightness.dark;
  
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       title: Row(
//         children: [
//           Icon(Icons.lock_outline, color: Colors.orange),
//           SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               'كلمة مرور الوصول غير متوفرة',
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: isDark ? Colors.white : Colors.black87,
//               ),
//             ),
//           ),
//         ],
//       ),
//       // content: Text(
//       //   'لم يتم تعيين كلمة مرور وصول لحسابك.\nيرجى الاتصال بالمدير الأعلى لإنشاء كلمة مرور.',
//       //   style: TextStyle(
//       //     color: isDark ? Colors.white70 : Colors.black87,
//       //   ),
//       // ),
//       actions: [
//         ElevatedButton(
//           onPressed: () => Navigator.pop(context),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: AppColors.primary,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
//           ),
//           child: const Text('فهمت', style: TextStyle(color: Colors.white)),
//         ),
//       ],
//     ),
//   );
// }
// // Updated _showAccessPasswordDialog method with loading state

// Future<bool> _showAccessPasswordDialog() async {
//   final isDark = Theme.of(context).brightness == Brightness.dark;
//   final passwordController = TextEditingController();
//   bool obscurePassword = true;
//   String? errorMessage;
//   bool isLoading = false; // ADD THIS LINE

//   final result = await showDialog<bool>(
//     context: context,
//     barrierDismissible: false,
//     builder: (context) => StatefulBuilder(
//       builder: (context, setDialogState) => AlertDialog(
//         backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Row(
//           children: [
//             Icon(Icons.key, color: AppColors.primary),
//             SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 'أدخل كلمة مرور الوصول',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 18,
//                   color: isDark ? Colors.white : Colors.black87,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Container(
//             //   padding: const EdgeInsets.all(12),
//             //   decoration: BoxDecoration(
//             //     color: Colors.blue.shade50,
//             //     borderRadius: BorderRadius.circular(8),
//             //     border: Border.all(color: Colors.blue.shade200),
//             //   ),
//             //   child: Row(
//             //     children: const [
//             //       Icon(Icons.info_outline, color: Colors.blue, size: 20),
//             //       SizedBox(width: 8),
//             //       Expanded(
//             //         child: Text(
//             //           'هذه الصفحة محمية. يرجى إدخال كلمة المرور.',
//             //           style: TextStyle(color: Colors.blue, fontSize: 12),
//             //         ),
//             //       ),
//             //     ],
//             //   ),
//             // ),
//             // SizedBox(height: 16),
//             TextField(
//               controller: passwordController,
//               obscureText: obscurePassword,
//               autofocus: true,
//               enabled: !isLoading, // DISABLE WHEN LOADING
//               style: TextStyle(
//                 color: isDark ? Colors.white : Colors.black87,
//               ),
//               decoration: InputDecoration(
//                 labelText: 'كلمة مرور ',
//                 hintText: 'أدخل كلمة المرور',
//                 prefixIcon: const Icon(Icons.lock_outline),
//                 suffixIcon: IconButton(
//                   icon: Icon(
//                     obscurePassword ? Icons.visibility : Icons.visibility_off,
//                   ),
//                   onPressed: isLoading ? null : () { // DISABLE WHEN LOADING
//                     setDialogState(() {
//                       obscurePassword = !obscurePassword;
//                     });
//                   },
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 errorText: errorMessage,
//               ),
//               onSubmitted: isLoading ? null : (_) async { // DISABLE WHEN LOADING
//                 if (passwordController.text.isEmpty) {
//                   setDialogState(() {
//                     errorMessage = 'يرجى إدخال كلمة المرور';
//                   });
//                   return;
//                 }
                
//                 // Start loading
//                 setDialogState(() {
//                   isLoading = true;
//                   errorMessage = null;
//                 }); 
                
//                 try {
//                   final isValid = await ApiService.validateSpecialPageAccess(
//                     passwordController.text,
//                   );
//                   if (isValid) {
//                     Navigator.pop(context, true);
//                   } else {
//                     setDialogState(() {
//                       isLoading = false;
//                       errorMessage = 'كلمة المرور غير صحيحة';
//                     });
//                   }
//                 } catch (e) {
//                   setDialogState(() {
//                     isLoading = false;
//                     errorMessage = 'خطأ في التحقق من كلمة المرور';
//                   });
//                 }
//               },
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: isLoading ? null : () => Navigator.pop(context, false), // DISABLE WHEN LOADING
//             child: Text(
//               'إلغاء',
//               style: TextStyle(
//                 color: isLoading 
//                     ? Colors.grey 
//                     : (isDark ? Colors.white60 : Colors.grey[700]),
//               ),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: isLoading ? null : () async { // DISABLE WHEN LOADING
//               if (passwordController.text.isEmpty) {
//                 setDialogState(() {
//                   errorMessage = 'يرجى إدخال كلمة المرور';
//                 });
//                 return;
//               }

//               // Start loading
//               setDialogState(() {
//                 isLoading = true;
//                 errorMessage = null;
//               });

//               try {
//                 final isValid = await ApiService.validateSpecialPageAccess(
//                   passwordController.text,
//                 );

//                 if (isValid) {
//                   Navigator.pop(context, true);
//                 } else {
//                   setDialogState(() {
//                     isLoading = false;
//                     errorMessage = 'كلمة المرور غير صحيحة';
//                   });
//                 }
//               } catch (e) {
//                 setDialogState(() {
//                   isLoading = false;
//                   errorMessage = 'خطأ في التحقق من كلمة المرور';
//                 });
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: isLoading 
//                   ? Colors.grey 
//                   : AppColors.primary,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
//             ),
//             child: isLoading // UPDATED CHILD WITH LOADING INDICATOR
//                 ? Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: const [
//                       SizedBox(
//                         width: 16,
//                         height: 16,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                         ),
//                       ),
//                       SizedBox(width: 8),
//                       Text('جاري التحقق...', style: TextStyle(color: Colors.white)),
//                     ],
//                   )
//                 : const Text('تحقق', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     ),
//   );

//   passwordController.dispose();
//   return result ?? false;  
// }

//   Future<void> _checkConnectivityAndLoad() async {
//   setState(() {
//     isLoading = true;
//   });
  
//   // Show loading for 2 seconds
//   await Future.delayed(Duration(seconds: 2));
//   final connectivityResult = await Connectivity().checkConnectivity();
  
//   if (connectivityResult.contains(ConnectivityResult.none)) {
//     _showNoInternetDialog();
//     setState(() {
//       isLoading = false;
//     });
//     return;
//   }
  
//   await _loadGrooms();
// }

// void _showNoInternetDialog() {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (context) => AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       title: Row(
//         children: [
//           Icon(Icons.wifi_off, color: Colors.orange),
//           SizedBox(width: 10),
//           Text('لا يوجد اتصال'),
//         ],
//       ),
//       content: Text('يرجى التحقق من اتصالك بالإنترنت'),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: Text('إلغاء'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             Navigator.pop(context);
//             _checkConnectivityAndLoad();
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: AppColors.primary,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           ),
//           child: Text('إعادة المحاولة', style: TextStyle(color: Colors.white)),
//         ),
//       ],
//     ),
//   );
// }


//   void _showViewGroomDialog(Map<String, dynamic> groom) {
//     showDialog(
//       context: context,
//       builder: (context) => ViewGroomDetailsDialog(groom: groom),
//     );
//   }


// //   Future<Map<String, dynamic>?> _getGroomReservationStatus(int groomId) async {
// //   try {
// //     // First check for validated reservation (highest priority)
// //     try {
// //       final validated = await ApiService.getMyValidatedReservation();
// //       if (validated.isNotEmpty && validated['groom_id'] == groomId) {
// //         return {
// //           'status': 'validated',
// //           'reservation': validated,
// //           'priority': 1
// //         };
// //       }
// //     } catch (e) {
// //       // No validated reservation found, continue checking
// //     }

// //     // Check for pending reservation (second priority)
// //     try {
// //       final pending = await ApiService.getMyPendingReservation();
// //       if (pending.isNotEmpty && pending['groom_id'] == groomId) {
// //         return {
// //           'status': 'pending_validation',
// //           'reservation': pending,
// //           'priority': 2
// //         };
// //       }
// //     } catch (e) {
// //       // No pending reservation found, continue checking
// //     }

// //     // Check for cancelled reservations (lowest priority)
// //     try {
// //       final cancelled = await ApiService.getMyCancelledReservations();
// //       if (cancelled.isNotEmpty) {
// //         // Find the most recent cancelled reservation for this groom
// //         final groomCancelled = cancelled.where((res) => res['groom_id'] == groomId).toList();
// //         if (groomCancelled.isNotEmpty) {
// //           // Sort by date and get the most recent
// //           groomCancelled.sort((a, b) => 
// //             DateTime.parse(b['created_at'] ?? '').compareTo(DateTime.parse(a['created_at'] ?? ''))
// //           );
// //           return {
// //             'status': 'cancelled',
// //             'reservation': groomCancelled.first,
// //             'priority': 3
// //           };
// //         }
// //       }
// //     } catch (e) {
// //       // No cancelled reservations found
// //     }

// //     // No reservation found
// //     return null;
// //   } catch (e) {
// //     print('Error getting reservation status: $e');
// //     return null;
// //   }
// // }
// Future<Map<String, dynamic>?> _getGroomReservationStatus(int groomId) async {
//   print('🔍 Starting reservation status check for groomId: $groomId');
  
//   try {
//     // Priority 1: Validated reservation
//     print('📋 Checking for validated reservations...');
//     try {
//       final validatedList = await ApiService.getValidatedReservations();
//       print('✅ Validated count: ${validatedList.length}');
//       final validatedForGroom = validatedList.where((r) => int.tryParse(r['groom_id'].toString()) == groomId).toList();
//       if (validatedForGroom.isNotEmpty) {
//         print('✨ MATCH FOUND - Returning validated reservation');
//         return {'status': 'validated', 'reservation': validatedForGroom.first, 'priority': 1};
//       }
//       print('❌ No validated reservations for this groom');
//     } catch (e) {
//       print('⚠️ Error fetching validated: $e');
//     }

//     // Priority 2: Pending reservation
//     print('📋 Checking for pending reservations...');
//     try {
//       final pendingList = await ApiService.getPendingReservations();
//       print('⏳ Pending count: ${pendingList.length}');
//       final pendingForGroom = pendingList.where((r) => int.tryParse(r['groom_id'].toString()) == groomId).toList();
//       if (pendingForGroom.isNotEmpty) {
//         print('✨ MATCH FOUND - Returning pending reservation');
//         return {'status': 'pending_validation', 'reservation': pendingForGroom.first, 'priority': 2};
//       }
//       print('❌ No pending reservations for this groom');
//     } catch (e) {
//       print('⚠️ Error fetching pending: $e');
//     }

//     // Priority 3: Most recent cancelled reservation
//     print('📋 Checking for cancelled reservations...');
//     try {
//       final cancelledList = await ApiService.getCancelledReservations();
//       print('❌ Cancelled count: ${cancelledList.length}');
//       final groomCancelled = cancelledList.where((r) => int.tryParse(r['groom_id'].toString()) == groomId).toList();
//       if (groomCancelled.isNotEmpty) {
//         groomCancelled.sort((a, b) => (DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(0))
//             .compareTo(DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(0)));
//         print('✨ MATCH FOUND - Returning cancelled reservation');
//         return {'status': 'cancelled', 'reservation': groomCancelled.first, 'priority': 3};
//       }
//       print('❌ No cancelled reservations for this groom');
//     } catch (e) {
//       print('⚠️ Error fetching cancelled: $e');
//     }

//     print('🚫 No reservation found for groomId: $groomId');
//     return null;
//   } catch (e) {
//     print('💥 Error getting reservation status: $e');
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
  
//   return LayoutBuilder(
//     builder: (context, constraints) {
//       // More granular screen size detection
//       final screenWidth = MediaQuery.of(context).size.width;
//       final isSmallScreen = screenWidth < 600;
//       final isTablet = screenWidth >= 600 && screenWidth < 1024;
//       final isDesktop = screenWidth >= 1024;
      
//       // Dynamic sizing based on screen
//       final cardMargin = isSmallScreen ? 8.0 : (isTablet ? 12.0 : 16.0);
//       final cardPadding = isSmallScreen ? 12.0 : (isTablet ? 16.0 : 20.0);
//       final avatarSize = isSmallScreen ? 45.0 : (isTablet ? 55.0 : 65.0);
//       final titleFontSize = isSmallScreen ? 16.0 : (isTablet ? 18.0 : 20.0);
      
//       return Container(
//         margin: EdgeInsets.symmetric(
//           horizontal: cardMargin, 
//           vertical: 6
//         ),
//         child: Material(
//           elevation: isSmallScreen ? 1 : (isTablet ? 2 : 3),
//           borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
//           color: Colors.white,
//           shadowColor: Colors.black.withOpacity(0.08),
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
//               border: Border.all(
//                 color: Colors.grey.withOpacity(0.1),
//                 width: 1,
//               ),
//             ),
//             child: Padding(
//               padding: EdgeInsets.all(cardPadding),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildHeaderSection(groom, isActive, groomId, 
//                     isSmallScreen, avatarSize, titleFontSize),
                  
//                   SizedBox(height: isSmallScreen ? 12 : 16),
                  
//                   _buildInformationGrid(groom, isSmallScreen, isTablet),
                  
//                   SizedBox(height: isSmallScreen ? 16 : 20),
                  
//                   _buildActionButtons(groom, status, isActive, isSmallScreen, isTablet),
                  

//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }

// Widget _buildHeaderSection(
//   Map<String, dynamic> groom, 
//   bool isActive, 
//   int? groomId, 
//   bool isSmallScreen,
//   double avatarSize,
//   double titleFontSize
// ) {
//   return Row(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       // Avatar Circle - responsive size
//       Container(
//         width: avatarSize,
//         height: avatarSize,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           gradient: LinearGradient(
//             colors: isActive 
//               ? [Colors.green.withOpacity(0.8), Colors.green.withOpacity(0.6)]
//               : [Colors.grey.withOpacity(0.8), Colors.grey.withOpacity(0.6)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Icon(
//           Icons.person,
//           color: Colors.white,
//           size: avatarSize * 0.5,
//         ),
//       ),
      
//       SizedBox(width: isSmallScreen ? 8 : 12),
      
//       // Name and Status - flexible sizing
//       Expanded(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               '${groom['first_name'] ?? ''} ${groom['last_name'] ?? ''}',
//               style: TextStyle(
//                 fontSize: titleFontSize,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey[800],
//               ),
//               overflow: TextOverflow.ellipsis,
//               maxLines: isSmallScreen ? 1 : 2,
//             ),
//             SizedBox(height: 4),
//             Text(
//               groom['phone_number']?.toString() ?? '',
//               style: TextStyle(
//                 fontSize: isSmallScreen ? 12 : 14,
//                 color: Colors.grey[600],
//               ),
//             ),
//           ],
//         ),
//       ),
      
//       SizedBox(width: 8),
      
//       // Status Badges Column - responsive sizing
//       Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           Container(
//             padding: EdgeInsets.symmetric(
//               horizontal: isSmallScreen ? 8 : 12, 
//               vertical: isSmallScreen ? 4 : 6
//             ),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: isActive 
//                   ? [Colors.green, Colors.green.shade600]
//                   : [Colors.red, Colors.red.shade600],
//               ),
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: (isActive ? Colors.green : Colors.red).withOpacity(0.3),
//                   blurRadius: 8,
//                   offset: Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Text(
//               isActive ? 'نشط' : 'غير نشط',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: isSmallScreen ? 10 : 12,
//               ),
//             ),
//           ),
          
//           if (groomId != null) ...[
//             SizedBox(height: 6),
//             _buildReservationStatusBadge(groomId, isSmallScreen),
//           ],
//         ],
//       ),
//     ],
//   );
// }
// Widget _buildReservationStatusBadge(int groomId, bool isSmallScreen) {
//   return FutureBuilder<Map<String, dynamic>?>(
//     future: _getGroomReservationStatus(groomId),
//     builder: (context, snapshot) {
//       if (snapshot.connectionState == ConnectionState.waiting) {
//         return Container(
//           padding: EdgeInsets.symmetric(
//             horizontal: isSmallScreen ? 6 : 8, 
//             vertical: 4
//           ),
//           decoration: BoxDecoration(
//             color: Colors.grey.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: SizedBox(
//             width: 10,
//             height: 10,
//             child: CircularProgressIndicator(strokeWidth: 1.5),
//           ),
//         );
//       }
      
//       String statusText;
//       List<Color> gradientColors;
      
//       if (snapshot.hasData && snapshot.data != null) {
//         final reservationStatus = snapshot.data!['status'] as String;
        
//         switch (reservationStatus) {
//           case 'validated':
//             statusText = 'حجز مؤكد';
//             gradientColors = [Colors.green, Colors.green.shade600];
//             break;
//           case 'pending_validation':
//             statusText = 'حجز معلق';
//             gradientColors = [Colors.orange, Colors.orange.shade600];
//             break;
//           case 'cancelled':
//             statusText = 'حجز ملغى';
//             gradientColors = [Colors.red, Colors.red.shade600];
//             break;
//           default:
//             statusText = 'غير معروف';
//             gradientColors = [Colors.grey, Colors.grey.shade600];
//         }
//       } else {
//         statusText = 'لا يوجد حجز';
//         gradientColors = [Colors.grey.shade400, Colors.grey.shade500];
//       }
      
//       return Container(
//         padding: EdgeInsets.symmetric(
//           horizontal: isSmallScreen ? 6 : 10, 
//           vertical: isSmallScreen ? 3 : 4
//         ),
//         constraints: BoxConstraints(
//           maxWidth: isSmallScreen ? 80 : 100,
//         ),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(colors: gradientColors),
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: gradientColors[0].withOpacity(0.3),
//               blurRadius: 6,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Text(
//           statusText,
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             fontSize: isSmallScreen ? 9 : 10,
//           ),
//           textAlign: TextAlign.center,
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//         ),
//       );
//     },
//   );
// }

// Widget _buildInformationGrid(Map<String, dynamic> groom, bool isSmallScreen, bool isTablet) {
//   final basicInfo = <Map<String, String>>[
//     {'label': 'اسم الأب', 'value': groom['father_name']?.toString() ?? ''},
//     {'label': 'اسم الجد', 'value': groom['grandfather_name']?.toString() ?? ''},
//     {'label': 'تاريخ الميلاد', 'value': groom['birth_date']?.toString() ?? ''},
//     {'label': 'عنوان السكن', 'value': groom['home_address']?.toString() ?? ''},
//   ];
  
//   final guardianInfo = <Map<String, String>>[
//     {'label': 'اسم الولي', 'value': groom['guardian_name']?.toString() ?? ''},
//     {'label': 'هاتف الولي', 'value': groom['guardian_phone']?.toString() ?? ''},
//     {'label': 'صلة القرابة', 'value': groom['guardian_relation']?.toString() ?? ''},
//   ];
  
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       // Basic Information Section
//       _buildInfoSection(
//         title: 'المعلومات الأساسية',
//         icon: Icons.person_outline,
//         color: Colors.green,
//         items: basicInfo,
//         isSmallScreen: isSmallScreen,
//       ),
      
//       // Guardian Information Section (only if data exists)
//       if (guardianInfo.any((info) => info['value']!.isNotEmpty)) ...[
//         SizedBox(height: 16),
//         _buildInfoSection(
//           title: 'معلومات الولي',
//           icon: Icons.family_restroom,
//           color: Colors.purple,
//           items: guardianInfo,
//           isSmallScreen: isSmallScreen,
//         ),
//       ],
//     ],
//   );
// }

// Widget _buildInfoSection({
//   required String title,
//   required IconData icon,
//   required Color color,
//   required List<Map<String, String>> items,
//   required bool isSmallScreen,
// }) {
//   return Container(
//     padding: EdgeInsets.all(12),
//     decoration: BoxDecoration(
//       color: color.withOpacity(0.05),
//       borderRadius: BorderRadius.circular(12),
//       border: Border.all(
//         color: color.withOpacity(0.2),
//         width: 1,
//       ),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Section Header
//         Row(
//           children: [
//             Container(
//               padding: EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(
//                 icon,
//                 color: color,
//                 size: 16,
//               ),
//             ),
//             SizedBox(width: 8),
//             Text(
//               title,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: color,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
        
//         SizedBox(height: 8),
        
//         // Information Items
//         ...items
//             .where((item) => item['value']!.isNotEmpty)
//             .map((item) => _buildCompactInfoRow(
//                   item['label']!, 
//                   item['value']!, 
//                   isSmallScreen
//                 )),
//       ],
//     ),
//   );
// }

// Widget _buildCompactInfoRow(String label, String value, bool isSmallScreen) {
//   return Padding(
//     padding: EdgeInsets.symmetric(vertical: 3),
//     child: Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           width: isSmallScreen ? 80 : 100,
//           child: Text(
//             '$label:',
//             style: TextStyle(
//               fontWeight: FontWeight.w500,
//               color: Colors.grey[700],
//               fontSize: 12,
//             ),
//           ),
//         ),
//         Expanded(
//           child: Text(
//             value.isNotEmpty ? value : 'غير محدد',
//             style: TextStyle(
//               color: value.isNotEmpty ? Colors.black87 : Colors.grey,
//               fontSize: 12,
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }

// Widget _buildActionButtons(
//   Map<String, dynamic> groom, 
//   String status, 
//   bool isActive, 
//   bool isSmallScreen,
//   bool isTablet
// ) {
//   if (isSmallScreen) {
//     return _buildMobileActionButtons(groom, status, isActive);
//   } else {
//     return _buildDesktopActionButtons(groom, status, isActive, isTablet);
//   }
// }


// Widget _buildMobileActionButtons(Map<String, dynamic> groom, String status, bool isActive) {
//   return Column(
//     children: [
//       // Primary Actions Row
//       Row(
//         children: [
//           _buildModernButton(
//             icon: Icons.visibility,
//             label: 'عرض',
//             colors: [Colors.purple, Colors.purple.shade700],
//             onPressed: () => _showViewGroomDialog(groom),
//           ),
//           SizedBox(width: 6),
//           _buildModernButton(
//             icon: Icons.edit,
//             label: 'تعديل',
//             colors: [Colors.green, AppColors.primary],
//             onPressed: () async  {
//                         // Check if tab requires access verification
//                 bool hasAccess = await _verifyAccessForTab();
                
//                 if (!hasAccess) {
//                   return; // Don't navigate if access is denied
//                 }
//                 _showEditGroomDialog(groom);
//               },          
//           ),
//         ],
//       ),
      
//       SizedBox(height: 6),
      
//       // Secondary Actions Row
//       Row(
//         children: [
//           _buildModernButton(
//             icon: isActive ? Icons.visibility_off : Icons.visibility,
//             label: isActive ? 'إيقاف' : 'تفعيل',
//             colors: isActive 
//               ? [Colors.orange, Colors.orange.shade700]
//               : [Colors.green, Colors.green.shade700],
//             onPressed: () => _updateGroomStatus(
//                 groom['phone_number']?.toString() ?? '', 
//                 status
//               ),
//           ),
//           SizedBox(width: 6),
//           _buildModernButton(
//             icon: Icons.delete,
//             label: 'حذف',
//             colors: [Colors.red, Colors.red.shade700],
//             onPressed: () async  {
//                               // Check if tab requires access verification
//                       bool hasAccess = await _verifyAccessForTab();
//                       print('Access verification result+++++++++++++: $hasAccess');
//                       if (!hasAccess) {
//                         return; // Don't navigate if access is denied
//                       }
//                     _deleteGroom(groom['phone_number']?.toString() ?? '');      
//             },          
//           ),
//         ],
//       ),
//     ],
//   );
// }
// Widget _buildDesktopActionButtons(
//   Map<String, dynamic> groom, 
//   String status, 
//   bool isActive,
//   bool isTablet
// ) {
//   return Wrap(
//     spacing: isTablet ? 6 : 8,
//     runSpacing: isTablet ? 6 : 8,
//     alignment: WrapAlignment.spaceEvenly,
//     children: [
//       _buildModernButton(
//         icon: Icons.visibility,
//         label: isTablet ? 'عرض' : 'عرض التفاصيل',
//         colors: [Colors.purple, Colors.purple.shade700],
//         onPressed: () => _showViewGroomDialog(groom),
//         isCompact: isTablet,
//       ),
//       _buildModernButton(
//         icon: Icons.edit,
//         label: 'تعديل',
//         colors: [Colors.green, AppColors.primary],
//         onPressed: () async  {
//                   // Check if tab requires access verification
//           bool hasAccess = await _verifyAccessForTab();
          
//           if (!hasAccess) {
//             return; // Don't navigate if access is denied
//           }
//           _showEditGroomDialog(groom);
//         },
//         isCompact: isTablet,
//       ),
//       _buildModernButton(
//         icon: isActive ? Icons.visibility_off : Icons.visibility,
//         label: isActive ? (isTablet ? 'إيقاف' : 'إيقاف التفعيل') : 'تفعيل',
//         colors: isActive 
//           ? [Colors.orange, Colors.orange.shade700]
//           : [Colors.green, Colors.green.shade700],
//           onPressed: () => _updateGroomStatus(
//             groom['phone_number']?.toString() ?? '', 
//             status
//           ),
//         // onPressed: () async  {
//         //           // Check if tab requires access verification
//         //   bool hasAccess = await _verifyAccessForTab();
//         //   print('Access verification result+++++++++++++: $hasAccess');
//         //   if (!hasAccess) {
//         //     return; // Don't navigate if access is denied
//         //   }
//         //   _updateGroomStatus(
//         //     groom['phone_number']?.toString() ?? '', 
//         //     status
//         //   );      
//         //   },
        
//         isCompact: isTablet,
//       ),
//       _buildModernButton(
//         icon: Icons.delete,
//         label: 'حذف',
//         colors: [Colors.red, Colors.red.shade700],
//         onPressed: () async  {
//                   // Check if tab requires access verification
//           bool hasAccess = await _verifyAccessForTab();
//           print('Access verification result+++++++++++++: $hasAccess');
//           if (!hasAccess) {
//             return; // Don't navigate if access is denied
//           }
//          _deleteGroom(groom['phone_number']?.toString() ?? '');      
//           },
//         isCompact: isTablet,
//       ),
//     ],
//   );
// }

// Widget _buildModernButton({
//   required IconData icon,
//   required String label,
//   required List<Color> colors,
//   required VoidCallback onPressed,
//   bool isCompact = true,
// }) {
//   return Flexible(
//     child: Container(
//       height: 40,
//       constraints: BoxConstraints(
//         minWidth: isCompact ? 60 : 100,
//         maxWidth: double.infinity,
//       ),
//       child: ElevatedButton(
//         onPressed: onPressed,
//         style: ElevatedButton.styleFrom(
//           elevation: 0,
//           backgroundColor: Colors.transparent,
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           padding: EdgeInsets.symmetric(
//             horizontal: isCompact ? 4 : 12,
//             vertical: 6,
//           ),
//         ),
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(colors: colors),
//             borderRadius: BorderRadius.circular(10),
//             boxShadow: [
//               BoxShadow(
//                 color: colors[0].withOpacity(0.3),
//                 blurRadius: 6,
//                 offset: Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Container(
//             padding: EdgeInsets.symmetric(
//               horizontal: isCompact ? 6 : 10,
//               vertical: 6,
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(icon, size: 14),
//                 if (!isCompact) ...[
//                   SizedBox(width: 4),
//                   Flexible(
//                     child: Text(
//                       label,
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 11,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                       maxLines: 1,
//                     ),
//                   ),
//                 ] else if (label.length <= 4) ...[
//                   SizedBox(width: 2),
//                   Text(
//                     label,
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 10,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     ),
//   );
// }

// // Updated main build method with modern AppBar
// @override
// Widget build(BuildContext context) {
  
//   return Scaffold(
//     appBar: _buildModernAppBar(),
//     body: Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             Colors.green.shade50,
//             Colors.white,
//           ],
//         ),
//       ),
//       child: RefreshIndicator(
//         onRefresh: _loadGrooms,
//         color: AppColors.primary,
//         child: _buildBody(),
        
//       ),

//     ),
//   );
// }

// PreferredSizeWidget _buildModernAppBar() {
//   final isDark = Theme.of(context).brightness == Brightness.dark;
//   return AppBar(
//     elevation: 0,
//     backgroundColor: Colors.transparent,
//     flexibleSpace: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     isDark ? AppColors.primary.withOpacity(0.4):AppColors.primary.withOpacity(0.8) ,
//                     AppColors.primary,
//                     AppColors.primary,
//                     isDark ? AppColors.primary.withOpacity(0.4):AppColors.primary.withOpacity(0.8) ,
//                     // isDark ? AppColors.primary.withOpacity(0.4):const Color.fromARGB(255, 130, 161, 112).withOpacity(0.9),
                    
//                   ],
//                 ),
//               ),
//             ),
//     title: LayoutBuilder(
//       builder: (context, constraints) {
//         final isSmallScreen = MediaQuery.of(context).size.width < 600;
//         return Text(
//           'إدارة العرسان',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: isSmallScreen ? 18 : 20,
//           ),
//         );
//       },
//     ),
//     foregroundColor: Colors.white,
//     leading: IconButton(
//       icon: Icon(Icons.arrow_back_ios_new, size: 20),
//       onPressed: () {
//         Navigator.pushReplacementNamed(context, '/clan_admin_home');
//       },
//     ),
//     actions: [
//       LayoutBuilder(
//         builder: (context, constraints) {
//           final screenWidth = MediaQuery.of(context).size.width;
//           final isSmallScreen = screenWidth < 600;
          
//           return Row(
//             children: [
//               Container(
//                 margin: EdgeInsets.only(right: isSmallScreen ? 4 : 8),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: IconButton(
//                   onPressed: () async {
//                     final result = await Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => MultiStepSignupScreen(),
//                       ),
//                     );
//                     if (result != null) {
//                       _loadGrooms();
//                     }
//                   },
//                   icon: Icon(Icons.person_add, size: isSmallScreen ? 18 : 20),
//                   tooltip: 'إضافة عريس جديد',
//                   padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
//                 ),
//               ),
//               Container(
//                 margin: EdgeInsets.only(
//                   right: isSmallScreen ? 4 : 8, 
//                   left: isSmallScreen ? 8 : 16
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: IconButton(
//                   onPressed: _checkConnectivityAndLoad,
//                   icon: Icon(Icons.refresh, size: isSmallScreen ? 18 : 20),
//                   tooltip: 'تحديث القائمة',
//                   padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     ],
//   );
// }
// Widget _buildBody() {
//   if (isLoading) {
//     return _buildLoadingState();
//   }
  
//   if (errorMessage != null) {
//     return _buildErrorState();
//   }
  
//   if (grooms.isEmpty) {
//     return _buildEmptyState();
//   }
  
//   return LayoutBuilder(
//     builder: (context, constraints) {
//       final isSmallScreen = constraints.maxWidth < 600;
      
//       return ListView.builder(
//         padding: EdgeInsets.only(
//           top: isSmallScreen ? 12 : 16,
//           left: 2,
//           right: 2,
//           bottom: isSmallScreen ? 150 : 120,
//         ),
//         itemCount: grooms.length,
//         itemBuilder: (context, index) => _buildGroomCard(grooms[index]),
//       );
//     },
//   );
// }
// Widget _buildLoadingState() {
//   return Center(
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           padding: EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.1),
//                 blurRadius: 20,
//                 offset: Offset(0, 5),
//               ),
//             ],
//           ),
//           child: CircularProgressIndicator(
//             valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
//             strokeWidth: 3,
//           ),
//         ),
//         SizedBox(height: 20),
//         Text(
//           'جاري تحميل البيانات...',
//           style: TextStyle(
//             fontSize: 16,
//             color: Colors.grey[600],
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     ),
//   );
// }

// Widget _buildErrorState() {
//   return Center(
//     child: Container(
//       margin: EdgeInsets.all(32),
//       padding: EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.red.withOpacity(0.1),
//             blurRadius: 20,
//             offset: Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             padding: EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.red.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(Icons.error_outline, size: 48, color: Colors.red),
//           ),
//           SizedBox(height: 16),
//           Text(
//             'خطأ في تحميل البيانات',
//             style: TextStyle(
//               fontSize: 18, 
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[800],
//             ),
//           ),
//           SizedBox(height: 8),
//           Text(
//             errorMessage!,
//             style: TextStyle(color: Colors.grey[600]),
//             textAlign: TextAlign.center,
//           ),
//           SizedBox(height: 20),
//           ElevatedButton.icon(
//             onPressed: _checkConnectivityAndLoad,
//             icon: Icon(Icons.refresh),
//             label: Text('إعادة المحاولة'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//               padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

// Widget _buildEmptyState() {
//   return Center(
//     child: Container(
//       margin: EdgeInsets.all(32),
//       padding: EdgeInsets.all(32),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 20,
//             offset: Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.green.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.people_outline, 
//               size: 64, 
//               color: AppColors.primary,
//             ),
//           ),
//           SizedBox(height: 20),
//           Text(
//             'لا توجد عرسان مسجلين',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[800],
//             ),
//           ),
//           SizedBox(height: 8),
//           Text(
//             'ابدأ بإضافة أول عريس',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[600],
//             ),
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

//   // Future<void> _updateGroom() async {
//   //   if (!_formKey.currentState!.validate()) return;

//   //   setState(() {
//   //     isLoading = true;
//   //   });

//   //   try {
//   //     // Check if phone number has changed
//   //     final originalPhoneNumber = widget.groom['phone_number']?.toString() ?? '';
//   //     final newPhoneNumber = _phoneController.text.trim();
//   //     final phoneNumberChanged = originalPhoneNumber != newPhoneNumber && newPhoneNumber.isNotEmpty;

//   //     final updatedData = await ApiService.updateGroomDetails(
//   //       widget.groom['id'],
//   //       firstName: _firstNameController.text.trim().isEmpty ? null : _firstNameController.text.trim(),
//   //       lastName: _lastNameController.text.trim().isEmpty ? null : _lastNameController.text.trim(),
//   //       fatherName: _fatherNameController.text.trim().isEmpty ? null : _fatherNameController.text.trim(),
//   //       grandfatherName: _grandfatherNameController.text.trim().isEmpty ? null : _grandfatherNameController.text.trim(),
//   //       phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
//   //       birthDate: _birthDateController.text.trim().isEmpty ? null : _birthDateController.text.trim(),
//   //       birthAddress: _birthAddressController.text.trim().isEmpty ? null : _birthAddressController.text.trim(),
//   //       homeAddress: _homeAddressController.text.trim().isEmpty ? null : _homeAddressController.text.trim(),
//   //       guardianName: _guardianNameController.text.trim().isEmpty ? null : _guardianNameController.text.trim(),
//   //       guardianPhone: _guardianPhoneController.text.trim().isEmpty ? null : _guardianPhoneController.text.trim(),
//   //       guardianHomeAddress: _guardianHomeAddressController.text.trim().isEmpty ? null : _guardianHomeAddressController.text.trim(),
//   //       guardianBirthAddress: _guardianBirthAddressController.text.trim().isEmpty ? null : _guardianBirthAddressController.text.trim(),
//   //       guardianBirthDate: _guardianBirthDateController.text.trim().isEmpty ? null : _guardianBirthDateController.text.trim(),
//   //       guardianRelation: _guardianRelationController.text.trim().isEmpty ? null : _guardianRelationController.text.trim(),
//   //     );

//   //     widget.onUpdate({
//   //       'first_name': _firstNameController.text.trim(),
//   //       'last_name': _lastNameController.text.trim(),
//   //       'father_name': _fatherNameController.text.trim(),
//   //       'grandfather_name': _grandfatherNameController.text.trim(),
//   //       'phone_number': _phoneController.text.trim(),
//   //       'birth_date': _birthDateController.text.trim(),
//   //       'birth_address': _birthAddressController.text.trim(),
//   //       'home_address': _homeAddressController.text.trim(),
//   //       'guardian_name': _guardianNameController.text.trim(),
//   //       'guardian_phone': _guardianPhoneController.text.trim(),
//   //       'guardian_home_address': _guardianHomeAddressController.text.trim(),
//   //       'guardian_birth_address': _guardianBirthAddressController.text.trim(),
//   //       'guardian_birth_date': _guardianBirthDateController.text.trim(),
//   //       'guardian_relation': _guardianRelationController.text.trim(),
//   //     });

//   //     Navigator.pop(context);

//   //     // If phone number was changed, redirect to OTP screen
//   //     if (phoneNumberChanged) {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(
//   //           content: Text('تم تحديث رقم الهاتف. يجب التحقق من الرقم الجديد'),
//   //           backgroundColor: Colors.orange,
//   //         ),
//   //       );
        
//   //       // send OTP to new phone number
//   //       await ApiService.resendOTP(newPhoneNumber);


//   //       // Navigate to OTP screen for phone verification
//   //       Navigator.pushReplacement(
//   //         context,
//   //         MaterialPageRoute(
//   //           builder: (context) => OTPVerificationScreenE(
//   //             phoneNumber: newPhoneNumber,
//   //             isClanadmin:true
//   //           ),
//   //         ),
//   //       );
//   //     } else {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(
//   //           content: Text('تم تحديث معلومات العريس بنجاح'),
//   //           backgroundColor: Colors.green,
//   //         ),
//   //       );
//   //     }
//   //   } catch (e) {
//   //     ScaffoldMessenger.of(context).showSnackBar( 
//   //       SnackBar(
//   //         content: Text('خطأ في التحديث: ${e.toString()}'),
//   //         backgroundColor: Colors.red,
//   //       ),
//   //     );
//   //   } finally {
//   //     setState(() {
//   //       isLoading = false;
//   //     });
//   //   }
//   // }

//  Future<void> _updateGroom() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       // Check if phone number has changed
//       final originalPhoneNumber = widget.groom['phone_number']?.toString() ?? '';
//       final newPhoneNumber = _phoneController.text.trim();
//       final phoneNumberChanged = originalPhoneNumber != newPhoneNumber && newPhoneNumber.isNotEmpty;

//       // If phone number is being changed, check for active reservations
//       if (phoneNumberChanged && widget.groom['id'] != null) {
//         final groomId = widget.groom['id'] as int;
        
//         // Check for validated reservation
//         try {
//           final validatedList = await ApiService.getValidatedReservations();
//           final hasValidated = validatedList.any((res) => 
//             int.tryParse(res['groom_id'].toString()) == groomId
//           );
          
//           if (hasValidated) {
//             if (!mounted) return;
//             setState(() {
//               isLoading = false;
//             });
            
//             _showModernErrorDialog('لا يمكن تغيير رقم الهاتف لوجود حجز مؤكد');
//             return;
//           }
//         } catch (e) {
//           // Continue checking pending reservations
//         }
        
//         // Check for pending reservation
//         try {
//           final pendingList = await ApiService.getPendingReservations();
//           final hasPending = pendingList.any((res) => 
//             int.tryParse(res['groom_id'].toString()) == groomId
//           );
          
//           if (hasPending) {
//             if (!mounted) return;
//             setState(() {
//               isLoading = false;
//             });
            
//             _showModernErrorDialog('لا يمكن تغيير رقم الهاتف لوجود حجز معلق');
//             return;
//           }
//         } catch (e) {
//           // Continue with update if error checking reservations
//         }
//       }

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

//       // Check if widget is still mounted before proceeding with navigation/snackbars
//       if (!mounted) return;

//       Navigator.pop(context);

//       // If phone number was changed, redirect to OTP screen
//       if (phoneNumberChanged) {
//         if (!mounted) return;
        
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('تم تحديث رقم الهاتف. يجب التحقق من الرقم الجديد'),
//             backgroundColor: Colors.orange,
//           ),
//         );
        
//         // send OTP to new phone number
//         await ApiService.resendOTP(newPhoneNumber);

//         // Check mounted again before navigation
//         if (!mounted) return;

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
//         if (!mounted) return;
        
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('تم تحديث معلومات العريس بنجاح'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       if (!mounted) return;
      
//       ScaffoldMessenger.of(context).showSnackBar( 
//         SnackBar(
//           content: Text('خطأ في التحديث: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }

//   // Add this method to your _EditGroomDialogState class
// void _showModernErrorDialog(String message) {
//   showDialog(
//     context: context,
//     barrierDismissible: true,
//     builder: (BuildContext context) {
//       return Dialog(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         child: Container(
//           width: MediaQuery.of(context).size.width * 0.85,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 Colors.white,
//                 Colors.red.shade50.withOpacity(0.3),
//               ],
//             ),
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 20,
//                 offset: Offset(0, 10),
//               ),
//               BoxShadow(
//                 color: Colors.red.withOpacity(0.1),
//                 blurRadius: 40,
//                 offset: Offset(0, 20),
//               ),
//             ],
//           ),
//           child: Padding(
//             padding: EdgeInsets.all(24),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Error Icon with Animation
//                 Container(
//                   width: 80,
//                   height: 80,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Colors.red.shade400, Colors.red.shade600],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.red.withOpacity(0.3),
//                         blurRadius: 15,
//                         offset: Offset(0, 5),
//                       ),
//                     ],
//                   ),
//                   child: Icon(
//                     Icons.error_outline_rounded,
//                     color: Colors.white,
//                     size: 40,
//                   ),
//                 ),
                
//                 SizedBox(height: 20),
                
//                 // Title
//                 Text(
//                   'تعذر التحديث',
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey[800],
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
                
//                 SizedBox(height: 12),
                
//                 // Message
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                   decoration: BoxDecoration(
//                     color: Colors.red.shade50.withOpacity(0.5),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: Colors.red.withOpacity(0.2),
//                       width: 1,
//                     ),
//                   ),
//                   child: Text(
//                     message,
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.grey[700],
//                       height: 1.4,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
                
//                 SizedBox(height: 24),
                
//                 // Action Button
//                 Container(
//                   width: double.infinity,
//                   height: 48,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Colors.red.shade500, Colors.red.shade700],
//                       begin: Alignment.centerLeft,
//                       end: Alignment.centerRight,
//                     ),
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.red.withOpacity(0.3),
//                         blurRadius: 8,
//                         offset: Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Material(
//                     color: Colors.transparent,
//                     child: InkWell(
//                       borderRadius: BorderRadius.circular(12),
//                       onTap: () => Navigator.of(context).pop(),
//                       child: Center(
//                         child: Text(
//                           'موافق',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }


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
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[800]),
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
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[800]),
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
//     // Priority 1: Validated reservation
//     try {
//       final validated = await ApiService.getMyValidatedReservation();
//       if (validated.isNotEmpty && validated['groom_id'] == groomId) {
//         return {'status': 'validated', 'reservation': validated, 'priority': 1};
//       }
//     } catch (_) {}

//     // Priority 2: Pending reservation
//     try {
//       final pending = await ApiService.getMyPendingReservation();
//       if (pending.isNotEmpty && pending['groom_id'] == groomId) {
//         return {'status': 'pending_validation', 'reservation': pending, 'priority': 2};
//       }
//     } catch (_) {}

//     // Priority 3: Most recent cancelled reservation
//     try {
//       final cancelled = await ApiService.getMyCancelledReservations();
//       final groomCancelled = cancelled.where((r) => r['groom_id'] == groomId).toList();
//       if (groomCancelled.isNotEmpty) {
//         groomCancelled.sort((a, b) => (DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(0))
//             .compareTo(DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(0)));
//         return {'status': 'cancelled', 'reservation': groomCancelled.first, 'priority': 3};
//       }
//     } catch (_) {}

//     return null;
//   } catch (e) {
//     print('Error getting reservation status: $e');
//     return null;
//   }
// }
//   Widget _buildDetailRow(String label, String value, bool isDark) {



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
//                 color: isDark ? Colors.white  : Colors.grey[700],
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value.isNotEmpty ? value : 'غير محدد',
//               style: TextStyle(
//                 color:  const Color.fromARGB(255, 218, 218, 218),
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
//           color: Colors.green[800],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final status = groom['status']?.toString() ?? 'inactive';
//     final isActive = status == 'active';
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     final isDark = themeProvider.isDarkMode;
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
//                     _buildDetailRow('الاسم الأول', groom['first_name'] ?? '', isDark),
//                     _buildDetailRow('اسم العائلة', groom['last_name'] ?? '', isDark),
//                     _buildDetailRow('اسم الأب', groom['father_name'] ?? '' , isDark),
//                     _buildDetailRow('اسم الجد', groom['grandfather_name'] ?? '', isDark),
//                     _buildDetailRow('رقم الهاتف', groom['phone_number']?.toString() ?? '', isDark),
//                     _buildDetailRow('تاريخ الميلاد', groom['birth_date'] ?? '', isDark),
//                     _buildDetailRow('مكان الميلاد', groom['birth_address'] ?? '', isDark),
//                     _buildDetailRow('عنوان السكن', groom['home_address'] ?? '', isDark),
                    
//                     // Guardian Information
//                     _buildSectionTitle('معلومات الولي'),
//                     _buildDetailRow('اسم الولي', groom['guardian_name'] ?? '', isDark),
//                     _buildDetailRow('هاتف الولي', groom['guardian_phone'] ?? '', isDark),
//                     _buildDetailRow('عنوان سكن الولي', groom['guardian_home_address'] ?? '', isDark),
//                     _buildDetailRow('مكان ميلاد الولي', groom['guardian_birth_address'] ?? '', isDark),
//                     _buildDetailRow('تاريخ ميلاد الولي', groom['guardian_birth_date'] ?? '', isDark),
//                     _buildDetailRow('صلة القرابة', groom['guardian_relation'] ?? '', isDark),
                    
//                     // Additional Information
//                     _buildSectionTitle('معلومات إضافية'),
//                     _buildDetailRow('تاريخ الإنشاء', groom['created_at'] ?? '', isDark),
//                     _buildDetailRow('تاريخ آخر تحديث', groom['updated_at'] ?? '', isDark),
//                     _buildDetailRow('معرف العريس', groom['id']?.toString() ?? '', isDark),

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
//                                 _buildDetailRow('حالة الحجز', statusText, isDark),
//                                 if (reservation['hall_name'] != null)
//                                   _buildDetailRow('اسم القاعة', reservation['hall_name'] ?? '', isDark),
//                                 if (reservation['event_date'] != null)
//                                   _buildDetailRow('تاريخ الحدث', reservation['event_date'] ?? '', isDark),
//                                 if (reservation['created_at'] != null)
//                                   _buildDetailRow('تاريخ الحجز', reservation['created_at'] ?? '', isDark),
//                                 if (reservation['total_cost'] != null)
//                                   _buildDetailRow('التكلفة الإجمالية', '${reservation['total_cost']} دينار', isDark),
//                               ],
//                             );
//                           }
                          
//                           return _buildDetailRow('حالة الحجز', 'لا يوجد حجز', isDark);
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
//                 backgroundColor: Colors.green[800],
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