<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Payment extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'bill_id',
        'amount',
        'payment_date',
        'payment_method',
        'transaction_id',
        'receipt_number',
        'notes',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'amount' => 'decimal:2',
        'payment_date' => 'date',
    ];

    /**
     * Get the bill that owns the payment.
     */
    public function bill()
    {
        return $this->belongsTo(MemberBill::class, 'bill_id');
    }

    /**
     * Get the member through the bill.
     */
    public function member()
    {
        return $this->hasOneThrough(Member::class, MemberBill::class, 'id', 'id', 'bill_id', 'member_id');
    }
}
