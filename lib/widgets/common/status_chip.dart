import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/order.dart';
import '../../models/invoice.dart';
import '../../models/machine.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool small;

  const StatusChip({super.key, required this.label, required this.color, this.small = false});

  static Color colorForOrderStage(OrderStage stage, bool delivered) {
    if (delivered) return AppColors.statusDelivered;
    switch (stage) {
      case OrderStage.queued:
        return AppColors.statusQueued;
      case OrderStage.cutting:
        return AppColors.statusCutting;
      case OrderStage.welding:
        return AppColors.statusWelding;
      case OrderStage.qc:
        return AppColors.statusQC;
      case OrderStage.ready:
        return AppColors.statusReady;
    }
  }

  static Color colorForInvoice(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return AppColors.invoicePaid;
      case InvoiceStatus.outstanding:
        return AppColors.invoiceOutstanding;
      case InvoiceStatus.overdue:
        return AppColors.invoiceOverdue;
    }
  }

  static Color colorForMachine(MachineStatus status) {
    switch (status) {
      case MachineStatus.running:
        return AppColors.machineRunning;
      case MachineStatus.idle:
        return AppColors.machineIdle;
      case MachineStatus.maintenance:
        return AppColors.machineMaintenance;
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
