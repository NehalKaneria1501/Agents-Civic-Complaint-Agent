import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/civic_models.dart';
import '../services/amc_database.dart';
import '../theme/civic_colors.dart';
import '../widgets/civic_photo_renderer.dart';

// ==========================================
// SCREEN: AGENT CHAT SCREEN
// Full AI Chatbot with Camera & Gallery uploads
// ==========================================

class AgentChatScreen extends StatefulWidget {
  final Function(CivicTicket)? onViewTicket;

  const AgentChatScreen({super.key, this.onViewTicket});

  @override
  State<AgentChatScreen> createState() => _AgentChatScreenState();
}

class _AgentChatScreenState extends State<AgentChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isProcessing = false;
  String _agentStepLabel = '';

  @override
  void initState() {
    super.initState();
    _seedInitialChatFlow();
  }

  void _seedInitialChatFlow() {
    // 1. Initial User photo upload message
    _messages.add(
      ChatMessage(
        id: 'user-01',
        isUser: true,
        text: 'Can you report this massive pothole I just hit on Main Street near 4th Ave?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        attachedPhoto: sampleIncidents[0],
      ),
    );

    // 2. Initial AI Agent Tool Execution Response
    final ticket = AmcDatabase.instance.tickets.first;
    _messages.add(
      ChatMessage(
        id: 'bot-01',
        isUser: false,
        text: "I've received your photo. Running automated municipal diagnostics...",
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
        ticketSummary: ticket,
        toolCalls: [
          ToolCallLog(
            type: ToolCallType.analyzeImage,
            toolName: 'analyze_civic_image()',
            arguments: {'image': 'pothole_main_st.jpg', 'mode': 'damage_severity'},
            result: {'detected_issue': 'Pothole (severity high)', 'confidence': 0.98},
            latency: const Duration(milliseconds: 480),
          ),
          ToolCallLog(
            type: ToolCallType.lookupWardDepartment,
            toolName: 'lookup_ward_and_department()',
            arguments: {'gps': '23.0365, 72.5126', 'issue': 'Pothole'},
            result: {'ward': 'Ward 4 - Central Zone', 'dept': 'Roads & Infrastructure Dept'},
            latency: const Duration(milliseconds: 390),
          ),
          ToolCallLog(
            type: ToolCallType.createTicket,
            toolName: 'create_amc_ticket()',
            arguments: {'title': 'Deep Pothole Hazard', 'ward': 4, 'dept': 'ROAD_ENG'},
            result: {'ticket_id': '#AMC-9482', 'status': 'Assigned', 'sla': '48h'},
            latency: const Duration(milliseconds: 520),
          ),
        ],
      ),
    );

    // 3. User status query
    _messages.add(
      ChatMessage(
        id: 'user-02',
        isUser: true,
        text: 'What is the status?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
    );

    // 4. AI Agent status answer
    _messages.add(
      ChatMessage(
        id: 'bot-02',
        isUser: false,
        text: 'Ticket **#AMC-9482** is currently **Assigned** to Ward 4 Roads Team. Estimated repair by Thursday.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        ticketSummary: ticket,
        toolCalls: [
          ToolCallLog(
            type: ToolCallType.fetchStatus,
            toolName: 'fetch_ticket_status()',
            arguments: {'ticket_id': 'AMC-9482'},
            result: ticket.toJson(),
            latency: const Duration(milliseconds: 320),
          ),
        ],
      ),
    );
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

  Future<void> _handleUserMessage(String text, {SampleIncident? samplePhoto}) async {
    final query = text.trim();
    if (query.isEmpty && samplePhoto == null) return;

    _textController.clear();
    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          isUser: true,
          text: query.isNotEmpty ? query : 'Report civic issue from photo (${samplePhoto?.title})',
          timestamp: DateTime.now(),
          attachedPhoto: samplePhoto,
        ),
      );
      _isProcessing = true;
      _agentStepLabel = 'CivicBot reviewing municipal query...';
    });
    _scrollToBottom();

    final lower = query.toLowerCase();
    final isStatus = lower.contains('status') || lower.contains('track') || lower.contains('update');

    if (isStatus && samplePhoto == null) {
      await _executeStatusQuery(query);
    } else {
      await _executeFilingPipeline(samplePhoto ?? sampleIncidents[0]);
    }

    setState(() {
      _isProcessing = false;
      _agentStepLabel = '';
    });
    _scrollToBottom();
  }

  Future<void> _executeFilingPipeline(SampleIncident photo) async {
    final tools = <ToolCallLog>[];

    setState(() => _agentStepLabel = 'Executing analyze_civic_image()...');
    await Future.delayed(const Duration(milliseconds: 600));
    tools.add(
      ToolCallLog(
        type: ToolCallType.analyzeImage,
        toolName: 'analyze_civic_image()',
        arguments: {'photo_key': photo.key, 'exif_gps': photo.gpsCoords},
        result: {'issue': photo.issueCategory, 'severity': photo.severity, 'confidence': '98.5%'},
        latency: const Duration(milliseconds: 510),
      ),
    );

    setState(() => _agentStepLabel = 'Executing lookup_ward_and_department()...');
    await Future.delayed(const Duration(milliseconds: 550));
    final ward = AmcDatabase.instance.findWard(photo.defaultArea);
    final dept = AmcDatabase.instance.findDepartment(photo.departmentKey);
    tools.add(
      ToolCallLog(
        type: ToolCallType.lookupWardDepartment,
        toolName: 'lookup_ward_and_department()',
        arguments: {'location': photo.defaultArea, 'category': photo.issueCategory},
        result: {'ward': '${ward.wardName} (${ward.zone})', 'dept': dept.name, 'sla': '${dept.slaHours}h'},
        latency: const Duration(milliseconds: 440),
      ),
    );

    setState(() => _agentStepLabel = 'Executing create_amc_ticket()...');
    await Future.delayed(const Duration(milliseconds: 600));
    final ticket = AmcDatabase.instance.createTicket(
      issueCategory: photo.issueCategory,
      description: photo.description,
      severity: photo.severity,
      area: photo.defaultArea,
      departmentKey: photo.departmentKey,
      photoUrl: photo.photoUrl,
    );
    tools.add(
      ToolCallLog(
        type: ToolCallType.createTicket,
        toolName: 'create_amc_ticket()',
        arguments: {'category': ticket.issueCategory, 'ward': ward.wardNumber},
        result: ticket.toJson(),
        latency: const Duration(milliseconds: 580),
      ),
    );

    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          isUser: false,
          text: "I've analyzed your photo. Complaint successfully logged under official municipal SLA.",
          timestamp: DateTime.now(),
          ticketSummary: ticket,
          toolCalls: tools,
        ),
      );
    });
  }

  Future<void> _executeStatusQuery(String query) async {
    setState(() => _agentStepLabel = 'Executing fetch_ticket_status()...');
    await Future.delayed(const Duration(milliseconds: 600));

    final ticket = AmcDatabase.instance.fetchStatus(query);
    if (ticket == null) return;

    final tool = ToolCallLog(
      type: ToolCallType.fetchStatus,
      toolName: 'fetch_ticket_status()',
      arguments: {'query': query, 'ticket_id': ticket.ticketId},
      result: ticket.toJson(),
      latency: const Duration(milliseconds: 340),
    );

    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          isUser: false,
          text: 'Ticket **#${ticket.ticketId}** is currently **${ticket.status}** with ${ticket.department.name}. Estimated repair within ${ticket.department.slaHours} hours.',
          timestamp: DateTime.now(),
          ticketSummary: ticket,
          toolCalls: [tool],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Agent Context Banner
        _buildContextBanner(),

        // Chat Message List
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (ctx, i) => _buildMessageRow(_messages[i]),
          ),
        ),

        // Agent Processing Status Bar
        if (_isProcessing)
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
                Text(
                  _agentStepLabel,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

        // Quick Suggestion Pills
        _buildSuggestionPills(),

        // Chat Input Bar
        _buildInputBar(),
      ],
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

  Widget _buildToolDiagnosticsList(List<ToolCallLog> toolLogs) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: toolLogs.map((tool) {
          String label = tool.toolName;
          if (tool.type == ToolCallType.analyzeImage) {
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
                const Icon(Icons.check_circle_rounded, color: CivicColors.primary, size: 16),
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

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: CivicColors.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: CivicColors.surfaceLow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        onSubmitted: (val) => _handleUserMessage(val),
                        decoration: const InputDecoration(
                          hintText: 'Message CivicBot...',
                          hintStyle: TextStyle(fontSize: 13, color: CivicColors.onSurfaceVariant),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    // Quick Camera Button
                    IconButton(
                      icon: const Icon(Icons.camera_alt_rounded, color: CivicColors.primary, size: 21),
                      tooltip: 'Take Photo with Camera',
                      onPressed: _openCameraFromChat,
                    ),
                    // Attachment / Gallery / Document Picker Button
                    IconButton(
                      icon: const Icon(Icons.attach_file_rounded, color: CivicColors.onSurfaceVariant, size: 20),
                      tooltip: 'Upload from Gallery or Documents',
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
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
        );
      },
    );
  }
}
