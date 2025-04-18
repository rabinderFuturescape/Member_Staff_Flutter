<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AdminAttendanceController;

// Admin routes - protected by admin middleware and gate
Route::middleware(['auth:api', 'can:view-admin-dashboard'])->group(function () {
    // Attendance routes
    Route::get('/admin/attendance', [AdminAttendanceController::class, 'index']);
    Route::get('/admin/attendance/summary', [AdminAttendanceController::class, 'summary']);
    Route::post('/admin/attendance/update', [AdminAttendanceController::class, 'update']);
});
