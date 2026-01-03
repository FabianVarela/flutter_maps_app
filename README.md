# Flutter Maps App

Flutter application featuring Google Maps integration with real-time location tracking, place search, and custom map
styling. Built with Bloc pattern for state management and supporting Android, iOS, and Web platforms.

## Prerequisites

Before getting started, make sure you have the following installed:

- **Flutter SDK**: >=3.10.0 <4.0.0
- **Dart SDK**: >=3.10.0 <4.0.0
- **IDE**: VSCode or Android Studio with Flutter extensions
- **Google Cloud Account**: Required for Google Maps API access
- **Platforms**:
    - For iOS: Xcode (macOS only)
    - For Android: Android Studio or Android SDK
    - For Web: Google Chrome

## Initial Setup

### 1. Clone the repository

```bash
git clone <repository-url>
cd flutter_maps_app
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Google Maps API

This project requires Google Maps API keys for Android, iOS, and Web.

#### Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the following APIs:
    - Maps SDK for Android
    - Maps SDK for iOS
    - Maps JavaScript API
    - Places API
    - Geolocation API

#### Generate API Keys

1. Go to **APIs & Services** > **Credentials**
2. Click **Create Credentials** > **API Key**
3. Create separate API keys for each platform (recommended) or use one key for all
4. Restrict each API key to specific APIs and platforms for security

#### Configure Android

1. Restrict the Android API key to:
    - Maps SDK for Android
    - Places API
    - Android apps (add your app's SHA-1 fingerprint)

#### Configure iOS

1. Restrict the iOS API key to:
    - Maps SDK for iOS
    - Places API
    - iOS apps (add your bundle identifier)

#### Configure Web

1. Open `web/index.html`
2. Add the Google Maps JavaScript API script with your API key:
   ```html
   <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_WEB_API_KEY_HERE"></script>
   ```
3. Restrict the Web API key to:
    - Maps JavaScript API
    - Places API
    - HTTP referrers (add your website URLs)

### 4. Configure Location Permissions

#### Android

The necessary permissions are already configured in `android/app/src/main/AndroidManifest.xml`:

```xml

<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

#### iOS

Add location permissions to `ios/Runner/Info.plist`:

```xml

<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to your location to show your position on the map</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs access to your location to track your position</string>
```

### 5. Generate assets

The project uses `flutter_gen` to generate type-safe access to assets:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Assets are located at:

- `assets/map_styles/` - Custom map style JSON files
- `assets/images/` - Image assets

### 6. Generate localization files

```bash
flutter gen-l10n
```

## Development

### Run the application

```bash
flutter run
```

### Run on specific platform

```bash
# Android
flutter run -d android

# iOS
flutter run -d iPhone

# Web
flutter run -d chrome
```

### Build for production

```bash
# Android (App Bundle)
flutter build appbundle

# Android (APK)
flutter build apk

# iOS
flutter build ios

# Web
flutter build web
```

## Project Structure

```
lib/
├── core/                   # Core application infrastructure
│   ├── gen/               # Generated assets (flutter_gen)
│   ├── theme/             # App theming
│   └── utils/             # Utilities and helpers
├── Bloc/                   # Bloc state management
│   ├── location_Bloc/     # User location tracking
│   ├── map_Bloc/          # Map state management
│   └── places_Bloc/       # Places search
├── data/                   # Data layer
│   ├── models/            # Data models
│   ├── repositories/      # Data repositories
│   └── services/          # External services (Google Maps API)
├── ui/                     # UI layer
│   ├── pages/             # Application pages
│   └── widgets/           # Reusable widgets
└── main.dart              # Application entry point
assets/
├── map_styles/            # Custom map styles (JSON)
└── images/                # Image assets
```

## Features

### Google Maps Integration

- **Interactive Map**: Full-featured Google Maps with gestures support
- **Map Controls**: Zoom, compass, and map type controls
- **Custom Markers**: Add custom markers with info windows
- **Polylines & Polygons**: Draw routes and areas on the map
- **Map Styling**: Apply custom map styles (light, dark, retro, etc.)
- **Map Types**: Switch between normal, satellite, hybrid, and terrain views

### Location Services

