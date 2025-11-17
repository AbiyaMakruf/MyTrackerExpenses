<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::dropIfExists('wallet_icons');
        Schema::dropIfExists('category_icons');
    }

    public function down(): void
    {
        // Legacy tables are not recreated.
    }
};
