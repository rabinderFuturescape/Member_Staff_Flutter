<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use Tymon\JWTAuth\Facades\JWTAuth;

class VerifyMemberContext
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        // Get the authenticated user
        $user = JWTAuth::parseToken()->authenticate();
        
        // If no user is authenticated, return unauthorized
        if (!$user) {
            return response()->json([
                'code' => 401,
                'message' => 'Unauthorized: Authentication required',
            ], 401);
        }
        
        // Get the member_id from the request
        $requestMemberId = $request->input('member_id');
        
        // If no member_id is provided in the request, continue
        if (!$requestMemberId) {
            return $next($request);
        }
        
        // Get the member_id from the authenticated user
        $userMemberId = $user->member_id;
        
        // If the user doesn't have a member_id, they might be an admin or other role
        if (!$userMemberId) {
            // Check if the user has the admin role
            if ($user->hasRole('admin')) {
                return $next($request);
            }
            
            return response()->json([
                'code' => 403,
                'message' => 'Forbidden: User is not associated with any member',
            ], 403);
        }
        
        // If the member_id in the request doesn't match the user's member_id, return forbidden
        if ($requestMemberId !== $userMemberId) {
            return response()->json([
                'code' => 403,
                'message' => 'Forbidden: Cannot perform actions for other members',
            ], 403);
        }
        
        return $next($request);
    }
}
