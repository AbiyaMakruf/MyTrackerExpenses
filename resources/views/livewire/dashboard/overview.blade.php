@php use Illuminate\Support\Facades\Storage; use Illuminate\Support\Str; @endphp

<section class="glass-card">
    <div class="flex flex-col gap-3">
        <div class="flex items-center justify-between">
            <div>
                <p class="text-sm uppercase tracking-wide text-[#08745C]">Hi {{ auth()->user()->name }}</p>
                <h1 class="text-2xl font-semibold text-[#095C4A]">Your financial pulse</h1>
                <p class="text-xs text-slate-500">Tracking period: {{ $periodLabel }}</p>
            </div>
            <div class="flex items-center gap-2">
                <label for="period" class="text-xs font-medium text-slate-500">Period</label>
                <select wire:model.live="period" id="period" class="rounded-full border border-[#15B489]/40 px-3 py-1 text-sm text-[#095C4A]">
                    @foreach ($periodOptions as $key => $label)
                        <option value="{{ $key }}">{{ $label }}</option>
                    @endforeach
                </select>
            </div>
        </div>
        <div class="grid gap-4 md:grid-cols-3">
            <div class="rounded-2xl border border-white/80 bg-gradient-to-br from-[#095C4A] to-[#08745C] p-4 text-white shadow-xl">
                <p class="text-xs uppercase tracking-wide">Cash Flow</p>
                <div class="mt-3 flex flex-wrap gap-4">
                    <div>
                        <p class="text-xs text-white/70">Income</p>
                        <p class="text-2xl font-semibold">{{ number_format($cashFlow['income'], 0) }} {{ auth()->user()->base_currency }}</p>
                    </div>
                    <div>
                        <p class="text-xs text-white/70">Expense</p>
                        <p class="text-2xl font-semibold">{{ number_format($cashFlow['expense'], 0) }} {{ auth()->user()->base_currency }}</p>
                    </div>
                </div>
                <div class="mt-4 flex items-center justify-between text-xs text-white/80">
                    <span>Net balance</span>
                    <span class="font-semibold">{{ number_format($cashFlow['income'] - $cashFlow['expense'], 0) }}</span>
                </div>
            </div>

            <div class="rounded-2xl border border-white/60 bg-white/70 p-4 shadow-inner">
                <p class="text-xs uppercase tracking-wide text-slate-500">Wallet overview</p>
                <div class="mt-3 space-y-4">
                    @foreach ($walletGroups as $group => $items)
                        <div>
                            <p class="text-xs font-semibold uppercase tracking-wide text-slate-400">{{ $group }}</p>
                            <div class="mt-2 space-y-2">
                                @foreach ($items as $wallet)
                                    @php
                                        $icon = $wallet->iconDefinition;
                                        $bg = $wallet->icon_background ?: '#F6FFFA';
                                        $color = $wallet->icon_color ?: '#095C4A';
                                    @endphp
                                    <div class="flex items-center justify-between rounded-xl border border-[#D2F9E7] bg-white px-3 py-2 shadow-sm">
                                        <div class="flex items-center gap-3">
                                            <div class="flex h-10 w-10 items-center justify-center rounded-2xl" style="background-color: {{ $bg }}; color: {{ $color }}">
                                                @if ($icon && $icon->type === 'image' && $icon->image_path)
                                                    <img src="{{ Storage::disk('public')->url($icon->image_path) }}" alt="{{ $icon->label }}" class="h-6 w-6 object-contain">
                                                @elseif ($icon && $icon->fa_class)
                                                    <span data-fa-icon="{{ $icon->fa_class }}" class="text-lg"></span>
                                                @else
                                                    <span class="text-sm font-semibold">{{ Str::upper(Str::substr($wallet->name, 0, 2)) }}</span>
                                                @endif
                                            </div>
                                            <div>
                                                <p class="text-sm font-semibold text-[#095C4A]">{{ $wallet->name }}</p>
                                                <p class="text-xs text-slate-500">{{ strtoupper($wallet->currency) }}</p>
                                            </div>
                                        </div>
                                        <div class="text-right">
                                            <p class="text-base font-semibold text-[#08745C]">{{ number_format($wallet->current_balance, 0) }}</p>
                                            <p class="text-[10px] text-slate-400">{{ ucfirst($wallet->type) }}</p>
                                        </div>
                                    </div>
                                @endforeach
                            </div>
                        </div>
                    @endforeach
                </div>
            </div>

            <div class="rounded-2xl border border-white/60 bg-white/70 p-4 shadow-inner">
                <p class="text-xs uppercase tracking-wide text-slate-500">Top expenses</p>
                <div class="mt-3 space-y-3">
                    @forelse ($topExpenses as $expense)
                        <div class="flex items-center justify-between">
                            <div>
                                <p class="text-sm font-semibold text-[#095C4A]">{{ $expense->category->name ?? 'Uncategorized' }}</p>
                                <p class="text-xs text-slate-500">{{ number_format($expense->total, 0) }} {{ auth()->user()->base_currency }}</p>
                            </div>
                            <div class="h-2 w-20 rounded-full bg-[#D2F9E7]">
                                <div class="h-2 rounded-full bg-[#15B489]" style="width: {{ min(100, ($expense->total / max(1, $topExpenses->max('total'))) * 100) }}%"></div>
                            </div>
                        </div>
                    @empty
                        <p class="text-sm text-slate-400">No expenses recorded yet.</p>
                    @endforelse
                </div>
            </div>
        </div>
