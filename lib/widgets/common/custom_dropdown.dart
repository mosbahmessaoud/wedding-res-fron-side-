
// lib/widgets/custom_dropdown.dart
import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final IconData? prefixIcon;
  final bool enabled;
  final String? Function(T?)? validator;

  const CustomDropdown({
    super.key,
    this.value,
    required this.hint,
    required this.items,
    this.onChanged,
    this.prefixIcon,
    this.enabled = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        color: enabled ? Colors.white : Colors.grey[100],
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        hint: Row(
          children: [
            if (prefixIcon != null) ...[
              Icon(prefixIcon, color: AppColors.primary, size: 22),
              SizedBox(width: 12),
            ],
            Text(
              hint,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
        items: items,
        onChanged: enabled ? onChanged : null,
        validator: validator,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          prefixIcon: prefixIcon != null 
              ? Icon(prefixIcon, color: AppColors.primary, size: 22)
              : null,
        ),
        dropdownColor: Colors.white,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
