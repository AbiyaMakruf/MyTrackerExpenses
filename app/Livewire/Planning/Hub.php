<?php

namespace App\Livewire\Planning;

use App\Models\Budget;
use App\Models\Category;
use App\Models\Goal;
use App\Models\Icon;
use App\Models\PlannedPayment;
use App\Models\Subscription;
use App\Models\Transaction;
use Illuminate\Contracts\View\View;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\Rule;
use Livewire\Attributes\Layout;
use Livewire\Component;
use Livewire\Attributes\On;
use Livewire\WithPagination;

#[Layout('layouts.app')]
class Hub extends Component
{
    use WithPagination;

    public string $tab = 'planned-payments';

    public ?int $editingPlannedPaymentId = null;
    public ?int $editingBudgetId = null;
    public ?int $editingGoalId = null;
    public ?int $editingSubscriptionId = null;

    public array $plannedPaymentForm = [
        'title' => '',
        'amount' => null,
        'due_date' => '',
        'wallet_id' => null,
        'category_id' => null,
        'icon_id' => null,
        'repeat_option' => 'none',
        'note' => '',
    ];

    public array $budgetForm = [
        'name' => '',
        'amount' => null,
        'period_type' => 'monthly',
        'category_id' => null,
        'wallet_id' => null,
        'icon_id' => null,
        'start_date' => '',
        'end_date' => '',
    ];

    public array $goalForm = [
        'name' => '',
        'target_amount' => null,
        'current_amount' => null,
        'deadline' => '',
        'goal_wallet_id' => null,
        'icon_id' => null,
        'auto_save_amount' => null,
        'auto_save_interval' => 'monthly',
        'note' => '',
    ];

    public array $subscriptionForm = [
        'name' => '',
        'amount' => null,
        'billing_cycle' => 'monthly',
        'next_billing_date' => '',
        'wallet_id' => null,
        'category_id' => null,
        'sub_category_id' => null,
        'icon_id' => null,
        'auto_post_transaction' => true,
        'reminder_days' => 3,
        'note' => '',
    ];

    public bool $iconPickerOpen = false;
    public string $iconPickerContext = 'planned-payment';
    public string $iconPickerTab = 'fontawesome';
    public string $iconPickerSearch = '';
    public int $perPage = 20;
    
    public ?array $plannedPaymentIconPreview = null;
    public ?array $budgetIconPreview = null;
    public ?array $goalIconPreview = null;
    public ?array $subscriptionIconPreview = null;

    public ?string $deletingType = null;
    public ?int $deletingId = null;

    public function openIconPicker(string $context): void
    {
        $this->iconPickerContext = $context;
        $this->iconPickerOpen = true;
    }

    public function selectIcon(int $iconId): void
    {
        $icon = Icon::find($iconId);
        $preview = [
            'type' => $icon->type,
            'fa_class' => $icon->fa_class,
            'image_url' => $icon->image_url,
        ];

        if ($this->iconPickerContext === 'planned-payment') {
            $this->plannedPaymentForm['icon_id'] = $iconId;
            $this->plannedPaymentIconPreview = $preview;
        } elseif ($this->iconPickerContext === 'budget') {
            $this->budgetForm['icon_id'] = $iconId;
            $this->budgetIconPreview = $preview;
        } elseif ($this->iconPickerContext === 'goal') {
            $this->goalForm['icon_id'] = $iconId;
            $this->goalIconPreview = $preview;
        } elseif ($this->iconPickerContext === 'subscription') {
            $this->subscriptionForm['icon_id'] = $iconId;
            $this->subscriptionIconPreview = $preview;
        }

        $this->iconPickerOpen = false;
    }

    public function updatingIconPickerSearch(): void
    {
        $this->resetPage();
    }

    public function updatingPerPage(): void
    {
        $this->resetPage();
    }

    public function setTab(string $tab): void
    {
        $this->tab = $tab;
    }

