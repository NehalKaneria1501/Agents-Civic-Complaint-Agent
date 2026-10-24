import 'package:flutter/material.dart';
import '../models/civic_models.dart';
import '../theme/civic_colors.dart';
import 'home_screen.dart';
import 'agent_chat_screen.dart';
import 'tickets_screen.dart';
import 'profile_screen.dart';
import 'ticket_detail_screen.dart';
import 'crew_tracking_screen.dart';
import '../widgets/civic_app_logo.dart';

// ==========================================
// SCREEN: MAIN SHELL SCREEN (BOTTOM NAVIGATION & HOST)
// ==========================================

class MainShellScreen extends StatefulWidget {
  final VoidCallback? onSignOut;
  final VoidCallback? onManagePermissions;
  const MainShellScreen({super.key, this.onSignOut, this.onManagePermissions});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;
  CivicTicket? _activeTicketForDetails;
  CivicTicket? _activeTicketForLiveTracking;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildStitchTopAppBar(),
      body: _buildCurrentScreen(),
      bottomNavigationBar: _buildStitchBottomNavBar(),
    );
  }

  PreferredSizeWidget _buildStitchTopAppBar() {
    return AppBar(
      backgroundColor: CivicColors.surfaceContainerLowest.withValues(alpha: 0.95),
      elevation: 0,
      scrolledUnderElevation: 1,
      title: Row(
        children: [
          const CivicAppLogo(
            size: 32,
            showShadow: false,
          ),

          const SizedBox(width: 10),
          const Text(
            'CivicAgent',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CivicColors.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: CivicColors.onSurfaceVariant),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All municipal notifications caught up.')),
              );
            },
          ),
          const CircleAvatar(
            radius: 16,
            backgroundColor: CivicColors.primary,
            child: Icon(Icons.person, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen() {
    if (_activeTicketForLiveTracking != null) {
      return CrewLiveTrackingScreen(
        ticket: _activeTicketForLiveTracking!,
        onBack: () => setState(() => _activeTicketForLiveTracking = null),
      );
    }

    if (_activeTicketForDetails != null) {
      return TicketDetailsView(
        ticket: _activeTicketForDetails!,
        onBack: () => setState(() => _activeTicketForDetails = null),
        onAskAgent: () {
          setState(() {
            _activeTicketForDetails = null;
            _currentIndex = 1; // Go to Agent Chat
          });
        },
        onTrackCrew: () {
          setState(() {
            _activeTicketForLiveTracking = _activeTicketForDetails;
          });
        },
      );
    }

    switch (_currentIndex) {
      case 0:
        return HomeScreen(
          onOpenAgentWithIncident: (incident) {
            setState(() {
              _currentIndex = 1;
            });
          },
          onOpenTicket: (ticket) {
            setState(() {
              _activeTicketForDetails = ticket;
            });
          },
        );
      case 1:
        return AgentChatScreen(
          onViewTicket: (ticket) {
            setState(() {
              _activeTicketForDetails = ticket;
            });
          },
        );
      case 2:
        return TicketsLedgerScreen(
          onOpenTicket: (ticket) {
            setState(() {
              _activeTicketForDetails = ticket;
            });
          },
        );
      case 3:
        return ProfileScreen(
          onSignOut: widget.onSignOut,
          onManagePermissions: widget.onManagePermissions,
        );
      default:
        return const HomeScreen();
    }
  }

  Widget _buildStitchBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: CivicColors.surface.withValues(alpha: 0.95),
        border: Border(top: BorderSide(color: CivicColors.outlineVariant.withValues(alpha: 0.3))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Home'),
              _buildNavItem(1, Icons.smart_toy_rounded, 'Agent'),
              _buildNavItem(2, Icons.receipt_long_rounded, 'Tickets'),
              _buildNavItem(3, Icons.person_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index && _activeTicketForDetails == null;
    return InkWell(
      onTap: () {
        setState(() {
          _activeTicketForDetails = null;
          _currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? CivicColors.primaryContainer.withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? CivicColors.onPrimaryContainer : CivicColors.onSurfaceVariant,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? CivicColors.onPrimaryContainer : CivicColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
