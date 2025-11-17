<?php

namespace App\Console\Commands;

use App\Models\RecurringTransaction;
use App\Models\Subscription;
use App\Models\Transaction;
use App\Models\Wallet;
use Illuminate\Console\Command;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class ProcessRecurringTransactions extends Command
{
    protected $signature = 'recurring:process';

    protected $description = 'Process recurring transactions and subscriptions';

    public function handle(): int
    {
        $processed = 0;
        $subscriptionsProcessed = 0;

        RecurringTransaction::query()
            ->where('is_active', true)
            ->where('auto_post', true)
            ->where('next_run_at', '<=', now())
            ->chunkById(50, function ($recurrings) use (&$processed) {
                foreach ($recurrings as $recurring) {
                    if ($recurring->last_run_at && $recurring->last_run_at->equalTo($recurring->next_run_at)) {
                        continue;
                    }

                    DB::transaction(function () use ($recurring, &$processed) {
                        $wallet = Wallet::find($recurring->wallet_id);
                        if (! $wallet) {
                            return;
                        }

                        $transaction = Transaction::create([
                            'user_id' => $recurring->user_id,
                            'wallet_id' => $recurring->wallet_id,
                            'to_wallet_id' => $recurring->to_wallet_id,
                            'category_id' => $recurring->category_id,
                            'sub_category_id' => $recurring->sub_category_id,
                            'recurring_transaction_id' => $recurring->id,
                            'type' => $recurring->type,
                            'amount' => $recurring->amount,
                            'currency' => $recurring->currency,
                            'payment_type' => $recurring->payment_type,
                            'transaction_date' => $recurring->next_run_at,
                            'note' => $recurring->note,
                        ]);

                        if ($recurring->type === 'expense') {
                            $wallet->decrement('current_balance', $recurring->amount);
                        } elseif ($recurring->type === 'income') {
                            $wallet->increment('current_balance', $recurring->amount);
                        } elseif ($recurring->type === 'transfer' && $recurring->to_wallet_id) {
                            $wallet->decrement('current_balance', $recurring->amount);
                            Wallet::where('id', $recurring->to_wallet_id)->increment('current_balance', $recurring->amount);
                        }

                        $nextRun = $this->calculateNextRun($recurring);

                        $recurring->update([
                            'last_run_at' => $recurring->next_run_at,
                            'next_run_at' => $nextRun,
                            'is_active' => $recurring->end_date && $nextRun->greaterThan($recurring->end_date) ? false : $recurring->is_active,
                        ]);

                        $processed++;
                    });
                }
            });

        Subscription::query()
            ->where('status', 'active')
            ->where('auto_post_transaction', true)
            ->where('next_billing_date', '<=', today())
            ->chunkById(50, function ($subscriptions) use (&$subscriptionsProcessed) {
                foreach ($subscriptions as $subscription) {
                    DB::transaction(function () use ($subscription, &$subscriptionsProcessed) {
                        $wallet = Wallet::find($subscription->wallet_id);
                        if (! $wallet) {
                            return;
                        }

                        Transaction::create([
                            'user_id' => $subscription->user_id,
                            'wallet_id' => $subscription->wallet_id,
                            'category_id' => $subscription->category_id,
                            'type' => 'expense',
                            'amount' => $subscription->amount,
                            'currency' => $subscription->currency,
                            'transaction_date' => $subscription->next_billing_date->startOfDay(),
                            'payment_type' => 'auto',
                            'note' => $subscription->name,
                        ]);

                        $wallet->decrement('current_balance', $subscription->amount);

                        $subscription->update([
                            'last_billed_at' => now(),
                            'next_billing_date' => $this->calculateSubscriptionNextBilling($subscription),
                        ]);

                        $subscriptionsProcessed++;
                    });
                }
            });

        Log::info('Recurring entries processed', [
            'recurring' => $processed,
            'subscriptions' => $subscriptionsProcessed,
        ]);
        $this->info("Processed {$processed} recurring transactions and {$subscriptionsProcessed} subscriptions");

        return self::SUCCESS;
    }

    protected function calculateNextRun(RecurringTransaction $recurring): Carbon
    {
        $base = $recurring->next_run_at ?? now();

        return match ($recurring->interval) {
            'daily' => $base->copy()->addDay(),
            'weekly' => $base->copy()->addWeek(),
            'yearly' => $base->copy()->addYear(),
            'custom' => $base->copy()->addDays($recurring->custom_days ?? 1),
            default => $base->copy()->addMonth(),
        };
    }

    protected function calculateSubscriptionNextBilling(Subscription $subscription): Carbon
    {
        $base = $subscription->next_billing_date ?? today();

        return match ($subscription->billing_cycle) {
            'weekly' => $base->copy()->addWeek(),
            'quarterly' => $base->copy()->addMonths(3),
            'yearly' => $base->copy()->addYear(),
            default => $base->copy()->addMonth(),
        };
    }
}
