<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CategoryIcon extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'icon_key',
        'icon_type',
        'is_active',
        'description',
        'meta',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'meta' => 'array',
    ];

    public function categories()
    {
        return $this->hasMany(Category::class);
    }
}
