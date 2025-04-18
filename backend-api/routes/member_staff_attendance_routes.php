<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\MemberStaffAttendanceController;

Route::middleware('auth:api')->group(function () {
    Route::post('/member-staff/attendance', [MemberStaffAttendanceController::class, 'store']);
});
