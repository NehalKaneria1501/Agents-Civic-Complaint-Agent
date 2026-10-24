import 'package:flutter/material.dart';
import '../theme/civic_colors.dart';

// ==========================================
// SCREEN: PERMISSIONS ONBOARDING SCREEN
// "allow all permission as per required and necessary"
// ==========================================

class PermissionsScreen extends StatefulWidget {
  final bool cameraGranted;
  final bool locationGranted;
  final bool storageGranted;
  final bool notificationsGranted;
  final Function({
    required bool camera,
    required bool location,
    required bool storage,
    required bool notifications,
  }) onUpdatePermissions;
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const PermissionsScreen({
    super.key,
    required this.cameraGranted,
    required this.locationGranted,
    required this.storageGranted,
    required this.notificationsGranted,
    required this.onUpdatePermissions,
    required this.onContinue,
    required this.onSkip,
  });

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  late bool _camera;
  late bool _location;
  late bool _storage;
  late bool _notifications;

  @override
  void initState() {
    super.initState();
    _camera = widget.cameraGranted;
    _location = widget.locationGranted;
    _storage = widget.storageGranted;
    _notifications = widget.notificationsGranted;
  }

  void _notifyChange() {
    widget.onUpdatePermissions(
      camera: _camera,
      location: _location,
      storage: _storage,
      notifications: _notifications,
    );
  }

  void _grantAll() {
    setState(() {
      _camera = true;
      _location = true;
      _storage = true;
      _notifications = true;
    });
    _notifyChange();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ All required permissions granted: Camera, GPS, Media, & Notifications.'),
        backgroundColor: CivicColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allGranted = _camera && _location && _storage && _notifications;

    return Scaffold(
      backgroundColor: CivicColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: widget.onSkip,
            child: const Text('Skip', style: TextStyle(color: CivicColors.onSurfaceVariant)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CivicColors.primaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.verified_user_rounded, color: CivicColors.primary, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'Municipal Device Permissions',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: CivicColors.onSurface, letterSpacing: -0.5),
              ),
              const SizedBox(height: 6),
              const Text(
                'CivicAgent requires these system permissions to identify civic hazards, pinpoint your municipal ward, and alert repair squads.',
                style: TextStyle(fontSize: 13, color: CivicColors.onSurfaceVariant, height: 1.4),
              ),
              const SizedBox(height: 20),

              // Master Allow All Permissions Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [CivicColors.primary, CivicColors.primaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: CivicColors.primary.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: Colors.white, size: 28),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Allow All Required Permissions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                          SizedBox(height: 2),
                          Text('Recommended for seamless 1-tap complaint filing', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _grantAll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: CivicColors.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(allGranted ? 'Granted ✓' : 'Grant All', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Individual Permission Toggles
              _buildPermissionTile(
                icon: Icons.camera_alt_rounded,
                title: 'Camera & Live Reticle',
                subtitle: 'Capture potholes, streetlight fixtures & garbage dumps with real-time HUD analysis.',
                value: _camera,
                onChanged: (v) {
                  setState(() => _camera = v);
                  _notifyChange();
                },
              ),
              _buildPermissionTile(
                icon: Icons.location_on_rounded,
                title: 'Precise GPS Coordinates',
                subtitle: 'Automatically map the exact street location, AMC Ward, and municipal zone.',
                value: _location,
                onChanged: (v) {
                  setState(() => _location = v);
                  _notifyChange();
                },
              ),
              _buildPermissionTile(
                icon: Icons.photo_library_rounded,
                title: 'Photo Gallery & Storage',
                subtitle: 'Attach existing inspection evidence photos from your phone gallery.',
                value: _storage,
                onChanged: (v) {
                  setState(() => _storage = v);
                  _notifyChange();
                },
              ),
              _buildPermissionTile(
                icon: Icons.notifications_active_rounded,
                title: 'Push Notifications & Alerts',
                subtitle: 'Receive real-time notifications on squad dispatch, SLA timers, and resolution.',
                value: _notifications,
                onChanged: (v) {
                  setState(() => _notifications = v);
                  _notifyChange();
                },
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: widget.onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CivicColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Save & Continue to Sign In', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: value ? CivicColors.primary.withValues(alpha: 0.3) : CivicColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: value ? CivicColors.primaryContainer.withValues(alpha: 0.2) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: value ? CivicColors.primary : Colors.grey, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: CivicColors.onSurface)),
                    const SizedBox(width: 6),
                    if (value)
                      const Icon(Icons.check_circle, size: 14, color: Color(0xFF10B981)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(fontSize: 11.5, color: CivicColors.onSurfaceVariant, height: 1.35)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: CivicColors.primary,
            activeThumbColor: Colors.white,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
