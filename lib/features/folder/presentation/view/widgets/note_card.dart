import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tionova/features/folder/data/models/NoteModel.dart';

class NoteCard extends StatelessWidget {
  final Notemodel note;
  final Color accentColor;
  final VoidCallback onTap;

  const NoteCard({
    super.key,
    required this.note,
    required this.accentColor,
    required this.onTap,
  });

  String _formatDate(DateTime date) {
    return DateFormat('M/d/yyyy, h:mm a').format(date);
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
    final duration = meta?['duration'] ?? 'Unknown';
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_outline, color: Colors.orange, size: 32),
            const SizedBox(height: 8),
            Text(
              'Voice note • $duration',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
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

  List<Widget> _buildTags() {
    final type = note.rawData['type'] as String? ?? 'text';
    final meta = note.rawData['meta'] as Map<String, dynamic>?;
    final tags = <String>[];

    // Add type
    tags.add(type);

    // Add additional meta tags
    if (meta != null) {
      if (meta['size'] != null) {
        final sizeInKB = (meta['size'] as num) / 1024;
        tags.add('${sizeInKB.toStringAsFixed(1)} KB');
      }
      if (meta['duration'] != null) {
        tags.add(meta['duration'].toString());
      }
    }

    return tags
        .map(
          (tag) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getColorForType(type).withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _getColorForType(type).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              tag,
              style: TextStyle(
                color: _getColorForType(type),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final type = note.rawData['type'] as String? ?? 'text';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0E0E10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getColorForType(type).withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getColorForType(type).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getIconForType(type),
                      color: _getColorForType(type),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
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
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(note.createdAt),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[600],
                    size: 16,
                  ),
                ],
              ),
            ),

            // Preview Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildPreview(),
            ),

            // Tags
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(spacing: 8, runSpacing: 8, children: _buildTags()),
            ),
          ],
        ),
      ),
    );
  }
}
