import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/chapter/data/models/NoteModel.dart';

class NoteCard extends StatefulWidget {
  final Notemodel note;
  final Color accentColor;
  final VoidCallback onTap;
  final String? folderOwnerId;

  const NoteCard({
    super.key,
    required this.note,
    required this.accentColor,
    required this.onTap,
    this.folderOwnerId,
  });

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  bool _isHovered = false;

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('h:mm a').format(date);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  bool _shouldShowCreator(BuildContext context) {
    if (widget.folderOwnerId == null) return false;
    if (widget.note.creatorEmail == null && widget.note.creatorName == null)
      return false;

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthSuccess) return false;

    final currentUserId = authState.user.id;
    return currentUserId != widget.folderOwnerId;
  }

  String _getCreatorDisplay() {
    if (widget.note.creatorName != null &&
        widget.note.creatorName!.isNotEmpty) {
      return widget.note.creatorName!;
    }
    if (widget.note.creatorEmail != null &&
        widget.note.creatorEmail!.isNotEmpty) {
      return widget.note.creatorEmail!.split('@').first;
    }
    return 'Unknown';
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'text':
        return Icons.text_fields_rounded;
      case 'image':
        return Icons.image_rounded;
      case 'voice':
        return Icons.mic_rounded;
      default:
        return Icons.note_rounded;
    }
  }

  Color _getColorForType(String type, ColorScheme colorScheme) {
    switch (type) {
      case 'text':
        return Colors.blue;
      case 'image':
        return Colors.purple;
      case 'voice':
        return Colors.orange;
      default:
        return widget.accentColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final type = widget.note.rawData['type'] as String? ?? 'text';
    final typeColor = _getColorForType(type, colorScheme);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: _isHovered
                ? colorScheme.surfaceContainerHigh
                : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered
                  ? typeColor.withOpacity(0.5)
                  : colorScheme.outline.withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: typeColor.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(colorScheme, type, typeColor),
              _buildContent(colorScheme, type, typeColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, String type, Color typeColor) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [typeColor.withOpacity(0.8), typeColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: typeColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(_getIconForType(type), color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.note.title,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      color: colorScheme.onSurfaceVariant,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(widget.note.createdAt),
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                    if (_shouldShowCreator(context)) ...[
                      const SizedBox(width: 12),
                      _buildCreatorBadge(colorScheme),
                    ],
                  ],
                ),
              ],
            ),
          ),
          _buildTypeBadge(type, typeColor),
        ],
      ),
    );
  }

  Widget _buildCreatorBadge(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: widget.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: widget.accentColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_rounded, size: 12, color: widget.accentColor),
          const SizedBox(width: 4),
          Text(
            _getCreatorDisplay(),
            style: TextStyle(
              color: widget.accentColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(String type, Color typeColor) {
    final label = type[0].toUpperCase() + type.substring(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: typeColor.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: typeColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildContent(ColorScheme colorScheme, String type, Color typeColor) {
    final data = widget.note.rawData['data'] as String? ?? '';
    if (type == 'voice') return _buildVoicePreview(colorScheme);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: type == 'image'
          ? _buildImagePreview(data, colorScheme)
          : _buildTextPreview(data, colorScheme),
    );
  }

  Widget _buildImagePreview(String imageData, ColorScheme colorScheme) {
    try {
      if (imageData.isEmpty) return _buildErrorPreview('No image', colorScheme);

      Widget image;
      if (imageData.startsWith('http')) {
        image = Image.network(
          imageData,
          width: double.infinity,
          height: 160,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 160,
              color: colorScheme.surfaceContainerHighest,
              child: const Center(child: CircularProgressIndicator()),
            );
          },
        );
      } else {
        final bytes = base64Decode(
          imageData.contains(',') ? imageData.split(',').last : imageData,
        );
        image = Image.memory(
          bytes,
          width: double.infinity,
          height: 160,
          fit: BoxFit.cover,
        );
      }

      return ClipRRect(borderRadius: BorderRadius.circular(12), child: image);
    } catch (e) {
      return _buildErrorPreview('Invalid image', colorScheme);
    }
  }

  Widget _buildVoicePreview(ColorScheme colorScheme) {
    final meta = widget.note.rawData['meta'] as Map<String, dynamic>?;
    final duration = meta?['duration'] ?? '0:00';
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.orange,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Voice Recording',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  duration,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.waves_rounded, color: Colors.orange, size: 24),
        ],
      ),
    );
  }

  Widget _buildTextPreview(String text, ColorScheme colorScheme) {
    return Text(
      text,
      style: TextStyle(
        color: colorScheme.onSurfaceVariant,
        fontSize: 15,
        height: 1.6,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildErrorPreview(String message, ColorScheme colorScheme) {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: colorScheme.error, fontSize: 13),
        ),
      ),
    );
  }
}
