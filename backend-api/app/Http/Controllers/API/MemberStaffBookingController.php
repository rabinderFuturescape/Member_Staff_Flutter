<?php

namespace App\Http\Controllers\API;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Models\MemberStaffBooking;
use App\Models\BookingSlot;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;

class MemberStaffBookingController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth:api');
    }

    public function index(Request $request)
    {
        if (!Gate::allows('view-bookings', $request->user())) {
            return response()->json(['error' => 'Forbidden'], 403);
        }

        $memberId = $request->query('member_id');

        $bookings = MemberStaffBooking::with('slots')
            ->where('member_id', $memberId)
            ->get()
            ->flatMap(function ($booking) {
                return $booking->slots->map(function ($slot) use ($booking) {
                    return [
                        'booking_id' => $booking->id,
                        'staff_id' => $booking->staff_id,
                        'date' => $slot->date,
                        'hour' => $slot->hour,
                        'status' => $booking->status,
                    ];
                });
            });

        return response()->json($bookings);
    }

    public function store(Request $request)
    {
        if (!Gate::allows('create-booking', $request->user())) {
            return response()->json(['error' => 'Forbidden'], 403);
        }

        $validated = $request->validate([
            'staff_id' => 'required|exists:staff,id',
            'member_id' => 'required|exists:members,id',
            'unit_id' => 'required',
            'company_id' => 'required',
            'start_date' => 'required|date',
            'end_date' => 'required|date',
            'repeat_type' => 'required|string',
            'slot_hours' => 'required|array',
            'notes' => 'nullable|string'
        ]);

        DB::beginTransaction();

        try {
            $booking = MemberStaffBooking::create([
                'staff_id' => $validated['staff_id'],
                'member_id' => $validated['member_id'],
                'unit_id' => $validated['unit_id'],
                'company_id' => $validated['company_id'],
                'start_date' => $validated['start_date'],
                'end_date' => $validated['end_date'],
                'repeat_type' => $validated['repeat_type'],
                'notes' => $validated['notes'] ?? null,
                'status' => 'pending'
            ]);

            $dateRange = collect(range(
                strtotime($validated['start_date']),
                strtotime($validated['end_date']),
                86400
            ))->map(fn($timestamp) => date('Y-m-d', $timestamp));

            foreach ($dateRange as $date) {
                foreach ($validated['slot_hours'] as $hour) {
                    BookingSlot::create([
                        'booking_id' => $booking->id,
                        'date' => $date,
                        'hour' => $hour,
                        'is_confirmed' => false
                    ]);
                }
            }

            DB::commit();
            return response()->json(['status' => 'success', 'booking_id' => $booking->id]);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function update(Request $request, $id)
    {
        if (!Gate::allows('reschedule-booking', $request->user())) {
            return response()->json(['error' => 'Forbidden'], 403);
        }

        $validated = $request->validate([
            'new_date' => 'required|date',
            'new_hours' => 'required|array'
        ]);

        $booking = MemberStaffBooking::findOrFail($id);
        $booking->slots()->delete();

        foreach ($validated['new_hours'] as $hour) {
            BookingSlot::create([
                'booking_id' => $booking->id,
                'date' => $validated['new_date'],
                'hour' => $hour,
                'is_confirmed' => false
            ]);
        }

        $booking->start_date = $validated['new_date'];
        $booking->end_date = $validated['new_date'];
        $booking->status = 'rescheduled';
        $booking->save();

        return response()->json(['status' => 'rescheduled']);
    }

    public function destroy(Request $request, $id)
    {
        if (!Gate::allows('cancel-booking', $request->user())) {
            return response()->json(['error' => 'Forbidden'], 403);
        }

        $booking = MemberStaffBooking::findOrFail($id);
        $booking->slots()->delete();
        $booking->delete();

        return response()->json(['status' => 'deleted']);
    }
}
