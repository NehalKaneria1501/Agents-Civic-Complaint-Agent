# Agents-Civic-Complaint-Agent 🏛️📱

AI-powered Civic Issue Reporting & Complaint Management Agent built with Flutter.

Mock the municipal (AMC - Ahmedabad Municipal Corporation) system as a local reactive database with complete end-to-end AI agent tool calls:

- **Image Analysis (`analyze_civic_image`)**: Identifies road hazards, pothole severity, streetlight fixtures, and solid waste dumps with confidence scores.
- **Ward & Department Lookup (`lookup_ward_and_department`)**: Geospatial and area-based routing to the designated municipal ward and department with official SLA benchmarks.
- **Ticket Creation (`create_amc_ticket`)**: Automated civic ticket creation, tracking IDs, squad dispatch, and timeline generation.
- **Status Fetch (`fetch_ticket_status`)**: Real-time civic ledger queries and tracking.

---

## 🚀 Key Features

- **Resilient Multi-Source Photo Renderer**: Handles live camera captures, gallery files, offline fallback incident graphics, and network photos with HUD reticles and geotags.
- **Full Android Permissions**: Configured in `AndroidManifest.xml` for Camera, Photo Gallery (`READ_MEDIA_IMAGES`), Legacy Storage, GPS Geotagging, and Notifications.
- **Municipal Agent Chat**: Conversational interface with interactive AI diagnostic tool call visualization and timeline updates.
- **Onboarding & Permission Verification**: Dedicated permission configuration screen and civic dashboard.

---

## 🛠️ Getting Started

### Prerequisites

- Flutter SDK 3.13+ or higher
- Android Studio / VS Code with Flutter extension
- Android SDK 34 (API 34)

### Running the Project

```bash
# Get dependencies
flutter pub get

# Run on connected device or emulator
flutter run

# Run widget and integration tests
flutter test
```
