require 'yaml'
require 'pry'
FILE_NAME='accounts.yml'
require_relative 'console'
require_relative 'validators/account_validator'

class Account
  attr_accessor :card, :file_path # TODO: remove if unused
  attr_reader :current_account, :name, :password, :login, :age

  def initialize(file_path = FILE_NAME)
    @errors = []
    @file_path = file_path
    @console = Console.new(self)
    @validator = Validators::Account.new
  end



  def show_cards # TODO: move to Console
    puts "There is no active cards!\n" unless @current_account.card.any? {|card| puts "- #{card[:number]}, #{card[:type]}"}
  end

  def create
    loop do
      @name = @console.name_input
      @age = @console.age_input
      @login = @console.login_input
      @password = @console.password_input
      @validator.validate(self)

      break if @validator.valid?

      @validator.puts_errors
    end

    @cards = [] # TODO: what is this? -> rename to @cards
    new_accounts = accounts << self
    @current_account = self
    store_accounts(new_accounts)
    @console.main_menu
  end

  def create_card
    # TODO: should we keep it here?
    type = @console.credit_card_type
    CreditCard.new(type)
  end

  def account_validate
    
  end

  def load
    loop do
      return create_the_first_account if accounts.none?
      login = @console.read_from_console{'Enter your login'}
      password = @console.read_from_console{'Enter your password'}

      if accounts.map { |account| { login: account.login, password: account.password } }.include?(login: login, password: password)
        @current_account= accounts.select { |account| login == account.login }.first
        break
      else
        puts 'There is no account with given credentials'
        next
      end
    end
    @console.main_menu
  end

  def create_the_first_account
    puts 'There is no active accounts, do you want to be the first?[y/n]'
    if gets.chomp == 'y'
      create
    else
      @console
    end
  end

  def destroy
    puts 'Are you sure you want to destroy account?[y/n]'
    answer = gets.chomp
    if answer == 'y'
      new_accounts = []
      accounts.each {|account| new_accounts.push(account) unless account.login == @current_account.login}
    end
      store_accounts(new_accounts)
  end

  def accounts
    File.new(file_path, 'w+') unless File.exist?(FILE_NAME)
    YAML.load_file(FILE_NAME)
  end

  private

  def store_accounts(new_accounts)
    File.open(@file_path, 'w') { |file| file.write new_accounts.to_yaml }
  end
end
