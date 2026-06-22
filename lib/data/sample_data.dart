import '../models/order.dart';
import '../models/inventory_item.dart';
import '../models/supplier.dart';
import '../models/invoice.dart';
import '../models/machine.dart';
import '../models/drawing.dart';
import '../models/team_member.dart';

class SampleData {
  static List<Order> get orders => [
        const Order(
          id: 1042,
          customer: 'Patel Engineering',
          item: 'MS Angle Bracket',
          spec: '40×40×5',
          qty: 120,
          material: 'MS Angle',
          due: '28 Jun',
          ordered: '12 Jun',
          stage: OrderStage.welding,
        ),
        const Order(
          id: 1041,
          customer: 'Krishna Motors',
          item: 'GI Shaft',
          spec: 'Ø25×600mm',
          qty: 30,
          material: 'GI Round Bar',
          due: '25 Jun',
          ordered: '10 Jun',
          stage: OrderStage.qc,
        ),
        const Order(
          id: 1040,
          customer: 'Deccan Fabricators',
          item: 'MS Frame',
          spec: '1200×800mm',
          qty: 5,
          material: 'MS Channel',
          due: '22 Jun',
          ordered: '8 Jun',
          stage: OrderStage.ready,
        ),
        const Order(
          id: 1039,
          customer: 'Surya Auto',
          item: 'Drill Jig Plate',
          spec: '300×200×10mm',
          qty: 10,
          material: 'EN8 Flat',
          due: '20 Jun',
          ordered: '5 Jun',
          stage: OrderStage.ready,
          delivered: true,
          drawing: 'gear-blank.step',
        ),
        const Order(
          id: 1038,
          customer: 'Patel Engineering',
          item: 'Bolt Plate Set',
          spec: 'M12 × 50mm',
          qty: 200,
          material: 'MS Flat',
          due: '18 Jun',
          ordered: '3 Jun',
          stage: OrderStage.ready,
          delivered: true,
          drawing: 'boltplate.pdf',
        ),
        const Order(
          id: 1043,
          customer: 'Apex Industries',
          item: 'GI Washer',
          spec: 'M16 DIN 125',
          qty: 500,
          material: 'GI Sheet',
          due: '30 Jun',
          ordered: '14 Jun',
          stage: OrderStage.queued,
        ),
        const Order(
          id: 1044,
          customer: 'Krishna Motors',
          item: 'Gear Blank',
          spec: 'Ø80×30mm',
          qty: 15,
          material: 'EN8 Round',
          due: '5 Jul',
          ordered: '15 Jun',
          stage: OrderStage.cutting,
        ),
      ];

