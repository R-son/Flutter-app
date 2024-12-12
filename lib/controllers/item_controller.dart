import '../models/item.dart';
import '../services/api_service.dart';

class ItemController {
  Future<List<Item>> getItems(String? category) async {
    return await ApiService.fetchItems(category: category);
  }

  Future<void> addItem(Item item) async {
    await ApiService.addItem(item);
  }
}
