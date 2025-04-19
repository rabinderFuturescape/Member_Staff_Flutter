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
        Schema::create('staff_ratings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('member_id')->constrained()->onDelete('cascade');
            $table->unsignedBigInteger('staff_id');
            $table->enum('staff_type', ['society', 'member']);
            $table->unsignedTinyInteger('rating')->comment('Rating from 1 to 5');
            $table->text('feedback')->nullable();
            $table->timestamps();
            
            // Add a unique constraint to prevent multiple ratings from the same member for the same staff in the same month
            $table->unique(['member_id', 'staff_id', 'staff_type', DB::raw('YEAR(created_at)'), DB::raw('MONTH(created_at)')]);
            
            // Add indexes for better performance
            $table->index(['staff_id', 'staff_type']);
            $table->index('rating');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('staff_ratings');
    }
};
