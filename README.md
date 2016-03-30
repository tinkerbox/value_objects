# ValueObjects

Serializable and validatable value objects for ActiveRecord

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'value_objects'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install value_objects

## Usage

### Create the value object class

The value object class inherits from `ValueObjects::Value`, and attributes are defined with `attr_accessor`:

```ruby
class AddressValue < ValueObjects::Value
  attr_accessor :street, :postcode, :city
end

address = AddressValue.new(street: '123 Big Street', postcode: '12345', city: 'Metropolis')
address.street # => "123 Big Street"
address.street = '321 Main St' # => "321 Main St"
address.to_hash # => {:street=>"321 Main St", :postcode=>"12345", :city=>"Metropolis"}
```

### Add validations

Validations can be added using the DSL from `ActiveModel::Validations`:

```ruby
class AddressValue < ValueObjects::Value
  attr_accessor :street, :postcode, :city
  validates :postcode, presence: true
end

address = AddressValue.new(street: '123 Big Street', city: 'Metropolis')
address.valid? # => false
address.errors.to_h # => {:postcode=>"can't be blank"}
address.postcode = '12345' # => "12345"
address.valid? # => true
address.errors.to_h # => {}
```

### Serialization with ActiveRecord

The value object class can be used as the coder for the `serialize` method:

```ruby
class Customer < ActiveRecord::Base
  serialize :home_address, AddressValue
end

customer = Customer.new
customer.home_address = AddressValue.new(street: '123 Big Street', postcode: '12345', city: 'Metropolis')
customer.save
customer.reload
customer.home_address # => #<AddressValue:0x00ba9876543210 @street="123 Big Street", @postcode="12345", @city="Metropolis">
```

### Validation with ActiveRecord

By default, validating the record does not automatically validate the value object.
Use the `ValueObjects::ValidValidator` to make this automatic:

```ruby
class Customer < ActiveRecord::Base
  serialize :home_address, AddressValue
  validates :home_address, 'value_objects/valid': true
  validates :home_address, presence: true # other validations are allowed too
end

customer = Customer.new
customer.home_address = AddressValue.new(street: '123 Big Street', city: 'Metropolis')
customer.valid? # => false
customer.errors.to_h # => {:home_address=>"is invalid"}
customer.home_address.errors.to_h # => {:postcode=>"can't be blank"}
customer = Customer.new
customer.valid? # => false
customer.errors.to_h # => {:home_address=>"can't be blank"}
```

### With `ValueObjects::ActiveRecord`

For easy set up of both serialization and validation, `include ValueObjects::ActiveRecord` and invoke `value_object`:

```ruby
class Customer < ActiveRecord::Base
  include ValueObjects::ActiveRecord
  value_object :home_address, AddressValue
  validates :home_address, presence: true
end
```

This basically works the same way but also defines the `<attribute>_attributes=` method which can be used to assign the value object using a hash:

```ruby
customer.home_address_attributes = { street: '321 Main St', postcode: '54321', city: 'Micropolis' }
customer.home_address # => #<AddressValue:0x00ba9876503210 @street="321 Main St", @postcode="54321", @city="Micropolis">
```

This is functionally similar to what `accepts_nested_attributes_for` does for associations.

### Value object collections

Serialization and validation of value object collections are also supported.

First, create a nested `Collection` class that inherits from `ValueObjects::Value::Collection`:

```ruby
class AddressValue < ValueObjects::Value
  attr_accessor :street, :postcode, :city
  validates :postcode, presence: true

  class Collection < Collection
  end
end
```

Then use the nested `Collection` class as the serialization coder:

```ruby
class Customer < ActiveRecord::Base
  include ValueObjects::ActiveRecord
  value_object :addresses, AddressValue::Collection
  validates :addresses, presence: true
end

customer = Customer.new(addresses: [])
customer.valid? # => false
customer.errors.to_h # => {:addresses=>"can't be blank"}
customer.addresses << AddressValue.new(street: '123 Big Street', postcode: '12345', city: 'Metropolis')
customer.valid? # => true
customer.addresses << AddressValue.new(street: '321 Main St', city: 'Micropolis')
customer.valid? # => false
customer.errors.to_h # => {:addresses=>"is invalid"}
customer.addresses[1].errors.to_h # => {:postcode=>"can't be blank"}
```

The `<attribute>_attributes=` method also functions in much the same way:

```ruby
customer.addresses_attributes = { '0' => { city: 'Micropolis' }, '1' => { city: 'Metropolis' } }
customer.addresses # => [#<AddressValue:0x00ba9876543210 @city="Micropolis">, #<AddressValue:0x00ba9876503210 @city="Metropolis">]
```

Except, items with '-1' keys are considered as dummy items and ignored:

```ruby
customer.addresses_attributes = { '0' => { city: 'Micropolis' }, '-1' => { city: 'Metropolis' } }
customer.addresses # => [#<AddressValue:0x00ba9876543210 @city="Micropolis">]
```

This is useful when data is submitted via standard HTML forms encoded with the 'application/x-www-form-urlencoded' media type (which cannot represent empty collections). To work around this, a dummy item can be added to the collection with it's key set to '-1' and it will conveniently be ignored when assigned to the value object collection.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