- **Real-time Location**: Track user's current location
- **Location Updates**: Continuous location tracking
- **Location Permissions**: Handle location permission requests
- **GPS Accuracy**: Display location accuracy radius
- **My Location Button**: Quick navigation to current position
- **Background Tracking**: Continue tracking in background (optional)

### Places Search

- **Place Search**: Search for places using Google Places API
- **Autocomplete**: Real-time search suggestions
- **Place Details**: View detailed information about places
- **Nearby Places**: Find nearby points of interest
- **Place Categories**: Filter by category (restaurants, gas stations, etc.)
- **Custom Markers**: Display search results on map

### Map Customization

- **Custom Styles**: Multiple pre-defined map styles
- **Style Switcher**: Easy switching between map styles
- **Custom Markers**: Icon customization for different marker types
- **Info Windows**: Custom info window designs

### User Experience

- **Smooth Animations**: Animated camera movements
- **Loading States**: Skeleton loaders and progress indicators
- **Error Handling**: User-friendly error messages
- **Offline Support**: Basic functionality without internet
- **State Persistence**: Remember last map position and settings
- **Responsive Design**: Works on phones and tablets

## Bloc Architecture

### Location Bloc

Manages user location tracking:

- `LocationRequested`: Request current location
- `LocationUpdated`: Continuous location updates
- `LocationPermissionChanged`: Handle permission changes
- `LocationServiceStatusChanged`: Track GPS service status

### Map Bloc

Manages map state and interactions:

- `MapInitialized`: Initialize map with settings
- `MapStyleChanged`: Apply custom map style
- `MapTypeChanged`: Switch map type (normal, satellite, etc.)
- `CameraPositionChanged`: Update camera position
- `MarkerAdded`: Add marker to map
- `PolylineAdded`: Add route/path to map

### Places Bloc

Handles place search functionality:

- `PlacesSearchRequested`: Search for places
- `PlaceSelected`: Show details for selected place
- `NearbyPlacesRequested`: Find nearby places
- `AutocompleteQueryChanged`: Update search suggestions

## Google Maps API

### Maps SDK

- **Android**: Uses Google Maps SDK for Android
- **iOS**: Uses Google Maps SDK for iOS
- **Web**: Uses Google Maps JavaScript API

### Places API

Search and autocomplete functionality:

```
GET https://maps.googleapis.com/maps/api/place/autocomplete/json?input={query}&key={API_KEY}&types={types}&location={lat,lng}&radius={radius}
```

### Geocoding API

Convert addresses to coordinates:

```
GET https://maps.googleapis.com/maps/api/geocode/json?address={address}&key={API_KEY}
```

## Map Styles

