<?php

namespace App\Livewire\Dashboard;

use App\Models\Budget;
use App\Models\Goal;
use App\Models\PlannedPayment;
use App\Models\RecurringTransaction;
use App\Models\Subscription;
use App\Models\Transaction;
use App\Models\User;
use Illuminate\Contracts\View\View;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Carbon;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Auth;
use Livewire\Attributes\Layout;
use Livewire\Component;

#[Layout('layouts.app')]
class Overview extends Component
{
    public string $period;

    public array $periodOptions = [
        'daily' => 'Today',
        'weekly' => 'This Week',
        'this_month' => 'This Month',
        'monthly' => 'This Month',
        'yearly' => 'This Year',
        'custom_30' => 'Last 30 Days',
    ];

    public function mount(): void
    {
        $this->period = config('myexpenses.dashboard.default_filter', 'this_month');
    }

    public function render(): View
    {
        $user = Auth::user();
        [$startDate, $endDate] = $this->resolveDateRange();
        $transactionQuery = $this->queryForPeriod($startDate, $endDate);

        $wallets = $user->wallets()
            ->with('iconDefinition')
            ->orderByDesc('is_default')
            ->orderBy('name')
            ->get();

        return view('livewire.dashboard.overview', [
            'wallets' => $wallets,
            'walletTotal' => $wallets->sum('current_balance'),
            'walletGroups' => $this->groupWallets($wallets),
            'recentTransactions' => (clone $transactionQuery)
                ->latest('transaction_date')
                ->limit(10)
                ->with(['wallet.iconDefinition', 'category.icon', 'subCategory.icon'])
                ->get(),
            'cashFlow' => [
                'income' => (clone $transactionQuery)->where('type', 'income')->sum('amount'),
                'expense' => (clone $transactionQuery)->where('type', 'expense')->sum('amount'),
            ],
            'balanceTrend' => $this->buildBalanceTrend($startDate, $endDate),
            'topExpenses' => $this->buildTopExpenses($transactionQuery),
            'budgetProgress' => $this->buildBudgetProgress($user, $startDate, $endDate),
            'goalsSummary' => $this->buildGoalSummary($user),
            'upcomingRecurring' => $this->buildUpcomingRecurring($user),
            'upcomingSubscriptions' => $this->buildUpcomingSubscriptions($user),
            'upcomingPlannedPayments' => $this->buildUpcomingPlannedPayments($user),
            'periodLabel' => $this->periodOptions[$this->period] ?? $this->period,
        ]);
    }

    protected function resolveDateRange(): array
    {
        return match ($this->period) {
            'daily' => [now()->startOfDay(), now()->endOfDay()],
            'weekly' => [now()->startOfWeek(), now()->endOfWeek()],
            'yearly' => [now()->startOfYear(), now()->endOfYear()],
            'custom_30' => [now()->copy()->subDays(29)->startOfDay(), now()->endOfDay()],
            default => [now()->startOfMonth(), now()->endOfMonth()],
        };
    }

    protected function queryForPeriod(Carbon $start, Carbon $end): Builder
    {
        return Transaction::query()
            ->where('user_id', Auth::id())
            ->whereBetween('transaction_date', [$start, $end]);
    }

    protected function buildBalanceTrend(Carbon $start, Carbon $end): array
    {
        return Transaction::query()
            ->where('user_id', Auth::id())
            ->whereBetween('transaction_date', [$start, $end])
            ->selectRaw("DATE(transaction_date) as day, SUM(CASE WHEN type = 'income' THEN amount ELSE -amount END) as net")
            ->groupBy('day')
            ->orderBy('day')
            ->get()
            ->map(fn ($row) => [
                'date' => Carbon::parse($row->day)->format('d/m'),
                'net' => (float) $row->net,
            ])->all();
    }

    protected function buildTopExpenses(Builder $query): Collection
    {
        return (clone $query)
            ->where('type', 'expense')
            ->selectRaw('category_id, SUM(amount) as total')
            ->groupBy('category_id')
            ->with('category')
            ->orderByDesc('total')
            ->limit(config('myexpenses.statistics.top_n_categories', 5))
            ->get();
    }

    protected function buildBudgetProgress(User $user, Carbon $start, Carbon $end): Collection
    {
        $spendingByCategory = Transaction::query()
            ->where('user_id', $user->id)
            ->where('type', 'expense')
            ->whereBetween('transaction_date', [$start, $end])
            ->selectRaw('COALESCE(category_id, 0) as bucket, SUM(amount) as total')
            ->groupBy('bucket')
            ->pluck('total', 'bucket');

        return $user->budgets()
            ->with('category')
            ->get()
            ->map(function (Budget $budget) use ($spendingByCategory) {
                $key = $budget->category_id ?? 0;
                $spent = (float) ($spendingByCategory[$key] ?? 0);
                $percentage = $budget->amount > 0 ? min(100, round(($spent / $budget->amount) * 100, 2)) : 0;

                return [
                    'budget' => $budget,
                    'spent' => $spent,
                    'percentage' => $percentage,
                ];
            });
    }

    protected function buildGoalSummary(User $user): Collection
    {
        return $user->goals()
            ->latest('deadline')
            ->get()
            ->map(function (Goal $goal) {
                $progress = $goal->target_amount > 0 ? round(($goal->current_amount / $goal->target_amount) * 100, 2) : 0;
                $isNearDeadline = $goal->deadline && $goal->deadline->isBefore(now()->addDays(14));

                return [
                    'goal' => $goal,
                    'progress' => min(100, $progress),
                    'is_near_deadline' => $isNearDeadline,
                ];
            });
    }

    protected function buildUpcomingRecurring(User $user): array
    {
        $now = now();

        return [
            'seven_days' => RecurringTransaction::query()
                ->where('user_id', $user->id)
                ->whereBetween('next_run_at', [$now, $now->copy()->addDays(7)])
                ->orderBy('next_run_at')
                ->get(),
            'thirty_days' => RecurringTransaction::query()
                ->where('user_id', $user->id)
                ->whereBetween('next_run_at', [$now, $now->copy()->addDays(30)])
                ->orderBy('next_run_at')
                ->get(),
        ];
    }

    protected function buildUpcomingSubscriptions(User $user): array
    {
        $subscriptions = Subscription::query()
            ->where('user_id', $user->id)
            ->where('next_billing_date', '>=', now()->startOfDay())
            ->orderBy('next_billing_date')
            ->limit(5)
            ->with('icon')
            ->get();

        return [
            'total_monthly' => $user->subscriptions()->sum('amount'),
            'items' => $subscriptions,
        ];
    }

    protected function buildUpcomingPlannedPayments(User $user): Collection
    {
        return PlannedPayment::query()
            ->where('user_id', $user->id)
            ->where('due_date', '>=', now()->startOfDay())
            ->orderBy('due_date')
            ->limit(5)
            ->with('icon')
            ->get();
    }

    protected function groupWallets(Collection $wallets): Collection
    {
        $labels = [
            'bank' => 'Bank',
            'e-wallet' => 'E-Wallet',
            'cash' => 'Cash',
            'investment' => 'Investment',
        ];

        return $wallets->groupBy(function ($wallet) use ($labels) {
            return $labels[$wallet->type] ?? 'Others';
        });
    }
}
