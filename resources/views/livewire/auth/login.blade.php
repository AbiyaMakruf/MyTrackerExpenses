<x-layouts.auth>
    <div class="flex flex-col gap-6">
        <div class="space-y-2 text-center">
            <p class="text-xs font-semibold uppercase tracking-[0.25em] text-[#08745C] dark:text-[#72E3BD]">{{ __('Welcome back') }}</p>
            <h2 class="text-2xl font-semibold text-[#095C4A] dark:text-white">{{ __('Sign in to My Expenses') }}</h2>
            <p class="text-sm text-slate-500 dark:text-gray-300">{{ __('Keep your cash flow, budgets, and subscriptions on track every day.') }}</p>
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

        <form method="POST" action="{{ route('login.store') }}" class="flex flex-col gap-5">
            @csrf

            <flux:input
                name="email"
                :label="__('Email')"
                type="email"
                required
                autofocus
                autocomplete="email"
                placeholder="you@business.com"
            />

            <div class="relative">
                <flux:input
                    name="password"
                    :label="__('Password')"
                    type="password"
                    required
                    autocomplete="current-password"
                    placeholder="••••••••"
                    viewable
                />

                @if (Route::has('password.request'))
                    <flux:link class="absolute top-0 text-sm end-0 text-[#08745C]" :href="route('password.request')" wire:navigate>
                        {{ __('Forgot password?') }}
                    </flux:link>
                @endif
            </div>

            <flux:checkbox name="remember" :label="__('Keep me signed in')" :checked="old('remember')" />

            <button type="submit" class="w-full rounded-2xl bg-[#095C4A] px-4 py-3 text-base font-semibold text-white shadow-lg shadow-[#095C4A]/20 transition-all duration-200 ease-out hover:scale-[1.02] hover:brightness-110 focus-visible:ring-2 focus-visible:ring-[#72E3BD] disabled:cursor-not-allowed disabled:opacity-50" data-test="login-button">
                {{ __('Log in') }}
            </button>
        </form>

        @if (Route::has('register'))
            <div class="space-x-1 text-center text-sm text-slate-500 rtl:space-x-reverse dark:text-gray-300">
                <span>{{ __('New here?') }}</span>
                <flux:link :href="route('register')" class="font-semibold text-[#08745C] hover:underline dark:text-[#72E3BD]" wire:navigate>{{ __('Create an account') }}</flux:link>
            </div>
        @endif
    </div>
</x-layouts.auth>
