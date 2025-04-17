<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\StaffController;
use App\Http\Controllers\ScheduleController;
use App\Http\Controllers\MemberStaffController;
use App\Http\Controllers\AuthController;

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
Route::post('/auth/login', [AuthController::class, 'login']);
Route::post('/auth/generate-test-token', [AuthController::class, 'generateTestToken']);

// Protected routes
Route::middleware(['jwt.verify'])->group(function () {
    // Staff routes
    Route::get('/staff', [StaffController::class, 'index']);
    Route::post('/staff', [StaffController::class, 'store']);
    Route::get('/staff/{id}', [StaffController::class, 'show']);
    Route::put('/staff/{id}', [StaffController::class, 'update']);
    Route::delete('/staff/{id}', [StaffController::class, 'destroy']);
    
    // Staff verification routes
    Route::get('/staff/check', [StaffController::class, 'checkMobile']);
    Route::post('/staff/send-otp', [StaffController::class, 'sendOtp']);
    Route::post('/staff/verify-otp', [StaffController::class, 'verifyOtp']);
    Route::put('/staff/{id}/verify', [StaffController::class, 'verifyIdentity'])->middleware('verify.member');
    
    // Schedule routes
    Route::get('/staff/{staffId}/schedule', [ScheduleController::class, 'getSchedule']);
    Route::put('/staff/{staffId}/schedule', [ScheduleController::class, 'updateSchedule'])->middleware('verify.member');
    Route::post('/staff/{staffId}/schedule/slots', [ScheduleController::class, 'addTimeSlot'])->middleware('verify.member');
    Route::put('/staff/{staffId}/schedule/slots', [ScheduleController::class, 'updateTimeSlot'])->middleware('verify.member');
    Route::delete('/staff/{staffId}/schedule/slots', [ScheduleController::class, 'removeTimeSlot'])->middleware('verify.member');
    
    // Member staff routes
    Route::get('/members/{memberId}/staff', [MemberStaffController::class, 'getMemberStaff'])->middleware('verify.member');
    Route::post('/member-staff/assign', [MemberStaffController::class, 'assignMemberStaff'])->middleware('verify.member');
    Route::post('/member-staff/unassign', [MemberStaffController::class, 'unassignMemberStaff'])->middleware('verify.member');
});
