class Console
  HELLO_MESSAGE = <<~HELLO_MESSAGE.freeze
    Hello, we are RubyG bank!
    - If you want to create account - press `create`
    - If you want to load account - press `load`
    - If you want to exit - press `exit`
  HELLO_MESSAGE

  def initialize
    @account = Account.new
    hello
  end

  def hello
    puts HELLO_MESSAGE
    command = gets.chomp
    case command
    when 'create'then @account.create
    when 'load'  then @account.load
    else
      exit
    end
  end

  def main_menu
    puts main_menu_message

    loop do
      command = gets.chomp
      case command
      when 'SC'then @account.show_cards
      when 'CC'then @account.card.create
      when 'DC'then @account.card.destroy
      when 'PM'then @account.card.put_money
      when 'WM'then @account.card.withdraw_money
      when 'SM'then @account.card.send_money
      when 'DA'
         @account.destroy
         exit
      when 'exit'
        exit
      else
        puts "Wrong command. Try again!\n"
      end
    end
  end

  def name_input
    read_from_console{'Enter your name'}
  end

  def age_input
    read_from_console.to_i{'Enter your age'}
  end

  def login_input
    puts 'Enter your login'
    read_from_console{'Enter your login'}
  end

  def password_input
    read_from_console{'Enter your password'}
  end

  private

  def send_to_cosole
    puts yield
  end

  def read_from_console
    puts yield
    gets.chomp
  end

  def main_menu_message
    <<~MAIN_MENU_MESSAGE
      \nWelcome, #{@account.current_account.name}
      If you want to:
      - show all cards - press SC
      - create card - press CC
      - destroy card - press DC
      - put money on card - press PM
      - withdraw money on card - press WM
      - send money to another card  - press SM
      - destroy account - press `DA`
      - exit from account - press `exit`
    MAIN_MENU_MESSAGE
  end
end
