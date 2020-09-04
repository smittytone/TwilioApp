// Load Electric Imp's Twilio library
#require "Twilio.class.nut:1.0"

// GLOBALS
twilio <- null;
target <- null;

// Import code setting up Twilio (requires Squinter) or uncomment and complete code below
#import "~/OneDrive/Programming/impClock/twilio.nut"
//twilio = Twilio("<ACCOUNT_SID>", "<AUTH_TOKEN", "<TWILIO_PHONE_NUMBER>");


// Register the handler for incoming HTTP requests
http.onrequest(function(request, response) {
    local path = request.path.tolower();
    if (path == "/twilio" || path == "/twilio/") {
        // Twilio request handler
        local message = "OK";
        try {
            local data = http.urldecode(request.body);
            server.log("SMS received: " + data.Body);
            device.send("show.sms", data.Body);
        } catch(ex) {
            message = "Something went horribly wrong: " + ex;
        }

        // Get the library to respond to Twilio
        twilio.respond(response, message);
    } else {
        // Default request handler
        response.send(200, "OK");
    }
});

// Trigger a test message
imp.wakeup(10, function() {
    server.log("Sending test SMS to device...");
    device.send("show.sms", "This is a TEST message");
});