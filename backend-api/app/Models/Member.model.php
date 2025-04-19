<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Member extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'email',
        'mobile',
        'photo_url',
        'unit_id',
        'company_id',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * Get the unit associated with the member.
     */
    public function unit()
    {
        return $this->belongsTo(Unit::class);
    }

    /**
     * Get the company associated with the member.
     */
    public function company()
    {
        return $this->belongsTo(Company::class);
    }

    /**
     * Get the staff associated with the member.
     */
    public function staff()
    {
        return $this->hasMany(Staff::class);
    }

    /**
     * Get the ratings submitted by the member.
     */
    public function ratings()
    {
        return $this->hasMany(StaffRating::class);
    }

    /**
     * Get the bookings made by the member.
     */
    public function bookings()
    {
        return $this->hasMany(StaffBooking::class);
    }
}
