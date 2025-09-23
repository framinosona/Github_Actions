# 🍎 Install Apple Certificate Action

Install Apple certificates and provisioning profiles for iOS/macOS development in GitHub Actions workflows.

## Features

- 🔒 **Secure Certificate Installation** - Install Apple development/distribution certificates
- 📱 **Provisioning Profile Support** - Install and manage provisioning profiles
- 🔑 **Keychain Management** - Create and configure temporary keychains
- 🛡️ **Security First** - Secure handling of certificates and passwords
- 🔧 **Flexible Input** - Support for base64 data or file paths
- 📊 **Detailed Output** - Certificate and profile information for downstream actions
- 🧹 **Automatic Cleanup** - Optional keychain cleanup after use

## Usage

### Basic Usage

Install a certificate from base64 encoded data:

```yaml
- name: Install Apple Certificate
  uses: ./install-apple-certificate
  with:
    certificate-data: ${{ secrets.APPLE_CERTIFICATE_DATA }}
    certificate-password: ${{ secrets.APPLE_CERTIFICATE_PASSWORD }}
```

### Complete iOS Development Setup

```yaml
- name: Install Apple Certificate and Provisioning Profile
  uses: ./install-apple-certificate
  with:
    certificate-data: ${{ secrets.IOS_DISTRIBUTION_CERTIFICATE }}
    certificate-password: ${{ secrets.IOS_CERTIFICATE_PASSWORD }}
    provisioning-profile-data: ${{ secrets.IOS_PROVISIONING_PROFILE }}
    certificate-type: 'distribution'
    team-id: 'ABCDEF1234'
```

### Using Certificate Files

```yaml
- name: Install Certificate from File
  uses: ./install-apple-certificate
  with:
    certificate-path: 'certificates/ios_distribution.p12'
    certificate-password: ${{ secrets.CERTIFICATE_PASSWORD }}
    provisioning-profile-path: 'profiles/app_store.mobileprovision'
```

## Inputs

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

## Outputs

| Output | Description | Example |
|--------|-------------|---------|
| `keychain-path` | Path to the created keychain | `/Users/runner/Library/Keychains/build.keychain-db` |
| `certificate-name` | Name of installed certificate | `iPhone Distribution: My Company` |
| `certificate-sha1` | SHA1 fingerprint of certificate | `1234567890ABCDEF...` |
| `provisioning-profile-name` | Name of installed profile | `My App Store Profile` |
| `provisioning-profile-uuid` | UUID of installed profile | `12345678-1234-1234-1234-123456789012` |
| `team-id` | Team ID from certificate or input | `ABCDEF1234` |

## Examples

### Complete iOS App Build Pipeline

```yaml
name: Build iOS App

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v4

    - name: Install Apple Certificate
      id: certificate
      uses: ./install-apple-certificate
      with:
        certificate-data: ${{ secrets.IOS_DISTRIBUTION_CERTIFICATE }}
        certificate-password: ${{ secrets.IOS_CERTIFICATE_PASSWORD }}
        provisioning-profile-data: ${{ secrets.IOS_PROVISIONING_PROFILE }}
        certificate-type: 'distribution'

    - name: Build iOS App
      run: |
        xcodebuild archive \
          -workspace MyApp.xcworkspace \
          -scheme MyApp \
          -configuration Release \
          -archivePath MyApp.xcarchive \
          CODE_SIGN_IDENTITY="${{ steps.certificate.outputs.certificate-name }}" \
          PROVISIONING_PROFILE_SPECIFIER="${{ steps.certificate.outputs.provisioning-profile-uuid }}" \
          DEVELOPMENT_TEAM="${{ steps.certificate.outputs.team-id }}"
```

### Multiple Certificate Installation

```yaml
- name: Install Development Certificate
  uses: ./install-apple-certificate
  with:
    certificate-data: ${{ secrets.DEV_CERTIFICATE }}
    certificate-password: ${{ secrets.DEV_CERT_PASSWORD }}
    provisioning-profile-data: ${{ secrets.DEV_PROFILE }}
    certificate-type: 'development'
    keychain-name: 'dev.keychain'
    delete-keychain: 'false'

- name: Install Distribution Certificate
  uses: ./install-apple-certificate
  with:
    certificate-data: ${{ secrets.DIST_CERTIFICATE }}
    certificate-password: ${{ secrets.DIST_CERT_PASSWORD }}
    provisioning-profile-data: ${{ secrets.DIST_PROFILE }}
    certificate-type: 'distribution'
    keychain-name: 'dist.keychain'
    delete-keychain: 'false'
```

### macOS App Development

```yaml
- name: Install macOS Developer Certificate
  uses: ./install-apple-certificate
  with:
    certificate-data: ${{ secrets.MACOS_DEVELOPER_CERTIFICATE }}
    certificate-password: ${{ secrets.MACOS_CERT_PASSWORD }}
    certificate-type: 'developer-id'
    team-id: 'ABCDEF1234'

- name: Build and Sign macOS App
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
- name: Setup Persistent Keychain
  id: keychain
  uses: ./install-apple-certificate
  with:
    certificate-data: ${{ secrets.CERTIFICATE_DATA }}
    certificate-password: ${{ secrets.CERTIFICATE_PASSWORD }}
    keychain-name: 'persistent-build.keychain'
    delete-keychain: 'false'  # Keep keychain for subsequent steps

- name: Build App
  run: |
    # Your build commands here
    xcodebuild ...

- name: Cleanup Keychain
  if: always()
  run: |
    security delete-keychain "${{ steps.keychain.outputs.keychain-path }}" || true
```

