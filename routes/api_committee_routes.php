<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\CommitteeDuesReportController;

// Committee Routes
Route::middleware(['auth:sanctum', 'committee'])->group(function () {
    // Dues Report Routes
    Route::get('/committee/dues-report', [CommitteeDuesReportController::class, 'index']);
    Route::get('/committee/dues-report/export', [CommitteeDuesReportController::class, 'exportCsv']);
    Route::get('/committee/dues-report/chart-summary', [CommitteeDuesReportController::class, 'chartSummary']);
});
