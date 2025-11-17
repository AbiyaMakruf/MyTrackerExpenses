<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('category_icons', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('icon_key')->unique();
            $table->enum('icon_type', ['emoji', 'icon'])->default('icon');
            $table->boolean('is_active')->default(true);
            $table->string('description')->nullable();
            $table->json('meta')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('category_icons');
    }
};
