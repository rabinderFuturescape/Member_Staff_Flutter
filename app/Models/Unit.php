<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Unit extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'unit_number',
        'building_id',
        'floor',
        'area_sqft',
        'type',
        'is_occupied',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'is_occupied' => 'boolean',
    ];

    /**
     * Get the building that owns the unit.
     */
    public function building()
    {
        return $this->belongsTo(Building::class);
    }

    /**
     * Get the members for the unit.
     */
    public function members()
    {
        return $this->hasMany(Member::class);
    }
}
