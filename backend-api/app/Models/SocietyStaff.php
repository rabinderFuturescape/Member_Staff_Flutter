<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SocietyStaff extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'name',
        'category',
        'photo_url',
        'phone',
        'email',
        'address',
        'status',
    ];

    /**
     * Get the ratings for the society staff.
     */
    public function ratings()
    {
        return $this->hasMany(StaffRating::class, 'staff_id')
            ->where('staff_type', 'society');
    }
}
