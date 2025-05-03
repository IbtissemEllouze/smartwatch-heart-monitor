import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';


class ChartPage extends StatelessWidget {
 final List<int> heartRateData;
 final List<int> spo2Data;


 ChartPage({required this.heartRateData, required this.spo2Data});


 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: Text("Graphiques BPM & SpO₂"),
       backgroundColor: Colors.pinkAccent,
     ),
     body: Padding(
       padding: const EdgeInsets.all(16.0),
       child: Column(
         children: [
           Text(
             "Évolution du rythme cardiaque (ECG-like)",
             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
           ),
           SizedBox(height: 10),
           _buildGraph(heartRateData, Colors.greenAccent, "BPM"),
           SizedBox(height: 20),
           Text(
             "Évolution de la saturation en oxygène",
             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
           ),
           SizedBox(height: 10),
           _buildGraph(spo2Data, Colors.blueAccent, "SpO₂"),
         ],
       ),
     ),
   );
 }


 Widget _buildGraph(List<int> data, Color color, String label) {
   return data.isNotEmpty
       ? SizedBox(
           height: 200,
           child: LineChart(
             LineChartData(
               gridData: FlGridData(show: false), // Pas de grille pour un effet plus propre
               titlesData: FlTitlesData(
                 leftTitles: AxisTitles(
                   sideTitles: SideTitles(
                     showTitles: true,
                     reservedSize: 40,
                     getTitlesWidget: (value, meta) {
                       return Text(
                         value.toInt().toString(),
                         style: TextStyle(fontSize: 12, color: color),
                       );
                     },
                   ),
                 ),
                 bottomTitles: AxisTitles(
                   sideTitles: SideTitles(
                     showTitles: true,
                     reservedSize: 20,
                     getTitlesWidget: (value, meta) {
                       return Text(value.toInt().toString(),
                           style: TextStyle(fontSize: 12, color: color));
                     },
                   ),
                 ),
               ),
               borderData: FlBorderData(
                 show: true,
                 border: Border.all(color: Colors.black, width: 1),
               ),
               lineBarsData: [
                 LineChartBarData(
                   spots: _getChartSpots(data),
                   isCurved: true, // Courbe légèrement arrondie
                   curveSmoothness: 0.2, // Ajustement pour ressembler à un ECG
                   barWidth: 3,
                   isStrokeCapRound: true,
                   belowBarData: BarAreaData(show: false),
                   dotData: FlDotData(show: false),
                   gradient: LinearGradient(
                     colors: [color.withOpacity(0.8), color.withOpacity(0.3)],
                   ),
                 ),
               ],
             ),
           ),
         )
       : Center(
           child: Text(
             "Aucune donnée disponible pour $label",
             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
           ),
         );
 }


 // Fonction pour convertir les données en points pour le graphique
 List<FlSpot> _getChartSpots(List<int> data) {
   return List.generate(
       data.length, (index) => FlSpot(index.toDouble(), data[index].toDouble()));
 }
}
