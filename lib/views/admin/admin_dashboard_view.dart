import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:product/controllers/dashboard_controller.dart';
import 'package:product/routes/app_routes.dart';
import 'package:product/views/common/role_guard.dart';
import 'package:product/views/dashboard/widgets/admin_bottom_navigation.dart';
import 'package:product/views/dashboard/widgets/dashboard_header.dart';
import 'package:product/views/dashboard/widgets/dashboard_stat_card.dart';
import 'package:product/views/dashboard/widgets/stock_alert_tile.dart';

class AdminDashboardView extends GetView<DashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final contentWidth = size.width > 700 ? 540.0 : size.width;
    final gap = Get.height * 0.018;

    return RoleGuard(
      requiredRole: 'admin',
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
                          greeting: 'Mathe Joieinet!',
                          name: controller.userName,
                          accentColor: const Color(0xFF131A2A),
                        ),
                        SizedBox(height: gap),
                        _adminBalanceCard(context),
                        SizedBox(height: gap * 0.9),
                        _statsGrid(context),
                        SizedBox(height: gap),
                        _stockAlertSection(context),
                        SizedBox(height: gap),
                        _activityCard(),
                        SizedBox(height: gap * 0.9),
                        AdminBottomNavigation(
                          onAddTap: () => Get.toNamed(AppRoutes.adminEntryForm),
                          onDashboardTap: () =>
                              Get.offNamed(AppRoutes.adminDashboard),
                          onProductsTap: () =>
                              Get.toNamed(AppRoutes.adminProductList),
                          onOutputsTap: () =>
                              Get.toNamed(AppRoutes.adminOutputList),
                          onUsersTap: () =>
                              Get.toNamed(AppRoutes.adminUserList),
                        ),
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

  Widget _adminBalanceCard(BuildContext context) {
    final cardHeight = (Get.height * 0.24).clamp(160.0, 220.0);

    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF2D79E6), Color(0xFF0B47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 360;
              final titleSize = compact ? 18.0 : 27.0;
              final amountSize = compact ? 32.0 : 44.0;
              final chartLeftPadding = compact
                  ? constraints.maxWidth * 0.46
                  : 110.0;

              return Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(chartLeftPadding, 22, 8, 10),
                      child: Obx(
                        () => LineChart(
                          LineChartData(
                            minY: 0,
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
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
                                color: Colors.white.withValues(alpha: 0.9),
                                barWidth: 2.3,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.28),
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
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Obx(
                      () => Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              'Tableau de bord Admin',
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
                              '€${controller.adminAmount.value.toStringAsFixed(2)}',
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
                                '+ ${controller.incomingToday.value * 24} cette semaine',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
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

  Widget _statsGrid(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final ratio = width < 360 ? 0.92 : (width < 420 ? 1.02 : 1.18);

    return Obx(
      () => GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: ratio,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          DashboardStatCard(
            title: 'Total Produits',
            value: '${controller.totalProducts.value}',
            icon: Icons.inventory_2_rounded,
            iconColor: const Color(0xFF26A69A),
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

  Widget _stockAlertSection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 380;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (compact)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Produits en Rupture',
                      style: GoogleFonts.poppins(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF161E30),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.adminProductList),
                      child: Text(
                        'Alertes',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF697089),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Produits en Rupture',
                        style: GoogleFonts.poppins(
                          fontSize: 30,
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
            const SizedBox(height: 8),
            Obx(() {
              if (controller.lowStockProducts.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Aucune alerte de stock actuellement.',
                    style: GoogleFonts.poppins(color: const Color(0xFF6C748C)),
                  ),
                );
              }

              return Column(
                children: controller.lowStockProducts
                    .map(
                      (p) => StockAlertTile(
                        productName: p.name,
                        quantity: p.quantity,
                      ),
                    )
                    .toList(),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _activityCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'Dernieres Activites',
                style: GoogleFonts.poppins(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF161E30),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _flowCount(
                  'Entrees',
                  controller.incomingToday.value,
                  const Color(0xFF40C7BE),
                ),
                _flowCount(
                  'Sorties',
                  controller.outgoingToday.value,
                  const Color(0xFFF2AE3F),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: CircularPercentIndicator(
                radius: (Get.width * 0.28).clamp(84.0, 110.0),
                lineWidth: 18,
                percent: controller.semiCirclePercent.value.clamp(0.0, 1.0),
                arcType: ArcType.HALF,
                startAngle: 180,
                circularStrokeCap: CircularStrokeCap.round,
                backgroundColor: const Color(0xFFECEEF6),
                progressColor: const Color(0xFF31C1DE),
                center: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Text(
                    '${(controller.semiCirclePercent.value * 100).toStringAsFixed(1)}%',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111A2B),
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

  Widget _flowCount(String title, int value, Color badgeColor) {
    return Column(
      children: [
        Text(
          '$title: $value',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF182033),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '${(value * 0.1).toStringAsFixed(1)}%',
            style: GoogleFonts.poppins(
              color: badgeColor,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
