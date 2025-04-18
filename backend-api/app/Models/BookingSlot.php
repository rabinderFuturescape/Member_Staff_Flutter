<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class BookingSlot extends Model
{
    protected $fillable = ['booking_id', 'date', 'hour', 'is_confirmed'];

    public function booking(): BelongsTo
    {
        return $this->belongsTo(MemberStaffBooking::class, 'booking_id');
    }
}
