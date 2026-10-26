import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../blocs/profile/profile_cubit.dart';
import '../blocs/profile/profile_state.dart';
import '../models/civic_models.dart';
import '../theme/civic_colors.dart';
import '../widgets/civic_app_logo.dart';

// ==========================================
// SCREEN: PROFILE SCREEN (MVVM ARCHITECTURE)
// Backed by ProfileCubit and ProfileState
// ==========================================

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onSignOut;
  final VoidCallback? onManagePermissions;

  const ProfileScreen({
    super.key,
    this.onSignOut,
    this.onManagePermissions,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  VoidCallback? get onSignOut => widget.onSignOut;
  VoidCallback? get onManagePermissions => widget.onManagePermissions;

  Future<void> _pickProfilePhoto(BuildContext context, ImageSource source) async {
    try {
      final photo = await pickCivicPhoto(context: context, source: source);
      if (photo != null && context.mounted) {
        context.read<ProfileCubit>().updatePhoto(photo.photoUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Profile photo updated from ${source == ImageSource.camera ? "camera" : "gallery"}!'),
            backgroundColor: CivicColors.primary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not set profile photo: $e'), backgroundColor: CivicColors.error),
        );
      }
    }
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: CivicColors.primary,
      alignment: Alignment.center,
      child: const Icon(Icons.person, color: Colors.white, size: 52),
    );
  }

  void _showPhotoOptions(BuildContext context, ProfileState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Change Profile Picture',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CivicColors.onSurface),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: CivicColors.primary,
                      child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                    ),
                    title: const Text('Take Photo from Camera', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    subtitle: const Text('Capture a live citizen profile picture', style: TextStyle(fontSize: 11.5)),
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickProfilePhoto(context, ImageSource.camera);
                    },
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: CivicColors.secondary,
                      child: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 20),
                    ),
                    title: const Text('Choose Photo from Gallery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    subtitle: const Text('Select existing photo from phone gallery', style: TextStyle(fontSize: 11.5)),
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickProfilePhoto(context, ImageSource.gallery);
                    },
                  ),
                  if (state.photoPath != null)
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: CivicColors.errorContainer,
                        child: Icon(Icons.delete_outline_rounded, color: CivicColors.error, size: 20),
                      ),
                      title: const Text('Remove Photo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: CivicColors.error)),
                      subtitle: const Text('Revert to default municipal avatar', style: TextStyle(fontSize: 11.5)),
                      onTap: () {
                        Navigator.pop(ctx);
                        context.read<ProfileCubit>().removePhoto();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile photo reset.')),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context, ProfileState state) {
    final nameCtrl = TextEditingController(text: state.name);
    final phoneCtrl = TextEditingController(text: state.phone);
    final areaCtrl = TextEditingController(text: state.address);
    final emailCtrl = TextEditingController(text: state.email);
    String selectedWard = state.ward;

    final wards = [
      'Ward 4 (Navrangpura/Central District, AMC)',
      'Ward 8 (Vastrapur/West District, AMC)',
      'Ward 12 (Bodakdev/North-West, AMC)',
      'Ward 15 (Paldi/South-West, AMC)',
      'Ward 21 (Maninagar/South, AMC)',
      'Ward 32 (Sabarmati/North-West, AMC)',
      'Ward 42 (Ellisbridge/Central, AMC)',
    ];

    if (!wards.contains(selectedWard)) {
      wards.insert(0, selectedWard);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final bottomInset = MediaQuery.of(modalCtx).viewInsets.bottom;
            return Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Edit Citizen Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CivicColors.onSurface)),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Name
                    const Text('Citizen Full Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: CivicColors.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: CivicColors.surfaceLow,
                        prefixIcon: const Icon(Icons.person_outline, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Phone / WhatsApp
                    const Text('Mobile / WhatsApp Number (SLA Dispatch)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: CivicColors.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: CivicColors.surfaceLow,
                        prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Ward selector
                    const Text('Registered Municipal Ward', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: CivicColors.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: selectedWard,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: CivicColors.surfaceLow,
                        prefixIcon: const Icon(Icons.location_city_rounded, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      items: wards.map((w) {
                        return DropdownMenuItem(
                          value: w,
                          child: Text(w, style: const TextStyle(fontSize: 12.5), overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedWard = val);
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // Registered Area
                    const Text('Street / Locality', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: CivicColors.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: areaCtrl,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: CivicColors.surfaceLow,
                        prefixIcon: const Icon(Icons.home_work_outlined, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.read<ProfileCubit>().updateProfile(
                            name: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : null,
                            phone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : null,
                            ward: selectedWard,
                            address: areaCtrl.text.trim().isNotEmpty ? areaCtrl.text.trim() : null,
                            email: emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : null,
                          );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✓ Profile updated successfully!'),
                              backgroundColor: CivicColors.primary,
                            ),
                          );
                        },
                        icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                        label: const Text('Save Profile Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CivicColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Profile Avatar with Clickable Camera / Gallery Badge (Overflow-Proof & Downsampled)
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: CivicColors.primary, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: CivicColors.primary.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: SizedBox(
                          width: 90,
                          height: 90,
                          child: state.photoPath != null && state.photoPath!.isNotEmpty
                              ? (!kIsWeb && File(state.photoPath!).existsSync()
                                  ? Image.file(
                                      File(state.photoPath!),
                                      fit: BoxFit.cover,
                                      cacheWidth: 300,
                                      cacheHeight: 300,
                                      errorBuilder: (ctx, err, stack) => _buildDefaultAvatar(),
                                    )
                                  : Image.network(
                                      state.photoPath!,
                                      fit: BoxFit.cover,
                                      cacheWidth: 300,
                                      cacheHeight: 300,
                                      errorBuilder: (ctx, err, stack) => _buildDefaultAvatar(),
                                    ))
                              : _buildDefaultAvatar(),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: InkWell(
                        onTap: () => _showPhotoOptions(context, state),
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: CivicColors.secondary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                state.name,
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: CivicColors.onSurface),
              ),
              const SizedBox(height: 2),
              Text(
                state.ward,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12.5, color: CivicColors.onSurfaceVariant),
              ),
              const SizedBox(height: 14),

              // Edit Profile Action Button
              OutlinedButton.icon(
                onPressed: () => _showEditProfileDialog(context, state),
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: const Text('Edit Profile & Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: CivicColors.primary,
                  side: const BorderSide(color: CivicColors.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 18),

              _buildProfileTile(Icons.phone_android_rounded, 'SMS / WhatsApp Status Dispatch', state.phone),
              _buildProfileTile(Icons.location_on_outlined, 'Registered Area', state.address),
              _buildProfileTile(Icons.verified_user_outlined, 'Citizen Trust Score', 'Level ${state.trustScore} (Verified Citizen)'),
              _buildProfileTile(Icons.help_outline_rounded, 'AMC Municipal Grievance Helpline', '155304 / 1800 233 2330'),

          if (onManagePermissions != null)
            InkWell(
              onTap: onManagePermissions,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: CivicColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: CivicColors.primary.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.security_rounded, color: CivicColors.primary, size: 22),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('System Device Permissions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CivicColors.onSurface)),
                          Text('Camera, GPS Geotag, Storage, and Push Alerts', style: TextStyle(fontSize: 11.5, color: CivicColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 14, color: CivicColors.primary),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // App Details & Official App Icon Branding
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CivicColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CivicColors.outlineVariant.withValues(alpha: 0.4)),
            ),
            child: const Row(
              children: [
                CivicAppLogo(
                  size: 48,
                  showShadow: false,
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CivicAgent • AMC Civic Issue Agent',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CivicColors.onSurface),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Version 1.0.0+1 • Autonomous Tool Calls & Dispatch',
                        style: TextStyle(fontSize: 11, color: CivicColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Sign Out Action Button
          if (onSignOut != null)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Sign Out of CivicAgent?'),
                      content: const Text('You will be returned to the Citizen Sign In portal. Your filed complaints will remain synced with AMC.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            onSignOut!();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CivicColors.error,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout_rounded, color: CivicColors.error, size: 20),
                label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold, color: CivicColors.error)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: CivicColors.error),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
        ],
          ),
        );
      },
    );
  }

  Widget _buildProfileTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CivicColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: CivicColors.primary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CivicColors.onSurface)),
                Text(subtitle, style: const TextStyle(fontSize: 11.5, color: CivicColors.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

