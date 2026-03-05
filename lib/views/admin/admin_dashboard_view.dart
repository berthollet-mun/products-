import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:product/controllers/dashboard_controller.dart';
import 'package:product/routes/app_routes.dart';
import 'package:product/theme/app_theme.dart';
import 'package:product/views/common/role_guard.dart';
import 'package:product/views/dashboard/widgets/admin_bottom_navigation.dart';
import 'package:product/views/dashboard/widgets/dashboard_header.dart';
import 'package:product/views/dashboard/widgets/dashboard_stat_card.dart';
import 'package:product/views/dashboard/widgets/stock_alert_tile.dart';

class AdminDashboardView extends GetView<DashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = Get.width;
    final horizontalPadding = (width * 0.05).clamp(14.0, 24.0);
    final sectionGap = (Get.height * 0.018).clamp(10.0, 18.0);
    final maxBodyWidth = math.min(width, 700.0);

    return RoleGuard(
      requiredRole: 'admin',
      child: Scaffold(
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              0,
              horizontalPadding,
              (Get.height * 0.008).clamp(4.0, 10.0),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxBodyWidth),
              child: AdminBottomNavigation(
                onAddTap: () => Get.toNamed(AppRoutes.adminEntryForm),
                onDashboardTap: () => Get.offNamed(AppRoutes.adminDashboard),
                onProductsTap: () => Get.toNamed(AppRoutes.adminProductList),
                onOutputsTap: () => Get.toNamed(AppRoutes.adminOutputList),
                onUsersTap: () => Get.toNamed(AppRoutes.adminUserList),
              ),
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.pageGradient),
          child: SafeArea(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return RefreshIndicator(
                onRefresh: controller.loadDashboardData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxBodyWidth),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          sectionGap,
                          horizontalPadding,
                          (Get.height * 0.09).clamp(70.0, 92.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            DashboardHeader(
                              greeting: 'Mathe Joieinet!',
                              name: controller.userName,
                              accentColor: const Color(0xFF151B2B),
                            ),
                            SizedBox(height: sectionGap),
                            _adminMainCard(),
                            SizedBox(height: sectionGap),
                            _statsGrid(),
                            SizedBox(height: sectionGap),
                            _stockAlertSection(),
                            SizedBox(height: sectionGap),
                            _activitySection(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _adminMainCard() {
    final compact = Get.width < 360;
    final titleSize = compact ? 16.0 : 18.0;
    final amountSize = compact ? 26.0 : 32.0;

    return AspectRatio(
      aspectRatio: compact ? 1.45 : 1.72,
      child: Container(
        padding: EdgeInsets.all((Get.width * 0.04).clamp(12.0, 20.0)),
        decoration: AppTheme.glassCard(gradient: AppTheme.adminGradient),
        child: Stack(
          children: [
            Positioned.fill(
              left: Get.width * 0.34,
              child: Padding(
                padding: EdgeInsets.only(top: Get.height * 0.04),
                child: Obx(
                  () => LineChart(
                    LineChartData(
                      minY: 0,
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      lineTouchData: const LineTouchData(enabled: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(
                            controller.adminLineSeries.length,
                            (i) => FlSpot(
                              i.toDouble(),
                              controller.adminLineSeries[i],
                            ),
                          ),
                          isCurved: true,
                          barWidth: 2.5,
                          color: Colors.white,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.25),
                                Colors.white.withValues(alpha: 0.02),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tableau de bord Admin',
                      style: GoogleFonts.poppins(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: (Get.height * 0.01).clamp(6.0, 12.0)),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '\u20AC${controller.adminAmount.value.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontSize: amountSize,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: (Get.height * 0.006).clamp(4.0, 10.0)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: (Get.width * 0.03).clamp(10.0, 14.0),
                      vertical: (Get.height * 0.006).clamp(3.0, 6.0),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '+ ${controller.incomingToday.value * 24} cette semaine',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statsGrid() {
    final width = Get.width;
    const ratio = 1.2;

    return Obx(
      () => GridView.count(
        crossAxisCount: 2,
        childAspectRatio: ratio,
        crossAxisSpacing: (width * 0.025).clamp(8.0, 14.0),
        mainAxisSpacing: (width * 0.025).clamp(8.0, 14.0),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          DashboardStatCard(
            title: 'Total Produits',
            value: '${controller.totalProducts.value}',
            icon: Icons.inventory_2_rounded,
            iconColor: const Color(0xFF2AA79D),
          ),
          DashboardStatCard(
            title: 'Entrees',
            value: '${controller.incomingToday.value}',
            subtitle: 'Aujourd\'hui',
            icon: Icons.call_received_rounded,
            iconColor: const Color(0xFF3FA4E7),
          ),
          DashboardStatCard(
            title: 'Sorties',
            value: '${controller.outgoingToday.value}',
            subtitle: 'Aujourd\'hui',
            icon: Icons.call_made_rounded,
            iconColor: const Color(0xFFEA8E34),
          ),
          DashboardStatCard(
            title: 'Ruptures',
            value: '${controller.lowStockCount.value}',
            subtitle: 'Alertes stock',
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFF2994A),
          ),
        ],
      ),
    );
  }

  Widget _stockAlertSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Produits en Rupture',
                  style: GoogleFonts.poppins(
                    fontSize: (Get.width * 0.05).clamp(18.0, 22.0),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF161E30),
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.adminProductList),
              child: Text(
                'Alertes',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF697089),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: (Get.height * 0.008).clamp(6.0, 10.0)),
        Obx(() {
          if (controller.lowStockProducts.isEmpty) {
            return Container(
              padding: EdgeInsets.all((Get.width * 0.04).clamp(12.0, 16.0)),
              decoration: AppTheme.glassCard(),
              child: Text(
                'Aucune alerte de stock actuellement.',
                style: GoogleFonts.poppins(color: const Color(0xFF6C748C)),
              ),
            );
          }

          return Column(
            children: controller.lowStockProducts
                .map(
                  (product) => StockAlertTile(
                    productName: product.name,
                    quantity: product.quantity,
                  ),
                )
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _activitySection() {
    final chartSize = (Get.width * 0.45).clamp(150.0, 210.0);

    return Obx(
      () => Container(
        padding: EdgeInsets.all((Get.width * 0.045).clamp(12.0, 18.0)),
        decoration: AppTheme.glassCard(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'Dernieres Activites',
                style: GoogleFonts.poppins(
                  fontSize: (Get.width * 0.05).clamp(18.0, 20.0),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF161E30),
                ),
              ),
            ),
            SizedBox(height: (Get.height * 0.014).clamp(8.0, 14.0)),
            Row(
              children: [
                Expanded(
                  child: _flowPill(
                    title: 'Entrees',
                    value: controller.incomingToday.value,
                    color: const Color(0xFF40C7BE),
                  ),
                ),
                SizedBox(width: (Get.width * 0.025).clamp(8.0, 12.0)),
                Expanded(
                  child: _flowPill(
                    title: 'Sorties',
                    value: controller.outgoingToday.value,
                    color: const Color(0xFFF2AE3F),
                  ),
                ),
              ],
            ),
            SizedBox(height: (Get.height * 0.02).clamp(12.0, 20.0)),
            Center(
              child: SizedBox(
                width: chartSize,
                height: chartSize,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: chartSize * 0.28,
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(
                        color: const Color(0xFF31C1DE),
                        value: (controller.semiCirclePercent.value * 100)
                            .clamp(0, 100),
                        radius: chartSize * 0.18,
                        title: '',
                      ),
                      PieChartSectionData(
                        color: const Color(0xFFF2AE3F),
                        value: ((1 - controller.semiCirclePercent.value) * 100)
                            .clamp(0, 100),
                        radius: chartSize * 0.18,
                        title: '',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: (Get.height * 0.008).clamp(4.0, 10.0)),
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${(controller.semiCirclePercent.value * 100).toStringAsFixed(1)}% Sorties',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF111A2B),
                    fontWeight: FontWeight.w700,
                    fontSize: (Get.width * 0.048).clamp(15.0, 18.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _flowPill({
    required String title,
    required int value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (Get.width * 0.03).clamp(10.0, 14.0),
        vertical: (Get.height * 0.01).clamp(8.0, 12.0),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius - 6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '$title : $value',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF182033),
              ),
            ),
          ),
          SizedBox(height: (Get.height * 0.004).clamp(2.0, 8.0)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: (Get.width * 0.022).clamp(8.0, 10.0),
              vertical: (Get.height * 0.003).clamp(2.0, 4.0),
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(999),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${(value * 0.1).toStringAsFixed(1)}%',
                style: GoogleFonts.poppins(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
