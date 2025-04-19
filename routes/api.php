<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AdminStaffRatingController;
use App\Http\Controllers\API\CommitteeDuesReportController;
use App\Http\Controllers\API\FeatureRequestController;

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

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

// Admin Staff Rating Routes
Route::middleware(['auth:sanctum', 'admin'])->group(function () {
    Route::get('/admin/staff/ratings', [AdminStaffRatingController::class, 'index']);
    Route::get('/admin/staff/ratings/export', [AdminStaffRatingController::class, 'exportCsv']);
});

// Committee Dues Report Routes
Route::middleware(['auth:sanctum', 'committee'])->group(function () {
    Route::get('/committee/dues-report', [CommitteeDuesReportController::class, 'index']);
    Route::get('/committee/dues-report/export', [CommitteeDuesReportController::class, 'exportCsv']);
});

// Feature Request Routes
Route::prefix('feature-requests')->middleware(['auth:sanctum'])->group(function () {
    Route::get('/', [FeatureRequestController::class, 'index']);
    Route::get('/suggest', [FeatureRequestController::class, 'suggest']);
    Route::post('/', [FeatureRequestController::class, 'store']);
    Route::post('/{id}/vote', [FeatureRequestController::class, 'vote']);
});

// Include other route files
require __DIR__ . '/api_committee_routes.php';
