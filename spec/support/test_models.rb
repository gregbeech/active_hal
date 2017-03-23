# frozen_string_literal: true
class Address
  include ActiveHal::Model

  hal_attr :id, :line1
end

class Customer
  include ActiveHal::Model

  hal_attr :id, :first_name
end

class Order
  include ActiveHal::Model

  hal_attr :id, :total_price

  belongs_to :restaurant
  belongs_to :user, class_name: 'Customer'
  belongs_to :address, rel: 'https://example.org/rels/address'
  has_many :items, class_name: 'OrderItem', rel: 'https://example.org/rels/order-items'
end

class OrderItem
  include ActiveHal::Model

  hal_attr :id, :name
end

class Restaurant
  include ActiveHal::Model

  hal_attr :id, :name
end
