<?php

namespace Database\Factories;

use App\Models\StaffRating;
use App\Models\Member;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\StaffRating>
 */
class StaffRatingFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'member_id' => Member::factory(),
            'staff_id' => $this->faker->numberBetween(1, 100),
            'staff_type' => $this->faker->randomElement(['society', 'member']),
            'rating' => $this->faker->numberBetween(1, 5),
            'feedback' => $this->faker->optional(0.7)->paragraph(),
        ];
    }
}
