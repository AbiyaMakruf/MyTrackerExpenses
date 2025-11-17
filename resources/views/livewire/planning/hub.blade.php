<section class="glass-card space-y-5">
    <div class="flex flex-col gap-2">
        <h1 class="text-2xl font-semibold text-[#095C4A]">Planning center</h1>
        <p class="text-sm text-slate-500">Plan payments, budgets, goals, and subscriptions from one mobile-first hub.</p>
    </div>

    <div class="flex flex-wrap gap-2">
        @foreach ([
            'planned-payments' => 'Planned payments',
            'budgets' => 'Budgets',
            'goals' => 'Goals',
            'subscriptions' => 'Subscriptions',
        ] as $key => $label)
            <button type="button" wire:click="setTab('{{ $key }}')" @class([
                'rounded-full px-4 py-2 text-sm font-semibold',
                'bg-[#095C4A] text-white shadow' => $tab === $key,
                'bg-white text-slate-600' => $tab !== $key,
            ])>
                {{ $label }}
            </button>
        @endforeach
    </div>

    @if (session('planning_status'))
        <div class="rounded-2xl bg-[#D2F9E7] px-4 py-2 text-sm font-semibold text-[#08745C]">
            {{ session('planning_status') }}
        </div>
    @endif

    @if ($tab === 'planned-payments')
        <div class="grid gap-4 md:grid-cols-2">
            <div class="space-y-3">
                <h2 class="text-lg font-semibold text-[#095C4A]">Upcoming payments</h2>
                <div class="divide-y divide-[#D2F9E7]">
                    @forelse ($plannedPayments as $payment)
                        <div class="py-3">
                            <div class="flex items-center justify-between">
                                <div>
                                    <p class="text-sm font-semibold">{{ $payment->title }}</p>
                                    <p class="text-xs text-slate-500">{{ optional($payment->due_date)->format('d M Y') }} • {{ strtoupper($payment->repeat_option) }}</p>
                                </div>
                                <p class="font-semibold text-[#08745C]">{{ number_format($payment->amount, 0) }}</p>
                            </div>
                            <p class="text-xs text-slate-400">{{ $payment->note }}</p>
                        </div>
                    @empty
                        <p class="text-sm text-slate-400">No planned payments yet.</p>
                    @endforelse
                </div>
            </div>
            <form wire:submit.prevent="savePlannedPayment" class="space-y-3 rounded-2xl border border-[#72E3BD]/60 bg-white/80 p-4">
                <h3 class="text-base font-semibold text-[#095C4A]">New planned payment</h3>
                <div>
                    <label class="text-xs text-slate-500">Title</label>
                    <input type="text" wire:model.live="plannedPaymentForm.title" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                    @error('plannedPaymentForm.title') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
                </div>
                <div class="grid gap-3 md:grid-cols-2">
                    <div>
                        <label class="text-xs text-slate-500">Amount</label>
                        <input type="text" inputmode="decimal" data-money-input wire:model.live="plannedPaymentForm.amount" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                        @error('plannedPaymentForm.amount') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
                    </div>
                    <div>
                        <label class="text-xs text-slate-500">Due date</label>
                        <input type="text" data-datepicker wire:model.live="plannedPaymentForm.due_date" readonly class="w-full cursor-pointer rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                        @error('plannedPaymentForm.due_date') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
                    </div>
                </div>
                <div class="grid gap-3 md:grid-cols-2">
                    <div>
                        <label class="text-xs text-slate-500">Wallet</label>
                        <select wire:model.live="plannedPaymentForm.wallet_id" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                            <option value="">Select wallet</option>
                            @foreach ($wallets as $wallet)
                                <option value="{{ $wallet->id }}">{{ $wallet->name }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div>
                        <label class="text-xs text-slate-500">Category</label>
                        <select wire:model.live="plannedPaymentForm.category_id" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                            <option value="">Optional</option>
                            @foreach ($categories as $category)
                                <option value="{{ $category->id }}">{{ $category->name }}</option>
                            @endforeach
                        </select>
                    </div>
                </div>
                <div>
                    <label class="text-xs text-slate-500">Repeat</label>
                    <select wire:model.live="plannedPaymentForm.repeat_option" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                        @foreach (config('myexpenses.planning.planned_payment_repeat_options') as $option)
                            <option value="{{ $option }}">{{ ucfirst($option) }}</option>
                        @endforeach
                    </select>
                </div>
                <div>
                    <label class="text-xs text-slate-500">Note</label>
                    <textarea wire:model.live="plannedPaymentForm.note" rows="2" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2"></textarea>
                </div>
                <button type="submit" class="btn-primary w-full">Save planned payment</button>
            </form>
        </div>
    @endif

    @if ($tab === 'budgets')
        <div class="grid gap-4 md:grid-cols-2">
            <div class="space-y-3">
                <h2 class="text-lg font-semibold text-[#095C4A]">Budgets</h2>
                <div class="space-y-3">
                    @forelse ($budgets as $budget)
                        <div class="rounded-2xl border border-[#D2F9E7] bg-white/80 p-3">
                            <div class="flex items-center justify-between">
                                <p class="text-sm font-semibold">{{ $budget->name }}</p>
                                <span class="text-xs text-slate-500">{{ ucfirst($budget->period_type) }}</span>
                            </div>
                            <div class="mt-2 h-2 rounded-full bg-[#D2F9E7]">
                                <div class="h-2 rounded-full bg-[#08745C]" style="width: {{ $budget->percentage }}%"></div>
                            </div>
                            <p class="mt-1 text-xs text-slate-500">{{ number_format($budget->spent, 0) }} / {{ number_format($budget->amount, 0) }}</p>
                        </div>
                    @empty
                        <p class="text-sm text-slate-400">No budgets defined.</p>
                    @endforelse
                </div>
            </div>
            <form wire:submit.prevent="saveBudget" class="space-y-3 rounded-2xl border border-[#72E3BD]/60 bg-white/80 p-4">
                <h3 class="text-base font-semibold text-[#095C4A]">Create budget</h3>
                <div>
                    <label class="text-xs text-slate-500">Budget name</label>
                    <input type="text" wire:model.live="budgetForm.name" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                    @error('budgetForm.name') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
                </div>
                <div class="grid gap-3 md:grid-cols-2">
                    <div>
                        <label class="text-xs text-slate-500">Amount</label>
                        <input type="text" inputmode="decimal" data-money-input wire:model.live="budgetForm.amount" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                        @error('budgetForm.amount') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
                    </div>
                    <div>
                        <label class="text-xs text-slate-500">Period</label>
                        <select wire:model.live="budgetForm.period_type" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                            @foreach (config('myexpenses.planning.budget_period_options') as $option)
                                <option value="{{ $option }}">{{ ucfirst($option) }}</option>
                            @endforeach
                        </select>
                    </div>
                </div>
                <div>
                    <label class="text-xs text-slate-500">Category</label>
                    <select wire:model.live="budgetForm.category_id" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                        <option value="">All categories</option>
                        @foreach ($categories as $category)
                            <option value="{{ $category->id }}">{{ $category->name }}</option>
                        @endforeach
                    </select>
                </div>
                <div>
                    <label class="text-xs text-slate-500">Wallet (optional)</label>
                    <select wire:model.live="budgetForm.wallet_id" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                        <option value="">All wallets</option>
                        @foreach ($wallets as $wallet)
                            <option value="{{ $wallet->id }}">{{ $wallet->name }}</option>
                        @endforeach
                    </select>
                </div>
                <div class="grid gap-3 md:grid-cols-2">
                    <div>
                        <label class="text-xs text-slate-500">Start date</label>
                        <input type="text" data-datepicker wire:model.live="budgetForm.start_date" readonly class="w-full cursor-pointer rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                    </div>
                    <div>
                        <label class="text-xs text-slate-500">End date</label>
                        <input type="text" data-datepicker wire:model.live="budgetForm.end_date" readonly class="w-full cursor-pointer rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                        @error('budgetForm.end_date') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
                    </div>
                </div>
                <button type="submit" class="btn-primary w-full">Save budget</button>
            </form>
        </div>
    @endif

    @if ($tab === 'goals')
        <div class="grid gap-4 md:grid-cols-2">
            <div class="space-y-3">
                <h2 class="text-lg font-semibold text-[#095C4A]">Savings goals</h2>
                <div class="space-y-3">
                    @forelse ($goals as $goal)
                        @php($progress = $goal->target_amount > 0 ? round(($goal->current_amount / $goal->target_amount) * 100, 1) : 0)
                        <div class="flex items-center gap-4 rounded-2xl border border-[#D2F9E7] bg-white/80 p-4">
                            <div class="text-center">
                                <p class="text-2xl font-semibold text-[#08745C]">{{ $progress }}%</p>
                                <p class="text-xs text-slate-500">Progress</p>
                            </div>
                            <div>
                                <p class="text-sm font-semibold">{{ $goal->name }}</p>
                                <p class="text-xs text-slate-500">Target {{ number_format($goal->target_amount, 0) }} by {{ optional($goal->deadline)->format('d M Y') ?? '—' }}</p>
                                <p class="text-xs text-slate-400">{{ $goal->note }}</p>
                            </div>
                        </div>
                    @empty
                        <p class="text-sm text-slate-400">No goals created.</p>
                    @endforelse
                </div>
            </div>
            <form wire:submit.prevent="saveGoal" class="space-y-3 rounded-2xl border border-[#72E3BD]/60 bg-white/80 p-4" id="goals">
                <h3 class="text-base font-semibold text-[#095C4A]">New goal</h3>
                <div>
                    <label class="text-xs text-slate-500">Goal name</label>
                    <input type="text" wire:model.live="goalForm.name" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                    @error('goalForm.name') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
                </div>
                <div class="grid gap-3 md:grid-cols-2">
                    <div>
                        <label class="text-xs text-slate-500">Target amount</label>
                        <input type="text" inputmode="decimal" data-money-input wire:model.live="goalForm.target_amount" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                        @error('goalForm.target_amount') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
                    </div>
                    <div>
                        <label class="text-xs text-slate-500">Current amount</label>
                        <input type="text" inputmode="decimal" data-money-input wire:model.live="goalForm.current_amount" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                    </div>
                </div>
                <div class="grid gap-3 md:grid-cols-2">
                    <div>
                        <label class="text-xs text-slate-500">Wallet</label>
                        <select wire:model.live="goalForm.goal_wallet_id" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                            <option value="">Select wallet</option>
                            @foreach ($wallets as $wallet)
                                <option value="{{ $wallet->id }}">{{ $wallet->name }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div>
                        <label class="text-xs text-slate-500">Deadline</label>
                        <input type="text" data-datepicker wire:model.live="goalForm.deadline" readonly class="w-full cursor-pointer rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                    </div>
                </div>
                <div class="grid gap-3 md:grid-cols-2">
                    <div>
                        <label class="text-xs text-slate-500">Auto-save amount</label>
                        <input type="text" inputmode="decimal" data-money-input wire:model.live="goalForm.auto_save_amount" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                    </div>
                    <div>
                        <label class="text-xs text-slate-500">Auto-save interval</label>
                        <select wire:model.live="goalForm.auto_save_interval" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                            <option value="weekly">Weekly</option>
                            <option value="monthly">Monthly</option>
                        </select>
                    </div>
                </div>
                <div>
                    <label class="text-xs text-slate-500">Note</label>
                    <textarea wire:model.live="goalForm.note" rows="2" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2"></textarea>
                </div>
                <button type="submit" class="btn-primary w-full">Save goal</button>
            </form>
        </div>
    @endif

    @if ($tab === 'subscriptions')
        <div class="grid gap-4 md:grid-cols-2" id="subscriptions">
            <div class="space-y-3">
                <h2 class="text-lg font-semibold text-[#095C4A]">Active subscriptions</h2>
                <div class="space-y-3">
                    @forelse ($subscriptions as $subscription)
                        <div class="rounded-2xl border border-[#D2F9E7] bg-white/80 p-3">
                            <div class="flex items-center justify-between">
                                <p class="text-sm font-semibold">{{ $subscription->name }}</p>
                                <span class="text-xs text-slate-500">{{ ucfirst($subscription->billing_cycle) }}</span>
                            </div>
                            <p class="text-xs text-slate-500">Next billing {{ optional($subscription->next_billing_date)->format('d M Y') ?? '—' }}</p>
                            <p class="text-sm font-semibold text-[#08745C]">{{ number_format($subscription->amount, 0) }}</p>
                        </div>
                    @empty
                        <p class="text-sm text-slate-400">No subscriptions added.</p>
                    @endforelse
                </div>
            </div>
            <form wire:submit.prevent="saveSubscription" class="space-y-3 rounded-2xl border border-[#72E3BD]/60 bg-white/80 p-4">
                <h3 class="text-base font-semibold text-[#095C4A]">New subscription</h3>
                <div>
                    <label class="text-xs text-slate-500">Name</label>
                    <input type="text" wire:model.live="subscriptionForm.name" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                    @error('subscriptionForm.name') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
                </div>
                <div class="grid gap-3 md:grid-cols-2">
                    <div>
                        <label class="text-xs text-slate-500">Amount</label>
                        <input type="text" inputmode="decimal" data-money-input wire:model.live="subscriptionForm.amount" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                        @error('subscriptionForm.amount') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
                    </div>
                    <div>
                        <label class="text-xs text-slate-500">Billing cycle</label>
                        <select wire:model.live="subscriptionForm.billing_cycle" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                            @foreach (['weekly', 'monthly', 'quarterly', 'yearly'] as $cycle)
                                <option value="{{ $cycle }}">{{ ucfirst($cycle) }}</option>
                            @endforeach
                        </select>
                    </div>
                </div>
                <div class="grid gap-3 md:grid-cols-2">
                    <div>
                        <label class="text-xs text-slate-500">Next billing date</label>
                        <input type="text" data-datepicker wire:model.live="subscriptionForm.next_billing_date" readonly class="w-full cursor-pointer rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                        @error('subscriptionForm.next_billing_date') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
                    </div>
                    <div>
                        <label class="text-xs text-slate-500">Wallet</label>
                        <select wire:model.live="subscriptionForm.wallet_id" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                            <option value="">Select wallet</option>
                            @foreach ($wallets as $wallet)
                                <option value="{{ $wallet->id }}">{{ $wallet->name }}</option>
                            @endforeach
                        </select>
                        @error('subscriptionForm.wallet_id') <p class="text-xs text-red-500">{{ $message }}</p> @enderror
                    </div>
                </div>
                <div>
                    <label class="text-xs text-slate-500">Category</label>
                    <select wire:model.live="subscriptionForm.category_id" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                        <option value="">Optional</option>
                        @foreach ($categories as $category)
                            <option value="{{ $category->id }}">{{ $category->name }}</option>
                        @endforeach
                    </select>
                </div>
                @if ($subscriptionSubCategories->isNotEmpty())
                    <div>
                        <label class="text-xs text-slate-500">Sub-category</label>
                        <select wire:model.live="subscriptionForm.sub_category_id" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                            <option value="">Optional</option>
                            @foreach ($subscriptionSubCategories as $child)
                                <option value="{{ $child->id }}">{{ $child->name }}</option>
                            @endforeach
                        </select>
                    </div>
                @endif
                <div class="grid gap-3 md:grid-cols-2">
                    <div>
                        <label class="text-xs text-slate-500">Auto-post transaction</label>
                        <select wire:model.live="subscriptionForm.auto_post_transaction" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2">
                            <option value="1">Yes</option>
                            <option value="0">No</option>
                        </select>
                    </div>
                    <div>
                        <label class="text-xs text-slate-500">Reminder days</label>
                        <input type="number" min="0" wire:model.live="subscriptionForm.reminder_days" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                    </div>
                </div>
                <div>
                    <label class="text-xs text-slate-500">Note</label>
                    <textarea wire:model.live="subscriptionForm.note" rows="2" class="w-full rounded-2xl border border-[#D2F9E7] px-3 py-2"></textarea>
                </div>
                <button type="submit" class="btn-primary w-full">Save subscription</button>
            </form>
        </div>
    @endif
</section>
