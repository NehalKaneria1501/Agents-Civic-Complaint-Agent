import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'theme/civic_colors.dart';
import 'services/firestore_service.dart';
import 'repositories/civic_repository.dart';
import 'blocs/tickets/tickets_bloc.dart';
import 'blocs/tickets/tickets_event.dart';
import 'blocs/chat/chat_bloc.dart';
import 'blocs/profile/profile_cubit.dart';
import 'screens/splash_screen.dart';
import 'screens/permissions_screen.dart';
import 'screens/auth_screens.dart';
import 'screens/main_shell_screen.dart';

import 'services/firebase_ai_logic_service.dart';

// Exports for backward-compatibility with tests & external references
export 'theme/civic_colors.dart';
export 'models/civic_models.dart';
export 'services/amc_database.dart';
export 'services/firestore_service.dart';
export 'services/firebase_ai_logic_service.dart';
export 'services/google_maps_service.dart';
export 'repositories/civic_repository.dart';
export 'blocs/tickets/tickets_bloc.dart';
export 'blocs/tickets/tickets_event.dart';
export 'blocs/tickets/tickets_state.dart';
export 'blocs/chat/chat_bloc.dart';
export 'blocs/chat/chat_event.dart';
export 'blocs/chat/chat_state.dart';
export 'blocs/profile/profile_cubit.dart';
export 'blocs/profile/profile_state.dart';
export 'widgets/civic_photo_renderer.dart';
export 'widgets/civic_app_logo.dart';
export 'screens/splash_screen.dart';
export 'screens/permissions_screen.dart';
export 'screens/auth_screens.dart';
export 'screens/main_shell_screen.dart';
export 'screens/home_screen.dart';
export 'screens/agent_chat_screen.dart';
export 'screens/tickets_screen.dart';
export 'screens/ticket_detail_screen.dart';
export 'screens/profile_screen.dart';
export 'screens/crew_tracking_screen.dart';
export 'screens/feedback_screen.dart';
export 'screens/civic_map_screen.dart';
export 'screens/amc_directory_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (civic-complaint-agent-dee84) & AI Logic
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirestoreService.instance.init();
    FirebaseAiLogicService.instance.init();
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  runApp(const CivicAgentApp());
}

// Global Alias for tests
typedef MyApp = CivicAgentApp;

// ==========================================
// ROOT APP NAVIGATION STATES
// ==========================================

enum AppNavState {
  splash,
  permissions,
  signIn,
  forgotPassword,
  otpVerification,
  mainApp,
}

// ==========================================
// ROOT APP WIDGET
// ==========================================

class CivicAgentApp extends StatefulWidget {
  final bool startWithMainApp;
  const CivicAgentApp({super.key, this.startWithMainApp = false});

  @override
  State<CivicAgentApp> createState() => _CivicAgentAppState();
}

class _CivicAgentAppState extends State<CivicAgentApp> {
  late AppNavState _navState;
  String _phoneNumber = '+91 98765 43210';
  bool _isResetPassword = false;

  // Global Permissions State
  bool _cameraGranted = true;
  bool _locationGranted = true;
  bool _storageGranted = true;
  bool _notificationsGranted = true;

  @override
  void initState() {
    super.initState();
    _navState = widget.startWithMainApp ? AppNavState.mainApp : AppNavState.splash;
  }

  void _navigateTo(AppNavState state) {
    setState(() {
      _navState = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<CivicRepository>(
      create: (context) => AmcCivicRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<TicketsBloc>(
            create: (context) => TicketsBloc(
              repository: context.read<CivicRepository>(),
            )..add(const LoadTicketsEvent()),
          ),
          BlocProvider<ChatBloc>(
            create: (context) => ChatBloc(
              repository: context.read<CivicRepository>(),
            ),
          ),
          BlocProvider<ProfileCubit>(
            create: (context) => ProfileCubit(),
          ),
        ],
        child: MaterialApp(
          title: 'AMC Civic Complaint Agent',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: CivicColors.surface,
            colorScheme: ColorScheme.fromSeed(
              seedColor: CivicColors.primary,
              primary: CivicColors.primary,
              secondary: CivicColors.secondary,
              surface: CivicColors.surface,
            ),
            fontFamily: 'Inter',
          ),
          home: _buildCurrentNavScreen(),
        ),
      ),
    );
  }

  Widget _buildCurrentNavScreen() {
    switch (_navState) {
      case AppNavState.splash:
        return SplashScreen(
          onGetStarted: () => _navigateTo(AppNavState.permissions),
          onSkipToMain: () => _navigateTo(AppNavState.mainApp),
        );
      case AppNavState.permissions:
        return PermissionsScreen(
          cameraGranted: _cameraGranted,
          locationGranted: _locationGranted,
          storageGranted: _storageGranted,
          notificationsGranted: _notificationsGranted,
          onUpdatePermissions: ({
            required bool camera,
            required bool location,
            required bool storage,
            required bool notifications,
          }) {
            setState(() {
              _cameraGranted = camera;
              _locationGranted = location;
              _storageGranted = storage;
              _notificationsGranted = notifications;
            });
          },
          onContinue: () => _navigateTo(AppNavState.signIn),
          onSkip: () => _navigateTo(AppNavState.signIn),
        );
      case AppNavState.signIn:
        return SignInScreen(
          onSignInSuccess: () => _navigateTo(AppNavState.mainApp),
          onForgotPassword: () {
            _isResetPassword = true;
            _navigateTo(AppNavState.forgotPassword);
          },
          onSignInWithOtp: (phone) {
            _phoneNumber = phone;
            _isResetPassword = false;
            _navigateTo(AppNavState.otpVerification);
          },
          onGuestDemo: () => _navigateTo(AppNavState.mainApp),
        );
      case AppNavState.forgotPassword:
        return ForgotPasswordScreen(
          onBack: () => _navigateTo(AppNavState.signIn),
          onSendOtp: (phone) {
            _phoneNumber = phone;
            _isResetPassword = true;
            _navigateTo(AppNavState.otpVerification);
          },
        );
      case AppNavState.otpVerification:
        return OtpVerificationScreen(
          phoneNumber: _phoneNumber,
          isResetPassword: _isResetPassword,
          onBack: () => _navigateTo(_isResetPassword ? AppNavState.forgotPassword : AppNavState.signIn),
          onVerificationSuccess: () => _navigateTo(AppNavState.mainApp),
        );
      case AppNavState.mainApp:
        return MainShellScreen(
          onSignOut: () => _navigateTo(AppNavState.signIn),
          onManagePermissions: () => _navigateTo(AppNavState.permissions),
        );
    }
  }
}
