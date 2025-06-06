<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MemberStaffAttendance extends Model
{
    use HasFactory;

    protected $table = 'member_staff_attendance';

    protected $fillable = [
        'member_id',
        'staff_id',
        'unit_id',
        'date',
        'status',
        'note',
        'photo_url'
    ];

    protected $casts = [
        'date' => 'date',
    ];

    /**
     * Get the staff that owns the attendance record.
     */
    public function staff(): BelongsTo
    {
        return $this->belongsTo(Staff::class);
    }

    /**
     * Get the member that owns the attendance record.
     */
    public function member(): BelongsTo
    {
        return $this->belongsTo(Member::class);
    }
}
