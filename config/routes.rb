Rails.application.routes.draw do

  match '(:anything)' => 'application#nothing', via: [:options]

  devise_for :users

  resources :users do
    collection do
      get 'favorite_churches'
    end
  end

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :sessions, only: [] do
        collection do
          post '/', to: 'sessions#create'
        end
      end

      resources :registrations, only: [] do
        collection do
          post '/', to: 'registrations#create'
        end
      end

      resources :users do
        collection do
          post 'near_users'
          post 'filter_users'
          post 'login_signup'
          post 'userinfo'
        end
      end

      resources :favourites do
        collection do
          post 'all'
          post 'create'
          post 'destroy'
        end
      end

      resources :userinfos do
        collection do
          post 'create'
        end
      end

      resources :chats, only: [] do
        collection do
          post 'create'
          post 'by_user'
        end
      end

      resources :pokes, only: [] do
        collection do
          post 'create'
        end
      end

    end
  end

  # scope '/api' do
  #   scope '/v1' do
  #     get 'sessions', to: 'sessions#create'
  #   end
  # end
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'home#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