Custom map styles are defined in JSON format in `assets/map_styles/`. Each style file follows
the [Snazzy Maps](https://snazzymaps.com/) format.

### Available Styles

1. **night_blue_mode.json** - Grayscale monochrome style
2. **night_mode.json** - Vintage map appearance
3. **personal_mode.json** - Dark theme for low-light environments
4. **uber_mode.json** - High contrast night mode

## Testing

### Run all tests

```bash
flutter test
```

### Run tests with coverage

```bash
flutter test --coverage
```

### View coverage report

```bash
# Generate coverage report
genhtml coverage/lcov.info -o coverage/

# Open coverage report in browser
open coverage/index.html
```

### Run specific test file

```bash
flutter test test/path/to/test_file.dart
```

## Code Quality

### Run code analysis

The project uses `very_good_analysis` to maintain code quality:

```bash
flutter analyze
```

### Format code

```bash
flutter format .
```

### Generate code

For assets and localization:

```bash
# Generate assets
flutter pub run build_runner build --delete-conflicting-outputs

# Watch for changes and auto-generate
flutter pub run build_runner watch --delete-conflicting-outputs

# Generate localization
flutter gen-l10n
```

## Main Dependencies

### Maps & Location

- **google_maps_flutter**: Google Maps SDK integration
- **geolocator**: Location services and permissions
- **google_maps_webservice**: Google Maps Web Services API

### State Management & Architecture

- **flutter_Bloc**: Bloc pattern implementation
- **Bloc**: Core Bloc library
- **equatable**: Value equality for Bloc states
- **Bloc_concurrency**: Advanced Bloc concurrency control

### Data Persistence

- **shared_preferences**: Local key-value storage

### Utilities

- **stream_transform**: Stream transformation utilities

### Dev Dependencies

- **build_runner**: Code generation
- **flutter_gen_runner**: Type-safe asset generation
- **very_good_analysis**: Strict lint rules

## Location Permissions

### Android Permission Levels

The app requests the following location permissions:

- `ACCESS_FINE_LOCATION`: Precise location from GPS
- `ACCESS_COARSE_LOCATION`: Approximate location from network

### iOS Permission Levels

- **When In Use**: Location access while app is in foreground
- **Always**: Location access even when app is in background (if needed)

### Web Geolocation

Web uses browser's Geolocation API, which prompts user for permission automatically.

## Troubleshooting

### Google Maps not displaying

1. **Check API Key**: Verify API key is correctly configured
2. **Enable APIs**: Ensure required APIs are enabled in Google Cloud Console
3. **Billing**: Verify billing is enabled for your Google Cloud project
4. **Restrictions**: Check API key restrictions aren't Blocking requests
5. **Platform**: Confirm API key is configured for the correct platform

### Location not working

#### Android

- Verify location permissions in `AndroidManifest.xml`
- Check device GPS is enabled
- Grant location permission in app settings
- Test on physical device (emulator GPS may be unreliable)

#### iOS

- Check `Info.plist` has location usage descriptions
- Verify location permissions granted in iOS Settings
- Test on physical device for best results

#### Web

- Use HTTPS (required for geolocation on web)
- Allow location permission in browser
- Check browser console for geolocation errors

### Map shows gray screen

- Verify API key is valid
- Check internet connection
- Ensure Maps SDK is enabled for your platform
- Check for JavaScript errors (Web)
- Verify billing is enabled

### Places search not working

- Enable Places API in Google Cloud Console
- Check API key has Places API access
- Verify internet connection
- Check API quota and billing

### "API key not valid" error

- Copy API key exactly (no extra spaces)
- Check API key restrictions match your app
- Verify correct API is enabled
- Try creating a new unrestricted key for testing

### iOS build fails

```bash
flutter clean
cd ios
pod install
pod update
cd ..
flutter build ios
```

### Android build fails

```bash
flutter clean
cd android
./gradlew clean
cd ..
flutter build apk
```

### Asset generation fails

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Location permission denied

Handle permission denial gracefully:

- Show explanation dialog
- Direct user to app settings
- Provide fallback functionality
- Test permission flows thoroughly

## Performance Optimization

This app implements several performance optimizations:

### Map Performance

- **Marker Clustering**: Group nearby markers to reduce clutter
- **Visible Region**: Only render markers in visible area
- **Lite Mode**: Use lite mode for static maps
- **Zoom-based Markers**: Show/hide markers based on zoom level

## Architecture

### Bloc Pattern

The app follows the Bloc (Business Logic Component) pattern:

- **UI**: Widgets that display data and emit events
- **Bloc**: Business logic that processes events and emits states
- **Repository**: Data layer that communicates with APIs and services
- **Services**: External service integrations (Google Maps, Location)

### Data Flow

1. User interacts with map (pan, zoom, search)
2. UI emits event to appropriate Bloc
3. Bloc processes event and calls repository/service
4. Service interacts with Google Maps API or device GPS
5. Repository returns data to Bloc
6. Bloc emits new state
7. UI rebuilds to reflect changes

### Service Layer

- **GoogleMapsService**: Wrapper for Google Maps Web Services
- **LocationService**: Handles device location tracking
- **PlacesService**: Place search and autocomplete
- **GeocodeService**: Address to coordinate conversion

## Security Best Practices

### API Key Security

- **Restrict Keys**: Always restrict API keys to specific APIs and platforms
- **Separate Keys**: Use different keys for dev/staging/production
- **Don't Commit**: Never commit API keys to version control
- **Environment Variables**: Use environment variables or secret management
- **Rotation**: Regularly rotate API keys
- **Monitoring**: Monitor API usage for anomalies

## Testing Strategy

### Unit Tests

- Bloc event/state testing with Bloc_test
- Repository method testing
- Service integration testing
- Model validation testing

### Widget Tests

- Widget rendering tests
- User interaction tests
- Map widget testing
- State change verification

## License

[Include license information here]
