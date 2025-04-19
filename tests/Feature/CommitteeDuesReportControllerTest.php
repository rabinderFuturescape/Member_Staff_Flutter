<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;
use App\Models\User;
use App\Models\Member;
use App\Models\Building;
use App\Models\Unit;
use App\Models\MemberBill;
use App\Models\Payment;
use Laravel\Sanctum\Sanctum;

class CommitteeDuesReportControllerTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Setup the test environment.
     */
    protected function setUp(): void
    {
        parent::setUp();
        
        // Create buildings, units, members, bills, and payments
        $this->createTestData();
    }

    /**
     * Create test data for the tests.
     */
    private function createTestData()
    {
        // Create buildings
        $buildingA = Building::create([
            'name' => 'Building A',
            'code' => 'A',
            'total_units' => 10,
        ]);

        $buildingB = Building::create([
            'name' => 'Building B',
            'code' => 'B',
            'total_units' => 10,
        ]);

        // Create units
        $unitA101 = Unit::create([
            'unit_number' => 'A-101',
            'building_id' => $buildingA->id,
            'floor' => '1',
            'is_occupied' => true,
        ]);

        $unitA102 = Unit::create([
            'unit_number' => 'A-102',
            'building_id' => $buildingA->id,
            'floor' => '1',
            'is_occupied' => true,
        ]);

        $unitB101 = Unit::create([
            'unit_number' => 'B-101',
            'building_id' => $buildingB->id,
            'floor' => '1',
            'is_occupied' => true,
        ]);

        // Create members
        $memberA101 = Member::create([
            'name' => 'John Doe',
            'email' => 'john@example.com',
            'mobile' => '1234567890',
            'unit_id' => $unitA101->id,
        ]);

        $memberA102 = Member::create([
            'name' => 'Jane Smith',
            'email' => 'jane@example.com',
            'mobile' => '9876543210',
            'unit_id' => $unitA102->id,
        ]);

        $memberB101 = Member::create([
            'name' => 'Bob Johnson',
            'email' => 'bob@example.com',
            'mobile' => '5555555555',
            'unit_id' => $unitB101->id,
        ]);

        // Create bills
        $billA101 = MemberBill::create([
            'member_id' => $memberA101->id,
            'bill_cycle' => 'Apr 2025',
            'amount' => 1000,
            'due_date' => '2025-04-10',
            'status' => 'unpaid',
        ]);

        $billA102 = MemberBill::create([
            'member_id' => $memberA102->id,
            'bill_cycle' => 'Apr 2025',
            'amount' => 1200,
            'due_date' => '2025-04-10',
            'status' => 'partial',
        ]);

        $billB101 = MemberBill::create([
            'member_id' => $memberB101->id,
            'bill_cycle' => 'Apr 2025',
            'amount' => 1500,
            'due_date' => '2025-04-10',
            'status' => 'unpaid',
        ]);

        // Create payments
        Payment::create([
            'bill_id' => $billA102->id,
            'amount' => 500,
            'payment_date' => '2025-04-05',
            'payment_method' => 'online',
            'receipt_number' => 'REC-001',
        ]);
    }

    /**
     * Test that committee members can view the dues report.
     */
    public function test_committee_members_can_view_dues_report()
    {
        // Create a committee user
        $committeeUser = User::factory()->create(['role' => 'committee']);
        
        // Act as the committee user
        Sanctum::actingAs($committeeUser);
        
        // Make the request
        $response = $this->getJson('/api/committee/dues-report');
        
        // Assert the response
        $response->assertStatus(200)
                 ->assertJsonStructure([
                     'data' => [
                         '*' => [
                             'member_name',
                             'unit_number',
                             'building_name',
                             'bill_cycle',
                             'bill_amount',
                             'amount_paid',
                             'due_amount',
                             'due_date',
                             'last_payment_date',
                         ]
                     ],
                     'current_page',
                     'first_page_url',
                     'from',
                     'last_page',
                     'last_page_url',
                     'links',
                     'next_page_url',
                     'path',
                     'per_page',
                     'prev_page_url',
                     'to',
                     'total',
                 ]);
    }

    /**
     * Test that non-committee members cannot view the dues report.
     */
    public function test_non_committee_members_cannot_view_dues_report()
    {
        // Create a regular user
        $regularUser = User::factory()->create(['role' => 'member']);
        
        // Act as the regular user
        Sanctum::actingAs($regularUser);
        
        // Make the request
        $response = $this->getJson('/api/committee/dues-report');
        
        // Assert the response
        $response->assertStatus(403);
    }

    /**
     * Test that committee members can filter the dues report by building.
     */
    public function test_committee_members_can_filter_dues_report_by_building()
    {
        // Create a committee user
        $committeeUser = User::factory()->create(['role' => 'committee']);
        
        // Act as the committee user
        Sanctum::actingAs($committeeUser);
        
        // Make the request with building filter
        $response = $this->getJson('/api/committee/dues-report?building=A');
        
        // Assert the response
        $response->assertStatus(200)
                 ->assertJsonStructure([
                     'data' => [
                         '*' => [
                             'member_name',
                             'unit_number',
                             'building_name',
                             'bill_cycle',
                             'bill_amount',
                             'amount_paid',
                             'due_amount',
                             'due_date',
                             'last_payment_date',
                         ]
                     ],
                 ]);
        
        // Check that only Building A units are returned
        $data = $response->json('data');
        foreach ($data as $item) {
            $this->assertEquals('Building A', $item['building_name']);
        }
    }

    /**
     * Test that committee members can filter the dues report by month.
     */
    public function test_committee_members_can_filter_dues_report_by_month()
    {
        // Create a committee user
        $committeeUser = User::factory()->create(['role' => 'committee']);
        
        // Act as the committee user
        Sanctum::actingAs($committeeUser);
        
        // Make the request with month filter
        $response = $this->getJson('/api/committee/dues-report?month=2025-04');
        
        // Assert the response
        $response->assertStatus(200);
        
        // Check that only April 2025 bills are returned
        $data = $response->json('data');
        foreach ($data as $item) {
            $this->assertEquals('Apr 2025', $item['bill_cycle']);
        }
    }

    /**
     * Test that committee members can filter the dues report by status.
     */
    public function test_committee_members_can_filter_dues_report_by_status()
    {
        // Create a committee user
        $committeeUser = User::factory()->create(['role' => 'committee']);
        
        // Act as the committee user
        Sanctum::actingAs($committeeUser);
        
        // Make the request with status filter (unpaid)
        $response = $this->getJson('/api/committee/dues-report?status=unpaid');
        
        // Assert the response
        $response->assertStatus(200);
        
        // Check that only unpaid bills are returned
        $data = $response->json('data');
        foreach ($data as $item) {
            $this->assertEquals(0, $item['amount_paid']);
        }
        
        // Make the request with status filter (partial)
        $response = $this->getJson('/api/committee/dues-report?status=partial');
        
        // Assert the response
        $response->assertStatus(200);
        
        // Check that only partially paid bills are returned
        $data = $response->json('data');
        foreach ($data as $item) {
            $this->assertGreaterThan(0, $item['amount_paid']);
            $this->assertLessThan($item['bill_amount'], $item['amount_paid']);
        }
    }

    /**
     * Test that committee members can search the dues report.
     */
    public function test_committee_members_can_search_dues_report()
    {
        // Create a committee user
        $committeeUser = User::factory()->create(['role' => 'committee']);
        
        // Act as the committee user
        Sanctum::actingAs($committeeUser);
        
        // Make the request with search filter
        $response = $this->getJson('/api/committee/dues-report?search=John');
        
        // Assert the response
        $response->assertStatus(200);
        
        // Check that only John Doe's bills are returned
        $data = $response->json('data');
        foreach ($data as $item) {
            $this->assertEquals('John Doe', $item['member_name']);
        }
    }

    /**
     * Test that committee members can export the dues report as CSV.
     */
    public function test_committee_members_can_export_dues_report()
    {
        // Create a committee user
        $committeeUser = User::factory()->create(['role' => 'committee']);
        
        // Act as the committee user
        Sanctum::actingAs($committeeUser);
        
        // Make the request
        $response = $this->get('/api/committee/dues-report/export');
        
        // Assert the response
        $response->assertStatus(200)
                 ->assertHeader('Content-Type', 'text/csv; charset=UTF-8')
                 ->assertHeader('Content-Disposition', 'attachment; filename="dues_report_' . now()->format('Y-m-d') . '.csv"');
    }

    /**
     * Test that non-committee members cannot export the dues report.
     */
    public function test_non_committee_members_cannot_export_dues_report()
    {
        // Create a regular user
        $regularUser = User::factory()->create(['role' => 'member']);
        
        // Act as the regular user
        Sanctum::actingAs($regularUser);
        
        // Make the request
        $response = $this->get('/api/committee/dues-report/export');
        
        // Assert the response
        $response->assertStatus(403);
    }
}
