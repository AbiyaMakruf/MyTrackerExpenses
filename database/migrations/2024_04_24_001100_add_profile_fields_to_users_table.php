<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('role')->default('user')->after('id');
            $table->string('base_currency', 3)->default(config('myexpenses.currency.default', 'IDR'))->after('email');
            $table->string('language', 5)->default(config('myexpenses.default_language', 'en'))->after('base_currency');
            $table->string('timezone')->default(config('myexpenses.default_timezone', 'Asia/Jakarta'))->after('language');
            $table->foreignId('default_wallet_id')->nullable()->after('timezone')->constrained('wallets')->nullOnDelete();
            $table->json('settings')->nullable()->after('remember_token');
            $table->timestamp('last_active_at')->nullable()->after('settings');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropConstrainedForeignId('default_wallet_id');
            $table->dropColumn([
                'role',
                'base_currency',
                'language',
                'timezone',
                'settings',
                'last_active_at',
            ]);
        });
    }
};
