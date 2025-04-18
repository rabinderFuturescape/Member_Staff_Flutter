<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Staff extends Model
{
    use HasFactory, SoftDeletes;

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'staff';

    /**
     * The primary key for the model.
     *
     * @var string
     */
    protected $primaryKey = 'id';

    /**
     * Indicates if the IDs are auto-incrementing.
     *
     * @var bool
     */
    public $incrementing = false;

    /**
     * The data type of the auto-incrementing ID.
     *
     * @var string
     */
    protected $keyType = 'string';

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'mobile',
        'email',
        'staff_scope',
        'department',
        'designation',
        'society_id',
        'unit_id',
        'company_id',
        'aadhaar_number',
        'residential_address',
        'next_of_kin_name',
        'next_of_kin_mobile',
        'photo_url',
        'is_verified',
        'verified_at',
        'verified_by_member_id',
        'created_by',
        'updated_by',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'is_verified' => 'boolean',
        'verified_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * Get the time slots for the staff.
     */
    public function timeSlots()
    {
        return $this->hasMany(TimeSlot::class);
    }

    /**
     * Get the member assignments for the staff.
     */
    public function memberAssignments()
    {
        return $this->hasMany(MemberStaffAssignment::class);
    }

    /**
     * Get the members assigned to this staff.
     */
    public function members()
    {
        return $this->belongsToMany(Member::class, 'member_staff_assignments')
            ->withTimestamps();
    }

    /**
     * Get the attendance records for the staff.
     */
    public function attendanceRecords()
    {
        return $this->hasMany(MemberStaffAttendance::class);
    }

    /**
     * Scope a query to only include society staff.
     *
     * @param  \Illuminate\Database\Eloquent\Builder  $query
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function scopeSociety($query)
    {
        return $query->where('staff_scope', 'society');
    }

    /**
     * Scope a query to only include member staff.
     *
     * @param  \Illuminate\Database\Eloquent\Builder  $query
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function scopeMember($query)
    {
        return $query->where('staff_scope', 'member');
    }

    /**
     * Scope a query to only include verified staff.
     *
     * @param  \Illuminate\Database\Eloquent\Builder  $query
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function scopeVerified($query)
    {
        return $query->where('is_verified', true);
    }

    /**
     * Scope a query to only include unverified staff.
     *
     * @param  \Illuminate\Database\Eloquent\Builder  $query
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function scopeUnverified($query)
    {
        return $query->where('is_verified', false);
    }
}
