<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SocietyStaff extends Model
{
    use HasFactory;

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'society_staff';

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
        'company_id',
        'department',
        'position',
        'employee_id',
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
     * Get the company associated with the society staff.
     */
    public function company()
    {
        return $this->belongsTo(Company::class);
    }

    /**
     * Get the ratings for the society staff.
     */
    public function ratings()
    {
        return $this->hasMany(StaffRating::class, 'staff_id')
            ->where('staff_type', 'society');
    }

    /**
     * Get the schedules for the society staff.
     */
    public function schedules()
    {
        return $this->hasMany(SocietyStaffSchedule::class);
    }

    /**
     * Get the attendance records for the society staff.
     */
    public function attendance()
    {
        return $this->hasMany(SocietyStaffAttendance::class);
    }
}
