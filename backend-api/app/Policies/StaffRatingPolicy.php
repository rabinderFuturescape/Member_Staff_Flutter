<?php

namespace App\Policies;

use App\Models\StaffRating;
use App\Models\User;
use Illuminate\Auth\Access\HandlesAuthorization;

class StaffRatingPolicy
{
    use HandlesAuthorization;

    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return true; // All authenticated users can view ratings
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, StaffRating $staffRating): bool
    {
        return true; // All authenticated users can view a rating
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        return $user->role === 'member'; // Only members can create ratings
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, StaffRating $staffRating): bool
    {
        // Only the member who created the rating can update it
        return $user->member_id === $staffRating->member_id;
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, StaffRating $staffRating): bool
    {
        // Only the member who created the rating or an admin can delete it
        return $user->member_id === $staffRating->member_id || $user->role === 'admin';
    }

    /**
     * Determine whether the user can restore the model.
     */
    public function restore(User $user, StaffRating $staffRating): bool
    {
        return $user->role === 'admin'; // Only admins can restore ratings
    }

    /**
     * Determine whether the user can permanently delete the model.
     */
    public function forceDelete(User $user, StaffRating $staffRating): bool
    {
        return $user->role === 'admin'; // Only admins can force delete ratings
    }

    /**
     * Determine whether the user can view admin dashboard.
     */
    public function viewAdminDashboard(User $user): bool
    {
        return $user->role === 'admin'; // Only admins can view admin dashboard
    }
}
