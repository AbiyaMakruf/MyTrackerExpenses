<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}" class="h-full">
    <head>
        @include('partials.head', ['title' => ($title ?? config('app.name')) . ' | ' . config('app.tagline')])
    </head>
    <body class="min-h-screen bg-[#D2F9E7] font-sans antialiased text-slate-900">
        <div class="flex min-h-screen flex-col">
            <header class="sticky top-0 z-40 bg-white/90 backdrop-blur shadow-sm">
                <div class="mx-auto flex w-full max-w-6xl items-center justify-between px-4 py-3 md:px-8">
                    <div class="flex items-center gap-3">
                        <a href="{{ route('dashboard') }}" class="flex items-center gap-2" wire:navigate>
                            <x-app-logo class="h-10 w-10" />
                            <div>
                                <p class="text-base font-semibold text-[#095C4A]">{{ config('app.name') }}</p>
                                <p class="text-xs text-slate-500">{{ config('app.tagline') }}</p>
                            </div>
                        </a>
                    </div>
                    <nav class="hidden items-center gap-4 text-sm font-medium md:flex">
                        <a href="{{ route('dashboard') }}" wire:navigate @class([
                            'rounded-full px-4 py-2 transition',
                            'bg-[#095C4A] text-white' => request()->routeIs('dashboard'),
                            'text-slate-600 hover:bg-[#D2F9E7] hover:text-[#095C4A]' => ! request()->routeIs('dashboard'),
                        ])>Dashboard</a>
                        <a href="{{ route('planning') }}" wire:navigate @class([
                            'rounded-full px-4 py-2 transition',
                            'bg-[#095C4A] text-white' => request()->routeIs('planning'),
                            'text-slate-600 hover:bg-[#D2F9E7] hover:text-[#095C4A]' => ! request()->routeIs('planning'),
                        ])>Planning</a>
                        <a href="{{ route('statistics') }}" wire:navigate @class([
                            'rounded-full px-4 py-2 transition',
                            'bg-[#095C4A] text-white' => request()->routeIs('statistics'),
                            'text-slate-600 hover:bg-[#D2F9E7] hover:text-[#095C4A]' => ! request()->routeIs('statistics'),
                        ])>Statistics</a>
                        <a href="{{ route('profile.settings') }}" wire:navigate @class([
                            'rounded-full px-4 py-2 transition',
                            'bg-[#095C4A] text-white' => request()->routeIs('profile.settings'),
                            'text-slate-600 hover:bg-[#D2F9E7] hover:text-[#095C4A]' => ! request()->routeIs('profile.settings'),
                        ])>Profile</a>
                    </nav>
                    <div class="flex items-center gap-3">
                        <div class="hidden text-right text-sm md:block">
                            <p class="font-semibold">{{ auth()->user()->name }}</p>
                            <p class="text-xs text-slate-500">{{ auth()->user()->email }}</p>
                        </div>
                        <flux:dropdown align="end">
                            <flux:profile
                                :name="auth()->user()->name"
                                :initials="auth()->user()->initials()"
                                variant="outline"
                                size="sm"
                            />
                            <flux:menu class="w-48">
                                <flux:menu.item :href="route('profile.settings')" icon="cog-6-tooth" wire:navigate>Settings</flux:menu.item>
                                @can('access-admin')
                                <flux:menu.item :href="route('admin.dashboard')" icon="shield-check" wire:navigate>Admin</flux:menu.item>
                                @endcan
                                <flux:menu.separator />
                                <form method="POST" action="{{ route('logout') }}">
                                    @csrf
                                    <flux:menu.item as="button" type="submit" icon="arrow-right-start-on-rectangle">Logout</flux:menu.item>
                                </form>
                            </flux:menu>
                        </flux:dropdown>
                    </div>
                </div>
            </header>

            <main class="mx-auto flex w-full max-w-6xl flex-1 flex-col gap-4 px-4 pb-28 pt-4 md:px-8 md:pb-12">
                {{ $slot }}
            </main>

            <nav class="fixed inset-x-0 bottom-0 z-40 mx-auto mb-2 max-w-3xl rounded-t-3xl border border-green-100 bg-white/90 px-6 py-3 shadow-2xl shadow-[#095C4A]/30 backdrop-blur md:hidden">
                <div class="grid grid-cols-4 gap-2 text-xs font-medium text-slate-600">
                    @php($navItems = [
                        ['route' => 'dashboard', 'label' => 'Dashboard', 'icon' => 'home'],
                        ['route' => 'planning', 'label' => 'Planning', 'icon' => 'calendar-days'],
                        ['route' => 'statistics', 'label' => 'Statistics', 'icon' => 'chart-pie'],
                        ['route' => 'profile.settings', 'label' => 'Profile', 'icon' => 'user-circle'],
                    ])
                    @foreach ($navItems as $item)
                        @php($isActive = request()->routeIs($item['route']))
                        <a href="{{ route($item['route']) }}" wire:navigate class="flex flex-col items-center gap-1 rounded-full px-2 py-1.5 text-center {{ $isActive ? 'text-[#095C4A]' : 'text-slate-500' }}">
                            <flux:icon :name="$item['icon']" class="h-5 w-5 {{ $isActive ? 'text-[#095C4A]' : 'text-slate-400' }}" />
                            <span>{{ $item['label'] }}</span>
                        </a>
                    @endforeach
                </div>
            </nav>

            <a href="{{ route('records.add') }}"
                wire:navigate
                class="fixed bottom-20 right-5 z-40 inline-flex h-14 w-14 items-center justify-center rounded-full bg-[#15B489] text-white shadow-2xl shadow-[#15B489]/50 transition hover:scale-105 md:bottom-10 md:right-10">
                <flux:icon name="plus" class="h-6 w-6" />
                <span class="sr-only">Add Record</span>
            </a>
        </div>

        @livewireScripts
        @fluxScripts
        @stack('scripts')
    </body>
</html>
