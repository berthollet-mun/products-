import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:product/controllers/dashboard_controller.dart';
import 'package:product/routes/app_routes.dart';
import 'package:product/views/common/role_guard.dart';
import 'package:product/views/dashboard/widgets/dashboard_header.dart';
import 'package:product/views/dashboard/widgets/dashboard_history_tile.dart';
import 'package:product/views/dashboard/widgets/dashboard_stat_card.dart';

class CashierDashboardView extends GetView<DashboardController> {
  const CashierDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final contentWidth = size.width > 700 ? 540.0 : size.width;
    final gap = Get.height * 0.018;

    return RoleGuard(
      requiredRole: 'caissier',
      child: Scaffold(
        backgroundColor: const Color(0xFFEDEAF6),
        body: SafeArea(
          child: Center(
            child: SizedBox(
              width: contentWidth,
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                return RefreshIndicator(
                  onRefresh: controller.loadDashboardData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DashboardHeader(
                          greeting: 'Salut',
                          name: controller.userName,
                          accentColor: const Color(0xFF178B84),
                        ),
                        SizedBox(height: gap),
                        _cashierMainCard(),
                        SizedBox(height: gap * 0.9),
                        _quickStats(context),
                        SizedBox(height: gap),
                        _recentHistory(),
                        SizedBox(height: gap),
                        _weeklySalesChart(),
                        SizedBox(height: gap * 0.9),
                        _registerSaleButton(),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cashierMainCard() {
    final cardHeight = (Get.height * 0.24).clamp(160.0, 220.0);

    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF26A69A), Color(0xFF0E7A86)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 360;
              final titleSize = compact ? 17.0 : 24.0;
              final amountSize = compact ? 31.0 : 42.0;
              final barWidth = compact ? 96.0 : 120.0;

              return Stack(
                children: [
                  Positioned(
                    right: 14,
                    top: 20,
                    bottom: 14,
                    width: barWidth,
                    child: Obx(
                      () => BarChart(
                        BarChartData(
                          maxY:
                              (controller.cashierBars.isEmpty
                                  ? 20
                                  : controller.cashierBars.reduce(
                                      (a, b) => a > b ? a : b,
                                    )) +
                              6,
                          minY: 0,
                          alignment: BarChartAlignment.spaceAround,
                          barTouchData: BarTouchData(enabled: false),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          barGroups: List.generate(
                            controller.cashierBars.length.clamp(0, 6),
                            (index) => BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: controller.cashierBars[index],
                                  width: compact ? 8 : 10,
                                  borderRadius: BorderRadius.circular(8),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFB6FBF0), Colors.white],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Obx(
                      () => Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              'Tableau de bord Caissier',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: titleSize,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: compact ? 6 : 12),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '€${controller.cashierAmount.value.toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: amountSize,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(height: compact ? 6 : 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '+ ${controller.incomingToday.value + controller.outgoingToday.value} produits aujourd\'hui',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _quickStats(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final compact = width < 360;

    return Column(
      children: [
        Obx(
          () => Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.05),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Derniere Vente',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: const Color(0xFF7A8093),
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          controller.lastSaleProduct.value,
                          style: GoogleFonts.poppins(
                            fontSize: compact ? 16 : 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF171E31),
                          ),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${controller.lastSaleQty.value} unites - ${controller.lastSaleTime.value}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF5C6379),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.bar_chart_rounded,
                  color: Color(0xFF26A69A),
                  size: 42,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Obx(
          () => Row(
            children: compact
                ? [
                    Expanded(
                      child: DashboardStatCard(
                        title: 'Stock Disponible',
                        value: '${controller.availableStock.value}',
                        icon: Icons.stacked_bar_chart_rounded,
                        iconColor: const Color(0xFF26A69A),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DashboardStatCard(
                        title: 'Ruptures',
                        value: '${controller.lowStockCount.value}',
                        icon: Icons.warning_amber_rounded,
                        iconColor: const Color(0xFFEA8E34),
                      ),
                    ),
                  ]
                : [
                    Expanded(
                      child: DashboardStatCard(
                        title: 'Stock Disponible',
                        value: '${controller.availableStock.value}',
                        icon: Icons.stacked_bar_chart_rounded,
                        iconColor: const Color(0xFF26A69A),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DashboardStatCard(
                        title: 'Ruptures',
                        value: '${controller.lowStockCount.value}',
                        icon: Icons.warning_amber_rounded,
                        iconColor: const Color(0xFFEA8E34),
                      ),
                    ),
                  ],
          ),
        ),
      ],
    );
  }

  Widget _recentHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Historique Recent',
            style: GoogleFonts.poppins(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF161E30),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Obx(() {
          if (controller.recentHistory.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                'Aucune operation recente',
                style: GoogleFonts.poppins(color: const Color(0xFF7A8093)),
              ),
            );
          }

          return Column(
            children: controller.recentHistory
                .map(
                  (item) => DashboardHistoryTile(
                    productName: item.productName,
                    quantity: item.quantity,
                    timeLabel: item.timeLabel,
                    isOutgoing: item.isOutgoing,
                  ),
                )
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _weeklySalesChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ventes de la Semaine',
              style: GoogleFonts.poppins(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF161E30),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: Get.height * 0.2,
              child: BarChart(
                BarChartData(
                  maxY:
                      (controller.cashierBars.isEmpty
                          ? 20
                          : controller.cashierBars.reduce(
                              (a, b) => a > b ? a : b,
                            )) +
                      8,
                  minY: 0,
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(enabled: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: const Color(0xFFEDEEF4), strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const labels = [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun',
                          ];
                          final idx = value.toInt();
                          if (idx < 0 || idx >= labels.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              labels[idx],
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF70778D),
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(
                    controller.cashierBars.length.clamp(0, 7),
                    (i) => BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: controller.cashierBars[i],
                          width: 16,
                          borderRadius: BorderRadius.circular(8),
                          color: i == 0
                              ? const Color(0xFF23B7CC)
                              : const Color(0xFFC9D0DE),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _registerSaleButton() {
    return SizedBox(
      width: double.infinity,
      height: (Get.height * 0.07).clamp(50.0, 58.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF26A69A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        onPressed: () => Get.toNamed(AppRoutes.cashierOutputForm),
        child: Text(
          '+ Enregistrer Vente',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
