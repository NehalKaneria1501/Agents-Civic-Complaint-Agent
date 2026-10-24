import 'package:flutter/material.dart';
import '../theme/civic_colors.dart';
import '../widgets/civic_app_logo.dart';

// ==========================================
// SCREEN: PROFILE SCREEN
// ==========================================

class ProfileScreen extends StatelessWidget {
  final VoidCallback? onSignOut;
  final VoidCallback? onManagePermissions;

  const ProfileScreen({
    super.key,
    this.onSignOut,
    this.onManagePermissions,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: CivicColors.primary,
            child: Icon(Icons.person, color: Colors.white, size: 48),
          ),
          const SizedBox(height: 12),
          const Text(
            'Citizen Account (Nehal Kaneria)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CivicColors.onSurface),
          ),
          const Text(
            'Active Ward: Ward 4 (Navrangpura/Central District, AMC)',
            style: TextStyle(fontSize: 12.5, color: CivicColors.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          _buildProfileTile(Icons.notifications_active_outlined, 'SMS / WhatsApp Status Dispatch', 'Enabled (+91 98765 43210)'),
          _buildProfileTile(Icons.location_on_outlined, 'Registered Area', 'Navrangpura CG Road & Vastrapur'),
          _buildProfileTile(Icons.verified_user_outlined, 'Citizen Trust Score', 'Level 4 (Verified Citizen)'),
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
