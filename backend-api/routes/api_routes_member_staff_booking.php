<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\MemberStaffBookingController;

// Member Staff Booking routes
Route::get('/member-staff/bookings', [MemberStaffBookingController::class, 'index']);
Route::post('/member-staff/booking', [MemberStaffBookingController::class, 'store']);
Route::put('/member-staff/booking/{id}', [MemberStaffBookingController::class, 'update']);
Route::delete('/member-staff/booking/{id}', [MemberStaffBookingController::class, 'destroy']);
