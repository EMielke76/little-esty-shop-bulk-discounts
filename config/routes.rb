Rails.application.routes.draw do
  resources :merchants do
    resources :items, controller: 'merchant_items'
    resources :bulk_discounts, controller: 'merchant_bulk_discounts'
  end

  scope '/admin', as: 'admin' do
    resources :merchants, controller: 'admin_merchants'
  end

  scope '/admin' do
    resources :invoices, controller: 'admin_invoices'
  end



  # get '/merchants/:id/bulk_discounts', to: 'merchant_bulk_discounts#index'
  # get '/merchants/:merchant_id/bulk_discounts/new', to: 'merchant_bulk_discounts#new'
  # get '/merchants/:merchant_id/bulk_discounts/:discount_id', to: 'merchant_bulk_discounts#show'
  # get '/merchants/:merchant_id/bulk_discounts/:discount_id/edit', to: 'merchant__bulk_discounts#edit'
  # post '/merchants/:merchant_id/bulk_discounts', to: 'merchant_bulk_discounts#create'
  # patch '/merchants/:merchant_id/bulk_discounts/:discount_id', to: 'merchant_bulk_discounts#update'
  # delete '/merchants/:merchant_id/bulk_discounts/:discount_id', to: 'merchant_bulk_discounts#destroy'

  get '/merchants/:id/invoices', to: 'merchant_invoices#index'
  get '/merchants/:merchant_id/invoices/:invoice_id', to: 'merchant_invoices#show'
  patch '/merchants/:merchant_id/invoices/:invoice_id/:invoice_item_id', to: 'invoice_items#update'

  get '/merchants/:id/dashboard', to: 'merchants#dashboard'

  get '/admin', to: 'admin#dashboard'

  patch '/admin/invoices/:invoice_id/:invoice_item_id', to: 'admin_invoice_items#update'
end
