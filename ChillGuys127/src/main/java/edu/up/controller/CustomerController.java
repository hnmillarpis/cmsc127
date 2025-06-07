package edu.up.controller;

import edu.up.model.Customer;
import edu.up.service.CustomerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/customers")
@CrossOrigin(origins = "http://localhost:3000")
public class CustomerController {
    
    @Autowired
    private CustomerService customerService;
    
    @PostMapping("/guest")
    public ResponseEntity<Customer> createGuestCustomer(@RequestParam String firstName) {
        return ResponseEntity.ok(customerService.createGuestCustomer(firstName));
    }
    
    @PostMapping("/member")
    public ResponseEntity<Customer> createMemberCustomer(
            @RequestParam String firstName,
            @RequestParam String lastName,
            @RequestParam String memberId,
            @RequestParam String birthday,
            @RequestParam String contactDetails) {
        return ResponseEntity.ok(customerService.createMemberCustomer(
            firstName, lastName, memberId, birthday, contactDetails));
    }
    
    @GetMapping("/member/{memberId}")
    public ResponseEntity<Customer> getCustomerByMemberId(@PathVariable String memberId) {
        Customer customer = customerService.getCustomerByMemberId(memberId);
        return customer != null ? ResponseEntity.ok(customer) : ResponseEntity.notFound().build();
    }
} 