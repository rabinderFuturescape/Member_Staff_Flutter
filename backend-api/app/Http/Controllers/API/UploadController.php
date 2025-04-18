<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class UploadController extends Controller
{
    /**
     * Handle photo upload for member staff attendance
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function uploadPhoto(Request $request)
    {
        // Validate the request
        $validator = Validator::make($request->all(), [
            'photo' => 'required|image|mimes:jpeg,png,jpg|max:5120', // 5MB max
            'member_id' => 'required|exists:members,id',
            'unit_id' => 'required|numeric',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            // Get the uploaded file
            $photo = $request->file('photo');
            
            // Generate a unique filename
            $filename = 'attendance_' . $request->member_id . '_' . time() . '_' . Str::random(10) . '.' . $photo->getClientOriginalExtension();
            
            // Create directory if it doesn't exist
            $directory = 'member_staff_attendance/' . date('Y/m');
            if (!Storage::disk('public')->exists($directory)) {
                Storage::disk('public')->makeDirectory($directory);
            }
            
            // Store the file
            $path = $photo->storeAs($directory, $filename, 'public');
            
            // Generate the URL
            $url = asset('storage/' . $path);
            
            // Log the upload
            \Log::info('Photo uploaded', [
                'member_id' => $request->member_id,
                'unit_id' => $request->unit_id,
                'path' => $path,
                'url' => $url
            ]);
            
            return response()->json([
                'status' => 'success',
                'message' => 'Photo uploaded successfully',
                'url' => $url,
                'path' => $path
            ]);
        } catch (\Exception $e) {
            \Log::error('Photo upload failed', [
                'error' => $e->getMessage(),
                'member_id' => $request->member_id
            ]);
            
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to upload photo',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
