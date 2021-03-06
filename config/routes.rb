Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "welcome#index"
  resources :merchant do
    resources :dashboard, only: [:index]
    resources :items
    resources :invoices
    resources :invoice_items, only: [:update]
    resources :bulk_discounts, only: [:index, :show]
  end

  resources :admin, only: [:index]

  namespace :admin do
    resources :merchants, only: [:index, :show, :edit, :update, :new, :create ]
    resources :invoices
  end

  resources :repos, only: [:index]
end
