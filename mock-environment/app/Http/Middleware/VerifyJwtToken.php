<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use Tymon\JWTAuth\Facades\JWTAuth;
use Tymon\JWTAuth\Exceptions\TokenExpiredException;
use Tymon\JWTAuth\Exceptions\TokenInvalidException;
use Tymon\JWTAuth\Exceptions\JWTException;

class VerifyJwtToken
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        try {
            $user = JWTAuth::parseToken()->authenticate();
            
            if (!$user) {
                return response()->json([
                    'code' => 401,
                    'message' => 'User not found',
                ], 401);
            }
        } catch (TokenExpiredException $e) {
            return response()->json([
                'code' => 401,
                'message' => 'Token expired',
            ], 401);
        } catch (TokenInvalidException $e) {
            return response()->json([
                'code' => 401,
                'message' => 'Invalid token',
            ], 401);
        } catch (JWTException $e) {
            return response()->json([
                'code' => 401,
                'message' => 'Token not provided',
            ], 401);
        }

        return $next($request);
    }
}
