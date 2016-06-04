class GameController
  def initialize(request)
    @manager = Codebreaker::Manager.new
    @request = request
    @manager.game_init
    @text = 'This is GameController'
  end

  def index_action
    {text: @text, code: @manager.secret_code}
  end
end