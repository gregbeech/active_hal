# ActiveHal

This library lets you write [ActiveModel](http://guides.rubyonrails.org/active_model_basics.html) classes for [JSON-HAL](https://tools.ietf.org/html/draft-kelly-json-hal-08), e.g. the following model...

```ruby
class Order
  include ActiveHal::Model

  hal_attr :id, :total_price

  belongs_to :restaurant
  belongs_to :user, class_name: 'Customer'
  belongs_to :address, rel: 'https://example.org/rels/address'
  has_many :items, class_name: 'OrderItem', rel: 'https://example.org/rels/order-items'
end
```

...could be used to represent the following JSON-HAL.

```json
{
  "_links": {
    "curies": [{
      "name": "eg",
      "href": "https://example.org/rels/{rel}",
      "templated": true
    }],
    "self": {
      "href": "https://example.org/orders/108"
    },
    "restaurant": {
      "href": "https://example.org/restaurants/72"
    },
    "user": {
      "href": "https://example.org/users/38"
    },
    "eg:address": {
      "href": "https://example.org/addresses/82"
    },
    "eg:order-item": [{
      "href": "https://example.org/order-items/382"
    }, {
      "href": "https://example.org/order-items/383"
    }]
  },
  "id": 108,
  "total_price": 12.99
}
```

You can then just use them like normal objects, and any attributes and relations will be loaded automatically.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gregbeech/active_hal. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

