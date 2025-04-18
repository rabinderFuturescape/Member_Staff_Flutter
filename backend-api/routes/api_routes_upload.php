<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\UploadController;

// Upload routes
Route::post('/upload-photo', [UploadController::class, 'uploadPhoto']);
