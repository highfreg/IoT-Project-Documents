#include <WiFi.h>
#include <HTTPClient.h>
#include <time.h>
#include "ACS712.h" // Include the ACS712 library

// Wi-Fi credentials
const char* ssid = "SDPRO";
const char* password = "homenergy123";
const char* serverUrl = "https://officially-polished-ray.ngrok-free.app/data";
const char* ntpServer = "pool.ntp.org";
const long  gmtOffset_sec = 10800;
const int   daylightOffset_sec = 0;

ACS712 ACS1(34, 3.3, 4095, 185); // Configure the first ACS712 sensor
ACS712 ACS2(35, 3.3, 4095, 185); // Configure the second ACS712 sensor

struct tm timeinfo;

void setup() {
  Serial.begin(115200);
  WiFi.begin(ssid, password);
  Serial.print("Connecting to Wi-Fi...");

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nConnected to Wi-Fi!");

  configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);

  // Calibrate sensors
  ACS1.autoMidPoint();
  Serial.print("ACS1 Calibrated MidPoint: ");
  Serial.println(ACS1.getMidPoint());

  ACS2.autoMidPoint();
  Serial.print("ACS2 Calibrated MidPoint: ");
  Serial.println(ACS2.getMidPoint());
}

void loop() {
  if (!getLocalTime(&timeinfo)) {
    Serial.println("Failed to obtain time");
    return;
  }

  // Measure and calculate current and power for sensor 1
  float current1 = 0.0;
  for (int i = 0; i < 100; i++) {
    current1 += ACS1.mA_AC_sampling();
    delay(10);
  }
  current1 = current1 / 100.0;
  current1 -= 01.0; // Offset adjustment
  if (current1 / 1000.0 < 0.1) current1 = 0.0; // Ignore low readings
  float power1 = current1 / 1000.0 * 230.0; // Assuming 230V mains voltage

  // Measure and calculate current and power for sensor 2
  //float current2 = 0.0;
  //for (int i = 0; i < 100; i++) {
    //current2 += ACS2.mA_AC_sampling();
    //delay(10);
  //}
  //current2 = current2 / 100.0;
  //current2 -= 01.0; // Offset adjustment
 // if (current2 / 1000.0 < 0.12) current2 = 0.0; // Ignore low readings
  //float power2 = current2 / 1000.0 * 230.0; // Assuming 230V mains voltage
  float current2 = 0.0; 
  float power2 = 0.0;
  // Format time
  char timeStr[64];
  strftime(timeStr, sizeof(timeStr), "%Y-%m-%d %H:%M:%S", &timeinfo);

  // Create JSON data
  String jsonData = "{";
  jsonData += "\"device1\": {";
  jsonData += "\"deviceId\":\"Plug-01\",";
  jsonData += "\"current\":" + String(current1 / 1000.0, 2) + ",";
  jsonData += "\"power\":" + String(power1, 2);
  jsonData += "},";
  jsonData += "\"device2\": {";
  jsonData += "\"deviceId\":\"Plug-02\",";
  jsonData += "\"current\":" + String(current2 / 1000.0, 2) + ",";
  jsonData += "\"power\":" + String(power2, 2);
  jsonData += "}";
  jsonData += "}";

  Serial.println("JSON Data: " + jsonData);

  // Send data to server
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    http.begin(serverUrl);
    http.addHeader("Content-Type", "application/json");

    int httpResponseCode = http.POST(jsonData);
    if (httpResponseCode > 0) {
      String response = http.getString();
      Serial.println("Server Response: " + response);
    } else {
      Serial.println("Error in sending POST request");
    }
    http.end();
  } else {
    Serial.println("Wi-Fi Disconnected");
  }

  delay(3000); // Adjust delay as needed
}