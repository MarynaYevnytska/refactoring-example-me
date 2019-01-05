
CREDITE_CARD={"create_card_greeting" : 'create_card_greeting'}
class CreditCard
  VALID_TYPES = %w[
    usual
    capitalist
    virtual
  ].freeze
CARD_NUMBER=16
BALANCE={ 'usual':50,'capitalist':100, 'virtual':150}.freeze
  def initialize(type)
    case type
      when 'usual' then @card = CreditCards::Usual.new
      when 'capitalist' then @card = CreditCards::Capitalist.new
      when 'virtual' then @card = CreditCards::Virtual.new
    end
    @console=Console.new
  end

def data_recording(card_type)
  case card_type
  when 'usual'
    card = {type: 'usual',number: random_number,balance: BALANCE[:usual]}
  when 'capitalist'
    card = {type: 'capitalist',number: random_number,balance: BALANCE[:capitalist]}
  when 'virtual'
    card = {type: 'virtual', number: random_number, balance: BALANCE[:virtual]}
  end
end

def new_account_exist?
  new_accounts = []
    accounts.each do |account|
     if account.login == @current_account.login
       new_accounts.push(@current_account)
     else
       new_accounts.push(account)
    end
end

  def create_card
    loop do
      card_type = @console.read_from_console{I18n.t(CREDITE_CARD[:create_card_greeting])}
      if VALID_TYPES.include?(card_type)
        random_number = CARD_NUMBER.times.map { rand(10) }.join
        data_recording (card_type)
        cards = @current_account.card << card
        @current_account.card = cards # important!!!
        save(new_account_exist?, @file_path)
        break

      else
        @console.send_to_console{I18n.t(CONSOLE_SEND[:wrong_card])}
      end
    end
  end

  def destroy
    #@card.delete # : TODO move to base Credite card class
    loop do
      if @current_account.card.any?
        @console.send_to_console{I18n.t(CONSOLE_SEND[:delete])}
        @current_account.card.each_with_index do |card, index|
        @console.send_to_console{I18n.t(CONSOLE_SEND[:card], card_number: card[:number],
                                            card_type:card[:type], press_index: index + 1)
                                          end
        destroy_choice = @console.read_from_console{I18n.t(CONSOLE_SEND[:destroy])}
        case destroy_choice
            when (0..@current_account.card.length).include?(destroy_choice.to_i)
            destroy_confirm = @console.read_from_console{I18n.t(CONSOLE_SEND[:sure?], card_for_delete: @current_account.card[destroy_choice.to_i - 1][:number])}
              if  destroy_confirm == 'y'
                @current_account.card.delete_at(destroy_choice.to_i - 1)
              #save(new_account_exist?, @file_path) # :TODO reason?
                break
              end
            when 'exit' then break
            else
              @console.send_to_console{I18n.t(CONSOLE_SEND[:wrong_number!])}
            end
        else
          @console.send_to_console{I18n.t(CONSOLE_SEND[:no_active!])}
          break
        end
      end

  def withdraw_money
    puts 'Choose the card for withdrawing:'
    #answer, answer2, aanswer3 = nil # answers for gets.chomp
    if @current_account.card.any?
      @current_account.card.each_with_index do |card, index|
        puts "- #{card[:number]}, #{card[:type]}, press #{index + 1}"
      end
      puts "press `exit` to exit\n"
      loop do
        answer = gets.chomp
        break if answer == 'exit'
        if (0..@current_account.card.length).include?(answer&.to_i)
          current_card = @current_account.card[answer&.to_i - 1]
          loop do
            puts 'Input the amount of money you want to withdraw'
            answer2 = gets.chomp
            if answer2&.to_i > 0
              money_left = current_card[:balance] - answer2&.to_i - withdraw_tax(current_card[:type], current_card[:balance], current_card[:number], answer2&..to_i)
              if money_left > 0
                current_card[:balance] = money_left
                @current_account.card[answer&.to_i - 1] = current_card
                new_accounts = []
                accounts.each do |account|
                  new_accounts.push(@current_account) if account.login == @current_account.login
                  new_accounts.push(account) unless account.login == @current_account.login
                  end
                end
                File.open(@file_path, 'w') { |file| file.write new_accounts.to_yaml } # Storing
                puts "Money #{answer2&.to_i} withdrawed from #{current_card[:number]}$. Money left: #{current_card[:balance]}$. Tax: #{withdraw_tax(current_card[:type], current_card[:balance], current_card[:number], answer2&.to_i)}$"
                return
              else
                puts "You don't have enough money on card for such operation"
                return
              end
            else
              puts 'You must input correct amount of $'
              return
            end
          end
        else
          puts "You entered wrong number!\n"
          return
        end
      end
    else
      puts "There is no active cards!\n"
    end
  end

  def put_money
    puts 'Choose the card for putting:'

    if @current_account.card.any?
      @current_account.card.each_with_index do |card, index|
        puts "- #{card[:number]}, #{card[:type]}, press #{index + 1}"
      end
      puts "press `exit` to exit\n"
      loop do
        answer = gets.chomp
        break if answer == 'exit'

        if (0..@current_account.card.length).include?(answer&.to_i)
          current_card = @current_account.card[answer&.to_i - 1]
          loop do
            puts 'Input the amount of money you want to put on your card'
            answer2 = gets.chomp
            if answer&.to_i > 0
              if put_tax(current_card[:type], current_card[:balance], current_card[:number], a2&.to_i.to_i) >= a2&.to_i.to_i
                puts 'Your tax is higher than input amount'
                return
              else
                new_money_amount = current_card[:balance] + answer2&.to_i - put_tax(current_card[:type], current_card[:balance], current_card[:number], answer2&.to_i)
                current_card[:balance] = new_money_amount
                @current_account.card[answer&.to_i.to_i - 1] = current_card
                new_accounts = []
                accounts.each do |account|
                  if account.login == @current_account.login
                    new_accounts.push(@current_account)
                  else
                    new_accounts.push(account)
                  end
                end
                File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml } # Storing
                puts "Money #{answer2&.to_i} was put on #{current_card[:number]}. Balance: #{current_card[:balance]}. Tax: #{put_tax(current_card[:type], current_card[:balance], current_card[:number], answer2&.to_i)}"
                return
              end
            else
              puts 'You must input correct amount of money'
              return
            end
          end
        else
          puts "You entered wrong number!\n"
          return
        end
      end
    else
      puts "There is no active cards!\n"
    end
  end

  def send_money
    puts 'Choose the card for sending:'

    if @current_account.card.any?
      @current_account.card.each_with_index do |c, i|
        puts "- #{card[:number]}, #{card[:type]}, press #{index + 1}"
      end
      puts "press `exit` to exit\n"
      answer = gets.chomp
      exit if answer == 'exit'
      if (0..@current_account.card.length).include?(answer&.to_i)
        sender_card = @current_account.card[answer&.to_i - 1]
      else
        puts 'Choose correct card'
        return
      end
    else
      puts "There is no active cards!\n"
      return
    end

    puts 'Enter the recipient card:'
    answer2 = gets.chomp
    if answer2.length == CARD_NUMBER
      all_cards = accounts.map(&:card).flatten
      if all_cards.select { |card| card[:number] == answer2 }.any?
        recipient_card = all_cards.select { |card| card[:number] == answer2 }.first
      else
        puts "There is no card with number #{a2}\n"
        return
      end
    else
      puts 'Please, input correct number of card'
      return
    end

    loop do
      puts 'Input the amount of money you want to withdraw'
      answer3 = gets.chomp
      if answer3&.to_i > 0
        sender_balance = sender_card[:balance] - answer3&.to_i - sender_tax(sender_card[:type], sender_card[:balance], sender_card[:number], answer3&.to_i)
        recipient_balance = recipient_card[:balance] + a3&.to_i.to_i - put_tax(recipient_card[:type], recipient_card[:balance], recipient_card[:number], answer3&.to_i)
        if sender_balance < 0
          puts "You don't have enough money on card for such operation"
        elsif put_tax(recipient_card[:type], recipient_card[:balance], recipient_card[:number], answer3&.to_i) >= answer3&.to_i
          puts 'There is no enough money on sender card'
        else
          sender_card[:balance] = sender_balance
          @current_account.card[answer&.to_i.to_i - 1] = sender_card
          new_accounts = []
          accounts.each do |account|
            if account.login == @current_account.login
              new_accounts.push(@current_account)
            elsif account.card.map { |card| card[:number] }.include? answer2
              recipient = account
              new_recipient_cards = []
              recipient.card.each do |card|
                card[:balance] = recipient_balance if card[:number] == answer2
                new_recipient_cards.push(card)
              end
              recipient.card = new_recipient_cards
              new_accounts.push(recipient)
            end
          end
          File.open('accounts.yml', 'w') { |file| file.write new_accounts.to_yaml } # Storing
          puts "Money #{answer3&.to_i}$ was put on #{sender_card[:number]}. Balance: #{recipient_balance}. Tax: #{put_tax(sender_card[:type], sender_card[:balance], sender_card[:number], answer3&.to_i)}$\n"
          puts "Money #{answer3&.to_i}$ was put on #{answer2}. Balance: #{sender_balance}. Tax: #{sender_tax(sender_card[:type], sender_card[:balance], sender_card[:number], answer3&.to_i)}$\n"
          break
        end
      else
        puts 'You entered wrong number!\n'
      end
    end
  end

  private

  def withdraw_tax(type, _balance, _number, amount)
    if type == 'usual'
      return amount * 0.05
    elsif type == 'capitalist'
      return amount * 0.04
    elsif type == 'virtual'
      return amount * 0.88
    end

    0
  end

  def put_tax(type, _balance, _number, amount)
    if type == 'usual'
      return amount * 0.02
    elsif type == 'capitalist'
      return 10
    elsif type == 'virtual'
      return 1
    end

    0
  end

  def sender_tax(type, _balance, _number, amount)
    if type == 'usual'
      return 20
    elsif type == 'capitalist'
      return amount * 0.1
    elsif type == 'virtual'
      return 1
    end

    0
  end
end
