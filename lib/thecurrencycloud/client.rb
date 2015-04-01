require 'thecurrencycloud'
require 'active_support/all'
require 'json'

module TheCurrencyCloud
  # Represents a client and associated functionality.
  class Client
    attr_reader :client_id, :api_key, :token, :token_renewed_block

    def initialize(client_id, api_key = nil, token = nil)
      @api_key = api_key
      @client_id = client_id
      @token = token ? token : authenticate(client_id)
    end

    def with_logger(logger, logger_key, broker_account_id = nil)
      @logger = logger
      @logger_key = logger_key
      @broker_account_id = broker_account_id

      self
    end

    def after_token_renewed(&block)
      @token_renewed_block = block
    end

    def prices_market(ccy_pair, options = {})
      response = get("prices/market/#{ccy_pair.upcase}", options)
      Hashie::Mash.new(log_and_map(response)).data
    end

    def prices_client_quote(buy_currency, sell_currency,
                            side, amount, options = {})
      side = convert_sell_sym(side)
      options.merge!(buy_currency: buy_currency, sell_currency: sell_currency,
                     side: side, amount: amount)
      response = post('prices/client_quote', options)
      Hashie::Mash.new(log_and_map(response)).data
    end

    # Returns a list of trades
    def trades(options = {})
      response = get('trades', options)
      Hashie::Mash.new(log_and_map(response)).data
                                             .map { |d| Hashie::Mash.new(d) }
    end

    # Executes a trade
    def trade_execute(options)
      side = convert_sell_sym(options[:side])
      response = post('trade/execute', options.merge(side: side))
      Hashie::Mash.new(log_and_map(response)).data
    end

    # Executes a trade with payment
    def trade_execute_with_payment(options)
      side = convert_sell_sym(options[:side])
      response = post('trade/execute_with_payment', options.merge(side: side))
      Hashie::Mash.new(log_and_map(response)).data
    end

    def trade(trade_id)
      response = get("trade/#{trade_id}")
      Hashie::Mash.new(log_and_map(response)).data
    end

    # Bad API design here
    def settlement_account(trade_id)
      response = get("trade/#{trade_id}/settlement_account")
      # Strange behaviour. If we try to access the data it is nulL
      Hashie::Mash.new(log_and_map(response))
    end
    # Returns a list of payments
    def payments(options = {})
      # /api/en/v1.0/:token/payments
      response = get('payments', options)
      log_and_map(response).parsed_response['data']
                           .map { |d| Hashie::Mash.new(d) }
    end

    def payment(trade_id, options = {})
      # /api/en/v1.0/:token/payment/:payment_id
      response = get("payment/#{trade_id}", options)
      Hashie::Mash.new(log_and_map(response)).data
    end

    def create_payment(id, options)
      # /api/en/v1.0/:token/payment/:payment_id
      response = post("payment/#{id}", options)
      log_and_map(response)
    end

    def add_payment(options)
      response = post('payment/add', options)
      Hashie::Mash.new(log_and_map(response))
    end

    def update_payment(id, options)
      response = post("payment/#{id}", options)
      Hashie::Mash.new(log_and_map(response))
    end

    def bank_accounts
      # /api/en/v1.0/:token/bank_accounts
      response = get('bank_accounts')
      log_and_map(response).parsed_response['data']
                           .map { |d| Hashie::Mash.new(d) }
    end

    alias_method :beneficiaries, :bank_accounts

    def beneficiary(id)
      # /api/en/v1.0/:token/bank_account/:beneficiary_id
      response = get("beneficiary/#{id}")
      Hashie::Mash.new(log_and_map(response)).data
    end

    def update_beneficiary(beneficiary_id, beneficiary_details)
      response = post("beneficiary/#{beneficiary_id}", beneficiary_details)
      Hashie::Mash.new(log_and_map(response)).data
    end

    def beneficiaries
      response = get('beneficiaries')
      Hashie::Mash.new(log_and_map(response)).data
    end

    def create_beneficiary(beneficiary_details)
      response = post('beneficiary/new', beneficiary_details)
      Hashie::Mash.new(log_and_map(response)).data
    end

    def beneficiary_required_details(currency, destination_country_code)
      # /api/en/v1.0/:token/beneficiaries/required_fields
      response = get('beneficiaries/required_fields',
                     ccy: currency,
                     destination_country_code: destination_country_code)
      Hashie::Mash.new(log_and_map(response)).data.map(&:required).flatten.uniq
    end

    def beneficiary_validate_details(options = {})
      response = get('beneficiary/validate_details', options)
      Hashie::Mash.new(log_and_map(response)).data
    end

    def bank_required_fields(currency, destination_country_code)
        # /api/en/v1.0/:token/bank_accounts/required_fields
    end

    def create_bank_account(bank)
      response = post('bank_account/new', bank)
      Hashie::Mash.new(log_and_map(response)).data
    end

    # Close the session
    def close_session
      # /api/en/v1.0/:token/close_session
      response = post('close_session')
      @token = nil
      Hashie::Mash.new(log_and_map(response)).data
    end

    private

    def authenticate(login_id)
      response = TheCurrencyCloud.post(
        '/authentication/token/new',
        body: {
          login_id: login_id,
          api_key: @api_key || TheCurrencyCloud.api_key
        }.to_query
      )
      Hashie::Mash.new(handle_response(response)).data
    end

    def get(action, options = {})
      with_expired_token_handler(action) do
        TheCurrencyCloud.get(uri_for(action), query: options)
      end
    end

    def post(action, options = {})
      with_expired_token_handler(action) do
        TheCurrencyCloud.post(uri_for(action), body: options.to_query)
      end
    end

    def token_expired?(action, response)
      if response.code == 200 && action != 'close_session'
        parsed_response = Hashie::Mash.new(response.parsed_response)

        return parsed_response.status.downcase == 'error' &&
          parsed_response.message.downcase.in?([
            'supplied token was not recognised',
            'your session has expired'
          ])
      end
      false
    end

    def with_expired_token_handler(action)
      response = yield
      if token_expired?(action, response)
        @token = authenticate(client_id)
        # tell the consumer that the token is renewed
        token_renewed_block.call(@token) if token_renewed_block
        # retry the request
        response = yield
      end
      response
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
        fail 'Side must be :buy or :sell'
      end

      side
    end

    def log_and_map(response)
      successful = true
      handle_response(response)
    rescue => e
      successful = false
      raise e
    ensure
      if @logger
        @logger.log(
          @logger_key,
          @broker_account_id,
          response_to_hash(response),
          request_to_hash(response.request),
          successful: successful
        )
      end
    end

    def handle_response(response) # :nodoc:
      case response.code
      when 400
        fail BadRequest.new(Hashie::Mash.new(response))
      when 401
        fail Unauthorized.new(Hashie::Mash.new(response))
      when 404
        fail NotFound.new(Hashie::Mash.new(response))
      when 400...500
        fail ClientError.new
      when 500...600
        fail ServerError.new
      else
        data = (response.body && response.body.length >= 2) ? response.body : nil
        return response if data.nil?
        mash_response = Hashie::Mash.new(JSON.parse(data))
        if mash_response.status == 'error'
          fail BadRequest.new(mash_response)
        else
          response
        end
      end
    end

    def response_to_hash(response)
      { headers: response.headers, code: response.code, body: response.body }
    end

    def request_to_hash(request)
      result = {
        http_method: request.http_method.name.demodulize.upcase,
        uri: request.uri.to_s,
        headers: request.options[:headers].to_h,
        query: request.options[:query],
        body: request.options[:body]
      }

      result
    end
  end
end
