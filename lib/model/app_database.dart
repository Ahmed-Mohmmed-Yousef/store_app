import 'package:moor/moor.dart';
import 'package:moor_flutter/moor_flutter.dart';

// Moor works by source gen. This file will all the generated code.
part 'app_database.g.dart';

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  RealColumn get price => real()();
}

@UseMoor(tables: [Products], daos: [ProductDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super((FlutterQueryExecutor.inDatabaseFolder(
    path: 'db.sqlite',
    logStatements: true,
  )));
  @override
  int get schemaVersion => 1;
}

@UseDao(tables: [Products])
class ProductDao extends DatabaseAccessor<AppDatabase> with _$ProductDaoMixin {
  final AppDatabase db;

  ProductDao(this.db) : super(db);

  Future<List<Product>> getAllProducts() => select(products).get();
  Stream<List<Product>> watchAllProduct() => select(products).watch();
  Stream<List<Product>> watchTasksName(String name) {
    return customSelectStream(
      'SELECT * FROM products WHERE name LIKE \'$name%\' ORDER BY name;',
      // The Stream will emit new values when the data inside the Tasks table changes
      readsFrom: {products},
    )
    // customSelect or customSelectStream gives us QueryRow list
    // This runs each time the Stream emits a new value.
        .map((rows) {
      // Turning the data of a row into a Task object
      return rows.map((row) => Product.fromData(row.data, db)).toList();
    });
  }
  Future insertProduct(Insertable<Product> product) => into(products).insert(product);
  Future updateProduct(Insertable<Product> product) => update(products).replace(product);
  Future deleteProduct(Insertable<Product> product) => delete(products).delete(product);
}