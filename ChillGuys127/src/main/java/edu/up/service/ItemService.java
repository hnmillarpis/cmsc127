package edu.up.service;

import edu.up.model.Item;
import edu.up.repository.ItemRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ItemService {
    
    @Autowired
    private ItemRepository itemRepository;
    
    public Item createItem(Item item) {
        // Generate item code based on category and name
        String itemCode = generateItemCode(item);
        item.setItemCode(itemCode);
        return itemRepository.save(item);
    }
    
    public List<Item> getAllItems() {
        return itemRepository.findAll();
    }
    
    public Item getItemByCode(String itemCode) {
        return itemRepository.findByItemCode(itemCode);
    }
    
    public List<Item> getItemsByCategory(String category) {
        return itemRepository.findByCategory(category);
    }
    
    public Item updateItem(Item item) {
        return itemRepository.save(item);
    }
    
    public void deleteItem(Long id) {
        itemRepository.deleteById(id);
    }
    
    private String generateItemCode(Item item) {
        String category = item.getCategory();
        String name = item.getName();
        
        // XX-YYYY-ZZZ format
        String xx = category.substring(0, 1) + category.substring(category.length() - 1);
        String yyyy = name.length() >= 4 ? name.substring(0, 4) : name;
        
        // Get count of items in this category for ZZZ
        long count = itemRepository.findByCategory(category).size() + 1;
        String zzz = String.format("%03d", count);
        
        return xx + "-" + yyyy + "-" + zzz;
    }
} 