import 'package:flutter_test/flutter_test.dart';
import 'package:agentsciviccomplaintagent/repositories/civic_repository.dart';
import 'package:agentsciviccomplaintagent/blocs/profile/profile_cubit.dart';
import 'package:agentsciviccomplaintagent/blocs/tickets/tickets_bloc.dart';
import 'package:agentsciviccomplaintagent/blocs/tickets/tickets_event.dart';
import 'package:agentsciviccomplaintagent/blocs/tickets/tickets_state.dart';
import 'package:agentsciviccomplaintagent/blocs/chat/chat_bloc.dart';
import 'package:agentsciviccomplaintagent/blocs/chat/chat_state.dart';

void main() {
  group('ProfileCubit (MVVM Citizen ViewModel)', () {
    late ProfileCubit cubit;

    setUp(() {
      cubit = ProfileCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state has default citizen details and trust score', () {
      expect(cubit.state.name, 'Nehal Kaneria');
      expect(cubit.state.trustScore, 4);
      expect(cubit.state.photoPath, isNull);
    });

    test('updateProfile modifies specific citizen profile fields', () {
      cubit.updateProfile(
        name: 'Aarav Patel',
        phone: '+91 99999 11111',
        ward: 'Ward 8 (Vastrapur/West District, AMC)',
      );

      expect(cubit.state.name, 'Aarav Patel');
      expect(cubit.state.phone, '+91 99999 11111');
      expect(cubit.state.ward, 'Ward 8 (Vastrapur/West District, AMC)');
      expect(cubit.state.email, 'nehal.kaneria@ahmedabadcity.gov.in'); // Unchanged
    });

    test('updatePhoto and removePhoto updates avatar state correctly', () {
      cubit.updatePhoto('sample_path/avatar.jpg');
      expect(cubit.state.photoPath, 'sample_path/avatar.jpg');

      cubit.removePhoto();
      expect(cubit.state.photoPath, isNull);
    });
  });

  group('TicketsBloc (MVVM Tickets ViewModel)', () {
    late CivicRepository repository;
    late TicketsBloc bloc;

    setUp(() {
      repository = AmcCivicRepository();
      bloc = TicketsBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is TicketsInitialState', () {
      expect(bloc.state, isA<TicketsInitialState>());
    });

    test('LoadTicketsEvent emits TicketsLoadedState with tickets from repository', () async {
      bloc.add(const LoadTicketsEvent());

      await expectLater(
        bloc.stream,
        emits(isA<TicketsLoadedState>().having(
          (s) => s.allTickets.isNotEmpty,
          'allTickets is not empty',
          isTrue,
        )),
      );
    });

    test('FilterTicketsEvent filters tickets by status correctly', () async {
      bloc.add(const LoadTicketsEvent());

      await bloc.stream.firstWhere((s) => s is TicketsLoadedState);

      bloc.add(const FilterTicketsEvent('Resolved'));

      await expectLater(
        bloc.stream,
        emits(isA<TicketsLoadedState>().having(
          (s) => s.activeFilter,
          'activeFilter',
          'Resolved',
        )),
      );
    });
  });

  group('ChatBloc (MVVM Diagnostics & AI Agent ViewModel)', () {
    late CivicRepository repository;
    late ChatBloc chatBloc;

    setUp(() {
      repository = AmcCivicRepository();
      chatBloc = ChatBloc(repository: repository);
    });

    tearDown(() {
      chatBloc.close();
    });

    test('initializes with automated seed municipal chat flow', () async {
      await expectLater(
        chatBloc.stream,
        emits(isA<ChatState>().having(
          (s) => s.messages.isNotEmpty,
          'messages length > 0',
          isTrue,
        )),
      );
    });
  });
}
