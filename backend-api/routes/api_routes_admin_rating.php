<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AdminStaffRatingController;

// Admin Staff Rating Routes
Route::middleware(['auth:api', 'can:view-admin-dashboard'])->group(function () {
    // Get all staff ratings with aggregated data
    Route::get('/admin/staff/ratings', [AdminStaffRatingController::class, 'index']);
    
    // Get detailed information about a specific staff's ratings
    Route::get('/admin/staff/{staffId}/ratings', [AdminStaffRatingController::class, 'show']);
    
    // Export ratings data as CSV
    Route::get('/admin/staff/ratings/export', [AdminStaffRatingController::class, 'export']);
});
