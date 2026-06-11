# Bundle ID Rebrand Checklist

When ready to change from `com.pally.pally` to `com.memoly.app` (or chosen ID):

1. android/app/build.gradle line 26: `namespace "com.pally.pally"` -> new ID
2. android/app/build.gradle line 45: `applicationId "com.pally.pally"` -> new ID
3. ios/Runner.xcodeproj/project.pbxproj: all PRODUCT_BUNDLE_IDENTIFIER entries
   - com.pally.pally (3 occurrences: Debug, Profile, Release)
   - com.pally.pally.RunnerTests (3 occurrences)
4. Rename android/app/src/main/kotlin/com/pally/pally/ directory to match
5. Update the package declaration in MainActivity.kt to match the new ID
6. Update any Firebase config (google-services.json, GoogleService-Info.plist)
7. Update Sentry DSN if bundle-specific

NOTE: Do NOT change the bundle ID after first app store submission -- it creates a new app.
