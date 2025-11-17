<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('subscriptions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->decimal('amount', 20, 2);
            $table->string('billing_cycle')->default('monthly');
            $table->date('next_billing_date')->nullable();
            $table->foreignId('wallet_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('category_id')->nullable()->constrained()->nullOnDelete();
            $table->string('status')->default('active');
            $table->boolean('auto_post_transaction')->default(false);
            $table->unsignedInteger('reminder_days')->default(3);
            $table->timestamp('last_billed_at')->nullable();
            $table->string('currency', 3)->default(config('myexpenses.currency.default', 'IDR'));
            $table->string('note')->nullable();
            $table->json('metadata')->nullable();
            $table->softDeletes();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('subscriptions');
    }
};
