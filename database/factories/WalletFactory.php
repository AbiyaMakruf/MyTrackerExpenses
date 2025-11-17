<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<\App\Models\Wallet>
 */
class WalletFactory extends Factory
{
    public function definition(): array
    {
        $types = config('myexpenses.wallets.types', ['bank', 'e-wallet', 'cash']);

        return [
            'user_id' => User::factory(),
            'name' => fake()->randomElement(['BCA', 'Mandiri', 'GoPay', 'Cash']) . ' ' . fake()->word(),
            'type' => fake()->randomElement($types),
            'currency' => config('myexpenses.currency.default', 'IDR'),
            'initial_balance' => fake()->numberBetween(100000, 5000000),
            'current_balance' => fn (array $attributes) => $attributes['initial_balance'],
            'is_default' => false,
            'icon' => 'heroicon-wallet',
        ];
    }
}