</section>

@php
    $balanceChart = [
        'type' => 'line',
        'data' => [
            'labels' => collect($balanceTrend)->pluck('date'),
            'datasets' => [
                [
                    'label' => 'Net balance',
                    'data' => collect($balanceTrend)->pluck('net'),
                    'borderColor' => '#08745C',
                    'backgroundColor' => 'rgba(21, 180, 137, 0.2)',
                    'tension' => 0.4,
                    'fill' => true,
                ],
            ],
        ],
        'options' => [
            'plugins' => [
                'legend' => ['display' => false],
            ],
            'scales' => [
                'y' => ['beginAtZero' => true],
            ],
        ],
    ];

    $cashFlowChart = [
        'type' => 'bar',
        'data' => [
            'labels' => ['Income', 'Expense'],
            'datasets' => [
                [
                    'label' => 'Amount',
                    'data' => [$cashFlow['income'], $cashFlow['expense']],
                    'backgroundColor' => ['#08745C', '#FB7185'],
                    'borderRadius' => 12,
                ],
            ],
        ],
        'options' => [
            'plugins' => [
                'legend' => ['display' => false],
            ],
            'scales' => [
                'y' => ['beginAtZero' => true],
            ],
        ],
    ];
@endphp

<div class="grid gap-4 md:grid-cols-2">
    <div class="glass-card">
        <div class="flex items-center justify-between">
            <div>
                <h2 class="text-lg font-semibold text-[#095C4A]">Balance trend</h2>
                <p class="text-xs text-slate-500">Area chart • {{ $periodLabel }}</p>
            </div>
        </div>
        <div class="mt-3 h-64" data-chart>
            <canvas data-chart='@json($balanceChart)'></canvas>
        </div>
    </div>

    <div class="glass-card">
        <div class="flex items-center justify-between">
            <div>
                <h2 class="text-lg font-semibold text-[#095C4A]">Cash flow</h2>
                <p class="text-xs text-slate-500">Income vs expense</p>
            </div>
        </div>
        <div class="mt-3 h-64" data-chart>
            <canvas data-chart='@json($cashFlowChart)'></canvas>
        </div>
    </div>
</div>

