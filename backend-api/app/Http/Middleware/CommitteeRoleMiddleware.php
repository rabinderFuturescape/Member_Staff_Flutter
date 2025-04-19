<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CommitteeRoleMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle(Request $request, Closure $next)
    {
        // Get user roles from the token payload
        $userRoles = $request->user_roles ?? [];
        
        // Check if the user has the committee role
        if (!in_array('committee', $userRoles)) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized. Committee access required.',
            ], 403);
        }

        return $next($request);
    }
}
