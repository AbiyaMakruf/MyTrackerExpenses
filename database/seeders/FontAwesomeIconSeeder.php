<?php

namespace Database\Seeders;

use App\Models\Icon;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class FontAwesomeIconSeeder extends Seeder
{
    public function run(): void
    {
        $disk = Storage::disk('public');
        $basePath = 'icons/fontawesome';

        if (!$disk->exists($basePath)) {
            $this->command->error("Directory not found: {$basePath}");
            return;
        }

        // Fix existing icons that might have been imported as 'image' type
        $updated = Icon::where('image_path', 'like', $basePath . '/%')
            ->where('type', 'image')
            ->update(['type' => 'fontawesome']);
            
        if ($updated > 0) {
            $this->command->info("Updated {$updated} existing icons to FontAwesome type.");
        }

        // Get all files recursively
        $files = $disk->allFiles($basePath);
        
        $this->command->info("Found " . count($files) . " files. Starting import...");

        $batchSize = 100;
        $batch = [];
        $count = 0;

        foreach ($files as $file) {
            // Only process SVG files
            if (strtolower(pathinfo($file, PATHINFO_EXTENSION)) !== 'svg') {
                continue;
            }

            // Parse path to get group and label
            // Example: icons/fontawesome/solid/address-book.svg
            // Group: solid
            // Label: Address Book
            
            $relativePath = Str::after($file, $basePath . '/');
            $parts = explode('/', $relativePath);
            
            // If file is in a subdirectory, use that as group, otherwise 'default'
            $group = count($parts) > 1 ? $parts[0] : 'default';
            $filename = pathinfo($file, PATHINFO_FILENAME);
            $label = Str::title(str_replace('-', ' ', $filename));

            // Check if icon already exists to avoid duplicates
            // We check by image_path
            $exists = Icon::where('image_path', $file)->exists();

            if (!$exists) {
                $batch[] = [
                    'type' => 'fontawesome',
                    'fa_class' => null,
                    'image_path' => $file,
                    'image_disk' => 'public',
                    'label' => $label,
                    'group' => $group,
                    'created_by' => null, // System generated
                    'is_active' => true,
                    'created_at' => now(),
                    'updated_at' => now(),
                ];
            }

            if (count($batch) >= $batchSize) {
                Icon::insert($batch);
                $count += count($batch);
                $this->command->info("Imported {$count} icons...");
                $batch = [];
            }
        }

        if (!empty($batch)) {
            Icon::insert($batch);
            $count += count($batch);
        }

        $this->command->info("Done! Total imported: {$count}");
    }
}
