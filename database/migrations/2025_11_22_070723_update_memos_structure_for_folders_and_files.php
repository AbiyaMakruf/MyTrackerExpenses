<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('memo_folders', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->string('color')->default('#095C4A');
            $table->timestamps();
        });

        Schema::table('memo_groups', function (Blueprint $table) {
            $table->foreignId('memo_folder_id')->nullable()->constrained()->cascadeOnDelete();
        });

        Schema::table('memo_entries', function (Blueprint $table) {
            $table->renameColumn('image_path', 'file_path');
            $table->string('file_name')->nullable();
            $table->string('mime_type')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('memo_entries', function (Blueprint $table) {
            $table->dropColumn(['file_name', 'mime_type']);
            $table->renameColumn('file_path', 'image_path');
        });

        Schema::table('memo_groups', function (Blueprint $table) {
            $table->dropForeign(['memo_folder_id']);
            $table->dropColumn('memo_folder_id');
        });

        Schema::dropIfExists('memo_folders');
    }
};
