<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\StaffRating;
use App\Models\Staff;
use App\Models\SocietyStaff;
use App\Models\Member;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;

class AdminStaffRatingController extends Controller
{
    /**
     * Display a listing of staff ratings with aggregated data.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(Request $request)
    {
        // Check if user has admin permissions
        if (Gate::denies('view-admin-dashboard')) {
            return response()->json(['error' => 'Unauthorized. You do not have permission to access this resource.'], 403);
        }

        // Get query parameters for filtering
        $staffType = $request->input('staff_type');
        $minRating = $request->input('min_rating');
        $maxRating = $request->input('max_rating');
        $search = $request->input('search');
        
        // Start building the query
        $query = StaffRating::select(
            'staff_id',
            'staff_type',
            DB::raw('AVG(rating) as average_rating'),
            DB::raw('COUNT(*) as total_ratings')
        );
        
        // Apply filters if provided
        if ($staffType) {
            $query->where('staff_type', $staffType);
        }
        
        // Group by staff_id and staff_type
        $query->groupBy('staff_id', 'staff_type');
        
        // Order by average rating (descending)
        $query->orderByDesc('average_rating');
        
        // Get the results
        $ratings = $query->get();
        
        // Apply additional filters that need to be done after aggregation
        if ($minRating) {
            $ratings = $ratings->filter(function ($item) use ($minRating) {
                return $item->average_rating >= $minRating;
            });
        }
        
        if ($maxRating) {
            $ratings = $ratings->filter(function ($item) use ($maxRating) {
                return $item->average_rating <= $maxRating;
            });
        }
        
        // Add staff details to the response
        $ratingsWithDetails = $ratings->map(function ($rating) use ($search) {
            // Get staff details based on staff_type
            if ($rating->staff_type === 'society') {
                $staff = SocietyStaff::find($rating->staff_id);
            } else {
                $staff = Staff::find($rating->staff_id);
            }
            
            // Skip if staff not found or doesn't match search term
            if (!$staff || ($search && !str_contains(strtolower($staff->name), strtolower($search)))) {
                return null;
            }
            
            // Format the average rating to 1 decimal place
            $rating->average_rating = round($rating->average_rating, 1);
            
            // Add staff details
            $rating->staff_name = $staff->name;
            $rating->staff_category = $staff->category ?? null;
            $rating->staff_photo_url = $staff->photo_url ?? null;
            
            return $rating;
        })->filter(); // Remove null values (filtered out by search)
        
        return response()->json([
            'total' => $ratingsWithDetails->count(),
            'ratings' => $ratingsWithDetails->values() // Reset array keys
        ]);
    }

    /**
     * Display detailed information about a specific staff's ratings.
     *
     * @param  int  $staffId
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function show($staffId, Request $request)
    {
        // Check if user has admin permissions
        if (Gate::denies('view-admin-dashboard')) {
            return response()->json(['error' => 'Unauthorized. You do not have permission to access this resource.'], 403);
        }

        // Validate request
        $request->validate([
            'staff_type' => 'required|in:society,member',
        ]);

        $staffType = $request->input('staff_type');

        // Check if staff exists
        if ($staffType === 'society') {
            $staff = SocietyStaff::find($staffId);
        } else {
            $staff = Staff::find($staffId);
        }

        if (!$staff) {
            return response()->json(['error' => 'Staff not found.'], 404);
        }

        // Get aggregated rating data
        $ratingData = StaffRating::where('staff_id', $staffId)
            ->where('staff_type', $staffType)
            ->select(
                DB::raw('AVG(rating) as average_rating'),
                DB::raw('COUNT(*) as total_ratings')
            )
            ->first();

        // Get rating distribution
        $distribution = [];
        for ($i = 1; $i <= 5; $i++) {
            $distribution[$i] = StaffRating::where('staff_id', $staffId)
                ->where('staff_type', $staffType)
                ->where('rating', $i)
                ->count();
        }

        // Get recent reviews with member details
        $recentReviews = StaffRating::where('staff_id', $staffId)
            ->where('staff_type', $staffType)
            ->with('member:id,name')
            ->orderBy('created_at', 'desc')
            ->take(10)
            ->get()
            ->map(function ($rating) {
                return [
                    'id' => $rating->id,
                    'rating' => $rating->rating,
                    'feedback' => $rating->feedback,
                    'member_name' => $rating->member ? $rating->member->name : 'Anonymous',
                    'created_at' => $rating->created_at->format('Y-m-d H:i:s')
                ];
            });

        return response()->json([
            'staff_id' => $staffId,
            'staff_type' => $staffType,
            'staff_name' => $staff->name,
            'staff_category' => $staff->category ?? null,
            'staff_photo_url' => $staff->photo_url ?? null,
            'average_rating' => round($ratingData->average_rating, 1),
            'total_ratings' => $ratingData->total_ratings,
            'rating_distribution' => $distribution,
            'recent_reviews' => $recentReviews,
        ]);
    }

    /**
     * Export ratings data as CSV.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Symfony\Component\HttpFoundation\StreamedResponse
     */
    public function export(Request $request)
    {
        // Check if user has admin permissions
        if (Gate::denies('view-admin-dashboard')) {
            return response()->json(['error' => 'Unauthorized. You do not have permission to access this resource.'], 403);
        }

        // Get query parameters for filtering
        $staffType = $request->input('staff_type');
        $minRating = $request->input('min_rating');
        $maxRating = $request->input('max_rating');
        $search = $request->input('search');
        
        // Start building the query
        $query = StaffRating::with(['member:id,name']);
        
        // Apply filters if provided
        if ($staffType) {
            $query->where('staff_type', $staffType);
        }
        
        if ($minRating) {
            $query->where('rating', '>=', $minRating);
        }
        
        if ($maxRating) {
            $query->where('rating', '<=', $maxRating);
        }
        
        // Order by created_at (descending)
        $query->orderBy('created_at', 'desc');
        
        // Get all ratings
        $ratings = $query->get();
        
        // Apply search filter if provided
        if ($search) {
            $ratings = $ratings->filter(function ($rating) use ($search) {
                // Get staff details based on staff_type
                if ($rating->staff_type === 'society') {
                    $staff = SocietyStaff::find($rating->staff_id);
                } else {
                    $staff = Staff::find($rating->staff_id);
                }
                
                // Check if staff name contains search term
                return $staff && str_contains(strtolower($staff->name), strtolower($search));
            });
        }
        
        // Create CSV response
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
                'Staff Name', 'Rating', 'Feedback', 'Created At'
            ]);
            
            // Add data rows
            foreach ($ratings as $rating) {
                // Get staff details based on staff_type
                if ($rating->staff_type === 'society') {
                    $staff = SocietyStaff::find($rating->staff_id);
                } else {
                    $staff = Staff::find($rating->staff_id);
                }
                
                $staffName = $staff ? $staff->name : 'Unknown';
                
                fputcsv($file, [
                    $rating->id,
                    $rating->member_id,
                    $rating->member ? $rating->member->name : 'Unknown',
                    $rating->staff_id,
                    $rating->staff_type,
                    $staffName,
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
