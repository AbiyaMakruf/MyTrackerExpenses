<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>{{ config('app.name') }} – {{ config('app.tagline') }}</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <style>
            :root {
                font-family: 'Inter', system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
                color: #0f172a;
            }
            * { box-sizing: border-box; }
            body {
                margin: 0;
                min-height: 100vh;
                background: #D2F9E7;
                color: #0f172a;
            }
            a { text-decoration: none; color: inherit; }
            header {
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding: 1.5rem clamp(1.25rem, 4vw, 4rem);
            }
            .logo {
                display: flex;
                align-items: center;
                gap: .75rem;
                font-weight: 600;
                color: #095C4A;
            }
            .logo span {
                display: inline-flex;
                height: 3rem;
                width: 3rem;
                align-items: center;
                justify-content: center;
                border-radius: 1rem;
                background: #15B489;
                color: #fff;
                font-weight: 700;
            }
            nav {
                display: flex;
                align-items: center;
                gap: 1rem;
                font-size: .95rem;
            }
            .btn {
                padding: .75rem 1.5rem;
                border-radius: 999px;
                font-weight: 600;
                border: 1px solid transparent;
            }
            .btn-outline {
                border-color: #15B489;
                color: #08745C;
                background: transparent;
            }
            .btn-primary {
                background: linear-gradient(135deg, #095C4A, #15B489);
                color: #fff;
                box-shadow: 0 15px 35px rgba(9, 92, 74, .25);
            }
            .hero {
                padding: 3rem clamp(1.25rem, 4vw, 4rem);
                display: grid;
                gap: 2.5rem;
                grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
                align-items: center;
            }
            .hero-card {
                background: rgba(255, 255, 255, .92);
                border-radius: 2rem;
                padding: 2rem;
                box-shadow: 0 25px 60px rgba(8, 116, 92, .2);
            }
            .hero h1 {
                margin: 0;
                font-size: clamp(2.25rem, 5vw, 3.25rem);
                color: #095C4A;
            }
            .hero p {
                margin: 1rem 0 0;
                color: #475569;
                line-height: 1.6;
            }
            .metrics {
                display: flex;
                gap: 1.5rem;
                flex-wrap: wrap;
                margin-top: 2rem;
            }
            .metric {
                flex: 1 1 140px;
                padding: 1.2rem;
                border-radius: 1.25rem;
                background: #F2FFFA;
            }
            .metric h3 {
                margin: 0;
                font-size: 2rem;
                color: #08745C;
            }
            .features {
                padding: 0 clamp(1.25rem, 4vw, 4rem) 4rem;
                display: grid;
                gap: 1.5rem;
                grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            }
            .feature {
                background: rgba(255, 255, 255, .85);
                border-radius: 1.5rem;
                padding: 1.75rem;
                border: 1px solid rgba(8, 116, 92, .1);
            }
            .feature h4 {
                margin: 0 0 .75rem;
                color: #095C4A;
                font-size: 1.1rem;
            }
            footer {
                padding: 2rem clamp(1.25rem, 4vw, 4rem);
                text-align: center;
                font-size: .9rem;
                color: #475569;
            }
            @media (max-width: 640px) {
                header { flex-direction: column; gap: 1rem; }
                nav { flex-wrap: wrap; justify-content: center; }
            }
        </style>
    </head>
    <body>
        <header>
            <a href="{{ route('home') }}" class="logo">
                <span>ME</span>
                <div>
                    <div>{{ config('app.name', 'My Expenses') }}</div>
                    <small style="font-size:.75rem; letter-spacing:.2em; color:#08745C;">{{ config('app.tagline') }}</small>
                </div>
            </a>
            @if (Route::has('login'))
                <nav>
                    <a class="btn btn-outline" href="#features">Features</a>
                    <a class="btn btn-outline" href="#security">Security</a>
                    <a class="btn btn-outline" href="{{ route('register') }}">Create account</a>
                    <a class="btn btn-primary" href="{{ route('login') }}">Log in</a>
                </nav>
            @endif
        </header>

        <section class="hero">
            <div class="hero-card">
                <p style="text-transform:uppercase; letter-spacing:.4em; font-size:.75rem; color:#08745C; margin:0 0 1rem;">
                    Cashflow • Budgets • Goals
                </p>
                <h1>Own every rupiah you earn and spend.</h1>
                <p>
                    Sync wallets, automate recurring transactions, and visualize your cash flow with
                    delightful mobile-first widgets. Built for Indonesian creators, founders, and families
                    who want clarity every single day.
                </p>
                <div style="margin-top:2rem; display:flex; gap:1rem; flex-wrap:wrap;">
                    <a class="btn btn-primary" href="{{ route('register') }}">Get started</a>
                    <a class="btn btn-outline" href="{{ route('login') }}">I already have an account</a>
                </div>
                <div class="metrics">
                    <div class="metric">
                        <h3>+120k</h3>
                        <p style="margin:.25rem 0 0;">Transactions tracked</p>
                    </div>
                    <div class="metric">
                        <h3>3 mins</h3>
                        <p style="margin:.25rem 0 0;">Average onboarding time</p>
                    </div>
                    <div class="metric">
                        <h3>99.99%</h3>
                        <p style="margin:.25rem 0 0;">Uptime & encrypted syncing</p>
                    </div>
                </div>
            </div>
            <div class="hero-card" id="features">
                <h3 style="margin:0; font-size:1.1rem; text-transform:uppercase; letter-spacing:.35em; color:#72E3BD;">
                    Command center
                </h3>
                <p style="margin:.6rem 0 1.5rem; color:#475569;">
                    Experience the same UI you get after login—optimized for phones—right from your browser.
                </p>
                <ul style="list-style:none; margin:0; padding:0; display:flex; flex-direction:column; gap:1.25rem;">
                    <li>
                        <strong style="color:#095C4A;">Balance Trend</strong>
                        <p style="margin:.4rem 0 0; color:#475569;">Interactive charts powered by Chart.js showing income vs expense.</p>
                    </li>
                    <li>
                        <strong style="color:#095C4A;">Budgets & Goals</strong>
                        <p style="margin:.4rem 0 0; color:#475569;">Allocate by category, see progress rings, and automate savings.</p>
                    </li>
                    <li>
                        <strong style="color:#095C4A;">Supabase + Livewire 3</strong>
                        <p style="margin:.4rem 0 0; color:#475569;">Blazing-fast SPA feel backed by PostgreSQL and Laravel 12.</p>
                    </li>
                </ul>
            </div>
        </section>

        <section class="features" id="security">
            <article class="feature">
                <h4>Real automation</h4>
                <p>Recurring income, bills, subscriptions, and planned payments run through Laravel scheduler so you never duplicate or miss a record.</p>
            </article>
            <article class="feature">
                <h4>Mobile-first DNA</h4>
                <p>Bottom navigation, floating “Add Record” action, and thumb-friendly forms make daily logging second nature.</p>
            </article>
            <article class="feature">
                <h4>Deep exports</h4>
                <p>Download CSV, Excel, or PDF with filters, grouped totals, and optional receipt attachments—perfect for accountants.</p>
            </article>
            <article class="feature">
                <h4>Admin insights</h4>
                <p>Role-based access with an admin cockpit to monitor active users, curated icon libraries, and global policies.</p>
            </article>
        </section>

        <footer>
            &copy; {{ date('Y') }} {{ config('app.name') }} — {{ config('app.tagline') }}. Built with Laravel 12, Livewire 3, Tailwind CSS, and Supabase PostgreSQL.
        </footer>
    </body>
</html>
