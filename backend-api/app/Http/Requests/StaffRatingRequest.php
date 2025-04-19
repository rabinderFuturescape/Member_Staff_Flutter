<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use Carbon\Carbon;

class StaffRatingRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true; // Authorization will be handled by the policy
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array|string>
     */
    public function rules(): array
    {
        $rules = [
            'staff_id' => 'required|integer',
            'staff_type' => 'required|in:society,member',
            'rating' => 'required|integer|min:1|max:5',
            'feedback' => 'nullable|string|max:500',
        ];
        
        // Check if the user has already rated this staff in the current month
        if ($this->isMethod('POST')) {
            $rules['staff_id'] = [
                'required',
                'integer',
                Rule::unique('staff_ratings')->where(function ($query) {
                    $query->where('member_id', auth()->user()->member_id)
                        ->where('staff_id', $this->staff_id)
                        ->where('staff_type', $this->staff_type)
                        ->whereYear('created_at', Carbon::now()->year)
                        ->whereMonth('created_at', Carbon::now()->month);
                }),
            ];
        }
        
        return $rules;
    }

    /**
     * Get the error messages for the defined validation rules.
     *
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'staff_id.unique' => 'You have already rated this staff this month. You can only rate a staff once per month.',
        ];
    }
}
