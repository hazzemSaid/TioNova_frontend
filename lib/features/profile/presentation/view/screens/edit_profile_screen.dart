import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tionova/features/profile/data/models/profile_model.dart';
import 'package:tionova/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:tionova/features/profile/presentation/cubit/profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  final Profile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _universityController;
  late FocusNode _usernameFocus;
  late FocusNode _universityFocus;

  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.profile.username);
    _universityController = TextEditingController(
      text: widget.profile.universityCollege ?? '',
    );
    _usernameFocus = FocusNode();
    _universityFocus = FocusNode();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _universityController.dispose();
    _usernameFocus.dispose();
    _universityFocus.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 2048,
        maxHeight: 2048,
      );

      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          final cropped = await _cropCenterSquareAndResize(
            bytes,
            targetSize: 512,
          );
          setState(() {
            _selectedImageBytes = cropped;
            _selectedImageName = image.name;
            _selectedImage = null;
          });
        } else {
          final file = File(image.path);
          final int fileSizeInBytes = await file.length();
          final double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
          if (fileSizeInMB > 5) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image must be less than 5MB'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          setState(() {
            _selectedImage = file;
            _selectedImageBytes = null;
            _selectedImageName = null;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<Uint8List> _cropCenterSquareAndResize(
    Uint8List bytes, {
    int targetSize = 512,
  }) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final w = image.width.toDouble();
    final h = image.height.toDouble();
    final size = w < h ? w : h;
    final left = (w - size) / 2;
    final top = (h - size) / 2;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final src = Rect.fromLTWH(left, top, size, size);
    final dst = Rect.fromLTWH(
      0,
      0,
      targetSize.toDouble(),
      targetSize.toDouble(),
    );
    canvas.drawImageRect(image, src, dst, Paint());
    final picture = recorder.endRecording();
    final cropped = await picture.toImage(targetSize, targetSize);
    final byteData = await cropped.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _updateProfile() async {
    if (_usernameController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username cannot be empty'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      // Prepare the update data
      final Map<String, dynamic> updateData = {
        'username': _usernameController.text,
        'universityCollege': _universityController.text,
      };

      // Call the cubit method to update profile
      if (!mounted) return;
      if (kIsWeb) {
        if (_selectedImageBytes != null) {
          updateData['profilePictureBytes'] = _selectedImageBytes!;
          updateData['profilePictureName'] =
              _selectedImageName ?? 'profile.png';
        }
        await context.read<ProfileCubit>().updateProfile(updateData);
      } else {
        await context.read<ProfileCubit>().updateProfile(
          updateData,
          imageFile: _selectedImage,
        );
      }

      if (!mounted) return;

      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Delay slightly to allow snackbar to show before navigation
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Edit Profile',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          // Only listen for errors now
          // Success is handled in _updateProfile() method
          if (state is ProfileError) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Profile Collage Section with Picture, Name, and Bio
                _buildProfileCollageSection(theme, isDark),
                const SizedBox(height: 32),

                // Form Fields Section (for editing university, etc.)
                _buildFormSection(theme),
                const SizedBox(height: 32),

                // Update Button
                _buildUpdateButton(theme),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCollageSection(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Personal Information
          Text(
            'Personal Information',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 20),

          // Profile Picture Section with Decorative Elements
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Decorative background elements
                Positioned(
                  top: -10,
                  left: -10,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary.withOpacity(0.15),
                    ),
                  ),
                ),
                Positioned(
                  top: 5,
                  right: -5,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.secondary.withOpacity(0.15),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -15,
                  right: -20,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary.withOpacity(0.1),
                    ),
                  ),
                ),

                // Main profile picture with circular border gradient
                Column(
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.4),
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _selectedImageBytes != null
                            ? Image.memory(
                                _selectedImageBytes!,
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.high,
                              )
                            : _selectedImage != null
                            ? Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.high,
                              )
                            : widget.profile.profilePicture != null
                            ? Image.network(
                                widget.profile.profilePicture!,
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.high,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.1),
                                      child: Icon(
                                        Icons.person,
                                        size: 70,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                              )
                            : Container(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.1,
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 70,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Camera Icon Badge
                    GestureDetector(
                      onTap: _isUpdating ? null : _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: isDark ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Camera instruction
          Center(
            child: Text(
              'Click the camera icon to change your profile picture',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),

          // Divider
          Divider(
            color: theme.colorScheme.outline.withOpacity(0.15),
            height: 24,
          ),

          // Full Name Field (non-editable with label)
          _buildTextFieldLabel(theme, 'Full Name'),
          const SizedBox(height: 8),
          TextField(
            controller: _usernameController,
            focusNode: _usernameFocus,
            enabled: !_isUpdating,
            decoration: InputDecoration(
              hintText: 'Enter your full name',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              prefixIcon: Icon(
                Icons.person_outline,
                color: theme.colorScheme.primary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),

          // Email Address (non-editable)
          _buildTextFieldLabel(theme, 'Email Address'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surface.withOpacity(0.5),
            ),
            child: Row(
              children: [
                Icon(Icons.email_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.profile.email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Email cannot be changed. Contact support if needed.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // University/College Field
          _buildTextFieldLabel(theme, 'University/College'),
          const SizedBox(height: 8),
          TextField(
            controller: _universityController,
            focusNode: _universityFocus,
            enabled: !_isUpdating,
            decoration: InputDecoration(
              hintText: 'Enter your university or college',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              prefixIcon: Icon(
                Icons.school_outlined,
                color: theme.colorScheme.primary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.1),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldLabel(ThemeData theme, String label) {
    return Text(
      label,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  Widget _buildUpdateButton(ThemeData theme) {
    final bool hasChanges =
        _usernameController.text != widget.profile.username ||
        _universityController.text !=
            (widget.profile.universityCollege ?? '') ||
        _selectedImage != null ||
        _selectedImageBytes != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (_isUpdating || !hasChanges) ? null : _updateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: theme.colorScheme.primary.withOpacity(0.5),
          disabledForegroundColor: Colors.white.withOpacity(0.7),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isUpdating
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary,
                  ),
                ),
              )
            : Text(
                'Update Profile',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}
