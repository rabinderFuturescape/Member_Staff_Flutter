<?php

namespace App\Events;

use App\Models\MemberStaffAttendance;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class AttendanceUpdated implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    /**
     * The attendance record that was updated.
     *
     * @var \App\Models\MemberStaffAttendance
     */
    public $attendance;

    /**
     * The formatted attendance data for broadcasting.
     *
     * @var array
     */
    public $attendanceData;

    /**
     * Create a new event instance.
     *
     * @param  \App\Models\MemberStaffAttendance  $attendance
     * @return void
     */
    public function __construct(MemberStaffAttendance $attendance)
    {
        $this->attendance = $attendance;
        
        // Format the data for broadcasting
        $this->attendanceData = [
            'id' => $attendance->id,
            'staff_id' => $attendance->staff_id,
            'staff_name' => $attendance->staff->name ?? 'Unknown',
            'staff_category' => $attendance->staff->category ?? 'Staff',
            'staff_photo' => $attendance->staff->photo_url ?? null,
            'status' => $attendance->status,
            'note' => $attendance->note,
            'photo_url' => $attendance->photo_url,
            'date' => $attendance->date->format('Y-m-d'),
            'updated_at' => $attendance->updated_at->toIso8601String()
        ];
    }

    /**
     * Get the channels the event should broadcast on.
     *
     * @return \Illuminate\Broadcasting\Channel|array
     */
    public function broadcastOn()
    {
        return new Channel('attendance');
    }

    /**
     * The event's broadcast name.
     *
     * @return string
     */
    public function broadcastAs()
    {
        return 'attendance.updated';
    }

    /**
     * Get the data to broadcast.
     *
     * @return array
     */
    public function broadcastWith()
    {
        return $this->attendanceData;
    }
}
