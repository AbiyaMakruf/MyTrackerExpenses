<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Goal extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'name',
        'target_amount',
        'current_amount',
        'deadline',
        'goal_wallet_id',
        'auto_save_amount',
        'auto_save_interval',
        'auto_save_next_run_at',
        'auto_save_enabled',
        'status',
        'note',
        'metadata',
    ];

    protected $casts = [
        'target_amount' => 'decimal:2',
        'current_amount' => 'decimal:2',
        'deadline' => 'date',
        'auto_save_amount' => 'decimal:2',
        'auto_save_next_run_at' => 'datetime',
        'auto_save_enabled' => 'boolean',
        'metadata' => 'array',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function wallet()
    {
        return $this->belongsTo(Wallet::class, 'goal_wallet_id');
    }
}
