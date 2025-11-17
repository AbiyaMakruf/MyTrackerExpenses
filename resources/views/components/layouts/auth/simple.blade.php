<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        @include('partials.head')
    </head>
    <body class="min-h-screen bg-[#D2F9E7] font-sans text-slate-900 antialiased">
        <div class="relative flex min-h-screen items-center justify-center px-4 py-10 sm:px-6 lg:px-8">
            <div class="absolute inset-0 overflow-hidden">
                <div class="absolute -left-32 top-10 h-64 w-64 rounded-full bg-[#72E3BD]/40 blur-3xl"></div>
                <div class="absolute -right-16 bottom-10 h-72 w-72 rounded-full bg-[#15B489]/30 blur-3xl"></div>
            </div>
            <div class="relative z-10 grid w-full max-w-5xl gap-10 rounded-3xl bg-white/90 p-6 shadow-2xl shadow-[#095C4A]/20 backdrop-blur md:grid-cols-[1.1fr,0.9fr] lg:gap-12 lg:p-10">
                <div class="flex flex-col justify-between gap-6">
                    <div class="space-y-5">
                        <a href="{{ route('home') }}" wire:navigate class="inline-flex items-center gap-3">
                            <span class="flex h-12 w-12 items-center justify-center rounded-2xl bg-[#D2F9E7] text-[#095C4A]">
                                <x-app-logo-icon class="h-8 w-8" />
                            </span>
                            <div>
                                <p class="text-lg font-semibold text-[#095C4A]">{{ config('app.name', 'My Expenses') }}</p>
                                <p class="text-xs uppercase tracking-wide text-[#08745C]">{{ config('app.tagline') }}</p>
                            </div>
                        </a>
                        <div class="space-y-3">
                            <h1 class="text-3xl font-semibold leading-tight text-[#095C4A]">
                                Track smarter. Plan boldly. Live freely.
                            </h1>
                            <p class="text-sm leading-relaxed text-slate-500">
                                Stay on top of every wallet, bill, and savings goal with mobile-first controls, real-time insights, and a guided onboarding built for busy creators.
                            </p>
                        </div>
                        <ul class="space-y-3 text-sm text-[#095C4A]">
                            <li class="flex items-center gap-3">
                                <span class="inline-flex h-6 w-6 items-center justify-center rounded-full bg-[#D2F9E7] text-xs font-semibold">1</span>
                                Consolidated dashboard for balances, budgets, and subscriptions.
                            </li>
                            <li class="flex items-center gap-3">
                                <span class="inline-flex h-6 w-6 items-center justify-center rounded-full bg-[#D2F9E7] text-xs font-semibold">2</span>
                                Recurring automation for income, bills, and planned payments.
                            </li>
                            <li class="flex items-center gap-3">
                                <span class="inline-flex h-6 w-6 items-center justify-center rounded-full bg-[#D2F9E7] text-xs font-semibold">3</span>
                                Export-ready records with CSV, Excel, or PDF in a tap.
                            </li>
                        </ul>
                    </div>
                    <p class="text-xs font-medium uppercase tracking-[0.3em] text-[#08745C]">
                        Secure · Private · Built for Indonesia
                    </p>
                </div>
                <div class="flex flex-col gap-6 rounded-2xl border border-[#D2F9E7] bg-white/80 p-6 shadow-inner">
                    {{ $slot }}
                </div>
            </div>
        </div>
        @fluxScripts
    </body>
</html>
