import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;

  const SearchBar({Key? key, this.hintText = '', this.onChanged})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF8E8E93), fontSize: 16),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF8E8E93),
            size: 20,
          ),
          filled: false,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
