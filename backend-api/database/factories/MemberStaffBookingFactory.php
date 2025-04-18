<?php

namespace Database\Factories;

use App\Models\MemberStaffBooking;
use App\Models\Staff;
use App\Models\Member;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\MemberStaffBooking>
 */
class MemberStaffBookingFactory extends Factory
{
    /**
     * The name of the factory's corresponding model.
     *
     * @var string
     */
    protected $model = MemberStaffBooking::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $startDate = $this->faker->dateTimeBetween('now', '+30 days');
        $endDate = clone $startDate;
        
        if ($this->faker->boolean(30)) {
            $endDate = $this->faker->dateTimeBetween($startDate, '+7 days');
        }
        
        return [
            'staff_id' => Staff::factory(),
            'member_id' => Member::factory(),
            'unit_id' => fn (array $attributes) => Member::find($attributes['member_id'])->unit_id,
            'company_id' => fn (array $attributes) => Member::find($attributes['member_id'])->company_id,
            'start_date' => $startDate,
            'end_date' => $endDate,
            'repeat_type' => $this->faker->randomElement(['once', 'daily', 'weekly']),
            'notes' => $this->faker->boolean(70) ? $this->faker->sentence() : null,
            'status' => $this->faker->randomElement(['pending', 'confirmed', 'rescheduled', 'cancelled']),
        ];
    }
    
    /**
     * Indicate that the booking is pending.
     *
     * @return \Illuminate\Database\Eloquent\Factories\Factory
     */
    public function pending()
    {
        return $this->state(function (array $attributes) {
            return [
                'status' => 'pending',
            ];
        });
    }
    
    /**
     * Indicate that the booking is confirmed.
     *
     * @return \Illuminate\Database\Eloquent\Factories\Factory
     */
    public function confirmed()
    {
        return $this->state(function (array $attributes) {
            return [
                'status' => 'confirmed',
            ];
        });
    }
    
    /**
     * Indicate that the booking is rescheduled.
     *
     * @return \Illuminate\Database\Eloquent\Factories\Factory
     */
    public function rescheduled()
    {
        return $this->state(function (array $attributes) {
            return [
                'status' => 'rescheduled',
            ];
        });
    }
    
    /**
     * Indicate that the booking is cancelled.
     *
     * @return \Illuminate\Database\Eloquent\Factories\Factory
     */
    public function cancelled()
    {
        return $this->state(function (array $attributes) {
            return [
                'status' => 'cancelled',
            ];
        });
    }
}
