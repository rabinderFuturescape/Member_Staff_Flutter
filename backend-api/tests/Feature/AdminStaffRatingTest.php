<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;
use App\Models\User;
use App\Models\Member;
use App\Models\Staff;
use App\Models\SocietyStaff;
use App\Models\StaffRating;
use Laravel\Sanctum\Sanctum;

class AdminStaffRatingTest extends TestCase
{
    use RefreshDatabase, WithFaker;

    /**
     * Setup the test environment.
     */
    protected function setUp(): void
    {
        parent::setUp();
        
        // Create an admin user
        $this->admin = User::factory()->create([
            'role' => 'admin',
        ]);
        
        // Create a regular user
        $this->user = User::factory()->create([
            'role' => 'member',
        ]);
        
        // Create members
        $this->members = Member::factory()->count(5)->create();
        
        // Create staff
        $this->staff = Staff::factory()->count(3)->create([
            'member_id' => $this->members->first()->id,
        ]);
        
        // Create society staff
        $this->societyStaff = SocietyStaff::factory()->count(3)->create();
        
        // Create ratings for member staff
        foreach ($this->staff as $staff) {
            foreach ($this->members->skip(1) as $member) {
                StaffRating::factory()->create([
                    'member_id' => $member->id,
                    'staff_id' => $staff->id,
                    'staff_type' => 'member',
                    'rating' => $this->faker->numberBetween(1, 5),
                    'feedback' => $this->faker->sentence(),
                ]);
            }
        }
        
        // Create ratings for society staff
        foreach ($this->societyStaff as $staff) {
            foreach ($this->members as $member) {
                StaffRating::factory()->create([
                    'member_id' => $member->id,
                    'staff_id' => $staff->id,
                    'staff_type' => 'society',
                    'rating' => $this->faker->numberBetween(1, 5),
                    'feedback' => $this->faker->sentence(),
                ]);
            }
        }
    }

    /**
     * Test that unauthorized users cannot access the admin staff ratings endpoint.
     */
    public function test_unauthorized_users_cannot_access_admin_staff_ratings()
    {
        Sanctum::actingAs($this->user);
        
        $response = $this->getJson('/api/admin/staff/ratings');
        
        $response->assertStatus(403);
    }

    /**
     * Test that admin users can access the admin staff ratings endpoint.
     */
    public function test_admin_users_can_access_admin_staff_ratings()
    {
        Sanctum::actingAs($this->admin);
        
        $response = $this->getJson('/api/admin/staff/ratings');
        
        $response->assertStatus(200)
            ->assertJsonStructure([
                'total',
                'ratings' => [
                    '*' => [
                        'staff_id',
                        'staff_type',
                        'average_rating',
                        'total_ratings',
                        'staff_name',
                        'staff_category',
                        'staff_photo_url',
                    ],
                ],
            ]);
    }

    /**
     * Test that admin users can filter staff ratings by staff type.
     */
    public function test_admin_users_can_filter_staff_ratings_by_staff_type()
    {
        Sanctum::actingAs($this->admin);
        
        $response = $this->getJson('/api/admin/staff/ratings?staff_type=member');
        
        $response->assertStatus(200)
            ->assertJsonStructure([
                'total',
                'ratings' => [
                    '*' => [
                        'staff_id',
                        'staff_type',
                        'average_rating',
                        'total_ratings',
                        'staff_name',
                        'staff_category',
                        'staff_photo_url',
                    ],
                ],
            ]);
        
        $ratings = $response->json('ratings');
        foreach ($ratings as $rating) {
            $this->assertEquals('member', $rating['staff_type']);
        }
    }

    /**
     * Test that admin users can filter staff ratings by minimum rating.
     */
    public function test_admin_users_can_filter_staff_ratings_by_minimum_rating()
    {
        Sanctum::actingAs($this->admin);
        
        $response = $this->getJson('/api/admin/staff/ratings?min_rating=4');
        
        $response->assertStatus(200)
            ->assertJsonStructure([
                'total',
                'ratings' => [
                    '*' => [
                        'staff_id',
                        'staff_type',
                        'average_rating',
                        'total_ratings',
                        'staff_name',
                        'staff_category',
                        'staff_photo_url',
                    ],
                ],
            ]);
        
        $ratings = $response->json('ratings');
        foreach ($ratings as $rating) {
            $this->assertGreaterThanOrEqual(4, $rating['average_rating']);
        }
    }

    /**
     * Test that admin users can view detailed information about a specific staff's ratings.
     */
    public function test_admin_users_can_view_detailed_staff_ratings()
    {
        Sanctum::actingAs($this->admin);
        
        $staff = $this->staff->first();
        
        $response = $this->getJson("/api/admin/staff/{$staff->id}/ratings?staff_type=member");
        
        $response->assertStatus(200)
            ->assertJsonStructure([
                'staff_id',
                'staff_type',
                'staff_name',
                'staff_category',
                'staff_photo_url',
                'average_rating',
                'total_ratings',
                'rating_distribution',
                'recent_reviews' => [
                    '*' => [
                        'id',
                        'rating',
                        'feedback',
                        'member_name',
                        'created_at',
                    ],
                ],
            ]);
        
        $this->assertEquals($staff->id, $response->json('staff_id'));
        $this->assertEquals('member', $response->json('staff_type'));
        $this->assertEquals($staff->name, $response->json('staff_name'));
    }

    /**
     * Test that admin users can export staff ratings as CSV.
     */
    public function test_admin_users_can_export_staff_ratings()
    {
        Sanctum::actingAs($this->admin);
        
        $response = $this->get('/api/admin/staff/ratings/export');
        
        $response->assertStatus(200)
            ->assertHeader('Content-Type', 'text/csv; charset=UTF-8')
            ->assertHeader('Content-Disposition', 'attachment; filename="staff_ratings.csv"');
    }
}
