<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\StaffRating;
use App\Models\Staff;
use App\Models\SocietyStaff;
use App\Http\Requests\StaffRatingRequest;
use App\Http\Resources\StaffRatingResource;
use Illuminate\Support\Facades\Gate;

class StaffRatingController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        // Get the authenticated user's member ID
        $memberId = auth()->user()->member_id;
        
        // Get query parameters for filtering
        $staffType = $request->input('staff_type');
        $rating = $request->input('rating');
        
        // Start building the query
        $query = StaffRating::where('member_id', $memberId);
        
        // Apply filters if provided
        if ($staffType) {
            $query->where('staff_type', $staffType);
        }
        
        if ($rating) {
            $query->where('rating', $rating);
        }
        
        // Order by created_at (descending)
        $query->orderBy('created_at', 'desc');
        
        // Paginate the results
        $ratings = $query->paginate(10);
        
        return StaffRatingResource::collection($ratings);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(StaffRatingRequest $request)
    {
        // Check if the user is authorized to create a rating
        if (Gate::denies('create', StaffRating::class)) {
            return response()->json(['error' => 'Unauthorized. You do not have permission to create a rating.'], 403);
        }
        
        // Get the authenticated user's member ID
        $memberId = auth()->user()->member_id;
        
        // Validate that the staff exists
        if ($request->staff_type === 'society') {
            $staff = SocietyStaff::find($request->staff_id);
        } else {
            $staff = Staff::find($request->staff_id);
        }
        
        if (!$staff) {
            return response()->json(['error' => 'Staff not found.'], 404);
        }
        
        // Create the rating
        $rating = StaffRating::create([
            'member_id' => $memberId,
            'staff_id' => $request->staff_id,
            'staff_type' => $request->staff_type,
            'rating' => $request->rating,
            'feedback' => $request->feedback,
        ]);
        
        return new StaffRatingResource($rating);
    }

    /**
     * Display the specified resource.
     */
    public function show(StaffRating $rating)
    {
        // Check if the user is authorized to view the rating
        if (Gate::denies('view', $rating)) {
            return response()->json(['error' => 'Unauthorized. You do not have permission to view this rating.'], 403);
        }
        
        return new StaffRatingResource($rating);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(StaffRatingRequest $request, StaffRating $rating)
    {
        // Check if the user is authorized to update the rating
        if (Gate::denies('update', $rating)) {
            return response()->json(['error' => 'Unauthorized. You do not have permission to update this rating.'], 403);
        }
        
        // Update the rating
        $rating->update([
            'rating' => $request->rating,
            'feedback' => $request->feedback,
        ]);
        
        return new StaffRatingResource($rating);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(StaffRating $rating)
    {
        // Check if the user is authorized to delete the rating
        if (Gate::denies('delete', $rating)) {
            return response()->json(['error' => 'Unauthorized. You do not have permission to delete this rating.'], 403);
        }
        
        // Delete the rating
        $rating->delete();
        
        return response()->json(['message' => 'Rating deleted successfully.']);
    }
}
