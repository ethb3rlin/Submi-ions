# == Route Map
#
#                                   Prefix Verb   URI Pattern                                                                                       Controller#Action
#                                    votes GET    /votes(.:format)                                                                                  votes#index
#                                          POST   /votes(.:format)                                                                                  votes#create
#                                 new_vote GET    /votes/new(.:format)                                                                              votes#new
#                                edit_vote GET    /votes/:id/edit(.:format)                                                                         votes#edit
#                                     vote GET    /votes/:id(.:format)                                                                              votes#show
#                                          PATCH  /votes/:id(.:format)                                                                              votes#update
#                                          PUT    /votes/:id(.:format)                                                                              votes#update
#                                          DELETE /votes/:id(.:format)                                                                              votes#destroy
#                       complete_judgement POST   /judgements/:id/complete(.:format)                                                                judgements#complete
#                        no_show_judgement POST   /judgements/:id/no_show(.:format)                                                                 judgements#no_show
#                               judgements GET    /judgements(.:format)                                                                             judgements#index
#                                          POST   /judgements(.:format)                                                                             judgements#create
#                            new_judgement GET    /judgements/new(.:format)                                                                         judgements#new
#                           edit_judgement GET    /judgements/:id/edit(.:format)                                                                    judgements#edit
#                                judgement GET    /judgements/:id(.:format)                                                                         judgements#show
#                                          PATCH  /judgements/:id(.:format)                                                                         judgements#update
#                                          PUT    /judgements/:id(.:format)                                                                         judgements#update
#                                          DELETE /judgements/:id(.:format)                                                                         judgements#destroy
#           user_verify_zupass_credentials GET    /users/:user_id/verify_zupass_credentials(.:format)                                               users#verify_zupass_credentials
#                                edit_user GET    /users/:id/edit(.:format)                                                                         users#edit
#                                     user PATCH  /users/:id(.:format)                                                                              users#update
#                                          PUT    /users/:id(.:format)                                                                              users#update
#                               admin_root GET    /admin(.:format)                                                                                  admin/admin#index
#                           admin_settings GET    /admin/settings(.:format)                                                                         admin/admin#settings
#                  admin_update_start_time PATCH  /admin/update_start_time(.:format)                                                                admin/admin#update_start_time
#                       admin_update_stage PATCH  /admin/update_stage(.:format)                                                                     admin/admin#update_hackathon_stage
#                         admin_reschedule POST   /admin/reschedule(.:format)                                                                       admin/admin#reschedule
#              admin_user_ethereum_address POST   /admin/users/:user_id/ethereum_address(.:format)                                                  admin/ethereum_addresses#create
#      admin_user_destroy_ethereum_address DELETE /admin/users/:user_id/ethereum_address/:id(.:format)                                              admin/ethereum_addresses#destroy
#                       admin_user_approve PATCH  /admin/users/:user_id/approve(.:format)                                                           admin/users#manually_approve
#                     admin_user_unapprove DELETE /admin/users/:user_id/unapprove(.:format)                                                         admin/users#unapprove
#                              admin_users GET    /admin/users(.:format)                                                                            admin/users#index
#                                          POST   /admin/users(.:format)                                                                            admin/users#create
#                           new_admin_user GET    /admin/users/new(.:format)                                                                        admin/users#new
#                          edit_admin_user GET    /admin/users/:id/edit(.:format)                                                                   admin/users#edit
#                               admin_user GET    /admin/users/:id(.:format)                                                                        admin/users#show
#                                          PATCH  /admin/users/:id(.:format)                                                                        admin/users#update
#                                          PUT    /admin/users/:id(.:format)                                                                        admin/users#update
#                                          DELETE /admin/users/:id(.:format)                                                                        admin/users#destroy
#                     admin_judging_breaks POST   /admin/judging_breaks(.:format)                                                                   admin/judging_breaks#create
#                      admin_judging_break PATCH  /admin/judging_breaks/:id(.:format)                                                               admin/judging_breaks#update
#                                          PUT    /admin/judging_breaks/:id(.:format)                                                               admin/judging_breaks#update
#                                          DELETE /admin/judging_breaks/:id(.:format)                                                               admin/judging_breaks#destroy
#                        admin_submissions GET    /admin/submissions(.:format)                                                                      admin/submissions#index
#                      admin_judging_teams GET    /admin/judging_teams(.:format)                                                                    admin/judging_teams#index
#                                          POST   /admin/judging_teams(.:format)                                                                    admin/judging_teams#create
#                   new_admin_judging_team GET    /admin/judging_teams/new(.:format)                                                                admin/judging_teams#new
#                  edit_admin_judging_team GET    /admin/judging_teams/:id/edit(.:format)                                                           admin/judging_teams#edit
#                       admin_judging_team GET    /admin/judging_teams/:id(.:format)                                                                admin/judging_teams#show
#                                          PATCH  /admin/judging_teams/:id(.:format)                                                                admin/judging_teams#update
#                                          PUT    /admin/judging_teams/:id(.:format)                                                                admin/judging_teams#update
#                                          DELETE /admin/judging_teams/:id(.:format)                                                                admin/judging_teams#destroy
#                 admin_generate_fake_data POST   /admin/generate_fake_data(.:format)                                                               admin/admin#generate_fake_data
#                      admin_wipe_all_data DELETE /admin/wipe_all_data(.:format)                                                                    admin/admin#wipe_all_data
#                                  sign_in POST   /sign_in(.:format)                                                                                sessions#sign_in
#                                 sign_out DELETE /sign_out(.:format)                                                                               sessions#sign_out
#                   submission_add_comment POST   /submissions/:submission_id/add_comment(.:format)                                                 submissions#add_comment
#                      results_submissions GET    /submissions/results(.:format)                                                                    submissions#results
#                              submissions GET    /submissions(.:format)                                                                            submissions#index
#                                          POST   /submissions(.:format)                                                                            submissions#create
#                           new_submission GET    /submissions/new(.:format)                                                                        submissions#new
#                          edit_submission GET    /submissions/:id/edit(.:format)                                                                   submissions#edit
#                               submission GET    /submissions/:id(.:format)                                                                        submissions#show
#                                          PATCH  /submissions/:id(.:format)                                                                        submissions#update
#                                          PUT    /submissions/:id(.:format)                                                                        submissions#update
#                                          DELETE /submissions/:id(.:format)                                                                        submissions#destroy
#                       hacking_team_leave DELETE /teams/:hacking_team_id/leave(.:format)                                                           hacking_teams#leave
#                       hacking_team_apply POST   /teams/:hacking_team_id/apply(.:format)                                                           hacking_teams#apply
#                      hacking_team_accept POST   /teams/:hacking_team_id/accept/:id(.:format)                                                      hacking_teams#accept
#                      hacking_team_reject DELETE /teams/:hacking_team_id/reject/:id(.:format)                                                      hacking_teams#reject
#                    hacking_team_unreject POST   /teams/:hacking_team_id/unreject/:id(.:format)                                                    hacking_teams#unreject
#               hacking_team_admin_members GET    /teams/:hacking_team_id/admin_members(.:format)                                                   hacking_teams#admin_members
#                   hacking_team_force_add POST   /teams/:hacking_team_id/force_add(.:format)                                                       hacking_teams#force_add
#                        hacking_team_kick DELETE /teams/:hacking_team_id/kick/:id(.:format)                                                        hacking_teams#kick
#                            hacking_teams GET    /teams(.:format)                                                                                  hacking_teams#index
#                                          POST   /teams(.:format)                                                                                  hacking_teams#create
#                         new_hacking_team GET    /teams/new(.:format)                                                                              hacking_teams#new
#                        edit_hacking_team GET    /teams/:id/edit(.:format)                                                                         hacking_teams#edit
#                             hacking_team GET    /teams/:id(.:format)                                                                              hacking_teams#show
#                                          PATCH  /teams/:id(.:format)                                                                              hacking_teams#update
#                                          PUT    /teams/:id(.:format)                                                                              hacking_teams#update
#                                          DELETE /teams/:id(.:format)                                                                              hacking_teams#destroy
#                       rails_health_check GET    /up(.:format)                                                                                     rails/health#show
#                                     root GET    /                                                                                                 users#home
#         turbo_recede_historical_location GET    /recede_historical_location(.:format)                                                             turbo/native/navigation#recede
#         turbo_resume_historical_location GET    /resume_historical_location(.:format)                                                             turbo/native/navigation#resume
#        turbo_refresh_historical_location GET    /refresh_historical_location(.:format)                                                            turbo/native/navigation#refresh
#            rails_postmark_inbound_emails POST   /rails/action_mailbox/postmark/inbound_emails(.:format)                                           action_mailbox/ingresses/postmark/inbound_emails#create
#               rails_relay_inbound_emails POST   /rails/action_mailbox/relay/inbound_emails(.:format)                                              action_mailbox/ingresses/relay/inbound_emails#create
#            rails_sendgrid_inbound_emails POST   /rails/action_mailbox/sendgrid/inbound_emails(.:format)                                           action_mailbox/ingresses/sendgrid/inbound_emails#create
#      rails_mandrill_inbound_health_check GET    /rails/action_mailbox/mandrill/inbound_emails(.:format)                                           action_mailbox/ingresses/mandrill/inbound_emails#health_check
#            rails_mandrill_inbound_emails POST   /rails/action_mailbox/mandrill/inbound_emails(.:format)                                           action_mailbox/ingresses/mandrill/inbound_emails#create
#             rails_mailgun_inbound_emails POST   /rails/action_mailbox/mailgun/inbound_emails/mime(.:format)                                       action_mailbox/ingresses/mailgun/inbound_emails#create
#           rails_conductor_inbound_emails GET    /rails/conductor/action_mailbox/inbound_emails(.:format)                                          rails/conductor/action_mailbox/inbound_emails#index
#                                          POST   /rails/conductor/action_mailbox/inbound_emails(.:format)                                          rails/conductor/action_mailbox/inbound_emails#create
#        new_rails_conductor_inbound_email GET    /rails/conductor/action_mailbox/inbound_emails/new(.:format)                                      rails/conductor/action_mailbox/inbound_emails#new
#            rails_conductor_inbound_email GET    /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                                      rails/conductor/action_mailbox/inbound_emails#show
# new_rails_conductor_inbound_email_source GET    /rails/conductor/action_mailbox/inbound_emails/sources/new(.:format)                              rails/conductor/action_mailbox/inbound_emails/sources#new
#    rails_conductor_inbound_email_sources POST   /rails/conductor/action_mailbox/inbound_emails/sources(.:format)                                  rails/conductor/action_mailbox/inbound_emails/sources#create
#    rails_conductor_inbound_email_reroute POST   /rails/conductor/action_mailbox/:inbound_email_id/reroute(.:format)                               rails/conductor/action_mailbox/reroutes#create
# rails_conductor_inbound_email_incinerate POST   /rails/conductor/action_mailbox/:inbound_email_id/incinerate(.:format)                            rails/conductor/action_mailbox/incinerates#create
#                       rails_service_blob GET    /rails/active_storage/blobs/redirect/:signed_id/*filename(.:format)                               active_storage/blobs/redirect#show
#                 rails_service_blob_proxy GET    /rails/active_storage/blobs/proxy/:signed_id/*filename(.:format)                                  active_storage/blobs/proxy#show
#                                          GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                                        active_storage/blobs/redirect#show
#                rails_blob_representation GET    /rails/active_storage/representations/redirect/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations/redirect#show
#          rails_blob_representation_proxy GET    /rails/active_storage/representations/proxy/:signed_blob_id/:variation_key/*filename(.:format)    active_storage/representations/proxy#show
#                                          GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format)          active_storage/representations/redirect#show
#                       rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                                       active_storage/disk#show
#                update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                               active_storage/disk#update
#                     rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                                    active_storage/direct_uploads#create

