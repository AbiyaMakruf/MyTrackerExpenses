<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}" class="h-full">
    <head>
        @include('partials.head')
    </head>
    <body class="min-h-screen bg-gradient-to-br from-[#D2F9E7] to-[#72E3BD]/40 font-sans text-slate-900 antialiased dark:bg-gray-900 dark:text-gray-200">
        <div class="flex min-h-screen items-center justify-center px-4 py-10">
            <div class="w-full max-w-md rounded-3xl border border-white/60 bg-white/90 p-6 shadow-2xl shadow-[#08745C]/20 backdrop-blur dark:border-gray-700 dark:bg-gray-800">
                <div class="mb-6 flex flex-col items-center gap-2">
                    <span class="flex h-14 w-14 items-center justify-center rounded-2xl bg-[#095C4A] text-white shadow-lg shadow-[#095C4A]/30">
                        <img src="{{ asset('favicon.png') }}" alt="Logo" />
                    </span>
                    <p class="text-base font-semibold text-[#095C4A] dark:text-white">{{ config('app.name', 'My Expenses') }}</p>
                </div>
                <div class="flex flex-col gap-6">
                    {{ $slot }}
                </div>
            </div>
        </div>
        @fluxScripts
    </body>
</html>
