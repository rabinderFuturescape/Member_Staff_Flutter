<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CommitteeDuesReportController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        if ($user->role !== 'committee') {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $building = $request->query('building');
        $wing = $request->query('wing');
        $floor = $request->query('floor');
        $min_due = $request->query('min_due');
        $max_due = $request->query('max_due');
        $month = $request->query('month');

        $query = DB::table('member_bills as mb')
            ->join('members as m', 'm.id', '=', 'mb.member_id')
            ->join('units as u', 'u.id', '=', 'm.unit_id')
            ->leftJoin('buildings as b', 'b.id', '=', 'u.building_id')
            ->leftJoin(DB::raw('(
                SELECT member_id, SUM(amount_paid) as total_paid, MAX(payment_date) as last_payment
                FROM payments
                GROUP BY member_id
            ) as p'), 'p.member_id', '=', 'mb.member_id')
            ->select([
                'u.unit_no',
                'u.floor',
                'b.name as wing',
                'm.name as member_name',
                'mb.bill_cycle',
                'mb.total_amount as bill_amount',
                DB::raw('IFNULL(p.total_paid, 0) as paid'),
                DB::raw('(mb.total_amount - IFNULL(p.total_paid, 0)) as due'),
                'mb.due_date',
                'p.last_payment'
            ])
            ->whereRaw('DATE_FORMAT(mb.bill_cycle, "%Y-%m") = ?', [$month]);

        if ($building) $query->where('b.name', $building);
        if ($wing) $query->where('b.name', $wing);
        if ($floor) $query->where('u.floor', $floor);
        if ($min_due) $query->havingRaw('due >= ?', [$min_due]);
        if ($max_due) $query->havingRaw('due <= ?', [$max_due]);

        return response()->json($query->paginate(25));
    }

    public function chartSummary(Request $request)
    {
        $month = $request->query('month');

        $summary = DB::table('member_bills as mb')
            ->join('members as m', 'm.id', '=', 'mb.member_id')
            ->join('units as u', 'u.id', '=', 'm.unit_id')
            ->leftJoin('buildings as b', 'b.id', '=', 'u.building_id')
            ->leftJoin(DB::raw('(
                SELECT member_id, SUM(amount_paid) as total_paid
                FROM payments
                GROUP BY member_id
            ) as p'), 'p.member_id', '=', 'mb.member_id')
            ->select([
                'b.name as label',
                DB::raw('SUM(mb.total_amount - IFNULL(p.total_paid, 0)) as total_due')
            ])
            ->whereRaw('DATE_FORMAT(mb.bill_cycle, "%Y-%m") = ?', [$month])
            ->groupBy('b.name')
            ->orderByDesc('total_due')
            ->get();

        return response()->json($summary);
    }
}
