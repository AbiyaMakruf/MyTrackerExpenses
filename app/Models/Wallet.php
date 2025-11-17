<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Wallet extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'name',
        'type',
        'currency',
        'initial_balance',
        'current_balance',
        'is_default',
        'wallet_icon_id',
        'icon',
        'icon_color',
        'icon_background',
        'meta',
        'archived_at',
    ];

    protected $casts = [
        'initial_balance' => 'decimal:2',
        'current_balance' => 'decimal:2',
        'is_default' => 'boolean',
        'meta' => 'array',
        'archived_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function transactions()
    {
        return $this->hasMany(Transaction::class);
    }

    public function iconDefinition()
    {
        return $this->belongsTo(WalletIcon::class, 'wallet_icon_id');
    }
}
