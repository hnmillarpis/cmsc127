package edu.up.controller;

import edu.up.model.Item;
import edu.up.service.ItemService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/items")
@CrossOrigin(origins = "http://localhost:3000") // React app will run on port 3000
public class ItemController {
    
    @Autowired
    private ItemService itemService;
    
    @PostMapping
    public ResponseEntity<Item> createItem(@RequestBody Item item) {
        return ResponseEntity.ok(itemService.createItem(item));
    }
    
    @GetMapping
    public ResponseEntity<List<Item>> getAllItems() {
        return ResponseEntity.ok(itemService.getAllItems());
    }
    
    @GetMapping("/{itemCode}")
    public ResponseEntity<Item> getItemByCode(@PathVariable String itemCode) {
        Item item = itemService.getItemByCode(itemCode);
        return item != null ? ResponseEntity.ok(item) : ResponseEntity.notFound().build();
    }
    
    @GetMapping("/category/{category}")
    public ResponseEntity<List<Item>> getItemsByCategory(@PathVariable String category) {
        return ResponseEntity.ok(itemService.getItemsByCategory(category));
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Item> updateItem(@PathVariable Long id, @RequestBody Item item) {
        item.setId(id);
        return ResponseEntity.ok(itemService.updateItem(item));
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteItem(@PathVariable Long id) {
        itemService.deleteItem(id);
        return ResponseEntity.ok().build();
    }
} 