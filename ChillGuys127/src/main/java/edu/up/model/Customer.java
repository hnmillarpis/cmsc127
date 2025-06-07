package edu.up.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
public class Customer {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String firstName;
    private String lastName;
    private String memberId;
    private String birthday;
    private String contactDetails;
    private String customerType; // "GUEST" or "MEMBER"
} 