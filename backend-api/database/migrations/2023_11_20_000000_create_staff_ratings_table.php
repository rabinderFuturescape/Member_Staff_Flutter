<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateStaffRatingsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('staff_ratings', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('member_id');
            $table->unsignedBigInteger('staff_id');
            $table->enum('staff_type', ['society', 'member']);
            $table->integer('rating')->comment('1 to 5');
            $table->text('feedback')->nullable();
            $table->timestamps();
            
            // Indexes
            $table->index(['member_id', 'staff_id', 'staff_type']);
            $table->index(['staff_id', 'staff_type']);
            
            // Foreign keys
            $table->foreign('member_id')->references('id')->on('members')->onDelete('cascade');
            // Note: We don't add a foreign key for staff_id because it could reference different tables
            // depending on staff_type
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('staff_ratings');
    }
}
