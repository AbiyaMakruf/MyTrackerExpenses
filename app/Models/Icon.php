<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class Icon extends Model
{
    use HasFactory;

    protected $fillable = [
        'type',
        'fa_class',
        'image_path',
        'image_disk',
        'label',
        'group',
        'created_by',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    protected $appends = [
        'image_url',
    ];

    public function creator()
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function wallets()
    {
        return $this->hasMany(Wallet::class);
    }

    public function categories()
    {
        return $this->hasMany(Category::class);
    }

    public function getImageUrlAttribute(): ?string
    {
        if (! $this->image_path) {
            return null;
        }

        if (Str::startsWith($this->image_path, ['http://', 'https://'])) {
            return $this->image_path;
        }

        $disk = $this->image_disk ?: config('filesystems.icons_disk', 'public');

        if ($disk === 'gcs') {
            $bucket = config('services.gcs.bucket', 'tracker-expenses');
            return sprintf('https://storage.googleapis.com/%s/%s', $bucket, ltrim($this->image_path, '/'));
        }

        return Storage::disk($disk)->url($this->image_path);
    }
}
