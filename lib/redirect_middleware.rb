class RedirectMiddleware
  attr_accessor :app
  def initialize(app)
    @app = app
  end

  def call(env)
    location = if env["QUERY_STRING"].include?("inst=bentley")
      "https://search.lib.umich.edu/catalog?library=Bentley+Historical+Library"
    elsif env["QUERY_STRING"].include?("inst=clements")
      "https://search.lib.umich.edu/catalog?library=William+L.+Clements+Library"
    elsif env["QUERY_STRING"].include?("inst=flint")
      "https://search.lib.umich.edu/catalog?library=Flint+Thompson+Library"
    elsif env["QUERY_STRING"].include?("inst=aa")
      "https://search.lib.umich.edu/catalog?library=U-M+Ann+Arbor+Libraries"
    else
      return app.call(env)
    end
    [302, {"location" => location, "content-type" => "text/html", "content-length" => 0}, []]
  end
end
