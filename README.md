QR Hub

A modern Flutter application for generating, scanning, saving, and managing QR codes with a clean and user-friendly interface.


Project Overview
QR Hub is a Flutter-based QR utility application that allows users to:
* Generate QR codes from text or URLs
* Scan QR codes using the device camera
* Save generated and scanned QR records
* Export and share QR codes
* Manage QR history
* Switch between Light and Dark themes
* View exported QR images in a visual album
The application was built with a focus on clean UI, smooth user experience, reusable widgets, and maintainable Flutter architecture.


Setup Instructions
1. Clone the Repository
git clone https://github.com/NathanThomas91/QR-HUB.git

2. Navigate to Project Folder
cd QR-HUB

3. Install Dependencies
flutter pub get

4. Run the Application
flutter run


Packages Used

| Package            | Purpose                             |
| ------------------ | ----------------------------------- |
| provider           | State management for theme handling |
| mobile_scanner     | QR code scanning using camera       |
| qr_flutter         | QR code generation                  |
| shared_preferences | Local data storage                  |
| screenshot         | Capture QR code images              |
| share_plus         | Share QR images/files               |
| path_provider      | Access device storage paths         |


Features Implemented

1.QR Code Generator
* Generate QR codes from text or links
* Save generated QR codes to history
* Export QR codes as images
* Share QR codes directly

2.QR Code Scanner
* Real-time QR scanning
* Automatic duplicate prevention
* Auto-save scanned records
* Animated success feedback

3.History Management
* View scanned/generated QR history
* Delete individual records
* Clear all history
* Export history as CSV

4.Theme Support
* Light Mode
* Dark Mode
* System Theme support

5.QR Album
* Visual gallery for exported QR images
* Full image preview support

6.UI/UX Features
* Smooth animations
* Reusable custom widgets
* Empty state handling
* Modern card-based UI
* Responsive layouts


# Author
Nathan Thomas Chacko
