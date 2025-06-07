package edu.up.service;

import edu.up.model.Customer;
import edu.up.repository.CustomerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class CustomerService {
    
    @Autowired
    private CustomerRepository customerRepository;
    
    public Customer createCustomer(Customer customer) {
        return customerRepository.save(customer);
    }
    
    public Customer getCustomerByMemberId(String memberId) {
        return customerRepository.findByMemberId(memberId);
    }
    
    public Customer createGuestCustomer(String firstName) {
        Customer guest = new Customer();
        guest.setFirstName(firstName);
        guest.setCustomerType("GUEST");
        return customerRepository.save(guest);
    }
    
    public Customer createMemberCustomer(String firstName, String lastName, String memberId, 
                                       String birthday, String contactDetails) {
        Customer member = new Customer();
        member.setFirstName(firstName);
        member.setLastName(lastName);
        member.setMemberId(memberId);
        member.setBirthday(birthday);
        member.setContactDetails(contactDetails);
        member.setCustomerType("MEMBER");
        return customerRepository.save(member);
    }
} 