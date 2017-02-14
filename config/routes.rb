Clio::Application.routes.draw do

  mount Spectrum::Json::Engine => '/'

end
