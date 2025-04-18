<?php

namespace App\Http\Controllers;

use App\Models\Staff;
use App\Models\Otp;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use Carbon\Carbon;

class StaffController extends Controller
{
    /**
     * Check if a staff exists by mobile number.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function checkMobile(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'mobile' => 'required|string|regex:/^[0-9]{12}$/',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        $mobile = $request->input('mobile');
        $staff = Staff::where('mobile', $mobile)->first();

        if ($staff) {
            return response()->json([
                'success' => true,
                'exists' => true,
                'verified' => (bool) $staff->is_verified,
                'staff_id' => $staff->id,
            ]);
        }

        return response()->json([
            'success' => true,
            'exists' => false,
        ]);
    }

    /**
     * Send OTP to a mobile number.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function sendOtp(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'mobile' => 'required|string|regex:/^[0-9]{12}$/',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        $mobile = $request->input('mobile');

        // Invalidate any existing OTPs for this mobile
        Otp::where('mobile', $mobile)
            ->where('verified', false)
            ->update(['expires_at' => now()]);

        // Generate a new OTP (in a real app, this would be a random 6-digit number)
        // For testing purposes, we'll use a fixed OTP
        $otp = '123456';
        
        // Save the OTP to the database
        Otp::create([
            'mobile' => $mobile,
            'otp' => $otp,
            'verified' => false,
            'expires_at' => now()->addMinutes(10), // OTP expires in 10 minutes
        ]);

        // In a real app, you would send the OTP via SMS
        // For testing, we'll just return success

        return response()->json([
            'success' => true,
            'message' => 'OTP sent successfully',
        ]);
    }

    /**
     * Verify an OTP.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function verifyOtp(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'mobile' => 'required|string|regex:/^[0-9]{12}$/',
            'otp' => 'required|string|size:6',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        $mobile = $request->input('mobile');
        $otpValue = $request->input('otp');

        // Find the latest valid OTP for this mobile
        $otp = Otp::where('mobile', $mobile)
            ->where('otp', $otpValue)
            ->where('verified', false)
            ->where('expires_at', '>', now())
            ->latest()
            ->first();

        if (!$otp) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid or expired OTP',
            ], 400);
        }

        // Mark the OTP as verified
        $otp->markAsVerified();

        return response()->json([
            'success' => true,
            'message' => 'OTP verified successfully',
        ]);
    }

    /**
     * Create a new staff.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'mobile' => 'required|string|regex:/^[0-9]{12}$/|unique:staff,mobile',
            'email' => 'nullable|email|max:255',
            'staff_scope' => 'required|in:society,member',
            'department' => 'nullable|string|max:255',
            'designation' => 'nullable|string|max:255',
            'society_id' => 'nullable|string|required_if:staff_scope,society',
            'unit_id' => 'nullable|string|required_if:staff_scope,member',
            'company_id' => 'required|string',
            'member_id' => 'required|string', // From member context
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        // Create the staff
        $staff = Staff::create([
            'id' => (string) Str::uuid(),
            'name' => $request->input('name'),
            'mobile' => $request->input('mobile'),
            'email' => $request->input('email'),
            'staff_scope' => $request->input('staff_scope'),
            'department' => $request->input('department'),
            'designation' => $request->input('designation'),
            'society_id' => $request->input('society_id'),
            'unit_id' => $request->input('unit_id'),
            'company_id' => $request->input('company_id'),
            'is_verified' => false,
            'created_by' => $request->input('member_id'),
            'updated_by' => $request->input('member_id'),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Staff created successfully',
            'data' => $staff,
        ], 201);
    }

    /**
     * Verify a staff's identity.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  string  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function verify(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'aadhaar_number' => 'required|string|size:12',
            'residential_address' => 'required|string',
            'next_of_kin_name' => 'required|string|max:255',
            'next_of_kin_mobile' => 'required|string|regex:/^[0-9]{12}$/',
            'photo' => 'nullable|image|max:2048', // Max 2MB
            'member_id' => 'required|string', // From member context
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        $staff = Staff::findOrFail($id);

        // Check if staff is already verified
        if ($staff->is_verified) {
            return response()->json([
                'success' => false,
                'message' => 'Staff is already verified',
            ], 400);
        }

        // Handle photo upload
        $photoUrl = null;
        if ($request->hasFile('photo')) {
            $photo = $request->file('photo');
            $photoName = time() . '_' . $photo->getClientOriginalName();
            $photo->storeAs('public/staff_photos', $photoName);
            $photoUrl = 'storage/staff_photos/' . $photoName;
        }

        // Update staff with verification details
        $staff->update([
            'aadhaar_number' => $request->input('aadhaar_number'),
            'residential_address' => $request->input('residential_address'),
            'next_of_kin_name' => $request->input('next_of_kin_name'),
            'next_of_kin_mobile' => $request->input('next_of_kin_mobile'),
            'photo_url' => $photoUrl,
            'is_verified' => true,
            'verified_at' => now(),
            'verified_by_member_id' => $request->input('member_id'),
            'updated_by' => $request->input('member_id'),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Staff verified successfully',
            'data' => $staff,
        ]);
    }

    /**
     * Get a staff's details.
     *
     * @param  string  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function show($id)
    {
        $staff = Staff::findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $staff,
        ]);
    }

    /**
     * Update a staff's details.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  string  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function update(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:255',
            'email' => 'nullable|email|max:255',
            'department' => 'nullable|string|max:255',
            'designation' => 'nullable|string|max:255',
            'member_id' => 'required|string', // From member context
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        $staff = Staff::findOrFail($id);

        // Update staff details
        $staff->update([
            'name' => $request->input('name', $staff->name),
            'email' => $request->input('email', $staff->email),
            'department' => $request->input('department', $staff->department),
            'designation' => $request->input('designation', $staff->designation),
            'updated_by' => $request->input('member_id'),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Staff updated successfully',
            'data' => $staff,
        ]);
    }

    /**
     * Delete a staff.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  string  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy(Request $request, $id)
    {
        $staff = Staff::findOrFail($id);

        // Soft delete the staff
        $staff->delete();

        return response()->json([
            'success' => true,
            'message' => 'Staff deleted successfully',
        ]);
    }
}
