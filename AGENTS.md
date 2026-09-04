# Base44 development notes

- Run the project with `docker compose -f docker-compose.base44.yml up -d`.
- The web service uses Apache rather than PHP's built-in server because API routes depend on `.htaccess` rewrites.
- `db-init` applies both `install/schema.sql` and `install/insert_core_scripts.sql`; both are idempotent and must complete before the web service starts.
- The PHP app reads database settings from process environment variables (with `.env` retained as a local override).
- Verify externally routed host handling with `curl -H 'Host: external-preview.example.com' http://localhost:3000/`.
- The development seed login is `admin` / `admin123`.
- Global themes: `public_theme` setting accepts `classic`, `modern` or `solar`. The public landing is routed by `index.php` (classic → `index.html`, modern → `public/index.php`, solar → `public/solar.php`). Admin and login pick up the same theme via `data-app-theme` on `<html>` (fetch in their heads) styled by `assets/css/app-themes.css`; `classic` is the unattributed default.
