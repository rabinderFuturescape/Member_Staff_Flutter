<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;
use App\Models\StaffRating;
use App\Models\Staff;
use App\Models\SocietyStaff;
use App\Models\Member;
use App\Models\User;
use App\Models\MemberStaffAssignment;

class StaffRatingTest extends TestCase
{
    use RefreshDatabase;

    protected $member;
    protected $memberStaff;
    protected $societyStaff;
    protected $user;
    protected $adminUser;

    protected function setUp(): void
    {
        parent::setUp();

        // Create a member
        $this->member = Member::factory()->create();

        // Create a user for the member
        $this->user = User::factory()->create([
            'member_id' => $this->member->id,
        ]);

        // Create an admin user
        $this->adminUser = User::factory()->create([
            'role' => 'admin',
        ]);

        // Create a member staff
        $this->memberStaff = Staff::factory()->create();

        // Create a society staff
        $this->societyStaff = SocietyStaff::factory()->create();

        // Assign the member staff to the member
        MemberStaffAssignment::create([
            'member_id' => $this->member->id,
            'staff_id' => $this->memberStaff->id,
        ]);
    }

    /** @test */
    public function a_member_can_rate_their_assigned_staff()
    {
        $response = $this->actingAs($this->user, 'api')
            ->postJson('/api/staff/rating', [
                'member_id' => $this->member->id,
                'staff_id' => $this->memberStaff->id,
                'staff_type' => 'member',
                'rating' => 4,
                'feedback' => 'Great service!',
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('message', 'Rating submitted successfully.')
            ->assertJsonStructure([
                'message',
                'rating' => [
                    'id',
                    'member_id',
                    'staff_id',
                    'staff_type',
                    'rating',
                    'feedback',
                    'created_at',
                    'updated_at',
                ],
            ]);

        $this->assertDatabaseHas('staff_ratings', [
            'member_id' => $this->member->id,
            'staff_id' => $this->memberStaff->id,
            'staff_type' => 'member',
            'rating' => 4,
            'feedback' => 'Great service!',
        ]);
    }

    /** @test */
    public function a_member_can_rate_society_staff()
    {
        $response = $this->actingAs($this->user, 'api')
            ->postJson('/api/staff/rating', [
                'member_id' => $this->member->id,
                'staff_id' => $this->societyStaff->id,
                'staff_type' => 'society',
                'rating' => 5,
                'feedback' => 'Excellent work!',
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('message', 'Rating submitted successfully.');

        $this->assertDatabaseHas('staff_ratings', [
            'member_id' => $this->member->id,
            'staff_id' => $this->societyStaff->id,
            'staff_type' => 'society',
            'rating' => 5,
            'feedback' => 'Excellent work!',
        ]);
    }

    /** @test */
    public function a_member_cannot_rate_unassigned_staff()
    {
        // Create another staff that is not assigned to the member
        $unassignedStaff = Staff::factory()->create();

        $response = $this->actingAs($this->user, 'api')
            ->postJson('/api/staff/rating', [
                'member_id' => $this->member->id,
                'staff_id' => $unassignedStaff->id,
                'staff_type' => 'member',
                'rating' => 3,
                'feedback' => 'Average service.',
            ]);

        $response->assertStatus(403)
            ->assertJsonPath('error', 'You can only rate staff assigned to your unit.');

        $this->assertDatabaseMissing('staff_ratings', [
            'member_id' => $this->member->id,
            'staff_id' => $unassignedStaff->id,
        ]);
    }

    /** @test */
    public function a_member_cannot_rate_staff_more_than_once_per_month()
    {
        // Create an existing rating from the last week
        StaffRating::factory()->create([
            'member_id' => $this->member->id,
            'staff_id' => $this->memberStaff->id,
            'staff_type' => 'member',
            'rating' => 4,
            'feedback' => 'Previous rating',
            'created_at' => now()->subWeek(),
        ]);

        $response = $this->actingAs($this->user, 'api')
            ->postJson('/api/staff/rating', [
                'member_id' => $this->member->id,
                'staff_id' => $this->memberStaff->id,
                'staff_type' => 'member',
                'rating' => 5,
                'feedback' => 'New rating',
            ]);

        $response->assertStatus(422)
            ->assertJsonPath('error', 'You have already rated this staff member in the last month.');

        $this->assertDatabaseMissing('staff_ratings', [
            'member_id' => $this->member->id,
            'staff_id' => $this->memberStaff->id,
            'feedback' => 'New rating',
        ]);
    }

    /** @test */
    public function a_member_can_get_rating_summary_for_staff()
    {
        // Create multiple ratings for the staff
        StaffRating::factory()->count(5)->create([
            'staff_id' => $this->memberStaff->id,
            'staff_type' => 'member',
        ]);

        $response = $this->actingAs($this->user, 'api')
            ->getJson("/api/staff/{$this->memberStaff->id}/ratings?staff_type=member");

        $response->assertStatus(200)
            ->assertJsonStructure([
                'staff_id',
                'staff_type',
                'average_rating',
                'total_ratings',
                'rating_distribution',
                'recent_reviews',
            ]);
    }

    /** @test */
    public function admin_can_get_all_ratings()
    {
        // Create multiple ratings
        StaffRating::factory()->count(10)->create();

        $response = $this->actingAs($this->adminUser, 'api')
            ->getJson('/api/admin/staff/ratings');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'total',
                'page',
                'limit',
                'ratings',
            ]);
    }

    /** @test */
    public function admin_can_filter_ratings_by_staff_type()
    {
        // Create ratings for both staff types
        StaffRating::factory()->count(5)->forSocietyStaff()->create();
        StaffRating::factory()->count(5)->forMemberStaff()->create();

        $response = $this->actingAs($this->adminUser, 'api')
            ->getJson('/api/admin/staff/ratings?staff_type=society');

        $response->assertStatus(200);
        
        $ratings = $response->json('ratings');
        foreach ($ratings as $rating) {
            $this->assertEquals('society', $rating['staff_type']);
        }
    }

    /** @test */
    public function admin_can_filter_ratings_by_rating_value()
    {
        // Create ratings with different values
        StaffRating::factory()->count(3)->create(['rating' => 5]);
        StaffRating::factory()->count(3)->create(['rating' => 3]);
        StaffRating::factory()->count(3)->create(['rating' => 1]);

        $response = $this->actingAs($this->adminUser, 'api')
            ->getJson('/api/admin/staff/ratings?min_rating=4');

        $response->assertStatus(200);
        
        $ratings = $response->json('ratings');
        foreach ($ratings as $rating) {
            $this->assertGreaterThanOrEqual(4, $rating['rating']);
        }
    }

    /** @test */
    public function admin_can_export_ratings_as_csv()
    {
        // Create some ratings
        StaffRating::factory()->count(5)->create();

        $response = $this->actingAs($this->adminUser, 'api')
            ->getJson('/api/admin/staff/ratings/export');

        $response->assertStatus(200)
            ->assertHeader('Content-Type', 'text/csv; charset=UTF-8')
            ->assertHeader('Content-Disposition', 'attachment; filename="staff_ratings.csv"');
    }

    /** @test */
    public function regular_user_cannot_access_admin_ratings()
    {
        $response = $this->actingAs($this->user, 'api')
            ->getJson('/api/admin/staff/ratings');

        $response->assertStatus(403);
    }
}
