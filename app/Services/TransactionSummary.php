<?php

namespace App\Services;

use Illuminate\Support\Collection;

class TransactionSummary
{
    public static function build(Collection $transactions): array
    {
        $incomeTotal = (float) $transactions->where('type', 'income')->sum('amount');
        $expenseTotal = (float) $transactions->where('type', 'expense')->sum('amount');
        $netTotal = $incomeTotal - $expenseTotal;
        $maxTotal = max($incomeTotal, $expenseTotal, 1); // prevent division by zero for bars

        $topIncomeCategories = self::topCategories($transactions, 'income');
        $topExpenseCategories = self::topCategories($transactions, 'expense');

        return [
            'income_total' => $incomeTotal,
            'expense_total' => $expenseTotal,
            'net_total' => $netTotal,
            'max_total' => $maxTotal,
            'top_income_categories' => $topIncomeCategories,
            'top_expense_categories' => $topExpenseCategories,
        ];
    }

    protected static function topCategories(Collection $transactions, string $type, int $limit = 5): array
    {
        return $transactions
            ->where('type', $type)
            ->groupBy(function ($transaction) {
                return $transaction->category->name ?? 'Uncategorized';
            })
            ->map(function ($items, $name) {
                return [
                    'name' => $name,
                    'amount' => (float) $items->sum('amount'),
                ];
            })
            ->sortByDesc('amount')
            ->take($limit)
            ->values()
            ->all();
    }
}
