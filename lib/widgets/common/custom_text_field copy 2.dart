// // lib/widgets/common/custom_text_field.dart
// import 'package:flutter/material.dart';
// import '../../utils/colors.dart';

// class CustomTextField extends StatelessWidget {
//   final TextEditingController? controller;
//   final String label;
//   final String? hint;
//   final IconData? prefixIcon;
//   final Widget? suffixIcon;
//   final bool obscureText;
//   final TextInputType keyboardType;
//   final String? Function(String?)? validator;
//   final Function(String)? onChanged;
//   final int? maxLines;
//   final bool enabled;

//   const CustomTextField({
//     Key? key,
//     this.controller,
//     required this.label,
//     this.hint,
//     this.prefixIcon,
//     this.suffixIcon,
//     this.obscureText = false,
//     this.keyboardType = TextInputType.text,
//     this.validator,
//     this.onChanged,
//     this.maxLines = 1,
//     this.enabled = true,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (label.isNotEmpty) ...[
//           Padding(
//             padding: EdgeInsets.only(bottom: 8, right: 4),
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//           ),
//         ],
//         Container(
//           decoration: BoxShadow(
//             color: Colors.black.withOpacity(0.02),
//             blurRadius: 8,
//             offset: Offset(0, 2),
//           ) != null ? BoxDecoration(
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.02),
//                 blurRadius: 8,
//                 offset: Offset(0, 2),
//               ),
//             ],
//           ) : null,
//           child: TextFormField(
//             controller: controller,
//             obscureText: obscureText,
//             keyboardType: keyboardType,
//             validator: validator,
//             onChanged: onChanged,
//             maxLines: maxLines,
//             enabled: enabled,
//             style: TextStyle(
//               fontSize: 16,
//               color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
//               fontWeight: FontWeight.w500,
//             ),
//             decoration: InputDecoration(
//               hintText: hint,
//               hintStyle: TextStyle(
//                 color: AppColors.textSecondary.withOpacity(0.7),
//                 fontSize: 15,
//                 fontWeight: FontWeight.w400,
//               ),
//               prefixIcon: prefixIcon != null
//                   ? Container(
//                       margin: EdgeInsets.only(right: 12, left: 16),
//                       padding: EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: AppColors.primary.withOpacity(0.08),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Icon(
//                         prefixIcon,
//                         color: AppColors.primary,
//                         size: 20,
//                       ),
//                     )
//                   : null,
//               suffixIcon: suffixIcon,
//               filled: true,
//               fillColor: enabled ? Colors.white : Colors.grey.shade50,
//               contentPadding: EdgeInsets.symmetric(
//                 horizontal: 16,
//                 vertical: 18,
//               ),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(16),
//                 borderSide: BorderSide(
//                   color: AppColors.border,
//                   width: 1.5,
//                 ),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(16),
//                 borderSide: BorderSide(
//                   color: AppColors.border,
//                   width: 1.5,
//                 ),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(16),
//                 borderSide: BorderSide(
//                   color: AppColors.primary,
//                   width: 2,
//                 ),
//               ),
//               errorBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(16),
//                 borderSide: BorderSide(
//                   color: AppColors.error,
//                   width: 1.5,
//                 ),
//               ),
//               focusedErrorBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(16),
//                 borderSide: BorderSide(
//                   color: AppColors.error,
//                   width: 2,
//                 ),
//               ),
//               disabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(16),
//                 borderSide: BorderSide(
//                   color: AppColors.border.withOpacity(0.5),
//                   width: 1,
//                 ),
//               ),
//               errorStyle: TextStyle(
//                 color: AppColors.error,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// // lib/widgets/common/custom_dropdown.dart
// class CustomDropdown<T> extends StatelessWidget {
//   final T? value;
//   final String hint;
//   final List<DropdownMenuItem<T>> items;
//   final Function(T?) onChanged;
//   final IconData? prefixIcon;
//   final bool enabled;
//   final String? Function(T?)? validator;

