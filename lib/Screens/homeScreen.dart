import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:store_app/Screens/add_product_screen.dart';
import 'package:store_app/model/app_database.dart';
import 'package:barcode_scan/barcode_scan.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _productName = '';
  TextEditingController _productNameController = TextEditingController();
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Abo Hamza'),
      ),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: _productNameController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  labelText: 'Search here',
                  prefix: Icon(Icons.search),
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
                onChanged: (value) async {
                  setState(() {
                    _productName = value;
                  });
                },
              ),
            ),
            Expanded(
              child: _buildProductList(context),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => AddProductScreen()));
        },
      ),
    );
  }

  Future<void> _scan() async {
    ScanResult codeSanner = await BarcodeScanner.scan();
    _productNameController.text = codeSanner.rawContent;
    setState(() {
      _productName = codeSanner.rawContent;
    });
  }

  StreamBuilder<List<Product>> _buildProductList(BuildContext context) {
    final productDao = Provider.of<ProductDao>(context);

    return StreamBuilder(
      stream: _productName != ''
          ? productDao.watchTasksName(_productName)
          : productDao.watchAllProduct(),
      builder: (context, AsyncSnapshot<List<Product>> snapshot) {
        final products = snapshot.data ?? List();
        return ListView.builder(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemCount: products.length,
          itemBuilder: (_, index) {
            final itemProduct = products[index];
            return _buildListItem(context, itemProduct, productDao);
          },
        );
      },
    );
  }

  Widget _buildListItem(
      BuildContext context, Product product, ProductDao productDao) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: [
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => productDao.deleteProduct(product),
        ),
        IconSlideAction(
          caption: 'Update',
          color: Colors.blue,
          icon: Icons.settings,
          onTap: () {
            TextEditingController controller = TextEditingController();
            controller.text = '${product.price}';
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text('Update Price'),
                content: Container(
                  height: 200,
                  child: Column(
                    children: [
                      TextField(
                        controller: controller,
                        decoration: InputDecoration(labelText: 'Product price'),
                        autofocus: true,
                        keyboardType: TextInputType.numberWithOptions(
                            signed: false, decimal: true),
                      ),
                      RaisedButton(
                          child: Text('Save'),
                          onPressed: () {
                            if (controller.text != '') {
                              productDao.updateProduct(product.copyWith(
                                  price: double.parse(controller.text)));
                            }
                            Navigator.of(context).pop();
                          }),
                    ],
                  ),
                ),
              ),
            );
          },
        )
      ],
      child: Card(
        child: ListTile(
          title: Text(
            product.name,
            style: TextStyle(fontSize: 20),
          ),
          trailing: Text(
            '${product.price.toStringAsFixed(2)} EG',
            style: TextStyle(
                color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