  static List<InventoryItem> get inventory => [
        const InventoryItem(
          id: 1,
          name: 'MS Angle',
          category: 'Structural',
          qty: 480,
          unit: 'kg',
          reorder: 300,
          log: [
            StockLogEntry(date: '12 Jun', delta: -60, note: 'Used for #1042'),
            StockLogEntry(date: '10 Jun', delta: 500, note: 'Purchase — Rathi Steels'),
            StockLogEntry(date: '5 Jun', delta: -40, note: 'Used for #1038'),
          ],
        ),
        const InventoryItem(
          id: 2,
          name: 'GI Sheet',
          category: 'Sheet Metal',
          qty: 28,
          unit: 'sheets',
          reorder: 50,
          log: [
            StockLogEntry(date: '13 Jun', delta: -4, note: 'Used for #1043'),
            StockLogEntry(date: '8 Jun', delta: 40, note: 'Purchase — Mehta Metals'),
          ],
        ),
        const InventoryItem(
          id: 3,
          name: 'MS Round Bar',
          category: 'Bar Stock',
          qty: 210,
          unit: 'kg',
          reorder: 200,
          log: [
            StockLogEntry(date: '11 Jun', delta: -30, note: 'Used for #1041'),
            StockLogEntry(date: '7 Jun', delta: 250, note: 'Purchase — Rathi Steels'),
          ],
        ),
        const InventoryItem(
          id: 4,
          name: 'Welding Electrode',
          category: 'Consumable',
          qty: 12,
          unit: 'kg',
          reorder: 25,
          log: [
            StockLogEntry(date: '12 Jun', delta: -8, note: 'Welding #1042'),
            StockLogEntry(date: '9 Jun', delta: 30, note: 'Purchase — Pioneer Tools'),
          ],
        ),
        const InventoryItem(
          id: 5,
          name: 'EN8 Round Bar',
          category: 'Bar Stock',
          qty: 95,
          unit: 'kg',
          reorder: 80,
          log: [
            StockLogEntry(date: '14 Jun', delta: -20, note: 'Used for #1044'),
            StockLogEntry(date: '6 Jun', delta: 100, note: 'Purchase — Bhushan Steel'),
          ],
        ),
        const InventoryItem(
          id: 6,
          name: 'Cutting Disc',
          category: 'Consumable',
          qty: 8,
          unit: 'pcs',
          reorder: 20,
          log: [
            StockLogEntry(date: '13 Jun', delta: -5, note: 'Cutting ops'),
            StockLogEntry(date: '5 Jun', delta: 25, note: 'Purchase — Pioneer Tools'),
          ],
        ),
        const InventoryItem(
          id: 7,
          name: 'Red Oxide Primer',
          category: 'Paint',
          qty: 18,
          unit: 'L',
          reorder: 10,
          log: [
            StockLogEntry(date: '10 Jun', delta: -3, note: 'Priming #1039, #1040'),
            StockLogEntry(date: '1 Jun', delta: 20, note: 'Purchase — Asian Paints'),
          ],
        ),
        const InventoryItem(
          id: 8,
          name: 'MS Channel',
          category: 'Structural',
          qty: 150,
          unit: 'kg',
          reorder: 200,
          log: [
            StockLogEntry(date: '9 Jun', delta: -80, note: 'Used for #1040'),
            StockLogEntry(date: '3 Jun', delta: 200, note: 'Purchase — Rathi Steels'),
          ],
        ),
      ];

  static List<Supplier> get suppliers => [
        const Supplier(
          id: 1,
          name: 'Rathi Steels',
          materials: 'MS Angle, MS Channel, MS Round Bar',
          phone: '+91 98200 11234',
          location: 'Bhiwandi, MH',
        ),
        const Supplier(
          id: 2,
          name: 'Mehta Metals',
          materials: 'GI Sheet, CR Sheet, HR Sheet',
          phone: '+91 98200 22345',
          location: 'Kurla, Mumbai',
        ),
        const Supplier(
          id: 3,
          name: 'Bhushan Steel',
          materials: 'EN8, EN24, Alloy Bars',
          phone: '+91 98200 33456',
          location: 'Thane, MH',
        ),
        const Supplier(
          id: 4,
          name: 'Pioneer Tools',
          materials: 'Cutting Disc, Welding Electrode, Drill Bits',
          phone: '+91 98200 44567',
          location: 'Andheri, Mumbai',
        ),
        const Supplier(
          id: 5,
          name: 'Asian Paints Industrial',
          materials: 'Red Oxide, Epoxy Primer, Enamel Paint',
          phone: '+91 98200 55678',
          location: 'Navi Mumbai',
        ),
      ];

  static List<Invoice> get invoices => [
        const Invoice(
          id: 'INV-2406',
          customer: 'Patel Engineering',
          amount: 48500,
          status: InvoiceStatus.outstanding,
          date: '14 Jun',
        ),
        const Invoice(
          id: 'INV-2405',
          customer: 'Krishna Motors',
          amount: 32200,
          status: InvoiceStatus.paid,
          date: '10 Jun',
        ),
        const Invoice(
          id: 'INV-2404',
          customer: 'Deccan Fabricators',
          amount: 71000,
          status: InvoiceStatus.overdue,
          date: '1 Jun',
        ),
        const Invoice(
          id: 'INV-2403',
          customer: 'Surya Auto',
          amount: 19800,
          status: InvoiceStatus.paid,
          date: '28 May',
        ),
        const Invoice(
          id: 'INV-2402',
          customer: 'Apex Industries',
          amount: 25500,
          status: InvoiceStatus.outstanding,
          date: '20 May',
        ),
      ];

