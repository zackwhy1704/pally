# Apple External Link Account Entitlement — activation runbook

> Lets the iOS app show a **tappable** "Continue on web" button that opens the
> Apalchi billing page in Safari, instead of the copy-only link we ship by
> default. Until Apple grants this, iOS stays copy-only (App Store §3.1.1).

## Why this isn't enabled in the build yet

The entitlement `com.apple.developer.storekit.external-link.account` requires
**Apple approval per app**, and the provisioning profile must carry the
capability. Adding the key to `Runner.entitlements` *before* approval breaks
device/release code signing. So:

- **Code is already wired** behind a server flag — no app change needed at
  grant time, only a flag flip + (once approved) the entitlement key + a new
  signed build.
- The entitlement XML below is **staged here, not in the build.**

## One-time: apply to Apple

1. App Store Connect → your app → **App Information** (or the dedicated
   *External Purchase Link* / *External Link Account* request form). Request the
   **External Link Account Entitlement** (reader-style account-management link).
2. Justify it as: subscriptions are sold and managed on `apalchi.com`; the app
   links users to their account page to manage/upgrade. Declare the storefront
   **regions** where the link will be shown.
3. Wait for Apple approval (manual review). They email when granted.

## On approval: activate (one PR + one flag flip)

1. **Add the entitlement** to BOTH `ios/Runner/Runner.entitlements` and
   `ios/Runner/RunnerRelease.entitlements`, inside the top-level `<dict>`.
   Replace the country array with exactly the regions Apple approved:

   ```xml
   <key>com.apple.developer.storekit.external-link.account</key>
   <array>
       <string>us</string>
       <!-- ...only the storefront codes Apple granted... -->
   </array>
   ```

2. In the Apple Developer portal, enable the matching capability on the App ID
   and regenerate the provisioning profile(s); update signing in Xcode / CI.

3. **Flip the server flag** `ios_external_link_enabled = true` for the desired
   users/regions. The flag is defined in
   `lib/core/services/feature_flags.dart` (`FeatureFlags.iosExternalLinkEnabled`)
   and consumed in `lib/features/subscription/widgets/web_upgrade_cta.dart`
   (`allowLaunch`). No client release is needed for the flag flip itself, but
   the entitlement + profile change DOES require a new signed build submitted
   for review.

4. Ship the signed build. iOS users in the granted regions now see the tappable
   "Continue on web" button; everyone else still sees the copy-only link.

## Rollback

Set `ios_external_link_enabled = false` server-side → iOS instantly reverts to
copy-only with no app update. (The entitlement can stay in the binary; the flag
is the kill switch.)

## Related

- Compliance background and the web-only purchasing model: see the B2C
  web-billing PR (`feat/b2c-web-billing`).
- Android needs none of this — it link-outs to the system browser already.