    public function savePlannedPayment(): void
    {
        $data = $this->validate([
            'plannedPaymentForm.title' => ['required', 'string', 'max:255'],
            'plannedPaymentForm.amount' => ['required', 'numeric', 'min:0.01'],
            'plannedPaymentForm.due_date' => ['required', 'date'],
            'plannedPaymentForm.wallet_id' => ['required', Rule::exists('wallets', 'id')->where('user_id', Auth::id())],
            'plannedPaymentForm.category_id' => ['nullable', Rule::exists('categories', 'id')],
            'plannedPaymentForm.icon_id' => ['nullable', Rule::exists('icons', 'id')],
            'plannedPaymentForm.repeat_option' => ['required', Rule::in(config('myexpenses.planning.planned_payment_repeat_options'))],
            'plannedPaymentForm.note' => ['nullable', 'string', 'max:500'],
        ])['plannedPaymentForm'];

        if ($this->editingPlannedPaymentId) {
            $plannedPayment = PlannedPayment::where('user_id', Auth::id())->findOrFail($this->editingPlannedPaymentId);
            $plannedPayment->update([
                ...$data,
                'is_recurring' => $data['repeat_option'] !== 'none',
            ]);
            session()->flash('planning_status', 'Planned payment updated');
        } else {
            PlannedPayment::create([
                ...$data,
                'user_id' => Auth::id(),
                'is_recurring' => $data['repeat_option'] !== 'none',
                'status' => 'pending',
            ]);
            session()->flash('planning_status', 'Planned payment saved');
        }

        $this->resetPlannedPaymentForm();
    }

    public function editPlannedPayment(int $id): void
    {
        $plannedPayment = PlannedPayment::where('user_id', Auth::id())->findOrFail($id);
        $this->editingPlannedPaymentId = $id;
        $this->plannedPaymentForm = [
            'title' => $plannedPayment->title,
            'amount' => $plannedPayment->amount,
            'due_date' => $plannedPayment->due_date->format('Y-m-d'),
            'wallet_id' => $plannedPayment->wallet_id,
            'category_id' => $plannedPayment->category_id,
            'icon_id' => $plannedPayment->icon_id,
            'repeat_option' => $plannedPayment->repeat_option,
            'note' => $plannedPayment->note,
        ];

        if ($plannedPayment->icon) {
            $this->plannedPaymentIconPreview = [
                'type' => $plannedPayment->icon->type,
                'fa_class' => $plannedPayment->icon->fa_class,
                'image_url' => $plannedPayment->icon->image_path ? asset('storage/' . $plannedPayment->icon->image_path) : null,
                'label' => $plannedPayment->icon->label,
            ];
        } else {
            $this->plannedPaymentIconPreview = null;
        }
    }

    public function deletePlannedPayment(int $id): void
    {
        PlannedPayment::where('user_id', Auth::id())->findOrFail($id)->delete();
        session()->flash('planning_status', 'Planned payment deleted');
    }

    public function resetPlannedPaymentForm(): void
    {
        $this->editingPlannedPaymentId = null;
        $this->plannedPaymentForm = [
            'title' => '',
            'amount' => null,
            'due_date' => '',
            'wallet_id' => null,
            'category_id' => null,
            'icon_id' => null,
            'repeat_option' => 'none',
            'note' => '',
        ];
        $this->plannedPaymentIconPreview = null;
    }

    public function saveBudget(): void
    {
        $data = $this->validate([
            'budgetForm.name' => ['required', 'string', 'max:255'],
            'budgetForm.amount' => ['required', 'numeric', 'min:0.01'],
            'budgetForm.period_type' => ['required', Rule::in(config('myexpenses.planning.budget_period_options'))],
            'budgetForm.category_id' => ['nullable', Rule::exists('categories', 'id')],
            'budgetForm.wallet_id' => ['nullable', Rule::exists('wallets', 'id')->where('user_id', Auth::id())],
            'budgetForm.icon_id' => ['nullable', Rule::exists('icons', 'id')],
            'budgetForm.start_date' => ['nullable', 'date'],
            'budgetForm.end_date' => ['nullable', 'date', 'after:budgetForm.start_date'],
        ])['budgetForm'];

        if ($this->editingBudgetId) {
            $budget = Budget::where('user_id', Auth::id())->findOrFail($this->editingBudgetId);
            $budget->update([
                ...$data,
            ]);
            session()->flash('planning_status', 'Budget updated');
        } else {
            Budget::create([
                ...$data,
                'user_id' => Auth::id(),
            ]);
            session()->flash('planning_status', 'Budget saved');
        }

        $this->resetBudgetForm();
    }

