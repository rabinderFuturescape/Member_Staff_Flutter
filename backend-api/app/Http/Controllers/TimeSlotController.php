<?php

namespace App\Http\Controllers;

use App\Models\Staff;
use App\Models\TimeSlot;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use Carbon\Carbon;

class TimeSlotController extends Controller
{
    /**
     * Get a staff's schedule.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  string  $staffId
     * @return \Illuminate\Http\JsonResponse
     */
    public function getSchedule(Request $request, $staffId)
    {
        $validator = Validator::make($request->all(), [
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        $staff = Staff::findOrFail($staffId);

        $startDate = $request->input('start_date') ? Carbon::parse($request->input('start_date')) : Carbon::today();
        $endDate = $request->input('end_date') ? Carbon::parse($request->input('end_date')) : $startDate->copy()->addDays(6);

        $timeSlots = $staff->timeSlots()
            ->whereBetween('date', [$startDate, $endDate])
            ->orderBy('date')
            ->orderBy('start_time')
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'staff' => $staff,
                'time_slots' => $timeSlots,
                'start_date' => $startDate->toDateString(),
                'end_date' => $endDate->toDateString(),
            ],
        ]);
    }

    /**
     * Add a time slot to a staff's schedule.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  string  $staffId
     * @return \Illuminate\Http\JsonResponse
     */
    public function addTimeSlot(Request $request, $staffId)
    {
        $validator = Validator::make($request->all(), [
            'date' => 'required|date',
            'start_time' => 'required|date_format:H:i',
            'end_time' => 'required|date_format:H:i|after:start_time',
            'is_booked' => 'boolean',
            'member_id' => 'required|string', // From member context
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        $staff = Staff::findOrFail($staffId);

        // Check if the staff is verified
        if (!$staff->is_verified) {
            return response()->json([
                'success' => false,
                'message' => 'Staff must be verified before adding time slots',
            ], 400);
        }

        // Create a new time slot
        $newTimeSlot = new TimeSlot([
            'date' => $request->input('date'),
            'start_time' => $request->input('start_time'),
            'end_time' => $request->input('end_time'),
            'is_booked' => $request->input('is_booked', false),
        ]);

        // Check for conflicts with existing time slots
        $existingTimeSlots = $staff->timeSlots()
            ->where('date', $request->input('date'))
            ->get();

        foreach ($existingTimeSlots as $existingTimeSlot) {
            if ($newTimeSlot->overlaps($existingTimeSlot)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Time slot conflicts with an existing time slot',
                    'conflicting_slot' => $existingTimeSlot,
                ], 400);
            }
        }

        // Save the time slot
        $newTimeSlot->id = (string) Str::uuid();
        $newTimeSlot->staff_id = $staffId;
        $newTimeSlot->save();

        return response()->json([
            'success' => true,
            'message' => 'Time slot added successfully',
            'data' => $newTimeSlot,
        ], 201);
    }

    /**
     * Update a time slot.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  string  $staffId
     * @param  string  $timeSlotId
     * @return \Illuminate\Http\JsonResponse
     */
    public function updateTimeSlot(Request $request, $staffId, $timeSlotId)
    {
        $validator = Validator::make($request->all(), [
            'date' => 'sometimes|required|date',
            'start_time' => 'sometimes|required|date_format:H:i',
            'end_time' => 'sometimes|required|date_format:H:i|after:start_time',
            'is_booked' => 'boolean',
            'member_id' => 'required|string', // From member context
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        $staff = Staff::findOrFail($staffId);
        $timeSlot = $staff->timeSlots()->findOrFail($timeSlotId);

        // Create a temporary time slot with the updated values for conflict checking
        $updatedTimeSlot = new TimeSlot([
            'date' => $request->input('date', $timeSlot->date),
            'start_time' => $request->input('start_time', $timeSlot->start_time),
            'end_time' => $request->input('end_time', $timeSlot->end_time),
            'is_booked' => $request->input('is_booked', $timeSlot->is_booked),
        ]);

        // Check for conflicts with existing time slots (excluding the current one)
        $existingTimeSlots = $staff->timeSlots()
            ->where('id', '!=', $timeSlotId)
            ->where('date', $updatedTimeSlot->date)
            ->get();

        foreach ($existingTimeSlots as $existingTimeSlot) {
            if ($updatedTimeSlot->overlaps($existingTimeSlot)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Updated time slot conflicts with an existing time slot',
                    'conflicting_slot' => $existingTimeSlot,
                ], 400);
            }
        }

        // Update the time slot
        $timeSlot->update([
            'date' => $updatedTimeSlot->date,
            'start_time' => $updatedTimeSlot->start_time,
            'end_time' => $updatedTimeSlot->end_time,
            'is_booked' => $updatedTimeSlot->is_booked,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Time slot updated successfully',
            'data' => $timeSlot,
        ]);
    }

    /**
     * Remove a time slot.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  string  $staffId
     * @param  string  $timeSlotId
     * @return \Illuminate\Http\JsonResponse
     */
    public function removeTimeSlot(Request $request, $staffId, $timeSlotId)
    {
        $staff = Staff::findOrFail($staffId);
        $timeSlot = $staff->timeSlots()->findOrFail($timeSlotId);

        // Soft delete the time slot
        $timeSlot->delete();

        return response()->json([
            'success' => true,
            'message' => 'Time slot removed successfully',
        ]);
    }

    /**
     * Get time slots for a specific date.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  string  $staffId
     * @param  string  $date
     * @return \Illuminate\Http\JsonResponse
     */
    public function getTimeSlotsForDate(Request $request, $staffId, $date)
    {
        $staff = Staff::findOrFail($staffId);
        $date = Carbon::parse($date);

        $timeSlots = $staff->timeSlots()
            ->where('date', $date->toDateString())
            ->orderBy('start_time')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $timeSlots,
        ]);
    }

    /**
     * Bulk add time slots.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  string  $staffId
     * @return \Illuminate\Http\JsonResponse
     */
    public function bulkAddTimeSlots(Request $request, $staffId)
    {
        $validator = Validator::make($request->all(), [
            'time_slots' => 'required|array',
            'time_slots.*.date' => 'required|date',
            'time_slots.*.start_time' => 'required|date_format:H:i',
            'time_slots.*.end_time' => 'required|date_format:H:i|after:time_slots.*.start_time',
            'time_slots.*.is_booked' => 'boolean',
            'member_id' => 'required|string', // From member context
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        $staff = Staff::findOrFail($staffId);

        // Check if the staff is verified
        if (!$staff->is_verified) {
            return response()->json([
                'success' => false,
                'message' => 'Staff must be verified before adding time slots',
            ], 400);
        }

        $timeSlots = $request->input('time_slots');
        $addedTimeSlots = [];
        $conflictingTimeSlots = [];

        foreach ($timeSlots as $timeSlotData) {
            $newTimeSlot = new TimeSlot([
                'date' => $timeSlotData['date'],
                'start_time' => $timeSlotData['start_time'],
                'end_time' => $timeSlotData['end_time'],
                'is_booked' => $timeSlotData['is_booked'] ?? false,
            ]);

            // Check for conflicts with existing time slots
            $existingTimeSlots = $staff->timeSlots()
                ->where('date', $timeSlotData['date'])
                ->get();

            $hasConflict = false;
            foreach ($existingTimeSlots as $existingTimeSlot) {
                if ($newTimeSlot->overlaps($existingTimeSlot)) {
                    $conflictingTimeSlots[] = [
                        'new_slot' => $timeSlotData,
                        'existing_slot' => $existingTimeSlot,
                    ];
                    $hasConflict = true;
                    break;
                }
            }

            if (!$hasConflict) {
                // Save the time slot
                $newTimeSlot->id = (string) Str::uuid();
                $newTimeSlot->staff_id = $staffId;
                $newTimeSlot->save();
                $addedTimeSlots[] = $newTimeSlot;
            }
        }

        return response()->json([
            'success' => true,
            'message' => count($addedTimeSlots) . ' time slots added successfully',
            'data' => [
                'added_time_slots' => $addedTimeSlots,
                'conflicting_time_slots' => $conflictingTimeSlots,
            ],
        ]);
    }
}
