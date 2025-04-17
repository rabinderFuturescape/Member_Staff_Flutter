<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Tymon\JWTAuth\Facades\JWTAuth;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class AuthController extends Controller
{
    /**
     * Login a user and return a JWT token.
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required|string|min:6',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'code' => 400,
                'message' => 'Validation failed',
                'details' => $validator->errors(),
            ], 400);
        }

        $credentials = $request->only('email', 'password');

        if (!$token = JWTAuth::attempt($credentials)) {
            return response()->json([
                'code' => 401,
                'message' => 'Invalid credentials',
            ], 401);
        }

        return $this->respondWithToken($token);
    }

    /**
     * Generate a test token for development purposes.
     */
    public function generateTestToken(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'member_id' => 'required|string',
            'unit_id' => 'required|string',
            'company_id' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'code' => 400,
                'message' => 'Validation failed',
                'details' => $validator->errors(),
            ], 400);
        }

        // Get member details
        $member = DB::table('members')->where('id', $request->member_id)->first();
        
        if (!$member) {
            return response()->json([
                'code' => 404,
                'message' => 'Member not found',
            ], 404);
        }

        // Create a custom token payload
        $customClaims = [
            'member_id' => $request->member_id,
            'unit_id' => $request->unit_id,
            'company_id' => $request->company_id,
            'member_name' => $member->name,
            'unit_number' => $member->unit_number,
            'email' => $member->email,
            'mobile' => $member->mobile,
        ];

        // Generate token with custom claims
        $token = JWTAuth::customClaims($customClaims)->fromUser(User::first());

        return $this->respondWithToken($token);
    }

    /**
     * Get the token array structure.
     */
    protected function respondWithToken($token)
    {
        return response()->json([
            'access_token' => $token,
            'token_type' => 'bearer',
            'expires_in' => JWTAuth::factory()->getTTL() * 60,
        ]);
    }
}
