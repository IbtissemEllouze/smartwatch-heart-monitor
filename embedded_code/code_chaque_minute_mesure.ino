#include <math.h>


// WiFi
#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#define WIFI_SSID "TUNETD10F4F"
#define WIFI_PASSWORD "6CF2A9C9F8"


// Firebase
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"
#define API_KEY "AIzaSyBIo4KOLupfr-WKX8l8ZFe99KPWS5y6mr4"
#define DATABASE_URL "https://test-flutter-proj-650ef-default-rtdb.firebaseio.com/"


FirebaseData FirebaseData;
FirebaseAuth auth;
FirebaseConfig config;
TaskHandle_t PostToFirebase;
bool signupOK = false;


// Capteur MAX30100
#include <Wire.h>
#include "MAX30100_PulseOximeter.h"
#define POX_REPORTING_PERIOD_MS  1000


PulseOximeter pox;
TaskHandle_t GetReadings;
uint8_t _spo2;
uint8_t _heartRate;


uint32_t poxLastReport = 0;
unsigned long lastUpdate = 0;
const unsigned long interval = 60000; // 1 minute (60000 ms)


void setup() {
 Serial.begin(115200);


 InitializeWifi();
 SignUpToFirebase();
 InitializePOX();


 xTaskCreatePinnedToCore(SensorReadings, "GetReadings", 1724, NULL, 0, &GetReadings, 0);
 xTaskCreatePinnedToCore(SendReadingsToFirebase, "PostToFirebase", 6268, NULL, 0, &PostToFirebase, 1);
}


void SensorReadings(void * parameter) {
 for (;;) {
   pox.update();


   if (millis() - poxLastReport > POX_REPORTING_PERIOD_MS) {
     _heartRate = round(pox.getHeartRate());
     _spo2 = round(pox.getSpO2());


     Serial.print("Heart rate: ");
     Serial.print(_heartRate);
     Serial.print(" bpm / SpO2: ");
     Serial.print(_spo2);
     Serial.println(" %");


     poxLastReport = millis();
   }
   vTaskDelay(10 / portTICK_PERIOD_MS); // Pause pour éviter surcharge CPU
 }
}


void SendReadingsToFirebase(void * parameter) {
  static unsigned long lastUpdate = 0;  // Variable pour suivre le dernier envoi
  const unsigned long interval = 1000;   // Intervalle de 1 seconde (1000 millisecondes)
  
  for (;;) {
    if (Firebase.ready() && signupOK) {
      // Si 1 seconde est écoulée
      if (millis() - lastUpdate >= interval) {
        lastUpdate = millis(); // Met à jour le temps du dernier envoi

        // Convertir les données en JSON et les envoyer à Firebase
        String timestamp = String(millis());
        String path = "/sensor_data/" + timestamp;

        FirebaseJson json;
        // Ajouter la dernière valeur lue de BPM et SpO2
        json.set("bpm", _heartRate);
        json.set("spo2", _spo2);

        // Envoyer les données à Firebase
        if (Firebase.RTDB.setJSON(&FirebaseData, path, &json)) {
          Serial.println("✅ Données envoyées à Firebase: " + path);
        } else {
          Serial.println("❌ Échec d'envoi: " + FirebaseData.errorReason());
        }
      }
    }
    vTaskDelay(1000 / portTICK_PERIOD_MS); // Pause pour éviter surcharge CPU
  }
}


void InitializeWifi() {
 WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
 Serial.print("🔌 Connexion Wi-Fi");
 while (WiFi.status() != WL_CONNECTED) {
   Serial.print(".");
   delay(300);
 }
 Serial.println("\n✅ Connecté à Wi-Fi");
}


void SignUpToFirebase() {
 config.api_key = API_KEY;
 config.database_url = DATABASE_URL;


 if (Firebase.signUp(&config, &auth, "", "")) {
   Serial.println("✅ Firebase connecté");
   signupOK = true;
 } else {
   Serial.printf("❌ Erreur Firebase: %s\n", config.signer.signupError.message.c_str());
 }


 config.token_status_callback = tokenStatusCallback;
 Firebase.begin(&config, &auth);
 Firebase.reconnectWiFi(true);
}


void InitializePOX() {
 Serial.print("📡 Initialisation du capteur...");
 if (!pox.begin()) {
   Serial.println("❌ ÉCHEC");
   for (;;);
 } else {
   Serial.println("✅ SUCCÈS");
 }
}


void loop() {
 delay(1);
}

