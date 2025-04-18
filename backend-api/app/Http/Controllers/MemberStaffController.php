<?php

namespace App\Http\Controllers;

use App\Models\Member;
use App\Models\Staff;
use App\Models\MemberStaffAssignment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class MemberStaffController extends Controller
{
    /**
     * Get staff assigned to a member.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  string  $memberId
     * @return \Illuminate\Http\JsonResponse
     */
    public function getMemberStaff(Request $request, $memberId)
    {
        $member = Member::findOrFail($memberId);

        // Check if the authenticated member has access to this member's staff
        if ($request->input('member_id') !== $memberId) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access',
            ], 403);
        }

        $staff = $member->staff()->with('timeSlots')->get();

        return response()->json([
            'success' => true,
            'data' => $staff,
        ]);
    }

    /**
     * Assign a staff to a member.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function assignStaff(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'member_id' => 'required|string|exists:members,id',
            'staff_id' => 'required|string|exists:staff,id',
            'assigned_by' => 'required|string|exists:members,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        $memberId = $request->input('member_id');
        $staffId = $request->input('staff_id');
        $assignedBy = $request->input('assigned_by');

        // Check if the authenticated member has permission to assign staff
        if ($request->input('member_id') !== $memberId && $request->input('member_id') !== $assignedBy) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access',
            ], 403);
        }

        // Check if the staff is verified
        $staff = Staff::findOrFail($staffId);
        if (!$staff->is_verified) {
            return response()->json([
                'success' => false,
                'message' => 'Staff must be verified before assignment',
            ], 400);
        }

        // Check if the staff is already assigned to the member
        $existingAssignment = MemberStaffAssignment::where('member_id', $memberId)
            ->where('staff_id', $staffId)
            ->where('is_active', true)
            ->first();

        if ($existingAssignment) {
            return response()->json([
                'success' => false,
                'message' => 'Staff is already assigned to this member',
                'data' => $existingAssignment,
            ], 400);
        }

        // Create the assignment
        $assignment = MemberStaffAssignment::create([
            'id' => (string) Str::uuid(),
            'member_id' => $memberId,
            'staff_id' => $staffId,
            'assigned_by' => $assignedBy,
            'is_active' => true,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Staff assigned successfully',
            'data' => $assignment,
        ], 201);
    }

    /**
     * Unassign a staff from a member.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function unassignStaff(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'member_id' => 'required|string|exists:members,id',
            'staff_id' => 'required|string|exists:staff,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        $memberId = $request->input('member_id');
        $staffId = $request->input('staff_id');

        // Check if the authenticated member has permission to unassign staff
        if ($request->input('member_id') !== $memberId) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access',
            ], 403);
        }

        // Find the assignment
        $assignment = MemberStaffAssignment::where('member_id', $memberId)
            ->where('staff_id', $staffId)
            ->where('is_active', true)
            ->first();

        if (!$assignment) {
            return response()->json([
                'success' => false,
                'message' => 'Staff is not assigned to this member',
            ], 404);
        }

        // Deactivate the assignment
        $assignment->update(['is_active' => false]);

        return response()->json([
            'success' => true,
            'message' => 'Staff unassigned successfully',
        ]);
    }

    /**
     * Get all staff for a company.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getCompanyStaff(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'company_id' => 'required|string',
            'staff_scope' => 'nullable|in:society,member',
            'is_verified' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        $companyId = $request->input('company_id');
        $staffScope = $request->input('staff_scope');
        $isVerified = $request->input('is_verified');

        // Build the query
        $query = Staff::where('company_id', $companyId);

        if ($staffScope) {
            $query->where('staff_scope', $staffScope);
        }

        if ($isVerified !== null) {
            $query->where('is_verified', $isVerified);
        }

        $staff = $query->get();

        return response()->json([
            'success' => true,
            'data' => $staff,
        ]);
    }

    /**
     * Search for staff.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function searchStaff(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'company_id' => 'required|string',
            'query' => 'required|string|min:3',
            'staff_scope' => 'nullable|in:society,member',
            'is_verified' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        $companyId = $request->input('company_id');
        $query = $request->input('query');
        $staffScope = $request->input('staff_scope');
        $isVerified = $request->input('is_verified');

        // Build the query
        $staffQuery = Staff::where('company_id', $companyId)
            ->where(function ($q) use ($query) {
                $q->where('name', 'like', "%{$query}%")
                    ->orWhere('mobile', 'like', "%{$query}%")
                    ->orWhere('email', 'like', "%{$query}%");
            });

        if ($staffScope) {
            $staffQuery->where('staff_scope', $staffScope);
        }

        if ($isVerified !== null) {
            $staffQuery->where('is_verified', $isVerified);
        }

        $staff = $staffQuery->get();

        return response()->json([
            'success' => true,
            'data' => $staff,
        ]);
    }
}