    public function editBudget(int $id): void
    {
        $budget = Budget::where('user_id', Auth::id())->findOrFail($id);
        $this->editingBudgetId = $id;
        $this->budgetForm = [
            'name' => $budget->name,
            'amount' => $budget->amount,
            'period_type' => $budget->period_type,
            'category_id' => $budget->category_id,
            'wallet_id' => $budget->wallet_id,
            'icon_id' => $budget->icon_id,
            'start_date' => optional($budget->start_date)->format('Y-m-d'),
            'end_date' => optional($budget->end_date)->format('Y-m-d'),
        ];

        if ($budget->icon) {
            $this->budgetIconPreview = [
                'type' => $budget->icon->type,
                'fa_class' => $budget->icon->fa_class,
                'image_url' => $budget->icon->image_path ? asset('storage/' . $budget->icon->image_path) : null,
                'label' => $budget->icon->label,
            ];
        } else {
            $this->budgetIconPreview = null;
        }
    }

    public function deleteBudget(int $id): void
    {
        Budget::where('user_id', Auth::id())->findOrFail($id)->delete();
        session()->flash('planning_status', 'Budget deleted');
    }

    public function resetBudgetForm(): void
    {
        $this->editingBudgetId = null;
        $this->budgetForm = [
            'name' => '',
            'amount' => null,
            'period_type' => 'monthly',
            'category_id' => null,
            'wallet_id' => null,
            'icon_id' => null,
            'start_date' => '',
            'end_date' => '',
        ];
        $this->budgetIconPreview = null;
    }

    public function saveGoal(): void
    {
        $data = $this->validate([
            'goalForm.name' => ['required', 'string', 'max:255'],
            'goalForm.target_amount' => ['required', 'numeric', 'min:0.01'],
            'goalForm.current_amount' => ['nullable', 'numeric', 'min:0'],
            'goalForm.deadline' => ['nullable', 'date'],
            'goalForm.goal_wallet_id' => ['nullable', Rule::exists('wallets', 'id')->where('user_id', Auth::id())],
            'goalForm.icon_id' => ['nullable', Rule::exists('icons', 'id')],
            'goalForm.auto_save_amount' => ['nullable', 'numeric', 'min:0'],
            'goalForm.auto_save_interval' => ['nullable', Rule::in(['weekly', 'monthly'])],
            'goalForm.note' => ['nullable', 'string', 'max:500'],
        ])['goalForm'];

        if ($this->editingGoalId) {
            $goal = Goal::where('user_id', Auth::id())->findOrFail($this->editingGoalId);
            $goal->update([
                ...$data,
                'auto_save_enabled' => filled($data['auto_save_amount']),
            ]);
            session()->flash('planning_status', 'Goal updated');
        } else {
            Goal::create([
                ...$data,
                'user_id' => Auth::id(),
                'status' => 'ongoing',
                'auto_save_enabled' => filled($data['auto_save_amount']),
            ]);
            session()->flash('planning_status', 'Goal saved');
        }

        $this->resetGoalForm();
    }

    public function editGoal(int $id): void
    {
        $goal = Goal::where('user_id', Auth::id())->findOrFail($id);
        $this->editingGoalId = $id;
        $this->goalForm = [
            'name' => $goal->name,
            'target_amount' => $goal->target_amount,
            'current_amount' => $goal->current_amount,
            'deadline' => optional($goal->deadline)->format('Y-m-d'),
            'goal_wallet_id' => $goal->goal_wallet_id,
            'icon_id' => $goal->icon_id,
            'auto_save_amount' => $goal->auto_save_amount,
            'auto_save_interval' => $goal->auto_save_interval,
            'note' => $goal->note,
        ];

        if ($goal->icon) {
            $this->goalIconPreview = [
                'type' => $goal->icon->type,
                'fa_class' => $goal->icon->fa_class,
                'image_url' => $goal->icon->image_path ? asset('storage/' . $goal->icon->image_path) : null,
                'label' => $goal->icon->label,
            ];
        } else {
            $this->goalIconPreview = null;
        }
    }

