package edu.up.service;

import edu.up.model.*;
import edu.up.repository.OrderRepository;
import edu.up.repository.ItemRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class OrderService {
    
    @Autowired
    private OrderRepository orderRepository;
    
    @Autowired
    private ItemRepository itemRepository;
    
    public Order createOrder(Customer customer, List<OrderItem> orderItems) {
        Order order = new Order();
        order.setCustomer(customer);
        order.setOrderDate(LocalDateTime.now());
        
        double total = 0;
        for (OrderItem item : orderItems) {
            item.setOrder(order);
            total += item.getPrice() * item.getQuantity();
        }
        
        order.setTotalAmount(total);
        order.setOrderItems(orderItems);
        
        return orderRepository.save(order);
    }
    
    public List<Order> getAllOrders() {
        return orderRepository.findAll();
    }
    
    public Order getOrderById(Long id) {
        return orderRepository.findById(id).orElse(null);
    }
} 