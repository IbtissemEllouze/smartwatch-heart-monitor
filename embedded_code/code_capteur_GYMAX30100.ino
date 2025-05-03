#include <Wire.h>
#include "MAX30100_PulseOximeter.h"

// Intervalle de rapport
#define REPORTING_PERIOD_MS 500

PulseOximeter pox;
uint32_t tsLastReport = 0;

void onBeatDetected() {
  Serial.println("Beat Detected!");
}

void setup() {
  Serial.begin(115200); 
  Serial.print("Initializing pulse oximeter...");

  // Initialisation du capteur
  if (!pox.begin()) {
    Serial.println("FAILED");
    while (1); // Rester bloqué ici en cas d'échec d'initialisation
  } else {
    Serial.println("SUCCESS");
  }
  
  pox.setIRLedCurrent(MAX30100_LED_CURR_14_2MA);

  // Détection des battements
  pox.setOnBeatDetectedCallback(onBeatDetected);
}

void loop() {
  // Mise à jour des données du capteur
  pox.update();

  if (millis() - tsLastReport > REPORTING_PERIOD_MS) {
    int spo2 = pox.getSpO2();
    int bpm = pox.getHeartRate();
    
    // Affichage des données dans le moniteur série
    Serial.print("Heart rate: ");
    Serial.print(bpm);
    Serial.print(" bpm / SpO2: ");
    Serial.print(spo2);
    Serial.println(" %");
    
    tsLastReport = millis();
  }
}
