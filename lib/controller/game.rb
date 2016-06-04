class GameController
  def initialize(request)
    @manager = Codebreaker::Manager.new
    @request = request
    @manager.game_init
  end

  def game_action
    status = 'no_game'
    code = ''
    hint_val = ''
    hint_cnt = 0
    attempts_val = {}
    attempts_cnt = 0
    if(@request.session[:game])
      
    end

    @request.session[:game] = nil if ['win', 'lose'].include? status

    {status: status, code: code, hint_val: hint_val, hint_cnt: hint_cnt,
      attempts_val: attempts_val, attempts_cnt: attempts_cnt}
  end
end