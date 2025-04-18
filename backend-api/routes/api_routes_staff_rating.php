<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\StaffRatingController;

// Staff Rating Routes
Route::middleware(['auth:api'])->group(function () {
    // Submit a rating
    Route::post('/staff/rating', [StaffRatingController::class, 'submitRating']);
    
    // Get ratings summary for a staff
    Route::get('/staff/{staffId}/ratings', [StaffRatingController::class, 'getRatingsSummary']);
});

// Admin Routes
Route::middleware(['auth:api', 'can:view-admin-dashboard'])->group(function () {
    // Get all ratings for admin dashboard
    Route::get('/admin/staff/ratings', [StaffRatingController::class, 'getAllRatings']);
    
    // Export ratings as CSV
    Route::get('/admin/staff/ratings/export', [StaffRatingController::class, 'exportRatings']);
});
