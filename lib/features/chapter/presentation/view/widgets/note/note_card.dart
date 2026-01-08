import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/chapter/data/models/NoteModel.dart';

class NoteCard extends StatelessWidget {
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
    // Don't show if no folder owner ID (shouldn't happen, but be safe)
    if (folderOwnerId == null) return false;

    // Don't show if no creator info
    if (note.creatorEmail == null && note.creatorName == null) return false;

    // Get current user ID from AuthCubit
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthSuccess) return false;

    final currentUserId = authState.user.id;

    // Show creator if current user is NOT the folder owner
    return currentUserId != folderOwnerId;
  }

  String _getCreatorDisplay() {
    // Prefer creator name, fall back to email username
    if (note.creatorName != null && note.creatorName!.isNotEmpty) {
      return note.creatorName!;
    }
    if (note.creatorEmail != null && note.creatorEmail!.isNotEmpty) {
      // Extract username from email (part before @)
      return note.creatorEmail!.split('@').first;
    }
    return 'Unknown';
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'text':
        return Icons.text_fields;
      case 'image':
        return Icons.image;
      case 'voice':
        return Icons.mic;
      default:
        return Icons.note;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'text':
        return Colors.blue;
      case 'image':
        return Colors.purple;
      case 'voice':
        return Colors.orange;
      default:
        return accentColor;
    }
  }

  Widget _buildPreview() {
    final type = note.rawData['type'] as String? ?? 'text';
    final data = note.rawData['data'] as String? ?? '';

    switch (type) {
      case 'image':
        return _buildImagePreview(data);
      case 'voice':
        return _buildVoicePreview();
      case 'text':
      default:
        return _buildTextPreview(data);
    }
  }

  Widget _buildImagePreview(String imageData) {
    try {
      if (imageData.isEmpty) {
        return _buildErrorPreview('No image data');
      }

      // Check if it's a URL (Cloudinary) or base64 data
      if (imageData.startsWith('http://') || imageData.startsWith('https://')) {
        // It's a Cloudinary URL, use Image.network
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageData,
            width: double.infinity,
            height: 120,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 120,
                color: const Color(0xFF1C1C1E),
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    color: Colors.purple,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorPreview('Failed to load image');
            },
          ),
        );
      } else {
        // It's base64 data, decode it
        final cleanBase64 = imageData.contains(',')
            ? imageData.split(',').last
            : imageData;
        final Uint8List bytes = base64Decode(cleanBase64);
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            bytes,
            width: double.infinity,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorPreview('Invalid image');
            },
          ),
        );
      }
    } catch (e) {
      return _buildErrorPreview('Error: $e');
    }
  }

  Widget _buildVoicePreview() {
    final meta = note.rawData['meta'] as Map<String, dynamic>?;
    final duration = meta?['duration'] ?? '0:00';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withOpacity(0.1),
            Colors.orange.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow, color: Colors.orange, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Voice Recording',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  duration,
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextPreview(String text) {
    return Text(
      text,
      style: TextStyle(color: Colors.grey[300], fontSize: 14, height: 1.5),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildErrorPreview(String message) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: Colors.grey[500], fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildTypeBadge() {
    final type = note.rawData['type'] as String? ?? 'text';
    final typeLabel = type[0].toUpperCase() + type.substring(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _getColorForType(type).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getColorForType(type).withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIconForType(type), color: _getColorForType(type), size: 14),
          const SizedBox(width: 6),
          Text(
            typeLabel,
            style: TextStyle(
              color: _getColorForType(type),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final type = note.rawData['type'] as String? ?? 'text';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[850]!, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon, title, and date
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getColorForType(type),
                          _getColorForType(type).withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconForType(type),
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.grey[600],
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(note.createdAt),
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                            // Show creator info if this is not the owner's folder and creator info exists
                            if (_shouldShowCreator(context)) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: accentColor.withOpacity(0.3),
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.person_outline,
                                      size: 10,
                                      color: accentColor,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      _getCreatorDisplay(),
                                      style: TextStyle(
                                        color: accentColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildTypeBadge(),
                ],
              ),
            ),

            // Preview Content (only for text and image, voice has its own design)
            if (type != 'voice')
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _buildPreview(),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _buildVoicePreview(),
              ),
          ],
        ),
      ),
    );
  }
}
