<?php

namespace Database\Factories;

use App\Models\StaffRating;
use App\Models\Member;
use App\Models\Staff;
use App\Models\SocietyStaff;
use Illuminate\Database\Eloquent\Factories\Factory;

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
     * @return array
     */
    public function definition()
    {
        $staffType = $this->faker->randomElement(['society', 'member']);
        
        // Get a random staff ID based on the staff type
        if ($staffType === 'society') {
            $staffId = SocietyStaff::inRandomOrder()->first()->id ?? 1;
        } else {
            $staffId = Staff::inRandomOrder()->first()->id ?? 1;
        }
        
        return [
            'member_id' => Member::inRandomOrder()->first()->id ?? 1,
            'staff_id' => $staffId,
            'staff_type' => $staffType,
            'rating' => $this->faker->numberBetween(1, 5),
            'feedback' => $this->faker->optional(0.7)->paragraph(1),
            'created_at' => $this->faker->dateTimeBetween('-6 months', 'now'),
            'updated_at' => function (array $attributes) {
                return $attributes['created_at'];
            },
        ];
    }
    
    /**
     * Indicate that the rating is for society staff.
     *
     * @return \Illuminate\Database\Eloquent\Factories\Factory
     */
    public function forSocietyStaff()
    {
        return $this->state(function (array $attributes) {
            return [
                'staff_type' => 'society',
                'staff_id' => SocietyStaff::inRandomOrder()->first()->id ?? 1,
            ];
        });
    }
    
    /**
     * Indicate that the rating is for member staff.
     *
     * @return \Illuminate\Database\Eloquent\Factories\Factory
     */
    public function forMemberStaff()
    {
        return $this->state(function (array $attributes) {
            return [
                'staff_type' => 'member',
                'staff_id' => Staff::inRandomOrder()->first()->id ?? 1,
            ];
        });
    }
    
    /**
     * Indicate that the rating is high (4-5).
     *
     * @return \Illuminate\Database\Eloquent\Factories\Factory
     */
    public function highRating()
    {
        return $this->state(function (array $attributes) {
            return [
                'rating' => $this->faker->numberBetween(4, 5),
                'feedback' => $this->faker->optional(0.8)->paragraph(1),
            ];
        });
    }
    
    /**
     * Indicate that the rating is low (1-2).
     *
     * @return \Illuminate\Database\Eloquent\Factories\Factory
     */
    public function lowRating()
    {
        return $this->state(function (array $attributes) {
            return [
                'rating' => $this->faker->numberBetween(1, 2),
                'feedback' => $this->faker->optional(0.9)->paragraph(1),
            ];
        });
    }
}
