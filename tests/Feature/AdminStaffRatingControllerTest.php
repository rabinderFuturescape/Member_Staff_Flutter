<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;
use App\Models\User;
use App\Models\StaffRating;
use Laravel\Sanctum\Sanctum;

class AdminStaffRatingControllerTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test that admin can view staff ratings.
     *
     * @return void
     */
    public function test_admin_can_view_staff_ratings()
    {
        // Create an admin user
        $admin = User::factory()->create(['role' => 'admin']);
        
        // Create some staff ratings
        StaffRating::factory()->count(5)->create();
        
        // Act as the admin
        Sanctum::actingAs($admin);
        
        // Make the request
        $response = $this->getJson('/api/admin/staff/ratings');
        
        // Assert the response
        $response->assertStatus(200)
                 ->assertJsonStructure([
                     '*' => [
                         'staff_id',
                         'staff_type',
                         'average_rating',
                         'total_ratings'
                     ]
                 ]);
    }

    /**
     * Test that non-admin cannot view staff ratings.
     *
     * @return void
     */
    public function test_non_admin_cannot_view_staff_ratings()
    {
        // Create a regular user
        $user = User::factory()->create(['role' => 'member']);
        
        // Act as the regular user
        Sanctum::actingAs($user);
        
        // Make the request
        $response = $this->getJson('/api/admin/staff/ratings');
        
        // Assert the response
        $response->assertStatus(403);
    }

    /**
     * Test that admin can export staff ratings as CSV.
     *
     * @return void
     */
    public function test_admin_can_export_staff_ratings()
    {
        // Create an admin user
        $admin = User::factory()->create(['role' => 'admin']);
        
        // Create some staff ratings
        StaffRating::factory()->count(5)->create();
        
        // Act as the admin
        Sanctum::actingAs($admin);
        
        // Make the request
        $response = $this->get('/api/admin/staff/ratings/export');
        
        // Assert the response
        $response->assertStatus(200)
                 ->assertHeader('Content-Type', 'text/csv; charset=UTF-8')
                 ->assertHeader('Content-Disposition', 'attachment; filename="staff_ratings_report.csv"');
    }

    /**
     * Test that non-admin cannot export staff ratings.
     *
     * @return void
     */
    public function test_non_admin_cannot_export_staff_ratings()
    {
        // Create a regular user
        $user = User::factory()->create(['role' => 'member']);
        
        // Act as the regular user
        Sanctum::actingAs($user);
        
        // Make the request
        $response = $this->get('/api/admin/staff/ratings/export');
        
        // Assert the response
        $response->assertStatus(403);
    }
}
