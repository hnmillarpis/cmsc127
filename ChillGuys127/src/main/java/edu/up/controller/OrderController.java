package edu.up.controller;

import edu.up.model.*;
import edu.up.service.OrderService;
import edu.up.service.CustomerService;
import edu.up.repository.ItemRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/orders")
@CrossOrigin(origins = "http://localhost:3000")
public class OrderController {
    
    @Autowired
    private OrderService orderService;
    
    @Autowired
    private CustomerService customerService;
    
    @Autowired
    private ItemRepository itemRepository;
    
    @PostMapping
    public ResponseEntity<Order> createOrder(@RequestBody OrderRequest request) {
        Customer customer;
        if ("GUEST".equals(request.getCustomerType())) {
            customer = customerService.createGuestCustomer(request.getCustomerName());
        } else {
            customer = customerService.getCustomerByMemberId(request.getMemberId());
            if (customer == null) {
                return ResponseEntity.badRequest().build();
            }
        }
        
        List<OrderItem> orderItems = request.getItems().stream()
            .map(itemRequest -> {
                Item item = itemRepository.findById(itemRequest.getItemId())
                    .orElseThrow(() -> new RuntimeException("Item not found"));
                OrderItem orderItem = new OrderItem();
                orderItem.setItem(item);
                orderItem.setQuantity(itemRequest.getQuantity());
                orderItem.setCustomizations(String.join(",", itemRequest.getCustomizations()));
                orderItem.setPrice(itemRequest.getPrice());
                return orderItem;
            })
            .toList();
        
        Order order = orderService.createOrder(customer, orderItems);
        return ResponseEntity.ok(order);
    }
    
    @GetMapping
    public ResponseEntity<List<Order>> getAllOrders() {
        return ResponseEntity.ok(orderService.getAllOrders());
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Order> getOrderById(@PathVariable Long id) {
        Order order = orderService.getOrderById(id);
        return order != null ? ResponseEntity.ok(order) : ResponseEntity.notFound().build();
    }
} 