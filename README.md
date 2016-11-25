# ActiveArchiver

Provide export / import to ActiveRecord and support CarrierWave.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_archiver', github:'zaru/active_archiver'
```

And then execute:

    $ bundle

## Usage

### sample code

```
export = User.find(1).export

User.find(1).destroy
User.find(1)
=> ActiveRecord::RecordNotFound: Couldn't find User with 'id'=1

User.import(export)
User.find(1)
=> #<User id: 1, ...>
```

### export

Returns the specified model object as a hash. Images uploaded with CarrierWave are encoded in Base64.

```ruby
export = User.last.export

=> {:attributes=>
  {"id"=>3,
   "last_name"=>"hoge",
   "first_name"=>"piyo",
   "email"=>"hogepiyo@example.com",
   "created_at"=>Sun, 06 Nov 2016 21:04:11 JST +09:00,
   "updated_at"=>Tue, 22 Nov 2016 12:16:28 JST +09:00},
 :associations=>[]}
```

If you want to export related models as well

```ruby
export = User.last.export(includes: [:photos])

=> {:attributes=>
  {"id"=>3,
   "last_name"=>"hoge",
   "first_name"=>"piyo",
   "email"=>"hogepiyo@example.com",
   "created_at"=>Sun, 06 Nov 2016 21:04:11 JST +09:00,
   "updated_at"=>Tue, 22 Nov 2016 12:16:28 JST +09:00},
 :associations=>
   [{:model_name=>"Photo",
     :association_name=>:photos,
     :attributes=>
      {"id"=>57,
       "user_id"=>3,
       "image"=>
        {:url=>"https://example.com/uploads/hoge.png",
         :file_name=>"hoge.png",
         :blob=>
          "data:image/png;base64,iVBORw...
```

To specify a nested model.

```
class User < ApplicationRecord
  has_many :photos
  has_many :pets
end

class Pet < ApplicationRecord
  has_many :pet_photos
end
```

```
export = User.last.export(includes: [:photos, pets:[:pet_photos]])
```

### import

```
User.import(export)
```

### archive

Write the temporary file.

```
Hoge.find(1).archive

=> #<File:/tmp/20161125-12571-ak10w5.json (closed)>
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zaru/active_archiver.

