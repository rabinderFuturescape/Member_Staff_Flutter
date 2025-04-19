<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use App\Models\Staff;
use App\Models\SocietyStaff;

class StaffRatingAggregateResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        // Get staff details based on staff_type
        if ($this->staff_type === 'society') {
            $staff = SocietyStaff::find($this->staff_id);
        } else {
            $staff = Staff::find($this->staff_id);
        }
        
        return [
            'staff_id' => $this->staff_id,
            'staff_type' => $this->staff_type,
            'staff_name' => $staff ? $staff->name : 'Unknown',
            'staff_category' => $staff ? ($staff->category ?? null) : null,
            'staff_photo_url' => $staff ? ($staff->photo_url ?? null) : null,
            'average_rating' => round($this->average_rating, 1),
            'total_ratings' => $this->total_ratings,
        ];
    }
}
