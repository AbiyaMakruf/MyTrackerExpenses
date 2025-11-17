<?php

namespace Database\Seeders;

use App\Models\Budget;
use App\Models\Category;
use App\Models\Goal;
use App\Models\Label;
use App\Models\PlannedPayment;
use App\Models\RecurringTransaction;
use App\Models\Subscription;
use App\Models\Transaction;
use App\Models\User;
use App\Models\Icon;
use App\Models\Wallet;
use Illuminate\Database\Seeder;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Hash;
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
            // Finance / Money
            ['label' => 'Wallet', 'group' => 'finance', 'fa_class' => 'fas:wallet'],
            ['label' => 'Coins', 'group' => 'finance', 'fa_class' => 'fas:coins'],
            ['label' => 'Money Bill', 'group' => 'finance', 'fa_class' => 'fas:money-bill'],
            ['label' => 'Money Check', 'group' => 'finance', 'fa_class' => 'fas:money-check'],
            ['label' => 'Sack Dollar', 'group' => 'finance', 'fa_class' => 'fas:sack-dollar'],
            ['label' => 'Credit Card', 'group' => 'finance', 'fa_class' => 'far:credit-card'],
            ['label' => 'Piggy Bank', 'group' => 'finance', 'fa_class' => 'fas:piggy-bank'],
            // Banks
            ['label' => 'Building Columns', 'group' => 'banks', 'fa_class' => 'fas:building-columns'],
            ['label' => 'Bank', 'group' => 'banks', 'fa_class' => 'fas:bank'],
            ['label' => 'Vault', 'group' => 'banks', 'fa_class' => 'fas:vault'],
            // Shopping
            ['label' => 'Cart Shopping', 'group' => 'shopping', 'fa_class' => 'fas:cart-shopping'],
            ['label' => 'Basket', 'group' => 'shopping', 'fa_class' => 'fas:basket-shopping'],
            ['label' => 'Store', 'group' => 'shopping', 'fa_class' => 'fas:store'],
            ['label' => 'Tags', 'group' => 'shopping', 'fa_class' => 'fas:tags'],
            // Food
            ['label' => 'Utensils', 'group' => 'food', 'fa_class' => 'fas:utensils'],
            ['label' => 'Burger', 'group' => 'food', 'fa_class' => 'fas:burger'],
            ['label' => 'Mug Hot', 'group' => 'food', 'fa_class' => 'fas:mug-hot'],
            ['label' => 'Wine Glass', 'group' => 'food', 'fa_class' => 'fas:wine-glass'],
            ['label' => 'Heart Pulse', 'group' => 'health', 'fa_class' => 'fas:heart-pulse'],
            ['label' => 'Gifts', 'group' => 'general', 'fa_class' => 'fas:gifts'],
            // Transportation
            ['label' => 'Car', 'group' => 'transport', 'fa_class' => 'fas:car'],
            ['label' => 'Motorcycle', 'group' => 'transport', 'fa_class' => 'fas:motorcycle'],
            ['label' => 'Bus', 'group' => 'transport', 'fa_class' => 'fas:bus'],
            ['label' => 'Gas Pump', 'group' => 'transport', 'fa_class' => 'fas:gas-pump'],
            // Bills & Utilities
            ['label' => 'Invoice', 'group' => 'bills', 'fa_class' => 'fas:file-invoice'],
            ['label' => 'Bolt', 'group' => 'bills', 'fa_class' => 'fas:bolt'],
            ['label' => 'Water', 'group' => 'bills', 'fa_class' => 'fas:water'],
            ['label' => 'Receipt', 'group' => 'bills', 'fa_class' => 'fas:receipt'],
            // Subscriptions
            ['label' => 'Cloud', 'group' => 'subscriptions', 'fa_class' => 'fas:cloud'],
            ['label' => 'TV', 'group' => 'subscriptions', 'fa_class' => 'fas:tv'],
            ['label' => 'Apple', 'group' => 'subscriptions', 'fa_class' => 'fab:apple'],
            ['label' => 'Spotify', 'group' => 'subscriptions', 'fa_class' => 'fab:spotify'],
            ['label' => 'Disney', 'group' => 'subscriptions', 'fa_class' => 'fab:disney'],
            ['label' => 'Wifi', 'group' => 'subscriptions', 'fa_class' => 'fas:wifi'],
            // Income
            ['label' => 'Briefcase', 'group' => 'income', 'fa_class' => 'fas:briefcase'],
            ['label' => 'Chart Line', 'group' => 'income', 'fa_class' => 'fas:chart-line'],
            ['label' => 'Dollar Slot', 'group' => 'income', 'fa_class' => 'fas:circle-dollar-to-slot'],
            // General
            ['label' => 'Tag', 'group' => 'general', 'fa_class' => 'fas:tag'],
            ['label' => 'List', 'group' => 'general', 'fa_class' => 'fas:list'],
            ['label' => 'Box', 'group' => 'general', 'fa_class' => 'fas:box'],
            ['label' => 'Circle', 'group' => 'general', 'fa_class' => 'fas:circle'],
        ];

        foreach ($icons as $icon) {
            Icon::updateOrCreate(
                ['fa_class' => $icon['fa_class']],
                [
                    'type' => 'fontawesome',
                    'label' => $icon['label'],
                    'group' => $icon['group'],
                    'is_active' => true,
                ],
            );
        }
    }

    protected function seedDefaultCategories(): void
    {
        $icons = Icon::all()->keyBy('fa_class');
        $defaultCategories = [
            ['name' => 'Food & Beverages', 'type' => 'expense', 'icon_key' => 'fas:mug-hot', 'color' => '#F97316'],
            ['name' => 'Groceries', 'type' => 'expense', 'icon_key' => 'fas:cart-shopping', 'color' => '#FACC15'],
            ['name' => 'Transport', 'type' => 'expense', 'icon_key' => 'fas:car', 'color' => '#60A5FA'],
            ['name' => 'Health & Fitness', 'type' => 'expense', 'icon_key' => 'fas:heart-pulse', 'color' => '#F472B6'],
            ['name' => 'Entertainment', 'type' => 'expense', 'icon_key' => 'fas:tv', 'color' => '#A855F7'],
            ['name' => 'Subscriptions', 'type' => 'expense', 'icon_key' => 'fas:wifi', 'color' => '#0EA5E9'],
            ['name' => 'Salary', 'type' => 'income', 'icon_key' => 'fas:briefcase', 'color' => '#10B981'],
            ['name' => 'Investments', 'type' => 'income', 'icon_key' => 'fas:chart-line', 'color' => '#14B8A6'],
            ['name' => 'Gift', 'type' => 'income', 'icon_key' => 'fas:gifts', 'color' => '#FB7185'],
        ];

        foreach ($defaultCategories as $order => $category) {
            Category::updateOrCreate(
                ['name' => $category['name'], 'type' => $category['type'], 'user_id' => null],
                [
                    'icon_id' => $icons[$category['icon_key']]->id ?? null,
                    'color' => $category['color'],
                    'display_order' => $order + 1,
                    'is_default' => true,
                    'icon_background' => $category['color'],
                ]
            );
        }
    }

    protected function seedDemoData(): void
    {
        $admin = User::factory()->create([
            'name' => 'Admin',
            'email' => 'admin@abiya',
            'role' => 'admin',
            'password' => Hash::make('Abiyajr11'),
            'two_factor_secret' => null,
            'two_factor_recovery_codes' => null,
            'two_factor_confirmed_at' => null,
        ]);

        $user = User::factory()->create([
            'name' => 'Demo User',
            'email' => 'demo@myexpenses.test',
        ]);

        $walletIcon = Icon::where('fa_class', 'fas:wallet')->first();
        $cashIcon = Icon::where('fa_class', 'fas:money-bill')->first();

        $wallets = [
            'main' => Wallet::factory()->for($user)->create([
                'name' => config('myexpenses.wallets.default_name'),
                'type' => 'bank',
                'initial_balance' => 5_000_000,
                'current_balance' => 5_000_000,
                'is_default' => true,
                'icon_id' => optional($walletIcon)->id,
                'icon_color' => '#095C4A',
                'icon_background' => '#D2F9E7',
            ]),
            'cash' => Wallet::factory()->for($user)->create([
                'name' => 'Cash',
                'type' => 'cash',
                'initial_balance' => 1_000_000,
                'current_balance' => 750_000,
                'icon_id' => optional($cashIcon)->id,
                'icon_color' => '#F97316',
                'icon_background' => '#FFF7ED',
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
