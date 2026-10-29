import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Rounded dark search field from the Home header.
class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.controller, this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: AppColors.text),
        cursorColor: AppColors.muted,
        decoration: const InputDecoration(
          hintText: 'Search nature, abstract…',
          hintStyle: TextStyle(color: AppColors.faint),
          prefixIcon: Icon(Icons.search, size: 18, color: AppColors.faint),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
