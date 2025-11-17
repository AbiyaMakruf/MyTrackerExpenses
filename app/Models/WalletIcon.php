<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class WalletIcon extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'source_type',
        'value',
        'icon_color',
        'background_color',
    ];

    public function wallets()
    {
        return $this->hasMany(Wallet::class);
    }
}
