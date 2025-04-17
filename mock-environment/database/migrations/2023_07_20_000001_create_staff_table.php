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
        Schema::create('staff', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('name');
            $table->string('mobile', 12)->unique();
            $table->string('email')->nullable();
            $table->enum('staff_scope', ['society', 'member']);
            $table->string('department')->nullable();
            $table->string('designation')->nullable();
            $table->uuid('society_id')->nullable();
            $table->uuid('unit_id')->nullable();
            $table->string('company_id')->nullable();
            $table->string('aadhaar_number', 12)->nullable();
            $table->text('residential_address')->nullable();
            $table->string('next_of_kin_name')->nullable();
            $table->string('next_of_kin_mobile', 12)->nullable();
            $table->string('photo_url')->nullable();
            $table->boolean('is_verified')->default(false);
            $table->timestamp('verified_at')->nullable();
            $table->uuid('verified_by_member_id')->nullable();
            $table->uuid('created_by')->nullable();
            $table->uuid('updated_by')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('staff');
    }
};
