require 'thecurrencycloud'
require 'json'
require 'rest_client'

module TheCurrencyCloud
  # Represents a client and associated functionality.
  class Client
    attr_reader :client_id, :api_key, :token

    def initialize(client_id, api_key = nil)
      @api_key = api_key
      @client_id = client_id
      @token = authenticate(client_id)
    end

    def prices_market(ccy_pair, options = {})
      response = get("prices/market/#{ccy_pair.upcase}", options)
      Price.new(response)
    end

    def prices_client_quote(buy_currency, sell_currency,
                            side, amount, options = {})
      side = convert_sell_sym(side)
      options.merge!(buy_currency: buy_currency, sell_currency: sell_currency,
                     side: side, amount: amount)
      response = post('prices/client_quote', options)
      Price.new(response)
    end

    # Returns a list of trades
    def trades(options = {})
      response = get('trades', options)
      mash = Trade.new(response)
      mash.map { |d| Trade.new(d) }
    end

    # Executes a trade
    def trade_execute(options)
      side = convert_sell_sym(options[:side])
      response = post('trade/execute', options.merge(side: side))
      Trade.new(response)
    end

    # Executes a trade with payment
    def trade_execute_with_payment(options)
      side = convert_sell_sym(options[:side])
      response = post('trade/execute_with_payment', options.merge(side: side))
      Trade.new(response)
    end

    def trade(trade_id)
      response = get("trade/#{trade_id}")
      Trade.new(response)
    end

    def settlement_account(trade_id)
      response = get("trade/#{trade_id}/settlement_account")
      Trade.new(response)
    end
    # Returns a list of payments
    def payments(options = {})
      # /api/en/v1.0/:token/payments
      response = get('payments', options)
      response.parsed_response['data'].map { |d| Payment.new(d) }
    end

    def payment(trade_id, options = {})
      # /api/en/v1.0/:token/payment/:payment_id
      response = get("payment/#{trade_id}", options)
      Payment.new(response)
    end

    def create_payment(id, options)
      # /api/en/v1.0/:token/payment/:payment_id
      post("payment/#{id}", options)
    end

    def add_payment(options)
      Payment.new(post('payment/add', options))
    end

    def update_payment(id, options)
      post("payment/#{id}", options)
    end

    def bank_accounts
      # /api/en/v1.0/:token/bank_accounts
      response = get('bank_accounts')
      response.parsed_response['data'].map { |d| Hashie::Mash.new(d) }
    end

    alias_method :beneficiaries, :bank_accounts

    def beneficiary(id)
      # /api/en/v1.0/:token/bank_account/:beneficiary_id
      response = get("beneficiary/#{id}")
      Hashie::Mash.new(response)
    end

    def update_beneficiary(beneficiary_id, beneficiary_details)
      response = post("beneficiary/#{beneficiary_id}", beneficiary_details)
      Hashie::Mash.new(response)
    end

    def beneficiaries
      response = get('beneficiaries')
      Hashie::Mash.new(response)
    end

    def create_beneficiary(beneficiary_details)
      response = post('beneficiary/new', beneficiary_details)
      Hashie::Mash.new(response)
    end

    def beneficiary_required_details(currency, destination_country_code)
      # /api/en/v1.0/:token/beneficiaries/required_fields
      response = get('beneficiaries/required_fields',
                     ccy: currency,
                     destination_country_code: destination_country_code)
      Hashie::Mash.new(response).map(&:required).flatten.uniq
    end

    def beneficiary_validate_details(options = {})
      response = get("beneficiary/validate_details", options)
      Hashie::Mash.new(response)
    end

    def bank_required_fields(currency, destination_country_code)
        # /api/en/v1.0/:token/bank_accounts/required_fields
    end

    def create_bank_account(bank)
      response = post('bank_account/new', bank)
      Hashie::Mash.new(response)
    end

    # Close the session
    def close_session
      # /api/en/v1.0/:token/close_session
      response = post('close_session')
      @token = nil
      Hashie::Mash.new(response)
    end

    private

    def authenticate(login_id)
      response = TheCurrencyCloud.post(
        '/authentication/token/new',
        body: {
          login_id: login_id,
          api_key: @api_key || TheCurrencyCloud.api_key
        }
      )
      Hashie::Mash.new(response)
    end

    def get(action, options = {})
      TheCurrencyCloud.get(uri_for(action), query: options)
    end

    def post(action, options = {})
      TheCurrencyCloud.post(uri_for(action), body: options)
    end

    # def post_form(action, options = {})
    #   TheCurrencyCloud.post_form uri_for(action), options
    # end

    def put(action, options = {})
      TheCurrencyCloud.put(uri_for(action), body: options)
    end

    def uri_for(action)
      "/#{token}/#{action}"
    end

    def convert_sell_sym(side)
      if side == :buy || side == 1
        side = 1
      elsif side == :sell || side == 2
        side = 2
      else
        fail "Side must be :buy or :sell"
      end

      side
    end
  end
end
