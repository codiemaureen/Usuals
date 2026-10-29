# Usuals — email/password and email-code login

## Deploy
1. Back up your current Netlify deploy and any local grocery data before replacing files.
2. Keep your original `icons/` folder: it was not included in the original uploads. The PWA service worker expects these files.
3. Deploy this folder's contents, with `index.html` at the website root, to the EXISTING Netlify site.
4. In Supabase > Authentication > URL Configuration, set Site URL to `https://theusuals.netlify.app/` and allow `https://theusuals.netlify.app/**` and `http://localhost:8000/**`.
5. In Supabase > Authentication > Providers > Email, enable email/password sign-in and leave **Confirm email** enabled for real users.
6. In Supabase > Authentication > Email Templates: change **Magic Link**, **Confirm Signup**, and **Reset Password** templates to present `{{ .Token }}` as a verification code instead of solely `{{ .ConfirmationURL }}`. Sample bodies below. This step is REQUIRED for in-app email code entry.
7. Existing email-link accounts can use Forgot password to choose a password.

### Example templates (paste each into the matching email template editor)

**Magic Link / OTP:**
```html
<h2>Your Usuals sign-in code</h2><p>Enter this code inside Usuals:</p><h1>{{ .Token }}</h1><p>If you did not request this, ignore this message.</p>
```

**Confirm Signup:**
```html
<h2>Confirm your Usuals account</h2><p>Enter this code in Usuals:</p><h1>{{ .Token }}</h1>
```

**Reset Password:**
```html
<h2>Reset your Usuals password</h2><p>Enter this code in Usuals:</p><h1>{{ .Token }}</h1><p>If you did not request a reset, ignore this message.</p>
```

## Important limitations
- Supabase's default email sender has strict rate limits; changing the login method does not increase them. Password login does not require an email on each visit. For production, configure custom SMTP.
- Only same-account device synchronization exists in this version, not invitations for separate household accounts.
- List saving still replaces an entire JSON document, so simultaneous edits can overwrite each other. Avoid editing two devices at once until item-level concurrency is implemented.
- Existing local-only grocery lists are not automatically merged into a new cloud account. Back them up before first sign-in.
- The publishable Supabase key in app.js is safe for frontend use; NEVER put a secret/service-role key there.
- This has been statically checked, not tested against your live Supabase project.
