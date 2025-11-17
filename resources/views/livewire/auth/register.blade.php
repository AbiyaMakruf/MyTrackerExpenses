<x-layouts.auth>
    <div class="flex flex-col gap-6">
        <div class="space-y-2 text-center">
            <p class="text-xs font-semibold uppercase tracking-[0.25em] text-[#08745C] dark:text-[#72E3BD]">{{ __('Get started') }}</p>
            <h2 class="text-2xl font-semibold text-[#095C4A] dark:text-white">{{ __('Create your My Expenses account') }}</h2>
            <p class="text-sm text-slate-500 dark:text-gray-300">
                {{ __('One secure login for wallets, recurring bills, and savings goals.') }}
            </p>
        </div>

        @if ($errors->any())
            <div class="rounded-2xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700 shadow-sm dark:border-red-500/40 dark:bg-red-500/10 dark:text-red-200">
                <ul class="list-disc space-y-1 pl-5">
                    @foreach ($errors->all() as $message)
                        <li>{{ $message }}</li>
                    @endforeach
                </ul>
            </div>
        @endif

        <x-auth-session-status class="text-center" :status="session('status')" />

        <form method="POST" action="{{ route('register.store') }}" class="flex flex-col gap-5">
            @csrf

            <div class="grid gap-3 sm:grid-cols-2">
                <flux:input
                    name="name"
                    :label="__('Full name')"
                    type="text"
                    required
                    autofocus
                    autocomplete="name"
                    placeholder="Aulia Saputra"
                />

                <flux:input
                    name="email"
                    :label="__('Email')"
                    type="email"
                    required
                    autocomplete="email"
                    placeholder="you@domain.com"
                />
            </div>

            <div class="grid gap-3 sm:grid-cols-2">
                <flux:input
                    name="password"
                    :label="__('Password')"
                    type="password"
                    required
                    autocomplete="new-password"
                    placeholder="Create a password"
                    viewable
                />

                <flux:input
                    name="password_confirmation"
                    :label="__('Confirm password')"
                    type="password"
                    required
                    autocomplete="new-password"
                    placeholder="Repeat password"
                    viewable
                />
            </div>

            <p class="text-xs text-slate-500">
                {{ __('By continuing you agree to our terms & privacy. We use enterprise-grade security to guard your data.') }}
            </p>

            <button type="submit" class="w-full rounded-2xl bg-[#08745C] px-4 py-3 text-base font-semibold text-white shadow-lg shadow-[#08745C]/20 transition-all duration-200 ease-out hover:scale-[1.02] hover:brightness-110 focus-visible:ring-2 focus-visible:ring-[#72E3BD] disabled:cursor-not-allowed disabled:opacity-50" data-test="register-user-button">
                {{ __('Create account') }}
            </button>
        </form>

        <div class="space-x-1 text-center text-sm text-slate-500 rtl:space-x-reverse dark:text-gray-300">
            <span>{{ __('Already have an account?') }}</span>
            <flux:link :href="route('login')" class="font-semibold text-[#08745C] hover:underline dark:text-[#72E3BD]" wire:navigate>{{ __('Log in') }}</flux:link>
        </div>
    </div>
</x-layouts.auth>
