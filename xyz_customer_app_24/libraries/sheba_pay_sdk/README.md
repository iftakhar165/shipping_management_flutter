# Latest Feature Card Widget

A professional and responsive Flutter widget for displaying latest features and updates in the Sheba Pay SDK.

## Features

- **Dynamic sizing**: Automatically adapts to different screen sizes
- **Flexible design**: Supports icons, badges, titles, descriptions, and actions
- **Grid and List layouts**: Can be displayed in both grid and list formats
- **Consistent theming**: Uses the existing AppTheme colors and styling
- **Interactive**: Support for tap callbacks
- **New badge indicator**: Optional "NEW" badge for highlighting new features
- **Predefined templates**: Ready-to-use payment feature cards

## Usage

### Single Feature Card

```dart
LatestFeatureCard(
  title: 'Enhanced Security',
  description: 'We\'ve upgraded our security system with biometric authentication and advanced encryption.',
  icon: Icons.security,
  iconColor: AppTheme.successColor,
  badgeText: 'Security',
  badgeColor: AppTheme.successColor,
  isNew: true,
  onTap: () {
    // Handle tap
  },
)
```

### List of Feature Cards

```dart
LatestFeatureCardList(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  features: PredefinedFeatureCards.paymentFeatures,
)
```

### Grid of Feature Cards

```dart
LatestFeatureCardGrid(
  features: [
    LatestFeatureCardData(
      title: 'QR Payments',
      description: 'Scan and pay instantly',
      icon: Icons.qr_code_scanner,
      iconColor: AppTheme.primaryColor,
    ),
    // More features...
  ],
  crossAxisCount: 2,
  childAspectRatio: 0.85,
)
```

## Properties

### LatestFeatureCard

| Property | Type | Description | Required |
|----------|------|-------------|----------|
| `title` | `String` | The main title of the feature | ✅ |
| `description` | `String` | Description text | ✅ |
| `icon` | `IconData` | Icon to display | ✅ |
| `iconColor` | `Color?` | Color for the icon (defaults to primaryColor) | ❌ |
| `badgeText` | `String?` | Text for the badge | ❌ |
| `badgeColor` | `Color?` | Color for the badge | ❌ |
| `onTap` | `VoidCallback?` | Callback when card is tapped | ❌ |
| `isNew` | `bool` | Whether to show NEW indicator | ❌ |
| `imageUrl` | `String?` | Optional image URL (for future use) | ❌ |

### LatestFeatureCardData

Used for creating lists and grids of feature cards with the same properties as `LatestFeatureCard`.

## Responsive Design

The widget automatically adjusts:
- Card width based on screen width with 16px margins
- Icon size as 12% of screen width
- Title font size as 4.5% of screen width
- Description font size as 3.5% of screen width
- Dynamic padding based on screen width

## Predefined Features

The widget includes predefined payment features:

```dart
PredefinedFeatureCards.paymentFeatures
```

Includes:
- Quick Pay (with "Fast" badge and NEW indicator)
- Secure Wallet (with "Safe" badge)
- Bill Payments (with "Auto" badge)
- Money Transfer (with "Free" badge and NEW indicator)

## Theme Integration

The widget uses colors from `AppTheme`:
- `AppTheme.primaryColor` - Primary blue (#007AFF)
- `AppTheme.successColor` - Green (#34C759)
- `AppTheme.warningColor` - Orange (#FF9500)
- `AppTheme.accentColor` - Teal (#00D4AA)
- `AppTheme.textPrimary` - Primary text color
- `AppTheme.textSecondary` - Secondary text color
- `AppTheme.cardColor` - Card background
- `AppTheme.cardShadow` - Card shadow styling

## Demo Screen

A complete demo screen is available at:
`xyz_customer_app_24/libraries/sheba_pay_sdk/lib/screens/spay_home/presentation/spay_home_demo_screen.dart`

This can be accessed via the dashboard "Sheba Pay Demo" button or by navigating to the `/spay-demo` route.