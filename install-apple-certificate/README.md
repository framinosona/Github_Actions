# 🍎 Apple Certificate Installation Action

A comprehensive GitHub Action for installing Apple certificates and provisioning profiles in macOS workflows with secure keychain management and flexible configuration options.

## ✨ Features

- 🔒 **Secure Certificate Installation** - Install Apple development/distribution certificates safely
- 📱 **Provisioning Profile Management** - Install and configure iOS/macOS provisioning profiles
- 🔑 **Keychain Management** - Create and configure temporary keychains with proper permissions
- 🛡️ **Security-First Design** - Secure handling of certificates, passwords, and private keys
- 🔧 **Flexible Input Options** - Support for base64 data, file paths, and multiple certificate types
- 📊 **Detailed Outputs** - Certificate fingerprints, profile UUIDs, and keychain information
- 🧹 **Automatic Cleanup** - Configurable keychain cleanup with secure file deletion
- 📋 **Comprehensive Validation** - Input validation and certificate verification

## 🚀 Basic Usage

Install a certificate from base64 encoded data:

```yaml
- name: "Install Apple Certificate"
  uses: laerdal/github_actions/install-apple-certificate@main
  with:
    certificate-data: ${{ secrets.APPLE_CERTIFICATE_DATA }}
    certificate-password: ${{ secrets.APPLE_CERTIFICATE_PASSWORD }}
```

```yaml
- name: "Install certificate and provisioning profile"
  uses: laerdal/github_actions/install-apple-certificate@main
  with:
    certificate-data: ${{ secrets.IOS_DISTRIBUTION_CERTIFICATE }}
    certificate-password: ${{ secrets.IOS_CERTIFICATE_PASSWORD }}
    provisioning-profile-data: ${{ secrets.IOS_PROVISIONING_PROFILE }}
    certificate-type: "distribution"
```

```yaml
- name: "Install from files"
  uses: laerdal/github_actions/install-apple-certificate@main
  with:
    certificate-path: "certificates/ios_distribution.p12"
    certificate-password: ${{ secrets.CERTIFICATE_PASSWORD }}
    provisioning-profile-path: "profiles/app_store.mobileprovision"
```

## 🔧 Advanced Usage

Full configuration with all available options:

```yaml
- name: "Complete iOS setup"
  uses: laerdal/github_actions/install-apple-certificate@main
  with:
    certificate-data: ${{ secrets.IOS_DISTRIBUTION_CERTIFICATE }}
    certificate-password: ${{ secrets.IOS_CERTIFICATE_PASSWORD }}
    provisioning-profile-data: ${{ secrets.IOS_PROVISIONING_PROFILE }}
    keychain-name: "ios-build.keychain"
    keychain-password: ${{ secrets.KEYCHAIN_PASSWORD }}
    delete-keychain: "false"
    certificate-type: "distribution"
    team-id: "ABCDEF1234"
    allow-codesign-keychain-access: "true"
    show-summary: "true"
```

## 🔐 Permissions Required

This action requires standard repository permissions:

```yaml
permissions:
  contents: read  # Required to checkout repository code
```

## 🏗️ CI/CD Example

Complete workflow for iOS app building with certificate installation:

```yaml
name: "Build iOS App"

on:
  push:
    branches: ["main"]
    tags: ["v*"]
  pull_request:
    branches: ["main"]

permissions:
  contents: read

jobs:
  build-ios:
    runs-on: macos-latest

    steps:
      - name: "📥 Checkout repository"
        uses: actions/checkout@v4

      - name: "🍎 Install Apple Certificate"
        id: certificate
        uses: laerdal/github_actions/install-apple-certificate@main
        with:
          certificate-data: ${{ secrets.IOS_DISTRIBUTION_CERTIFICATE }}
          certificate-password: ${{ secrets.IOS_CERTIFICATE_PASSWORD }}
          provisioning-profile-data: ${{ secrets.IOS_PROVISIONING_PROFILE }}
          certificate-type: "distribution"
          team-id: "ABCDEF1234"
          keychain-name: "build.keychain"
          delete-keychain: "false"
          show-summary: "true"

      - name: "🔧 Setup Xcode"
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: latest-stable

      - name: "📦 Install dependencies"
        run: |
          cd ios
          pod install --repo-update

      - name: "🔨 Build iOS app"
        run: |
          xcodebuild archive \
            -workspace MyApp.xcworkspace \
            -scheme MyApp \
            -configuration Release \
            -archivePath MyApp.xcarchive \
            CODE_SIGN_IDENTITY="${{ steps.certificate.outputs.certificate-name }}" \
            PROVISIONING_PROFILE_SPECIFIER="${{ steps.certificate.outputs.provisioning-profile-uuid }}" \
            DEVELOPMENT_TEAM="${{ steps.certificate.outputs.team-id }}" \
            -allowProvisioningUpdates

      - name: "📦 Export IPA"
        run: |
          xcodebuild -exportArchive \
            -archivePath MyApp.xcarchive \
            -exportPath ./build \
            -exportOptionsPlist ExportOptions.plist

      - name: "📤 Upload build artifacts"
        uses: actions/upload-artifact@v4
        with:
          name: "ios-app-${{ github.sha }}"
          path: ./build/*.ipa

      - name: "🧹 Cleanup keychain"
        if: always()
        run: |
          security delete-keychain "${{ steps.certificate.outputs.keychain-path }}" || true
```

