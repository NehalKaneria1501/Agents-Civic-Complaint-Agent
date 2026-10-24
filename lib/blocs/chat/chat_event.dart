import 'package:equatable/equatable.dart';
import '../../models/civic_models.dart';

// ==========================================
// BLOC EVENTS: CHAT
// ==========================================

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadInitialChatEvent extends ChatEvent {
  const LoadInitialChatEvent();
}

class SendChatMessageEvent extends ChatEvent {
  final String text;
  final SampleIncident? samplePhoto;

  const SendChatMessageEvent({required this.text, this.samplePhoto});

  @override
  List<Object?> get props => [text, samplePhoto?.key];
}
