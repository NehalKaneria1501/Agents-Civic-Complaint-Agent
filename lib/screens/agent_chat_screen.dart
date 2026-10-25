import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../blocs/chat/chat_bloc.dart';
import '../blocs/chat/chat_event.dart';
import '../blocs/chat/chat_state.dart';
import '../models/civic_models.dart';
import '../services/amc_database.dart';
import '../services/google_maps_service.dart';
import '../theme/civic_colors.dart';
import '../widgets/civic_photo_renderer.dart';

// ==========================================
// SCREEN: AGENT CHAT SCREEN (MVVM ARCHITECTURE)
// Full AI Chatbot driven by ChatBloc, Events & States
// ==========================================

class AgentChatScreen extends StatefulWidget {
  final Function(CivicTicket)? onViewTicket;
  final SampleIncident? initialIncident;
  final VoidCallback? onBack;

  const AgentChatScreen({
    super.key,
    this.onViewTicket,
    this.initialIncident,
    this.onBack,
  });

  @override
  State<AgentChatScreen> createState() => _AgentChatScreenState();
}

class _AgentChatScreenState extends State<AgentChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.initialIncident != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleUserMessage(
          'Please analyze this ${widget.initialIncident!.title} hazard and file a municipal ticket with live GPS routing.',
          samplePhoto: widget.initialIncident,
        );
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleUserMessage(String text, {SampleIncident? samplePhoto}) {
    final query = text.trim();
    if (query.isEmpty && samplePhoto == null) return;

    _textController.clear();
    context.read<ChatBloc>().add(
          SendChatMessageEvent(
            text: query,
            samplePhoto: samplePhoto,
          ),
        );
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // When keyboard opens or screen is compact, height drops below 480
        final isKeyboardOrCompact = constraints.maxHeight < 480;

        return BlocConsumer<ChatBloc, ChatState>(
          listener: (context, state) {
            _scrollToBottom();
          },
          builder: (context, state) {
            return Column(
              children: [
                // Header Agent Context Banner (collapses when keyboard is active to prevent squashing)
                if (!isKeyboardOrCompact) _buildContextBanner(),

                // Chat Message List
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.messages.length,
                    itemBuilder: (ctx, i) => _buildMessageRow(state.messages[i]),
                  ),
                ),

                // Agent Processing Status Bar
                if (state.isProcessing)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: CivicColors.primary,
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            state.stepLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Quick Suggestion Pills (shown when keyboard is dismissed)
                if (!isKeyboardOrCompact) _buildSuggestionPills(),

                // Chat Input Bar
                _buildInputBar(isKeyboardOrCompact: isKeyboardOrCompact),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildContextBanner() {
    final ticket = AmcDatabase.instance.tickets.first;
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: CivicColors.primaryContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          if (widget.onBack != null) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: CivicColors.onSurface, size: 22),
              onPressed: widget.onBack,
              tooltip: 'Back',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 10),
          ],
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: CivicColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'CivicBot Assistant',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: CivicColors.onSurface),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                    ),
                  ],
                ),
                Text(
                  'Active Municipal Case #${ticket.ticketId}',
                  style: const TextStyle(fontSize: 11.5, color: CivicColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: CivicColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'AI Active',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: CivicColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageRow(ChatMessage msg) {
    if (msg.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 300),
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: CivicColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.text,
                    style: const TextStyle(color: Colors.white, fontSize: 13.5, height: 1.35),
                  ),
                  if (msg.attachedPhoto != null) ...[
                    const SizedBox(height: 10),
                    CivicPhotoRenderer(
                      photoUrl: msg.attachedPhoto!.photoUrl,
                      category: msg.attachedPhoto!.departmentKey,
                      title: msg.attachedPhoto!.title,
                      gpsCoords: msg.attachedPhoto!.gpsCoords,
                      height: 140,
                      badge: 'Citizen Photo Attachment',
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 4),
            const Text('Just now', style: TextStyle(fontSize: 10.5, color: CivicColors.onSurfaceVariant)),
          ],
        ),
      );
    }

    // AI Message
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: CivicColors.primary,
            child: Icon(Icons.smart_toy_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Agent Thinking / Tool Execution Bento
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: CivicColors.surfaceContainer,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.text,
                        style: const TextStyle(fontSize: 13.5, color: CivicColors.onSurface, height: 1.35),
                      ),
                      if (msg.toolCalls.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _buildToolDiagnosticsList(msg.toolCalls),
                      ],
                      if (msg.googleMapsUrl != null) ...[
                        const SizedBox(height: 10),
                        _buildGoogleMapsCard(msg),
                      ],
                      if (msg.ticketSummary != null) ...[
                        const SizedBox(height: 12),
                        _buildTrackingIdCard(msg.ticketSummary!),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const Text('Just now', style: TextStyle(fontSize: 10.5, color: CivicColors.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleMapsCard(ChatMessage msg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E88E5).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.place_rounded, color: Color(0xFF1E88E5), size: 16),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Google Maps Platform Live Location',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    GoogleMapsService.openMapLocation(
                      latitude: 23.0365,
                      longitude: 72.5126,
                      label: msg.ticketSummary?.title ?? 'Civic Hazard Location',
                    );
                  },
                  icon: const Icon(Icons.map_rounded, size: 14),
                  label: const Text('View on Map', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1565C0),
                    side: const BorderSide(color: Color(0xFF1E88E5)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: const Size(40, 32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    GoogleMapsService.openDirections(
                      destinationLat: 23.0365,
                      destinationLng: 72.5126,
                    );
                  },
                  icon: const Icon(Icons.directions_rounded, size: 14),
                  label: const Text('Directions', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: const Size(40, 32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolDiagnosticsList(List<ToolCallLog> toolLogs) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: toolLogs.map((tool) {
          IconData icon = Icons.check_circle_rounded;
          Color iconColor = CivicColors.primary;
          String label = tool.toolName;

          if (tool.type == ToolCallType.firebaseAiLogic) {
            icon = Icons.auto_awesome_rounded;
            iconColor = const Color(0xFF6750A4);
            label = 'Firebase AI Logic (Gemini 1.5 Flash): ${tool.result['category'] ?? 'Damage Triage'}';
          } else if (tool.type == ToolCallType.googleMapsRoute) {
            icon = Icons.map_rounded;
            iconColor = const Color(0xFF1E88E5);
            label = 'Google Maps GIS: Pinpointed coordinates & repair squad route';
          } else if (tool.type == ToolCallType.analyzeImage) {
            label = 'Image Analysis: Pothole detected (severity high)';
          } else if (tool.type == ToolCallType.lookupWardDepartment) {
            label = 'Ward Lookup: Ward 4 - Central Zone';
          } else if (tool.type == ToolCallType.createTicket) {
            label = 'Department Assignment: Roads & Infrastructure Dept';
          } else if (tool.type == ToolCallType.fetchStatus) {
            label = 'Status Fetch: Active Assigned in Ledger';
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: CivicColors.onSurface),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrackingIdCard(CivicTicket ticket) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CivicColors.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CivicColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CivicColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tracking ID Generated',
                  style: TextStyle(fontSize: 10.5, color: CivicColors.onSurfaceVariant),
                ),
                Text(
                  '#${ticket.ticketId}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CivicColors.onPrimaryContainer),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (widget.onViewTicket != null) {
                widget.onViewTicket!(ticket);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CivicColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(60, 32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('View Ticket', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildPill('What is the status?', Icons.help_outline_rounded, () {
            _handleUserMessage('What is the status?');
          }),
          _buildPill('Report Pothole', Icons.car_crash_rounded, () {
            _handleUserMessage('', samplePhoto: sampleIncidents[0]);
          }),
          _buildPill('Notify Ward Engineer', Icons.contact_phone_outlined, () {
            _handleUserMessage('Notify the ward engineer for immediate repair');
          }),
          _buildPill('View updated timeline', Icons.timeline_rounded, () {
            if (widget.onViewTicket != null) {
              widget.onViewTicket!(AmcDatabase.instance.tickets.first);
            }
          }),
        ],
      ),
    );
  }

  Widget _buildPill(String label, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Icon(icon, size: 14, color: CivicColors.primary),
        label: Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
        backgroundColor: CivicColors.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: CivicColors.outlineVariant.withValues(alpha: 0.3)),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildInputBar({bool isKeyboardOrCompact = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: isKeyboardOrCompact ? 6 : 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: CivicColors.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: SafeArea(
        top: false,
        bottom: !isKeyboardOrCompact,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: CivicColors.surfaceLow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        maxLines: 3,
                        minLines: 1,
                        textInputAction: TextInputAction.send,
                        onTap: () => Future.delayed(const Duration(milliseconds: 250), _scrollToBottom),
                        onSubmitted: (val) => _handleUserMessage(val),
                        decoration: const InputDecoration(
                          hintText: 'Message CivicBot...',
                          hintStyle: TextStyle(fontSize: 13, color: CivicColors.onSurfaceVariant),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    // Quick Camera Button
                    IconButton(
                      icon: const Icon(Icons.camera_alt_rounded, color: CivicColors.primary, size: 21),
                      tooltip: 'Take Photo with Camera',
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                      onPressed: _openCameraFromChat,
                    ),
                    const SizedBox(width: 4),
                    // Attachment / Gallery / Document Picker Button
                    IconButton(
                      icon: const Icon(Icons.attach_file_rounded, color: CivicColors.onSurfaceVariant, size: 20),
                      tooltip: 'Upload from Gallery or Documents',
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                      onPressed: _showChatAttachmentOptions,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton.small(
              onPressed: () => _handleUserMessage(_textController.text),
              backgroundColor: CivicColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              child: const Icon(Icons.send_rounded, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCameraFromChat() async {
    final photo = await pickCivicPhoto(context: context, source: ImageSource.camera);
    if (photo != null) {
      _handleUserMessage('Reporting civic hazard with captured photo', samplePhoto: photo);
    }
  }

  Future<void> _openGalleryFromChat() async {
    final photo = await pickCivicPhoto(context: context, source: ImageSource.gallery);
    if (photo != null) {
      _handleUserMessage('Reporting civic hazard with gallery photo', samplePhoto: photo);
    }
  }

  void _showChatAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Attach Civic Evidence',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: CivicColors.onSurface),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: CivicColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: CivicColors.primary, size: 22),
                    ),
                    title: const Text('Take Photo from Camera', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Capture live pothole, garbage, or streetlight evidence', style: TextStyle(fontSize: 12)),
                    onTap: () {
                      Navigator.pop(ctx);
                      _openCameraFromChat();
                    },
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: CivicColors.secondary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.photo_library_rounded, color: CivicColors.secondary, size: 22),
                    ),
                    title: const Text('Upload Photo from Gallery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Select existing incident photo from your phone gallery', style: TextStyle(fontSize: 12)),
                    onTap: () {
                      Navigator.pop(ctx);
                      _openGalleryFromChat();
                    },
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: CivicColors.tertiary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.picture_as_pdf_rounded, color: CivicColors.tertiary, size: 22),
                    ),
                    title: const Text('Attach Incident Document / PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Attach municipal complaint notice or inspection document', style: TextStyle(fontSize: 12)),
                    onTap: () {
                      Navigator.pop(ctx);
                      final pdfIncident = SampleIncident(
                        key: 'pdf-${DateTime.now().millisecondsSinceEpoch}',
                        title: 'Municipal Notice / PDF Document',
                        issueCategory: 'Pothole & Broken Asphalt',
                        defaultArea: 'Ahmedabad Municipal Area',
                        description: 'Citizen attached official inspection PDF document for verification.',
                        severity: 'High',
                        departmentKey: 'pothole',
                        icon: Icons.picture_as_pdf_rounded,
                        accentColor: CivicColors.tertiary,
                        gpsCoords: '23.0338° N, 72.5467° E (Document Ref)',
                        photoUrl: sampleIncidents[0].photoUrl,
                      );
                      _handleUserMessage('Attached municipal inspection PDF document', samplePhoto: pdfIncident);
                    },
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 6),
                  const Text('Quick Test Scenarios (Demo Presets):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: CivicColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: sampleIncidents.map((s) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            avatar: Icon(s.icon, size: 14, color: s.accentColor),
                            label: Text(s.title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            onPressed: () {
                              Navigator.pop(ctx);
                              _handleUserMessage('Reporting issue from photo evidence', samplePhoto: s);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
