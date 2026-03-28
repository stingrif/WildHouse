import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({super.key});

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  final _lengthCtrl  = TextEditingController();
  final _widthCtrl   = TextEditingController();
  
  bool _includeInstall = true;
  bool _includeVat     = true;
  bool _tokenDiscount  = false;
  bool _isParsingPdf   = false; 
  String? _parsedPdfLog;

  final List<Map<String, dynamic>> _catalogItems = [
    {'name': 'Дуб Нордик (Паркет)', 'price': 85.0},
    {'name': 'Орех Премиум (Паркет)', 'price': 120.0},
    {'name': 'Графит (Стеновые панели)', 'price': 90.0},
    {'name': 'Белый матовый (Потолок)', 'price': 55.0},
    {'name': 'Электрический (Подогрев)', 'price': 150.0},
  ];
  late Map<String, dynamic> _selectedItem = _catalogItems.first;

  static const double _installPriceSmall = 700;
  static const double _installPriceLarge = 1000;
  static const double _vatRate      = 0.18;
  static const double _tokenDisc    = 0.15;
  static const double _waste        = 0.10; 

  double get _area {
    final l = double.tryParse(_lengthCtrl.text) ?? 0;
    final w = double.tryParse(_widthCtrl.text) ?? 0;
    return l * w;
  }

  double get _areaWithWaste => _area * (1 + _waste);
  double get _materialCost => _areaWithWaste * (_selectedItem['price'] as double);

  double get _installCost {
    if (!_includeInstall) return 0;
    return _area <= 13 ? _installPriceSmall : _installPriceLarge;
  }

  double get _subtotal => _materialCost + _installCost;
  double get _discount => _tokenDiscount ? _subtotal * _tokenDisc : 0;
  double get _vat => _includeVat ? (_subtotal - _discount) * _vatRate : 0;
  double get _total => _subtotal - _discount + _vat;

  void _simulatePdfUpload() async {
    setState(() { _isParsingPdf = true; _parsedPdfLog = 'Loading...'; });
    
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isParsingPdf = false;
      _lengthCtrl.text = '6.0';
      _widthCtrl.text = '4.5';
      _parsedPdfLog = 'План успешо распознан! [ru, he]\nШирина: 4.5м, Длина: 6.0м';
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_parsedPdfLog!), backgroundColor: AppColors.moss, duration: const Duration(seconds: 4))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context)!;
    final hasArea = _area > 0;
    
    final currencyType = ref.watch(currencyProvider);
    final currencyFormatter = ref.read(currencyProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.calculatorTitle),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: AppColors.walnut, size: 20),
            onPressed: () {
              final currentLabel = ref.read(localeProvider).languageCode;
              final next = currentLabel == 'ru' ? 'en' : (currentLabel == 'en' ? 'he' : 'ru');
              ref.read(localeProvider.notifier).setLocale(Locale(next));
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.currency_exchange, color: AppColors.walnut, size: 18),
            label: Text(currencyType == AppCurrency.ils ? '₪ ILS' : '\$ USD', style: const TextStyle(color: AppColors.walnut)),
            onPressed: () => ref.read(currencyProvider.notifier).toggle(),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.oakLight, foregroundColor: AppColors.walnut),
            icon: _isParsingPdf ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.picture_as_pdf),
            label: Text(_isParsingPdf ? '...' : loc.pdfUploadBtn),
            onPressed: _isParsingPdf ? null : _simulatePdfUpload,
          ),
          if (_parsedPdfLog != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Text(_parsedPdfLog!, style: const TextStyle(color: AppColors.moss, fontSize: 13, fontWeight: FontWeight.bold)),
            ),

          const SizedBox(height: 24),

          Text(loc.roomAreaLbl, style: t.titleLarge),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _NumField(ctrl: _lengthCtrl, label: loc.lengthLbl, onChanged: (_) => setState((){}))),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('×', style: TextStyle(fontSize: 24, color: AppColors.oak)),
            ),
            Expanded(child: _NumField(ctrl: _widthCtrl, label: loc.widthLbl, onChanged: (_) => setState((){}))),
          ]),
          
          if (hasArea) ...[
            const SizedBox(height: 8),
            _InfoChip('${_area.toStringAsFixed(2)} м²  →  +10%: ${_areaWithWaste.toStringAsFixed(2)} м²'),
          ],

          const SizedBox(height: 24),

          Text(loc.catalogOnlineItem, style: t.titleLarge),
          const SizedBox(height: 12),
          DropdownButtonFormField<Map<String, dynamic>>(
            value: _selectedItem,
            decoration: const InputDecoration(
               border: OutlineInputBorder(),
               contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8)
            ),
            items: _catalogItems.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text('${item['name']} — ${currencyFormatter.format(item['price'])} / м²'),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedItem = val);
            },
          ),

          const SizedBox(height: 24),

          Text(loc.installLbl, style: t.titleLarge),
          const SizedBox(height: 8),
          _SwitchRow(
            label: loc.installOptLbl,
            subtitle: _area <= 13 ? '${currencyFormatter.format(_installPriceSmall)} (< 13 м²)' : currencyFormatter.format(_installPriceLarge),
            value: _includeInstall,
            onChanged: (v) => setState(() => _includeInstall = v),
          ),
          _SwitchRow(
            label: '${loc.vatLbl} 18%',
            value: _includeVat,
            onChanged: (v) => setState(() => _includeVat = v),
          ),

          const SizedBox(height: 24),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: hasArea
                ? _ResultCard(
                    area: _areaWithWaste,
                    materialCost: _materialCost,
                    installCost: _installCost,
                    discount: _discount,
                    vat: _vat,
                    total: _total,
                    selectedItemName: _selectedItem['name'],
                    formatter: currencyFormatter.format,
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 24),
          if (hasArea)
            ElevatedButton(
              onPressed: () {
                ref.read(cartProvider.notifier).addToCart(CartItemModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: _selectedItem['name'],
                    brand: 'Wild House',
                    area: _areaWithWaste,
                    pricePerM2: _selectedItem['price'],
                    installIncluded: _includeInstall,
                    installPrice: _installCost,
                ));
                context.push(AppRoutes.cart);
              },
              child: Text(loc.addOnlineCart),
            ),
        ],
      ),
    );
  }
}

