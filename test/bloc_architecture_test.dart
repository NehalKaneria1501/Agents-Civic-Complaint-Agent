import 'package:flutter_test/flutter_test.dart';
import 'package:agentsciviccomplaintagent/repositories/civic_repository.dart';
import 'package:agentsciviccomplaintagent/blocs/profile/profile_cubit.dart';
import 'package:agentsciviccomplaintagent/blocs/tickets/tickets_bloc.dart';
import 'package:agentsciviccomplaintagent/blocs/tickets/tickets_event.dart';
import 'package:agentsciviccomplaintagent/blocs/tickets/tickets_state.dart';
import 'package:agentsciviccomplaintagent/blocs/chat/chat_bloc.dart';
import 'package:agentsciviccomplaintagent/blocs/chat/chat_state.dart';
import 'package:agentsciviccomplaintagent/services/google_maps_service.dart';
import 'package:agentsciviccomplaintagent/services/firebase_ai_logic_service.dart';

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

  group('GoogleMapsService & FirebaseAiLogicService', () {
    test('parseGpsCoordinates parses degrees and directions accurately', () {
      final coords = GoogleMapsService.parseGpsCoordinates('23.0365° N, 72.5126° E (Ward 4)');
      expect(coords, isNotNull);
      expect(coords!.key, closeTo(23.0365, 0.001));
      expect(coords.value, closeTo(72.5126, 0.001));
    });

    test('parseGpsCoordinates returns Ahmedabad HQ fallback on malformed string', () {
      final coords = GoogleMapsService.parseGpsCoordinates('unknown location');
      expect(coords, isNotNull);
      expect(coords!.key, closeTo(23.0225, 0.001));
      expect(coords.value, closeTo(72.5714, 0.001));
    });

    test('FirebaseAiLogicService analyzeIncident returns valid structured result', () async {
      final result = await FirebaseAiLogicService.instance.analyzeIncident(
        userText: 'Broken asphalt on road',
      );
      expect(result.title, isNotEmpty);
      expect(result.googleMapsUrl, contains('google.com/maps'));
      expect(result.googleMapsDirectionsUrl, contains('google.com/maps/dir'));
      expect(result.latitude, isNotNull);
      expect(result.longitude, isNotNull);
    });
  });
}

