<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class StaffRating extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'member_id',
        'staff_id',
        'staff_type',
        'rating',
        'feedback',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array
     */
    protected $casts = [
        'rating' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * Get the member who submitted the rating.
     */
    public function member()
    {
        return $this->belongsTo(Member::class);
    }

    /**
     * Get the staff being rated.
     * This is a polymorphic relationship based on staff_type.
     */
    public function staff()
    {
        if ($this->staff_type === 'society') {
            return $this->belongsTo(SocietyStaff::class, 'staff_id');
        } else {
            return $this->belongsTo(Staff::class, 'staff_id');
        }
    }

    /**
     * Scope a query to only include ratings for a specific staff.
     *
     * @param  \Illuminate\Database\Eloquent\Builder  $query
     * @param  int  $staffId
     * @param  string  $staffType
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function scopeForStaff($query, $staffId, $staffType)
    {
        return $query->where('staff_id', $staffId)
                     ->where('staff_type', $staffType);
    }

    /**
     * Scope a query to only include ratings by a specific member.
     *
     * @param  \Illuminate\Database\Eloquent\Builder  $query
     * @param  int  $memberId
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function scopeByMember($query, $memberId)
    {
        return $query->where('member_id', $memberId);
    }

    /**
     * Scope a query to only include ratings from the last month.
     *
     * @param  \Illuminate\Database\Eloquent\Builder  $query
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function scopeLastMonth($query)
    {
        return $query->where('created_at', '>=', now()->subMonth());
    }
}
