import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../app/theme.dart';
import '../../../../shared/services/revenue_cat_service.dart';
import '../controllers/settings_providers.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() =>
      _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  Offering? _offering;
  bool _loadingOffering = true;
  Package? _selectedPackage;
  bool _purchasing = false;

  @override
  void initState() {
    super.initState();
    _loadOffering();
  }

  Future<void> _loadOffering() async {
    final offering = await RevenueCatService.instance.getOffering();
    if (mounted) {
      setState(() {
        _offering = offering;
        _selectedPackage = offering?.availablePackages.firstOrNull;
        _loadingOffering = false;
      });
    }
  }

  Future<void> _purchase() async {
    if (_selectedPackage == null) return;
    setState(() => _purchasing = true);
    final ok = await RevenueCatService.instance.purchase(_selectedPackage!);
    if (!mounted) return;
    setState(() => _purchasing = false);
    if (ok) {
      ref.invalidate(isProUserProvider);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Welcome to FamilySync Pro! 🎉')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase cancelled or failed.')));
    }
  }

  Future<void> _restore() async {
    setState(() => _purchasing = true);
    final restored = await RevenueCatService.instance.restorePurchases();
    if (!mounted) return;
    setState(() => _purchasing = false);
    if (restored) {
      ref.invalidate(isProUserProvider);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchases restored!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No previous purchases found.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('FamilySync Pro')),
      body: SafeArea(
        child: _loadingOffering
            ? const Center(child: CircularProgressIndicator())
            : _offering == null
                ? _ErrorState(onRetry: _loadOffering)
                : CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(children: [
                            // Hero
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.tertiary,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.star,
                                  color: Colors.white, size: 40),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text('Go Pro',
                                style: theme.textTheme.headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.w800)),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Unlock everything FamilySync has to offer.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                  color:
                                      theme.colorScheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: AppSpacing.xl),

                            // Feature list
                            ..._kProFeatures.map((f) => _FeatureRow(
                                icon: f.$1,
                                label: f.$2,
                                sub: f.$3)),
                            const SizedBox(height: AppSpacing.xl),

                            // Package selector
                            ..._offering!.availablePackages
                                .map((pkg) => _PackageTile(
                                      package: pkg,
                                      isSelected:
                                          _selectedPackage == pkg,
                                      onTap: () => setState(
                                          () => _selectedPackage = pkg),
                                    )),
                            const SizedBox(height: AppSpacing.lg),

                            // CTA
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed:
                                    _purchasing ? null : _purchase,
                                child: _purchasing
                                    ? const SizedBox.square(
                                        dimension: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white))
                                    : Text(_selectedPackage != null
                                        ? 'Subscribe · ${_selectedPackage!.storeProduct.priceString}'
                                        : 'Subscribe'),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            TextButton(
                              onPressed: _purchasing ? null : _restore,
                              child: const Text('Restore purchases'),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Subscriptions renew automatically. Cancel anytime in your device settings.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color:
                                      theme.colorScheme.onSurfaceVariant),
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

// Pro features list — (icon, title, subtitle)
const _kProFeatures = [
  (Icons.people_outline, 'Unlimited members', 'Add as many family members as you need'),
  (Icons.history_outlined, 'Full event history', 'Access events from any time period'),
  (Icons.photo_library_outlined, 'Photo posts in Feed', 'Share photos with your family'),
  (Icons.bar_chart_outlined, 'Task streaks & stats', 'Detailed completion reports'),
  (Icons.support_agent_outlined, 'Priority support', 'Get help faster when you need it'),
];

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.label, required this.sub});
  final IconData icon;
  final String label;
  final String sub;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon,
              size: 20, color: theme.colorScheme.onPrimaryContainer),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: theme.textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
            Text(sub,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
          ]),
        ),
        Icon(Icons.check_circle,
            color: theme.colorScheme.primary, size: 20),
      ]),
    );
  }
}

class _PackageTile extends StatelessWidget {
  const _PackageTile({
    required this.package,
    required this.isSelected,
    required this.onTap,
  });
  final Package package;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = package.storeProduct;
    final isAnnual = package.packageType == PackageType.annual;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: isSelected
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
        ),
        child: Row(children: [
          Radio<Package>(
            value: package,
            groupValue: isSelected ? package : null,
            onChanged: (_) => onTap(),
            activeColor: theme.colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(product.title.isEmpty
                          ? (isAnnual ? 'Annual' : 'Monthly')
                          : product.title,
                      style: theme.textTheme.labelLarge
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  if (isAnnual) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiary,
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text('BEST VALUE',
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onTertiary,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ]),
                Text(product.description.isEmpty
                    ? product.priceString
                    : product.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Text(product.priceString,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : null)),
        ]),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.wifi_off_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: AppSpacing.md),
          const Text('Could not load subscription options.'),
          const SizedBox(height: AppSpacing.sm),
          FilledButton(onPressed: onRetry, child: const Text('Try again')),
        ]),
      );
}
