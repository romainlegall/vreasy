Rails.application.routes.draw do
  root to: 'messages#index'
  resources :messages
  get 'check_msgs' => 'messages#check_msgs'
end
