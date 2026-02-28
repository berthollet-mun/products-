import 'package:flutter/material.dart';
import 'package:product/utils/responsive_helper.dart';

class SaleDetailView extends StatelessWidget {
  final Map<String, dynamic> sale;

  const SaleDetailView({super.key, required this.sale});

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final date = sale['date'] as DateTime? ?? DateTime.now();
    final amount = sale['amount'] as double? ?? 0.0;
    final items = sale['items'] as int? ?? 0;
    final id = sale['id'] as String? ?? 'N/A';

    return Scaffold(
      backgroundColor: const Color(0xFF1E0701),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E0701),
        elevation: 0,
        title: Text(
          'Détails de la Vente',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isDesktop ? 24 : 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveHelper.getMaxContentWidth(context),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 32 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isDesktop ? 32 : 24),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(isDesktop ? 24 : 20),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        color: Colors.green,
                        size: isDesktop ? 56 : (isTablet ? 48 : 40),
                      ),
                      SizedBox(height: isDesktop ? 20 : 16),
                      Text(
                        'Vente #$id',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isDesktop ? 28 : (isTablet ? 24 : 20),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isDesktop ? 12 : 8),
                      Text(
                        _formatDate(date),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isDesktop ? 40 : 32),

                // Amount Section
                Text(
                  'Montant total',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: isDesktop ? 16 : 14,
                  ),
                ),
                SizedBox(height: isDesktop ? 12 : 8),
                Text(
                  '${amount.toStringAsFixed(2)} €',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: isDesktop ? 48 : (isTablet ? 40 : 32),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isDesktop ? 40 : 32),

                // Info Cards
                Container(
                  padding: EdgeInsets.all(isDesktop ? 24 : 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.white70,
                        size: isDesktop ? 28 : 24,
                      ),
                      SizedBox(width: isDesktop ? 20 : 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Articles',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: isDesktop ? 14 : 12,
                              ),
                            ),
                            Text(
                              '$items articles',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isDesktop ? 18 : 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isDesktop ? 40 : 32),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  height: isDesktop ? 60 : 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          isDesktop ? 16 : 12,
                        ),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'FERMER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isDesktop ? 18 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
