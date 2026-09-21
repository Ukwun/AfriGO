import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme.dart';

/// A live trade case surface. Values come only from the authorised order
/// record, so an empty field stays visibly unconfirmed instead of becoming
/// fictitious sample data.
class TradeWorkspaceScreen extends StatelessWidget {
  const TradeWorkspaceScreen({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: const _Brand(),
          centerTitle: true,
          leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back, color: AfrigoColors.primary)),
          actions: [IconButton(onPressed: () => context.push('/notifications'), icon: const Icon(Icons.notifications_none_rounded, color: AfrigoColors.primary))],
        ),
        body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('orders').doc(orderId).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return const _Unavailable();
            final record = snapshot.data!.data();
            if (record == null) return const _Unavailable(notFound: true);
            return _WorkspaceContents(orderId: orderId, record: record);
          },
        ),
      );
}

class _WorkspaceContents extends StatelessWidget {
  const _WorkspaceContents({required this.orderId, required this.record});
  final String orderId;
  final Map<String, dynamic> record;

  String text(List<String> keys, [String fallback = 'Not confirmed']) {
    for (final key in keys) {
      final value = record[key];
      if (value != null && value.toString().trim().isNotEmpty) return value.toString();
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final product = text(['productName', 'commodity', 'product', 'title'], 'Trade case');
    final quantity = text(['quantity'], 'Quantity pending');
    final unit = text(['unit', 'quantityUnit'], '');
    final route = text(['route', 'tradeRoute', 'destination'], 'Route pending');
    final status = text(['status', 'stage'], 'in progress').replaceAll('_', ' ');
    final value = text(['totalAmount', 'goodsValue', 'amount', 'price'], 'Value pending');
    final steps = _steps(status);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 34),
      children: [
        Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Trade case ${orderId.length > 12 ? orderId.substring(0, 12) : orderId}', style: AfrigoTypography.soraHeading2.copyWith(color: AfrigoColors.textPrimary)), const SizedBox(height: 5), Text('$product • $quantity $unit', style: AfrigoTypography.interBody1.copyWith(color: AfrigoColors.textSecondary))])), _Status(status: status)]),
        const SizedBox(height: 24),
        _Panel(title: 'Trade milestones', child: Row(children: List.generate(4, (index) => Expanded(child: _Milestone(index: index, complete: steps > index, current: steps == index))))),
        const SizedBox(height: 18),
        _Panel(title: 'Order details', child: Column(children: [
          _Detail(icon: Icons.eco_outlined, label: 'Product', value: '$product • $quantity $unit'),
          _Detail(icon: Icons.storefront_outlined, label: 'Seller', value: text(['sellerName', 'supplierName'], 'Seller identity pending')),
          _Detail(icon: Icons.business_outlined, label: 'Buyer', value: text(['buyerName'], 'Buyer identity pending')),
          _Detail(icon: Icons.route_outlined, label: 'Route', value: route),
          _Detail(icon: Icons.payments_outlined, label: 'Goods value', value: value, last: true),
        ])),
        const SizedBox(height: 18),
        _Panel(title: 'Documents and tasks', trailing: TextButton(onPressed: () => context.push('/orders/detail/$orderId'), child: const Text('View record')), child: Column(children: [
          _ActionRow(icon: Icons.description_outlined, title: 'Trade documents', subtitle: 'Private to authorised trade participants', onTap: () => context.push('/orders/detail/$orderId')),
          _ActionRow(icon: Icons.checklist_rounded, title: 'Outstanding tasks', subtitle: steps < 3 ? 'Complete requirements before shipment' : 'Shipment preparation is underway', onTap: () => context.push('/orders/detail/$orderId')),
        ])),
        const SizedBox(height: 18),
        Row(children: [Expanded(child: FilledButton.icon(onPressed: () => context.push('/orders/detail/$orderId'), icon: const Icon(Icons.open_in_new_rounded), label: const Text('Open trade record'))), const SizedBox(width: 12), Expanded(child: OutlinedButton.icon(onPressed: () => context.push('/orders/$orderId/logistics'), icon: const Icon(Icons.local_shipping_outlined), label: const Text('Request logistics')))]),
      ],
    );
  }

  int _steps(String status) {
    final value = status.toLowerCase();
    if (value.contains('deliver') || value.contains('complete')) return 4;
    if (value.contains('ship')) return 3;
    if (value.contains('document') || value.contains('prepar')) return 2;
    if (value.contains('accept') || value.contains('confirm') || value.contains('active')) return 1;
    return 0;
  }
}

class _Brand extends StatelessWidget { const _Brand(); @override Widget build(BuildContext context) => Text('AfriGoOS', style: AfrigoTypography.soraHeading5.copyWith(color: AfrigoColors.primary)); }
class _Unavailable extends StatelessWidget { const _Unavailable({this.notFound = false}); final bool notFound; @override Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.cloud_off_outlined, size: 46, color: AfrigoColors.textSecondary), const SizedBox(height: 12), Text(notFound ? 'Trade case not found' : 'Trade case unavailable'), const SizedBox(height: 8), const Text('Only authorised participants can view live trade records.', textAlign: TextAlign.center)]))); }
class _Status extends StatelessWidget { const _Status({required this.status}); final String status; @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xFFFFF4DE), borderRadius: BorderRadius.circular(24)), child: Text(status, style: const TextStyle(color: Color(0xFF946600), fontWeight: FontWeight.w700))); }
class _Panel extends StatelessWidget { const _Panel({required this.title, required this.child, this.trailing}); final String title; final Widget child; final Widget? trailing; @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(border: Border.all(color: AfrigoColors.borderLight), borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(title, style: AfrigoTypography.soraHeading5.copyWith(color: AfrigoColors.primary))), if (trailing != null) trailing!]), const SizedBox(height: 14), child])); }
class _Milestone extends StatelessWidget { const _Milestone({required this.index, required this.complete, required this.current}); final int index; final bool complete; final bool current; @override Widget build(BuildContext context) { const labels = ['Enquiry', 'Quotation', 'Documents', 'Shipment']; return Column(children: [Icon(complete ? Icons.check_circle : current ? Icons.timelapse_rounded : Icons.circle_outlined, color: complete ? AfrigoColors.primary : current ? const Color(0xFFB18420) : AfrigoColors.textTertiary), const SizedBox(height: 7), Text(labels[index], textAlign: TextAlign.center, style: const TextStyle(fontSize: 11))]); } }
class _Detail extends StatelessWidget { const _Detail({required this.icon, required this.label, required this.value, this.last = false}); final IconData icon; final String label, value; final bool last; @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(border: last ? null : const Border(bottom: BorderSide(color: AfrigoColors.borderLight))), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: AfrigoColors.primary), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: AfrigoTypography.interBody3.copyWith(color: AfrigoColors.textSecondary)), Text(value, style: AfrigoTypography.interBody2Semi.copyWith(color: AfrigoColors.textPrimary))]))])); }
class _ActionRow extends StatelessWidget { const _ActionRow({required this.icon, required this.title, required this.subtitle, required this.onTap}); final IconData icon; final String title, subtitle; final VoidCallback onTap; @override Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Row(children: [Icon(icon, color: AfrigoColors.primary), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: AfrigoTypography.interBody2Semi), Text(subtitle, style: AfrigoTypography.interBody3.copyWith(color: AfrigoColors.textSecondary))])), const Icon(Icons.chevron_right_rounded)]))); }
