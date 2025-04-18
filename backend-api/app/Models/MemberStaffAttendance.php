<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MemberStaffAttendance extends Model
{
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
}
