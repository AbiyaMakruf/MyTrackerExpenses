<?php

namespace App\Livewire\Transactions;

use App\Models\Category;
use App\Models\Label;
use App\Models\Transaction;
use App\Models\Wallet;
use Illuminate\Contracts\View\View;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Auth;
use Livewire\Attributes\Layout;
use Livewire\Attributes\On;
use Livewire\Component;
use Livewire\WithPagination;
use Illuminate\Support\Facades\DB;

#[Layout('layouts.app')]
class Index extends Component
{
    use WithPagination;

    public ?int $walletId = null;
    public string $type = 'all';
    public string $range = 'monthly';
    public ?string $dateFrom = null;
    public ?string $dateTo = null;
    public ?int $categoryId = null;
    public ?int $subCategoryId = null;
    public array $labelIds = [];
    public ?int $deletingTransactionId = null;

    protected $queryString = [
        'walletId' => ['except' => null],
        'type' => ['except' => 'all'],
        'range' => ['except' => 'monthly'],
        'dateFrom' => ['except' => null],
        'dateTo' => ['except' => null],
        'categoryId' => ['except' => null],
        'subCategoryId' => ['except' => null],
    ];

    public function updatedCategoryId(): void
    {
        $this->subCategoryId = null;
    }

    public function updatedRange(): void
    {
        if ($this->range !== 'custom') {
            $this->dateFrom = null;
            $this->dateTo = null;
        }
    }

    protected function resolveRange(): array
    {
        return match ($this->range) {
            'daily' => [now()->startOfDay(), now()->endOfDay()],
            'weekly' => [now()->startOfWeek(), now()->endOfWeek()],
            'yearly' => [now()->startOfYear(), now()->endOfYear()],
            'custom' => [
                $this->dateFrom ? Carbon::parse($this->dateFrom)->startOfDay() : null,
                $this->dateTo ? Carbon::parse($this->dateTo)->endOfDay() : null,
            ],
            default => [now()->startOfMonth(), now()->endOfMonth()],
        };
    }

    protected function baseQuery()
    {
        [$start, $end] = $this->resolveRange();

        return Transaction::query()
            ->where('user_id', Auth::id())
            ->when($start && $end, fn ($query) => $query->whereBetween('transaction_date', [$start, $end]))
            ->when($this->walletId, fn ($query) => $query->where('wallet_id', $this->walletId))
            ->when($this->type !== 'all', fn ($query) => $query->where('type', $this->type))
            ->when($this->categoryId, fn ($query) => $query->where('category_id', $this->categoryId))
            ->when($this->subCategoryId, fn ($query) => $query->where('sub_category_id', $this->subCategoryId))
            ->when(! empty($this->labelIds), function ($query) {
                $query->whereHas('labels', fn ($q) => $q->whereIn('labels.id', $this->labelIds));
            })
            ->with(['wallet', 'category', 'subCategory', 'labels']);
    }

    public function render(): View
    {
        $query = $this->baseQuery();

        $transactions = (clone $query)
            ->latest('transaction_date')
            ->paginate(15);

        $trend = (clone $query)
            ->selectRaw("DATE(transaction_date) as day, SUM(CASE WHEN type = 'income' THEN amount ELSE -amount END) as net")
            ->groupBy('day')
            ->orderBy('day')
            ->get();

        $distribution = (clone $query)
            ->selectRaw('category_id, SUM(amount) as total')
            ->whereNotNull('category_id')
            ->groupBy('category_id')
            ->with('category')
            ->get();

        $wallets = Auth::user()->wallets()->get();
        $categories = Category::query()
            ->whereNull('parent_id')
            ->where(function ($query) {
                $query->whereNull('user_id')->orWhere('user_id', Auth::id());
            })
            ->orderBy('display_order')
            ->get();

        $subCategories = $this->categoryId
            ? Category::query()->where('parent_id', $this->categoryId)->orderBy('display_order')->get()
            : collect();

        $labels = Auth::user()->labels()->orderBy('name')->get();

        $this->dispatch('refresh-charts');

        return view('livewire.transactions.index', [
            'transactions' => $transactions,
            'trend' => $trend,
            'distribution' => $distribution,
            'wallets' => $wallets,
            'categories' => $categories,
            'subCategories' => $subCategories,
            'labels' => $labels,
        ]);
    }

    public function delete(int $id): void
    {
        $transaction = Transaction::where('user_id', Auth::id())->find($id);

        if ($transaction) {
            DB::transaction(function () use ($transaction) {
                // Revert balance changes
                $wallet = $transaction->wallet;
                if ($transaction->type === 'expense') {
                    $wallet->increment('current_balance', $transaction->amount);
                } elseif ($transaction->type === 'income') {
                    $wallet->decrement('current_balance', $transaction->amount);
                } elseif ($transaction->type === 'transfer') {
                    $wallet->increment('current_balance', $transaction->amount);
                    if ($transaction->to_wallet_id) {
                        Wallet::where('id', $transaction->to_wallet_id)->decrement('current_balance', $transaction->amount);
                    }
                }

                $transaction->delete();
            });
        }
    }

    public function confirmDelete(int $id): void
    {
        $this->deletingTransactionId = $id;
        $this->dispatch('open-confirmation-modal', [
            'title' => 'Delete Transaction',
            'message' => 'Are you sure you want to delete this transaction? This action cannot be undone.',
            'action' => 'delete-transaction-confirmed',
        ]);
    }

    #[On('delete-transaction-confirmed')]
    public function deleteConfirmed(): void
    {
        if ($this->deletingTransactionId) {
            $this->delete($this->deletingTransactionId);
            $this->deletingTransactionId = null;
        }
    }
}
