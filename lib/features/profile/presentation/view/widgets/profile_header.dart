import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final VoidCallback? onThemeToggle;

  const ProfileHeader({Key? key, this.onThemeToggle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your study journey',
                style: TextStyle(color: const Color(0xFF8E8E93), fontSize: 14),
              ),
            ],
          ),
          GestureDetector(
            onTap: onThemeToggle,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.light_mode_outlined,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
