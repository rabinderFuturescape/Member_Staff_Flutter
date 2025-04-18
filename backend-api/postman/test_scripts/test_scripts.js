/**
 * Test scripts for the Member Staff API Postman collection.
 * These scripts are executed after the response is received.
 */

// Common tests for all requests
pm.test("Status code is 200 OK or 201 Created", function () {
    pm.expect(pm.response.code).to.be.oneOf([200, 201]);
});

pm.test("Response has the correct format", function () {
    const responseJson = pm.response.json();
    pm.expect(responseJson).to.be.an('object');
    pm.expect(responseJson).to.have.property('success');
});

pm.test("Response indicates success", function () {
    const responseJson = pm.response.json();
    pm.expect(responseJson.success).to.be.true;
});

// For the "Generate Test Token" request
if (pm.info.requestName === "Generate Test Token") {
    pm.test("Response contains a token", function () {
        const responseJson = pm.response.json();
        pm.expect(responseJson).to.have.property('token');
        pm.expect(responseJson.token).to.be.a('string');
    });

    // Set the token as an environment variable
    const responseJson = pm.response.json();
    pm.environment.set('auth_token', responseJson.token);
}

// For the "Verify Token" request
if (pm.info.requestName === "Verify Token") {
    pm.test("Token is valid", function () {
        const responseJson = pm.response.json();
        pm.expect(responseJson).to.have.property('data');
        pm.expect(responseJson.data).to.be.an('object');
        pm.expect(responseJson.data).to.have.property('member_id');
    });
}

// For the "Check Staff Mobile" request
if (pm.info.requestName === "Check Staff Mobile") {
    pm.test("Response indicates whether staff exists", function () {
        const responseJson = pm.response.json();
        pm.expect(responseJson).to.have.property('exists');
        
        if (responseJson.exists) {
            pm.expect(responseJson).to.have.property('verified');
            pm.expect(responseJson).to.have.property('staff_id');
            
            // Set the staff_id as an environment variable if it exists
            pm.environment.set('staff_id', responseJson.staff_id);
        }
    });
}

// For the "Send OTP" request
if (pm.info.requestName === "Send OTP") {
    pm.test("OTP sent successfully", function () {
        const responseJson = pm.response.json();
        pm.expect(responseJson).to.have.property('message');
        pm.expect(responseJson.message).to.include('OTP sent');
    });
}

// For the "Verify OTP" request
if (pm.info.requestName === "Verify OTP") {
    pm.test("OTP verified successfully", function () {
        const responseJson = pm.response.json();
        pm.expect(responseJson).to.have.property('message');
        pm.expect(responseJson.message).to.include('OTP verified');
    });
}

// For the "Create Staff" request
if (pm.info.requestName === "Create Staff") {
    pm.test("Staff created successfully", function () {
        const responseJson = pm.response.json();
        pm.expect(responseJson).to.have.property('message');
        pm.expect(responseJson.message).to.include('Staff created');
        pm.expect(responseJson).to.have.property('data');
        pm.expect(responseJson.data).to.be.an('object');
        pm.expect(responseJson.data).to.have.property('id');
        
        // Set the staff_id as an environment variable
        pm.environment.set('staff_id', responseJson.data.id);
    });
}

// For the "Get Staff" request
if (pm.info.requestName === "Get Staff") {
    pm.test("Staff details retrieved successfully", function () {
        const responseJson = pm.response.json();
        pm.expect(responseJson).to.have.property('data');
        pm.expect(responseJson.data).to.be.an('object');
        pm.expect(responseJson.data).to.have.property('id');
        pm.expect(responseJson.data.id).to.equal(pm.environment.get('staff_id'));
    });
}

// For the "Update Staff" request
if (pm.info.requestName === "Update Staff") {
    pm.test("Staff updated successfully", function () {
        const responseJson = pm.response.json();
        pm.expect(responseJson).to.have.property('message');
        pm.expect(responseJson.message).to.include('Staff updated');
        pm.expect(responseJson).to.have.property('data');
        pm.expect(responseJson.data).to.be.an('object');
        pm.expect(responseJson.data).to.have.property('id');
        pm.expect(responseJson.data.id).to.equal(pm.environment.get('staff_id'));
    });
}

// For the "Verify Staff Identity" request
if (pm.info.requestName === "Verify Staff Identity") {
    pm.test("Staff identity verified successfully", function () {
        const responseJson = pm.response.json();
        pm.expect(responseJson).to.have.property('message');
        pm.expect(responseJson.message).to.include('Staff verified');
        pm.expect(responseJson).to.have.property('data');
        pm.expect(responseJson.data).to.be.an('object');
        pm.expect(responseJson.data).to.have.property('id');
        pm.expect(responseJson.data.id).to.equal(pm.environment.get('staff_id'));
        pm.expect(responseJson.data).to.have.property('is_verified');
        pm.expect(responseJson.data.is_verified).to.be.true;
    });
}

