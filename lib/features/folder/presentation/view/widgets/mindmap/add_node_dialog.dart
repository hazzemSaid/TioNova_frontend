import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/features/folder/presentation/bloc/mindmap/mindmap_cubit.dart';

class AddNodeDialog extends StatefulWidget {
  final String? parentNodeId;
  final String? chapterId;
  final Function(String title, String content, String color, String icon) onAdd;

  const AddNodeDialog({
    super.key,
    this.parentNodeId,
    this.chapterId,
    required this.onAdd,
  });

  @override
  State<AddNodeDialog> createState() => _AddNodeDialogState();
}

class _AddNodeDialogState extends State<AddNodeDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedColor = '#4A90E2';
  String _selectedIcon = '💡';
  bool _isGenerating = false;

  final List<String> _availableColors = [
    '#4A90E2', // Blue
    '#8B5CF6', // Purple
    '#F59E0B', // Orange
    '#50C878', // Green
    '#EF4444', // Red
    '#EC4899', // Pink
  ];

  final List<String> _availableIcons = [
    '💡',
    '📚',
    '🎯',
    '📊',
    '⚡',
    '⭐',
    '🧠',
    '🔥',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _generateWithAI() {
    print('🔵 [AddNodeDialog] _generateWithAI() called');
    final query = _contentController.text.trim();
    print('📝 Query: "$query" (length: ${query.length})');
    print('🆔 ChapterId: ${widget.chapterId}');

    if (query.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter at least 10 characters for AI generation',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (widget.chapterId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chapter ID is required for AI generation'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('🚀 [AddNodeDialog] Calling cubit.generateSmartNodeContent()');
    context.read<MindmapCubit>().generateSmartNodeContent(
      text: query,
      chapterId: widget.chapterId!,
    );
    print('✅ [AddNodeDialog] Cubit method called');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MindmapCubit, MindmapState>(
      listener: (context, state) {
        // Handle MindmapLoaded state with AI generation flags
        if (state is MindmapLoaded) {
          // Check AI generation status
          if (state.isGeneratingAI && !_isGenerating) {
            setState(() {
              _isGenerating = true;
            });
          } else if (!state.isGeneratingAI && _isGenerating) {
            setState(() {
              _isGenerating = false;
            });
          }

          // Handle generated content
          if (state.generatedContent != null &&
              state.generatedContent!.isNotEmpty) {
            setState(() {
              _contentController.text = state.generatedContent!;
              // Auto-fill title from query if empty
              if (_titleController.text.isEmpty &&
                  state.generatedUserInput != null) {
                _titleController.text = _extractTitle(
                  state.generatedUserInput!,
                );
              }
            });
            // Clear the generated content after using it
            context.read<MindmapCubit>().clearGeneratedContent();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('AI content generated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }

          // Handle AI error
          if (state.aiError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.aiError}'),
                backgroundColor: Colors.red,
              ),
            );
            context.read<MindmapCubit>().clearErrors();
          }
        }
        // Fallback for legacy states
        else if (state is GeneratingSmartNode) {
          setState(() {
            _isGenerating = true;
          });
        } else if (state is SmartNodeGenerated) {
          setState(() {
            _isGenerating = false;
            _contentController.text = state.generatedContent;
            if (_titleController.text.isEmpty) {
              _titleController.text = _extractTitle(state.userInput);
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('AI content generated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is SmartNodeError) {
          setState(() {
            _isGenerating = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            final isSmallScreen = screenWidth < 600;

            return Container(
              width: isSmallScreen
                  ? screenWidth * 0.9
                  : math.min(550, screenWidth * 0.9),
              constraints: BoxConstraints(
                maxHeight: math.min(700, screenHeight * 0.85),
              ),
              padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F3A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2D3250)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        const Text(
                          'Create New Node',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add a new sub-node with your own content or use AI to enhance it',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title field
                    const Text(
                      'Title',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'e.g., Balanced Trees, Tree Traversal...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0A0E27),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF2D3250),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF2D3250),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF4A90E2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Content field with AI button
                    Row(
                      children: [
                        const Text(
                          'Content',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        // AI Generate Button
                        if (widget.chapterId != null)
                          TextButton.icon(
                            onPressed: _isGenerating ? null : _generateWithAI,
                            icon: _isGenerating
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF8B5CF6),
                                    ),
                                  )
                                : const Icon(
                                    Icons.auto_awesome,
                                    size: 16,
                                    color: Color(0xFF8B5CF6),
                                  ),
                            label: Text(
                              _isGenerating
                                  ? 'Generating...'
                                  : 'Generate with AI',
                              style: TextStyle(
                                color: _isGenerating
                                    ? Colors.white.withOpacity(0.5)
                                    : const Color(0xFF8B5CF6),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              backgroundColor: const Color(
                                0xFF8B5CF6,
                              ).withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _contentController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 6,
                      enabled: !_isGenerating,
                      decoration: InputDecoration(
                        hintText: _isGenerating
                            ? 'AI is generating content...'
                            : 'Type your content here, then click "Generate with AI" to enhance it...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                        ),
                        filled: true,
                        fillColor: _isGenerating
                            ? const Color(0xFF0A0E27).withOpacity(0.5)
                            : const Color(0xFF0A0E27),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF2D3250),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF2D3250),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF4A90E2),
                          ),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF2D3250),
                          ),
                        ),
                      ),
                    ),
                    if (widget.chapterId != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Min. 10 characters required for AI generation',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 11,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Color picker
                    const Text(
                      'Color',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _availableColors.map((color) {
                          final isSelected = color == _selectedColor;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColor = color;
                              });
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: _parseColor(color),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Icon picker
                    const Text(
                      'Icon',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableIcons.map((icon) {
                        final isSelected = icon == _selectedIcon;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIcon = icon;
                            });
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF2D3250)
                                  : const Color(0xFF0A0E27),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF4A90E2)
                                    : const Color(0xFF2D3250),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                icon,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _isGenerating
                              ? null
                              : () {
                                  if (_titleController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please enter a title'),
                                      ),
                                    );
                                    return;
                                  }
                                  widget.onAdd(
                                    _titleController.text,
                                    _contentController.text,
                                    _selectedColor,
                                    _selectedIcon,
                                  );
                                  Navigator.pop(context);
                                },
                          icon: const Icon(Icons.add),
                          label: const Text('Create Node'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A90E2),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(
                              0xFF4A90E2,
                            ).withOpacity(0.5),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _extractTitle(String query) {
    // Extract first few words as title, max 30 chars
    final words = query.split(' ');
    String title = '';
    for (final word in words) {
      if ((title + word).length > 30) break;
      title += (title.isEmpty ? '' : ' ') + word;
    }
    return title.isNotEmpty ? title : 'New Node';
  }

  Color _parseColor(String colorString) {
    final hexString = colorString.replaceAll('#', '');
    return Color(int.parse('FF$hexString', radix: 16));
  }
}
