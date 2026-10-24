import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/civic_models.dart';
import '../services/amc_database.dart';
import '../theme/civic_colors.dart';
import '../widgets/civic_photo_renderer.dart';
import '../blocs/tickets/tickets_bloc.dart';
import '../blocs/tickets/tickets_event.dart';
import '../blocs/tickets/tickets_state.dart';

// ==========================================
// SCREEN: TICKETS LEDGER SCREEN (MVVM VIEW)
// Shows all tickets with reactive Bloc state and status filter chips
// ==========================================

class TicketsLedgerScreen extends StatefulWidget {
  final Function(CivicTicket)? onOpenTicket;

  const TicketsLedgerScreen({super.key, this.onOpenTicket});

  @override
  State<TicketsLedgerScreen> createState() => _TicketsLedgerScreenState();
}

class _TicketsLedgerScreenState extends State<TicketsLedgerScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketsBloc, TicketsState>(
      builder: (context, state) {
        List<CivicTicket> displayedTickets = AmcDatabase.instance.tickets;
        String activeFilter = 'All';

        if (state is TicketsLoadedState) {
          displayedTickets = state.filteredTickets;
          activeFilter = state.activeFilter;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Tickets & Status',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: CivicColors.onSurface),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: CivicColors.primaryContainer.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${displayedTickets.length} Registered',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: CivicColors.onPrimaryContainer),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Reactive Status Filter Chips (MVVM ViewModel Binding)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Registered', 'Assigned', 'In Progress', 'Resolved'].map((filter) {
                    final isSelected = activeFilter.toLowerCase() == filter.toLowerCase();
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(filter, style: TextStyle(fontSize: 11.5, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                        selected: isSelected,
                        selectedColor: CivicColors.primaryContainer.withValues(alpha: 0.3),
                        checkmarkColor: CivicColors.primary,
                        onSelected: (_) {
                          context.read<TicketsBloc>().add(FilterTicketsEvent(filter));
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),

              if (displayedTickets.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  alignment: Alignment.center,
                  child: const Text('No tickets found for this category filter.', style: TextStyle(color: CivicColors.onSurfaceVariant)),
                )
              else
                ...displayedTickets.map((t) => _buildTicketCard(context, t)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTicketCard(BuildContext context, CivicTicket t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CivicColors.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (widget.onOpenTicket != null) widget.onOpenTicket!(t);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top badges row
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: CivicColors.primaryContainer.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#${t.ticketId}',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: CivicColors.primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: t.severity == 'Critical' || t.severity == 'High'
                            ? CivicColors.errorContainer
                            : CivicColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        t.severity,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: t.severity == 'Critical' || t.severity == 'High'
                              ? CivicColors.error
                              : CivicColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: t.status == 'In Progress'
                        ? CivicColors.secondaryContainer
                        : t.status == 'Resolved'
                            ? CivicColors.surfaceHigh
                            : CivicColors.primaryContainer.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    t.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: t.status == 'In Progress' ? CivicColors.onSecondaryContainer : CivicColors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Content row with Photo thumbnail
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 68,
                    height: 68,
                    child: CivicPhotoRenderer(
                      photoUrl: t.photoUrl ?? sampleIncidents[0].photoUrl,
                      category: t.issueCategory,
                      title: t.title,
                      height: 68,
                      showBadge: false,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: CivicColors.onSurface),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 13, color: CivicColors.primary),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              t.area,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11.5, color: CivicColors.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.business_outlined, size: 13, color: CivicColors.onSurfaceVariant),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              t.department.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: CivicColors.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    context.read<TicketsBloc>().add(AdvanceTicketStatusEvent(t));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ticket #${t.ticketId} updated to ${t.status}! Ask agent in chat for live status.')),
                    );
                  },
                  icon: const Icon(Icons.update_rounded, size: 14),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: const Size(60, 28),
                    foregroundColor: CivicColors.primary,
                    side: BorderSide(color: CivicColors.primary.withValues(alpha: 0.5)),
                  ),
                  label: const Text('Advance Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
