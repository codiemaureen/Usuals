# Usuals — connect to Supabase

The developer-managed Supabase URL and **publishable** key are already configured in `app.js`. Users need only sign in to Usuals; they do not need Supabase accounts.

1. You have already run `usuals-supabase-setup.sql` successfully. Do **not** run the old `supabase-setup.sql`.
2. In Supabase → Authentication → Providers → Email, confirm email sign-in is enabled and that Magic Link/OTP email delivery is configured.
3. Under Authentication → URL Configuration, set **Site URL** to the final HTTPS address where Usuals will live, and add it to Redirect URLs. For local testing also allow `http://localhost:8000/**` (the path wildcard should be adjusted according to Supabase's allowed redirects).
4. Publish this folder as a static site on Vercel or Netlify. **Important:** Copy your existing `icons/` directory into this folder before deploying; your uploaded files did not include it.
5. Run locally from this folder with `python -m http.server 8000`; visit `http://localhost:8000`. Click **Sign in**, enter your email, and follow the link. Your first login creates a private household and fills it with the starter grocery list.
6. Log in on your other device with the same email to test sync.

## Current scope and limitations

- This release synchronizes the same account across devices. The SQL already supports household membership, but **invitations and adding a second user to an existing household are not implemented yet**. Do not promise your husband a separate login until that is built.
- The list is stored as one JSON document, so near-simultaneous edits can overwrite each other (last-write-wins). For robust multi-person simultaneous shopping, migrate to row-level items and conflict handling.
- Signed-out edits stay local, but first sign-in uses the account's cloud data (or the default starter list for a new account); local changes made while signed out are not automatically imported.
- The app has a local/offline cache. It only synchronizes changes made while an authenticated session has a working connection; it does not yet guarantee offline-to-online reconciliation.
- Publishable keys and project URLs are safe to include in browser code; **never include a secret or service_role key**.
