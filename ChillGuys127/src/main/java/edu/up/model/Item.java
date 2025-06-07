package edu.up.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
public class Item {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String itemCode;
    private String name;
    private String category;
    private String size;
    private Double price;
    private String customizations;
    
    // For items with no size
    public static final String NO_SIZE = "NS";
} 