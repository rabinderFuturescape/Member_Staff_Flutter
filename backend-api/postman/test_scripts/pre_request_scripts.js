/**
 * Pre-request scripts for the Member Staff API Postman collection.
 * These scripts are executed before the request is sent.
 */

// Generate a UUID for use in requests
function generateUUID() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
        return v.toString(16);
    });
}

// Set default values for environment variables if they don't exist
if (!pm.environment.get('member_id')) {
    pm.environment.set('member_id', generateUUID());
}

if (!pm.environment.get('unit_id')) {
    pm.environment.set('unit_id', generateUUID());
}

if (!pm.environment.get('company_id')) {
    pm.environment.set('company_id', '8454');
}

// For the "Generate Test Token" request
if (pm.info.requestName === "Generate Test Token") {
    // No pre-request script needed
}

// For the "Create Staff" request
if (pm.info.requestName === "Create Staff") {
    // Generate a random mobile number for testing
    const randomMobile = '91' + Math.floor(Math.random() * 9000000000 + 1000000000);
    
    // Get the request body
    let requestBody = JSON.parse(pm.request.body.raw);
    
    // Update the mobile number
    requestBody.mobile = randomMobile;
    
    // Set the updated request body
    pm.request.body.raw = JSON.stringify(requestBody);
}

// For the "Add Time Slot" request
if (pm.info.requestName === "Add Time Slot") {
    // Set the date to today
    const today = new Date().toISOString().split('T')[0];
    
    // Get the request body
    let requestBody = JSON.parse(pm.request.body.raw);
    
    // Update the date
    requestBody.date = today;
    
    // Set the updated request body
    pm.request.body.raw = JSON.stringify(requestBody);
}

// For the "Bulk Add Time Slots" request
if (pm.info.requestName === "Bulk Add Time Slots") {
    // Set the date to today
    const today = new Date().toISOString().split('T')[0];
    
    // Get the request body
    let requestBody = JSON.parse(pm.request.body.raw);
    
    // Update the date for each time slot
    requestBody.time_slots.forEach(slot => {
        slot.date = today;
    });
    
    // Set the updated request body
    pm.request.body.raw = JSON.stringify(requestBody);
}

// For the "Get Time Slots for Date" request
if (pm.info.requestName === "Get Time Slots for Date") {
    // Set the date to today
    const today = new Date().toISOString().split('T')[0];
    
    // Update the URL
    pm.request.url.path[4] = today;
}

// For the "Get Staff Schedule" request
if (pm.info.requestName === "Get Staff Schedule") {
    // Set the start date to today
    const today = new Date().toISOString().split('T')[0];
    
    // Set the end date to 7 days from today
    const endDate = new Date();
    endDate.setDate(endDate.getDate() + 7);
    const endDateStr = endDate.toISOString().split('T')[0];
    
    // Update the query parameters
    pm.request.url.query.all().forEach(param => {
        if (param.key === 'start_date') {
            param.value = today;
        }
        if (param.key === 'end_date') {
            param.value = endDateStr;
        }
    });
}