<div class="grid gap-4 md:grid-cols-3">
    <div class="glass-card space-y-4">
        <div class="flex items-center justify-between">
            <div>
                <h3 class="text-lg font-semibold text-[#095C4A]">Budget spending</h3>
                <p class="text-xs text-slate-500">Keep budgets on track</p>
            </div>
            <a href="{{ route('planning') }}" wire:navigate class="text-xs font-semibold text-[#08745C]">View all</a>
        </div>
        <div class="space-y-4">
            @forelse ($budgetProgress as $budget)
                <div>
                    <div class="flex items-center justify-between">
                        <p class="text-sm font-semibold text-[#095C4A]">{{ $budget['budget']->name }}</p>
                        <p class="text-xs text-slate-500">{{ number_format($budget['spent'], 0) }} / {{ number_format($budget['budget']->amount, 0) }}</p>
                    </div>
                    <div class="mt-2 h-2 rounded-full bg-[#D2F9E7]">
                        <div class="h-2 rounded-full bg-[#08745C]" style="width: {{ $budget['percentage'] }}%"></div>
                    </div>
                </div>
            @empty
                <p class="text-sm text-slate-400">You have no budgets yet.</p>
            @endforelse
        </div>
    </div>

    <div class="glass-card space-y-4">
        <div class="flex items-center justify-between">
            <div>
                <h3 class="text-lg font-semibold text-[#095C4A]">Savings goals</h3>
                <p class="text-xs text-slate-500">Stay motivated</p>
            </div>
            <a href="{{ route('planning') }}#goals" wire:navigate class="text-xs font-semibold text-[#08745C]">Manage</a>
        </div>
        <div class="space-y-3">
            @forelse ($goalsSummary as $goal)
                <div class="flex items-center gap-3 rounded-2xl bg-white/80 p-3">
                    <div class="relative h-14 w-14">
                        <svg viewBox="0 0 36 36" class="h-14 w-14 -rotate-90">
                            <path
                                class="text-slate-200"
                                stroke="currentColor"
                                stroke-width="3.8"
                                fill="none"
                                d="M18 2.0845
                                    a 15.9155 15.9155 0 0 1 0 31.831
                                    a 15.9155 15.9155 0 0 1 0 -31.831"
                            />
                            <path
                                class="text-[#15B489]"
                                stroke="currentColor"
                                stroke-width="3.8"
                                stroke-dasharray="{{ $goal['progress'] }}, 100"
                                stroke-linecap="round"
                                fill="none"
                                d="M18 2.0845
                                    a 15.9155 15.9155 0 0 1 0 31.831
                                    a 15.9155 15.9155 0 0 1 0 -31.831"
                            />
                        </svg>
                        <span class="absolute inset-0 flex items-center justify-center text-xs font-semibold text-[#095C4A]">
                            {{ $goal['progress'] }}%
                        </span>
                    </div>
                    <div class="flex-1">
                        <p class="text-sm font-semibold text-[#095C4A]">{{ $goal['goal']->name }}</p>
                        <p class="text-xs text-slate-500">Target {{ number_format($goal['goal']->target_amount, 0) }}</p>
                        @if ($goal['is_near_deadline'])
                            <p class="text-xs font-semibold text-[#FB7185]">Approaching deadline</p>
                        @endif
                    </div>
                </div>
            @empty
                <p class="text-sm text-slate-400">No goals yet.</p>
            @endforelse
        </div>
    </div>

    <div class="glass-card space-y-4">
        <div class="flex items-center justify-between">
            <div>
                <h3 class="text-lg font-semibold text-[#095C4A]">Upcoming recurring</h3>
                <p class="text-xs text-slate-500">What to expect next</p>
            </div>
        </div>
        <div class="space-y-3 text-sm">
            <div>
                <p class="text-xs uppercase text-slate-400">Next 7 days</p>
                <ul class="mt-2 space-y-2">
                    @forelse ($upcomingRecurring['seven_days'] as $item)
                        <li class="flex items-center justify-between rounded-xl bg-white/70 px-3 py-2">
                            <span>{{ $item->note ?? $item->type }}</span>
                            <span class="font-semibold text-[#08745C]">{{ number_format($item->amount, 0) }}</span>
                        </li>
                    @empty
                        <p class="text-xs text-slate-400">No recurring actions.</p>
                    @endforelse
                </ul>
            </div>
            <div>
                <p class="text-xs uppercase text-slate-400">Next 30 days</p>
                <ul class="mt-2 space-y-2">
                    @forelse ($upcomingRecurring['thirty_days'] as $item)
                        <li class="flex items-center justify-between rounded-xl bg-white/70 px-3 py-2">
                            <span>{{ $item->note ?? $item->type }}</span>
                            <span class="font-semibold text-[#08745C]">{{ optional($item->next_run_at)->format('d M') }}</span>
                        </li>
                    @empty
                        <p class="text-xs text-slate-400">No scheduled recurring.</p>
                    @endforelse
                </ul>
            </div>
        </div>
    </div>
