# My Expenses

My Expenses is a Laravel 12 + Livewire 3 application that keeps track of personal finances in a mobile-first experience. It ships with wallet management, recurring transactions, budgeting, goals, subscriptions, rich statistics, export tooling, and an admin console for managing shared assets like icon libraries.

## Tech Stack

- **Backend:** Laravel 12, PHP 8.2, Livewire 3, PostgreSQL/Supabase
- **Frontend:** Blade, Tailwind CSS, Alpine.js, Chart.js, Vite build pipeline
- **Realtime UI:** Livewire SPA-style navigation + custom JS helpers for icons, money masking, and date pickers
- **Auth:** Laravel Breeze-style email/password login with optional admin role
- **Infrastructure ready:** Dockerfile optimized for Google Cloud Run deployments

## Prerequisites

- PHP 8.2+
- Composer 2.x
- Node.js 18+/npm 9+
- PostgreSQL (or Supabase instance)
- Redis (optional, for queues/caching)

## Local Development

1. **Clone & install dependencies**
   ```bash
   git clone <repo-url> tracker-expenses
   cd tracker-expenses
   composer install
   npm install
   ```

2. **Environment**
   ```bash
   cp .env.example .env
   php artisan key:generate
   ```
   Update the `.env` file with your Supabase credentials (or a local PostgreSQL DSN), mail driver, storage disks, etc.

3. **Database**
   ```bash
   php artisan migrate --seed
   ```
   The seeder creates an admin login (`admin@abiya` / `Abiyajr11`) plus demo data.

4. **Run dev servers**
   ```bash
   php artisan serve        # http://127.0.0.1:8000
   php artisan queue:work   # optional if processing jobs
   npm run dev              # hot reload assets via Vite
   ```

5. **Run tests**
   ```bash
   php artisan test
   ```

## Building Front-End Assets

```bash
npm run build   # generates production assets in public/build
```

## Docker & Cloud Run

The provided `Dockerfile` packages the application with nginx + PHP-FPM using the `webdevops/php-nginx` base image. It installs Composer dependencies, builds Vite assets, and exposes port 8080 which matches Cloud Run requirements.

### Build locally

```bash
docker build -t my-expenses:latest .

docker run -p 8090:8080 --env-file .env my-expenses:latest
```

Remember to pass all sensitive environment variables at runtime (database, queue, storage, mail, AWS keys, etc). The container expects `storage` to be writable and will use the provided env vars to bootstrap Laravel.

### Deploy to Cloud Run

Example workflow:

```bash
gcloud builds submit --tag gcr.io/<gcp-project>/my-expenses .
gcloud run deploy my-expenses \
  --image gcr.io/<gcp-project>/my-expenses \
  --region asia-southeast2 \
  --platform managed \
  --allow-unauthenticated \
  --set-env-vars APP_KEY=base64:...,APP_ENV=production,DB_URL=postgresql://...
```

Adjust the region/service names and include all required secrets via `--set-env-vars` or Secret Manager references.

## GitHub Actions

The repository ships with a CI workflow (`.github/workflows/ci.yml`) that installs Composer & npm dependencies, runs the Laravel test suite, and ensures the Docker image builds successfully on every push/pull request targeting `main` or feature branches. Customize the workflow if you need artifact uploads, Google Cloud authentication, or deployment gates.

## Useful Commands

| Command | Description |
| --- | --- |
| `php artisan migrate --seed` | Bootstrap schema and demo data |
| `php artisan optimize` | Cache config/routes/views for production |
| `php artisan schedule:run` | Manually trigger the scheduler (recurring transactions) |
| `php artisan storage:link` | Publish storage symlink for uploads |
| `npm run lint` | Run linting (if configured) |

Feel free to open issues or PRs for enhancements, bug fixes, or additional documentation.
