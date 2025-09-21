import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class CreateFolderButton extends StatelessWidget {
  const CreateFolderButton({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Center(
      child: GestureDetector(
        onTap: () {
          // Use a logging framework in production
        },
        child: DottedBorder(
          options: CustomPathDottedBorderOptions(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: const Color(0xFF1C1C1E),
            strokeWidth: 1.5,
            dashPattern: const [6, 3],
            customPath: (size) => Path()
              ..addRRect(
                RRect.fromRectAndRadius(
                  Rect.fromLTWH(0, 0, size.width, size.height),
                  const Radius.circular(30),
                ),
              ),
          ),
          child: Container(
            width: screenWidth * 0.9,
            height: screenHeight * 0.02,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screenWidth * 0.04),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.white, size: screenWidth * 0.05),
                SizedBox(width: screenWidth * 0.03),
                Text(
                  'Create New Study Folder',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
