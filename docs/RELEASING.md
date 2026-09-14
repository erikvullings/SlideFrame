# Releasing SlideFrame

Tagged releases are built as universal macOS applications, signed with a Developer ID Application
certificate, notarized by Apple, attached to a GitHub Release as a DMG, and published as the
`slideframe` cask in `erikvullings/homebrew-tap`.

## One-time GitHub setup

Create a `desktop-release` environment in the SlideFrame repository and add these environment
secrets:

The commands below use `env -u GH_TOKEN` so the `erikvullings` keychain login is selected instead
of any process-level GitHub token.

| Secret | Value |
| --- | --- |
| `APPLE_CERTIFICATE` | Base64-encoded `.p12` containing the Developer ID Application certificate and private key |
| `APPLE_CERTIFICATE_PASSWORD` | Password used when exporting that `.p12` |
| `APPLE_API_KEY` | App Store Connect API key ID |
| `APPLE_API_KEY_P8` | Complete contents of the downloaded `AuthKey_<KEY_ID>.p8` file |
| `APPLE_API_ISSUER` | App Store Connect issuer ID |
| `HOMEBREW_TAP_TOKEN` | Fine-grained GitHub token with Contents read/write access to `erikvullings/homebrew-tap` |

### Export the signing certificate

1. Open **Keychain Access** and locate the **Developer ID Application** certificate under
   **My Certificates**.
2. Expand it and confirm the private key is present.
3. Select the certificate and private key, then export them as `SlideFrame.p12`.
4. Use a strong temporary export password.
5. Store both values:

   ```bash
   base64 < SlideFrame.p12 | env -u GH_TOKEN gh secret set APPLE_CERTIFICATE \
     --repo erikvullings/SlideFrame --env desktop-release
   env -u GH_TOKEN gh secret set APPLE_CERTIFICATE_PASSWORD \
     --repo erikvullings/SlideFrame --env desktop-release
   ```

Delete the exported `.p12` after GitHub confirms the secret was stored.

### Create the notarization key

1. In App Store Connect, open **Users and Access → Integrations → Team Keys**.
2. Create a key with **Developer** access and download its `.p8` file. Apple permits one download.
3. Copy the key ID and issuer ID shown by App Store Connect.
4. Store all three values:

   ```bash
   env -u GH_TOKEN gh secret set APPLE_API_KEY \
     --repo erikvullings/SlideFrame --env desktop-release
   env -u GH_TOKEN gh secret set APPLE_API_ISSUER \
     --repo erikvullings/SlideFrame --env desktop-release
   env -u GH_TOKEN gh secret set APPLE_API_KEY_P8 \
     --repo erikvullings/SlideFrame --env desktop-release < AuthKey_<KEY_ID>.p8
   ```

Keep the `.p8` file in a secure credential store.

### Create the tap token

1. Create a fine-grained personal access token at
   <https://github.com/settings/personal-access-tokens/new>.
2. Select only `erikvullings/homebrew-tap`.
3. Grant **Repository permissions → Contents: Read and write**.
4. Store it:

   ```bash
   env -u GH_TOKEN gh secret set HOMEBREW_TAP_TOKEN \
     --repo erikvullings/SlideFrame --env desktop-release
   ```

## Publish a release

After CI is green, create and push a semantic version tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

The release workflow verifies tests, universal architectures, Developer ID signing, Apple
notarization and stapling, then updates the tap. Install or upgrade with:

```bash
brew tap erikvullings/tap
brew install --cask slideframe
# Later:
brew upgrade --cask slideframe
```
