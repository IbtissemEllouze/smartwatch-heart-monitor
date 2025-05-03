#include <Wire.h>
#include <MAX30100_PulseOximeter.h>

PulseOximeter pox;

#define SAMPLE_INTERVAL 50 // Intervalle d'échantillonnage en ms (augmenter la valeur pour ralentir)
float t = 0.0; // Temps simulé pour l'ECG

// Fonction pour générer une courbe ECG simulée
float ecgWaveform(float t, float heartRate) {
  // Intervalle entre les battements cardiaques (en secondes)
  float beatInterval = 60.0 / heartRate; // Fréquence cardiaque en BPM convertie en secondes

  // Onde P (petite onde avant le pic)
  float pWave = 0.1 * sin(2 * PI * (t - 0.2)) + 0.1;
  
  // Complexe QRS (pic rapide)
  float qrsComplex = -1.2 * exp(-pow((t - 0.5) / 0.08, 2)) + 1.5 * exp(-pow((t - 0.55) / 0.05, 2));
  
  // Onde T (après le pic)
  float tWave = 0.5 * sin(2 * PI * (t - 0.8)) * exp(-pow((t - 0.8) / 0.1, 2));

  // Le signal ECG simulé
  return pWave + qrsComplex + tWave;
}

void setup() {
  Serial.begin(115200);  // Initialisation du port série
  Serial.println("Simulation ECG avec GY-MAX30100");

  // Initialisation du capteur MAX30100
  if (!pox.begin()) {
    Serial.println("Erreur d'initialisation du capteur MAX30100");
    while (1); // Boucle infinie si l'initialisation échoue
  }

  // Configuration du capteur
  pox.setOnBeatDetectedCallback(onBeatDetected);
  Serial.println("Capteur MAX30100 prêt !");
}

void loop() {
  pox.update(); // Mettre à jour les valeurs du capteur
  
  // Récupérer la fréquence cardiaque
  float heartRate = pox.getHeartRate();
  
  // Si la fréquence cardiaque est valide, générer et afficher l'ECG
  if (heartRate > 0) {
    // Réduire la vitesse de la courbe ECG
    if (heartRate > 100) heartRate = 60; // Réduire la fréquence cardiaque pour ralentir la courbe

    float ecgValue = ecgWaveform(t, heartRate);
    
    // Envoyer la valeur ECG au Serial Plotter
    Serial.println(ecgValue);

    // Augmenter le temps pour simuler le tracé ECG
    t += SAMPLE_INTERVAL / 1000.0;
    if (t >= (60.0 / heartRate)) { // Réinitialiser après un cycle complet
      t = 0.0;
    }
  }

  delay(SAMPLE_INTERVAL); // Attendre un petit moment avant de lire les données suivantes
}

// Fonction de retour d'appel pour les battements détectés
void onBeatDetected() {
  // Afficher un message lorsque le capteur détecte un battement cardiaque
  Serial.println("Battement détecté !");
}