</div>

<div class="grid gap-4 md:grid-cols-2">
    <div class="glass-card">
        <div class="flex items-center justify-between mb-3">
            <div>
                <h3 class="text-lg font-semibold text-[#095C4A]">Recent transactions</h3>
                <p class="text-xs text-slate-500">Latest income & expenses</p>
            </div>
            <a href="{{ route('records.add') }}" wire:navigate class="text-xs font-semibold text-[#08745C]">Add record</a>
        </div>
        <div class="space-y-3">
            @foreach ($recentTransactions as $transaction)
                @php
                    $categoryForIcon = $transaction->subCategory ?? $transaction->category;
                    $iconDef = $categoryForIcon?->icon;
                    $iconBg = optional($categoryForIcon)->icon_background ?? optional($categoryForIcon)->color ?? '#F6FFFA';
                    $iconColor = optional($categoryForIcon)->icon_color ?? '#095C4A';
                @endphp
                <a href="{{ route('transactions.show', $transaction) }}" class="flex items-center gap-4 rounded-2xl border border-[#E2F5ED] bg-white px-3 py-3 shadow-sm transition-all duration-200 ease-out hover:scale-[1.01]">
                    <div class="flex h-12 w-12 items-center justify-center rounded-2xl" style="background-color: {{ $iconBg }}; color: {{ $iconColor }}">
                        @if ($iconDef && $iconDef->type === 'image' && $iconDef->image_path)
                            <img src="{{ Storage::disk('public')->url($iconDef->image_path) }}" alt="{{ $iconDef->label }}" class="h-8 w-8 object-contain">
                        @elseif ($iconDef && $iconDef->fa_class)
                            <span data-fa-icon="{{ $iconDef->fa_class }}" class="text-lg"></span>
                        @else
                            <span class="text-sm font-semibold">{{ Str::upper(Str::substr($transaction->category->name ?? $transaction->type, 0, 2)) }}</span>
                        @endif
                    </div>
                    <div class="flex-1">
                        <p class="text-sm font-semibold text-[#095C4A]">
                            {{ $transaction->category->name ?? ucfirst($transaction->type) }}
                            @if ($transaction->subCategory)
                                <span class="text-xs font-normal text-slate-500">• {{ $transaction->subCategory->name }}</span>
                            @endif
                        </p>
                        <p class="text-xs text-slate-500">{{ $transaction->wallet->name }} • {{ $transaction->transaction_date->format('l, d F H:i') }}</p>
                    </div>
                    <div class="text-right">
                        <p class="{{ $transaction->type === 'income' ? 'text-[#08745C]' : 'text-[#FB7185]' }} text-base font-semibold">
                            {{ $transaction->type === 'income' ? '+' : '-' }}{{ number_format($transaction->amount, 0) }}
                        </p>
                        <p class="text-[10px] text-slate-400">{{ $transaction->currency }}</p>
                    </div>
                </a>
            @endforeach
        </div>
    </div>

    <div class="glass-card space-y-4">
        <div class="flex items-center justify-between">
            <div>
                <h3 class="text-lg font-semibold text-[#095C4A]">Active subscriptions</h3>
                <p class="text-xs text-slate-500">Total monthly: {{ number_format($upcomingSubscriptions['total_monthly'], 0) }} {{ auth()->user()->base_currency }}</p>
            </div>
            <a href="{{ route('planning') }}#subscriptions" wire:navigate class="text-xs font-semibold text-[#08745C]">Manage</a>
        </div>
        <div class="space-y-3">
            @forelse ($upcomingSubscriptions['items'] as $subscription)
                <div class="flex items-center justify-between rounded-2xl bg-white/80 px-3 py-2">
                    <div>
                        <p class="text-sm font-semibold">{{ $subscription->name }}</p>
                        <p class="text-xs text-slate-500">Next billing {{ optional($subscription->next_billing_date)->format('d M') }}</p>
                    </div>
                    <p class="text-sm font-semibold text-[#08745C]">{{ number_format($subscription->amount, 0) }}</p>
                </div>
            @empty
                <p class="text-sm text-slate-400">No active subscriptions.</p>
            @endforelse
        </div>
    </div>
</div>
