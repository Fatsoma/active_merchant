module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class SoEasyPayGateway < Gateway
      self.test_url = 'https://secure.soeasypay.com/gateway.asmx'
      self.live_url = 'https://secure.soeasypay.com/gateway.asmx'
      self.money_format = :cents

      # The countries the gateway supports merchants from as 2 digit ISO country codes
      self.supported_countries = ['US', 'GB', 'DK', 'SE', 'NO']

      # The card types supported by the payment gateway
      self.supported_cardtypes = [:visa, :master, :american_express, :discover, :maestro, :jcb, :solo, :diners_club]

      # The homepage URL of the gateway
      self.homepage_url = 'http://www.soeasypay.com/'

      # The name of the gateway
      self.display_name = 'SoEasyPay'

      def initialize(options = {})
        requires!(options, :login, :password)
        @website_id = options[:login]
        @password = options[:password]
        super
      end

      def authorize(money, payment_source, options = {})        

        if payment_source.respond_to?(:number)
          commit(do_authorization(money, payment_source, options), options)
        else 
          commit(do_reauthorization(money, payment_source, options), options)
        end
      end
      
      def purchase(money, payment_source, options = {})
        if payment_source.respond_to?(:number)
          commit(do_sale(money, payment_source, options), options)
        else
          commit(do_rebill(money, payment_source, options), options)
        end
      end

      def three_d_complete(pa_res, transaction_id, options = {})
        commit(do_three_d_confirm(pa_res, transaction_id, options), options)
      end

      def capture(money, authorization, options = {})
        commit(do_capture(money, authorization, options), options)
      end

      def refund(money, authorization, options={})
        commit(do_refund(money, authorization, options), options)
      end

      def void(authorization, options={})
        commit(do_void('VOID', nil, authorization, options), options)
      end

      private

      def do_authorization(money, card, options)
        options.merge!({:soap_action => 'AuthorizeTransaction'})
        soap = REXML::Document.new('<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:tns="urn:Interface" xmlns:types="urn:Interface/encodedTypes" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
    <tns:AuthorizeTransaction>
      <AuthorizeTransactionRequest href="#id1" />
    </tns:AuthorizeTransaction>
    <tns:AuthorizeTransactionRequest id="id1" xsi:type="tns:AuthorizeTransactionRequest">
      <websiteID xsi:type="xsd:string"></websiteID>
      <password xsi:type="xsd:string"></password>
      <orderID xsi:type="xsd:string"></orderID>
      <orderDescription xsi:type="xsd:string"></orderDescription>
      <customerIP xsi:type="xsd:string"></customerIP>
      <amount xsi:type="xsd:string"></amount>
      <orderAmount xsi:type="xsd:string"></orderAmount>
      <currency xsi:type="xsd:string"></currency>
      <cardHolderName xsi:type="xsd:string"></cardHolderName>
      <cardHolderAddress xsi:type="xsd:string"></cardHolderAddress>
      <cardHolderZipcode xsi:type="xsd:string"></cardHolderZipcode>
      <cardHolderCity xsi:type="xsd:string"></cardHolderCity>
      <cardHolderState xsi:type="xsd:string"></cardHolderState>
      <cardHolderCountryCode xsi:type="xsd:string"></cardHolderCountryCode>
      <cardHolderPhone xsi:type="xsd:string"></cardHolderPhone>
      <cardHolderEmail xsi:type="xsd:string"></cardHolderEmail>
      <cardNumber xsi:type="xsd:string"></cardNumber>
      <cardSecurityCode xsi:type="xsd:string"></cardSecurityCode>
      <cardIssueNumber xsi:type="xsd:string"></cardIssueNumber>
      <cardStartMonth xsi:type="xsd:string"></cardStartMonth>
      <cardStartYear xsi:type="xsd:string"></cardStartYear>
      <cardExpireMonth xsi:type="xsd:string"></cardExpireMonth>
      <cardExpireYear xsi:type="xsd:string"></cardExpireYear>
      <AVSPolicy xsi:type="xsd:string"></AVSPolicy>
      <FSPolicy xsi:type="xsd:string"></FSPolicy>
      <Secure3DAcsMessage xsi:type="xsd:string"></Secure3DAcsMessage>
      <userVar1 xsi:type="xsd:string"></userVar1>
      <userVar2 xsi:type="xsd:string"></userVar2>
      <userVar3 xsi:type="xsd:string"></userVar3>
      <userVar4 xsi:type="xsd:string"></userVar4>
    </tns:AuthorizeTransactionRequest>
  </soap:Body>
</soap:Envelope>')
        fill_credentials(soap, options)
        fill_order_info(soap, options.merge({:amount => amount(money), :currency => (options[:currency] || currency(money))}))
        fill_cardholder(soap, card, options)
        fill_card(soap, card)
        return soap
      end

      def do_sale(money, card, options)
        options.merge!({:soap_action => 'SaleTransaction'})
        soap = REXML::Document.new('<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:tns="urn:Interface" xmlns:types="urn:Interface/encodedTypes" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
    <tns:SaleTransaction>
      <SaleTransactionRequest href="#id1" />
    </tns:SaleTransaction>
    <tns:SaleTransactionRequest id="id1" xsi:type="tns:SaleTransactionRequest">
      <websiteID xsi:type="xsd:string"></websiteID>
      <password xsi:type="xsd:string"></password>
      <orderID xsi:type="xsd:string"></orderID>
      <orderDescription xsi:type="xsd:string"></orderDescription>
      <customerIP xsi:type="xsd:string"></customerIP>
      <amount xsi:type="xsd:string"></amount>
      <orderAmount xsi:type="xsd:string"></orderAmount>
      <currency xsi:type="xsd:string"></currency>
      <cardHolderName xsi:type="xsd:string"></cardHolderName>
      <cardHolderAddress xsi:type="xsd:string"></cardHolderAddress>
      <cardHolderZipcode xsi:type="xsd:string"></cardHolderZipcode>
      <cardHolderCity xsi:type="xsd:string"></cardHolderCity>
      <cardHolderState xsi:type="xsd:string"></cardHolderState>
      <cardHolderCountryCode xsi:type="xsd:string"></cardHolderCountryCode>
      <cardHolderPhone xsi:type="xsd:string"></cardHolderPhone>
      <cardHolderEmail xsi:type="xsd:string"></cardHolderEmail>
      <cardNumber xsi:type="xsd:string"></cardNumber>
      <cardSecurityCode xsi:type="xsd:string"></cardSecurityCode>
      <cardIssueNumber xsi:type="xsd:string"></cardIssueNumber>
      <cardStartMonth xsi:type="xsd:string"></cardStartMonth>
      <cardStartYear xsi:type="xsd:string"></cardStartYear>
      <cardExpireMonth xsi:type="xsd:string"></cardExpireMonth>
      <cardExpireYear xsi:type="xsd:string"></cardExpireYear>
      <AVSPolicy xsi:type="xsd:string"></AVSPolicy>
      <FSPolicy xsi:type="xsd:string"></FSPolicy>
      <Secure3DAcsMessage xsi:type="xsd:string"></Secure3DAcsMessage>
      <userVar1 xsi:type="xsd:string"></userVar1>
      <userVar2 xsi:type="xsd:string"></userVar2>
      <userVar3 xsi:type="xsd:string"></userVar3>
      <userVar4 xsi:type="xsd:string"></userVar4>
    </tns:SaleTransactionRequest>
  </soap:Body>
</soap:Envelope>')
        fill_credentials(soap, options)
        fill_order_info(soap, options.merge({:amount => amount(money), :currency => (options[:currency] || currency(money))}))
        fill_cardholder(soap, card, options)
        fill_card(soap, card)
        return soap
      end

      def do_three_d_confirm(pa_res, transaction_id, options)
        options.merge!({:soap_action => 'S3DConfirm'})
        soap = REXML::Document.new('<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:tns="urn:Interface" xmlns:types="urn:Interface/encodedTypes" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
    <tns:S3DConfirm>
      <S3DConfirmRequest href="#id1" />
    </tns:S3DConfirm>
    <tns:S3DConfirmRequest id="id1" xsi:type="tns:S3DConfirmRequest">
      <websiteID xsi:type="xsd:string"></websiteID>
      <password xsi:type="xsd:string"></password>
      <transactionID xsi:type="xsd:string"></transactionID>
      <paRES xsi:type="xsd:string"></paRES>
    </tns:S3DConfirmRequest>
  </soap:Body>
</soap:Envelope>')
        fill_credentials(soap, options)
        fill_three_d_params(soap, pa_res, transaction_id)
        return soap
      end

      def do_reauthorization(money, authorization, options)
        options.merge!({:soap_action => 'ReauthorizeTransaction'})
        soap = REXML::Document.new('<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:tns="urn:Interface" xmlns:types="urn:Interface/encodedTypes" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
    <tns:ReauthorizeTransaction>
      <ReauthorizeTransactionRequest href="#id1" />
    </tns:ReauthorizeTransaction>
    <tns:ReauthorizeTransactionRequest id="id1" xsi:type="tns:ReauthorizeTransactionRequest">
      <websiteID xsi:type="xsd:string"></websiteID>
      <password xsi:type="xsd:string"></password>
      <transactionID xsi:type="xsd:string"></transactionID>
      <orderID xsi:type="xsd:string"></orderID>
      <orderDescription xsi:type="xsd:string"></orderDescription>
      <amount xsi:type="xsd:string"></amount>
      <currency xsi:type="xsd:string"></currency>
    </tns:ReauthorizeTransactionRequest>
  </soap:Body>
</soap:Envelope>')
        fill_credentials(soap, options)
        fill_order_info(soap, options.merge({:amount => amount(money), :currency => (options[:currency] || currency(money))}))
        fill_transaction_id(soap, authorization)
        return soap
      end

      def do_rebill(money, authorization, options)
        options.merge!({:soap_action => 'RebillTransaction'})
        soap = REXML::Document.new('<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:tns="urn:Interface" xmlns:types="urn:Interface/encodedTypes" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
    <tns:RebillTransaction>
      <RebillTransactionRequest href="#id1" />
    </tns:RebillTransaction>
    <tns:RebillTransactionRequest id="id1" xsi:type="tns:RebillTransactionRequest">
      <websiteID xsi:type="xsd:string"></websiteID>
      <password xsi:type="xsd:string"></password>
      <transactionID xsi:type="xsd:string"></transactionID>
      <orderID xsi:type="xsd:string"></orderID>
      <orderDescription xsi:type="xsd:string"></orderDescription>
      <amount xsi:type="xsd:string"></amount>
      <currency xsi:type="xsd:string"></currency>
    </tns:RebillTransactionRequest>
  </soap:Body>
</soap:Envelope>')
        fill_credentials(soap, options)
        fill_order_info(soap, options.merge({:amount => amount(money), :currency => (options[:currency] || currency(money))}))
        fill_transaction_id(soap, authorization)
        return soap
      end

      def do_capture(money, authorization, options)
        options.merge!({:soap_action => 'CaptureTransaction'})
        soap = REXML::Document.new('<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:tns="urn:Interface" xmlns:types="urn:Interface/encodedTypes" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
    <tns:CaptureTransaction>
      <CaptureTransactionRequest href="#id1" />
    </tns:CaptureTransaction>
    <tns:CaptureTransactionRequest id="id1" xsi:type="tns:CaptureTransactionRequest">
      <websiteID xsi:type="xsd:string"></websiteID>
      <password xsi:type="xsd:string"></password>
      <transactionID xsi:type="xsd:string"></transactionID>
      <orderID xsi:type="xsd:string"></orderID>
      <orderDescription xsi:type="xsd:string"></orderDescription>
      <amount xsi:type="xsd:string"></amount>
    </tns:CaptureTransactionRequest>
  </soap:Body>
</soap:Envelope>')
        fill_credentials(soap, options)
        fill_order_info(soap, options.merge({:amount => amount(money), :currency => (options[:currency] || currency(money))}))
        fill_transaction_id(soap, authorization)
        return soap
      end

      def do_refund(money, authorization, options)
        options.merge!({:soap_action => 'RefundTransaction'})
        soap = REXML::Document.new('<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:tns="urn:Interface" xmlns:types="urn:Interface/encodedTypes" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
    <tns:RefundTransaction>
      <RefundTransactionRequest href="#id1" />
    </tns:RefundTransaction>
    <tns:RefundTransactionRequest id="id1" xsi:type="tns:RefundTransactionRequest">
      <websiteID xsi:type="xsd:string"></websiteID>
      <password xsi:type="xsd:string"></password>
      <transactionID xsi:type="xsd:string"></transactionID>
      <orderID xsi:type="xsd:string"></orderID>
      <orderDescription xsi:type="xsd:string"></orderDescription>
      <amount xsi:type="xsd:string"></amount>
    </tns:RefundTransactionRequest>
  </soap:Body>
</soap:Envelope>')
        fill_credentials(soap, options)
        fill_order_info(soap, options.merge({:amount => amount(money), :currency => (options[:currency] || currency(money))}))
        fill_transaction_id(soap, authorization)
        return soap
      end

      def do_void(money, authorization, options)
        options.merge!({:soap_action => 'CancelTransaction'})
        soap = REXML::Document.new('<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:tns="urn:Interface" xmlns:types="urn:Interface/encodedTypes" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
    <tns:CancelTransaction>
      <CancelTransactionRequest href="#id1" />
    </tns:CancelTransaction>
    <tns:CancelTransactionRequest id="id1" xsi:type="tns:CancelTransactionRequest">
      <websiteID xsi:type="xsd:string"></websiteID>
      <password xsi:type="xsd:string"></password>
      <transactionID xsi:type="xsd:string"></transactionID>
    </tns:CancelTransactionRequest>
  </soap:Body>
</soap:Envelope>')
        fill_credentials(soap, options)
        fill_transaction_id(soap, authorization)
        return soap
      end

      def fill_credentials(soap, options)
        REXML::XPath.first(soap.root, '//websiteID').text = @website_id
        REXML::XPath.first(soap.root, '//password').text = @password
      end

      def fill_three_d_params(soap, pa_res, transaction_id)
        REXML::XPath.first(soap.root, '//transactionID').text = transaction_id
        REXML::XPath.first(soap.root, '//paRES').text = pa_res
      end

      def fill_cardholder(soap, card, options)
        ch_info = options[:billing_address] || options[:address]


        REXML::XPath.first(soap.root, '//customerIP').text = options[:ip]
        name = card.name || ch_info[:name]
        REXML::XPath.first(soap.root, '//cardHolderName').text = name if name
        address = ch_info[:address1] || ''
        address << ch_info[:address2] if ch_info[:address2]
        REXML::XPath.first(soap.root, '//cardHolderAddress').text = address
        REXML::XPath.first(soap.root, '//cardHolderZipcode').text = ch_info[:zip]
        REXML::XPath.first(soap.root, '//cardHolderCity').text = ch_info[:city]
        REXML::XPath.first(soap.root, '//cardHolderState').text = ch_info[:state]
        REXML::XPath.first(soap.root, '//cardHolderCountryCode').text = ch_info[:country]
        REXML::XPath.first(soap.root, '//cardHolderPhone').text = ch_info[:phone]
        REXML::XPath.first(soap.root, '//cardHolderEmail').text = options[:email]
      end

      def fill_transaction_id(soap, transaction_id)
        REXML::XPath.first(soap.root, '//transactionID').text = transaction_id
      end

      def fill_card(soap, card)
        REXML::XPath.first(soap.root, '//cardNumber').text = card.number
        REXML::XPath.first(soap.root, '//cardSecurityCode').text = card.verification_value
        REXML::XPath.first(soap.root, '//cardExpireMonth').text = card.month.to_s.rjust(2, "0")
        REXML::XPath.first(soap.root, '//cardExpireYear').text = card.year
      end

      def fill_order_info(soap, options)
        REXML::XPath.first(soap.root, '//orderID').text = options[:order_id]
        REXML::XPath.first(soap.root, '//orderDescription').text = "Order #{options[:order_id]}"
        REXML::XPath.first(soap.root, '//amount').text = options[:amount]
        node = REXML::XPath.first(soap.root, '//currency')

        if node
          node.text = options[:currency]
        end
      end

      def parse(response, action)
        result = {}
        document = REXML::Document.new(response)
        response_element = document.root.get_elements("//[@xsi:type='tns:#{action}Response']").first
        response_element.elements.each do |element|
          result[element.name.underscore] = element.text
        end
        result
      end

      def get_element_value(document, element_name)
        node = REXML::XPath.first(document.root, "//#{element_name}")
        node.text if node
      end

      def set_element_value(document, element_name, value)
        return unless value.present?
        node = REXML::XPath.first(document.root, "//#{element_name}")
        node.text = value if node
      end

      def commit(soap, options)
        requires!(options, :soap_action)
        soap_action = options[:soap_action]
        xml = ""
      	REXML::Formatters::Default.new().write(soap.root, xml)
        headers = {"SOAPAction" => "\"urn:Interface##{soap_action}\"",
                   "Content-Type" => "text/xml; charset=utf-8"}
        response_string = ssl_post(test? ? self.test_url : self.live_url, xml, headers)
        response = parse(response_string, soap_action)
        return Response.new(response['errorcode'] == '000',
                            response['errormessage'],
                            response,
                            :test => test?,
                            :authorization => response['transaction_id'])
      end
    end
  end
end

