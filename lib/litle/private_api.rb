module Killbill::Litle
  class PrivatePaymentPlugin
    include Singleton

    def register_token!(kb_account_id, paypage_registration_id, options = {})
      litle_response = gateway.store paypage_registration_id, options
      response = save_response litle_response, :register_token

      # Create the payment method (not associated to a Killbill payment method yet)
      LitlePaymentMethod.create! :kb_account_id => kb_account_id, :kb_payment_method_id => nil, :litle_token => response.litle_token
    end

    private

    def save_response(litle_response, api_call)
      logger.warn "Unsuccessful #{api_call}: #{litle_response.message}" unless litle_response.success?

      # Save the response to our logs
      response = LitleResponse.from_response(api_call, nil, litle_response)
      response.save!
      response
    end

    def gateway
      # The gateway should have been configured when the plugin started
      Killbill::Litle::Gateway.instance
    end

    def logger
      # The logger should have been configured when the plugin started
      Killbill::Litle.logger
    end
  end
end