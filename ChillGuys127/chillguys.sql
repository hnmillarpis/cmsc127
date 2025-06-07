-- create types
CREATE TYPE user_role AS ENUM ('ADMIN', 'MANAGER', 'CASHIER');
CREATE TYPE order_status AS ENUM ('PENDING', 'PREPARING', 'COMPLETED', 'CANCELLED');
CREATE TYPE payment_method AS ENUM ('CASH', 'CARD', 'GCASH', 'PAYMAYA');
CREATE TYPE promo_type AS ENUM ('PERCENTAGE', 'FIXED_AMOUNT');
CREATE TYPE item_type AS ENUM ('BEVERAGE', 'FOOD', 'PASTRY', 'MERCHANDISE');

-- admin table
CREATE TABLE admin (
    admin_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    role VARCHAR(20) DEFAULT 'SUPER_ADMIN',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

-- users table
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role user_role NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- categories table
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    item_type item_type NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- items table
CREATE TABLE items (
    item_id SERIAL PRIMARY KEY,
    item_code VARCHAR(20) UNIQUE NOT NULL, -- Format: XX-YYYY-ZZZ
    auto_code VARCHAR(30) UNIQUE NOT NULL, -- Auto-generated code
    name VARCHAR(100) NOT NULL,
    category_id INTEGER REFERENCES categories(category_id) ON DELETE SET NULL,
    item_type item_type NOT NULL,
    description TEXT,
    image_url VARCHAR(255),
    is_available BOOLEAN DEFAULT TRUE,
    is_customizable BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- item sizes table
CREATE TABLE item_sizes (
    size_id SERIAL PRIMARY KEY,
    item_id INTEGER REFERENCES items(item_id) ON DELETE CASCADE,
    size_name VARCHAR(20) NOT NULL, -- Small, Medium, Large
    base_price DECIMAL(10,2) NOT NULL CHECK (base_price >= 0),
    price_adjustment DECIMAL(10,2) DEFAULT 0.00, -- Additional cost for this size
    is_available BOOLEAN DEFAULT TRUE,
    UNIQUE(item_id, size_name)
);

-- item customizations table
CREATE TABLE item_customizations (
    customization_id SERIAL PRIMARY KEY,
    item_id INTEGER REFERENCES items(item_id) ON DELETE CASCADE,
    customization_name VARCHAR(100) NOT NULL,
    description TEXT,
    additional_cost DECIMAL(10,2) DEFAULT 0.00 CHECK (additional_cost >= 0),
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- add-ons table
CREATE TABLE add_ons (
    addon_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    item_type item_type NOT NULL,
    customization_id INTEGER REFERENCES item_customizations(customization_id) ON DELETE SET NULL,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- members table
CREATE TABLE members (
    member_id VARCHAR(5) PRIMARY KEY CHECK (LENGTH(member_id) = 5), -- 5-character alphanumeric
    membership_id VARCHAR(20) UNIQUE NOT NULL, -- New membership ID field
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    date_of_birth DATE,
    points INTEGER DEFAULT 0 CHECK (points >= 0),
    total_spent DECIMAL(12,2) DEFAULT 0.00 CHECK (total_spent >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- promo codes table
CREATE TABLE promo_codes (
    promo_id SERIAL PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    description VARCHAR(255),
    type promo_type NOT NULL,
    value DECIMAL(10,2) NOT NULL CHECK (value > 0),
    min_order_amount DECIMAL(10,2) DEFAULT 0.00,
    max_discount DECIMAL(10,2),
    usage_limit INTEGER,
    used_count INTEGER DEFAULT 0,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    applicable_item_type item_type, -- Can be NULL for all item types
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (end_date > start_date),
    CHECK (used_count <= usage_limit OR usage_limit IS NULL)
);

-- orders table
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    order_number VARCHAR(20) UNIQUE NOT NULL, -- Format: ORD-YYYYMMDD-XXXX
    member_id VARCHAR(5) REFERENCES members(member_id) ON DELETE SET NULL,
    cashier_id INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
    promo_id INTEGER REFERENCES promo_codes(promo_id) ON DELETE SET NULL,
    is_guest BOOLEAN DEFAULT FALSE,
    guest_name VARCHAR(100), -- For guest orders
    subtotal DECIMAL(12,2) NOT NULL CHECK (subtotal >= 0),
    discount_amount DECIMAL(12,2) DEFAULT 0.00 CHECK (discount_amount >= 0),
    total_amount DECIMAL(12,2) NOT NULL CHECK (total_amount >= 0),
    payment_method payment_method NOT NULL,
    amount_paid DECIMAL(12,2) NOT NULL CHECK (amount_paid >= 0),
    change_amount DECIMAL(12,2) DEFAULT 0.00 CHECK (change_amount >= 0),
    status order_status DEFAULT 'PENDING',
    points_earned INTEGER DEFAULT 0,
    points_used INTEGER DEFAULT 0,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    notes TEXT,
    CHECK (
        (is_guest = TRUE AND guest_name IS NOT NULL AND member_id IS NULL) OR
        (is_guest = FALSE AND member_id IS NOT NULL AND guest_name IS NULL) OR
        (is_guest = FALSE AND member_id IS NULL AND guest_name IS NULL)
    )
);

-- order items table
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
    item_id INTEGER REFERENCES items(item_id) ON DELETE RESTRICT,
    size_id INTEGER REFERENCES item_sizes(size_id) ON DELETE SET NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    total_price DECIMAL(10,2) NOT NULL CHECK (total_price >= 0),
    special_instructions TEXT
);

-- order item ddd-ons table
CREATE TABLE order_item_addons (
    order_item_id INTEGER REFERENCES order_items(order_item_id) ON DELETE CASCADE,
    addon_id INTEGER REFERENCES add_ons(addon_id) ON DELETE RESTRICT,
    customization_id INTEGER REFERENCES item_customizations(customization_id) ON DELETE SET NULL,
    quantity INTEGER DEFAULT 1 CHECK (quantity > 0),
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    PRIMARY KEY (order_item_id, addon_id)
);

-- create inventory table
CREATE TABLE inventory (
    inventory_id SERIAL PRIMARY KEY,
    item_id INTEGER REFERENCES items(item_id) ON DELETE CASCADE,
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0),
    reorder_level INTEGER DEFAULT 10,
    last_restocked TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- audit log table
CREATE TABLE audit_logs (
    log_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
    action VARCHAR(50) NOT NULL, -- INSERT, UPDATE, DELETE
    table_name VARCHAR(50) NOT NULL,
    record_id INTEGER,
    old_values JSONB,
    new_values JSONB,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- updated at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- auto_code generation function
CREATE OR REPLACE FUNCTION generate_auto_code()
RETURNS TRIGGER AS $$
DECLARE
    category_prefix VARCHAR(3);
    sequence_num INTEGER;
    new_auto_code VARCHAR(30);
BEGIN
    -- category prefix based on item_type
    SELECT
        CASE NEW.item_type
            WHEN 'BEVERAGE' THEN 'BEV'
            WHEN 'FOOD' THEN 'FOD'
            WHEN 'PASTRY' THEN 'PST'
            WHEN 'MERCHANDISE' THEN 'MER'
            ELSE 'ITM'
        END INTO category_prefix;

    -- next sequence number for this item type
    SELECT COALESCE(MAX(
        CAST(
            SUBSTRING(auto_code FROM LENGTH(category_prefix) + 2 FOR 6) AS INTEGER
        )
    ), 0) + 1
    INTO sequence_num
    FROM items
    WHERE item_type = NEW.item_type;

    -- generate auto_code: PREFIX-NNNNNN
    new_auto_code := category_prefix || '-' || LPAD(sequence_num::TEXT, 6, '0');

    NEW.auto_code := new_auto_code;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- triggers for updated_at columns
CREATE TRIGGER update_admin_updated_at BEFORE UPDATE ON admin
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_items_updated_at BEFORE UPDATE ON items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_item_customizations_updated_at BEFORE UPDATE ON item_customizations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_add_ons_updated_at BEFORE UPDATE ON add_ons
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_members_updated_at BEFORE UPDATE ON members
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_inventory_updated_at BEFORE UPDATE ON inventory
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- trigger for auto_code generation
CREATE TRIGGER generate_item_auto_code BEFORE INSERT ON items
    FOR EACH ROW EXECUTE FUNCTION generate_auto_code();

-- indexes for better performance
CREATE INDEX idx_items_category ON items(category_id);
CREATE INDEX idx_items_available ON items(is_available);
CREATE INDEX idx_items_type ON items(item_type);
CREATE INDEX idx_items_customizable ON items(is_customizable);
CREATE INDEX idx_orders_member ON orders(member_id);
CREATE INDEX idx_orders_cashier ON orders(cashier_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_guest ON orders(is_guest);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_item ON order_items(item_id);
CREATE INDEX idx_members_email ON members(email);
CREATE INDEX idx_members_membership ON members(membership_id);
CREATE INDEX idx_promo_codes_code ON promo_codes(code);
CREATE INDEX idx_promo_codes_active ON promo_codes(is_active);
CREATE INDEX idx_promo_codes_item_type ON promo_codes(applicable_item_type);
CREATE INDEX idx_add_ons_type ON add_ons(item_type);
CREATE INDEX idx_categories_type ON categories(item_type);

-- view for order summary
CREATE VIEW order_summary AS
SELECT
    o.order_id,
    o.order_number,
    CASE
        WHEN o.is_guest THEN o.guest_name
        ELSE CONCAT(m.first_name, ' ', m.last_name)
    END as customer_name,
    u.full_name as cashier_name,
    o.subtotal,
    o.discount_amount,
    o.total_amount,
    o.payment_method,
    o.status,
    o.order_date,
    COUNT(oi.order_item_id) as item_count
FROM orders o
LEFT JOIN members m ON o.member_id = m.member_id
LEFT JOIN users u ON o.cashier_id = u.user_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.order_number, o.is_guest, o.guest_name,
         m.first_name, m.last_name, u.full_name,
         o.subtotal, o.discount_amount, o.total_amount, o.payment_method, o.status, o.order_date;

-- view for item sales report
CREATE VIEW item_sales_report AS
SELECT
    i.item_id,
    i.item_code,
    i.auto_code,
    i.name as item_name,
    i.item_type,
    c.name as category_name,
    SUM(oi.quantity) as total_quantity_sold,
    SUM(oi.total_price) as total_revenue,
    AVG(oi.unit_price) as avg_price
FROM items i
LEFT JOIN categories c ON i.category_id = c.category_id
LEFT JOIN order_items oi ON i.item_id = oi.item_id
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'COMPLETED'
GROUP BY i.item_id, i.item_code, i.auto_code, i.name, i.item_type, c.name;

-- view for customizable items
CREATE VIEW customizable_items AS
SELECT
    i.item_id,
    i.auto_code,
    i.name as item_name,
    i.item_type,
    ic.customization_id,
    ic.customization_name,
    ic.additional_cost,
    COUNT(ao.addon_id) as available_addons
FROM items i
JOIN item_customizations ic ON i.item_id = ic.item_id
LEFT JOIN add_ons ao ON ic.customization_id = ao.customization_id AND ao.is_available = TRUE
WHERE i.is_customizable = TRUE AND i.is_available = TRUE
GROUP BY i.item_id, i.auto_code, i.name, i.item_type, ic.customization_id, ic.customization_name, ic.additional_cost;

-- comments
COMMENT ON DATABASE database IS 'Updated Coffee Shop Point of Sale System Database with Customization Support';
COMMENT ON TABLE admin IS 'System administrators with super admin privileges';
COMMENT ON TABLE users IS 'System users (Admin, Manager, Cashier)';
COMMENT ON TABLE items IS 'Menu items with auto-generated codes and customization support';
COMMENT ON TABLE item_customizations IS 'Available customizations for items';
COMMENT ON TABLE members IS 'Customer membership with membership ID';
COMMENT ON TABLE orders IS 'Order transactions supporting both member and guest orders';
COMMENT ON TABLE promo_codes IS 'Promotional discount codes with item type restrictions';
COMMENT ON TABLE add_ons IS 'Add-ons categorized by item type and customization';

-- message
DO $$
BEGIN
    RAISE NOTICE 'Updated Coffee Shop POS Database schema created successfully!';
    RAISE NOTICE 'New features added:';
    RAISE NOTICE '- Item type categorization';
    RAISE NOTICE '- Item customization system';
    RAISE NOTICE '- Guest order support';
    RAISE NOTICE '- Membership ID tracking';
    RAISE NOTICE '- Admin table';
    RAISE NOTICE '- Auto-code generation';
    RAISE NOTICE '- Item type-specific promo codes';
END $$;