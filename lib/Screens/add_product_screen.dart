import 'package:flutter/material.dart';
import 'package:moor_flutter/moor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:store_app/model/app_database.dart';
import 'package:barcode_scan/barcode_scan.dart';


class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  TextEditingController productNameController;
  TextEditingController priceController;
  FocusNode _namefocusNode = FocusNode();
  FocusNode _pricefocusNode = FocusNode();

  bool _nameValidate = false;
  bool _priceValidate = false;

  void initState() {
    productNameController = TextEditingController();
    priceController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _namefocusNode.dispose();
    _pricefocusNode.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    ScanResult codeSanner = await BarcodeScanner.scan();
    productNameController.text = codeSanner.rawContent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: productNameController,
              autofocus: true,
              focusNode: _namefocusNode,
              onSubmitted: (_) async {
                _pricefocusNode.requestFocus();
              },
              decoration: InputDecoration(
                labelText: 'Product Name',
                errorText: _nameValidate ? 'Value Can\'t Be Empty' : null,
                prefixIcon: Icon(Icons.auto_awesome),
                suffixIcon: IconButton(
                  icon: Icon(Icons.qr_code),
                  onPressed: () {
                    _scan();
                  },
                ),
                hintText: 'Enter Product Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            TextField(
              controller: priceController,
              focusNode: _pricefocusNode,
              onSubmitted: (_) async {
                // saveProduct(context);
                print('Done');
              },
              decoration: InputDecoration(
                  labelText: 'Product Price',
                  errorText: _priceValidate ? 'Value Can\'t Be Empty' : null,
                  prefixIcon: Icon(Icons.attach_money_outlined),
                  hintText: 'Enter Product Price',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
              keyboardType: TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.save_alt,
          color: Colors.white,
        ),
        onPressed: () {
          saveProduct(context);
        },
      ),
    );
  }

  void saveProduct(BuildContext context) {
    if (productNameController.text != '' && priceController.text != '') {
      final productDao = Provider.of<ProductDao>(context);
      final pro = ProductsCompanion(
          name: Value(productNameController.text),
          price: Value(
            double.parse(priceController.text),
          ));
      productDao.insertProduct(pro);
      Navigator.of(context).pop();
    } else {
      setState(() {
        productNameController.text == '' ? _nameValidate = true : _nameValidate = false;
        priceController.text == '' ? _priceValidate = true : _priceValidate = false;
      });
      _namefocusNode.requestFocus();
    }
  }
}
