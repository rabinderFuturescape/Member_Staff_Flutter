<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Otp extends Model
{
    use HasFactory;

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'otps';

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'mobile',
        'otp',
        'verified',
        'expires_at',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'verified' => 'boolean',
        'expires_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * Check if the OTP is expired.
     *
     * @return bool
     */
    public function isExpired()
    {
        return now()->isAfter($this->expires_at);
    }

    /**
     * Check if the OTP is valid.
     *
     * @param  string  $otp
     * @return bool
     */
    public function isValid($otp)
    {
        return !$this->isExpired() && !$this->verified && $this->otp === $otp;
    }

    /**
     * Mark the OTP as verified.
     *
     * @return bool
     */
    public function markAsVerified()
    {
        $this->verified = true;
        return $this->save();
    }

    /**
     * Scope a query to only include unverified OTPs.
     *
     * @param  \Illuminate\Database\Eloquent\Builder  $query
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function scopeUnverified($query)
    {
        return $query->where('verified', false);
    }

    /**
     * Scope a query to only include unexpired OTPs.
     *
     * @param  \Illuminate\Database\Eloquent\Builder  $query
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function scopeUnexpired($query)
    {
        return $query->where('expires_at', '>', now());
    }

    /**
     * Scope a query to only include valid OTPs.
     *
     * @param  \Illuminate\Database\Eloquent\Builder  $query
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function scopeValid($query)
    {
        return $query->unverified()->unexpired();
    }
}
