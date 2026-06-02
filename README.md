QR Hub
A modern Flutter application for generating, scanning, saving, and managing QR codes with a clean UI and smooth user experience.


Features
1.QR Code Generation
* Generate QR codes from text or URLs
* Save generated QR codes to history
* Export QR codes as images
* Share QR codes directly

2.QR Code Scanning
* Real-time QR scanning using device camera
* Automatic duplicate prevention
* Instant scan result preview
* Auto-save scanned codes to history

3.History Management
* View generated and scanned QR history
* Delete individual records
* Clear entire history
* Export history as CSV

4.Theme Support
* Light Mode
* Dark Mode
* System Theme support

5.QR Album
* Visual gallery for exported QR images
* Preview saved QR images


Tech Stack
* Flutter
* Dart
* Provider (State Management)
* SharedPreferences (Local Storage)


Packages Used
mobile_scanner
provider
qr_flutter
screenshot
share_plus
shared_preferences
path_provider


Project Structure
lib/
├── models/
│   └── history_model.dart
│
├── screens/
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   ├── scanner_screen.dart
│   ├── generate_qr_screen.dart
│   └── history_screen.dart
│
├── services/
│   └── storage_service.dart
│
├── utils/
│   └── constants.dart
│
├── widgets/
│   └── custom_button.dart
│
└── main.dart


Installation
1. Clone the repository
git clone <your-repository-link>

2. Navigate to project folder
cd qr_code_app

3. Install dependencies
flutter pub get

4. Run the app
flutter run


Future Improvements
* Better local database support using Hive/Isar
* QR customization (colors, logo embedding)
* Search and filter history
* Batch QR generation
* Cloud sync support
* Improved animation system


Learning Outcomes
This project helped in understanding:
* Flutter widget architecture
* State management using Provider
* Local storage handling
* File management
* QR generation and scanning
* UI/UX consistency
* Animation handling
* Reusable widget design


Author
Nathan Thomas Chacko