class _NumField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final ValueChanged<String> onChanged;

  const _NumField({required this.ctrl, required this.label, required this.onChanged});

  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl,
    onChanged: onChanged,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
    decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
  );
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({required this.label, this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: t.bodyMedium),
            if (subtitle != null)
              Text(subtitle!, style: t.bodySmall?.copyWith(color: AppColors.textSecondary)),
          ],
        )),
        Switch(value: value, onChanged: onChanged, activeColor: AppColors.walnut),
      ]),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String text;
  const _InfoChip(this.text);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: AppColors.oakLight, borderRadius: BorderRadius.circular(4)),
    child: Text(text, style: const TextStyle(fontFamily: 'Jost', fontSize: 13, color: AppColors.walnut)),
  );
}

class _ResultCard extends StatelessWidget {
  final double area, materialCost, installCost, discount, vat, total;
  final String selectedItemName;
  final String Function(double) formatter;

  const _ResultCard({
    required this.area, required this.materialCost, required this.installCost,
    required this.discount, required this.vat, required this.total, 
    required this.selectedItemName, required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.sandDark),
      ),
      child: Column(children: [
        Text(selectedItemName, style: t.headlineSmall, textAlign: TextAlign.center),
        const Divider(height: 20),
        _Row('${loc.materialLbl} (${area.toStringAsFixed(1)} м²)', formatter(materialCost)),
        if (installCost > 0) _Row(loc.installLbl, formatter(installCost)),
        if (discount > 0) _Row('Discount', '− ${formatter(discount)}', valueColor: AppColors.moss),
        if (vat > 0) _Row('${loc.vatLbl} 18%', formatter(vat)),
        const Divider(height: 20),
        Row(children: [
          Text(loc.totalLbl, style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const Spacer(),
          Text(formatter(total), style: t.headlineMedium?.copyWith(color: AppColors.walnut)),
        ]),
      ]),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _Row(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Text(label, style: t.bodyMedium),
        const Spacer(),
        Text(value, style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: valueColor ?? AppColors.textPrimary)),
      ]),
    );
  }
}
