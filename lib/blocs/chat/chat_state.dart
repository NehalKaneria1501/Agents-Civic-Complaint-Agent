import 'package:equatable/equatable.dart';
import '../../models/civic_models.dart';

// ==========================================
// BLOC STATES: CHAT
// ==========================================

class ChatState extends Equatable {
  final List<ChatMessage> messages;
  final bool isProcessing;
  final String stepLabel;
  final String? errorMessage;

  const ChatState({
    this.messages = const [],
    this.isProcessing = false,
    this.stepLabel = '',
    this.errorMessage,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isProcessing,
    String? stepLabel,
    String? errorMessage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isProcessing: isProcessing ?? this.isProcessing,
      stepLabel: stepLabel ?? this.stepLabel,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [messages, isProcessing, stepLabel, errorMessage];
}
