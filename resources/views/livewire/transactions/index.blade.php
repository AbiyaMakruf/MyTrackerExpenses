@php
    $trendChart = [
        'type' => 'line',
        'data' => [
            'labels' => $trend->map(fn ($row) => \Illuminate\Support\Carbon::parse($row->day)->format('d M')),
            'datasets' => [
                [
                    'label' => 'Net',
                    'data' => $trend->pluck('net'),
                    'borderColor' => '#095C4A',
                    'backgroundColor' => 'rgba(9,92,74,0.15)',
                    'fill' => true,
                    'tension' => 0.4,
                ],
            ],
        ],
        'options' => [
            'plugins' => ['legend' => ['display' => false]],
        ],
    ];

    $distributionChart = [
        'type' => 'doughnut',
        'data' => [
            'labels' => $distribution->map(fn ($row) => $row->category->name ?? 'Other'),
            'datasets' => [
                [
                    'data' => $distribution->pluck('total'),
                    'backgroundColor' => ['#095C4A', '#08745C', '#15B489', '#72E3BD', '#F97316', '#A855F7'],
                ],
            ],
        ],
        'options' => [
            'plugins' => ['legend' => ['position' => 'bottom']],
        ],
    ];
@endphp

<section class="glass-card space-y-6">
    <div class="flex flex-col gap-2">
        <h1 class="text-2xl font-semibold text-[#095C4A]">Transactions</h1>
        <p class="text-sm text-slate-500">Filter, explore, and export your complete transaction history.</p>
    </div>

    <div class="grid gap-4 md:grid-cols-4">
        <div>
            <label class="text-xs text-slate-500">Wallet</label>
            <select wire:model.live="walletId" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                <option value="">{{ __('All wallets') }}</option>
                @foreach ($wallets as $wallet)
                    <option value="{{ $wallet->id }}">{{ $wallet->name }}</option>
                @endforeach
            </select>
        </div>
        <div>
            <label class="text-xs text-slate-500">Type</label>
            <select wire:model.live="type" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                <option value="all">All</option>
                <option value="income">Income</option>
                <option value="expense">Expense</option>
                <option value="transfer">Transfer</option>
            </select>
        </div>
        <div>
            <label class="text-xs text-slate-500">Range</label>
            <select wire:model.live="range" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                @foreach (['daily', 'weekly', 'monthly', 'yearly', 'custom'] as $option)
                    <option value="{{ $option }}">{{ ucfirst($option) }}</option>
                @endforeach
            </select>
        </div>
        <div class="grid grid-cols-2 gap-2" x-data>
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
        </div>
    </div>

    <div class="grid gap-4 md:grid-cols-4">
        <div>
            <label class="text-xs text-slate-500">Category</label>
            <select wire:model.live="categoryId" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                <option value="">{{ __('All categories') }}</option>
                @foreach ($categories as $category)
                    <option value="{{ $category->id }}">{{ $category->name }}</option>
                @endforeach
            </select>
        </div>
        <div>
            <label class="text-xs text-slate-500">Sub-category</label>
            <select wire:model.live="subCategoryId" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                <option value="">{{ __('All sub-categories') }}</option>
                @foreach ($subCategories as $child)
                    <option value="{{ $child->id }}">{{ $child->name }}</option>
                @endforeach
            </select>
        </div>
        <div class="md:col-span-2">
            <label class="text-xs text-slate-500">Labels</label>
            <div class="flex flex-wrap gap-2 rounded-2xl border border-[#D2F9E7] p-2">
                @foreach ($labels as $label)
                    <label class="inline-flex items-center gap-2 rounded-full border border-[#D2F9E7] px-3 py-1 text-xs font-semibold">
                        <input type="checkbox" value="{{ $label->id }}" wire:model.live="labelIds" class="rounded text-[#095C4A]" />
                        {{ $label->name }}
                    </label>
                @endforeach
            </div>
        </div>
    </div>

    <div class="grid gap-4 md:grid-cols-2">
        <div class="glass-card h-64" data-chart>
            <canvas data-chart='@json($trendChart)'></canvas>
        </div>
        <div class="glass-card h-64" data-chart>
            <canvas data-chart='@json($distributionChart)'></canvas>
        </div>
    </div>

    <div class="rounded-3xl border border-[#D2F9E7] bg-white/90 p-4 shadow-lg">
        <div class="flex items-center justify-between">
            <h2 class="text-lg font-semibold text-[#095C4A]">Transaction list</h2>
            <span class="text-xs text-slate-500">{{ $transactions->total() }} records</span>
        </div>
        <div class="mt-3 overflow-x-auto">
            <table class="w-full min-w-[640px] text-left text-sm text-slate-600">
                <thead class="text-xs uppercase text-slate-400">
                    <tr>
                        <th class="px-3 py-2">Date</th>
                        <th class="px-3 py-2">Wallet</th>
                        <th class="px-3 py-2">Category</th>
                        <th class="px-3 py-2">Labels</th>
                        <th class="px-3 py-2 text-right">Amount</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-[#F1F5F9]">
                    @foreach ($transactions as $transaction)
                        <tr>
                            <td class="px-3 py-3 text-slate-500">{{ $transaction->transaction_date->format('d M Y H:i') }}</td>
                            <td class="px-3 py-3 font-semibold text-[#095C4A]">{{ $transaction->wallet->name }}</td>
                            <td class="px-3 py-3">
                                <div class="text-sm font-semibold text-[#095C4A]">{{ $transaction->category->name ?? ucfirst($transaction->type) }}</div>
                                @if ($transaction->subCategory)
                                    <div class="text-xs text-slate-500">{{ $transaction->subCategory->name }}</div>
                                @endif
                            </td>
                            <td class="px-3 py-3">
                                <div class="flex flex-wrap gap-1">
                                    @foreach ($transaction->labels as $label)
                                        <span class="rounded-full bg-[#F6FFFA] px-2 py-1 text-[10px] font-semibold text-[#095C4A]">{{ $label->name }}</span>
                                    @endforeach
                                </div>
                            </td>
                            <td class="px-3 py-3 text-right font-semibold {{ $transaction->type === 'income' ? 'text-[#08745C]' : 'text-[#FB7185]' }}">
                                {{ $transaction->type === 'income' ? '+' : '-' }}{{ number_format($transaction->amount, 0) }}
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
        <div class="mt-3">
            {{ $transactions->links() }}
        </div>
    </div>
</section>
