<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class StaffRatingResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'member_id' => $this->member_id,
            'member_name' => $this->member->name ?? 'Unknown',
            'staff_id' => $this->staff_id,
            'staff_type' => $this->staff_type,
            'staff_name' => $this->staff_type === 'society' 
                ? ($this->societyStaff->name ?? 'Unknown') 
                : ($this->memberStaff->name ?? 'Unknown'),
            'rating' => $this->rating,
            'feedback' => $this->feedback,
            'created_at' => $this->created_at->format('Y-m-d H:i:s'),
            'updated_at' => $this->updated_at->format('Y-m-d H:i:s'),
        ];
    }
}