## 📋 Inputs

### Required Inputs

| Input | Description | Example |
|-------|-------------|---------|
| `certificate-password` | Password for the certificate | `${{ secrets.CERT_PASSWORD }}` |

### Certificate Inputs (one required)

| Input | Description | Default | Example |
|-------|-------------|---------|---------|
| `certificate-data` | Base64 encoded certificate (.p12) | `''` | `${{ secrets.APPLE_CERT_DATA }}` |
| `certificate-path` | Path to certificate file | `''` | `certs/distribution.p12` |

### Optional Inputs

| Input | Description | Default | Example |
|-------|-------------|---------|---------|
| `provisioning-profile-data` | Base64 encoded provisioning profile | `''` | `${{ secrets.PROFILE_DATA }}` |
| `provisioning-profile-path` | Path to provisioning profile file | `''` | `profiles/app.mobileprovision` |
| `keychain-name` | Name for temporary keychain | `build.keychain` | `ios-build.keychain` |
| `keychain-password` | Password for temporary keychain | `build-keychain-password` | `secure-password` |
| `delete-keychain` | Delete keychain after installation | `true` | `false` |
| `certificate-type` | Certificate type | `development` | `distribution` |
| `team-id` | Apple Developer Team ID | `''` | `ABCDEF1234` |
| `allow-codesign-keychain-access` | Allow codesign to access keychain | `true` | `false` |
| `show-summary` | Show action summary | `true` | `false` |

### Certificate Types

- `development` - Development certificates for testing
- `distribution` - Distribution certificates for App Store/Ad Hoc
- `developer-id` - Developer ID certificates for macOS distribution

## 📤 Outputs

| Output | Description | Example |
|--------|-------------|---------|
| `keychain-path` | Path to the created keychain | `/Users/runner/Library/Keychains/build.keychain-db` |
| `certificate-name` | Name of installed certificate | `iPhone Distribution: My Company` |
| `certificate-sha1` | SHA1 fingerprint of certificate | `1234567890ABCDEF...` |
| `provisioning-profile-name` | Name of installed profile | `My App Store Profile` |
| `provisioning-profile-uuid` | UUID of installed profile | `12345678-1234-1234-1234-123456789012` |
| `team-id` | Team ID from certificate or input | `ABCDEF1234` |

## 🔗 Related Actions

| Action | Purpose | Repository |
|--------|---------|------------|
| 🔢 **generate-version** | Version generation for builds | `laerdal/github_actions/generate-version` |
| 🏷️ **git-tag** | Create build tags | `laerdal/github_actions/git-tag` |
| 🚀 **github-release** | Create releases with binaries | `laerdal/github_actions/github-release` |

## 💡 Examples

### Complete iOS App Build Pipeline

```yaml
- name: "Install development certificate"
  uses: laerdal/github_actions/install-apple-certificate@main
  with:
    certificate-data: ${{ secrets.IOS_DEV_CERTIFICATE }}
    certificate-password: ${{ secrets.IOS_CERT_PASSWORD }}
    provisioning-profile-data: ${{ secrets.IOS_DEV_PROFILE }}
    certificate-type: "development"
    keychain-name: "dev.keychain"

- name: "Install distribution certificate"
  uses: laerdal/github_actions/install-apple-certificate@main
  with:
    certificate-data: ${{ secrets.IOS_DIST_CERTIFICATE }}
    certificate-password: ${{ secrets.IOS_CERT_PASSWORD }}
    provisioning-profile-data: ${{ secrets.IOS_DIST_PROFILE }}
    certificate-type: "distribution"
    keychain-name: "dist.keychain"
```

### macOS App Development

