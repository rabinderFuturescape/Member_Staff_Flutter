<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;
use Carbon\Carbon;
use Symfony\Component\HttpFoundation\StreamedResponse;

class CommitteeDuesReportController extends Controller
{
    /**
     * Display a listing of all dues for committee members.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(Request $request)
    {
        // Check if user has committee role
        if (Gate::denies('view-committee-reports')) {
            return response()->json(['error' => 'Unauthorized. Committee access required.'], 403);
        }

        // Get query parameters for filtering
        $building = $request->input('building');
        $month = $request->input('month'); // Format: YYYY-MM
        $status = $request->input('status'); // unpaid, partial, overdue
        $search = $request->input('search'); // For member name or unit number
        $perPage = $request->input('per_page', 15);
        
        // Start building the query
        $query = DB::table('member_bills')
            ->join('members', 'member_bills.member_id', '=', 'members.id')
            ->join('units', 'members.unit_id', '=', 'units.id')
            ->join('buildings', 'units.building_id', '=', 'buildings.id')
            ->leftJoin(DB::raw('(
                SELECT 
                    bill_id, 
                    SUM(amount) as total_paid, 
                    MAX(payment_date) as last_payment_date
                FROM payments
                GROUP BY bill_id
            ) as payments'), 'member_bills.id', '=', 'payments.bill_id')
            ->select([
                'members.name as member_name',
                'units.unit_number',
                'buildings.name as building_name',
                'member_bills.bill_cycle',
                'member_bills.amount as bill_amount',
                DB::raw('COALESCE(payments.total_paid, 0) as amount_paid'),
                DB::raw('member_bills.amount - COALESCE(payments.total_paid, 0) as due_amount'),
                'member_bills.due_date',
                'payments.last_payment_date'
            ]);
        
        // Apply filters if provided
        if ($building) {
            $query->where('buildings.name', $building)
                  ->orWhere('buildings.code', $building);
        }
        
        if ($month) {
            // Parse the month (YYYY-MM) and filter by bill cycle
            $date = Carbon::createFromFormat('Y-m', $month);
            $query->whereMonth('member_bills.due_date', $date->month)
                  ->whereYear('member_bills.due_date', $date->year);
        }
        
        if ($status) {
            switch ($status) {
                case 'unpaid':
                    $query->whereNull('payments.total_paid')
                          ->orWhere('payments.total_paid', 0);
                    break;
                case 'partial':
                    $query->whereRaw('payments.total_paid > 0 AND payments.total_paid < member_bills.amount');
                    break;
                case 'overdue':
                    $query->whereRaw('(member_bills.amount - COALESCE(payments.total_paid, 0)) > 0')
                          ->where('member_bills.due_date', '<', now());
                    break;
            }
        }
        
        if ($search) {
            $query->where(function($q) use ($search) {
                $q->where('members.name', 'like', "%{$search}%")
                  ->orWhere('units.unit_number', 'like', "%{$search}%");
            });
        }
        
        // Only show records with due amount > 0
        $query->whereRaw('(member_bills.amount - COALESCE(payments.total_paid, 0)) > 0');
        
        // Order by due date (oldest first)
        $query->orderBy('member_bills.due_date', 'asc');
        
        // Get paginated results
        $duesReport = $query->paginate($perPage);
        
        return response()->json($duesReport);
    }

    /**
     * Export dues report as CSV.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Symfony\Component\HttpFoundation\StreamedResponse
     */
    public function exportCsv(Request $request)
    {
        // Check if user has committee role
        if (Gate::denies('view-committee-reports')) {
            return response()->json(['error' => 'Unauthorized. Committee access required.'], 403);
        }

        // Get query parameters for filtering (same as index method)
        $building = $request->input('building');
        $month = $request->input('month');
        $status = $request->input('status');
        $search = $request->input('search');
        
        // Build the same query as in index method but without pagination
        $query = DB::table('member_bills')
            ->join('members', 'member_bills.member_id', '=', 'members.id')
            ->join('units', 'members.unit_id', '=', 'units.id')
            ->join('buildings', 'units.building_id', '=', 'buildings.id')
            ->leftJoin(DB::raw('(
                SELECT 
                    bill_id, 
                    SUM(amount) as total_paid, 
                    MAX(payment_date) as last_payment_date
                FROM payments
                GROUP BY bill_id
            ) as payments'), 'member_bills.id', '=', 'payments.bill_id')
            ->select([
                'members.name as member_name',
                'units.unit_number',
                'buildings.name as building_name',
                'member_bills.bill_cycle',
                'member_bills.amount as bill_amount',
                DB::raw('COALESCE(payments.total_paid, 0) as amount_paid'),
                DB::raw('member_bills.amount - COALESCE(payments.total_paid, 0) as due_amount'),
                'member_bills.due_date',
                'payments.last_payment_date'
            ]);
        
        // Apply the same filters as in index method
        if ($building) {
            $query->where('buildings.name', $building)
                  ->orWhere('buildings.code', $building);
        }
        
        if ($month) {
            $date = Carbon::createFromFormat('Y-m', $month);
            $query->whereMonth('member_bills.due_date', $date->month)
                  ->whereYear('member_bills.due_date', $date->year);
        }
        
        if ($status) {
            switch ($status) {
                case 'unpaid':
                    $query->whereNull('payments.total_paid')
                          ->orWhere('payments.total_paid', 0);
                    break;
                case 'partial':
                    $query->whereRaw('payments.total_paid > 0 AND payments.total_paid < member_bills.amount');
                    break;
                case 'overdue':
                    $query->whereRaw('(member_bills.amount - COALESCE(payments.total_paid, 0)) > 0')
                          ->where('member_bills.due_date', '<', now());
                    break;
            }
        }
        
        if ($search) {
            $query->where(function($q) use ($search) {
                $q->where('members.name', 'like', "%{$search}%")
                  ->orWhere('units.unit_number', 'like', "%{$search}%");
            });
        }
        
        // Only show records with due amount > 0
        $query->whereRaw('(member_bills.amount - COALESCE(payments.total_paid, 0)) > 0');
        
        // Order by due date (oldest first)
        $query->orderBy('member_bills.due_date', 'asc');
        
        // Get all results for CSV export
        $duesReport = $query->get();
        
        // Generate filename with current date
        $filename = 'dues_report_' . now()->format('Y-m-d') . '.csv';
        
        // Set headers for CSV download
        $headers = [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => 'attachment; filename="' . $filename . '"',
            'Pragma' => 'no-cache',
            'Cache-Control' => 'must-revalidate, post-check=0, pre-check=0',
            'Expires' => '0',
        ];
        
        // Create a callback function that will be used to stream the CSV
        $callback = function() use ($duesReport) {
            $file = fopen('php://output', 'w');
            
            // Add CSV header row
            fputcsv($file, [
                'Member Name',
                'Unit Number',
                'Building',
                'Bill Cycle',
                'Bill Amount',
                'Amount Paid',
                'Due Amount',
                'Due Date',
                'Last Payment Date'
            ]);
            
            // Add data rows
            foreach ($duesReport as $row) {
                fputcsv($file, [
                    $row->member_name,
                    $row->unit_number,
                    $row->building_name,
                    $row->bill_cycle,
                    $row->bill_amount,
                    $row->amount_paid,
                    $row->due_amount,
                    $row->due_date,
                    $row->last_payment_date ?? 'No payment received'
                ]);
            }
            
            fclose($file);
        };
        
        // Return the streamed response
        return new StreamedResponse($callback, 200, $headers);
    }
}
