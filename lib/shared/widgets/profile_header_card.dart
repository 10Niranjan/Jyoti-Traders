import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// Gradient identity card up top — avatar, title, and a couple of subtitle
/// lines at a glance, with a single edit affordance instead of every field
/// being separately editable inline. Shared by the retailer and admin
/// profile screens so both get the same tap-to-change-photo affordance.
class ProfileHeaderCard extends StatelessWidget {
  final String title;
  final List<String> subtitleLines;
  final String? photoUrl;
  final bool isUploadingPhoto;
  final VoidCallback onEdit;
  final VoidCallback onTapPhoto;

  const ProfileHeaderCard({
    super.key,
    required this.title,
    required this.subtitleLines,
    required this.photoUrl,
    required this.isUploadingPhoto,
    required this.onEdit,
    required this.onTapPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 12, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: isUploadingPhoto ? null : onTapPhoto,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withOpacity(0.16),
                  child: ClipOval(
                    child: isUploadingPhoto
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : _buildAvatarContent(),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, size: 12, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                for (final line in subtitleLines) ...[
                  const SizedBox(height: 3),
                  Text(
                    line,
                    style: GoogleFonts.inter(color: Colors.white.withOpacity(0.85), fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            tooltip: 'Edit profile',
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarContent() {
    if (photoUrl == null || photoUrl!.isEmpty) {
      return Text(
        title.isNotEmpty ? title[0].toUpperCase() : 'U',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
      );
    }
    return SizedBox(
      width: 56,
      height: 56,
      child: photoUrl!.startsWith('http')
          ? CachedNetworkImage(imageUrl: photoUrl!, fit: BoxFit.cover)
          : Image.file(File(photoUrl!), fit: BoxFit.cover),
    );
  }
}
