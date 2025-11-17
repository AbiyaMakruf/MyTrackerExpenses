<?php

namespace App\Livewire\Planning;

use App\Models\Budget;
use App\Models\Category;
use App\Models\Goal;
use App\Models\PlannedPayment;
use App\Models\Subscription;
use App\Models\Transaction;
use Illuminate\Contracts\View\View;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\Rule;
use Livewire\Attributes\Layout;
use Livewire\Component;

#[Layout('layouts.app')]
class Hub extends Component
{
    public string $tab = 'planned-payments';

    public array $plannedPaymentForm = [
        'title' => '',
        'amount' => null,
        'due_date' => '',
        'wallet_id' => null,
        'category_id' => null,
        'repeat_option' => 'none',
        'note' => '',
    ];

    public array $budgetForm = [
        'name' => '',
        'amount' => null,
        'period_type' => 'monthly',
        'category_id' => null,
        'wallet_id' => null,
        'start_date' => '',
        'end_date' => '',
    ];

    public array $goalForm = [
        'name' => '',
        'target_amount' => null,
        'current_amount' => null,
        'deadline' => '',
        'goal_wallet_id' => null,
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
        'auto_post_transaction' => true,
        'reminder_days' => 3,
        'note' => '',
    ];

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
            'plannedPaymentForm.repeat_option' => ['required', Rule::in(config('myexpenses.planning.planned_payment_repeat_options'))],
            'plannedPaymentForm.note' => ['nullable', 'string', 'max:500'],
        ])['plannedPaymentForm'];

        PlannedPayment::create([
            ...$data,
            'user_id' => Auth::id(),
            'is_recurring' => $data['repeat_option'] !== 'none',
            'status' => 'pending',
        ]);

        $this->plannedPaymentForm = [
            'title' => '',
            'amount' => null,
            'due_date' => '',
            'wallet_id' => null,
            'category_id' => null,
            'repeat_option' => 'none',
            'note' => '',
        ];

        session()->flash('planning_status', 'Planned payment saved');
    }

    public function saveBudget(): void
    {
        $data = $this->validate([
            'budgetForm.name' => ['required', 'string', 'max:255'],
            'budgetForm.amount' => ['required', 'numeric', 'min:0.01'],
            'budgetForm.period_type' => ['required', Rule::in(config('myexpenses.planning.budget_period_options'))],
            'budgetForm.category_id' => ['nullable', Rule::exists('categories', 'id')],
            'budgetForm.wallet_id' => ['nullable', Rule::exists('wallets', 'id')->where('user_id', Auth::id())],
            'budgetForm.start_date' => ['nullable', 'date'],
            'budgetForm.end_date' => ['nullable', 'date', 'after:budgetForm.start_date'],
        ])['budgetForm'];

        Budget::create([
            ...$data,
            'user_id' => Auth::id(),
        ]);

        $this->budgetForm = [
            'name' => '',
            'amount' => null,
            'period_type' => 'monthly',
            'category_id' => null,
            'wallet_id' => null,
            'start_date' => '',
            'end_date' => '',
        ];

        session()->flash('planning_status', 'Budget saved');
    }

    public function saveGoal(): void
    {
        $data = $this->validate([
            'goalForm.name' => ['required', 'string', 'max:255'],
            'goalForm.target_amount' => ['required', 'numeric', 'min:0.01'],
            'goalForm.current_amount' => ['nullable', 'numeric', 'min:0'],
            'goalForm.deadline' => ['nullable', 'date'],
            'goalForm.goal_wallet_id' => ['nullable', Rule::exists('wallets', 'id')->where('user_id', Auth::id())],
            'goalForm.auto_save_amount' => ['nullable', 'numeric', 'min:0'],
            'goalForm.auto_save_interval' => ['nullable', Rule::in(['weekly', 'monthly'])],
            'goalForm.note' => ['nullable', 'string', 'max:500'],
        ])['goalForm'];

        Goal::create([
            ...$data,
            'user_id' => Auth::id(),
            'status' => 'ongoing',
            'auto_save_enabled' => filled($data['auto_save_amount']),
        ]);

        $this->goalForm = [
            'name' => '',
            'target_amount' => null,
            'current_amount' => null,
            'deadline' => '',
            'goal_wallet_id' => null,
            'auto_save_amount' => null,
            'auto_save_interval' => 'monthly',
            'note' => '',
        ];

        session()->flash('planning_status', 'Goal saved');
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
            'subscriptionForm.auto_post_transaction' => ['boolean'],
            'subscriptionForm.reminder_days' => ['required', 'integer', 'min:0'],
            'subscriptionForm.note' => ['nullable', 'string', 'max:500'],
        ])['subscriptionForm'];

        Subscription::create([
            ...$data,
            'user_id' => Auth::id(),
            'status' => 'active',
            'currency' => Auth::user()->base_currency,
        ]);

        $this->subscriptionForm = [
            'name' => '',
            'amount' => null,
            'billing_cycle' => 'monthly',
            'next_billing_date' => '',
            'wallet_id' => null,
            'category_id' => null,
            'sub_category_id' => null,
            'auto_post_transaction' => true,
            'reminder_days' => 3,
            'note' => '',
        ];

        session()->flash('planning_status', 'Subscription saved');
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
            'plannedPayments' => $user->plannedPayments()->latest('due_date')->get(),
            'budgets' => $budgets,
            'goals' => $user->goals()->latest('deadline')->get(),
            'subscriptions' => $user->subscriptions()->orderBy('next_billing_date')->get(),
            'subscriptionSubCategories' => $subscriptionSubCategories,
        ]);
    }
}
