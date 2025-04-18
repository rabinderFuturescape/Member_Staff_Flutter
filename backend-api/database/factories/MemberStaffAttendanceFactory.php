<?php

namespace Database\Factories;

use App\Models\MemberStaffAttendance;
use App\Models\Staff;
use Illuminate\Database\Eloquent\Factories\Factory;

class MemberStaffAttendanceFactory extends Factory
{
    /**
     * The name of the factory's corresponding model.
     *
     * @var string
     */
    protected $model = MemberStaffAttendance::class;

    /**
     * Define the model's default state.
     *
     * @return array
     */
    public function definition()
    {
        $staffId = Staff::factory()->create()->id;
        
        return [
            'member_id' => $this->faker->numberBetween(1, 100),
            'staff_id' => $staffId,
            'unit_id' => $this->faker->numberBetween(1, 50),
            'date' => $this->faker->dateTimeBetween('-1 month', '+1 month')->format('Y-m-d'),
            'status' => $this->faker->randomElement(['present', 'absent', 'not_marked']),
            'note' => $this->faker->optional(0.7)->sentence(),
            'photo_url' => $this->faker->optional(0.5)->imageUrl(),
        ];
    }
    
    /**
     * Indicate that the attendance is present.
     *
     * @return \Illuminate\Database\Eloquent\Factories\Factory
     */
    public function present()
    {
        return $this->state(function (array $attributes) {
            return [
                'status' => 'present',
                'photo_url' => $this->faker->imageUrl(), // Present attendance usually has a photo
            ];
        });
    }
    
    /**
     * Indicate that the attendance is absent.
     *
     * @return \Illuminate\Database\Eloquent\Factories\Factory
     */
    public function absent()
    {
        return $this->state(function (array $attributes) {
            return [
                'status' => 'absent',
                'note' => $this->faker->sentence(), // Absent attendance usually has a note
            ];
        });
    }
    
    /**
     * Indicate that the attendance is not marked.
     *
     * @return \Illuminate\Database\Eloquent\Factories\Factory
     */
    public function notMarked()
    {
        return $this->state(function (array $attributes) {
            return [
                'status' => 'not_marked',
                'note' => null,
                'photo_url' => null,
            ];
        });
    }
}
