Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "omniauth_callbacks"
  },
  skip: [ :registrations, :passwords ]

  root "home#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  resources :items do
    resource :judgement, only: %i[update]
    resource :reason, only: %i[update]
  end

  resources :judgements, only: %i[index]

  resources :categories, only: %i[index new create destroy] do
    collection do
      # カテゴリー選択のモーダルのコンテンツを Turbo Frame経由で返す
      get :modal
    end
  end

  # LINEメッセージ通知
  post "/line/webhook", to: "line_webhooks#callback"
end
