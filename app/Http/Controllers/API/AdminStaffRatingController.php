<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\StaffRating;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpFoundation\StreamedResponse;

class AdminStaffRatingController extends Controller
{
    /**
     * Display a listing of staff ratings with aggregated data.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function index()
    {
        $ratings = StaffRating::select(
            'staff_id',
            'staff_type',
            DB::raw('AVG(rating) as average_rating'),
            DB::raw('COUNT(*) as total_ratings')
        )
        ->groupBy('staff_id', 'staff_type')
        ->orderByDesc('average_rating')
        ->get();

        return response()->json($ratings);
    }

    /**
     * Export staff ratings data as CSV.
     *
     * @return \Symfony\Component\HttpFoundation\StreamedResponse
     */
    public function exportCsv()
    {
        $ratings = StaffRating::select(
            'staff_id',
            'staff_type',
            DB::raw('AVG(rating) as average_rating'),
            DB::raw('COUNT(*) as total_ratings')
        )
        ->groupBy('staff_id', 'staff_type')
        ->get();

        $headers = [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => 'attachment; filename="staff_ratings_report.csv"'
        ];

        $callback = function () use ($ratings) {
            $handle = fopen('php://output', 'w');
            fputcsv($handle, ['Staff ID', 'Staff Type', 'Average Rating', 'Total Ratings']);

            foreach ($ratings as $row) {
                fputcsv($handle, [
                    $row->staff_id,
                    $row->staff_type,
                    number_format($row->average_rating, 2),
                    $row->total_ratings
                ]);
            }
            fclose($handle);
        };

        return new StreamedResponse($callback, 200, $headers);
    }
}
