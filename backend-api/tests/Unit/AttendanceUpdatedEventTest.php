<?php

namespace Tests\Unit;

use Tests\TestCase;
use App\Events\AttendanceUpdated;
use App\Models\MemberStaffAttendance;
use App\Models\Staff;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Event;

class AttendanceUpdatedEventTest extends TestCase
{
    use RefreshDatabase;
    
    /** @test */
    public function attendance_updated_event_contains_correct_data()
    {
        // Create a staff member
        $staff = Staff::factory()->create([
            'name' => 'Test Staff',
            'category' => 'Domestic Help',
            'photo_url' => 'https://example.com/photo.jpg'
        ]);
        
        // Create an attendance record
        $attendance = MemberStaffAttendance::factory()->create([
            'staff_id' => $staff->id,
            'member_id' => 1,
            'unit_id' => 1,
            'date' => now(),
            'status' => 'present',
            'note' => 'Test note',
            'photo_url' => 'https://example.com/proof.jpg'
        ]);
        
        // Create the event
        $event = new AttendanceUpdated($attendance);
        
        // Check that the event contains the correct data
        $this->assertEquals($attendance->id, $event->attendanceData['id']);
        $this->assertEquals($staff->id, $event->attendanceData['staff_id']);
        $this->assertEquals('Test Staff', $event->attendanceData['staff_name']);
        $this->assertEquals('Domestic Help', $event->attendanceData['staff_category']);
        $this->assertEquals('https://example.com/photo.jpg', $event->attendanceData['staff_photo']);
        $this->assertEquals('present', $event->attendanceData['status']);
        $this->assertEquals('Test note', $event->attendanceData['note']);
        $this->assertEquals('https://example.com/proof.jpg', $event->attendanceData['photo_url']);
        $this->assertEquals(now()->format('Y-m-d'), $event->attendanceData['date']);
    }
    
    /** @test */
    public function attendance_updated_event_broadcasts_on_correct_channel()
    {
        $attendance = MemberStaffAttendance::factory()->create();
        $event = new AttendanceUpdated($attendance);
        
        $this->assertEquals('attendance', $event->broadcastOn()->name);
    }
    
    /** @test */
    public function attendance_updated_event_has_correct_broadcast_name()
    {
        $attendance = MemberStaffAttendance::factory()->create();
        $event = new AttendanceUpdated($attendance);
        
        $this->assertEquals('attendance.updated', $event->broadcastAs());
    }
}
