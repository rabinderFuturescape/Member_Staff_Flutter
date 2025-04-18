<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\MemberStaffAttendanceController;

// Member Staff Attendance routes
Route::get('/member-staff/attendance', [MemberStaffAttendanceController::class, 'index']);
Route::post('/member-staff/attendance', [MemberStaffAttendanceController::class, 'store']);
