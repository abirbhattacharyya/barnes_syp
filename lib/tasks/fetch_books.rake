require 'json'
require 'open-uri'
require 'hpricot'

namespace :get_books do
  desc "fetch books"
  task :get_books => :environment do
      urls =  
        [
        "http://www.barnesandnoble.com/u/nook-books-bestsellers/379003503",
        "http://www.barnesandnoble.com/u/nook-books-bestsellers/379003503?start=21",
        "http://www.barnesandnoble.com/u/nook-books-bestsellers/379003503?start=41",
        "http://www.barnesandnoble.com/u/nook-books-bestsellers/379003503?start=61",
        "http://www.barnesandnoble.com/u/nook-books-bestsellers/379003503?start=81",
        ]
      urls.each_with_index do |url,url_index|
        puts "url: #{url}"
        data = Hpricot.parse(open(url))
        products = data.search("ul[@class=result-set ]/li")
        products.each_with_index do |product,index|
          puts "-"*50
          puts "Product: #{(index + 1) + (url_index * 20)}"
          product_url = product.at("li[@class=title]/a")["href"]
          get_product_info(product_url)          
        end
     end
  end

def get_product_info(url)
  product = Hash.new
  product.clear
  data = Hpricot.parse(open(url))
  product_info = data.at("div[@class=page-content-wrapper box centered-width l2r wide]")
  description = data.at("div[@id=product-commentary-overview-1]")
  desc_info= description.at("section/div") if description
  if desc_info.at("p")
    desc_info = desc_info.at("p").inner_text
  else
    desc_info = desc_info.inner_text
  end
  desc_info.gsub!(/\s+/,' ')
  product["description"] = desc_info
  name = product_info.at("div[@id=product-title-1]/h1").inner_text
  name.gsub!("[NOOK Book]",'\1')
  name.gsub!(/\s+/,' ')
  product["name"] = name.strip
  image_url = product_info.at("div[@class=image-block ]/img")["src"]
  product["front_image_remote_url"] = image_url
  author =  product_info.search("ul[@class=contributors]/li").last.inner_text.strip unless product_info.search("ul[@class=contributors]/li").nil?
  product["author"] = author
  price = product_info.at("div[@class=price hilight]").inner_text if product_info.at("div[@class=price hilight]")
  if price
    reg_price = get_price(price)
    target_price = (reg_price * 0.7).round(2)
  end
  return if reg_price < 5
  product["regular_price"] = reg_price
  product["target_price"] = target_price
  product["product_type"]  = Product::TYPES[:ebooks]
  product["user_id"]  = 1

  puts product.inspect
  product = Product.new(product)
  product.save
end

def get_price(str)
  return nil if str.nil?
  return str.gsub(/[^0-9\.]/, '').to_f
end




