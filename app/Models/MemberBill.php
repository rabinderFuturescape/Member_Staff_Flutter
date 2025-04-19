<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MemberBill extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'member_id',
        'bill_cycle',
        'amount',
        'due_date',
        'status',
        'description',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'amount' => 'decimal:2',
        'due_date' => 'date',
    ];

    /**
     * Get the member that owns the bill.
     */
    public function member()
    {
        return $this->belongsTo(Member::class);
    }

    /**
     * Get the payments for the bill.
     */
    public function payments()
    {
        return $this->hasMany(Payment::class, 'bill_id');
    }

    /**
     * Calculate the total amount paid for this bill.
     *
     * @return float
     */
    public function getTotalPaidAttribute()
    {
        return $this->payments->sum('amount');
    }

    /**
     * Calculate the remaining amount due for this bill.
     *
     * @return float
     */
    public function getDueAmountAttribute()
    {
        return $this->amount - $this->total_paid;
    }

    /**
     * Get the last payment date for this bill.
     *
     * @return \Illuminate\Support\Carbon|null
     */
    public function getLastPaymentDateAttribute()
    {
        $lastPayment = $this->payments()->latest('payment_date')->first();
        return $lastPayment ? $lastPayment->payment_date : null;
    }

    /**
     * Check if the bill is overdue.
     *
     * @return bool
     */
    public function getIsOverdueAttribute()
    {
        return $this->due_amount > 0 && $this->due_date < now();
    }
}
