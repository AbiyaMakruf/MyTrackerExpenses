<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Transaction extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'wallet_id',
        'to_wallet_id',
        'category_id',
        'sub_category_id',
        'recurring_transaction_id',
        'type',
        'amount',
        'currency',
        'exchange_rate',
        'amount_converted',
        'payment_type',
        'transaction_date',
        'status',
        'note',
        'attachment_path',
        'metadata',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'amount_converted' => 'decimal:2',
        'exchange_rate' => 'decimal:6',
        'transaction_date' => 'datetime',
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

    public function subCategory()
    {
        return $this->belongsTo(Category::class, 'sub_category_id');
    }

    public function recurringTemplate()
    {
        return $this->belongsTo(RecurringTransaction::class, 'recurring_transaction_id');
    }

    public function labels()
    {
        return $this->belongsToMany(Label::class)->withTimestamps();
    }
}
