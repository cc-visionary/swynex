
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../widgets/add_edit_pig_dialog.dart';
import '../widgets/log_farrowing_dialog.dart';
import '../widgets/register_purchase_dialog.dart';

class DefaultActionsFab extends StatelessWidget {
  const DefaultActionsFab({super.key});

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.child_friendly),
          label: 'Log Farrowing',
          onTap: () => showLogFarrowingDialog(context),
        ),
        SpeedDialChild(
          child: const Icon(Icons.shopping_cart),
          label: 'Register Purchase',
          onTap: () => showRegisterPurchaseDialog(context),
        ),
        SpeedDialChild(
          child: const Icon(Icons.person_add_alt_1),
          label: 'Add Single Pig',
          onTap: () => showAddEditPigDialog(context),
        ),
      ],
    );
  }
}
