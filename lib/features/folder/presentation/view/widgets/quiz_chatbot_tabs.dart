import 'package:flutter/material.dart';
import 'package:tionova/features/folder/presentation/view/widgets/BuildTap.dart';

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
            child: BuildTab(
              label: 'Quiz',
              icon: Icons.quiz_outlined,
              isActive: widget.activeTab == "quiz",
              onTap: () =>
                  widget.onTabChanged(widget.activeTab == "quiz" ? "" : "quiz"),
            ),
          ),
          Expanded(
            child: BuildTab(
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
}
