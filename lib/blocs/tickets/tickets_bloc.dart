import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/civic_models.dart';
import '../../repositories/civic_repository.dart';
import 'tickets_event.dart';
import 'tickets_state.dart';

// ==========================================
// BLOC: TICKETS BLOC
// Manages reactive municipal ticket lifecycle, SLA, and status filters
// ==========================================

class TicketsBloc extends Bloc<TicketsEvent, TicketsState> {
  final CivicRepository repository;
  StreamSubscription<List<CivicTicket>>? _subscription;

  TicketsBloc({required this.repository}) : super(const TicketsInitialState()) {
    on<LoadTicketsEvent>(_onLoadTickets);
    on<AddTicketEvent>(_onAddTicket);
    on<AdvanceTicketStatusEvent>(_onAdvanceTicketStatus);
    on<EscalateTicketEvent>(_onEscalateTicket);
    on<FilterTicketsEvent>(_onFilterTickets);

    _subscription = repository.ticketsStream.listen((tickets) {
      add(const LoadTicketsEvent());
    });
  }

  Future<void> _onLoadTickets(LoadTicketsEvent event, Emitter<TicketsState> emit) async {
    try {
      final currentFilter = state is TicketsLoadedState
          ? (state as TicketsLoadedState).activeFilter
          : 'All';

      final tickets = await repository.fetchTickets();
      final filtered = _applyFilter(tickets, currentFilter);

      emit(TicketsLoadedState(
        allTickets: tickets,
        filteredTickets: filtered,
        activeFilter: currentFilter,
      ));
    } catch (e) {
      emit(TicketsErrorState('Failed to load tickets: $e'));
    }
  }

  Future<void> _onAddTicket(AddTicketEvent event, Emitter<TicketsState> emit) async {
    try {
      await repository.registerTicket(event.ticket);
      add(const LoadTicketsEvent());
    } catch (e) {
      emit(TicketsErrorState('Failed to register ticket: $e'));
    }
  }

  Future<void> _onAdvanceTicketStatus(AdvanceTicketStatusEvent event, Emitter<TicketsState> emit) async {
    try {
      await repository.advanceTicketStatus(event.ticket);
      add(const LoadTicketsEvent());
    } catch (e) {
      emit(TicketsErrorState('Failed to advance ticket: $e'));
    }
  }

  Future<void> _onEscalateTicket(EscalateTicketEvent event, Emitter<TicketsState> emit) async {
    try {
      await repository.escalateTicket(event.ticket);
      add(const LoadTicketsEvent());
    } catch (e) {
      emit(TicketsErrorState('Failed to escalate ticket: $e'));
    }
  }

  void _onFilterTickets(FilterTicketsEvent event, Emitter<TicketsState> emit) {
    if (state is TicketsLoadedState) {
      final current = state as TicketsLoadedState;
      final filtered = _applyFilter(current.allTickets, event.statusFilter);
      emit(current.copyWith(
        filteredTickets: filtered,
        activeFilter: event.statusFilter,
      ));
    }
  }

  List<CivicTicket> _applyFilter(List<CivicTicket> tickets, String filter) {
    if (filter == 'All') return tickets;
    return tickets.where((t) => t.status.toLowerCase() == filter.toLowerCase()).toList();
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
