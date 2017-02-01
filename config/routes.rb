Rails.application.routes.draw do
  get 'using-from-example/without-from', to: 'using_from_example#without_from'
  get 'using-from-example/with-from',    to: 'using_from_example#with_from'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
