import 'package:flutter/material.dart';
import 'package:product/utils/responsive_helper.dart';

class SaleView extends StatefulWidget {
  const SaleView({super.key});

  @override
  State<SaleView> createState() => _SaleViewState();
}

class _SaleViewState extends State<SaleView> {
  // Mock data for demonstration
  final List<Map<String, dynamic>> _mockSales = [
    {
      'id': 'S001',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'amount': 156.50,
      'items': 3,
    },
    {
      'id': 'S002',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'amount': 89.99,
      'items': 2,
    },
    {
      'id': 'S003',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'amount': 245.00,
      'items': 5,
    },
  ];

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildSaleItem(Map<String, dynamic> sale) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : (isTablet ? 20 : 16),
        vertical: isDesktop ? 12 : (isTablet ? 10 : 8),
      ),
      padding: EdgeInsets.all(isDesktop ? 16 : (isTablet ? 14 : 12)),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(5),
        borderRadius: BorderRadius.circular(isDesktop ? 24 : 20),
        border: Border.all(color: Colors.white.withAlpha(5)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: isDesktop ? 60 : (isTablet ? 55 : 50),
          height: isDesktop ? 60 : (isTablet ? 55 : 50),
          decoration: BoxDecoration(
            color: Colors.green.withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.receipt_long,
              color: Colors.green,
              size: isDesktop ? 28 : (isTablet ? 26 : 24),
            ),
          ),
        ),
        title: Text(
          'Vente #${sale['id']}',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isDesktop ? 18 : (isTablet ? 17 : 16),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: isDesktop ? 6 : 4),
            Text(
              _formatDate(sale['date'] as DateTime),
              style: TextStyle(
                color: Colors.white54,
                fontSize: isDesktop ? 14 : (isTablet ? 13 : 12),
              ),
            ),
            Text(
              '${(sale['amount'] as double).toStringAsFixed(2)} € • ${sale['items']} articles',
              style: TextStyle(
                color: Colors.greenAccent,
                fontWeight: FontWeight.w600,
                fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.white54,
          size: isDesktop ? 28 : 24,
        ),
        onTap: () {
          // Navigate to sale detail when implemented
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Historique des Ventes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isDesktop ? 24 : 20,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveHelper.getMaxContentWidth(context),
          ),
          child: _mockSales.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: isDesktop ? 100 : (isTablet ? 80 : 64),
                        color: Colors.white24,
                      ),
                      SizedBox(height: isDesktop ? 24 : 16),
                      Text(
                        'Aucune vente enregistrée',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 16 : (isTablet ? 12 : 8),
                    vertical: isDesktop ? 16 : 8,
                  ),
                  itemCount: _mockSales.length,
                  itemBuilder: (context, index) =>
                      _buildSaleItem(_mockSales[index]),
                ),
        ),
      ),
    );
  }
}
