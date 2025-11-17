<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('recurring_transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('wallet_id')->constrained()->cascadeOnDelete();
            $table->foreignId('to_wallet_id')->nullable()->constrained('wallets')->nullOnDelete();
            $table->foreignId('category_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('sub_category_id')->nullable()->constrained('categories')->nullOnDelete();
            $table->string('type')->default('expense');
            $table->decimal('amount', 20, 2);
            $table->string('currency', 3)->default(config('myexpenses.currency.default', 'IDR'));
            $table->string('payment_type')->nullable();
            $table->string('interval')->default('monthly');
            $table->unsignedInteger('custom_days')->nullable();
            $table->timestamp('next_run_at');
            $table->date('end_date')->nullable();
            $table->boolean('auto_post')->default(true);
            $table->timestamp('last_run_at')->nullable();
            $table->boolean('is_active')->default(true);
            $table->string('note')->nullable();
            $table->json('metadata')->nullable();
            $table->softDeletes();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('recurring_transactions');
    }
};
