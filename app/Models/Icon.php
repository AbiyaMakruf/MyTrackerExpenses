<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Icon extends Model
{
    use HasFactory;

    protected $fillable = [
        'type',
        'fa_class',
        'image_path',
        'label',
        'group',
        'created_by',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
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
}
