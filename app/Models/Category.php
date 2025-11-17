<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Category extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'category_icon_id',
        'parent_id',
        'name',
        'type',
        'color',
        'is_default',
        'is_archived',
        'display_order',
    ];

    protected $casts = [
        'is_default' => 'boolean',
        'is_archived' => 'boolean',
    ];

    public function icon()
    {
        return $this->belongsTo(CategoryIcon::class, 'category_icon_id');
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function parent()
    {
        return $this->belongsTo(self::class, 'parent_id');
    }

    public function children()
    {
        return $this->hasMany(self::class, 'parent_id');
    }

    public function transactions()
    {
        return $this->hasMany(Transaction::class);
    }
}
