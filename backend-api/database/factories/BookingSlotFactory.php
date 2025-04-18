<?php

namespace Database\Factories;

use App\Models\BookingSlot;
use App\Models\MemberStaffBooking;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\BookingSlot>
 */
class BookingSlotFactory extends Factory
{
    /**
     * The name of the factory's corresponding model.
     *
     * @var string
     */
    protected $model = BookingSlot::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'booking_id' => MemberStaffBooking::factory(),
            'date' => fn (array $attributes) => MemberStaffBooking::find($attributes['booking_id'])->start_date,
            'hour' => $this->faker->numberBetween(8, 20),
            'is_confirmed' => $this->faker->boolean(70),
        ];
    }
    
    /**
     * Indicate that the slot is confirmed.
     *
     * @return \Illuminate\Database\Eloquent\Factories\Factory
     */
    public function confirmed()
    {
        return $this->state(function (array $attributes) {
            return [
                'is_confirmed' => true,
            ];
        });
    }
    
    /**
     * Indicate that the slot is not confirmed.
     *
     * @return \Illuminate\Database\Eloquent\Factories\Factory
     */
    public function notConfirmed()
    {
        return $this->state(function (array $attributes) {
            return [
                'is_confirmed' => false,
            ];
        });
    }
}
