<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        @include('partials.head', ['title' => ($title ?? config('app.name')) . ' | ' . config('app.tagline')])
    </head>
    <body class="min-h-screen bg-[#D2F9E7] font-sans antialiased text-slate-900">
        <div class="flex min-h-screen flex-col">
            <header class="sticky top-0 z-40 bg-white/90 backdrop-blur shadow-sm">
                <div class="mx-auto flex w-full max-w-6xl items-center justify-between px-4 py-3 md:px-8">
                    <div class="flex items-center gap-3">
                        <a href="{{ route('dashboard') }}" class="flex items-center gap-2" wire:navigate>
                            <div>
                                <p class="text-base font-semibold text-[#095C4A]">{{ config('app.name') }}</p>
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
                        <a href="{{ route('transactions.index') }}" wire:navigate @class([
                            'rounded-full px-4 py-2 transition',
                            'bg-[#095C4A] text-white' => request()->routeIs('transactions.index'),
                            'text-slate-600 hover:bg-[#D2F9E7] hover:text-[#095C4A]' => ! request()->routeIs('transactions.index'),
                        ])>Transactions</a>
                        <a href="{{ route('memos') }}" wire:navigate @class([
                            'rounded-full px-4 py-2 transition',
                            'bg-[#095C4A] text-white' => request()->routeIs('memos'),
                            'text-slate-600 hover:bg-[#D2F9E7] hover:text-[#095C4A]' => ! request()->routeIs('memos'),
                        ])>Memos</a>
                        <a href="{{ route('profile.settings') }}" wire:navigate @class([
                            'rounded-full px-4 py-2 transition',
                            'bg-[#095C4A] text-white' => request()->routeIs('profile.settings'),
                            'text-slate-600 hover:bg-[#D2F9E7] hover:text-[#095C4A]' => ! request()->routeIs('profile.settings'),
                        ])>Profile</a>
                    </nav>
                    <div class="flex items-center gap-3">
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
                <div class="grid grid-cols-6 gap-2 text-xs font-medium text-slate-600">
                    @php($navItems = [
                        ['route' => 'dashboard', 'label' => 'Dashboard', 'icon' => 'home'],
                        ['route' => 'planning', 'label' => 'Planning', 'icon' => 'calendar-days'],
                        ['route' => 'statistics', 'label' => 'Stats', 'icon' => 'chart-pie'],
                        ['route' => 'transactions.index', 'label' => 'Trans.', 'icon' => 'clipboard-document-list'],
                        ['route' => 'memos', 'label' => 'Memos', 'icon' => 'pencil-square'],
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
        
        <div x-data="{ open: false, title: '', message: '', action: null }"
             @open-confirmation-modal.window="open = true; title = $event.detail[0].title; message = $event.detail[0].message; action = $event.detail[0].action"
             x-show="open"
             class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4 backdrop-blur-sm"
             style="display: none;"
             x-transition:enter="transition ease-out duration-200"
             x-transition:enter-start="opacity-0"
             x-transition:enter-end="opacity-100"
             x-transition:leave="transition ease-in duration-150"
             x-transition:leave-start="opacity-100"
             x-transition:leave-end="opacity-0">
            <div class="w-full max-w-md rounded-2xl bg-white p-6 shadow-xl" @click.away="open = false">
                <h3 class="text-lg font-bold text-slate-900" x-text="title"></h3>
                <p class="mt-2 text-sm text-slate-500" x-text="message"></p>
                <div class="mt-6 flex justify-end gap-3">
                    <button @click="open = false" class="rounded-lg px-4 py-2 text-sm font-semibold text-slate-600 hover:bg-slate-100">Cancel</button>
                    <button @click="open = false; $dispatch(action)" class="rounded-lg bg-red-500 px-4 py-2 text-sm font-semibold text-white hover:bg-red-600">Delete</button>
                </div>
            </div>
        </div>

        @stack('scripts')
    </body>
</html>
