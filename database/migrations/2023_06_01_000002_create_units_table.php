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
        Schema::create('units', function (Blueprint $table) {
            $table->id();
            $table->string('unit_number');
            $table->foreignId('building_id')->constrained()->onDelete('cascade');
            $table->string('floor');
            $table->unsignedInteger('area_sqft')->nullable();
            $table->string('type')->nullable(); // 1BHK, 2BHK, etc.
            $table->boolean('is_occupied')->default(false);
            $table->timestamps();
            
            // Unique constraint for unit number within a building
            $table->unique(['building_id', 'unit_number']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('units');
    }
};