// For the "Delete Staff" request
if (pm.info.requestName === "Delete Staff") {
    pm.test("Staff deleted successfully", function () {
        const responseJson = pm.response.json();
        pm.expect(responseJson).to.have.property('message');
        pm.expect(responseJson.message).to.include('Staff deleted');
    });
}

// For the "Get Staff Schedule" request
if (pm.info.requestName === "Get Staff Schedule") {
    pm.test("Staff schedule retrieved successfully", function () {
        const responseJson = pm.response.json();
        pm.expect(responseJson).to.have.property('data');
        pm.expect(responseJson.data).to.be.an('object');
        pm.expect(responseJson.data).to.have.property('staff');
        pm.expect(responseJson.data).to.have.property('time_slots');
        pm.expect(responseJson.data.time_slots).to.be.an('array');
    });
}

// For the "Add Time Slot" request
if (pm.info.requestName === "Add Time Slot") {
    pm.test("Time slot added successfully", function () {
        const responseJson = pm.response.json();
        pm.expect(responseJson).to.have.property('message');
        pm.expect(responseJson.message).to.include('Time slot added');
        pm.expect(responseJson).to.have.property('data');
        pm.expect(responseJson.data).to.be.an('object');
        pm.expect(responseJson.data).to.have.property('id');
        
        // Set the time_slot_id as an environment variable
        pm.environment.set('time_slot_id', responseJson.data.id);
    });
}

// For the "Update Time Slot" request
if (pm.info.requestName === "Update Time Slot") {
    pm.test("Time slot updated successfully", function () {
        const responseJson = pm.response.json();
        pm.expect(responseJson).to.have.property('message');
        pm.expect(responseJson.message).to.include('Time slot updated');
        pm.expect(responseJson).to.have.property('data');
        pm.expect(responseJson.data).to.be.an('object');
        pm.expect(responseJson.data).to.have.property('id');
        pm.expect(responseJson.data.id).to.equal(pm.environment.get('time_slot_id'));
    });
}

// For the "Remove Time Slot" request
if (pm.info.requestName === "Remove Time Slot") {
    pm.test("Time slot removed successfully", function () {
        const responseJson = pm.response.json();
        pm.expect(responseJson).to.have.property('message');
        pm.expect(responseJson.message).to.include('Time slot removed');
    });
}

// For the "Get Time Slots for Date" request
if (pm.info.requestName === "Get Time Slots for Date") {
    pm.test("Time slots for date retrieved successfully", function () {
        const responseJson = pm.response.json();
        pm.expect(responseJson).to.have.property('data');
        pm.expect(responseJson.data).to.be.an('array');
    });
}

// For the "Bulk Add Time Slots" request
if (pm.info.requestName === "Bulk Add Time Slots") {
    pm.test("Time slots added in bulk successfully", function () {
        const responseJson = pm.response.json();
        pm.expect(responseJson).to.have.property('message');
        pm.expect(responseJson.message).to.include('time slots added');
        pm.expect(responseJson).to.have.property('data');
        pm.expect(responseJson.data).to.be.an('object');
        pm.expect(responseJson.data).to.have.property('added_time_slots');
        pm.expect(responseJson.data.added_time_slots).to.be.an('array');
    });
}

// For the "Get Member Staff" request
if (pm.info.requestName === "Get Member Staff") {
    pm.test("Member staff retrieved successfully", function () {
        const responseJson = pm.response.json();
        pm.expect(responseJson).to.have.property('data');
        pm.expect(responseJson.data).to.be.an('array');
    });
}

// For the "Assign Staff to Member" request
if (pm.info.requestName === "Assign Staff to Member") {
    pm.test("Staff assigned to member successfully", function () {
        const responseJson = pm.response.json();
        pm.expect(responseJson).to.have.property('message');
        pm.expect(responseJson.message).to.include('Staff assigned');
        pm.expect(responseJson).to.have.property('data');
        pm.expect(responseJson.data).to.be.an('object');
        pm.expect(responseJson.data).to.have.property('id');
    });
}

// For the "Unassign Staff from Member" request
if (pm.info.requestName === "Unassign Staff from Member") {
    pm.test("Staff unassigned from member successfully", function () {
        const responseJson = pm.response.json();
        pm.expect(responseJson).to.have.property('message');
        pm.expect(responseJson.message).to.include('Staff unassigned');
    });
}

// For the "Get Company Staff" request
if (pm.info.requestName === "Get Company Staff") {
    pm.test("Company staff retrieved successfully", function () {
        const responseJson = pm.response.json();
        pm.expect(responseJson).to.have.property('data');
        pm.expect(responseJson.data).to.be.an('array');
    });
}

// For the "Search Staff" request
if (pm.info.requestName === "Search Staff") {
    pm.test("Staff search completed successfully", function () {
        const responseJson = pm.response.json();
        pm.expect(responseJson).to.have.property('data');
        pm.expect(responseJson.data).to.be.an('array');
    });
}
