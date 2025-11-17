<div class="glass-card">
    <div class="flex flex-col gap-4">
        <div class="flex flex-col gap-2">
            <h1 class="text-2xl font-semibold text-[#095C4A]">Add record</h1>
            <p class="text-sm text-slate-500">Capture your expense, income or transfer instantly.</p>
        </div>

        <div class="flex flex-wrap gap-3">
            @foreach (['expense' => 'Expense', 'income' => 'Income', 'transfer' => 'Transfer'] as $value => $label)
                <button type="button" wire:click="$set('mode', '{{ $value }}')" @class([
                    'rounded-full px-4 py-2 text-sm font-semibold transition',
                    'bg-[#095C4A] text-white shadow' => $mode === $value,
                    'bg-white text-slate-600' => $mode !== $value,
                ])>
                    {{ $label }}
                </button>
            @endforeach
        </div>

        @if (session('status'))
            <div class="rounded-2xl bg-[#D2F9E7] px-4 py-2 text-sm font-semibold text-[#08745C]">
                {{ session('status') }}
            </div>
        @endif

        @if ($mode === 'transfer')
            <form wire:submit.prevent="save" class="space-y-4">
                <div class="grid gap-3 md:grid-cols-2">
                    <div>
                        <label class="text-xs text-slate-500">From wallet</label>
                        <select wire:model.live="wallet_id" class="w-full rounded-2xl border border-[#D2F9E7] bg-white px-4 py-2">
                            <option value="">Select wallet</option>
                            @foreach ($wallets as $wallet)
                                <option value="{{ $wallet->id }}">{{ $wallet->name }}</option>
                            @endforeach
                        </select>
                        @error('wallet_id') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
                    </div>
                    <div>
                        <label class="text-xs text-slate-500">To wallet</label>
                        <select wire:model.live="to_wallet_id" class="w-full rounded-2xl border border-[#D2F9E7] bg-white px-4 py-2">
                            <option value="">Select wallet</option>
                            @foreach ($wallets as $wallet)
                                <option value="{{ $wallet->id }}">{{ $wallet->name }}</option>
                            @endforeach
                        </select>
                        @error('to_wallet_id') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
                    </div>
                </div>

                <div class="grid gap-3 md:grid-cols-2">
                    <div>
                        <label class="text-xs text-slate-500">Amount</label>
                        <input type="text" inputmode="decimal" data-money-input wire:model.live="transfer_amount" class="w-full rounded-2xl border border-[#D2F9E7] bg-white px-4 py-2" placeholder="0.00" />
                        @error('transfer_amount') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
                    </div>
                    <div>
                        <label class="text-xs text-slate-500">Date & time</label>
                        <input type="text" data-datetimepicker wire:model.live="transfer_date" readonly class="w-full cursor-pointer rounded-2xl border border-[#D2F9E7] bg-white px-4 py-2" />
                        @error('transfer_date') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
                    </div>
                </div>

                <div>
                    <label class="text-xs text-slate-500">Note</label>
                    <textarea wire:model.live="transfer_note" rows="2" class="w-full rounded-2xl border border-[#D2F9E7] bg-white px-4 py-2" placeholder="Why are you moving this money?"></textarea>
                </div>

                <button type="submit" class="btn-primary w-full md:w-auto">Save transfer</button>
            </form>
        @else
            <form wire:submit.prevent="save" class="space-y-5">
                <div class="grid gap-3 md:grid-cols-2">
                    <div>
                        <label class="text-xs text-slate-500">Amount</label>
                        <input type="text" inputmode="decimal" data-money-input wire:model.live="amount" class="w-full rounded-2xl border border-[#D2F9E7] bg-white px-4 py-2 text-xl font-semibold text-[#095C4A]" placeholder="0.00" />
                        @error('amount') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
                    </div>
                    <div>
                        <label class="text-xs text-slate-500">Wallet</label>
                        <select wire:model.live="wallet_id" class="w-full rounded-2xl border border-[#D2F9E7] bg-white px-4 py-2">
                            <option value="">Select wallet</option>
                            @foreach ($wallets as $wallet)
                                <option value="{{ $wallet->id }}">{{ $wallet->name }}</option>
                            @endforeach
                        </select>
                        @error('wallet_id') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
                    </div>
                </div>

                <div class="grid gap-3 md:grid-cols-2">
                    <div>
                        <label class="text-xs text-slate-500">Category</label>
                        <select wire:model.live="category_id" class="w-full rounded-2xl border border-[#D2F9E7] bg-white px-4 py-2">
                            <option value="">No category</option>
                            @foreach ($categories->whereNull('parent_id') as $category)
                                <option value="{{ $category->id }}">{{ $category->name }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div>
                        <label class="text-xs text-slate-500">Sub-category</label>
                        <select wire:model.live="sub_category_id" class="w-full rounded-2xl border border-[#D2F9E7] bg-white px-4 py-2">
                            <option value="">Optional</option>
                            @foreach ($categories->where('parent_id', $category_id) as $child)
                                <option value="{{ $child->id }}">{{ $child->name }}</option>
                            @endforeach
                        </select>
                    </div>
                </div>

                <div class="grid gap-3 md:grid-cols-2">
                    <div>
                        <label class="text-xs text-slate-500">Date & time</label>
                        <input type="text" data-datetimepicker wire:model.live="transaction_date" readonly class="w-full cursor-pointer rounded-2xl border border-[#D2F9E7] bg-white px-4 py-2" />
                        @error('transaction_date') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
                    </div>
                    <div>
                        <label class="text-xs text-slate-500">Payment type</label>
                        <select wire:model.live="payment_type" class="w-full rounded-2xl border border-[#D2F9E7] bg-white px-4 py-2">
                            <option value="">Select type</option>
                            @foreach ($paymentTypes as $paymentType)
                                <option value="{{ $paymentType }}">{{ ucfirst(str_replace('_', ' ', $paymentType)) }}</option>
                            @endforeach
                        </select>
                        @error('payment_type') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
                    </div>
                </div>

                <div>
                    <label class="text-xs text-slate-500">Note</label>
                    <textarea wire:model.live="note" rows="2" class="w-full rounded-2xl border border-[#D2F9E7] bg-white px-4 py-2" placeholder="Add a quick note"></textarea>
                </div>

                <div>
                    <label class="text-xs text-slate-500">Labels</label>
                    <div class="flex flex-wrap gap-2">
                        @foreach ($labels as $label)
                            <label class="inline-flex cursor-pointer items-center gap-2 rounded-full border border-[#D2F9E7] bg-white px-3 py-1 text-xs">
                                <input type="checkbox" value="{{ $label->id }}" wire:model.live="labelIds" class="rounded text-[#095C4A]" />
                                {{ $label->name }}
                            </label>
                        @endforeach
                    </div>
                </div>

                @if ($allowAttachmentUploads)
                    <div>
                        <label class="text-xs text-slate-500">Attachments</label>
                        <input type="file" wire:model="receipt" class="w-full rounded-2xl border border-dashed border-[#72E3BD] bg-white px-4 py-6 text-center text-sm text-[#08745C]" />
                        @error('receipt') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
                        @if ($receipt)
                            <p class="mt-1 text-xs text-slate-500">Uploading {{ $receipt->getClientOriginalName() }}</p>
                        @endif
                    </div>
                @endif

                <div class="space-y-3 rounded-2xl border border-[#72E3BD]/60 bg-white/70 p-4">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm font-semibold text-[#095C4A]">Recurring transaction</p>
                            <p class="text-xs text-slate-500">Automatically post this record</p>
                        </div>
                        <label class="inline-flex cursor-pointer items-center gap-2">
                            <input type="checkbox" wire:model.live="is_recurring" class="rounded-full text-[#095C4A]" />
                            <span class="text-sm font-semibold">{{ $is_recurring ? 'Enabled' : 'Off' }}</span>
                        </label>
                    </div>

                    @if ($is_recurring)
                        <div class="grid gap-3 md:grid-cols-2">
                            <div>
                                <label class="text-xs text-slate-500">Interval</label>
                                <select wire:model.live="recurring_interval" class="w-full rounded-2xl border border-[#D2F9E7] bg-white px-4 py-2">
                                    @foreach ($intervalOptions as $option)
                                        <option value="{{ $option }}">{{ ucfirst($option) }}</option>
                                    @endforeach
                                </select>
                            </div>
                            <div>
                                <label class="text-xs text-slate-500">Auto-post</label>
                                <select wire:model.live="auto_post" class="w-full rounded-2xl border border-[#D2F9E7] bg-white px-4 py-2">
                                    <option value="1">Yes</option>
                                    <option value="0">No</option>
                                </select>
                            </div>
                        </div>
                        @if ($recurring_interval === 'custom')
                            <div>
                                <label class="text-xs text-slate-500">Repeat every (days)</label>
                                <input type="number" min="1" wire:model.live="recurring_custom_days" class="w-full rounded-2xl border border-[#D2F9E7] bg-white px-4 py-2" />
                                @error('recurring_custom_days') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
                            </div>
                        @endif
                        <div>
                            <label class="text-xs text-slate-500">End date (optional)</label>
                            <input type="text" data-datepicker wire:model.live="recurring_end_date" readonly class="w-full cursor-pointer rounded-2xl border border-[#D2F9E7] bg-white px-4 py-2" />
                            @error('recurring_end_date') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
                        </div>
                    @endif
                </div>

                <button type="submit" class="btn-primary w-full md:w-auto">Save {{ $mode }}</button>
            </form>
        @endif
    </div>
</div>
