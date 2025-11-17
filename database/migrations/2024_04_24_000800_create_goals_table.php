<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('goals', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->decimal('target_amount', 20, 2);
            $table->decimal('current_amount', 20, 2)->default(0);
            $table->date('deadline')->nullable();
            $table->foreignId('goal_wallet_id')->nullable()->constrained('wallets')->nullOnDelete();
            $table->decimal('auto_save_amount', 20, 2)->nullable();
            $table->string('auto_save_interval')->nullable();
            $table->timestamp('auto_save_next_run_at')->nullable();
            $table->boolean('auto_save_enabled')->default(false);
            $table->string('status')->default('ongoing');
            $table->string('note')->nullable();
            $table->json('metadata')->nullable();
            $table->softDeletes();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('goals');
    }
};