```yaml
- name: "Install macOS developer certificate"
  uses: laerdal/github_actions/install-apple-certificate@main
  with:
    certificate-data: ${{ secrets.MACOS_DEVELOPER_CERTIFICATE }}
    certificate-password: ${{ secrets.MACOS_CERT_PASSWORD }}
    certificate-type: "developer-id"
    team-id: "ABCDEF1234"

- name: "Build and sign macOS app"
  run: |
    xcodebuild archive \
      -project MyMacApp.xcodeproj \
      -scheme MyMacApp \
      -configuration Release \
      -archivePath MyMacApp.xcarchive \
      CODE_SIGN_IDENTITY="Developer ID Application: My Company"
```

### Persistent Keychain Setup

```yaml
- name: "Setup persistent keychain"
  id: keychain
  uses: laerdal/github_actions/install-apple-certificate@main
  with:
    certificate-data: ${{ secrets.CERTIFICATE_DATA }}
    certificate-password: ${{ secrets.CERTIFICATE_PASSWORD }}
    keychain-name: "persistent-build.keychain"
    delete-keychain: "false"

- name: "Build app with persistent keychain"
  run: |
    # Your build commands here
    xcodebuild -workspace MyApp.xcworkspace \
      -scheme MyApp \
      -configuration Release

- name: "Manual keychain cleanup"
  if: always()
  run: |
    security delete-keychain "${{ steps.keychain.outputs.keychain-path }}" || true
```

### Multi-Certificate Installation

```yaml
- name: "Install development certificate"
  uses: laerdal/github_actions/install-apple-certificate@main
  with:
    certificate-data: ${{ secrets.DEV_CERTIFICATE }}
    certificate-password: ${{ secrets.DEV_CERT_PASSWORD }}
    provisioning-profile-data: ${{ secrets.DEV_PROFILE }}
    certificate-type: "development"
    keychain-name: "dev.keychain"
    delete-keychain: "false"

- name: "Install distribution certificate"
  uses: laerdal/github_actions/install-apple-certificate@main
  with:
    certificate-data: ${{ secrets.DIST_CERTIFICATE }}
    certificate-password: ${{ secrets.DIST_CERT_PASSWORD }}
    provisioning-profile-data: ${{ secrets.DIST_PROFILE }}
    certificate-type: "distribution"
    keychain-name: "dist.keychain"
    delete-keychain: "false"
```

### Environment-Specific Certificates

```yaml
- name: "Install certificate for environment"
  uses: laerdal/github_actions/install-apple-certificate@main
  with:
    certificate-data: ${{ github.ref == 'refs/heads/main' && secrets.PRODUCTION_CERT || secrets.DEVELOPMENT_CERT }}
    certificate-password: ${{ secrets.CERTIFICATE_PASSWORD }}
    provisioning-profile-data: ${{ github.ref == 'refs/heads/main' && secrets.PRODUCTION_PROFILE || secrets.DEVELOPMENT_PROFILE }}
    certificate-type: ${{ github.ref == 'refs/heads/main' && 'distribution' || 'development' }}
```

## 📱 Requirements

### Prerequisites

- **macOS runner** - This action only works on macOS runners
- **Apple Developer Account** - Valid certificates and provisioning profiles
- **GitHub Secrets** - Securely store certificates and passwords

### Dependencies

- **macOS Security Framework** - Built-in macOS tools (security, plutil)
- **OpenSSL** - For certificate information extraction (pre-installed on macOS)

### Supported Platforms

- ✅ macOS (macos-latest, macos-13, macos-12)
- ❌ Linux (not supported)
- ❌ Windows (not supported)

## 🔐 Security Best Practices

### Storing Certificates and Passwords

**Never commit certificates or passwords to your repository.** Always use GitHub Secrets:

```yaml
# ✅ Secure - using secrets
certificate-data: ${{ secrets.APPLE_CERTIFICATE_DATA }}
certificate-password: ${{ secrets.APPLE_CERTIFICATE_PASSWORD }}

# ❌ Insecure - never do this
certificate-data: "MIIKzAIBAzCCCogGCSqGSIb3DQ..."
certificate-password: "my-secret-password"
```

### Preparing Certificates for GitHub Secrets

1. **Export certificate from Keychain Access as .p12 with password protection**

2. **Convert to base64:**

   ```bash
   base64 -i certificate.p12 | pbcopy
   ```

3. **Store in GitHub Secrets:**
   - Go to repository Settings → Secrets and variables → Actions
   - Add new secret with the base64 content

### Provisioning Profile Setup

1. **Download from Apple Developer Portal**

2. **Convert to base64:**

   ```bash
   base64 -i profile.mobileprovision | pbcopy
   ```

