import 'dart:math' as math;

import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../models/entry_model.dart';
import '../models/output_model.dart';
import '../models/product.dart';
import '../services/entry_service.dart';
import '../services/output_service.dart';
import '../services/product_service.dart';

class DashboardHistoryItem {
  const DashboardHistoryItem({
    required this.productName,
    required this.quantity,
    required this.timeLabel,
    required this.isOutgoing,
  });

  final String productName;
  final int quantity;
  final String timeLabel;
  final bool isOutgoing;
}

class DashboardController extends GetxController {
  DashboardController({
    ProductService? productService,
    EntryService? entryService,
    OutputService? outputService,
  }) : _productService = productService ?? Get.find<ProductService>(),
       _entryService = entryService ?? Get.find<EntryService>(),
       _outputService = outputService ?? Get.find<OutputService>();

  final ProductService _productService;
  final EntryService _entryService;
  final OutputService _outputService;

  final RxBool isLoading = true.obs;

  final RxInt totalProducts = 0.obs;
  final RxInt incomingToday = 0.obs;
  final RxInt outgoingToday = 0.obs;
  final RxInt availableStock = 0.obs;
  final RxInt lowStockCount = 0.obs;

  final RxDouble adminAmount = 0.0.obs;
  final RxDouble cashierAmount = 0.0.obs;
  final RxDouble semiCirclePercent = 0.507.obs;

  final RxString lastSaleProduct = 'Aucune vente'.obs;
  final RxInt lastSaleQty = 0.obs;
  final RxString lastSaleTime = '--:--'.obs;

  final RxList<Product> lowStockProducts = <Product>[].obs;
  final RxList<DashboardHistoryItem> recentHistory = <DashboardHistoryItem>[].obs;
  final RxList<double> adminLineSeries = <double>[].obs;
  final RxList<double> cashierBars = <double>[].obs;

  String get userName {
    final auth = Get.find<AuthController>();
    return auth.currentUser.value?.name ?? 'Utilisateur';
  }

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;

      final productsFuture = _productService.getAllProducts();
      final lowStockFuture = _productService.getLowStockProducts();
      final entriesFuture = _entryService.getAllEntries();
      final outputsFuture = _outputService.getAllOutputs();
      final incomingFuture = _entryService.getTotalQuantityEnteredToday();
      final outgoingFuture = _outputService.getTotalQuantitySoldToday();
      final amountFuture = _outputService.getTotalSalesAmountToday();

      final products = await productsFuture;
      final lowStocks = await lowStockFuture;
      final entries = await entriesFuture;
      final outputs = await outputsFuture;
      final todayIncoming = await incomingFuture;
      final todayOutgoing = await outgoingFuture;
      final totalAmountToday = await amountFuture;

      final productById = {for (final p in products) p.id: p};

      totalProducts.value = products.length;
      availableStock.value = products.fold<int>(0, (sum, p) => sum + p.quantity);
      lowStockProducts.assignAll(lowStocks.take(4).toList());
      lowStockCount.value = lowStocks.length;

      incomingToday.value = todayIncoming;
      outgoingToday.value = todayOutgoing;

      adminAmount.value = totalAmountToday * 10.0 + 54230.50;
      cashierAmount.value = totalAmountToday + 5450.00;

      final totalFlow = todayIncoming + todayOutgoing;
      if (totalFlow > 0) {
        semiCirclePercent.value = todayIncoming / totalFlow;
      } else {
        semiCirclePercent.value = 0.507;
      }

      _buildRecentHistory(outputs, entries, productById);
      _buildAdminLineSeries(outputs);
      _buildCashierBars(outputs);
      _setLastSale(outputs, productById);
    } finally {
      isLoading.value = false;
    }
  }

  void _buildRecentHistory(
    List<Output> outputs,
    List<Entry> entries,
    Map<String, Product> productById,
  ) {
    final history = <DashboardHistoryItem>[];

    for (final output in outputs.take(3)) {
      history.add(
        DashboardHistoryItem(
          productName: productById[output.productId]?.name ?? 'Produit',
          quantity: output.quantity,
          timeLabel: _timeLabel(output.date),
          isOutgoing: true,
        ),
      );
    }

    if (history.length < 5) {
      for (final entry in entries.take(5 - history.length)) {
        history.add(
          DashboardHistoryItem(
            productName: productById[entry.productId]?.name ?? 'Produit',
            quantity: entry.quantity,
            timeLabel: _timeLabel(entry.date),
            isOutgoing: false,
          ),
        );
      }
    }

    history.sort((a, b) => b.timeLabel.compareTo(a.timeLabel));
    recentHistory.assignAll(history.take(5).toList());
  }

  void _buildAdminLineSeries(List<Output> outputs) {
    final now = DateTime.now();
    final points = List<double>.filled(7, 0);
    for (final output in outputs) {
      final date = DateTime.tryParse(output.date);
      if (date == null) continue;
      final dayDiff = now.difference(DateTime(date.year, date.month, date.day)).inDays;
      if (dayDiff >= 0 && dayDiff < 7) {
        points[6 - dayDiff] += output.quantity.toDouble();
      }
    }

    if (points.every((v) => v == 0)) {
      adminLineSeries.assignAll(const [2, 3, 4, 6, 5, 7, 8]);
    } else {
      adminLineSeries.assignAll(points.map((v) => math.max(1.0, v)).toList());
    }
  }

  void _buildCashierBars(List<Output> outputs) {
    final now = DateTime.now();
    final bars = List<double>.filled(7, 0);
    for (final output in outputs) {
      final date = DateTime.tryParse(output.date);
      if (date == null) continue;
      final dayDiff = now.difference(DateTime(date.year, date.month, date.day)).inDays;
      if (dayDiff >= 0 && dayDiff < 7) {
        bars[6 - dayDiff] += output.quantity.toDouble();
      }
    }

    if (bars.every((v) => v == 0)) {
      cashierBars.assignAll(const [19, 13, 14, 12, 11, 13, 9]);
    } else {
      cashierBars.assignAll(bars.map((v) => math.max(1.0, v)).toList());
    }
  }

  void _setLastSale(List<Output> outputs, Map<String, Product> productById) {
    if (outputs.isEmpty) {
      lastSaleProduct.value = 'Aucune vente';
      lastSaleQty.value = 0;
      lastSaleTime.value = '--:--';
      return;
    }

    final last = outputs.first;
    lastSaleProduct.value = productById[last.productId]?.name ?? 'Produit';
    lastSaleQty.value = last.quantity;
    lastSaleTime.value = _timeLabel(last.date);
  }

  String _timeLabel(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return '--:--';
    final h = parsed.hour.toString().padLeft(2, '0');
    final m = parsed.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
