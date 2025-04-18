<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;
use App\Models\User;
use App\Models\MemberStaffAttendance;
use App\Models\Staff;
use Illuminate\Support\Facades\Event;
use App\Events\AttendanceUpdated;

class AdminAttendanceControllerTest extends TestCase
{
    use RefreshDatabase;

    protected $adminUser;
    protected $regularUser;
    
    protected function setUp(): void
    {
        parent::setUp();
        
        // Create an admin user
        $this->adminUser = User::factory()->create([
            'role' => 'admin'
        ]);
        
        // Create a regular user
        $this->regularUser = User::factory()->create([
            'role' => 'member'
        ]);
        
        // Create some staff members
        Staff::factory()->count(5)->create();
        
        // Create some attendance records
        $this->createAttendanceRecords();
    }
    
    protected function createAttendanceRecords()
    {
        $date = now()->format('Y-m-d');
        $staffIds = Staff::pluck('id')->toArray();
        
        foreach ($staffIds as $staffId) {
            MemberStaffAttendance::create([
                'member_id' => 1,
                'staff_id' => $staffId,
                'unit_id' => 1,
                'date' => $date,
                'status' => array_random(['present', 'absent', 'not_marked']),
                'note' => 'Test note',
                'photo_url' => null,
            ]);
        }
    }
    
    /** @test */
    public function admin_can_view_attendance_records()
    {
        $response = $this->actingAs($this->adminUser, 'api')
            ->getJson('/api/admin/attendance?date=' . now()->format('Y-m-d'));
        
        $response->assertStatus(200)
            ->assertJsonStructure([
                'records',
                'total',
                'page',
                'limit',
                'totalPages'
            ]);
        
        $this->assertCount(5, $response->json('records'));
    }
    
    /** @test */
    public function admin_can_filter_attendance_by_status()
    {
        // Update some records to have a specific status
        MemberStaffAttendance::query()->limit(2)->update(['status' => 'present']);
        
        $response = $this->actingAs($this->adminUser, 'api')
            ->getJson('/api/admin/attendance?date=' . now()->format('Y-m-d') . '&status=present');
        
        $response->assertStatus(200);
        $this->assertCount(2, $response->json('records'));
        
        foreach ($response->json('records') as $record) {
            $this->assertEquals('present', $record['status']);
        }
    }
    
    /** @test */
    public function admin_can_search_attendance_by_staff_name()
    {
        // Update a staff name to be searchable
        $staff = Staff::first();
        $staff->name = 'Unique Staff Name';
        $staff->save();
        
        $response = $this->actingAs($this->adminUser, 'api')
            ->getJson('/api/admin/attendance?date=' . now()->format('Y-m-d') . '&search=Unique');
        
        $response->assertStatus(200);
        $this->assertCount(1, $response->json('records'));
        $this->assertEquals('Unique Staff Name', $response->json('records.0.staff_name'));
    }
    
    /** @test */
    public function admin_can_get_attendance_summary()
    {
        $response = $this->actingAs($this->adminUser, 'api')
            ->getJson('/api/admin/attendance/summary?date=' . now()->format('Y-m-d'));
        
        $response->assertStatus(200)
            ->assertJsonStructure([
                'present',
                'absent',
                'not_marked',
                'total'
            ]);
        
        $this->assertEquals(5, $response->json('total'));
    }
    
    /** @test */
    public function admin_can_update_attendance_status()
    {
        Event::fake();
        
        $attendance = MemberStaffAttendance::first();
        
        $response = $this->actingAs($this->adminUser, 'api')
            ->postJson('/api/admin/attendance/update', [
                'attendance_id' => $attendance->id,
                'status' => 'present',
                'note' => 'Updated note'
            ]);
        
        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'message' => 'Attendance updated successfully'
            ]);
        
        $this->assertDatabaseHas('member_staff_attendance', [
            'id' => $attendance->id,
            'status' => 'present',
            'note' => 'Updated note'
        ]);
        
        Event::assertDispatched(AttendanceUpdated::class);
    }
    
    /** @test */
    public function regular_user_cannot_access_admin_attendance()
    {
        $response = $this->actingAs($this->regularUser, 'api')
            ->getJson('/api/admin/attendance?date=' . now()->format('Y-m-d'));
        
        $response->assertStatus(403);
    }
    
    /** @test */
    public function date_is_required_for_attendance_index()
    {
        $response = $this->actingAs($this->adminUser, 'api')
            ->getJson('/api/admin/attendance');
        
        $response->assertStatus(422);
    }
    
    /** @test */
    public function attendance_id_and_status_are_required_for_update()
    {
        $response = $this->actingAs($this->adminUser, 'api')
            ->postJson('/api/admin/attendance/update', [
                'note' => 'Just a note'
            ]);
        
        $response->assertStatus(422);
    }
}

// Helper function for random array element
if (!function_exists('array_random')) {
    function array_random($array) {
        return $array[array_rand($array)];
    }
}
