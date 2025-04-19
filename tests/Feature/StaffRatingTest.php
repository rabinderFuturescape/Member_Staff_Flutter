<?php

use App\Models\StaffRating;
use App\Models\Staff;
use App\Models\Member;

it('can create a staff rating', function () {
    // Arrange
    $member = Member::factory()->create();
    $staff = Staff::factory()->create();
    
    // Act
    $rating = StaffRating::create([
        'member_id' => $member->id,
        'staff_id' => $staff->id,
        'staff_type' => 'member',
        'rating' => 4,
        'feedback' => 'Great service!',
    ]);
    
    // Assert
    expect($rating)->toBeInstanceOf(StaffRating::class)
        ->and($rating->member_id)->toBe($member->id)
        ->and($rating->staff_id)->toBe($staff->id)
        ->and($rating->staff_type)->toBe('member')
        ->and($rating->rating)->toBe(4)
        ->and($rating->feedback)->toBe('Great service!');
});

it('enforces rating between 1 and 5', function () {
    // Arrange
    $member = Member::factory()->create();
    $staff = Staff::factory()->create();
    
    // Act & Assert
    expect(function () use ($member, $staff) {
        StaffRating::create([
            'member_id' => $member->id,
            'staff_id' => $staff->id,
            'staff_type' => 'member',
            'rating' => 6, // Invalid rating
            'feedback' => 'Great service!',
        ]);
    })->toThrow(Exception::class);
});
