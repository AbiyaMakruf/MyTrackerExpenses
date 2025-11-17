<?php

namespace App\Livewire\Dashboard;

use App\Models\Budget;
use App\Models\Goal;
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

    public function updatingPeriod(): void
    {
        $this->resetPage();
    }

    public function render(): View
    {
        $user = Auth::user();
        $wallets = $user->wallets()->orderByDesc('is_default')->orderBy('name')->get();
        [$startDate, $endDate] = $this->resolveDateRange();
        $transactionQuery = $this->queryForPeriod($startDate, $endDate);

        $recentTransactions = (clone $transactionQuery)
            ->latest('transaction_date')
            ->limit(10)
            ->with(['wallet', 'category'])
            ->get();

        $cashFlow = [
            'income' => (clone $transactionQuery)->where('type', 'income')->sum('amount'),
            'expense' => (clone $transactionQuery)->where('type', 'expense')->sum('amount'),
        ];

        $balanceTrend = $this->buildBalanceTrend($startDate, $endDate);
        $topExpenses = $this->buildTopExpenses($transactionQuery);
        $budgetProgress = $this->buildBudgetProgress($user, $startDate, $endDate);
        $goalsSummary = $this->buildGoalSummary($user);
        $upcomingRecurring = $this->buildUpcomingRecurring($user);
        $upcomingSubscriptions = $this->buildUpcomingSubscriptions($user);

        return view('livewire.dashboard.overview', [
            'wallets' => $wallets,
            'recentTransactions' => $recentTransactions,
            'cashFlow' => $cashFlow,
            'balanceTrend' => $balanceTrend,
            'topExpenses' => $topExpenses,
            'budgetProgress' => $budgetProgress,
            'goalsSummary' => $goalsSummary,
            'upcomingRecurring' => $upcomingRecurring,
            'upcomingSubscriptions' => $upcomingSubscriptions,
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
        $period = Carbon::parse($start)->toPeriod($end, '1 day');
        $data = [];

        foreach ($period as $date) {
            $sum = Transaction::query()
                ->where('user_id', Auth::id())
                ->whereDate('transaction_date', $date)
                ->selectRaw("SUM(CASE WHEN type = 'income' THEN amount ELSE -amount END) as net")
                ->value('net') ?? 0;

            $data[] = [
                'date' => $date->format('d/m'),
                'net' => $sum,
            ];
        }

        return $data;
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
        return $user->budgets()
            ->with('category')
            ->get()
            ->map(function (Budget $budget) use ($start, $end) {
                $spent = Transaction::query()
                    ->where('user_id', $budget->user_id)
                    ->where('type', 'expense')
                    ->when($budget->category_id, fn ($query) => $query->where('category_id', $budget->category_id))
                    ->whereBetween('transaction_date', [$start, $end])
                    ->sum('amount');

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
        return [
            'total_monthly' => $user->subscriptions()
                ->where('status', 'active')
                ->sum('amount'),
            'items' => $user->subscriptions()
                ->where('status', 'active')
                ->orderBy('next_billing_date')
                ->get(),
        ];
    }
}
