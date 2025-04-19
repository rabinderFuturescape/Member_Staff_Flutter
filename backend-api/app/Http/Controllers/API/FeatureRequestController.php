<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\FeatureRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class FeatureRequestController extends Controller
{
    /**
     * Display a listing of feature requests.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function index(Request $request)
    {
        // Get query parameters for sorting and pagination
        $sortBy = $request->input('sort_by', 'votes');
        $sortOrder = $request->input('sort_order', 'desc');
        $perPage = $request->input('per_page', 10);
        
        // Get feature requests with pagination
        $featureRequests = FeatureRequest::orderBy($sortBy, $sortOrder)
            ->paginate($perPage);
        
        return response()->json([
            'data' => $featureRequests->items(),
            'meta' => [
                'current_page' => $featureRequests->currentPage(),
                'last_page' => $featureRequests->lastPage(),
                'per_page' => $featureRequests->perPage(),
                'total' => $featureRequests->total(),
            ],
        ]);
    }

    /**
     * Store a newly created feature request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        // Validate request data
        $validator = Validator::make($request->all(), [
            'feature_title' => 'required|string|max:255',
            'description' => 'nullable|string',
        ]);
        
        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }
        
        // Check if a similar feature request already exists
        $existingRequest = FeatureRequest::where('feature_title', $request->feature_title)->first();
        
        if ($existingRequest) {
            // Increment vote count for existing request
            $existingRequest->incrementVote();
            
            return response()->json([
                'message' => 'Vote added to existing feature request',
                'data' => $existingRequest,
                'is_new' => false,
            ]);
        }
        
        // Create new feature request
        $featureRequest = FeatureRequest::create([
            'feature_title' => $request->feature_title,
            'description' => $request->description,
            'votes' => 1,
            'created_by' => auth()->id(),
        ]);
        
        return response()->json([
            'message' => 'Feature request created successfully',
            'data' => $featureRequest,
            'is_new' => true,
        ], 201);
    }

    /**
     * Upvote an existing feature request.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function vote($id)
    {
        $featureRequest = FeatureRequest::findOrFail($id);
        $featureRequest->incrementVote();
        
        return response()->json([
            'message' => 'Vote added successfully',
            'data' => $featureRequest,
        ]);
    }

    /**
     * Get suggestions for feature requests based on search term.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function suggest(Request $request)
    {
        $searchTerm = $request->input('q', '');
        
        if (strlen($searchTerm) < 2) {
            return response()->json(['data' => []]);
        }
        
        $suggestions = FeatureRequest::search($searchTerm)
            ->orderBy('votes', 'desc')
            ->limit(5)
            ->get(['id', 'feature_title', 'votes']);
        
        return response()->json(['data' => $suggestions]);
    }
}
