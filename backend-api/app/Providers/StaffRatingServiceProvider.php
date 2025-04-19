<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Gate;
use App\Models\StaffRating;
use App\Policies\StaffRatingPolicy;

class StaffRatingServiceProvider extends ServiceProvider
{
    /**
     * Register services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap services.
     */
    public function boot(): void
    {
        // Register the policy
        Gate::policy(StaffRating::class, StaffRatingPolicy::class);
        
        // Define a gate for viewing the admin dashboard
        Gate::define('view-admin-dashboard', function ($user) {
            return $user->role === 'admin';
        });
    }
}
