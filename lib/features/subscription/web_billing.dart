/// Canonical entry point to the web checkout — the ONE place this URL lives.
///
/// Purchasing is web-only (see [SubscriptionService]). Unauthenticated visitors
/// are routed through login (returnTo=/account/billing) by the web app, so the
/// same link works whether or not the browser already has a session. When the
/// public short link / final path changes, edit ONLY this constant.
///
/// Points at the PUBLIC consumer pricing page (`/plans`) rather than
/// `/account/billing`: `/plans` renders without a session and its CTAs route
/// unauthenticated users through login (returnTo=/account/billing), so the link
/// works from a fresh browser with no dead-end.
const String kWebBillingUrl = 'https://apalchi.com/plans';

/// The same destination shown to the user as short, type-able text on the
/// copiable-link (iOS) surface.
const String kWebBillingDisplay = 'apalchi.com/plans';

/// Account / manage-subscription page (billing portal lives here). Used by
/// already-premium users to update card details or cancel — never for the
/// initial purchase, which goes through [kWebBillingUrl].
const String kWebAccountUrl = 'https://apalchi.com/account/billing';
const String kWebAccountDisplay = 'apalchi.com/account';
