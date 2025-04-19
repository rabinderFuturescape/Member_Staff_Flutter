<?php

namespace App\Policies;

use App\Models\User;
use Illuminate\Auth\Access\HandlesAuthorization;

class CommitteePolicy
{
    use HandlesAuthorization;

    /**
     * Determine whether the user can view committee reports.
     *
     * @param  \App\Models\User  $user
     * @return bool
     */
    public function viewCommitteeReports(User $user)
    {
        return $user->role === 'committee';
    }
}
