SimpleFeed::Application.routes.draw do
  match 'posts/search/:keyword' => 'posts#search', via: :get 

  resources :posts do
    resources :comments
  end

  root to: 'home#index'
end
