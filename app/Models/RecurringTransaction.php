<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class RecurringTransaction extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'wallet_id',
        'to_wallet_id',
        'category_id',
        'sub_category_id',
        'type',
        'amount',
        'currency',
        'payment_type',
        'interval',
        'custom_days',
        'next_run_at',
        'end_date',
        'auto_post',
        'last_run_at',
        'is_active',
        'note',
        'metadata',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'custom_days' => 'integer',
        'next_run_at' => 'datetime',
        'end_date' => 'date',
        'auto_post' => 'boolean',
        'last_run_at' => 'datetime',
        'is_active' => 'boolean',
        'metadata' => 'array',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function wallet()
    {
        return $this->belongsTo(Wallet::class);
    }

    public function destinationWallet()
    {
        return $this->belongsTo(Wallet::class, 'to_wallet_id');
    }

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function transactions()
    {
        return $this->hasMany(Transaction::class);
    }
}
