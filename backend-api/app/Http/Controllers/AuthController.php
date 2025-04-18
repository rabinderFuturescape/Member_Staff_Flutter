<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Carbon\Carbon;

class AuthController extends Controller
{
    /**
     * Generate a test JWT token for development purposes.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function generateTestToken(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'member_id' => 'required|string',
            'unit_id' => 'required|string',
            'company_id' => 'required|string',
            'name' => 'required|string',
            'email' => 'required|email',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        $payload = [
            'iss' => 'oneapp',
            'aud' => 'member-staff-api',
            'iat' => Carbon::now()->timestamp,
            'exp' => Carbon::now()->addDays(7)->timestamp,
            'member_id' => $request->input('member_id'),
            'unit_id' => $request->input('unit_id'),
            'company_id' => $request->input('company_id'),
            'name' => $request->input('name'),
            'email' => $request->input('email'),
        ];

        $token = JWT::encode($payload, config('app.jwt_secret'), 'HS256');

        return response()->json([
            'success' => true,
            'token' => $token,
            'expires_at' => Carbon::now()->addDays(7)->toDateTimeString(),
        ]);
    }

    /**
     * Verify a JWT token.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function verifyToken(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'token' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $decoded = JWT::decode($request->input('token'), new Key(config('app.jwt_secret'), 'HS256'));

            return response()->json([
                'success' => true,
                'data' => (array) $decoded,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid token',
                'error' => $e->getMessage(),
            ], 401);
        }
    }
}
