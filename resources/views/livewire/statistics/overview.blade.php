@php
    $categoryChart = [
        'type' => 'doughnut',
        'data' => [
            'labels' => $categoryBreakdown->map(fn ($item) => $item->category->name ?? 'Uncategorized'),
            'datasets' => [
                [
                    'data' => $categoryBreakdown->pluck('total'),
                    'backgroundColor' => ['#095C4A', '#08745C', '#15B489', '#72E3BD', '#FB7185'],
                    'borderWidth' => 0,
                ],
            ],
        ],
    ];

    $incomeExpenseChart = [
        'type' => 'bar',
        'data' => [
            'labels' => ['Income', 'Expense'],
            'datasets' => [
                [
                    'data' => [$summary['income'], $summary['expense']],
                    'backgroundColor' => ['#08745C', '#FB7185'],
                    'borderRadius' => 14,
                ],
            ],
        ],
        'options' => [
            'plugins' => ['legend' => ['display' => false]],
        ],
    ];

    $trendChart = [
        'type' => 'line',
        'data' => [
            'labels' => $trendData->pluck('day')->map(fn ($day) => \Illuminate\Support\Carbon::parse($day)->format('d M')),
            'datasets' => [
                [
                    'label' => 'Net',
                    'data' => $trendData->pluck('total'),
                    'borderColor' => '#095C4A',
                    'backgroundColor' => 'rgba(9,92,74,0.2)',
                    'fill' => true,
                    'tension' => 0.4,
                ],
            ],
        ],
        'options' => [
            'plugins' => ['legend' => ['display' => false]],
        ],
    ];
@endphp

<section class="glass-card space-y-6">
    <div class="flex flex-col gap-2">
        <h1 class="text-2xl font-semibold text-[#095C4A]">Statistics</h1>
        <p class="text-sm text-slate-500">Visualize income, expenses, and subscription spending.</p>
    </div>

    <div class="grid gap-3 md:grid-cols-4">
        <div>
            <label class="text-xs text-slate-500">Range</label>
            <select wire:model.live="range" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                @foreach ($rangeOptions as $key => $label)
                    <option value="{{ $key }}">{{ $label }}</option>
                @endforeach
            </select>
        </div>
        @if ($range === 'custom')
            <div>
                <label class="text-xs text-slate-500">From</label>
                <input type="text" data-datepicker wire:model.live="dateFrom" readonly class="w-full cursor-pointer rounded-2xl border border-[#D2F9E7] px-3 py-2" />
            </div>
            <div>
                <label class="text-xs text-slate-500">To</label>
                <input type="text" data-datepicker wire:model.live="dateTo" readonly class="w-full cursor-pointer rounded-2xl border border-[#D2F9E7] px-3 py-2" />
            </div>
        @endif
        <div>
            <label class="text-xs text-slate-500">Type</label>
            <select wire:model.live="transactionType" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                <option value="all">All</option>
                <option value="income">Income</option>
                <option value="expense">Expense</option>
            </select>
        </div>
        <div>
            <label class="text-xs text-slate-500">Wallet</label>
            <select wire:model.live="walletId" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                <option value="">All wallets</option>
                @foreach ($wallets as $wallet)
                    <option value="{{ $wallet->id }}">{{ $wallet->name }}</option>
                @endforeach
            </select>
        </div>
        <div>
            <label class="text-xs text-slate-500">Category</label>
            <select wire:model.live="categoryId" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                <option value="">All categories</option>
                @foreach ($categories as $category)
                    <option value="{{ $category->id }}">{{ $category->name }}</option>
                @endforeach
            </select>
        </div>
    </div>

    <div class="grid gap-4 md:grid-cols-3">
        <div class="rounded-2xl border border-white/70 bg-white/80 p-4 shadow-inner">
            <p class="text-xs uppercase text-slate-400">Total income</p>
            <p class="text-3xl font-semibold text-[#08745C] mt-2">{{ number_format($summary['income'], 0) }}</p>
        </div>
        <div class="rounded-2xl border border-white/70 bg-white/80 p-4 shadow-inner">
            <p class="text-xs uppercase text-slate-400">Total expense</p>
            <p class="text-3xl font-semibold text-[#FB7185] mt-2">{{ number_format($summary['expense'], 0) }}</p>
        </div>
        <div class="rounded-2xl border border-white/70 bg-white/80 p-4 shadow-inner">
            <p class="text-xs uppercase text-slate-400">Net balance</p>
            <p class="text-3xl font-semibold text-[#095C4A] mt-2">{{ number_format($summary['net'], 0) }}</p>
        </div>
    </div>

    <div class="grid gap-4 md:grid-cols-2">
        <div class="glass-card">
            <h3 class="text-lg font-semibold text-[#095C4A]">Category distribution</h3>
            <div class="mt-3 h-64" data-chart>
                <canvas data-chart='@json($categoryChart)'></canvas>
            </div>
        </div>
        <div class="glass-card">
            <h3 class="text-lg font-semibold text-[#095C4A]">Income vs expense</h3>
            <div class="mt-3 h-64" data-chart>
                <canvas data-chart='@json($incomeExpenseChart)'></canvas>
            </div>
        </div>
    </div>

    <div class="glass-card">
        <h3 class="text-lg font-semibold text-[#095C4A]">Trend</h3>
        <div class="mt-3 h-72" data-chart>
            <canvas data-chart='@json($trendChart)'></canvas>
        </div>
    </div>
</section>
