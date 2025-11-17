<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Subscription extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'name',
        'amount',
        'billing_cycle',
        'next_billing_date',
        'wallet_id',
        'category_id',
        'sub_category_id',
        'status',
        'auto_post_transaction',
        'reminder_days',
        'last_billed_at',
        'currency',
        'note',
        'metadata',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'next_billing_date' => 'date',
        'auto_post_transaction' => 'boolean',
        'reminder_days' => 'integer',
        'last_billed_at' => 'datetime',
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

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function subCategory()
    {
        return $this->belongsTo(Category::class, 'sub_category_id');
    }
}