Rails.application.routes.draw do
  resources :votes

  resources :judgements do
    member do
      post 'complete'
      post 'no_show'

    end
  end

  resources :users, only: %i[edit update] do
    get 'verify_zupass_credentials'
  end

  namespace :admin do
    root 'admin#index'

    get 'settings' => 'admin#settings'
    patch 'update_start_time' => 'admin#update_start_time'
    patch 'update_stage' => 'admin#update_hackathon_stage'

    post 'reschedule' => 'admin#reschedule'

    resources :users do
      post 'ethereum_address' => 'ethereum_addresses#create'
      delete 'ethereum_address/:id' => 'ethereum_addresses#destroy', as: :destroy_ethereum_address

      patch 'approve' => 'users#manually_approve'
      delete 'unapprove' => 'users#unapprove'
    end

    resources :judging_breaks, only: %i[create update destroy]

    resources :submissions, only: :index
    resources :judging_teams

    post 'generate_fake_data' => 'admin#generate_fake_data'
    delete 'wipe_all_data' => 'admin#wipe_all_data'
  end

  post 'sign_in' => 'sessions#sign_in'
  delete 'sign_out' => 'sessions#sign_out'

  resources :submissions do
    post 'add_comment'

    collection do
      get 'results'
    end
  end

  resources :hacking_teams, path: :teams do
    delete 'leave'
    post 'apply'

    post 'accept/:id', to: 'hacking_teams#accept', as: :accept
    delete 'reject/:id', to: 'hacking_teams#reject', as: :reject
    post 'unreject/:id', to: 'hacking_teams#unreject', as: :unreject

    get 'admin_members'
    post 'force_add', to: 'hacking_teams#force_add', as: :force_add

    delete 'kick/:id', to: 'hacking_teams#kick', as: :kick
  end


  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  root 'users#home'
end
