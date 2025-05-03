# smartwatch-heart-monitor


Ce projet vise à concevoir et développer une smartwatch intelligente dédiée à la surveillance en temps réel de la santé cardiaque.  Le système utilise un capteur biométrique GY-MAX30100 connecté à une carte ESP32 pour mesurer en temps réel la fréquence cardiaque (BPM) et le taux de saturation en oxygène du sang (SpO2). Ces données sont envoyées chaque seconde vers Firebase Realtime Database, puis récupérées et affichées via une application mobile développée en Flutter. L'application permet non seulement de visualiser les données en temps réel, mais aussi d'afficher des courbes évolutives des paramètres cardiaques au fil du temps.

L'outil intègre également un modèle d'intelligence artificielle, mis en œuvre dans Python avec Anaconda, qui analyse les données collectées afin de détecter des anomalies telles que la tachycardie ou la bradycardie. Plusieurs modèles ont été testés, parmi lesquels les méthodes KNN, arbre de décision et SVM, avec le SVM choisi pour ses meilleures performances globales. Ce projet vise à offrir une solution portable, intelligente et évolutive pour la surveillance de la santé en temps réel, en particulier pour les personnes présentant des risques cardiaques.

Le système est conçu pour être évolutif et adaptable à diverses applications de santé, offrant une surveillance à distance des signes vitaux et une détection précoce des anomalies cardiaques.