## Requirements

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

## Security Best Practices

### Storing Certificates and Passwords

**Never commit certificates or passwords to your repository.** Always use GitHub Secrets:

```yaml
# ✅ Secure - using secrets
certificate-data: ${{ secrets.APPLE_CERTIFICATE_DATA }}
certificate-password: ${{ secrets.APPLE_CERTIFICATE_PASSWORD }}

# ❌ Insecure - never do this
certificate-data: 'MIIKzAIBAzCCCogGCSqGSIb3DQ...'
certificate-password: 'my-secret-password'
```

### Preparing Certificates for GitHub Secrets

1. **Export certificate from Keychain Access:**
   ```bash
   # Export as .p12 file with password protection
   ```

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

### Keychain Security

The action automatically:
- Creates temporary keychains with secure passwords
- Configures appropriate keychain settings
- Enables codesign access when needed
- Cleans up keychains after use (if enabled)

## Troubleshooting

### Common Issues

#### ❌ "This action only works on macOS runners"

```
Error: This action only works on macOS runners
```

**Solution:** Use a macOS runner:
```yaml
runs-on: macos-latest  # or macos-13, macos-12
```

#### ❌ Certificate Import Failures

```
Error: security: SecKeychainItemImport: MAC verification failed during PKCS12 import
```

**Solutions:**
1. Verify certificate password is correct
2. Ensure certificate is not corrupted
3. Check base64 encoding is valid

#### ❌ Provisioning Profile Issues

```
Error: Provisioning profile file not found
```

**Solutions:**
1. Verify base64 encoding of profile
2. Check profile file exists at specified path
3. Ensure profile is valid and not expired

#### ❌ Codesign Access Issues

```
Error: User interaction is not allowed
```

**Solutions:**
1. Ensure `allow-codesign-keychain-access` is set to `true`
2. Check keychain password is correct
3. Verify keychain is unlocked

### Debug Mode

Enable verbose output for troubleshooting:

```yaml
- name: Debug Certificate Installation
  uses: ./install-apple-certificate
  with:
    certificate-data: ${{ secrets.CERTIFICATE_DATA }}
    certificate-password: ${{ secrets.CERTIFICATE_PASSWORD }}
  env:
    ACTIONS_STEP_DEBUG: true
```

### Manual Verification

Verify installation manually:

```yaml
- name: Verify Certificate Installation
  run: |
    security find-identity -v -p codesigning
    security list-keychains -d user
    ls -la "$HOME/Library/MobileDevice/Provisioning Profiles/"
```

## Advanced Usage

### Custom Keychain Configuration

```yaml
- name: Install with Custom Keychain
  uses: ./install-apple-certificate
  with:
    certificate-data: ${{ secrets.CERTIFICATE_DATA }}
    certificate-password: ${{ secrets.CERTIFICATE_PASSWORD }}
    keychain-name: 'custom-build.keychain'
    keychain-password: ${{ secrets.KEYCHAIN_PASSWORD }}
    delete-keychain: 'false'
    allow-codesign-keychain-access: 'true'
```

### Multiple Team Support

```yaml
strategy:
  matrix:
    team:
      - { id: 'TEAM1234', cert: 'TEAM1_CERT', profile: 'TEAM1_PROFILE' }
      - { id: 'TEAM5678', cert: 'TEAM2_CERT', profile: 'TEAM2_PROFILE' }

steps:
- name: Install Certificate for ${{ matrix.team.id }}
  uses: ./install-apple-certificate
  with:
    certificate-data: ${{ secrets[matrix.team.cert] }}
    certificate-password: ${{ secrets.CERTIFICATE_PASSWORD }}
    provisioning-profile-data: ${{ secrets[matrix.team.profile] }}
    team-id: ${{ matrix.team.id }}
```

### Environment-Specific Certificates

```yaml
- name: Install Certificate
  uses: ./install-apple-certificate
  with:
    certificate-data: ${{ github.ref == 'refs/heads/main' && secrets.PRODUCTION_CERT || secrets.DEVELOPMENT_CERT }}
    certificate-password: ${{ secrets.CERTIFICATE_PASSWORD }}
    provisioning-profile-data: ${{ github.ref == 'refs/heads/main' && secrets.PRODUCTION_PROFILE || secrets.DEVELOPMENT_PROFILE }}
    certificate-type: ${{ github.ref == 'refs/heads/main' && 'distribution' || 'development' }}
```

## Contributing

When contributing to this action:

1. Follow the [Actions Guidelines](../.github/copilot-instructions.md)
2. Test with various certificate types and configurations
3. Ensure security best practices are maintained
4. Update documentation for new features
5. Test on different macOS runner versions

## License

This action is distributed under the same license as the repository.

## Support

For issues related to:
- **Apple certificates:** Check [Apple Developer Documentation](https://developer.apple.com/documentation/)
- **macOS keychain:** Check [macOS Security Framework](https://developer.apple.com/documentation/security)
- **Action bugs:** Create an issue in this repository
- **GitHub Actions:** Check [GitHub Actions Documentation](https://docs.github.com/en/actions)
