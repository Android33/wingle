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
          post 'destroy'
          post 'get_current_user'
          post 'change_password'
          post 'deactivate_account'
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
          post 'my_filter_users'
          post 'login_signup'
          post 'userinfo'
          post 'search_with_wingle_id'
          post 'search_with_email_id'
          post 'invite'
          post 'online_users'
          post 'set_gcm_token'
          post 'test_gcm'
          post 'test'
          post 'get_user'
        end
      end

      resources :favourites do
        collection do
          post 'all'
          post 'create'
          post 'destroy'
          post 'favorited_me'
        end
      end

      resources :notifications do
        collection do
          post 'all'
          post 'create'
          post 'destroy'
          post 'like'
        end
      end

      resources :images do
        collection do
          post 'upload_img_with_file'
          post 'upload_image_with_url'
        end
      end

      resources :userinfos do
        collection do
          post 'create'
          post 'update_wingle_id'
        end
      end

      resources :fsettings do
        collection do
          post 'update'
          post 'get'
        end
      end

      resources :nsettings do
        collection do
          post 'update'
          post 'get'
          post 'update_show_my_location'
        end
      end

      resources :chats, only: [] do
        collection do
          post 'create'
          post 'by_user'
          post 'with_user'
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
