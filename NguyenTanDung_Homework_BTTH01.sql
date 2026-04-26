create database homework_holiday;

use homework_holiday;

-- bảng khách hàng
create table customers (
    id int auto_increment primary key,
    full_name varchar(100) not null,
    phone varchar(15) unique not null,
    address varchar(255),
    customer_type enum('normal', 'vip') not null default 'normal'
);

-- bảng sản phẩm
create table products (
    id int auto_increment primary key,
    product_name varchar(150) not null,
    category varchar(100) not null,
    price decimal(10, 2) not null check (price >= 0),
    stock int not null default 0 check (stock >= 0)
);

-- bảng đơn hàng
create table orders (
    id int auto_increment primary key,
    customer_id int not null,
    order_date date not null default (current_date),
    status enum('completed', 'cancelled') not null default 'completed',
    foreign key (customer_id) references customers(id)
);

-- bảng chi tiết đơn hàng
create table order_details (
    id int auto_increment primary key,
    order_id int not null,
    product_id int not null,
    quantity int not null check (quantity > 0),
    total_price decimal(10, 2) not null check (total_price >= 0),
    foreign key (order_id) references orders(id),
    foreign key (product_id) references products(id)
);

-- 7 khách hàng: 2 vip, 2 chưa từng mua hàng (id 6, 7)
insert into customers (full_name, phone, address, customer_type) values
('nguyen van an',     '0901234567', '12 lý thường kiệt, hà nội',    'vip'),
('tran thi bich',     '0912345678', '45 trần phú, đà nẵng',         'vip'),
('le van cuong',      '0923456789', '78 nguyễn huệ, tp.hcm',        'normal'),
('pham thi dung',     '0934567890', '23 đinh tiên hoàng, hà nội',   'normal'),
('hoang minh duc',    '0945678901', '56 lê lợi, huế',               'normal'),
('vo thi em',         '0956789012', '90 phan chu trinh, hải phòng', 'normal'),  -- chưa mua hàng
('nguyen thi phuong', '0967890123', '14 bà triệu, hà nội',          'normal'); -- chưa mua hàng

-- 10 sản phẩm: 3 danh mục (thực phẩm, đồ uống, gia dụng), sp id=3 có stock = 0
insert into products (product_name, category, price, stock) values
('gạo st25 5kg',          'thực phẩm', 120000,  50),   -- id 1
('mì gói hảo hảo (thùng)','thực phẩm',  85000, 100),   -- id 2
('dầu ăn neptune 1l',     'thực phẩm',  45000,   0),   -- id 3: hết hàng cố ý
('nước mắm chinsu 500ml', 'thực phẩm',  32000,  75),   -- id 4
('nước suối lavie 500ml', 'đồ uống',     6000, 200),   -- id 5
('bia tiger 330ml (lốc)', 'đồ uống',    75000,  60),   -- id 6
('nước ngọt pepsi 1.5l',  'đồ uống',    22000,  80),   -- id 7
('nước tăng lực redbull', 'đồ uống',    12000, 150),   -- id 8
('chổi lau nhà',          'gia dụng',   85000,  30),   -- id 9
('nước rửa bát sunlight',  'gia dụng',  28000,  90);   -- id 10

-- 5 đơn hàng: 1 đơn cancelled (id 4), khách id 6 và 7 không có đơn nào
insert into orders (customer_id, order_date, status) values
(1, '2025-04-01', 'completed'),   -- id 1
(2, '2025-04-05', 'completed'),   -- id 2
(3, '2025-04-10', 'completed'),   -- id 3
(4, '2025-04-12', 'cancelled'),   -- id 4: đơn bị huỷ
(5, '2025-04-15', 'completed');   -- id 5

-- 12 chi tiết đơn hàng: đơn id 1 có 3 sp, đơn id 2 có 2 sp
insert into order_details (order_id, product_id, quantity, total_price) values
-- đơn 1: 3 sản phẩm
(1, 1,  2, 240000),
(1, 5, 10,  60000),
(1, 9,  1,  85000),
-- đơn 2: 2 sản phẩm
(2, 6,  3, 225000),
(2, 7,  2,  44000),
-- đơn 3: 2 sản phẩm
(3, 2,  1,  85000),
(3, 10, 2,  56000),
-- đơn 4: 2 sản phẩm (đơn cancelled)
(4, 4,  3,  96000),
(4, 8,  5,  60000),
-- đơn 5: 3 sản phẩm
(5, 1,  1, 120000),
(5, 2,  2, 170000),
(5, 5,  6,  36000);

-- khách vừa mua 5 sản phẩm id = 1, cập nhật tồn kho
update products
set stock = stock - 5
where id = 1;

-- BTTH02
-- yêu cầu 1: sản phẩm danh mục 'đồ uống', giá 10.000đ - 50.000đ, còn hàng
select id, product_name, category, price, stock
from products
where category = 'đồ uống'
  and price between 10000 and 50000
  and stock > 0;

-- yêu cầu 2: khách hàng họ 'nguyễn' hoặc địa chỉ ở 'hà nội'
select id, full_name, phone, address, customer_type
from customers
where full_name like 'nguyen%'
   or address like '%hà nội%';

-- yêu cầu 3: danh sách đơn hàng kèm tên khách, mới nhất lên đầu
select
    o.id          as mã_đơn,
    o.order_date  as ngày_mua,
    o.status      as trạng_thái,
    c.full_name   as tên_khách_hàng
from orders o
join customers c on o.customer_id = c.id
order by o.order_date desc;

-- yêu cầu 4: biên lai chi tiết hóa đơn (tên kh, ngày mua, tên sp, số lượng, đơn giá)
select
    c.full_name    as tên_khách_hàng,
    o.order_date   as ngày_mua,
    p.product_name as tên_sản_phẩm,
    od.quantity    as số_lượng,
    p.price        as đơn_giá
from order_details od
join orders   o on od.order_id   = o.id
join customers c on o.customer_id = c.id
join products  p on od.product_id = p.id
order by o.id, p.product_name;

-- yêu cầu 5: khách hàng chưa từng mua đơn hàng nào (gửi mã giảm giá)
select id, full_name, phone, address, customer_type
from customers
where id not in (
    select distinct customer_id from orders
);