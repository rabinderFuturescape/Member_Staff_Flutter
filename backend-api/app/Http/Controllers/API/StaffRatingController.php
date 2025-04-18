<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\StaffRating;
use App\Models\Staff;
use App\Models\SocietyStaff;
use App\Models\Member;
use App\Models\MemberStaffAssignment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class StaffRatingController extends Controller
{
    /**
     * Submit a new rating for a staff member.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function submitRating(Request $request)
    {
        // Validate request
        $validator = Validator::make($request->all(), [
            'member_id' => 'required|exists:members,id',
            'staff_id' => 'required|integer',
            'staff_type' => 'required|in:society,member',
            'rating' => 'required|integer|min:1|max:5',
            'feedback' => 'nullable|string|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        // Get member context from the request
        $memberContext = $request->get('member_context', []);
        $memberId = $request->input('member_id');
        
        // Verify that the member_id in the request matches the authenticated member
        if (!empty($memberContext['member_id']) && $memberContext['member_id'] != $memberId) {
            return response()->json(['error' => 'Unauthorized. You can only submit ratings for your own account.'], 403);
        }

        // Verify that the staff exists
        $staffId = $request->input('staff_id');
        $staffType = $request->input('staff_type');
        
        if ($staffType === 'society') {
            $staff = SocietyStaff::find($staffId);
        } else {
            $staff = Staff::find($staffId);
        }

        if (!$staff) {
            return response()->json(['error' => 'Staff not found.'], 404);
        }

        // For member staff, verify that the member is assigned to this staff
        if ($staffType === 'member') {
            $isAssigned = MemberStaffAssignment::where('member_id', $memberId)
                ->where('staff_id', $staffId)
                ->exists();

            if (!$isAssigned) {
                return response()->json(['error' => 'You can only rate staff assigned to your unit.'], 403);
            }
        }

        // Check if the member has already rated this staff in the last month
        $existingRating = StaffRating::byMember($memberId)
            ->forStaff($staffId, $staffType)
            ->lastMonth()
            ->first();

        if ($existingRating) {
            return response()->json([
                'error' => 'You have already rated this staff member in the last month.',
                'existing_rating' => $existingRating
            ], 422);
        }

        // Create the rating
        $rating = StaffRating::create([
            'member_id' => $memberId,
            'staff_id' => $staffId,
            'staff_type' => $staffType,
            'rating' => $request->input('rating'),
            'feedback' => $request->input('feedback'),
        ]);

        return response()->json([
            'message' => 'Rating submitted successfully.',
            'rating' => $rating
        ], 201);
    }

    /**
     * Get ratings summary for a staff member.
     *
     * @param  int  $staffId
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getRatingsSummary($staffId, Request $request)
    {
        // Validate request
        $validator = Validator::make($request->all(), [
            'staff_type' => 'required|in:society,member',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $staffType = $request->input('staff_type');

        // Verify that the staff exists
        if ($staffType === 'society') {
            $staff = SocietyStaff::find($staffId);
        } else {
            $staff = Staff::find($staffId);
        }

        if (!$staff) {
            return response()->json(['error' => 'Staff not found.'], 404);
        }

        // Get ratings summary
        $ratings = StaffRating::forStaff($staffId, $staffType);
        
        $averageRating = $ratings->avg('rating');
        $totalRatings = $ratings->count();
        
        // Get recent reviews with member names
        $recentReviews = StaffRating::forStaff($staffId, $staffType)
            ->with('member:id,name')
            ->orderBy('created_at', 'desc')
            ->take(5)
            ->get()
            ->map(function ($rating) {
                return [
                    'rating' => $rating->rating,
                    'feedback' => $rating->feedback,
                    'member_name' => $rating->member ? $rating->member->name : 'Anonymous',
                    'created_at' => $rating->created_at->format('Y-m-d H:i:s')
                ];
            });

        // Get rating distribution
        $ratingDistribution = [
            1 => StaffRating::forStaff($staffId, $staffType)->where('rating', 1)->count(),
            2 => StaffRating::forStaff($staffId, $staffType)->where('rating', 2)->count(),
            3 => StaffRating::forStaff($staffId, $staffType)->where('rating', 3)->count(),
            4 => StaffRating::forStaff($staffId, $staffType)->where('rating', 4)->count(),
            5 => StaffRating::forStaff($staffId, $staffType)->where('rating', 5)->count(),
        ];

        return response()->json([
            'staff_id' => $staffId,
            'staff_type' => $staffType,
            'average_rating' => round($averageRating, 1),
            'total_ratings' => $totalRatings,
            'rating_distribution' => $ratingDistribution,
            'recent_reviews' => $recentReviews,
        ]);
    }

    /**
     * Get all ratings for admin dashboard.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getAllRatings(Request $request)
    {
        // Validate request
        $validator = Validator::make($request->all(), [
            'staff_type' => 'nullable|in:society,member',
            'min_rating' => 'nullable|integer|min:1|max:5',
            'max_rating' => 'nullable|integer|min:1|max:5',
            'page' => 'nullable|integer|min:1',
            'limit' => 'nullable|integer|min:1|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        // Build query
        $query = StaffRating::with('member:id,name');
        
        // Apply filters
        if ($request->has('staff_type')) {
            $query->where('staff_type', $request->input('staff_type'));
        }
        
        if ($request->has('min_rating')) {
            $query->where('rating', '>=', $request->input('min_rating'));
        }
        
        if ($request->has('max_rating')) {
            $query->where('rating', '<=', $request->input('max_rating'));
        }
        
        // Pagination
        $page = $request->input('page', 1);
        $limit = $request->input('limit', 10);
        $offset = ($page - 1) * $limit;
        
        $total = $query->count();
        $ratings = $query->orderBy('created_at', 'desc')
                        ->offset($offset)
                        ->limit($limit)
                        ->get();

        return response()->json([
            'total' => $total,
            'page' => $page,
            'limit' => $limit,
            'ratings' => $ratings,
        ]);
    }

    /**
     * Export ratings as CSV.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Symfony\Component\HttpFoundation\StreamedResponse
     */
    public function exportRatings(Request $request)
    {
        // Validate request
        $validator = Validator::make($request->all(), [
            'staff_type' => 'nullable|in:society,member',
            'min_rating' => 'nullable|integer|min:1|max:5',
            'max_rating' => 'nullable|integer|min:1|max:5',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        // Build query
        $query = StaffRating::with(['member:id,name']);
        
        // Apply filters
        if ($request->has('staff_type')) {
            $query->where('staff_type', $request->input('staff_type'));
        }
        
        if ($request->has('min_rating')) {
            $query->where('rating', '>=', $request->input('min_rating'));
        }
        
        if ($request->has('max_rating')) {
            $query->where('rating', '<=', $request->input('max_rating'));
        }
        
        $ratings = $query->orderBy('created_at', 'desc')->get();

        $headers = [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => 'attachment; filename="staff_ratings.csv"',
            'Pragma' => 'no-cache',
            'Cache-Control' => 'must-revalidate, post-check=0, pre-check=0',
            'Expires' => '0',
        ];

        $callback = function() use ($ratings) {
            $file = fopen('php://output', 'w');
            
            // Add CSV header
            fputcsv($file, [
                'ID', 'Member ID', 'Member Name', 'Staff ID', 'Staff Type', 
                'Rating', 'Feedback', 'Created At'
            ]);
            
            // Add data rows
            foreach ($ratings as $rating) {
                fputcsv($file, [
                    $rating->id,
                    $rating->member_id,
                    $rating->member ? $rating->member->name : 'Unknown',
                    $rating->staff_id,
                    $rating->staff_type,
                    $rating->rating,
                    $rating->feedback,
                    $rating->created_at->format('Y-m-d H:i:s'),
                ]);
            }
            
            fclose($file);
        };

        return response()->stream($callback, 200, $headers);
    }
}
