import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/features/folder/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/folder/presentation/screens/mindmap_screen.dart';

/// Example: How to integrate Mindmap viewer into your Chapter Detail Screen
///
/// This example shows you how to:
/// 1. Add a "Generate Mindmap" button
/// 2. Listen for mindmap generation success
/// 3. Navigate to the mindmap viewer

class ChapterDetailScreenExample extends StatelessWidget {
  final String chapterId;
  final String token;

  const ChapterDetailScreenExample({
    Key? key,
    required this.chapterId,
    required this.token,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chapter Details')),
      body: BlocListener<ChapterCubit, ChapterState>(
        // Listen for mindmap creation success
        listener: (context, state) {
          if (state is CreateMindmapLoading) {
            // Show loading dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const Center(child: CircularProgressIndicator()),
            );
          } else if (state is CreateMindmapSuccess) {
            // Close loading dialog
            Navigator.of(context).pop();

            // Navigate to mindmap viewer
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MindmapScreen(mindmap: state.mindmap),
              ),
            );
          } else if (state is CreateMindmapError) {
            // Close loading dialog
            Navigator.of(context).pop();

            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message.errMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Column(
          children: [
            // Your existing chapter content here
            const Expanded(
              child: Center(child: Text('Chapter Content Goes Here')),
            ),

            // Generate Mindmap Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Trigger mindmap generation
                  context.read<ChapterCubit>().createMindmap(
                    token: token,
                    chapterId: chapterId,
                  );
                },
                icon: const Icon(Icons.hub),
                label: const Text('Generate Mind Map'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Alternative: Add mindmap button to existing widget
class MindmapButton extends StatelessWidget {
  final String chapterId;
  final String token;

  const MindmapButton({Key? key, required this.chapterId, required this.token})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChapterCubit, ChapterState>(
      listener: (context, state) {
        if (state is CreateMindmapSuccess) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MindmapScreen(mindmap: state.mindmap),
            ),
          );
        } else if (state is CreateMindmapError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message.errMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is CreateMindmapLoading;

        return ElevatedButton.icon(
          onPressed: isLoading
              ? null
              : () {
                  context.read<ChapterCubit>().createMindmap(
                    token: token,
                    chapterId: chapterId,
                  );
                },
          icon: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.hub),
          label: Text(isLoading ? 'Generating...' : 'View Mind Map'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A90E2),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        );
      },
    );
  }
}

/// Example: Floating Action Button for Mindmap
class MindmapFAB extends StatelessWidget {
  final String chapterId;
  final String token;

  const MindmapFAB({Key? key, required this.chapterId, required this.token})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChapterCubit, ChapterState>(
      listener: (context, state) {
        if (state is CreateMindmapSuccess) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MindmapScreen(mindmap: state.mindmap),
            ),
          );
        }
      },
      child: FloatingActionButton.extended(
        onPressed: () {
          context.read<ChapterCubit>().createMindmap(
            token: token,
            chapterId: chapterId,
          );
        },
        icon: const Icon(Icons.hub),
        label: const Text('Mind Map'),
        backgroundColor: const Color(0xFF4A90E2),
      ),
    );
  }
}
