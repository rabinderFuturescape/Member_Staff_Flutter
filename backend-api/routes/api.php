<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\StaffController;
use App\Http\Controllers\TimeSlotController;
use App\Http\Controllers\MemberStaffController;
use App\Http\Controllers\API\MemberStaffBookingController;
use App\Http\Controllers\API\MemberStaffAttendanceController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Public routes
Route::post('/auth/generate-test-token', [AuthController::class, 'generateTestToken']);
Route::post('/auth/verify-token', [AuthController::class, 'verifyToken']);

// Protected routes
Route::middleware(['verify.jwt', 'verify.member.context'])->group(function () {
    // Staff routes
    Route::get('/staff/check', [StaffController::class, 'checkMobile']);
    Route::post('/staff/send-otp', [StaffController::class, 'sendOtp']);
    Route::post('/staff/verify-otp', [StaffController::class, 'verifyOtp']);
    Route::post('/staff', [StaffController::class, 'store']);
    Route::get('/staff/{id}', [StaffController::class, 'show']);
    Route::put('/staff/{id}', [StaffController::class, 'update']);
    Route::put('/staff/{id}/verify', [StaffController::class, 'verify']);
    Route::delete('/staff/{id}', [StaffController::class, 'destroy']);

    // Time slot routes
    Route::get('/staff/{staffId}/schedule', [TimeSlotController::class, 'getSchedule']);
    Route::post('/staff/{staffId}/schedule/slots', [TimeSlotController::class, 'addTimeSlot']);
    Route::put('/staff/{staffId}/schedule/slots/{timeSlotId}', [TimeSlotController::class, 'updateTimeSlot']);
    Route::delete('/staff/{staffId}/schedule/slots/{timeSlotId}', [TimeSlotController::class, 'removeTimeSlot']);
    Route::get('/staff/{staffId}/schedule/date/{date}', [TimeSlotController::class, 'getTimeSlotsForDate']);
    Route::post('/staff/{staffId}/schedule/slots/bulk', [TimeSlotController::class, 'bulkAddTimeSlots']);

    // Member staff routes
    Route::get('/members/{memberId}/staff', [MemberStaffController::class, 'getMemberStaff']);
    Route::post('/member-staff/assign', [MemberStaffController::class, 'assignStaff']);
    Route::post('/member-staff/unassign', [MemberStaffController::class, 'unassignStaff']);
    Route::get('/company/{companyId}/staff', [MemberStaffController::class, 'getCompanyStaff']);
    Route::get('/staff/search', [MemberStaffController::class, 'searchStaff']);

    // Include Member Staff Booking routes
    require __DIR__.'/api_routes_member_staff_booking.php';

    // Include Member Staff Attendance routes
    require __DIR__.'/api_routes_member_staff_attendance.php';
});
