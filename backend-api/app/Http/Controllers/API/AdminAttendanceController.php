<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\MemberStaffAttendance;
use App\Models\Staff;
use Illuminate\Support\Facades\DB;
use App\Events\AttendanceUpdated;

class AdminAttendanceController extends Controller
{
    /**
     * Get attendance records for a specific date
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(Request $request)
    {
        $request->validate([
            'date' => 'required|date',
            'status' => 'nullable|in:present,absent,not_marked',
            'search' => 'nullable|string|max:100',
            'page' => 'nullable|integer|min:1',
            'limit' => 'nullable|integer|min:1|max:100'
        ]);

        $date = $request->input('date');
        $status = $request->input('status');
        $search = $request->input('search');
        $page = $request->input('page', 1);
        $limit = $request->input('limit', 10);

        $query = MemberStaffAttendance::with('staff')
            ->where('date', $date);

        // Apply status filter if provided
        if ($status) {
            $query->where('status', $status);
        }

        // Apply search filter if provided
        if ($search) {
            $query->whereHas('staff', function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%");
            });
        }

        // Get total count for pagination
        $total = $query->count();

        // Apply pagination
        $records = $query->skip(($page - 1) * $limit)
            ->take($limit)
            ->get()
            ->map(function ($rec) {
                return [
                    'staff_id' => $rec->staff_id,
                    'staff_name' => $rec->staff->name ?? 'Unknown',
                    'staff_category' => $rec->staff->category ?? 'Staff',
                    'staff_photo' => $rec->staff->photo_url ?? null,
                    'status' => $rec->status,
                    'note' => $rec->note,
                    'photo_url' => $rec->photo_url,
                    'updated_at' => $rec->updated_at->toIso8601String()
                ];
            });

        return response()->json([
            'records' => $records,
            'total' => $total,
            'page' => (int)$page,
            'limit' => (int)$limit,
            'totalPages' => ceil($total / $limit)
        ]);
    }

    /**
     * Get summary statistics for a specific date
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function summary(Request $request)
    {
        $request->validate([
            'date' => 'required|date'
        ]);

        $date = $request->input('date');

        $summary = [
            'present' => MemberStaffAttendance::where('date', $date)->where('status', 'present')->count(),
            'absent' => MemberStaffAttendance::where('date', $date)->where('status', 'absent')->count(),
            'not_marked' => MemberStaffAttendance::where('date', $date)->where('status', 'not_marked')->count(),
            'total' => Staff::count()
        ];

        return response()->json($summary);
    }

    /**
     * Update attendance status
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function update(Request $request)
    {
        $request->validate([
            'attendance_id' => 'required|exists:member_staff_attendance,id',
            'status' => 'required|in:present,absent,not_marked',
            'note' => 'nullable|string|max:500'
        ]);

        $attendance = MemberStaffAttendance::findOrFail($request->input('attendance_id'));
        
        $attendance->status = $request->input('status');
        
        if ($request->has('note')) {
            $attendance->note = $request->input('note');
        }
        
        $attendance->save();

        // Broadcast the update to all admin dashboard users
        event(new AttendanceUpdated($attendance));

        return response()->json([
            'status' => 'success',
            'message' => 'Attendance updated successfully',
            'attendance' => [
                'id' => $attendance->id,
                'staff_id' => $attendance->staff_id,
                'staff_name' => $attendance->staff->name ?? 'Unknown',
                'status' => $attendance->status,
                'note' => $attendance->note,
                'photo_url' => $attendance->photo_url,
                'updated_at' => $attendance->updated_at->toIso8601String()
            ]
        ]);
    }
}
