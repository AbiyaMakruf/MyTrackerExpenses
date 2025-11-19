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
                                <div class="flex items-center gap-3">
                                    <div class="flex h-10 w-10 items-center justify-center rounded-full bg-[#F6FFFA] text-[#095C4A]">
                                        @if ($payment->icon)
                                            @if ($payment->icon->type === 'image')
                                                <img src="{{ asset('storage/' . $payment->icon->image_path) }}" class="h-5 w-5 object-contain" />
                                            @else
                                                <span data-fa-icon="{{ $payment->icon->fa_class }}"></span>
                                            @endif
                                        @else
                                            <span class="text-xs font-bold">{{ Str::substr($payment->title, 0, 2) }}</span>
                                        @endif
                                    </div>
                                    <div>
                                        <p class="text-sm font-semibold">{{ $payment->title }}</p>
                                        <p class="text-xs text-slate-500">{{ optional($payment->due_date)->format('d M Y') }} • {{ strtoupper($payment->repeat_option) }}</p>
                                    </div>
                                </div>
                                <div class="text-right">
                                    <p class="font-semibold text-[#08745C]">{{ number_format($payment->amount, 0) }}</p>
                                    <div class="flex justify-end gap-2 text-xs">
                                        <button wire:click="editPlannedPayment({{ $payment->id }})" class="text-[#095C4A]">Edit</button>
                                        <button wire:click="deletePlannedPayment({{ $payment->id }})" class="text-red-500">Delete</button>
                                    </div>
                                </div>
                            </div>
                            <p class="mt-1 text-xs text-slate-400">{{ $payment->note }}</p>
                        </div>
                    @empty
                        <p class="text-sm text-slate-400">No planned payments yet.</p>
                    @endforelse
                </div>
            </div>
            <form wire:submit.prevent="savePlannedPayment" class="space-y-3 rounded-2xl border border-[#72E3BD]/60 bg-white/80 p-4">
                <div class="flex items-center justify-between">
                    <h3 class="text-base font-semibold text-[#095C4A]">{{ $editingPlannedPaymentId ? 'Edit planned payment' : 'New planned payment' }}</h3>
                    @if ($editingPlannedPaymentId)
                        <button type="button" wire:click="resetPlannedPaymentForm" class="text-xs text-red-500">Cancel</button>
                    @endif
                </div>
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
                    <div wire:ignore>
                        <input type="text" data-datepicker wire:model.live="plannedPaymentForm.due_date" readonly class="w-full cursor-pointer rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                    </div>
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
                    <label class="text-xs text-slate-500">Icon</label>
                    <div class="flex items-center gap-3">
                        <div class="flex h-10 w-10 items-center justify-center rounded-full border border-[#D2F9E7] bg-[#F6FFFA] text-[#095C4A]">
                            @if ($plannedPaymentIconPreview)
                                @if ($plannedPaymentIconPreview['type'] === 'image')
                                    <img src="{{ $plannedPaymentIconPreview['image_url'] }}" class="h-5 w-5 object-contain" />
                                @else
                                    <span data-fa-icon="{{ $plannedPaymentIconPreview['fa_class'] }}"></span>
                                @endif
                            @else
                                <span class="text-xs text-slate-400">None</span>
                            @endif
                        </div>
                        <button type="button" wire:click="openIconPicker('planned-payment')" class="text-sm font-semibold text-[#095C4A]">Choose icon</button>
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
                                <div class="flex items-center gap-3">
                                    <div class="flex h-10 w-10 items-center justify-center rounded-full bg-[#F6FFFA] text-[#095C4A]">
                                        @if ($budget->icon)
                                            @if ($budget->icon->type === 'image')
                                                <img src="{{ asset('storage/' . $budget->icon->image_path) }}" class="h-5 w-5 object-contain" />
                                            @else
                                                <span data-fa-icon="{{ $budget->icon->fa_class }}"></span>
                                            @endif
                                        @else
                                            <span class="text-xs font-bold">{{ Str::substr($budget->name, 0, 2) }}</span>
                                        @endif
                                    </div>
                                    <div>
                                        <p class="text-sm font-semibold">{{ $budget->name }}</p>
                                        <span class="text-xs text-slate-500">{{ ucfirst($budget->period_type) }}</span>
                                    </div>
                                </div>
                                <div class="flex gap-2 text-xs">
                                    <button wire:click="editBudget({{ $budget->id }})" class="text-[#095C4A]">Edit</button>
                                    <button wire:click="deleteBudget({{ $budget->id }})" class="text-red-500">Delete</button>
                                </div>
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
                <div class="flex items-center justify-between">
                    <h3 class="text-base font-semibold text-[#095C4A]">{{ $editingBudgetId ? 'Edit budget' : 'Create budget' }}</h3>
                    @if ($editingBudgetId)
                        <button type="button" wire:click="resetBudgetForm" class="text-xs text-red-500">Cancel</button>
                    @endif
                </div>
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
                <div>
                    <label class="text-xs text-slate-500">Icon</label>
                    <div class="flex items-center gap-3">
                        <div class="flex h-10 w-10 items-center justify-center rounded-full border border-[#D2F9E7] bg-[#F6FFFA] text-[#095C4A]">
                            @if ($budgetIconPreview)
                                @if ($budgetIconPreview['type'] === 'image')
                                    <img src="{{ $budgetIconPreview['image_url'] }}" class="h-5 w-5 object-contain" />
                                @else
                                    <span data-fa-icon="{{ $budgetIconPreview['fa_class'] }}"></span>
                                @endif
                            @else
                                <span class="text-xs text-slate-400">None</span>
                            @endif
                        </div>
                        <button type="button" wire:click="openIconPicker('budget')" class="text-sm font-semibold text-[#095C4A]">Choose icon</button>
                    </div>
                </div>
                <div class="grid gap-3 md:grid-cols-2">
                    <div>
                    <label class="text-xs text-slate-500">Start date</label>
                    <div wire:ignore>
                        <input type="text" data-datepicker wire:model.live="budgetForm.start_date" readonly class="w-full cursor-pointer rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                    </div>
                </div>
                <div>
                    <label class="text-xs text-slate-500">End date</label>
                    <div wire:ignore>
                        <input type="text" data-datepicker wire:model.live="budgetForm.end_date" readonly class="w-full cursor-pointer rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                    </div>
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
                            <div class="flex-1">
                                <div class="flex items-center justify-between">
                                    <div class="flex items-center gap-3">
                                        <div class="flex h-10 w-10 items-center justify-center rounded-full bg-[#F6FFFA] text-[#095C4A]">
                                            @if ($goal->icon)
                                                @if ($goal->icon->type === 'image')
                                                    <img src="{{ asset('storage/' . $goal->icon->image_path) }}" class="h-5 w-5 object-contain" />
                                                @else
                                                    <span data-fa-icon="{{ $goal->icon->fa_class }}"></span>
                                                @endif
                                            @else
                                                <span class="text-xs font-bold">{{ Str::substr($goal->name, 0, 2) }}</span>
                                            @endif
                                        </div>
                                        <div>
                                            <p class="text-sm font-semibold">{{ $goal->name }}</p>
                                            <p class="text-xs text-slate-500">Target {{ number_format($goal->target_amount, 0) }} by {{ optional($goal->deadline)->format('d M Y') ?? '—' }}</p>
                                        </div>
                                    </div>
                                    <div class="flex gap-2 text-xs">
                                        <button wire:click="editGoal({{ $goal->id }})" class="text-[#095C4A]">Edit</button>
                                        <button wire:click="deleteGoal({{ $goal->id }})" class="text-red-500">Delete</button>
                                    </div>
                                </div>
                                <p class="mt-1 text-xs text-slate-400">{{ $goal->note }}</p>
                            </div>
                        </div>
                    @empty
                        <p class="text-sm text-slate-400">No goals created.</p>
                    @endforelse
                </div>
            </div>
            <form wire:submit.prevent="saveGoal" class="space-y-3 rounded-2xl border border-[#72E3BD]/60 bg-white/80 p-4" id="goals">
                <div class="flex items-center justify-between">
                    <h3 class="text-base font-semibold text-[#095C4A]">{{ $editingGoalId ? 'Edit goal' : 'New goal' }}</h3>
                    @if ($editingGoalId)
                        <button type="button" wire:click="resetGoalForm" class="text-xs text-red-500">Cancel</button>
                    @endif
                </div>
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
                    <div wire:ignore>
                        <input type="text" data-datepicker wire:model.live="goalForm.deadline" readonly class="w-full cursor-pointer rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                    </div>
                    </div>
                </div>
                <div>
                    <label class="text-xs text-slate-500">Icon</label>
                    <div class="flex items-center gap-3">
                        <div class="flex h-10 w-10 items-center justify-center rounded-full border border-[#D2F9E7] bg-[#F6FFFA] text-[#095C4A]">
                            @if ($goalIconPreview)
                                @if ($goalIconPreview['type'] === 'image')
                                    <img src="{{ $goalIconPreview['image_url'] }}" class="h-5 w-5 object-contain" />
                                @else
                                    <span data-fa-icon="{{ $goalIconPreview['fa_class'] }}"></span>
                                @endif
                            @else
                                <span class="text-xs text-slate-400">None</span>
                            @endif
                        </div>
                        <button type="button" wire:click="openIconPicker('goal')" class="text-sm font-semibold text-[#095C4A]">Choose icon</button>
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
                                <div class="flex items-center gap-3">
                                    <div class="flex h-10 w-10 items-center justify-center rounded-full bg-[#F6FFFA] text-[#095C4A]">
                                        @if ($subscription->icon)
                                            @if ($subscription->icon->type === 'image')
                                                <img src="{{ asset('storage/' . $subscription->icon->image_path) }}" class="h-5 w-5 object-contain" />
                                            @else
                                                <span data-fa-icon="{{ $subscription->icon->fa_class }}"></span>
                                            @endif
                                        @else
                                            <span class="text-xs font-bold">{{ Str::substr($subscription->name, 0, 2) }}</span>
                                        @endif
                                    </div>
                                    <div>
                                        <p class="text-sm font-semibold">{{ $subscription->name }}</p>
                                        <span class="text-xs text-slate-500">{{ ucfirst($subscription->billing_cycle) }}</span>
                                    </div>
                                </div>
                                <div class="flex gap-2 text-xs">
                                    <button wire:click="editSubscription({{ $subscription->id }})" class="text-[#095C4A]">Edit</button>
                                    <button wire:click="deleteSubscription({{ $subscription->id }})" class="text-red-500">Delete</button>
                                </div>
                            </div>
                            <p class="mt-2 text-xs text-slate-500">Next billing {{ optional($subscription->next_billing_date)->format('d M Y') ?? '—' }}</p>
                            <p class="text-sm font-semibold text-[#08745C]">{{ number_format($subscription->amount, 0) }}</p>
                        </div>
                    @empty
                        <p class="text-sm text-slate-400">No subscriptions added.</p>
                    @endforelse
                </div>
            </div>
            <form wire:submit.prevent="saveSubscription" class="space-y-3 rounded-2xl border border-[#72E3BD]/60 bg-white/80 p-4">
                <div class="flex items-center justify-between">
                    <h3 class="text-base font-semibold text-[#095C4A]">{{ $editingSubscriptionId ? 'Edit subscription' : 'New subscription' }}</h3>
                    @if ($editingSubscriptionId)
                        <button type="button" wire:click="resetSubscriptionForm" class="text-xs text-red-500">Cancel</button>
                    @endif
                </div>
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
                    <div wire:ignore>
                        <input type="text" data-datepicker wire:model.live="subscriptionForm.next_billing_date" readonly class="w-full cursor-pointer rounded-2xl border border-[#D2F9E7] px-3 py-2" />
                    </div>
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
                <div>
                    <label class="text-xs text-slate-500">Icon</label>
                    <div class="flex items-center gap-3">
                        <div class="flex h-10 w-10 items-center justify-center rounded-full border border-[#D2F9E7] bg-[#F6FFFA] text-[#095C4A]">
                            @if ($subscriptionIconPreview)
                                @if ($subscriptionIconPreview['type'] === 'image')
                                    <img src="{{ $subscriptionIconPreview['image_url'] }}" class="h-5 w-5 object-contain" />
                                @else
                                    <span data-fa-icon="{{ $subscriptionIconPreview['fa_class'] }}"></span>
                                @endif
                            @else
                                <span class="text-xs text-slate-400">None</span>
                            @endif
                        </div>
                        <button type="button" wire:click="openIconPicker('subscription')" class="text-sm font-semibold text-[#095C4A]">Choose icon</button>
                    </div>
                </div>
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

    @if ($iconPickerOpen)
        <div class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4 backdrop-blur-sm">
            <div class="w-full max-w-md space-y-4 rounded-3xl bg-white p-6 shadow-xl">
                <div class="flex items-center justify-between">
                    <h3 class="text-lg font-semibold text-[#095C4A]">Select icon</h3>
                    <button wire:click="$set('iconPickerOpen', false)" class="text-slate-400 hover:text-slate-600">✕</button>
                </div>

                <input type="text" wire:model.live="iconPickerSearch" placeholder="Search icons..." class="w-full rounded-2xl border border-[#D2F9E7] px-4 py-2 text-sm" />

                <div class="flex gap-2 border-b border-[#D2F9E7] pb-2">
                    <button wire:click="$set('iconPickerTab', 'fontawesome')" @class(['text-sm font-semibold', 'text-[#095C4A]' => $iconPickerTab === 'fontawesome', 'text-slate-400' => $iconPickerTab !== 'fontawesome'])>FontAwesome</button>
                    <button wire:click="$set('iconPickerTab', 'image')" @class(['text-sm font-semibold', 'text-[#095C4A]' => $iconPickerTab === 'image', 'text-slate-400' => $iconPickerTab !== 'image'])>Custom</button>
                </div>

                <div class="grid max-h-60 grid-cols-5 gap-3 overflow-y-auto p-1">
                    @foreach ($icons as $icon)
                        @if ($icon->type === $iconPickerTab && (empty($iconPickerSearch) || str_contains(strtolower($icon->label), strtolower($iconPickerSearch))))
                            <button wire:click="selectIcon({{ $icon->id }})" class="flex aspect-square flex-col items-center justify-center gap-1 rounded-xl border border-[#E2F5ED] p-2 hover:bg-[#F6FFFA]">
                                @if ($icon->type === 'image')
                                    <img src="{{ asset('storage/' . $icon->image_path) }}" class="h-6 w-6 object-contain" />
                                @else
                                    <span data-fa-icon="{{ $icon->fa_class }}" class="text-xl text-[#095C4A]"></span>
                                @endif
                                <span class="truncate text-[10px] text-slate-500">{{ $icon->label }}</span>
                            </button>
                        @endif
                    @endforeach
                </div>
            </div>
        </div>
    @endif
</section>
