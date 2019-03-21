Rails.application.routes.draw do
  mount ActionCable.server => '/cable'
  root controller: :welcome, action: :index
  resource :hello, only: [:create]
end
