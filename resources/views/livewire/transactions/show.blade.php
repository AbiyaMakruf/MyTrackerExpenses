@php use Illuminate\Support\Facades\Storage; @endphp

<section class="glass-card space-y-5">
    <div class="flex flex-wrap items-center justify-between gap-3">
        <div>
            <p class="text-xs uppercase tracking-[0.4em] text-[#08745C]">{{ __('Transaction detail') }}</p>
            <h1 class="text-2xl font-semibold text-[#095C4A]">{{ ucfirst($transaction->type) }} • {{ $transaction->transaction_date->format(config('myexpenses.default_datetime_format')) }}</h1>
        </div>
        <div class="flex flex-wrap gap-3">
            <a href="{{ route('records.add', ['transaction' => $transaction->id]) }}" class="btn-primary inline-flex items-center rounded-full px-4 py-2 text-sm font-semibold transition-all duration-200 ease-out hover:scale-[1.02] hover:brightness-110">
                {{ __('Edit transaction') }}
            </a>
            <button type="button" wire:click="deleteTransaction" class="rounded-full bg-red-500 px-4 py-2 text-sm font-semibold text-white transition-all duration-200 ease-out hover:scale-[1.02] hover:brightness-110">
                {{ __('Delete') }}
            </button>
        </div>
    </div>

    @if (session('status'))
        <div class="rounded-2xl bg-[#D2F9E7] px-4 py-3 text-sm font-semibold text-[#08745C]">
            {{ session('status') }}
        </div>
    @endif

    <div class="grid gap-4 md:grid-cols-2">
        <div class="rounded-2xl border border-[#D2F9E7] bg-white/90 p-5 shadow-md dark:bg-gray-800 dark:text-gray-200">
            <dl class="space-y-4">
                <div>
                    <dt class="text-xs uppercase text-slate-500">{{ __('Amount') }}</dt>
                    <dd class="text-3xl font-semibold text-[#095C4A]">{{ number_format($transaction->amount, 0) }} {{ $transaction->currency }}</dd>
                </div>
                <div class="grid grid-cols-2 gap-3 text-sm">
                    <div>
                        <dt class="text-xs uppercase text-slate-400">{{ __('Wallet') }}</dt>
                        <dd class="font-semibold">{{ $transaction->wallet->name ?? '—' }}</dd>
                    </div>
                    <div>
                        <dt class="text-xs uppercase text-slate-400">{{ __('Category') }}</dt>
                        <dd class="font-semibold">{{ $transaction->category->name ?? '—' }}</dd>
                    </div>
                    <div>
                        <dt class="text-xs uppercase text-slate-400">{{ __('Sub category') }}</dt>
                        <dd class="font-semibold">{{ $transaction->subCategory->name ?? '—' }}</dd>
                    </div>
                    <div>
                        <dt class="text-xs uppercase text-slate-400">{{ __('Payment type') }}</dt>
                        <dd class="font-semibold">{{ $transaction->payment_type ?? '—' }}</dd>
                    </div>
                </div>
                <div>
                    <dt class="text-xs uppercase text-slate-400">{{ __('Labels') }}</dt>
                    <dd class="flex flex-wrap gap-2">
                        @forelse ($transaction->labels as $label)
                            <span class="rounded-full bg-[#F2FFFA] px-3 py-1 text-xs font-semibold text-[#08745C]">{{ $label->name }}</span>
                        @empty
                            <span class="text-sm text-slate-400">{{ __('No label') }}</span>
                        @endforelse
                    </dd>
                </div>
                <div>
                    <dt class="text-xs uppercase text-slate-400">{{ __('Note') }}</dt>
                    <dd class="text-sm text-slate-600 dark:text-gray-300">{{ $transaction->note ?? '—' }}</dd>
                </div>
            </dl>
        </div>
        <div class="rounded-2xl border border-[#D2F9E7] bg-white/90 p-5 shadow-md dark:bg-gray-800 dark:text-gray-200">
            <h2 class="text-lg font-semibold text-[#095C4A]">{{ __('Meta') }}</h2>
            <dl class="mt-4 space-y-3 text-sm">
                <div class="flex items-center justify-between">
                    <dt class="text-slate-500">{{ __('Recurring?') }}</dt>
                    <dd class="font-semibold">{{ $transaction->recurringTemplate ? __('Yes') : __('No') }}</dd>
                </div>
                <div class="flex items-center justify-between">
                    <dt class="text-slate-500">{{ __('Subscription link') }}</dt>
                    <dd class="font-semibold">{{ $transaction->metadata['subscription_name'] ?? '—' }}</dd>
                </div>
                <div>
                    <dt class="text-slate-500">{{ __('Attachment') }}</dt>
                    <dd>
                        @if ($transaction->attachment_path)
                            <a href="{{ Storage::disk('public')->url($transaction->attachment_path) }}" class="text-[#08745C] underline" target="_blank">{{ __('View attachment') }}</a>
                        @else
                            <span class="text-slate-400">{{ __('No attachment') }}</span>
                        @endif
                    </dd>
                </div>
            </dl>
        </div>
    </div>
</section>