    public function deleteGoal(int $id): void
    {
        Goal::where('user_id', Auth::id())->findOrFail($id)->delete();
        session()->flash('planning_status', 'Goal deleted');
    }

    public function resetGoalForm(): void
    {
        $this->editingGoalId = null;
        $this->goalForm = [
            'name' => '',
            'target_amount' => null,
            'current_amount' => null,
            'deadline' => '',
            'goal_wallet_id' => null,
            'icon_id' => null,
            'auto_save_amount' => null,
            'auto_save_interval' => 'monthly',
            'note' => '',
        ];
        $this->goalIconPreview = null;
    }

    public function saveSubscription(): void
    {
        $data = $this->validate([
            'subscriptionForm.name' => ['required', 'string', 'max:255'],
            'subscriptionForm.amount' => ['required', 'numeric', 'min:0.01'],
            'subscriptionForm.billing_cycle' => ['required', Rule::in(['weekly', 'monthly', 'quarterly', 'yearly'])],
            'subscriptionForm.next_billing_date' => ['required', 'date'],
            'subscriptionForm.wallet_id' => ['required', Rule::exists('wallets', 'id')->where('user_id', Auth::id())],
            'subscriptionForm.category_id' => ['nullable', Rule::exists('categories', 'id')],
            'subscriptionForm.sub_category_id' => ['nullable', Rule::exists('categories', 'id')],
            'subscriptionForm.icon_id' => ['nullable', Rule::exists('icons', 'id')],
            'subscriptionForm.auto_post_transaction' => ['boolean'],
            'subscriptionForm.reminder_days' => ['required', 'integer', 'min:0'],
            'subscriptionForm.note' => ['nullable', 'string', 'max:500'],
        ])['subscriptionForm'];

        if ($this->editingSubscriptionId) {
            $subscription = Subscription::where('user_id', Auth::id())->findOrFail($this->editingSubscriptionId);
            $subscription->update([
                ...$data,
            ]);
            session()->flash('planning_status', 'Subscription updated');
        } else {
            Subscription::create([
                ...$data,
                'user_id' => Auth::id(),
                'status' => 'active',
                'currency' => Auth::user()->base_currency,
            ]);
            session()->flash('planning_status', 'Subscription saved');
        }

        $this->resetSubscriptionForm();
    }

    public function editSubscription(int $id): void
    {
        $subscription = Subscription::where('user_id', Auth::id())->findOrFail($id);
        $this->editingSubscriptionId = $id;
        $this->subscriptionForm = [
            'name' => $subscription->name,
            'amount' => $subscription->amount,
            'billing_cycle' => $subscription->billing_cycle,
            'next_billing_date' => $subscription->next_billing_date->format('Y-m-d'),
            'wallet_id' => $subscription->wallet_id,
            'category_id' => $subscription->category_id,
            'sub_category_id' => $subscription->sub_category_id,
            'icon_id' => $subscription->icon_id,
            'auto_post_transaction' => $subscription->auto_post_transaction,
            'reminder_days' => $subscription->reminder_days,
            'note' => $subscription->note,
        ];

        if ($subscription->icon) {
            $this->subscriptionIconPreview = [
                'type' => $subscription->icon->type,
                'fa_class' => $subscription->icon->fa_class,
                'image_url' => $subscription->icon->image_path ? asset('storage/' . $subscription->icon->image_path) : null,
                'label' => $subscription->icon->label,
            ];
        } else {
            $this->subscriptionIconPreview = null;
        }
    }

    public function deleteSubscription(int $id): void
    {
        Subscription::where('user_id', Auth::id())->findOrFail($id)->delete();
        session()->flash('planning_status', 'Subscription deleted');
    }

    public function resetSubscriptionForm(): void
    {
        $this->editingSubscriptionId = null;
        $this->subscriptionForm = [
            'name' => '',
            'amount' => null,
            'billing_cycle' => 'monthly',
            'next_billing_date' => '',
            'wallet_id' => null,
            'category_id' => null,
            'sub_category_id' => null,
            'icon_id' => null,
            'auto_post_transaction' => true,
            'reminder_days' => 3,
            'note' => '',
        ];
        $this->subscriptionIconPreview = null;
    }

