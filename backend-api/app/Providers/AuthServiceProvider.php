<?php

namespace App\Providers;

use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;
use Illuminate\Support\Facades\Gate;
use App\Models\MemberStaffBooking;
use App\Policies\MemberStaffBookingPolicy;

class AuthServiceProvider extends ServiceProvider
{
    protected $policies = [
        MemberStaffBooking::class => MemberStaffBookingPolicy::class,
    ];

    public function boot(): void
    {
        $this->registerPolicies();

        Gate::define('view-bookings', [MemberStaffBookingPolicy::class, 'viewBookings']);
        Gate::define('create-booking', [MemberStaffBookingPolicy::class, 'createBooking']);
        Gate::define('reschedule-booking', [MemberStaffBookingPolicy::class, 'rescheduleBooking']);
        Gate::define('cancel-booking', [MemberStaffBookingPolicy::class, 'cancelBooking']);
    }
}
