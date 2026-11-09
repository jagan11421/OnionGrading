
import 'package:flutter/material.dart';
import '../services/metrics_service.dart';

class ModelMetricsScreen extends StatelessWidget {
  const ModelMetricsScreen({super.key});

  Widget metricCard(String title, dynamic value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${value ?? '--'}%',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Model Performance'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: MetricsService.getMetrics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final data = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              // Reopen the screen or use a stateful
              // implementation for refresh support.
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  data['model_name'] ?? 'Onion IQ Model',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Version: ${data['model_version']}',
                ),
                const SizedBox(height: 20),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.5,
                  children: [
                    metricCard('Precision', data['precision']),
                    metricCard('Recall', data['recall']),
                    metricCard('F1 Score', data['f1_score']),
                    metricCard('mAP@50', data['map50']),
                    metricCard('mAP@50-95', data['map50_95']),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
