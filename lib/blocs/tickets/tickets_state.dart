import 'package:equatable/equatable.dart';
import '../../models/civic_models.dart';

// ==========================================
// BLOC STATES: TICKETS
// ==========================================

abstract class TicketsState extends Equatable {
  const TicketsState();

  @override
  List<Object?> get props => [];
}

class TicketsInitialState extends TicketsState {
  const TicketsInitialState();
}

class TicketsLoadingState extends TicketsState {
  const TicketsLoadingState();
}

class TicketsLoadedState extends TicketsState {
  final List<CivicTicket> allTickets;
  final List<CivicTicket> filteredTickets;
  final String activeFilter;

  const TicketsLoadedState({
    required this.allTickets,
    required this.filteredTickets,
    this.activeFilter = 'All',
  });

  TicketsLoadedState copyWith({
    List<CivicTicket>? allTickets,
    List<CivicTicket>? filteredTickets,
    String? activeFilter,
  }) {
    return TicketsLoadedState(
      allTickets: allTickets ?? this.allTickets,
      filteredTickets: filteredTickets ?? this.filteredTickets,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }

  @override
  List<Object?> get props => [allTickets, filteredTickets, activeFilter];
}

class TicketsErrorState extends TicketsState {
  final String message;
  const TicketsErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
