<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('wallets', function (Blueprint $table) {
            if (Schema::hasColumn('wallets', 'wallet_icon_id')) {
                $table->dropConstrainedForeignId('wallet_icon_id');
            }

            if (Schema::hasColumn('wallets', 'icon')) {
                $table->dropColumn('icon');
            }

            if (! Schema::hasColumn('wallets', 'icon_id')) {
                $table->foreignId('icon_id')->nullable()->after('is_default')->constrained('icons')->nullOnDelete();
            }

            if (! Schema::hasColumn('wallets', 'icon_color')) {
                $table->string('icon_color')->nullable()->after('icon_id');
            }

            if (! Schema::hasColumn('wallets', 'icon_background')) {
                $table->string('icon_background')->nullable()->after('icon_color');
            }
        });
    }

    public function down(): void
    {
        Schema::table('wallets', function (Blueprint $table) {
            if (Schema::hasColumn('wallets', 'icon_id')) {
                $table->dropConstrainedForeignId('icon_id');
            }

            if (Schema::hasColumn('wallets', 'icon_color')) {
                $table->dropColumn('icon_color');
            }

            if (Schema::hasColumn('wallets', 'icon_background')) {
                $table->dropColumn('icon_background');
            }

            $table->string('icon')->nullable();
        });
    }
};