  static List<Quote> get quotes => [
        const Quote(
          id: 'QT-0089',
          customer: 'Apex Industries',
          amount: 55000,
          status: QuoteStatus.pending,
          date: '15 Jun',
        ),
        const Quote(
          id: 'QT-0088',
          customer: 'Krishna Motors',
          amount: 28000,
          status: QuoteStatus.won,
          date: '8 Jun',
        ),
        const Quote(
          id: 'QT-0087',
          customer: 'Sunrise Metals',
          amount: 18500,
          status: QuoteStatus.lost,
          date: '2 Jun',
        ),
        const Quote(
          id: 'QT-0086',
          customer: 'Patel Engineering',
          amount: 92000,
          status: QuoteStatus.pending,
          date: '28 May',
        ),
      ];

  static List<Machine> get machines => [
        const Machine(
          id: 1,
          name: 'Lathe Machine',
          status: MachineStatus.running,
          utilization: 0.78,
          note: 'Running on #1044 — Gear Blank',
        ),
        const Machine(
          id: 2,
          name: 'MIG Welding Station',
          status: MachineStatus.running,
          utilization: 0.65,
          note: 'Suresh on #1042 welding',
        ),
        const Machine(
          id: 3,
          name: 'Plasma Cutter',
          status: MachineStatus.running,
          utilization: 0.50,
          note: 'Cutting GI sheet for #1043',
        ),
        const Machine(
          id: 4,
          name: 'Drill Press',
          status: MachineStatus.idle,
          utilization: 0.0,
          note: 'Idle — next job queued',
        ),
        const Machine(
          id: 5,
          name: 'Surface Grinder',
          status: MachineStatus.maintenance,
          utilization: 0.0,
          note: 'Wheel dressing — back tomorrow',
        ),
        const Machine(
          id: 6,
          name: 'Band Saw',
          status: MachineStatus.idle,
          utilization: 0.0,
          note: 'Vijay shifts here after cutting',
        ),
      ];

  static List<Drawing> get drawings => [
        const Drawing(
          name: 'bracket-rev2.pdf',
          customer: 'Patel Engineering',
          size: '240 KB',
          rev: 'rev 2',
        ),
        const Drawing(
          name: 'shaft-25.dwg',
          customer: 'Krishna Motors',
          size: '180 KB',
          rev: 'rev 1',
        ),
        const Drawing(
          name: 'gi-frame.pdf',
          customer: 'Deccan Fabricators',
          size: '510 KB',
          rev: 'rev 3',
        ),
        const Drawing(
          name: 'boltplate.pdf',
          customer: 'Patel Engineering',
          size: '95 KB',
          rev: 'rev 1',
        ),
        const Drawing(
          name: 'gear-blank.step',
          customer: 'Krishna Motors',
          size: '1.2 MB',
          rev: 'rev 2',
        ),
        const Drawing(
          name: 'washer.dxf',
          customer: 'Surya Auto',
          size: '44 KB',
          rev: 'rev 1',
        ),
      ];

  static List<TeamMember> get team => [
        const TeamMember(
          name: 'Mikul Shah',
          initials: 'MS',
          role: 'Owner',
          task: 'Managing everything',
        ),
        const TeamMember(
          name: 'Suresh Patil',
          initials: 'SP',
          role: 'Welder',
          task: 'On #1042 — welding',
        ),
        const TeamMember(
          name: 'Iqbal Khan',
          initials: 'IK',
          role: 'Machinist',
          task: 'On #1044 — lathe',
        ),
        const TeamMember(
          name: 'Vijay More',
          initials: 'VM',
          role: 'Cutting',
          task: 'On #1043 — plasma cut',
        ),
        const TeamMember(
          name: 'Anita Rao',
          initials: 'AR',
          role: 'Accounts',
          task: 'Invoicing — INV-2406',
        ),
      ];
}
