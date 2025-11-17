<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('wallet_icons', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->enum('source_type', ['class', 'upload'])->default('class');
            $table->string('value');
            $table->string('icon_color')->nullable();
            $table->string('background_color')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('wallet_icons');
    }
};
