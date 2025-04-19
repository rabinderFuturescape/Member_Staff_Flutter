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
        Schema::create('feature_requests', function (Blueprint $table) {
            $table->id();
            $table->string('feature_title');
            $table->text('description')->nullable();
            $table->integer('votes')->default(1);
            $table->unsignedBigInteger('created_by')->nullable();
            $table->timestamps();
            
            // Add index for faster searches
            $table->index('feature_title');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('feature_requests');
    }
};
