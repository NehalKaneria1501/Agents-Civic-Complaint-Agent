import 'package:flutter/material.dart';
import '../models/civic_models.dart';
import '../theme/civic_colors.dart';
import '../widgets/civic_photo_renderer.dart';

// ==========================================
// SCREEN: TICKET DETAILS (STITCH SCREEN)
// ==========================================

class TicketDetailsView extends StatefulWidget {
  final CivicTicket ticket;
  final VoidCallback onBack;
  final VoidCallback onAskAgent;
  final VoidCallback? onTrackCrew;

  const TicketDetailsView({
    super.key,
    required this.ticket,
    required this.onBack,
    required this.onAskAgent,
    this.onTrackCrew,
  });

  @override
  State<TicketDetailsView> createState() => _TicketDetailsViewState();
}

class _TicketDetailsViewState extends State<TicketDetailsView> {
  CivicTicket get ticket => widget.ticket;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button row
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: widget.onBack,
              ),
              const Text(
                'Ticket Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CivicColors.onSurface),
              ),
              const Spacer(),
              if (!ticket.isEscalated)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      ticket.isEscalated = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('⚠️ Ticket escalated to Zonal Chief Engineer (SLA Priority Flagged)!'),
                        backgroundColor: CivicColors.error,
                      ),
                    );
                  },
                  icon: const Icon(Icons.emergency_share, size: 16, color: CivicColors.error),
                  label: const Text('Escalate', style: TextStyle(color: CivicColors.error, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Status Banner Card
          _buildStatusBanner(),
          const SizedBox(height: 16),

          // Photographic Evidence Section
          _buildPhotoEvidenceSection(),
          const SizedBox(height: 16),

          // Timeline & Status History
          _buildTimelineSection(),
          const SizedBox(height: 16),

          // Department Notes
          _buildDepartmentNotes(),
          const SizedBox(height: 18),

          // Action Button: Track Crew Live (Stitch Screen 70e916ecc2784261a0482eb36df4cc03)
          if (widget.onTrackCrew != null) ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: widget.onTrackCrew,
                icon: const Icon(Icons.location_searching_rounded, color: Colors.white, size: 20),
                label: const Text(
                  'Track Repair Crew Live (Squad #AMC-R4)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CivicColors.secondary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Action Button: Ask Civic AI Agent
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: widget.onAskAgent,
              icon: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
              label: const Text(
                'Ask Civic AI Agent about this ticket',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: CivicColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CivicColors.surfaceLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CivicColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: CivicColors.primaryContainer.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.sync_rounded, size: 14, color: CivicColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          ticket.status,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: CivicColors.onPrimaryContainer),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: CivicColors.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${ticket.severity} Severity',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: CivicColors.error),
                    ),
                  ),
                ],
              ),
              Text(
                '#${ticket.ticketId}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CivicColors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ticket.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: CivicColors.onSurface),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: CivicColors.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  ticket.area,
                  style: const TextStyle(fontSize: 12.5, color: CivicColors.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Quick Stats Grid
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Assigned Dept', style: TextStyle(fontSize: 10.5, color: CivicColors.onSurfaceVariant)),
                      const SizedBox(height: 2),
                      Text(
                        ticket.department.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: CivicColors.onSurface),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Est. Resolution', style: TextStyle(fontSize: 10.5, color: CivicColors.onSurfaceVariant)),
                      const SizedBox(height: 2),
                      Text(
                        'Within ${ticket.department.slaHours}h',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: CivicColors.onSurface),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoEvidenceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CivicColors.surfaceLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CivicColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.photo_camera_rounded, color: CivicColors.primary, size: 20),
                  const SizedBox(width: 8),
                  const Text('Photographic Evidence', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CivicColors.onSurface)),
                ],
              ),
              const Text('2 Photos Attached', style: TextStyle(fontSize: 11, color: CivicColors.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CivicPhotoRenderer(
                  photoUrl: ticket.photoUrl ?? sampleIncidents[0].photoUrl,
                  category: ticket.issueCategory,
                  title: ticket.title,
                  gpsCoords: ticket.ward.wardOffice,
                  height: 140,
                  badge: 'Initial Report',
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CivicPhotoRenderer(
                  photoUrl: ticket.followUpPhotoUrl ?? sampleIncidents[0].photoUrl,
                  category: ticket.issueCategory,
                  title: 'Post-Inspection Verification',
                  gpsCoords: ticket.ward.wardOffice,
                  height: 140,
                  badge: 'Field Squad Follow-up',
                  borderRadius: BorderRadius.circular(12),
                  customOverlay: Positioned(
                    bottom: 6,
                    left: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified, size: 12, color: CivicColors.primary),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'AI Geo-Tag Verified',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: CivicColors.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CivicColors.surfaceLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CivicColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timeline_rounded, color: CivicColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text('Status History & Timeline', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CivicColors.onSurface)),
            ],
          ),
          const SizedBox(height: 14),
          _buildTimelineStep('Complaint Filed & AI Analyzed', 'Today 2:15 PM', 'Automated computer vision classified severity as High and routed to municipal queue.', isDone: true),
          _buildTimelineStep('Ward & Department Assigned', 'Today 2:20 PM', 'Assigned to Roads & Infrastructure Dept, Ward 4 Central District.', isDone: true),
          _buildTimelineStep('Crew Dispatched', 'In Progress', 'Team Alpha (3 personnel) dispatched from Central Yard. Est. patch completion by 3:00 PM.', isDone: true, isActive: true),
          _buildTimelineStep('Quality Inspection & Closure', 'Pending', 'Final structural check by municipal inspector.', isDone: false),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String title, String time, String desc, {required bool isDone, bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: isActive
                  ? CivicColors.primaryContainer
                  : isDone
                      ? CivicColors.primary
                      : CivicColors.outlineVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDone ? Icons.check : Icons.schedule,
              color: Colors.white,
              size: 13,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isActive ? CivicColors.primary : CivicColors.onSurface)),
                    Text(time, style: const TextStyle(fontSize: 11, color: CivicColors.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 11.5, color: CivicColors.onSurfaceVariant, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentNotes() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CivicColors.surfaceLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CivicColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_outlined, color: CivicColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text('Department Notes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CivicColors.onSurface)),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.forum_outlined, color: CivicColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Inspection Officer Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: CivicColors.onSurface)),
                      const SizedBox(height: 3),
                      Text(
                        '"${ticket.fieldNotes ?? 'Severe structural base erosion detected beneath surface asphalt layer. High priority cold-patch scheduled.'}"',
                        style: const TextStyle(fontSize: 12, color: CivicColors.onSurfaceVariant, height: 1.35),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Updated by Field Supervisor ${ticket.ward.inspectorName}',
                        style: const TextStyle(fontSize: 10, color: CivicColors.onSurfaceVariant, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
