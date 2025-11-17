<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('wallets', function (Blueprint $table) {
            $table->foreignId('wallet_icon_id')->nullable()->after('is_default')->constrained()->nullOnDelete();
            $table->string('icon_color')->nullable()->after('wallet_icon_id');
            $table->string('icon_background')->nullable()->after('icon_color');
        });
    }

    public function down(): void
    {
        Schema::table('wallets', function (Blueprint $table) {
            $table->dropConstrainedForeignId('wallet_icon_id');
            $table->dropColumn(['icon_color', 'icon_background']);
        });
    }
};
