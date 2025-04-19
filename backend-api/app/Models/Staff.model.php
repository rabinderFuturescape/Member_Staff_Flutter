<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Staff extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'mobile',
        'category',
        'photo_url',
        'id_proof_url',
        'address',
        'next_of_kin',
        'is_verified',
        'member_id',
        'unit_id',
        'company_id',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'is_verified' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * Get the member who owns the staff.
     */
    public function member()
    {
        return $this->belongsTo(Member::class);
    }

    /**
     * Get the unit associated with the staff.
     */
    public function unit()
    {
        return $this->belongsTo(Unit::class);
    }

    /**
     * Get the company associated with the staff.
     */
    public function company()
    {
        return $this->belongsTo(Company::class);
    }

    /**
     * Get the ratings for the staff.
     */
    public function ratings()
    {
        return $this->hasMany(StaffRating::class, 'staff_id')
            ->where('staff_type', 'member');
    }

    /**
     * Get the schedules for the staff.
     */
    public function schedules()
    {
        return $this->hasMany(StaffSchedule::class);
    }

    /**
     * Get the bookings for the staff.
     */
    public function bookings()
    {
        return $this->hasMany(StaffBooking::class);
    }

    /**
     * Get the attendance records for the staff.
     */
    public function attendance()
    {
        return $this->hasMany(StaffAttendance::class);
    }
}
