import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_email_sender/flutter_email_sender.dart';

import 'api/pdf_invoice_api.dart';
import 'models/customer.dart';
import 'models/invoice.dart';
import 'models/purchase.dart';
import 'models/supplier.dart';
import 'widgets/purchase_widget.dart';

class AddPage extends StatefulWidget {
  AddPage({Key? key}) : super(key: key);

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _customerName = TextEditingController();

  final _customerPhone = TextEditingController();

  final _customerEmail = TextEditingController();

  final _customerAddress = TextEditingController();

  final List<TextEditingController> _list = [
    TextEditingController(text: '0'),
    TextEditingController(text: '0'),
    TextEditingController(text: '0'),
    TextEditingController(text: '0'),
    TextEditingController(text: '0'),
    TextEditingController(text: '0'),
    TextEditingController(text: '0'),
    TextEditingController(text: '0'),
    TextEditingController(text: '0'),
    TextEditingController(text: '0'),
    TextEditingController(text: '0'),
  ];

  final _listOfProducts = [
    PurchaseModel(name: 'OS Setup', price: 150),
    PurchaseModel(name: 'Full driver', price: 300),
    PurchaseModel(name: 'Single driver', price: 50),
    PurchaseModel(name: 'Office', price: 150),
    PurchaseModel(name: 'Adobe Master', price: 600),
    PurchaseModel(name: 'Single Adobe', price: 250),
    PurchaseModel(name: 'Wondersahre Filmora X', price: 250),
    PurchaseModel(name: 'AutoCad', price: 250),
    PurchaseModel(name: 'Extra Software', price: 50),
    PurchaseModel(name: 'Laptop Servacing', price: 500),
    PurchaseModel(name: 'Parts replacement', price: 400),
  ];

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add'),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 5,
              ),
              child: ListView(
                children: [
                  const SizedBox(
                    height: 3,
                  ),
                  TextField(
                    controller: _customerName,
                    decoration: const InputDecoration(
                      labelText: 'Customer Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  TextField(
                    controller: _customerPhone,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Customer Phone No',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  TextField(
                    controller: _customerEmail,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Customer Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  TextField(
                    controller: _customerAddress,
                    maxLength: null,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Customer Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  const Center(
                    child: Text(
                      "Purchase",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  for (var i = 0; i < _listOfProducts.length; i++) ...{
                    PurchaseWidget(
                      purchaseModel: _listOfProducts[i],
                      controller: _list[i],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                  },
                  ElevatedButton(
                    onPressed: () async {
                      isLoading = true;
                      setState(() {});
                      final date = DateTime.now();

                      final _cloud = FirebaseFirestore.instance;

                      _cloud.collection("invoice").add({
                        "name": _customerName.text,
                        "datetime": Timestamp.now(),
                      }).then((value) async {
                        List<InvoiceItem> _listOfInvoice = [];

                        for (int i = 0; i < _listOfProducts.length; i++) {
                          if (_list[i].text != '0') {
                            _listOfInvoice.add(InvoiceItem(
                              description: _listOfProducts[i].name,
                              quantity: int.parse(_list[i].text),
                              unitPrice: _listOfProducts[i].price * 1.0,
                            ));
                          }
                        }
                        final invoice = Invoice(
                          supplier: const Supplier(
                            name: 'PC Solution 512',
                            address: 'North Hall, Room-512',
                          ),
                          customer: Customer(
                            name: _customerName.text,
                            address: _customerAddress.text,
                            email: _customerEmail.text,
                            phone: _customerPhone.text,
                          ),
                          info: InvoiceInfo(
                            date: date,
                            description: '',
                            number: value.id,
                          ),
                          items: [..._listOfInvoice],
                        );

                        final pdfFile = await PdfInvoiceApi.generate(invoice);
                        final _storage = FirebaseStorage.instance;

                        await _storage
                            .ref("invoice")
                            .child(value.id)
                            .putFile(pdfFile);

                        var dir = await getExternalStorageDirectory();

                        final Email email = Email(
                          body: 'Invoice Of PC SOlution 512',
                          subject: 'Invoice Of PC SOlution 512',
                          recipients: [_customerEmail.text],
                          attachmentPaths: ["${dir!.path}/${value.id}.pdf"],
                          isHTML: false,
                        );
                        await FlutterEmailSender.send(email);

                        _customerAddress.clear();
                        _customerEmail.clear();
                        _customerName.clear();
                        _customerPhone.clear();
                        for (var i = 0; i < _list.length; i++) {
                          _list[i].text = '0';
                        }
                        isLoading = false;
                        setState(() {});

                        //PdfApi.openFile(pdfFile);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Invoice Sended")));
                      }).catchError((onError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(onError.toString())));
                      });
                    },
                    child: const Text("Save"),
                  ),
                ],
              ),
            ),
    );
  }
}
