<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class MemberStaffBooking extends Model
{
    protected $fillable = [
        'staff_id', 'member_id', 'unit_id', 'company_id',
        'start_date', 'end_date', 'repeat_type', 'notes', 'status'
    ];

    public function slots(): HasMany
    {
        return $this->hasMany(BookingSlot::class, 'booking_id');
    }
}
