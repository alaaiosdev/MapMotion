# MapMotion - Location Tracking iOS App

A SwiftUI-based iOS application that provides user authentication and real-time location tracking functionality.

## Features

- User authentication (login/registration) with local and Firebase storage
- Real-time location tracking using Core Location
- Google Maps integration for location visualization
- Movement path tracking and visualization
- Background location tracking
- Previous login history
- Secure local data storage

## Requirements

- iOS 15.0+
- Xcode 13.0+
- CocoaPods (for dependency management)
- Firebase account
- Google Maps API key

## Dependencies

- Firebase/Auth
- Firebase/Firestore
- GoogleMaps
- GooglePlaces

## Installation

1. Clone the repository:
```bash
git clone https://github.com/alaaiosdev/MapMotion.git
cd MapMotion
```

2. Install dependencies using CocoaPods:
```bash
pod install
```

3. Open `MapMotion.xcworkspace` in Xcode

4. Add your Google Maps API key in `Info.plist`

5. Configure Firebase:
   - Add your `GoogleService-Info.plist` to the project
   - Follow Firebase setup instructions in the Firebase console

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture pattern and is organized into the following components:

### Core Modules
- **Authentication**: Handles user login, registration, and session management
- **Location Services**: Manages real-time location tracking and updates
- **Storage**: Handles local and remote data persistence
- **Map Services**: Manages map rendering and location visualization

### Key Components
- **Views**: SwiftUI views for UI components
- **ViewModels**: Business logic and state management
- **Models**: Data models and entities
- **Services**: Core functionality implementations

## Privacy & Permissions

The app requires the following permissions:
- Location Services (Always/When In Use)
- Background App Refresh

These permissions are essential for tracking functionality and should be properly requested from users.

## Security

- User credentials are securely stored using Keychain
- Location data is encrypted when stored locally
- Firebase security rules are implemented for data protection

## Performance Considerations

- Optimized location tracking intervals
- Efficient battery usage management
- Background task handling
- Data caching strategies

## Error Handling

The app implements comprehensive error handling for:
- Network connectivity issues
- Location services availability
- Authentication failures
- Data persistence errors

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request
