<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('icons', function (Blueprint $table) {
            if (! Schema::hasColumn('icons', 'image_disk')) {
                $table->string('image_disk')->nullable()->after('image_path');
            }
        });
    }

    public function down(): void
    {
        Schema::table('icons', function (Blueprint $table) {
            if (Schema::hasColumn('icons', 'image_disk')) {
                $table->dropColumn('image_disk');
            }
        });
    }
};
