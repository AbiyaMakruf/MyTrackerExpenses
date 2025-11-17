<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('wallet_id')->constrained()->cascadeOnDelete();
            $table->foreignId('to_wallet_id')->nullable()->constrained('wallets')->nullOnDelete();
            $table->foreignId('category_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('sub_category_id')->nullable()->constrained('categories')->nullOnDelete();
            $table->foreignId('recurring_transaction_id')->nullable()->constrained()->nullOnDelete();
            $table->string('type')->default('expense');
            $table->decimal('amount', 20, 2);
            $table->string('currency', 3)->default(config('myexpenses.currency.default', 'IDR'));
            $table->decimal('exchange_rate', 20, 6)->default(1);
            $table->decimal('amount_converted', 20, 2)->nullable();
            $table->string('payment_type')->nullable();
            $table->dateTime('transaction_date');
            $table->string('status')->default('posted');
            $table->string('note')->nullable();
            $table->string('attachment_path')->nullable();
            $table->json('metadata')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });

        Schema::create('label_transaction', function (Blueprint $table) {
            $table->id();
            $table->foreignId('transaction_id')->constrained()->cascadeOnDelete();
            $table->foreignId('label_id')->constrained()->cascadeOnDelete();
            $table->timestamps();
            $table->unique(['transaction_id', 'label_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('label_transaction');
        Schema::dropIfExists('transactions');
    }
};
