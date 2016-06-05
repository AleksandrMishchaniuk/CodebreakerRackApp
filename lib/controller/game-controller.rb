class GameController
  def initialize(request)
    @request = request
    @manager = ( @request.session[:game] )? @request.session[:game][:manager]: nil
  end

  def game_action
    status = 'no_game'
    code = ''
    hint_val = ''
    hints_cnt = 0
    attempts_val = {}
    attempts_cnt = 0
    msg = nil

    if @manager 
      status = 'process'
      if @request.params['guess'] && @manager.attempts? 
        if valid_guess(@request.params['guess'])
          result = @manager.guess_result( @request.params['guess'] )
          status = 'win' if result == '++++'
          status = 'lose' if @manager.attempts_count == 0
          @request.session[:game][:attempts] << { 
                                                  guess: @request.params['guess'],
                                                  result: result
                                                }
          @request.session[:game][:status] = status
        else
          msg = 'wrong input'
        end
      end
      status = @request.session[:game][:status]
      code = @manager.secret_code
      hint_val = @request.session[:game][:hint]
      hints_cnt = @manager.hints_count
      attempts_val = @request.session[:game][:attempts]
      attempts_cnt = @manager.attempts_count
    end

    {
      status: status, code: code, hint_val: hint_val, hints_cnt: hints_cnt,
      attempts_val: attempts_val, attempts_cnt: attempts_cnt, msg: msg
    }
  end

  def new_action
    @manager = Codebreaker::Manager.new
    @manager.game_init
    @request.session[:game] = {}
    @request.session[:game][:attempts] = []
    @request.session[:game][:manager] = @manager
  end

  def hint_action
    @request.session[:game][:hint] = @manager.hint_result if @manager.hints?
  end

  def save_action
    if @manager && @request.params['user_name'] && \
                  valid_name(@request.params['user_name'])
        @manager.user_name = @request.params['user_name']
        @manager.save_game_data
        @request.session[:game] = nil
    end
  end

  def results_action
    rows = Codebreaker::Manager.new.get_saved_results.split("\n")
    rows.map! { |row| row.split("|") }
    results = rows.map do |row|
                {
                  user_name: row[0],
                  status: row[1],
                  attempts: row[2],
                  hints: row[3],
                  datetime: row[4]
                }
              end
    { results: results }
  end

  def valid_guess(guess)
    guess =~ @manager.guess_pattern
  end

  def valid_name(name)
    name =~ @manager.user_name_pattern
  end

end