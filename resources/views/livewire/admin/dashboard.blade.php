@php use Illuminate\Support\Facades\Storage; @endphp

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

    <!-- Unified Icon Manager -->
    <div class="space-y-4 rounded-3xl border border-[#D2F9E7] bg-white/90 p-4 shadow">
        <div class="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
            <div>
                <h2 class="text-lg font-semibold text-[#095C4A]">Unified icon library</h2>
                <p class="text-xs text-slate-500">Manage FontAwesome and custom icons.</p>
            </div>
            <input type="text" wire:model.live="iconSearch" placeholder="Search icons..." class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2 text-sm md:w-72" />
        </div>
        <div class="flex flex-wrap gap-2">
            <button type="button" wire:click="$set('iconTab','fontawesome')" @class([
                'rounded-full px-4 py-2 text-sm font-semibold',
                'bg-[#095C4A] text-white' => $iconTab === 'fontawesome',
                'bg-[#F2FFFA] text-[#095C4A]' => $iconTab !== 'fontawesome',
            ])>FontAwesome</button>
            <button type="button" wire:click="$set('iconTab','image')" @class([
                'rounded-full px-4 py-2 text-sm font-semibold',
                'bg-[#095C4A] text-white' => $iconTab === 'image',
                'bg-[#F2FFFA] text-[#095C4A]' => $iconTab !== 'image',
            ])>Custom uploads</button>
        </div>
        <div class="grid gap-3 md:grid-cols-4">
            @php($iconCollection = $iconTab === 'image' ? $customIcons : $fontawesomeIcons)
            @forelse ($iconCollection as $icon)
                <div class="rounded-2xl border border-[#D2F9E7] bg-white p-3 shadow-sm">
                    <div class="flex items-center justify-between">
                        <div class="flex h-10 w-10 items-center justify-center rounded-2xl bg-[#F6FFFA] text-[#095C4A]">
                            @if ($icon->type === 'image')
                                <img src="{{ Storage::disk('public')->url($icon->image_path) }}" alt="{{ $icon->label }}" class="h-6 w-6 object-contain" />
                            @else
                                <span data-fa-icon="{{ $icon->fa_class }}" class="text-lg"></span>
                            @endif
                        </div>
                        <button type="button" wire:click="toggleIcon({{ $icon->id }})" class="text-[10px] font-semibold {{ $icon->is_active ? 'text-emerald-600' : 'text-slate-400' }}">
                            {{ $icon->is_active ? 'ACTIVE' : 'INACTIVE' }}
                        </button>
                    </div>
                    <p class="mt-2 text-sm font-semibold text-[#095C4A]">{{ $icon->label }}</p>
                    <p class="text-xs text-slate-400">{{ $icon->group ?? 'general' }}</p>
                    @if ($icon->type === 'image')
                        <button type="button" wire:click="deleteIcon({{ $icon->id }})" class="mt-2 text-xs font-semibold text-red-500">Delete</button>
                    @endif
                </div>
            @empty
                <p class="text-sm text-slate-400 md:col-span-4">No icons found.</p>
            @endforelse
        </div>
    </div>

    <div class="grid gap-4 md:grid-cols-2">
        <form wire:submit.prevent="saveFontawesomeIcon" class="space-y-3 rounded-2xl border border-[#72E3BD]/60 bg-white/90 p-4">
            <h3 class="text-base font-semibold text-[#095C4A]">Add FontAwesome icon</h3>
            <div>
                <label class="text-xs text-slate-500">Label</label>
                <input type="text" wire:model.live="fontawesomeForm.label" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                @error('fontawesomeForm.label') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
            </div>
            <div>
                <label class="text-xs text-slate-500">Icon key</label>
                <input type="text" wire:model.live="fontawesomeForm.fa_class" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2" placeholder="fas:wallet" />
                <p class="text-[11px] text-slate-400">Format: <code>prefix:iconName</code> contoh <code>fas:wallet</code>, <code>far:calendar</code>, <code>fab:spotify</code>.</p>
                @error('fontawesomeForm.fa_class') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
            </div>
            <div>
                <label class="text-xs text-slate-500">Group</label>
                <input type="text" wire:model.live="fontawesomeForm.group" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2" />
            </div>
            <button type="submit" class="btn-primary w-full">Save FontAwesome icon</button>
        </form>
        <form wire:submit.prevent="saveCustomIcon" class="space-y-3 rounded-2xl border border-[#72E3BD]/60 bg-white/90 p-4">
            <h3 class="text-base font-semibold text-[#095C4A]">Upload custom icon</h3>
            <div>
                <label class="text-xs text-slate-500">Label</label>
                <input type="text" wire:model.live="customIconForm.label" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                @error('customIconForm.label') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
            </div>
            <div>
                <label class="text-xs text-slate-500">Group</label>
                <input type="text" wire:model.live="customIconForm.group" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2" />
            </div>
            <div>
                <label class="text-xs text-slate-500">Icon image (PNG)</label>
                <input type="file" wire:model="iconUpload" class="w-full rounded-2xl border border-dashed border-[#D2F9E7] px-3 py-2" />
                @error('iconUpload') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
            </div>
            <button type="submit" class="btn-primary w-full">Upload custom icon</button>
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
