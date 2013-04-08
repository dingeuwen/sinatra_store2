require 'pry'
gem 'sinatra', '1.3.0'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'
require 'better_errors'
require 'json'
require 'open-uri'
require 'uri'

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = File.expand_path("..",__FILE__)	
end


before do
  @db = SQLite3::Database.new "store.sqlite3"
  @db.results_as_hash = true
end


#****************INTEGRATING THE TWITTER API**********************
get '/products/search' do
  @q = params[:q]
  file = open("http://search.twitter.com/search.json?q=#{URI.escape(@q)}")
  @results = JSON.load(file.read)
  erb :search_results
end
#*****************************************************************
# WTF why did just moving this code block from the bottom to up here make it work??


#***************INTEGRATING THE GOOGLE PRODUCTS API***************
get '/products/search_google' do 
  @q = params[:q]
  file = open("https://www.googleapis.com/shopping/search/v1/public/products?key=AIzaSyBtm1EPiT8NUSsgTJhBb5dxlhGAi8FvLu4&country=US&q=#{URI.escape(@q)}", :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE)
  @results = JSON.load(file.read)
  erb :search_google
end
#*****************************************************************


get '/' do
  erb :home
end


get '/users' do
  @rs = @db.execute('SELECT * FROM users')
  erb :users
end


get '/products' do
  @rs = @db.execute('SELECT * FROM products')
  erb :products
end

#************CREATING A NEW PRODUCT*******************************
get '/new_product' do
  erb :new_product
end


post '/new_product' do
  @name = params[:new_product_name]
  @price = params[:new_product_price]
  @sale_status = params[:new_product_sale_status]
  sql = "INSERT INTO products ('name', 'price', 'on_sale') VALUES('#{@name}', '#{@price}', '#{@sale_status}')"
  @rs = @db.execute(sql)
  erb :product_created
end
#*****************************************************************

#THIS GOES TO A SINGLE PRODUCTS DETAILS
get '/products/:num' do
  @num = params[:num]
  sqll = "SELECT * FROM products WHERE id='#{@num}';"
  @rs = @db.execute(sqll)
  erb :single_product 
end

#************UPDATING A PRODUCT***********************************
get '/products/:num/update' do
  @num = params[:num]
  sqll = "SELECT * FROM products WHERE id='#{@num}';"
  @rs = @db.execute(sqll)
  erb :update_product
end

post '/products/:num' do
  @num = params[:num]
  @name = params[:updated_product_name]
  @price = params[:updated_product_price]
  @sale_status = params[:updated_product_sale_status]
  sql = "UPDATE products SET name='#{@name}', price='#{@price}', on_sale='#{@sale_status}' WHERE id='#{@num}';"
  @rs = @db.execute(sql)
  erb :product_updated
end
#*****************************************************************


#***********DELETING A PRODUCT************************************
post '/products/:num/delete' do
  @num = params[:num]
  sql = "DELETE FROM products WHERE id='#{@num}';"
  @rs = @db.execute(sql)
  erb :delete_product
end
#*****************************************************************





# to be done: 
#  - Use JSON + the Twitter API to include Twitter search results. Either have a link that goes to Twitter, or integrate the results into my page. 
#  - Use JSON + the Google Products API to include a picture, description, and link to buy for the product on the product detail page.
#  - Use Boostrap CSS to format everything from the menu to the tables and stuff properly

# bug list: 
# - when i delete, the id numbers remain the same. They don't update. ie. if i delete item 16, the remaining items will be like 14, 15, 17 etc. 
# - in updating, the fields should have the existing values as the defaults. else when i leave it blank, it updates to be a blank product. 

# questions: 
#  - how do people make the update and delete button in the whole product table work as opposed to in single product? 