<?php

namespace Database\Seeders;

use App\Models\Budget;
use App\Models\Category;
use App\Models\CategoryIcon;
use App\Models\Goal;
use App\Models\Label;
use App\Models\PlannedPayment;
use App\Models\RecurringTransaction;
use App\Models\Subscription;
use App\Models\Transaction;
use App\Models\User;
use App\Models\Wallet;
use Illuminate\Database\Seeder;
use Illuminate\Support\Collection;
use Illuminate\Support\Str;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->seedDefaultIcons();
        $this->seedDefaultCategories();
        $this->seedDemoData();
    }

    protected function seedDefaultIcons(): void
    {
        $icons = [
            ['name' => 'Food & Drink', 'icon_key' => 'heroicon-mug-hot', 'icon_type' => 'icon'],
            ['name' => 'Shopping', 'icon_key' => 'heroicon-shopping-bag', 'icon_type' => 'icon'],
            ['name' => 'Transport', 'icon_key' => 'heroicon-truck', 'icon_type' => 'icon'],
            ['name' => 'Salary', 'icon_key' => 'heroicon-banknotes', 'icon_type' => 'icon'],
            ['name' => 'Health', 'icon_key' => 'heroicon-heart', 'icon_type' => 'icon'],
            ['name' => 'Subscription', 'icon_key' => 'heroicon-credit-card', 'icon_type' => 'icon'],
            ['name' => 'Entertainment', 'icon_key' => 'heroicon-tv', 'icon_type' => 'icon'],
            ['name' => 'Investments', 'icon_key' => 'heroicon-presentation-chart-line', 'icon_type' => 'icon'],
            ['name' => 'Gift', 'icon_key' => '🎁', 'icon_type' => 'emoji'],
        ];

        foreach ($icons as $icon) {
            CategoryIcon::updateOrCreate(
                ['icon_key' => $icon['icon_key']],
                $icon
            );
        }
    }

    protected function seedDefaultCategories(): void
    {
        $icons = CategoryIcon::all()->keyBy('icon_key');
        $defaultCategories = [
            ['name' => 'Food & Beverages', 'type' => 'expense', 'icon_key' => 'heroicon-mug-hot', 'color' => '#F97316'],
            ['name' => 'Groceries', 'type' => 'expense', 'icon_key' => 'heroicon-shopping-bag', 'color' => '#FACC15'],
            ['name' => 'Transport', 'type' => 'expense', 'icon_key' => 'heroicon-truck', 'color' => '#60A5FA'],
            ['name' => 'Health & Fitness', 'type' => 'expense', 'icon_key' => 'heroicon-heart', 'color' => '#F472B6'],
            ['name' => 'Entertainment', 'type' => 'expense', 'icon_key' => 'heroicon-tv', 'color' => '#A855F7'],
            ['name' => 'Subscriptions', 'type' => 'expense', 'icon_key' => 'heroicon-credit-card', 'color' => '#0EA5E9'],
            ['name' => 'Salary', 'type' => 'income', 'icon_key' => 'heroicon-banknotes', 'color' => '#10B981'],
            ['name' => 'Investments', 'type' => 'income', 'icon_key' => 'heroicon-presentation-chart-line', 'color' => '#14B8A6'],
            ['name' => 'Gift', 'type' => 'income', 'icon_key' => '🎁', 'color' => '#FB7185'],
        ];

        foreach ($defaultCategories as $order => $category) {
            Category::updateOrCreate(
                ['name' => $category['name'], 'type' => $category['type'], 'user_id' => null],
                [
                    'category_icon_id' => $icons[$category['icon_key']]->id ?? null,
                    'color' => $category['color'],
                    'display_order' => $order + 1,
                    'is_default' => true,
                ]
            );
        }
    }

    protected function seedDemoData(): void
    {
        $admin = User::factory()->create([
            'name' => 'Admin',
            'email' => 'admin@myexpenses.test',
            'role' => 'admin',
        ]);

        $user = User::factory()->create([
            'name' => 'Demo User',
            'email' => 'demo@myexpenses.test',
        ]);

        $wallets = [
            'main' => Wallet::factory()->for($user)->create([
                'name' => config('myexpenses.wallets.default_name'),
                'type' => 'bank',
                'initial_balance' => 5_000_000,
                'current_balance' => 5_000_000,
                'is_default' => true,
            ]),
            'cash' => Wallet::factory()->for($user)->create([
                'name' => 'Cash',
                'type' => 'cash',
                'initial_balance' => 1_000_000,
                'current_balance' => 750_000,
            ]),
        ];

        $user->update(['default_wallet_id' => $wallets['main']->id]);

        $labels = collect(['Business', 'Personal', 'Recurring'])->mapWithKeys(function (string $label) use ($user) {
            return [
                Str::slug($label) => Label::create([
                    'user_id' => $user->id,
                    'name' => $label,
                    'slug' => Str::slug($label),
                    'color' => fake()->hexColor(),
                ]),
            ];
        });

        $categories = Category::whereNull('user_id')->get()->keyBy(fn (Category $category) => Str::slug($category->name));
        $now = now();

        $transactions = Collection::make([
            [
                'type' => 'expense',
                'category' => 'food-beverages',
                'amount' => 150_000,
                'wallet' => 'main',
                'label' => 'personal',
                'note' => 'Brunch with family',
            ],
            [
                'type' => 'expense',
                'category' => 'subscriptions',
                'amount' => 89_000,
                'wallet' => 'main',
                'label' => 'recurring',
                'note' => 'Netflix subscription',
            ],
            [
                'type' => 'income',
                'category' => 'salary',
                'amount' => 15_000_000,
                'wallet' => 'main',
                'label' => 'business',
                'note' => 'Monthly salary',
            ],
            [
                'type' => 'expense',
                'category' => 'transport',
                'amount' => 35_000,
                'wallet' => 'cash',
                'label' => 'personal',
                'note' => 'Taxi ride',
            ],
        ]);

        $transactions->each(function (array $data) use ($user, $wallets, $categories, $labels, $now) {
            $transaction = Transaction::create([
                'user_id' => $user->id,
                'wallet_id' => $wallets[$data['wallet']]->id,
                'type' => $data['type'],
                'category_id' => optional($categories[$data['category']] ?? null)->id,
                'amount' => $data['amount'],
                'currency' => $user->base_currency,
                'transaction_date' => $now->copy()->subDays(rand(0, 10)),
                'payment_type' => 'transfer',
                'note' => $data['note'],
            ]);

            if (isset($labels[$data['label']])) {
                $transaction->labels()->attach($labels[$data['label']]);
            }
        });

        Budget::create([
            'user_id' => $user->id,
            'name' => 'Monthly Food Budget',
            'category_id' => optional($categories['food-beverages'] ?? null)->id,
            'wallet_id' => $wallets['main']->id,
            'amount' => 3_000_000,
            'period_type' => 'monthly',
            'start_date' => now()->startOfMonth(),
            'end_date' => now()->endOfMonth(),
            'color' => '#15B489',
            'threshold_warning' => 80,
            'note' => 'Try to stay within 3M for food',
        ]);

        PlannedPayment::create([
            'user_id' => $user->id,
            'title' => 'Electricity Bill',
            'amount' => 500_000,
            'due_date' => now()->addDays(7),
            'wallet_id' => $wallets['main']->id,
            'category_id' => optional($categories['subscriptions'] ?? null)->id,
            'repeat_option' => 'monthly',
            'is_recurring' => true,
            'note' => 'PLN monthly payment',
        ]);

        Goal::create([
            'user_id' => $user->id,
            'name' => 'Emergency Fund',
            'target_amount' => 50_000_000,
            'current_amount' => 15_000_000,
            'deadline' => now()->addMonths(10),
            'goal_wallet_id' => $wallets['main']->id,
            'auto_save_amount' => 5_000_000,
            'auto_save_interval' => 'monthly',
            'auto_save_next_run_at' => now()->addMonth(),
            'auto_save_enabled' => true,
            'status' => 'ongoing',
            'note' => '6 months of living expenses',
        ]);

        Subscription::create([
            'user_id' => $user->id,
            'name' => 'Spotify Premium',
            'amount' => 54_990,
            'billing_cycle' => 'monthly',
            'next_billing_date' => now()->addDays(12),
            'wallet_id' => $wallets['main']->id,
            'category_id' => optional($categories['subscriptions'] ?? null)->id,
            'status' => 'active',
            'auto_post_transaction' => true,
            'reminder_days' => 3,
            'currency' => $user->base_currency,
        ]);

        RecurringTransaction::create([
            'user_id' => $user->id,
            'wallet_id' => $wallets['main']->id,
            'category_id' => optional($categories['salary'] ?? null)->id,
            'type' => 'income',
            'amount' => 15_000_000,
            'currency' => $user->base_currency,
            'payment_type' => 'transfer',
            'interval' => 'monthly',
            'next_run_at' => now()->addMonth(),
            'auto_post' => true,
            'note' => 'Monthly salary auto record',
        ]);
    }
}
