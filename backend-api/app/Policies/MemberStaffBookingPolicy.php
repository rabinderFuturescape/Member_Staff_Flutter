<?php

namespace App\Policies;

use App\Models\User;
use Illuminate\Auth\Access\HandlesAuthorization;

class MemberStaffBookingPolicy
{
    use HandlesAuthorization;

    public function viewBookings(User $user)
    {
        return $user->role === 'member' || $user->role === 'admin';
    }

    public function createBooking(User $user)
    {
        return $user->role === 'member';
    }

    public function rescheduleBooking(User $user)
    {
        return $user->role === 'member';
    }

    public function cancelBooking(User $user)
    {
        return $user->role === 'member';
    }
}