    public function confirmDelete(string $type, int $id): void
    {
        $this->deletingType = $type;
        $this->deletingId = $id;
        
        $message = match($type) {
            'planned-payment' => 'Delete this planned payment?',
            'budget' => 'Delete this budget?',
            'goal' => 'Delete this goal?',
            'subscription' => 'Delete this subscription?',
            default => 'Are you sure?',
        };

        $this->dispatch('open-confirmation-modal', [
            'title' => 'Confirm Deletion',
            'message' => $message,
            'action' => 'delete-planning-confirmed',
        ]);
    }

    #[On('delete-planning-confirmed')]
    public function deleteConfirmed(): void
    {
        if (!$this->deletingId || !$this->deletingType) return;

        match($this->deletingType) {
            'planned-payment' => $this->deletePlannedPayment($this->deletingId),
            'budget' => $this->deleteBudget($this->deletingId),
            'goal' => $this->deleteGoal($this->deletingId),
            'subscription' => $this->deleteSubscription($this->deletingId),
        };

        $this->deletingId = null;
        $this->deletingType = null;
    }

    public function render(): View
    {
        $user = Auth::user();
        $wallets = $user->wallets()->orderByDesc('is_default')->get();
        $categories = Category::query()
            ->whereNull('parent_id')
            ->where(function ($query) {
                $query->whereNull('user_id')->orWhere('user_id', Auth::id());
            })
            ->orderBy('display_order')
            ->get();

        $iconQuery = Icon::query()
            ->where('is_active', true)
            ->when($this->iconPickerSearch, function ($query) {
                $searchTerm = $this->iconPickerSearch;
                $searchLabel = str_replace('-', ' ', $searchTerm);

                $query->where(function ($sub) use ($searchTerm, $searchLabel) {
                    $sub->where('label', 'like', '%'.$searchTerm.'%')
                        ->orWhere('label', 'like', '%'.$searchLabel.'%')
                        ->orWhere('fa_class', 'like', '%'.$searchTerm.'%');
                });
            })
            ->orderBy('label');

        $fontawesomeIcons = $this->iconPickerOpen
            ? (clone $iconQuery)->where('type', 'fontawesome')->paginate($this->perPage)
            : collect();

        $customIcons = $this->iconPickerOpen
            ? (clone $iconQuery)->where('type', 'image')->get()
            : collect();

        $this->dispatch('refresh-fontawesome');

        $budgets = $user->budgets()->with('category')->get()->map(function (Budget $budget) {
            $spent = Transaction::query()
                ->where('user_id', $budget->user_id)
                ->where('type', 'expense')
                ->when($budget->category_id, fn ($query) => $query->where('category_id', $budget->category_id))
                ->whereBetween('transaction_date', [now()->startOfMonth(), now()->endOfMonth()])
                ->sum('amount');

            $budget->spent = $spent;
            $budget->percentage = $budget->amount > 0 ? min(100, round(($spent / $budget->amount) * 100, 2)) : 0;

            return $budget;
        });

        $subscriptionSubCategories = collect();

        if ($this->subscriptionForm['category_id']) {
            $subscriptionSubCategories = Category::query()
                ->where('parent_id', $this->subscriptionForm['category_id'])
                ->where(function ($query) {
                    $query->whereNull('user_id')->orWhere('user_id', Auth::id());
                })
                ->orderBy('display_order')
                ->get();
        }

        return view('livewire.planning.hub', [
            'wallets' => $wallets,
            'categories' => $categories,
            'iconPickerFontawesome' => $fontawesomeIcons,
            'iconPickerCustom' => $customIcons,
            'plannedPayments' => $user->plannedPayments()->latest('due_date')->get(),
            'budgets' => $budgets,
            'goals' => $user->goals()->latest('deadline')->get(),
            'subscriptions' => $user->subscriptions()->orderBy('next_billing_date')->get(),
            'subscriptionSubCategories' => $subscriptionSubCategories,
        ]);
    }
}
