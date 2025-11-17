<x-layouts.auth>
    <div class="flex flex-col gap-6">
        <div class="space-y-2 text-center">
            <p class="text-xs font-semibold uppercase tracking-[0.25em] text-[#08745C]">{{ __('Welcome back') }}</p>
            <h2 class="text-2xl font-semibold text-[#095C4A]">{{ __('Sign in to My Expenses') }}</h2>
            <p class="text-sm text-slate-500">{{ __('Keep your cash flow, budgets, and subscriptions on track every day.') }}</p>
        </div>

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

            <flux:button variant="primary" type="submit" class="w-full rounded-full bg-[#095C4A] px-4 py-3 text-base font-semibold shadow-lg shadow-[#095C4A]/20" data-test="login-button">
                {{ __('Log in') }}
            </flux:button>
        </form>

        @if (Route::has('register'))
            <div class="space-x-1 text-center text-sm text-slate-500 rtl:space-x-reverse">
                <span>{{ __('New here?') }}</span>
                <flux:link :href="route('register')" class="font-semibold text-[#08745C]" wire:navigate>{{ __('Create an account') }}</flux:link>
            </div>
        @endif
    </div>
</x-layouts.auth>
