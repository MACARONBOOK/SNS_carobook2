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

* create model(3→ entry,room,chat)
  rails g model ...<br>
  →do migrate
* associations
* + user<br>
  has_many :chats, dependent: :destroy<br>
  has_many :entries, dependent: :destroy
  
* + entry
  belongs_to :user
  belongs_to :room
 
* + room
  has_many :chats, dependent: :destroy
  has_many :entries, dependent: :destroy
 
* + chat (+validation)
  belongs_to :user
  belongs_to :room
  validates :message, presence: true,length:{maximum:140}
 
 
 -- partinal point! --(2case)
 
 -- 1case --
 
 * create controller(2→ rooms,chats)<br>
  rails g controller ...
 
* rewrite on Controller(3)
* + usersCon (※case when need any method)<br>
 @currentUserEntry=Entry.where(user_id: current_user.id)<br>
    @userEntry=Entry.where(user_id: @user.id)<br>
    if current_user.id == @user.id<br>
      @msg ="他のユーザーとDMしてみよう！"<br>
    else<br>
      @currentUserEntry.each do |cu|<br>
        @userEntry.each do |u|<br>
          if cu.room_id == u.room_id then<br>
            @isRoom = true<br>
            @roomId = cu.room_id<br>
          end<br>
        end<br>
      end<br>

      if @isRoom != true<br>
        @room = Room.new<br>
        @entry = Entry.new<br>
      end<br>
    end<br>
  
* + roomsCon<br>
   def create<br>
    @room = Room.create<br>
    @entry1 = Entry.create(room_id: @room.id, user_id: current_user.id)<br>
    @entry2 = Entry.create(params.require(:entry).permit(:user_id, :room_id).merge(room_id: @room.id))<br>
    redirect_to "/rooms/#{@room.id}"<br>
   end<br> 
   def show<br>
    @room = Room.find(params[:id])<br>
    if Entry.where(user_id: current_user.id,room_id: @room.id).present?<br>
      @chats = @room.chats<br>
      @chat = Chat.new<br>
      @entries = @room.entries<br>
    else<br>
      redirect_back(fallback_location: root_path)<br>
    end<br>
    end<br>
   end
 
* + chatsCon<br>
  before_action :authenticate_user!, only: [:create]<br>
  def create<br>
    if Entry.where(user_id: current_user.id, room_id: params[:chat][:room_id]).present?<br>
      @chat = Chat.create(params.require(:chat).permit(:user_id, :message, :room_id).merge(user_id: current_user.id))<br>
    else<br>
      flash[:alert] = "メッセージ送信に失敗しました。"<br>
    end<br>
    redirect_to request.referer<br>
  end
 
* add at routing<br>
  resources :chats, only: [:create]<br>
  resources :rooms, only: [:create, :show]

* create view(rooms/show) ※remove<> <br>
   div class="container" h1 チャットルーム /h1<br>

   h5  i class="fas fa-user-shield" 参加者 /i /h5<br>
   % @entries.each do |e| %<br>
    h6  a href="/users/<%= e.user.id %>"><%= e.user.name%>さん /a  /h6<br>
   % end %<br>

   hr<br>
   % if @chats.present? %<br>
     % @chats.each do |m| %<br>
       strong  %= m.message %  /strong<br>
       small by  strong  a href="/users/ %= m.user_id % "  %= m.user.name % さん /a  /strong  /small<br>
   hr<br>
     % end %<br>
   % else %<br>
     h3 class="text-center" メッセージはまだありません /h3<br>
   % end %<br>
   %= form_with model: @chat do |f| %<br>
     %= f.text_field :message, :placeholder => "メッセージを入力して下さい" , :size => 50 %<br>
     %= f.hidden_field :room_id, :value => @room.id %<br>
   
     %= f.submit "投稿する" %<br>
   % end %<br>
   %= link_to "Users", users_path,class:"fas fa-users"%<br>
   /div

* add at view<br>
  I'll show two-type of description!<br>
* + users/index(→use template, _info(userindex) )<br>
   %= render 'info(userindex)', user: current_user %
* + users/_info(userindex)<br>
   % if current_user != user && current_user.following?(user) && user.following?(current_user) %<br>
     %= link_to 'chatを始める', chat_path(user.id), class: "ml-3" %<br>
   % end %
 
* + users/show(→users/info)<br>
   %= render 'info', user: @user, isRoom: @isRoom, roomId: @roomId, room: @room, entry: @entry %
* + users/_info<br>
   % if current_user.id != user.id %<br>
    % if (current_user.following? user) && (user.following? current_user)  %<br>
    % if isRoom == true %<br>
      p class="user-show-room" a href="/rooms/<%= roomId % " class="btn btn-primary btn-lg" chatへ /a<br>
    % else %<br>
      %= form_for room do |f| %<br>
        %= fields_for entry do |e| %<br>
          %= e.hidden_field :user_id, value: user.id %<br>
        % end %<br>
        td  %= f.submit "chatを始める", class:"btn btn-outline-secondary btn-block user-show-chat"%  /td<br>
      % end %<br>
    % end %<br>
    % end %<br>
  % end %<br>
  <br>
     
 -- 2case --<br>
     
  * rewrite on Controller()
  * 
 
 
