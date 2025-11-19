<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Budget extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'name',
        'category_id',
        'wallet_id',
        'amount',
        'period_type',
        'start_date',
        'end_date',
        'color',
        'threshold_warning',
        'icon_id',
        'note',
        'metadata',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'threshold_warning' => 'decimal:2',
        'start_date' => 'date',
        'end_date' => 'date',
        'metadata' => 'array',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function wallet()
    {
        return $this->belongsTo(Wallet::class);
    }

    public function icon()
    {
        return $this->belongsTo(Icon::class);
    }
}
