<?php

namespace App\Livewire\Statistics;

use App\Models\Category;
use App\Models\Transaction;
use Illuminate\Contracts\View\View;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Auth;
use Livewire\Attributes\Layout;
use Livewire\Component;

#[Layout('layouts.app')]
class Overview extends Component
{
    public string $range;
    public string $transactionType = 'all';
    public ?int $walletId = null;
    public ?int $categoryId = null;
    public ?string $dateFrom = null;
    public ?string $dateTo = null;

    public array $rangeOptions = [
        'daily' => 'Daily',
        'weekly' => 'Weekly',
        'monthly' => 'Monthly',
        'yearly' => 'Yearly',
        'custom' => 'Custom range',
    ];

    public function mount(): void
    {
        $this->range = config('myexpenses.statistics.default_view', 'monthly');
    }

    protected function query(): Builder
    {
        [$start, $end] = $this->resolveRange();

        return Transaction::query()
            ->where('user_id', Auth::id())
            ->when($start && $end, fn ($query) => $query->whereBetween('transaction_date', [$start, $end]))
            ->when($this->transactionType !== 'all', fn ($query) => $query->where('type', $this->transactionType))
            ->when($this->walletId, fn ($query) => $query->where('wallet_id', $this->walletId))
            ->when($this->categoryId, fn ($query) => $query->where('category_id', $this->categoryId));
    }

    protected function resolveRange(): array
    {
        return match ($this->range) {
            'daily' => [now()->startOfDay(), now()->endOfDay()],
            'weekly' => [now()->startOfWeek(), now()->endOfWeek()],
            'yearly' => [now()->startOfYear(), now()->endOfYear()],
            'custom' => [$this->dateFrom ? Carbon::parse($this->dateFrom) : null, $this->dateTo ? Carbon::parse($this->dateTo) : null],
            default => [now()->startOfMonth(), now()->endOfMonth()],
        };
    }

    public function updatedRange(): void
    {
        if ($this->range !== 'custom') {
            $this->dateFrom = null;
            $this->dateTo = null;
        }
    }

    public function render(): View
    {
        $user = Auth::user();
        $query = $this->query();
        $income = (clone $query)->where('type', 'income')->sum('amount');
        $expense = (clone $query)->where('type', 'expense')->sum('amount');
        $net = $income - $expense;

        $categoryBreakdown = (clone $query)
            ->selectRaw('category_id, SUM(amount) as total')
            ->groupBy('category_id')
            ->with('category')
            ->orderByDesc('total')
            ->limit(config('myexpenses.statistics.top_n_categories', 5))
            ->get();

        $trendData = (clone $query)
            ->selectRaw("DATE(transaction_date) as day, SUM(CASE WHEN type = 'income' THEN amount ELSE -amount END) as total")
            ->groupBy('day')
            ->orderBy('day')
            ->get();

        return view('livewire.statistics.overview', [
            'wallets' => $user->wallets,
            'categories' => Category::query()
                ->where(function ($query) use ($user) {
                    $query->whereNull('user_id')->orWhere('user_id', $user->id);
                })
                ->get(),
            'summary' => [
                'income' => $income,
                'expense' => $expense,
                'net' => $net,
            ],
            'categoryBreakdown' => $categoryBreakdown,
            'trendData' => $trendData,
        ]);
    }
}
