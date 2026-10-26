import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/civic_models.dart';
import '../theme/civic_colors.dart';
import '../blocs/profile/profile_cubit.dart';
import '../blocs/profile/profile_state.dart';
import 'home_screen.dart';
import 'agent_chat_screen.dart';
import 'tickets_screen.dart';
import 'profile_screen.dart';
import 'ticket_detail_screen.dart';
import 'crew_tracking_screen.dart';
import 'feedback_screen.dart';
import 'civic_map_screen.dart';
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
  int _currentIndex = 0; // 0: Home, 1: Maps, 2: Tickets, 3: Feedback
  bool _isViewingProfile = false;
  bool _isViewingAgentChat = false;
  CivicTicket? _activeTicketForDetails;
  CivicTicket? _activeTicketForLiveTracking;
  SampleIncident? _activeIncidentForAgent;

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: _buildStitchTopAppBar(),
      body: _buildCurrentScreen(),
      floatingActionButton: (isKeyboardOpen || _isViewingProfile || _isViewingAgentChat)
          ? null
          : FloatingActionButton.extended(
              heroTag: 'civic_chatbot_fab',
              onPressed: () {
                setState(() {
                  _isViewingProfile = false;
                  _isViewingAgentChat = true;
                  _activeTicketForDetails = null;
                  _activeTicketForLiveTracking = null;
                });
              },
              backgroundColor: CivicColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.smart_toy_rounded, size: 20),
              label: const Text(
                'CivicBot AI',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.2),
              ),
            ),
      bottomNavigationBar: isKeyboardOpen ? null : _buildStitchBottomNavBar(),
    );
  }

  PreferredSizeWidget _buildStitchTopAppBar() {
    if (_isViewingProfile) {
      return AppBar(
        backgroundColor: CivicColors.surfaceContainerLowest.withValues(alpha: 0.95),
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: CivicColors.onSurface),
          onPressed: () {
            setState(() {
              _isViewingProfile = false;
            });
          },
        ),
        title: const Text(
          'Citizen Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: CivicColors.onSurface,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: CivicColors.onSurfaceVariant),
            onPressed: () {
              setState(() {
                _isViewingProfile = false;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      );
    }

    return AppBar(
      backgroundColor: CivicColors.surfaceContainerLowest.withValues(alpha: 0.95),
      elevation: 0,
      scrolledUnderElevation: 1,
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CivicAppLogo(
            size: 32,
            showShadow: false,
          ),
          SizedBox(width: 10),
          Text(
            'CivicAgent',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CivicColors.onSurface,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: CivicColors.onSurfaceVariant),
          tooltip: 'Municipal notifications',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('All municipal notifications caught up.')),
            );
          },
        ),
        BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, profileState) {
            final hasPhoto = profileState.photoPath != null && profileState.photoPath!.isNotEmpty;
            return Tooltip(
              message: 'Citizen Profile & Settings',
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isViewingProfile = true;
                    _isViewingAgentChat = false;
                    _activeTicketForDetails = null;
                    _activeTicketForLiveTracking = null;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: CivicColors.primary, width: 2),
                  ),
                  child: ClipOval(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: hasPhoto
                          ? (profileState.photoPath!.startsWith('http')
                              ? Image.network(
                                  profileState.photoPath!,
                                  fit: BoxFit.cover,
                                  cacheWidth: 100,
                                  cacheHeight: 100,
                                  errorBuilder: (_, _, _) => _buildTopBarDefaultAvatar(),
                                )
                              : Image.file(
                                  File(profileState.photoPath!),
                                  fit: BoxFit.cover,
                                  cacheWidth: 100,
                                  cacheHeight: 100,
                                  errorBuilder: (_, _, _) => _buildTopBarDefaultAvatar(),
                                ))
                          : _buildTopBarDefaultAvatar(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTopBarDefaultAvatar() {
    return Container(
      color: CivicColors.primary,
      alignment: Alignment.center,
      child: const Icon(Icons.person, color: Colors.white, size: 17),
    );
  }

  Widget _buildCurrentScreen() {
    if (_isViewingProfile) {
      return ProfileScreen(
        onSignOut: widget.onSignOut,
        onManagePermissions: widget.onManagePermissions,
      );
    }

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
            _isViewingAgentChat = true; // Open CivicBot Agent Chat
          });
        },
        onTrackCrew: () {
          setState(() {
            _activeTicketForLiveTracking = _activeTicketForDetails;
          });
        },
      );
    }

    if (_isViewingAgentChat) {
      return AgentChatScreen(
        initialIncident: _activeIncidentForAgent,
        onViewTicket: (ticket) {
          setState(() {
            _isViewingAgentChat = false;
            _activeTicketForDetails = ticket;
          });
        },
        onBack: () {
          setState(() {
            _isViewingAgentChat = false;
            _activeIncidentForAgent = null;
          });
        },
      );
    }

    switch (_currentIndex) {
      case 0:
        return HomeScreen(
          onOpenAgentWithIncident: (incident) {
            setState(() {
              _isViewingProfile = false;
              _isViewingAgentChat = true;
              _activeIncidentForAgent = incident;
            });
          },
          onOpenTicket: (ticket) {
            setState(() {
              _isViewingProfile = false;
              _activeTicketForDetails = ticket;
            });
          },
          onOpenFeedback: () {
            setState(() {
              _isViewingProfile = false;
              _currentIndex = 3; // Switch to Feedback / Complaint form
            });
          },
        );
      case 1:
        return CivicMapScreen(
          isEmbedded: true,
          onSelectTicket: (ticket) {
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
        return FeedbackComplaintScreen(
          onComplaintSubmitted: () {
            setState(() {
              _currentIndex = 2; // Jump to Tickets ledger to track new grievance
            });
          },
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
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              Expanded(child: _buildNavItem(0, Icons.home_rounded, 'Home')),
              Expanded(child: _buildNavItem(1, Icons.map_rounded, 'Maps')),
              Expanded(child: _buildNavItem(2, Icons.receipt_long_rounded, 'Tickets')),
              Expanded(child: _buildNavItem(3, Icons.rate_review_rounded, 'Feedback')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = !_isViewingProfile &&
        !_isViewingAgentChat &&
        _currentIndex == index &&
        _activeTicketForDetails == null &&
        _activeTicketForLiveTracking == null;

    return InkWell(
      onTap: () {
        setState(() {
          _isViewingProfile = false;
          _isViewingAgentChat = false;
          _activeTicketForDetails = null;
          _activeTicketForLiveTracking = null;
          _currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
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
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? CivicColors.onPrimaryContainer : CivicColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