desc "create nooks books"
task :nook_books => :environment do
  product1  = Product.new(:product_type => Product::TYPES[:nooks])
  product1.name = "NOOK Simple Touch"
  product1.author= "Barnes & Noble"
  product1.description = "Easiest to use with the world's best reading screen & longest battery life
    * NEW! Best-Text, ultra-crisp, reads just like paper - even in bright sun
    * NEW! Longest battery life - read for over 2 months based on a half hour of daily reading1
    * Over 2.5 million books, get them in seconds w/ built-in Wi-Fi
    * No annoying ads
    * Always free NOOK support in-store
    * Borrow books from your public library"
  product1.user_id  =1
  product1.regular_price = 99
  product1.target_price = 69
  product1.front_image_remote_url = "http://img2.imagesbn.com/images/155950000/155956115.GIF"
  product1.save
  puts "-"*50
  puts "Product 2"
  product2  = Product.new(:product_type => Product::TYPES[:nooks])
  product2.name = "NOOK Simple Touch with GlowLight"
  product2.author= "Barnes & Noble"
  product2.description = "World's #1 Reader now with breakthrough GlowLight:
    * Only Reader designed for perfect bedtime reading
    * Breakthrough technology creates a soft glow optimized for low light reading
    * Warm light illuminates entire screen evenly
    * End bedtime reading debate-when you want to read & your partner wants to sleep
    * GlowLight turns on instantly and adjusts easily with a touch
    * Revolutionary built-in anti-glare screen protector delivers just-like-paper experience - great in bright sun
    * Exclusive Best-Text & adjustable fonts make words crisp & clear
    * Fastest, most advanced E Ink display for seamless page turns
    * Lightest NOOK ever - perfect for long reading sessions and carrying everywhere
    * Unbeatable value: \"2 Readers in 1\" - Best of E Ink & Lit Display - Amazing in bed and at the beach"
  product2.user_id  =1
  product2.regular_price = 139
  product2.target_price = 98
  product2.front_image_remote_url = "http://img2.imagesbn.com/images/170190000/170197913.JPG"
  product2.save

  puts "-"*50
  puts "Product 3"
  product3  = Product.new(:product_type => Product::TYPES[:nooks])
  product3.name = "NOOK Color"
  product3.author= "Barnes & Noble"
  product3.description = "World's Best Reading Experience + Tablet Essentials
    * NEW! Movies & TV Shows from Netflix
    * NEW! NOOK Comics including the largest collection of Marvel graphic novels
    * World's most advanced VividView 7\" touchscreen
    * Over 2.5 million books, magazines, interactive kids' books
    * Must-have apps like Angry Birds, top music services, & more
    * Tablet essentials-email & Web w/video
    * Expandable memory- add up to 32 GB w/ microSD card
    * Always free NOOK support in-store"
  product3.user_id  =1
  product3.regular_price = 169
  product3.target_price = 118
  product3.front_image_remote_url = "http://img2.imagesbn.com/images/150180000/150186864.JPG"
  product3.save

  puts "-"*50
  puts "Product 4"
  product4  = Product.new(:product_type => Product::TYPES[:nooks])
  product4.name = "NOOK Tablet - 8GB"
  product4.author= "Barnes & Noble"
  product4.description = "Our fastest, lightest, most powerful tablet with the best in reading & entertainment, now in 8GB*.
    * Movies, TV shows & music from Netflix, Hulu Plus, Pandora & more
    * Lightning fast web-browsing, email & smooth streaming video
    * Over 2.5 million books, magazines, comics & kids' books
    * Thousands of must-have apps like Angry Birds & Words With Friends
    * World's most advanced VividView 7\" Touchscreen
    * Extra-long battery life - 11.5 hrs of reading or 9 hrs of video
    * 512MB RAM
    * Expandable memory- add up to 32 GB w/ microSD card
    * Always free in-store support"
  product4.user_id  =1
  product4.regular_price = 199
  product4.target_price = 140
  product4.front_image_remote_url = "http://img2.imagesbn.com/images/159220000/159224687.JPG"
  product4.save
  
end
desc "create combo books"
task :combo_books => :environment do

  ebooks = Product.by_product_type(Product::TYPES[:ebooks])
  nooks = Product.by_product_type(Product::TYPES[:nooks])

  unless nooks.empty?
    nooks.each_with_index do |nook,n_index|
      puts "Nook(#{nook.id}) : #{n_index + 1}"
      unless ebooks.empty?        
        ebooks.each_with_index do |ebook,e_index|
          puts "\tEBook(#{ebook.id}) : #{n_index + 1} + #{e_index + 1}"
            product = Product.new(:product_type => Product::TYPES[:combos])
            product.name = nook.name + " + " + ebook.name
            product.description = nook.description + " + " + ebook.description
            product.regular_price = nook.regular_price + ebook.regular_price
            product.target_price = nook.target_price + ebook.target_price
            product.author = ebook.author
            product.front_image_remote_url = File.join("http://localhost:3000",ebook.front_image.url)
            product.back_image_remote_url = File.join("http://localhost:3000",nook.front_image.url)
            product.save
        end
      end
    end
  end

end


end