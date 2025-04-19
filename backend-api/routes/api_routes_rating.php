<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\StaffRatingController;

// Staff Rating Routes
Route::middleware(['auth:api'])->group(function () {
    // Get all ratings for the authenticated user
    Route::get('/staff/ratings', [StaffRatingController::class, 'index']);
    
    // Create a new rating
    Route::post('/staff/ratings', [StaffRatingController::class, 'store']);
    
    // Get a specific rating
    Route::get('/staff/ratings/{rating}', [StaffRatingController::class, 'show']);
    
    // Update a rating
    Route::put('/staff/ratings/{rating}', [StaffRatingController::class, 'update']);
    
    // Delete a rating
    Route::delete('/staff/ratings/{rating}', [StaffRatingController::class, 'destroy']);
});
