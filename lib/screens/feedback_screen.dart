import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../blocs/tickets/tickets_bloc.dart';
import '../blocs/tickets/tickets_event.dart';
import '../models/civic_models.dart';
import '../theme/civic_colors.dart';
import '../widgets/civic_photo_renderer.dart';

// ==========================================
// SCREEN: CITIZEN FEEDBACK & COMPLAINT FORM
// Official AMC Municipal Grievance & Suggestion Portal
// ==========================================

class FeedbackComplaintScreen extends StatefulWidget {
  final VoidCallback? onComplaintSubmitted;

  const FeedbackComplaintScreen({super.key, this.onComplaintSubmitted});

  @override
  State<FeedbackComplaintScreen> createState() => _FeedbackComplaintScreenState();
}

class _FeedbackComplaintScreenState extends State<FeedbackComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _citizenNameController = TextEditingController(text: 'Nehal Kaneria');
  final _phoneController = TextEditingController(text: '+91 98765 43210');

  // Form selections
  bool _isGrievance = true; // true = Formal Complaint, false = Suggestion / Feedback
  String _selectedCategory = 'Road & Asphalt Infrastructure';
  String _selectedWard = 'Ward 4 - Navrangpura (Central)';
  int _starRating = 4;
  SampleIncident? _attachedPhoto;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Road & Asphalt Infrastructure',
    'Solid Waste & Garbage Collection',
    'Streetlight & Electrical Network',
    'Potable Water Supply & Leakage',
    'Stormwater Drainage & Waterlogging',
    'Health, Hygiene & Vector Fogging',
    'Parks, Gardens & Tree Pruning',
    'Encroachment & Illegal Parking',
  ];

  final List<String> _wards = [
    'Ward 4 - Navrangpura (Central)',
    'Ward 8 - Vastrapur (West)',
    'Ward 12 - Bodakdev (West)',
    'Ward 15 - Paldi (South-West)',
    'Ward 21 - Maninagar (South)',
    'Ward 32 - Sabarmati (North-West)',
    'Ward 42 - Ellisbridge (Central)',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _citizenNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final photo = await pickCivicPhoto(context: context, source: source);
    if (photo != null) {
      setState(() {
        _attachedPhoto = photo;
      });
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final newTicketId = 'AMC-${(DateTime.now().millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}';
    final wardNum = int.tryParse(_selectedWard.replaceAll(RegExp(r'[^0-9]'), '')) ?? 4;

    final newTicket = CivicTicket(
      ticketId: newTicketId,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      area: _selectedWard,
      status: 'Registered',
      severity: _isGrievance ? 'High' : 'Normal',
      createdAt: DateTime.now(),
      issueCategory: _selectedCategory,
      photoUrl: _attachedPhoto?.photoUrl,
      department: DepartmentInfo(
        code: 'AMC-DEPT-${_selectedCategory.substring(0, 4).toUpperCase()}',
        name: _selectedCategory.contains('Road')
            ? 'Roads & Infrastructure Engineering'
            : _selectedCategory.contains('Waste')
                ? 'Solid Waste Management'
                : _selectedCategory.contains('Water')
                    ? 'Water Supply & Sewerage Board'
                    : 'Municipal Administration',
        headOfficer: 'Er. Rajesh Patel (Zonal Chief)',
        slaHours: _isGrievance ? 48 : 72,
        icon: _selectedCategory.contains('Road')
            ? Icons.car_crash_rounded
            : _selectedCategory.contains('Waste')
                ? Icons.delete_outline_rounded
                : Icons.water_drop_outlined,
      ),
      ward: WardInfo(
        wardNumber: wardNum,
        wardName: _selectedWard,
        zone: 'Ahmedabad Municipal Corporation',
        wardOffice: 'AMC Sub-Civic Center',
        inspectorName: 'Municipal Inspector',
        phone: '079-27550000',
      ),
    );

    // Dispatch AddTicketEvent through MVVM TicketsBloc
    if (mounted) {
      context.read<TicketsBloc>().add(AddTicketEvent(newTicket));
    }

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    // Show Confirmation Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _isGrievance ? 'Grievance Registered' : 'Feedback Received',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thank you, ${_citizenNameController.text.trim()}! Your ${_isGrievance ? 'formal municipal complaint' : 'citizen suggestion'} has been logged into the AMC e-Governance system.',
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CivicColors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CivicColors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('OFFICIAL TRACKING NUMBER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: CivicColors.onSurfaceVariant)),
                  const SizedBox(height: 2),
                  Text('#${newTicket.ticketId}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CivicColors.primary)),
                  const SizedBox(height: 6),
                  Text('Ward: $_selectedWard', style: const TextStyle(fontSize: 11.5)),
                  Text('Estimated SLA: ${newTicket.department.slaHours} hours', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                  const Text('SMS / WhatsApp updates enabled', style: TextStyle(fontSize: 10.5, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _titleController.clear();
              _descController.clear();
              setState(() => _attachedPhoto = null);
              if (widget.onComplaintSubmitted != null) {
                widget.onComplaintSubmitted!();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CivicColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Done & Track Status', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CivicColors.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF031B33), CivicColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: CivicColors.primary.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 6)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.rate_review_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Citizen Grievance & Feedback',
                                style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              Text(
                                'Direct link to AMC Ward Engineers & Zonal Office',
                                style: TextStyle(fontSize: 11, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Toggle Pill: Complaint vs Suggestion
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _isGrievance = true),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: _isGrievance ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    'File Complaint',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5,
                                      color: _isGrievance ? CivicColors.primary : Colors.white70,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _isGrievance = false),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: !_isGrievance ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    'Feedback / Suggestion',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5,
                                      color: !_isGrievance ? CivicColors.primary : Colors.white70,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Category Selector
              const Text('Municipal Department / Service', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CivicColors.onSurface)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: CivicColors.outlineVariant.withValues(alpha: 0.35)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down_rounded, color: CivicColors.primary),
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Ward Selector
              const Text('Target Municipal Ward', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CivicColors.onSurface)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: CivicColors.outlineVariant.withValues(alpha: 0.35)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedWard,
                    isExpanded: true,
                    icon: const Icon(Icons.location_city_rounded, color: CivicColors.primary, size: 20),
                    items: _wards.map((w) => DropdownMenuItem(value: w, child: Text(w, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedWard = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Rating / Satisfaction (for Feedback mode)
              if (!_isGrievance) ...[
                const Text('Rate Current Municipal Service', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CivicColors.onSurface)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: CivicColors.outlineVariant.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final star = index + 1;
                      return IconButton(
                        icon: Icon(
                          star <= _starRating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: const Color(0xFFF59E0B),
                          size: 32,
                        ),
                        onPressed: () => setState(() => _starRating = star),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Title / Subject Input
              Text(_isGrievance ? 'Complaint Title / Short Summary' : 'Suggestion Title', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CivicColors.onSurface)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: _isGrievance ? 'e.g., Overflowing dumpster near Navrangpura crossroads' : 'e.g., Introduce dedicated bicycle lanes on Riverfront Road',
                  hintStyle: const TextStyle(fontSize: 12.5, color: CivicColors.onSurfaceVariant),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: CivicColors.outlineVariant.withValues(alpha: 0.35))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: CivicColors.outlineVariant.withValues(alpha: 0.35))),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),

              // Detailed Description
              const Text('Detailed Description & Location Landmark', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CivicColors.onSurface)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Please share specifics, street name, house/shop numbers, or suggestions for quick action...',
                  hintStyle: const TextStyle(fontSize: 12.5, color: CivicColors.onSurfaceVariant),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: CivicColors.outlineVariant.withValues(alpha: 0.35))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: CivicColors.outlineVariant.withValues(alpha: 0.35))),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please provide details' : null,
              ),
              const SizedBox(height: 16),

              // Photographic Evidence / Attachment
              const Text('Attach Photographic Evidence (Optional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CivicColors.onSurface)),
              const SizedBox(height: 8),
              if (_attachedPhoto != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      CivicPhotoRenderer(
                        photoUrl: _attachedPhoto!.photoUrl,
                        category: _selectedCategory,
                        title: _attachedPhoto!.title,
                        height: 140,
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                            onPressed: () => setState(() => _attachedPhoto = null),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickPhoto(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_rounded, size: 18),
                      label: const Text('Take Photo', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickPhoto(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_rounded, size: 18),
                      label: const Text('From Gallery', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitForm,
                  icon: _isSubmitting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Icon(_isGrievance ? Icons.send_rounded : Icons.thumb_up_rounded, size: 20),
                  label: Text(
                    _isSubmitting
                        ? 'Logging with AMC e-Governance...'
                        : _isGrievance
                            ? 'Submit Official Complaint'
                            : 'Send Citizen Feedback',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CivicColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 1,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