//   const CustomDropdown({
//     Key? key,
//     this.value,
//     required this.hint,
//     required this.items,
//     required this.onChanged,
//     this.prefixIcon,
//     this.enabled = true,
//     this.validator,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.02),
//             blurRadius: 8,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: DropdownButtonFormField<T>(
//         value: value,
//         items: items,
//         onChanged: enabled ? onChanged : null,
//         validator: validator,
//         style: TextStyle(
//           fontSize: 16,
//           color: AppColors.textPrimary,
//           fontWeight: FontWeight.w500,
//         ),
//         decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: TextStyle(
//             color: AppColors.textSecondary.withOpacity(0.7),
//             fontSize: 15,
//             fontWeight: FontWeight.w400,
//           ),
//           prefixIcon: prefixIcon != null
//               ? Container(
//                   margin: EdgeInsets.only(right: 12, left: 16),
//                   padding: EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: AppColors.primary.withOpacity(0.08),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(
//                     prefixIcon,
//                     color: AppColors.primary,
//                     size: 20,
//                   ),
//                 )
//               : null,
//           filled: true,
//           fillColor: enabled ? Colors.white : Colors.grey.shade50,
//           contentPadding: EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 18,
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide: BorderSide(
//               color: AppColors.border,
//               width: 1.5,
//             ),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide: BorderSide(
//               color: AppColors.border,
//               width: 1.5,
//             ),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide: BorderSide(
//               color: AppColors.primary,
//               width: 2,
//             ),
//           ),
//           errorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide: BorderSide(
//               color: AppColors.error,
//               width: 1.5,
//             ),
//           ),
//           focusedErrorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide: BorderSide(
//               color: AppColors.error,
//               width: 2,
//             ),
//           ),
//           disabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide: BorderSide(
//               color: AppColors.border.withOpacity(0.5),
//               width: 1,
//             ),
//           ),
//           errorStyle: TextStyle(
//             color: AppColors.error,
//             fontSize: 12,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         dropdownColor: Colors.white,
//         elevation: 8,
//         borderRadius: BorderRadius.circular(16),
//         icon: Container(
//           margin: EdgeInsets.only(left: 12),
//           child: Icon(
//             Icons.keyboard_arrow_down_rounded,
//             color: enabled ? AppColors.primary : AppColors.textSecondary,
//             size: 24,
//           ),
//         ),
//         isExpanded: true,
//       ),
//     );
//   }
// }

// // lib/widgets/common/loading_button.dart
// // Updated LoadingButton Widget (add this if not already present)
// class LoadingButton extends StatelessWidget {
//   final VoidCallback onPressed;
//   final bool isLoading;
//   final String text;
//   final IconData icon;

//   const LoadingButton({
//     Key? key,
//     required this.onPressed,
//     required this.isLoading,
//     required this.text,
//     required this.icon,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: 56,
//       child: ElevatedButton.icon(
//         onPressed: isLoading ? null : onPressed,
//         icon: isLoading
//             ? SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               )
//             : Icon(icon, color: Colors.white),
//         label: Text(
//           isLoading ? 'جاري التحقق...' : text,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Colors.white,
//           ),
//         ),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.primary,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           elevation: 4,
//           shadowColor: AppColors.primary.withOpacity(0.3),
//         ),
//       ),
//     );
//   }
// }

// // lib/utils/colors.dart (Updated color scheme)
// class AppColors {
//   static const Color primary = Color(0xFF2E7D32);
//   static const Color primaryLight = Color(0xFF60AD5E);
//   static const Color primaryDark = Color(0xFF005005);
  
//   static const Color secondary = Color(0xFF4CAF50);
//   static const Color secondaryLight = Color(0xFF80E27E);
//   static const Color secondaryDark = Color(0xFF087F23);
  
//   static const Color accent = Color(0xFFFF9800);
//   static const Color accentLight = Color(0xFFFFCC02);
//   static const Color accentDark = Color(0xFFE65100);
  
//   static const Color background = Color(0xFFFAFAFA);
//   static const Color surface = Colors.white;
//   static const Color surfaceLight = Color(0xFFF5F5F5);
  
//   static const Color textPrimary = Color(0xFF212121);
//   static const Color textSecondary = Color(0xFF757575);
//   static const Color textLight = Color(0xFFBDBDBD);
  
//   static const Color border = Color(0xFFE0E0E0);
//   static const Color borderLight = Color(0xFFEEEEEE);
  
//   static const Color success = Color(0xFF4CAF50);
//   static const Color warning = Color(0xFFFF9800);
//   static const Color error = Color(0xFFF44336);
//   static const Color info = Color(0xFF2196F3);
  
//   // Gradient colors
//   static const LinearGradient primaryGradient = LinearGradient(
//     colors: [primary, primaryLight],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );
  
//   static const LinearGradient backgroundGradient = LinearGradient(
//     colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
//     begin: Alignment.topCenter,
//     end: Alignment.bottomCenter,
//   );
// }