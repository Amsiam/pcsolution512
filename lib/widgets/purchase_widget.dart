import 'package:flutter/material.dart';

import '../models/purchase.dart';

class PurchaseWidget extends StatefulWidget {
  const PurchaseWidget({
    Key? key,
    required this.purchaseModel,
    required this.controller,
  }) : super(key: key);
  final PurchaseModel purchaseModel;
  final TextEditingController controller;
  @override
  State<PurchaseWidget> createState() => _PurchaseWidgetState();
}

class _PurchaseWidgetState extends State<PurchaseWidget> {
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    amountController.text =
        "${int.parse(widget.controller.text) * widget.purchaseModel.price}";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.purchaseModel.name,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        Expanded(
          child: TextField(
            controller: widget.controller,
            onChanged: (value) {
              amountController.text =
                  "${int.parse(value) * widget.purchaseModel.price}";
              setState(() {});
            },
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Quantity',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Expanded(
          child: TextField(
            enabled: false,
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Price',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}
