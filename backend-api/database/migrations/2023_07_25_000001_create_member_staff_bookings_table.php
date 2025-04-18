<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('member_staff_bookings', function (Blueprint $table) {
            $table->id();
            $table->string('staff_id');
            $table->string('member_id');
            $table->string('unit_id');
            $table->string('company_id');
            $table->date('start_date');
            $table->date('end_date');
            $table->string('repeat_type');
            $table->text('notes')->nullable();
            $table->string('status')->default('pending');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('member_staff_bookings');
    }
};
