<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\MemberStaffAttendance;
use Illuminate\Support\Facades\Validator;

class MemberStaffAttendanceController extends Controller
{
    public function index(Request $request)
    {
        $validated = $request->validate([
            'member_id' => 'required|exists:members,id',
            'month' => 'required|date_format:Y-m'
        ]);
        
        $year = substr($validated['month'], 0, 4);
        $month = substr($validated['month'], 5, 2);
        
        $attendances = MemberStaffAttendance::where('member_id', $validated['member_id'])
            ->whereYear('date', $year)
            ->whereMonth('date', $month)
            ->with('staff:id,name,photo_url,category')
            ->get();
        
        // Group by date and staff_id for easier frontend processing
        $result = [];
        foreach ($attendances as $attendance) {
            $dateStr = $attendance->date->format('Y-m-d');
            if (!isset($result[$dateStr])) {
                $result[$dateStr] = [];
            }
            
            $result[$dateStr][] = [
                'staff_id' => $attendance->staff_id,
                'staff_name' => $attendance->staff->name ?? 'Unknown',
                'staff_photo' => $attendance->staff->photo_url ?? null,
                'staff_category' => $attendance->staff->category ?? 'Staff',
                'status' => $attendance->status,
                'note' => $attendance->note,
                'photo_url' => $attendance->photo_url,
            ];
        }
        
        return response()->json($result);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'member_id' => 'required|exists:members,id',
            'unit_id' => 'required|numeric',
            'date' => 'required|date',
            'entries' => 'required|array',
            'entries.*.staff_id' => 'required|exists:staff,id',
            'entries.*.status' => 'required|in:present,absent',
            'entries.*.note' => 'nullable|string',
            'entries.*.photo_url' => 'nullable|string'
        ]);

        foreach ($validated['entries'] as $entry) {
            MemberStaffAttendance::updateOrCreate(
                [
                    'member_id' => $validated['member_id'],
                    'staff_id' => $entry['staff_id'],
                    'unit_id' => $validated['unit_id'],
                    'date' => $validated['date']
                ],
                [
                    'status' => $entry['status'],
                    'note' => $entry['note'] ?? null,
                    'photo_url' => $entry['photo_url'] ?? null,
                ]
            );
        }

        return response()->json(['status' => 'saved']);
    }
}
