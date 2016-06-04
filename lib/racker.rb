require "codebreaker"
require "erb"
require "./lib/controller/game"
require "./lib/controller/result"
 
class Racker
  def self.call(env)
    new(env).response.finish
  end
   
  @@geters = []
  def initialize(env)
    @request = Rack::Request.new(env)
    undef_geters
  end
   
  def response
    controller = GameController.new(@request)
    case @request.path
    when "/" then Rack::Response.new(render("index.html.erb"))
    when "/game"
      params = controller.game_action
      def_geters(params)
      Rack::Response.new(render("game.html.erb"))
    when "/game/new"
      controller.new_action
      Rack::Response.new do |response|
        response.redirect("/game")
      end
    when "/game/save"
      controller.save_action
      Rack::Response.new do |response|
        response.redirect("/results")
      end
    when "/hint"
      controller.hint_action
      Rack::Response.new do |response|
        response.redirect("/game")
      end
    when "/results"
      params = controller.results_action
      def_geters(params)
      Rack::Response.new(render("results.html.erb"))
    else Rack::Response.new("Not Found", 404)
    end
  end
   
  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def def_geters(params)
    class.class_eval do
      params.each do |name, val|
        @@geters << name
        define_method name do
          val
        end
      end
    end
  end

  def undef_geters
    class.class_eval do
      @@geters.each {|geter| remove_method geter}
      @@geters = []
    end
  end
end