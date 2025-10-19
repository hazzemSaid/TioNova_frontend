import 'package:flutter/material.dart';

class QuizChatbotTabs extends StatefulWidget {
  final String activeTab;
  final Function(String) onTabChanged;
  const QuizChatbotTabs({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  State<QuizChatbotTabs> createState() => _QuizChatbotTabsState();
}

class _QuizChatbotTabsState extends State<QuizChatbotTabs> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF2C2C2E), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              label: 'Quiz',
              icon: Icons.quiz_outlined,
              isActive: widget.activeTab == "quiz",
              onTap: () =>
                  widget.onTabChanged(widget.activeTab == "quiz" ? "" : "quiz"),
            ),
          ),
          Expanded(
            child: _buildTab(
              label: 'Chatbot',
              icon: Icons.chat_bubble_outline,
              isActive: widget.activeTab == "chatbot",
              onTap: () => widget.onTabChanged(
                widget.activeTab == "chatbot" ? "" : "chatbot",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2C2C2E) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: isActive ? 1.1 : 1.0,
              child: Icon(
                icon,
                color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
                fontSize: 15,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.2,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
