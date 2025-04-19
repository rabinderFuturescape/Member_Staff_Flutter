<?php

namespace Database\Factories;

use App\Models\StaffRating;
use App\Models\Member;
use App\Models\Staff;
use App\Models\SocietyStaff;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\StaffRating>
 */
class StaffRatingFactory extends Factory
{
    /**
     * The name of the factory's corresponding model.
     *
     * @var string
     */
    protected $model = StaffRating::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $staffType = $this->faker->randomElement(['society', 'member']);
        
        return [
            'member_id' => Member::factory(),
            'staff_id' => $staffType === 'society' ? SocietyStaff::factory() : Staff::factory(),
            'staff_type' => $staffType,
            'rating' => $this->faker->numberBetween(1, 5),
            'feedback' => $this->faker->optional(0.7)->paragraph(),
            'created_at' => $this->faker->dateTimeBetween('-1 year', 'now'),
            'updated_at' => now(),
        ];
    }

    /**
     * Configure the model factory.
     *
     * @return $this
     */
    public function configure()
    {
        return $this->afterMaking(function (StaffRating $rating) {
            // No additional configuration needed
        })->afterCreating(function (StaffRating $rating) {
            // No additional configuration needed
        });
    }

    /**
     * Indicate that the rating is for a society staff.
     *
     * @return \Illuminate\Database\Eloquent\Factories\Factory
     */
    public function forSocietyStaff()
    {
        return $this->state(function (array $attributes) {
            return [
                'staff_id' => SocietyStaff::factory(),
                'staff_type' => 'society',
            ];
        });
    }

    /**
     * Indicate that the rating is for a member staff.
     *
     * @return \Illuminate\Database\Eloquent\Factories\Factory
     */
    public function forMemberStaff()
    {
        return $this->state(function (array $attributes) {
            return [
                'staff_id' => Staff::factory(),
                'staff_type' => 'member',
            ];
        });
    }
}
