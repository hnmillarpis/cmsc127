package edu.up.model;

import lombok.Data;
import java.util.List;

@Data
public class OrderRequest {
    private String customerType;
    private String customerName;
    private String memberId;
    private List<OrderItemRequest> items;
    
    @Data
    public static class OrderItemRequest {
        private Long itemId;
        private Integer quantity;
        private List<String> customizations;
        private Double price;
    }
} 