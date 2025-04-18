<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class TimeSlot extends Model
{
    use HasFactory, SoftDeletes;

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'time_slots';

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
        'staff_id',
        'date',
        'start_time',
        'end_time',
        'is_booked',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'date' => 'date',
        'is_booked' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * Get the staff that owns the time slot.
     */
    public function staff()
    {
        return $this->belongsTo(Staff::class);
    }

    /**
     * Check if this time slot overlaps with another time slot.
     *
     * @param  \App\Models\TimeSlot  $timeSlot
     * @return bool
     */
    public function overlaps(TimeSlot $timeSlot)
    {
        // Different dates don't overlap
        if (!$this->date->isSameDay($timeSlot->date)) {
            return false;
        }

        // Convert times to minutes for easier comparison
        $thisStart = $this->timeToMinutes($this->start_time);
        $thisEnd = $this->timeToMinutes($this->end_time);
        $otherStart = $this->timeToMinutes($timeSlot->start_time);
        $otherEnd = $this->timeToMinutes($timeSlot->end_time);

        // Check for overlap
        return $thisStart < $otherEnd && $thisEnd > $otherStart;
    }

    /**
     * Convert a time string (HH:MM) to minutes.
     *
     * @param  string  $time
     * @return int
     */
    private function timeToMinutes($time)
    {
        $parts = explode(':', $time);
        return (int) $parts[0] * 60 + (int) $parts[1];
    }

    /**
     * Scope a query to only include time slots for a specific date.
     *
     * @param  \Illuminate\Database\Eloquent\Builder  $query
     * @param  \Carbon\Carbon|string  $date
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function scopeForDate($query, $date)
    {
        return $query->whereDate('date', $date);
    }

    /**
     * Scope a query to only include booked time slots.
     *
     * @param  \Illuminate\Database\Eloquent\Builder  $query
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function scopeBooked($query)
    {
        return $query->where('is_booked', true);
    }

    /**
     * Scope a query to only include available time slots.
     *
     * @param  \Illuminate\Database\Eloquent\Builder  $query
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function scopeAvailable($query)
    {
        return $query->where('is_booked', false);
    }
}
