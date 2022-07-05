# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
# SNS_carobook2

+ first commit → made format(use simply)
+ second commit → add like-it & comment function with js
+ third~sixth commit → add follow & search function & recover
<br>

 # Search_function(other style)
 
* create controller<br>
  rails g controller searches
  
* define search-action on SearchCon(conditional branch)
* + search-model→ params[:model]、method→ params[:content]、word→ params[:method]<br>  
  def search<br>
   @model = params[:model]<br>
   @content = params[:content]<br>
   @method = params[:method]<br>
   if @model == 'user'<br>
      @records = User.search_for(@content, @method)<br>
    else<br>
      @records = Book.search_for(@content, @method)<br>
    end<br>
  end<br>
 
  
* add at routing  <br>
  get 'search' => 'searches#search'
  
* add render on Application.html.erb(above the yield)<br>
  <div class="d-flex justify-content-center mb-2"><br>
    <%= render 'searches/form' %>  <br>
  </div><br>

* create template(searches/_form)
* + conditional branch<br>
  (f.text_field :content)<br>
  (f.select :model)<br>
  (f.select :method)<br>

* write define on each model(user,book)(search-method-branch)<br>
  perfect,forward,backward,partial<br>

* + user.rb<br>
  def self.search_for(content, method)<br>
    if method == 'perfect'<br>
      User.where(name: content)<br>
    elsif method == 'forward'<br>
      User.where('name LIKE ?', content + '%')<br>
    elsif method == 'backward'<br>
      User.where('name LIKE ?', '%' + content)<br>
    else<br>
      User.where('name LIKE ?', '%' + content + '%')<br>
    end<br>
  end<br>
end
  
* + book.rb <br>
  def self.search_for(content, method)<br>
    if method == 'perfect'<br>
      Book.where(title: content)<br>
    elsif method == 'forward'<br>
      Book.where('title LIKE ?', content+'%')<br>
    elsif method == 'backward'<br>
      Book.where('title LIKE ?', '%'+content)<br>
    else<br>
      Book.where('title LIKE ?', '%'+content+'%')<br>
    end<br>
  end

* write view(searches/search_result)※remove<><br>
  h2 Results index /h2<br>

  table class="table table-hover table-inverse"<br>
  --検索対象モデルがUserの時 --<br>
  % if @model == "user" %<br>
    h3 Users search for " %= @content % " h3<br>
      % @users.each do |user| %<br>
        tr<br>
          td %= user.name % /td <br>
        /tr<br>
      % end %<br>
  
   --検索対象モデルがUserではない時(= 検索対象モデルがBookの時) --<br>
    % elsif @model == 'book' %<br>
    h3 Books search for " %= @content % " h3<br>
      % @books.each do |book| %<br>
        tr<br>
          td %= book.title % /td<br>
          td %= book.body % /td<br>
        /tr<br>
      % end %<br>
  % end %<br>
  /table<br>


# +α like-it_function (weekly-ranking)

* rewrite at index-action BookCon<br>
  def index<br>
    to  = Time.current.at_end_of_day<br>
    from  = (to - 6.day).at_beginning_of_day<br>
    @books = Book.all.sort {|a,b|<br>
      b.favorites.where(created_at: from...to).size <=><br>
      a.favorites.where(created_at: from...to).size<br>
    }<br>
    @book = Book.new<br>
  end

* add at book.rb<br>
  has_many :week_favorites, -> { where(created_at: ((Time.current.at_end_of_day - 6.day).at_beginning_of_day)..   (Time.current.at_end_of_day)) }, class_name: 'Favorite'

* rewrite at favorites/btn<br>
  book.favorites.count → book.week_favorites.count<br>
  
# DM_function 
It just one-to-one relation.(many-to-many relation have other-style.)

* create model(3)
* association
* + user

* + entry 
* + room
* + chat

* rewrite on Controller(3)
* + users
* + rooms
* + chats

* add at routing

* create view(rooms/show)

* add at view<br>
  I'll show two-type of description!
* + users/index(→not to use template)
* + users/show(→users/info)
