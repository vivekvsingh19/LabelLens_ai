# RevenueCat Setup Guide for LabelSafe AI

## ✅ Completed Implementation

The RevenueCat SDK has been integrated into your Flutter app. Here's what's ready:

- ✅ SDK installed (`purchases_flutter` & `purchases_ui_flutter`)
- ✅ Service layer with full API support
- ✅ Riverpod providers for state management
- ✅ Custom paywall screen
- ✅ Subscription management screen
- ✅ Premium widgets for feature gating
- ✅ Profile screen integration
- ✅ Routing configured

---

## 🚀 Next Steps

### 1. RevenueCat Dashboard Setup

1. **Go to [RevenueCat Dashboard](https://app.revenuecat.com/)**

2. **Create a new project** (if not already created):
   - Project name: `LabelSafe AI`
   - Add your apps (iOS & Android)

3. **Get your production API keys**:
   - Go to **Project Settings → API Keys**
   - Copy the **Public API Key** for each platform
   - Replace the test key in `.env`:
   ```
   REVENUECAT_API_KEY=your_production_api_key
   ```

---

### 2. App Store Connect (iOS)

1. **Create In-App Purchases**:
   - Go to [App Store Connect](https://appstoreconnect.apple.com/)
   - Select your app → **In-App Purchases** → **Manage**
   - Create **Auto-Renewable Subscriptions**:

   | Product ID | Type | Duration | 🌍 World | 🇮🇳 India |
   |------------|------|----------|----------|----------|
   | `labelsafe_monthly` | Auto-Renewable | 1 Month | $2.99 | ₹79 |
   | `labelsafe_yearly` | Auto-Renewable | 1 Year | $19.99 | ₹449 |
   | `labelsafe_lifetime` | Non-Consumable | Lifetime | $39.99 | ₹799 |

   > 💡 **Two-Tier Pricing**:
   > - **🌍 World**: $2.99 / $19.99 / $39.99 (standard international pricing)
   > - **🇮🇳 India**: ₹79 / ₹449 / ₹799 (localized affordable pricing)

2. **Create a Subscription Group**:
   - Name: `LabelSafe Pro`
   - Add monthly and yearly subscriptions to this group

3. **Set Regional Pricing**:
   - When creating products, click **Set Prices for All Territories**
   - Set **Base Price** in USD for all countries
   - **Override India (INR)** with custom lower prices:

   | Region | Monthly | Yearly | Lifetime |
   |--------|---------|--------|----------|
   | 🌍 All Countries (Default) | $2.99 | $19.99 | $39.99 |
   | 🇮🇳 India (Override) | ₹79 | ₹449 | ₹799 |

4. **Set up Shared Secret**:
   - Go to **App Information** → **App-Specific Shared Secret**
   - Generate and copy the secret
   - Add it to RevenueCat dashboard

---

### 3. Google Play Console (Android)

1. **Create Subscriptions**:
   - Go to [Google Play Console](https://play.google.com/console/)
   - Select your app → **Monetize** → **Products** → **Subscriptions**
   - Click **Create subscription**
   
   **First Subscription - Monthly**:
   - **Product ID**: `labelsafe_monthly`
   - **Name**: `LabelSafe AI Pro - Monthly`
   - **Description**: Unlimited product scans and advanced analysis
   - **Billing period**: Monthly (1 month)
   - **Create**
   
   **Second Subscription - Yearly**:
   - **Product ID**: `labelsafe_yearly`
   - **Name**: `LabelSafe AI Pro - Yearly`
   - **Description**: Unlimited product scans and advanced analysis (Best value!)
   - **Billing period**: Yearly (1 year)
   - **Create**

2. **Create In-App Product** (for lifetime):
   - Go to **In-app products** (not subscriptions)
   - Click **Create product**
   - **Product ID**: `labelsafe_lifetime`
   - **Name**: `LabelSafe AI Pro - Lifetime`
   - **Description**: One-time lifetime access to all features
   - **Create**

3. **Set Prices for Each Product**:
   
   **For `labelsafe_monthly`**:
   - Click on it → **Pricing**
   - Set **Default price**: $2.99
   - Click **India** → Uncheck "Auto-convert prices" → Set ₹79
   
   **For `labelsafe_yearly`**:
   - Click on it → **Pricing**
   - Set **Default price**: $19.99
   - Click **India** → Uncheck "Auto-convert prices" → Set ₹449
   
   **For `labelsafe_lifetime`**:
   - Click on it → **Pricing**
   - Set **Default price**: $39.99
   - Click **India** → Uncheck "Auto-convert prices" → Set ₹799

4. **Link to RevenueCat**:
   - Get your **License Key**:
     - Go to **Settings** → **API access** → **Your license key**
   - Go to [RevenueCat Dashboard](https://app.revenuecat.com/)
   - Select your project → **Project Settings** → **Apps** → **Android**
   - Add the License Key under **Google Play Console**
   - Add **Package name**: `io.labelsafe.ai`

---

### 4. Configure RevenueCat Products

1. **Add Products in RevenueCat**:
   - Go to **Products** in your RevenueCat project
   - Click **+ New Product** for each:
     - `labelsafe_monthly`
     - `labelsafe_yearly`
     - `labelsafe_lifetime`

2. **Create an Entitlement**:
   - Go to **Entitlements** → **+ New**
   - Identifier: `LabelSafe AI Pro`
   - Attach all three products to this entitlement

3. **Create an Offering**:
   - Go to **Offerings** → **+ New**
   - Identifier: `default`
   - Make it the **Current Offering**
   - Add packages:
     - `$rc_monthly` → `labelsafe_monthly`
     - `$rc_annual` → `labelsafe_yearly`
     - `$rc_lifetime` → `labelsafe_lifetime`

---

### 5. Configure Paywall (Optional)

RevenueCat offers a no-code Paywall builder:

1. Go to **Paywalls** in RevenueCat dashboard
2. Create a new paywall
3. Design it to match your app's branding
4. Attach it to your offering

To use the RevenueCat paywall instead of custom:
```dart
// In your code, call:
await RevenueCatService().presentPaywall();
```

---

### 6. Set Up Customer Center

1. Go to **Customer Center** in RevenueCat dashboard
2. Configure:
   - Support email
   - FAQ items
   - Cancellation flows
   - Feedback collection

The Customer Center is already integrated - users can access it from the Subscription screen.

---

### 7. Testing

#### Sandbox Testing (iOS)
1. Create a **Sandbox Tester** in App Store Connect
2. Sign out of App Store on device
3. Test purchases (won't charge real money)

#### Testing (Android)
1. Add **License Test Accounts** in Play Console
2. Publish app to Internal Testing track
3. Test purchases with test accounts

#### RevenueCat Sandbox Mode
- Your test API key (`test_...`) works in sandbox
- Switch to production key for release builds

---

### 8. Platform-Specific Configuration

#### iOS (Already configured by Flutter plugin)
Ensure `ios/Runner/Info.plist` has:
```xml
<key>SKAdNetworkItems</key>
<array>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>cstr6suwn9.skadnetwork</string>
  </dict>
</array>
```

#### Android (Already configured by Flutter plugin)
Ensure `android/app/build.gradle` has billing permission:
```gradle
android {
    defaultConfig {
        // ...
    }
}
```

---

### 9. Go Live Checklist

- [ ] Replace test API key with production key
- [ ] Products created in App Store Connect
- [ ] Products created in Google Play Console
- [ ] Products added to RevenueCat
- [ ] Entitlement "LabelSafe AI Pro" configured
- [ ] Offering "default" set as current
- [ ] Sandbox testing completed
- [ ] App submitted for review

---

## 📱 Usage in Your App

### Show Paywall
```dart
// Navigate to custom paywall
context.push('/paywall');

// Or show RevenueCat native paywall
await RevenueCatService().presentPaywall();

// Show only if user doesn't have premium
await RevenueCatService().presentPaywallIfNeeded();
```

### Check Premium Status
```dart
// In a widget
final hasPremium = ref.watch(hasPremiumAccessProvider);

// Or directly
final isPremium = await RevenueCatService().hasPremiumAccess();
```

### Gate Features
```dart
PremiumGate(
  featureId: 'unlimited_scans',
  child: UnlimitedScansFeature(),
  lockedMessage: 'Upgrade to unlock unlimited scans',
)
```

### Show Subscription Status
```dart
PremiumBadge(showIfFree: true)
```

### Track Free Tier Usage
```dart
RemainingScansWidget()
```

---

## 🔗 Helpful Links

- [RevenueCat Documentation](https://www.revenuecat.com/docs)
- [Flutter SDK Reference](https://www.revenuecat.com/docs/getting-started/installation/flutter)
- [Paywalls Guide](https://www.revenuecat.com/docs/tools/paywalls)
- [Customer Center Guide](https://www.revenuecat.com/docs/tools/customer-center)
- [Testing Guide](https://www.revenuecat.com/docs/test-and-launch/sandbox)
- [App Store Setup](https://www.revenuecat.com/docs/getting-started/entitlements/app-store)
- [Play Store Setup](https://www.revenuecat.com/docs/getting-started/entitlements/google-play)

---

## 🆘 Support

If you have issues:
1. Check RevenueCat dashboard for errors
2. Enable debug logging: `Purchases.setLogLevel(LogLevel.debug)`
3. Check the [RevenueCat Community](https://community.revenuecat.com/)
