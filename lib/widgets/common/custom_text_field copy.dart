
// // lib/widgets/custom_text_field.dart
// import 'package:flutter/material.dart';
// import '../../utils/colors.dart';

// class CustomTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String label;
//   final String? hint;
//   final TextInputType? keyboardType;
//   final bool obscureText;
//   final String? Function(String?)? validator;
//   final IconData? prefixIcon;
//   final Widget? suffixIcon;
//   final int maxLines;
//   final bool enabled;

//   const CustomTextField({
//     super.key,
//     required this.controller,
//     required this.label,
//     this.hint,
//     this.keyboardType,
//     this.obscureText = false,
//     this.validator,
//     this.prefixIcon,
//     this.suffixIcon,
//     this.maxLines = 1,
//     this.enabled = true,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         SizedBox(height: 8),
//         TextFormField(
//           controller: controller,
//           keyboardType: keyboardType,
//           obscureText: obscureText,
//           validator: validator,
//           maxLines: maxLines,
//           enabled: enabled,
//           style: TextStyle(
//             fontSize: 16,
//             color: AppColors.textPrimary,
//           ),
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: TextStyle(
//               color: AppColors.textSecondary,
//               fontSize: 14,
//             ),
//             prefixIcon: prefixIcon != null 
//                 ? Icon(prefixIcon, color: AppColors.primary, size: 22)
//                 : null,
//             suffixIcon: suffixIcon,
//             filled: true,
//             fillColor: enabled ? Colors.white : Colors.grey[100],
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: AppColors.border),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: AppColors.border),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: AppColors.primary, width: 2),
//             ),
//             errorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: AppColors.error),
//             ),
//             focusedErrorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: AppColors.error, width: 2),
//             ),
//             contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//           ),
//         ),
//       ],
//     );
//   }
// }
