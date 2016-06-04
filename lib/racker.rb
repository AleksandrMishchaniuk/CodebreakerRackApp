require "codebreaker"
require "erb"
require "./lib/controller/game"
 
class Racker
  def self.call(env)
    new(env).response.finish
  end
   
  attr_reader :content
  @@geters = []

  def initialize(env)
    @content = 'index'
    @request = Rack::Request.new(env)
    undef_geters
  end
   
  def response
    controller = GameController.new(@request)
    case @request.path
    when "/"
      @content = 'index'
      Rack::Response.new(render())
    when "/game"
      @content = 'game'
      def_geters(controller.game_action)
      Rack::Response.new(render())
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
      @content = 'results'
      def_geters(controller.results_action)
      Rack::Response.new(render())
    else Rack::Response.new("Not Found", 404)
    end
  end
   
  def render(template = "layout")
    path = File.expand_path("../views/#{template}.html.erb", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def def_geters(params)
    self.class.class_eval do
      params.each do |name, val|
        @@geters << name
        define_method name do
          val
        end
      end
    end
  end

  def undef_geters
    self.class.class_eval do
      @@geters.each {|geter| remove_method geter}
      @@geters = []
    end
  end
end