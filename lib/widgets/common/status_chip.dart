import 'package:flutter/material.dart';
import '../../core/theme/app_color_scheme.dart';
import '../../models/order.dart';
import '../../models/invoice.dart';
import '../../models/machine.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool small;

  const StatusChip({super.key, required this.label, required this.color, this.small = false});

  static Color colorForOrderStage(OrderStage stage, bool delivered) {
    if (delivered) return AppColorScheme.statusDelivered;
    switch (stage) {
      case OrderStage.queued:
        return AppColorScheme.statusQueued;
      case OrderStage.cutting:
        return AppColorScheme.statusCutting;
      case OrderStage.welding:
        return AppColorScheme.statusWelding;
      case OrderStage.qc:
        return AppColorScheme.statusQC;
      case OrderStage.ready:
        return AppColorScheme.statusReady;
    }
  }

  static Color colorForInvoice(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return AppColorScheme.invoicePaid;
      case InvoiceStatus.outstanding:
        return AppColorScheme.invoiceOutstanding;
      case InvoiceStatus.overdue:
        return AppColorScheme.invoiceOverdue;
    }
  }

  static Color colorForMachine(MachineStatus status) {
    switch (status) {
      case MachineStatus.running:
        return AppColorScheme.machineRunning;
      case MachineStatus.idle:
        return AppColorScheme.machineIdle;
      case MachineStatus.maintenance:
        return AppColorScheme.machineMaintenance;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: small ? 11 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
