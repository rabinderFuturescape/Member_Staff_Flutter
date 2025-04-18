<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class VerifyMemberContext
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
        $memberId = $request->input('member_id');
        $unitId = $request->input('unit_id');
        $companyId = $request->input('company_id');

        if (!$memberId || !$unitId || !$companyId) {
            return response()->json([
                'success' => false,
                'message' => 'Member context is missing',
                'required_fields' => [
                    'member_id' => $memberId ? 'present' : 'missing',
                    'unit_id' => $unitId ? 'present' : 'missing',
                    'company_id' => $companyId ? 'present' : 'missing',
                ],
            ], 400);
        }

        return $next($request);
    }
}
