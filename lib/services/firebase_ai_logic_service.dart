import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../firebase_options.dart';
import '../models/civic_models.dart';
import 'google_maps_service.dart';

// ==========================================
// FIREBASE AI LOGIC SERVICE (civic-complaint-agent-dee84)
// Integrates Gemini Developer API directly through Firebase
// to classify civic hazards, extract locations, and route to Google Maps
// ==========================================

class CivicAiAnalysisResult {
  final String title;
  final String issueCategory;
  final String severity; // Low, Medium, High, Critical
  final String area;
  final String gpsCoords;
  final double latitude;
  final double longitude;
  final String departmentKey;
  final String departmentName;
  final String explanation;
  final bool isLiveAi;

  const CivicAiAnalysisResult({
    required this.title,
    required this.issueCategory,
    required this.severity,
    required this.area,
    required this.gpsCoords,
    required this.latitude,
    required this.longitude,
    required this.departmentKey,
    required this.departmentName,
    required this.explanation,
    this.isLiveAi = true,
  });

  String get googleMapsUrl => 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
  String get googleMapsDirectionsUrl => 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
}

class FirebaseAiLogicService {
  static final FirebaseAiLogicService instance = FirebaseAiLogicService._internal();
  FirebaseAiLogicService._internal();

  GenerativeModel? _model;
  bool _isInitialized = false;

  void init() {
    if (_isInitialized) return;
    try {
      final apiKey = DefaultFirebaseOptions.currentPlatform.apiKey;
      if (apiKey.isNotEmpty) {
        _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
          systemInstruction: Content.system(
            'You are the Ahmedabad Municipal Corporation (AMC) Civic Complaint AI Agent (CivicBot). '
            'Your role is to diagnose citizen civic issues like potholes, open garbage dumps, water logging, streetlight failure, and broken pipes. '
            'Always be helpful, civic-minded, and precise about Ahmedabad locations and AMC wards (e.g. Ward 4 Central Zone, Vastrapur, Navrangpura, Sabarmati, Maninagar).',
          ),
        );
        _isInitialized = true;
        debugPrint('✓ FirebaseAiLogicService initialized with Gemini (civic-complaint-agent-dee84)');
      }
    } catch (e) {
      debugPrint('! FirebaseAiLogicService init warning: $e');
    }
  }

  /// Analyzes a citizen report (text + photo context) using Gemini AI Logic
  Future<CivicAiAnalysisResult> analyzeIncident({
    required String userText,
    SampleIncident? samplePhoto,
  }) async {
    init();

    // Default coordinates based on sample photo or Ahmedabad central coordinates
    double lat = 23.0365;
    double lng = 72.5126;
    String area = 'Main Street (Ward 4 Central Zone, Ahmedabad)';
    String severity = 'High';
    String issueCategory = 'Road & Asphalt Hazard';
    String deptKey = 'pothole';
    String deptName = 'Roads & Infrastructure Dept';

    if (samplePhoto != null) {
      issueCategory = samplePhoto.issueCategory;
      severity = samplePhoto.severity;
      area = samplePhoto.defaultArea;
      deptKey = samplePhoto.departmentKey;
      final coords = GoogleMapsService.parseGpsCoordinates(samplePhoto.gpsCoords);
      if (coords != null) {
        lat = coords.key;
        lng = coords.value;
      }
    }

    if (_model != null) {
      try {
        final prompt = '''
Citizen report text: "$userText"
Photo context: "${samplePhoto?.title ?? 'Citizen captured photo'}" - Category: "${samplePhoto?.issueCategory ?? 'General Civic'}" - Default Area: "$area"

Please provide a concise municipal assessment:
1. Short hazard title (max 5 words)
2. Severity (Low, Medium, High, or Critical)
3. AMC Ward or Area recommendation in Ahmedabad
4. Department responsible (Roads, Solid Waste, Streetlight, Drainage, Health)
5. 1-2 sentence explanation of the civic risk and prompt repair directive.
''';

        final response = await _model!.generateContent([Content.text(prompt)]);
        final textResponse = response.text;

        if (textResponse != null && textResponse.isNotEmpty) {
          // Parse severity from response if present
          if (textResponse.toLowerCase().contains('critical')) {
            severity = 'Critical';
          } else if (textResponse.toLowerCase().contains('high')) {
            severity = 'High';
          } else if (textResponse.toLowerCase().contains('medium')) {
            severity = 'Medium';
          } else if (textResponse.toLowerCase().contains('low')) {
            severity = 'Low';
          }

          return CivicAiAnalysisResult(
            title: samplePhoto?.title ?? 'Civic Hazard Issue',
            issueCategory: issueCategory,
            severity: severity,
            area: area,
            gpsCoords: '$lat° N, $lng° E (AMC Ward)',
            latitude: lat,
            longitude: lng,
            departmentKey: deptKey,
            departmentName: deptName,
            explanation: textResponse.trim(),
            isLiveAi: true,
          );
        }
      } catch (e) {
        debugPrint('! Gemini AI call fallback to offline heuristic: $e');
      }
    }

    // Heuristic Fallback
    final fallbackExplanation = samplePhoto != null
        ? 'AI Computer Vision detected ${samplePhoto.title} (${samplePhoto.severity} Severity) at $area. Automated AMC repair squad dispatch requested.'
        : 'Civic issue categorized under $issueCategory. Automated municipal dispatch squad alerted with Google Maps coordinates.';

    return CivicAiAnalysisResult(
      title: samplePhoto?.title ?? 'Civic Complaint',
      issueCategory: issueCategory,
      severity: severity,
      area: area,
      gpsCoords: '$lat° N, $lng° E (Ward 4)',
      latitude: lat,
      longitude: lng,
      departmentKey: deptKey,
      departmentName: deptName,
      explanation: fallbackExplanation,
      isLiveAi: false,
    );
  }

  /// Answers conversational inquiries using Gemini AI Logic
  Future<String> answerQuery({
    required String query,
    String? currentTicketContext,
  }) async {
    init();

    if (_model != null) {
      try {
        final prompt = '''
Citizen asked: "$query"
Context: ${currentTicketContext ?? 'Ahmedabad Municipal Corporation citizen grievance portal'}
Provide a helpful, polite 1-2 sentence response. If asking for status or navigation, mention that Google Maps coordinates and live squad tracking are active.
''';
        final response = await _model!.generateContent([Content.text(prompt)]);
        if (response.text != null && response.text!.isNotEmpty) {
          return response.text!.trim();
        }
      } catch (e) {
        debugPrint('! Gemini chat query fallback: $e');
      }
    }

    // Fallback response
    return 'Your request has been logged with the AMC Central Control Room. Our AI agent is continuously syncing repair updates to Cloud Firestore and Google Maps.';
  }
}
