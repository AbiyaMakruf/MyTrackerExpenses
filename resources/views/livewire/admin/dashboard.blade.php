@php
    $transactionsChart = [
        'type' => 'bar',
        'data' => [
            'labels' => $transactionsPerDay->pluck('date')->map(fn ($date) => \Illuminate\Support\Carbon::parse($date)->format('d M')),
            'datasets' => [
                [
                    'label' => 'Transactions',
                    'data' => $transactionsPerDay->pluck('total'),
                    'backgroundColor' => '#095C4A',
                    'borderRadius' => 8,
                ],
            ],
        ],
        'options' => [
            'plugins' => ['legend' => ['display' => false]],
        ],
    ];
@endphp

<section class="glass-card space-y-6">
    <div class="flex items-center justify-between">
        <div>
            <h1 class="text-2xl font-semibold text-[#095C4A]">Admin dashboard</h1>
            <p class="text-sm text-slate-500">Monitor platform usage and manage shared assets.</p>
        </div>
        <span class="rounded-full bg-[#F6FFFA] px-4 py-1 text-sm font-semibold text-[#08745C]">Admin only</span>
    </div>

    @if (session('admin_status'))
        <div class="rounded-2xl bg-[#D2F9E7] px-4 py-2 text-sm font-semibold text-[#08745C]">
            {{ session('admin_status') }}
        </div>
    @endif

    <div class="grid gap-4 md:grid-cols-4">
        <div class="rounded-2xl border border-white/60 bg-white/80 p-4">
            <p class="text-xs uppercase text-slate-400">Total users</p>
            <p class="mt-3 text-3xl font-semibold text-[#095C4A]">{{ $stats['total_users'] }}</p>
        </div>
        <div class="rounded-2xl border border-white/60 bg-white/80 p-4">
            <p class="text-xs uppercase text-slate-400">Active (30d)</p>
            <p class="mt-3 text-3xl font-semibold text-[#08745C]">{{ $stats['active_users'] }}</p>
        </div>
        <div class="rounded-2xl border border-white/60 bg-white/80 p-4">
            <p class="text-xs uppercase text-slate-400">Transactions</p>
            <p class="mt-3 text-3xl font-semibold text-[#15B489]">{{ $stats['transactions'] }}</p>
        </div>
        <div class="rounded-2xl border border-white/60 bg-white/80 p-4">
            <p class="text-xs uppercase text-slate-400">Today</p>
            <p class="mt-3 text-3xl font-semibold text-[#72E3BD]">{{ $stats['transactions_today'] }}</p>
        </div>
    </div>

    <div class="glass-card">
        <h2 class="text-lg font-semibold text-[#095C4A]">Transactions per day</h2>
        <div class="mt-3 h-64" data-chart>
            <canvas data-chart='@json($transactionsChart)'></canvas>
        </div>
    </div>

    <div class="glass-card space-y-3">
        <h2 class="text-lg font-semibold text-[#095C4A]">Recent users</h2>
        <div class="overflow-x-auto rounded-2xl border border-[#D2F9E7] bg-white/80">
            <table class="w-full text-left text-sm text-slate-600">
                <thead class="text-xs uppercase text-slate-400">
                    <tr>
                        <th class="px-4 py-2">Name</th>
                        <th class="px-4 py-2">Email</th>
                        <th class="px-4 py-2">Role</th>
                        <th class="px-4 py-2">Last active</th>
                        <th class="px-4 py-2">Created</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach ($users as $user)
                        <tr class="border-t border-[#D2F9E7]">
                            <td class="px-4 py-2 font-semibold text-[#095C4A]">{{ $user->name }}</td>
                            <td class="px-4 py-2">{{ $user->email }}</td>
                            <td class="px-4 py-2">{{ ucfirst($user->role) }}</td>
                            <td class="px-4 py-2">{{ optional($user->last_active_at)->diffForHumans() }}</td>
                            <td class="px-4 py-2">{{ $user->created_at->format('d M Y') }}</td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>

    <div class="grid gap-4 md:grid-cols-2">
        <div class="space-y-3 rounded-2xl border border-[#D2F9E7] bg-white/80 p-4">
            <h2 class="text-lg font-semibold text-[#095C4A]">Category icons</h2>
            <div class="space-y-2 max-h-72 overflow-y-auto">
                @foreach ($icons as $icon)
                    <div class="flex items-center justify-between rounded-xl bg-[#F6FFFA] px-3 py-2">
                        <div>
                            <p class="text-sm font-semibold">{{ $icon->name }}</p>
                            <p class="text-xs text-slate-500">{{ $icon->icon_key }} • {{ ucfirst($icon->icon_type) }}</p>
                        </div>
                        <button type="button" wire:click="deleteIcon({{ $icon->id }})" class="text-xs font-semibold text-red-500">Delete</button>
                    </div>
                @endforeach
            </div>
        </div>
        <form wire:submit.prevent="saveIcon" class="space-y-3 rounded-2xl border border-[#72E3BD]/60 bg-white/90 p-4">
            <h3 class="text-base font-semibold text-[#095C4A]">Add icon</h3>
            <div>
                <label class="text-xs text-slate-500">Name</label>
                <input type="text" wire:model.live="iconForm.name" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                @error('iconForm.name') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
            </div>
            <div>
                <label class="text-xs text-slate-500">Icon key</label>
                <input type="text" wire:model.live="iconForm.icon_key" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2" placeholder="heroicon-shopping-bag or emoji" />
                @error('iconForm.icon_key') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
            </div>
            <div>
                <label class="text-xs text-slate-500">Type</label>
                <select wire:model.live="iconForm.icon_type" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                    <option value="icon">Icon</option>
                    <option value="emoji">Emoji</option>
                </select>
            </div>
            <div>
                <label class="text-xs text-slate-500">Description</label>
                <textarea wire:model.live="iconForm.description" rows="2" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2"></textarea>
            </div>
            <button type="submit" class="btn-primary w-full">Save icon</button>
        </form>
    </div>

    <div class="rounded-2xl border border-[#D2F9E7] bg-white/80 p-4">
        <h2 class="text-lg font-semibold text-[#095C4A]">Global settings</h2>
        <p class="text-sm text-slate-500">Reference of configurable parameters (edit via env/config).</p>
        <ul class="mt-2 list-disc space-y-1 pl-6 text-sm text-slate-600">
            @foreach ($globalSettings as $setting)
                <li>{{ $setting }}</li>
            @endforeach
        </ul>
    </div>
</section>