3. **Store in GitHub Secrets**

### Keychain Security Features

The action automatically:

- Creates temporary keychains with secure passwords
- Configures appropriate keychain settings for codesign access
- Enables codesign access when needed
- Cleans up keychains after use (if enabled)
- Sets restrictive file permissions (600) on temporary files

## 🐛 Troubleshooting

### Common Issues

#### Action Only Works on macOS

**Problem**: This action only works on macOS runners

**Solution**: Use a macOS runner:

```yaml
runs-on: macos-latest  # or macos-13, macos-12
```

#### Certificate Import Failures

**Problem**: security: SecKeychainItemImport: MAC verification failed during PKCS12 import

**Solutions:**

1. Verify certificate password is correct
2. Ensure certificate is not corrupted
3. Check base64 encoding is valid

```yaml
- name: "Validate certificate format"
  run: |
    echo "${{ secrets.CERTIFICATE_DATA }}" | base64 -d > temp-cert.p12
    if ! openssl pkcs12 -in temp-cert.p12 -noout -passin pass:"${{ secrets.CERTIFICATE_PASSWORD }}"; then
      echo "❌ Invalid certificate or password"
      exit 1
    fi
    rm temp-cert.p12
    echo "✅ Certificate validation passed"
```

#### Provisioning Profile Issues

**Problem**: Provisioning profile file not found

**Solutions:**

1. Verify base64 encoding of profile
2. Check profile file exists at specified path
3. Ensure profile is valid and not expired

```yaml
- name: "Validate provisioning profile"
  run: |
    echo "${{ secrets.PROVISIONING_PROFILE_DATA }}" | base64 -d > temp-profile.mobileprovision
    if ! plutil -lint temp-profile.mobileprovision; then
      echo "❌ Invalid provisioning profile"
      exit 1
    fi
    rm temp-profile.mobileprovision
    echo "✅ Provisioning profile validation passed"
```

#### Codesign Access Issues

**Problem**: User interaction is not allowed

**Solutions:**

1. Ensure `allow-codesign-keychain-access` is set to `true`
2. Check keychain password is correct
3. Verify keychain is unlocked

```yaml
- name: "Debug keychain access"
  run: |
    security list-keychains -d user
    security find-identity -v -p codesigning
    security unlock-keychain -p "${{ secrets.KEYCHAIN_PASSWORD }}" "${{ steps.certificate.outputs.keychain-path }}"
```

### Debug Mode

Enable verbose output for troubleshooting:

```yaml
- name: "Debug certificate installation"
  uses: laerdal/github_actions/install-apple-certificate@main
  with:
    certificate-data: ${{ secrets.CERTIFICATE_DATA }}
    certificate-password: ${{ secrets.CERTIFICATE_PASSWORD }}
    show-summary: "true"
  env:
    ACTIONS_STEP_DEBUG: true
```

### Manual Verification

Verify installation manually:

```yaml
- name: "Verify certificate installation"
  run: |
    security find-identity -v -p codesigning
    security list-keychains -d user
    ls -la "$HOME/Library/MobileDevice/Provisioning Profiles/"
```

## 🔧 Advanced Configuration

### Custom Keychain Configuration

```yaml
- name: "Install with custom keychain"
  uses: laerdal/github_actions/install-apple-certificate@main
  with:
    certificate-data: ${{ secrets.CERTIFICATE_DATA }}
    certificate-password: ${{ secrets.CERTIFICATE_PASSWORD }}
    keychain-name: "custom-build.keychain"
    keychain-password: ${{ secrets.KEYCHAIN_PASSWORD }}
    delete-keychain: "false"
    allow-codesign-keychain-access: "true"
```

### Multiple Team Support

```yaml
strategy:
  matrix:
    team:
      - { id: "TEAM1234", cert: "TEAM1_CERT", profile: "TEAM1_PROFILE" }
      - { id: "TEAM5678", cert: "TEAM2_CERT", profile: "TEAM2_PROFILE" }

steps:
  - name: "Install certificate for ${{ matrix.team.id }}"
    uses: laerdal/github_actions/install-apple-certificate@main
    with:
      certificate-data: ${{ secrets[matrix.team.cert] }}
      certificate-password: ${{ secrets.CERTIFICATE_PASSWORD }}
      provisioning-profile-data: ${{ secrets[matrix.team.profile] }}
      team-id: ${{ matrix.team.id }}
```

## 📄 License

This action is part of the GitHub Actions collection by Francois Raminosona.

---

> 💡 **Tip**: Store your certificates and provisioning profiles as GitHub Secrets and use environment protection rules for production releases.
