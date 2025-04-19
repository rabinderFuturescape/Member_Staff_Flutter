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
     * @var array<int, string>
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
     * @var array<string, string>
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
     * Get the staff being rated (polymorphic relationship).
     */
    public function staff()
    {
        if ($this->staff_type === 'society') {
            return $this->belongsTo(SocietyStaff::class, 'staff_id');
        } else {
            return $this->belongsTo(Staff::class, 'staff_id');
        }
    }
}
