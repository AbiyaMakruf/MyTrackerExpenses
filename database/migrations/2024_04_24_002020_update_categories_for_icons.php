<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('categories', function (Blueprint $table) {
            if (Schema::hasColumn('categories', 'category_icon_id')) {
                $table->dropConstrainedForeignId('category_icon_id');
            }

            if (! Schema::hasColumn('categories', 'icon_id')) {
                $table->foreignId('icon_id')->nullable()->after('parent_id')->constrained('icons')->nullOnDelete();
            }

            if (! Schema::hasColumn('categories', 'icon_color')) {
                $table->string('icon_color')->nullable()->after('icon_id');
            }

            if (! Schema::hasColumn('categories', 'icon_background')) {
                $table->string('icon_background')->nullable()->after('icon_color');
            }
        });
    }

    public function down(): void
    {
        Schema::table('categories', function (Blueprint $table) {
            if (Schema::hasColumn('categories', 'icon_id')) {
                $table->dropConstrainedForeignId('icon_id');
            }

            if (Schema::hasColumn('categories', 'icon_color')) {
                $table->dropColumn('icon_color');
            }

            if (Schema::hasColumn('categories', 'icon_background')) {
                $table->dropColumn('icon_background');
            }
        });
    }
};
