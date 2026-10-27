# Usuals — Grocery List

A mobile-friendly, printable progressive web app, seeded with **136 items in 16 categories** from your latest master grocery spreadsheet.

## Use it locally / publish it

- Run `python -m http.server 8000` from this folder, then open http://localhost:8000. Avoid opening `index.html` directly as a `file://` URL (modules and the seed file need an HTTP server).
- For use on your **iPhone, iPad, and laptop**, deploy this entire folder as a static website. Drag the project folder into [Netlify Drop](https://app.netlify.com/drop) or deploy with Vercel. Use the HTTPS address on each device.
- On iPhone and iPad, open the HTTPS URL in Safari, tap **Share → Add to Home Screen**. On laptop, bookmark the URL or install the site from your browser.

## Saving and syncing

Changes automatically save in the current browser via localStorage. **Without cloud setup, lists are not synced between devices and can be lost if you clear that browser's site data.**

For the same list on all devices:

1. Create a [Supabase](https://supabase.com) project and run the included `supabase-setup.sql` in SQL Editor. If `alter publication ...` reports that the table is already in the publication, you can ignore that final-line error.
2. In Supabase **Authentication → Providers**, enable Email. Under **Authentication → URL Configuration**, add your deployed app URL as an allowed Redirect URL (with trailing slash if applicable).
3. Open the app, click **Sync**, and enter your project URL and **publishable/anon** key (never the service-role secret). Sign in with an emailed magic link.
4. On each other device, open the same hosted app, configure the same Supabase project settings once on that device, and sign in with **the same email**. The list will sync automatically.

**Important:** On first login, if the cloud list already exists, it replaces that device's local list. If not, the current device's list is uploaded. Sign in first on the device that has your most current list.

## Features

- Add, edit, move and delete items; set quantities and notes
- Add, rename and delete categories
- Check/uncheck groceries and one-click **Uncheck all**
- Search and show selected items only
- Print directly from the same list (two-column print layout, no second sheet to update)
- Offline saving after the site has loaded; optional cross-device cloud syncing

## Notes

- Imported category and item names are kept as shown in the workbook, including any spelling variants.
- The printed sheet will fit across multiple pages if your printer needs more space; this is intentional to keep the text legible.
- Cloud synchronization uses last-write-wins; avoid changing the list on two offline devices at the same time.

## Branding update

The new Usuals grocery tote/checkmark icon is used as the in-app header icon, browser favicon, iPhone/iPad home screen icon, and PWA install icon. If replacing a previously deployed copy, upload all files including `icons/` and `sw.js`; a device that previously installed the app may need to remove and re-add its home screen shortcut to refresh the icon. Existing grocery list data is not reset by these branding changes.

## New: Shopping List screen

1. On **Master List**, check the groceries you want to buy.
2. Tap **View Shopping List** (or the **Shopping List** tab) to see only your selected items, grouped by category.
3. On the shopping screen, check an item as it goes into your cart. That is a separate **picked up** state; it won't remove the item from the shopping list or alter the master selection.
4. Use **Reset shopping progress** to start shopping the same selected list again, or **Master List → Uncheck all** to clear selections entirely.
5. Use **Print shopping list** to print only the selected items.

All state saves locally as before and participates in the optional Supabase sync when enabled. Replacing the files does **not** erase saved browser data.
