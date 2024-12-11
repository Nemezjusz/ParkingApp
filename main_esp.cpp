#include <ArduinoJson.h>
#include <FastLED.h>
#include <HTTPClient.h>
#include <WiFi.h>

// WiFi credentials
const char* ssid = "I_LOVE_802_11";
const char* password = "kotek-rjtek";

// API Endpoints
const char* updateEndpoint = "https://pilarz.dev/update_status
";

// LED configuration
#define NUM_LEDS 1
#define DATA_PIN 0
CRGB leds[NUM_LEDS];

// HC-SR04 pin configuration
const int TRIG_PIN = 25;
const int ECHO_PIN = 14;

// Parking spot information
// const char* parkingSpotID = "6744d6c861bab897cd88e6f2"; // A1
const char* parkingSpotID = "6744d6ca102e53aee7ce8791";  // A3
const char* prettyID = "A1";  // Replace with your pretty ID

// Constants
const int DISTANCE_THRESHOLD = 10;  // Distance in cm to detect a car
const long UPDATE_INTERVAL = 2000;
const int BLINK_INTERVAL = 500;  // LED blink interval in milliseconds
const int HTTP_TIMEOUT = 5000;   // HTTP timeout in milliseconds

// Global variables
unsigned long lastUpdateTime = 0;
unsigned long lastBlinkTime = 0;

bool blinkState = false;
bool carDetected = false;
String currentLedState = "green";  // Default state

void setLedColor(String color) {
    CRGB ledColor;

    if (color == "red" || color == "blink_red") {
        ledColor = CRGB::Red;
    } else if (color == "green") {
        ledColor = CRGB::Green;
    } else if (color == "blue") {
        ledColor = CRGB::Blue;
    } else if (color == "orange") {
        ledColor = CRGB::Orange;
    } else if (color == "yellow") {
        ledColor = CRGB::Yellow;
    } else {
        ledColor = CRGB::Black;  // LED off
    }

    leds[0] = ledColor;
    FastLED.show();
}

void handleBlinkingRed() {
    if (millis() - lastBlinkTime >= BLINK_INTERVAL) {
        blinkState = !blinkState;
        leds[0] = blinkState ? CRGB::Red : CRGB::Black;
        FastLED.show();
        lastBlinkTime = millis();
    }
}

// Function to measure distance using HC-SR04
float getDistance() {
    digitalWrite(TRIG_PIN, LOW);
    delayMicroseconds(2);
    digitalWrite(TRIG_PIN, HIGH);
    delayMicroseconds(10);
    digitalWrite(TRIG_PIN, LOW);

    long duration = pulseIn(ECHO_PIN, HIGH);
    float distance = (duration * 0.034) / 2;  // Convert to cm
    return distance;
}

// Send parking status to the server
void updateParkingStatus(bool occupied) {
    if (WiFi.status() != WL_CONNECTED) {
        currentLedState = occupied ? "red" : "green";
        return;
    }

    HTTPClient http;
    http.begin(updateEndpoint);
    http.addHeader("Content-Type", "application/json");

    // Create JSON payload
    JsonDocument docSend;
    docSend["parking_spot_id"] = parkingSpotID;
    docSend["status"] = occupied ? "occupied" : "free";
    docSend["pretty_id"] = prettyID;

    String payload;
    serializeJson(docSend, payload);
    int httpResponseCode = http.POST(payload);
    Serial.println("Payload: " + payload);

    if (httpResponseCode != 200) {
        Serial.println("Failed to update status");
        Serial.print("HTTP Response Code:");
        Serial.println(httpResponseCode);
        return;
    }
    Serial.println("Status updated successfully");

    String response = http.getString();
    JsonDocument doc;
    deserializeJson(doc, response);
    JsonObject spot = doc.as<JsonObject>();
    String newLedState = spot["color"].as<String>();
    newLedState.toLowerCase();
    Serial.println("color: " + newLedState);
    if (newLedState != currentLedState) {
        currentLedState = newLedState;
        Serial.println("New LED state: " + currentLedState);
    }
    Serial.println("LED state: " + currentLedState);

    http.end();
}

void setup() {
    // Initialize Serial Monitor
    Serial.begin(115200);

    FastLED.addLeds<NEOPIXEL, DATA_PIN>(leds, NUM_LEDS);
    FastLED.setBrightness(50);  // Set to 50% brightness

    pinMode(TRIG_PIN, OUTPUT);
    pinMode(ECHO_PIN, INPUT);

    // Connect to WiFi
    WiFi.begin(ssid, password);
    delay(1000);
}

void loop() {
    // Measure distance
    float distance = getDistance();
    bool currentCarDetected = distance < DISTANCE_THRESHOLD;
    // Debug output
    Serial.printf("Distance: %.2f cm, Car %s\n", distance,
                  currentCarDetected ? "Detected" : "Not Detected");

    // Update server when car detection state changes or periodically
    if (currentCarDetected != carDetected ||
        millis() - lastUpdateTime >= UPDATE_INTERVAL) {
        carDetected = currentCarDetected;
        updateParkingStatus(carDetected);
        lastUpdateTime = millis();
    }

    if (currentLedState == "blink_red") {
        handleBlinkingRed();
    } else {
        setLedColor(currentLedState);
    }

    delay(100);
}
