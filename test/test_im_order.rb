require 'minitest/autorun'
require 'shoulda'

require 'im_order'
require 'pp'

require 'test_constants'

class TestImOrder < MiniTest::Test
  i_suck_and_my_tests_are_order_dependent!

  context "wrong auth" do
    setup do
      @auth = ImOrder::Auth.new("WRONGKEY", "WRONGID", nil)
      @customer_uid = TEST_CUSTOMER_UID
      @order_uid = TEST_ORDER_UID
    end

    should "fail" do
      @customer = ImOrder::Customer.new(@customer_uid, "#{@customer_uid}@testimorder.com", "test", "client", "FR")
      assert_raises(ImOrder::InvalidKey) do
        @customer.push(@auth)
      end
    end

  end

  context "ordering" do
    setup do
      @auth = ImOrder::Auth.new(TEST_API_KEY, TEST_RESELLER_ID, TEST_RESELLER_GENCOD)
      @customer_uid = TEST_CUSTOMER_UID
      @order_uid = TEST_ORDER_UID
    end

    should "missing data when create customer" do
      @customer = ImOrder::Customer.new(@customer_uid, "#{@customer_uid}@testimorder.com")
      assert_raises(ImOrder::IncompleteCustomer) do
        @customer.push(@auth)
      end
    end

    should "create customer" do
      @customer = ImOrder::Customer.new(@customer_uid, "#{@customer_uid}@testimorder.com", "test", "client", "FR")
      r = @customer.push(@auth)
      assert_equal true, r
      refute_nil @customer.id
      refute_nil @customer.password
    end

    should "update customer" do
      @customer = ImOrder::Customer.new(@customer_uid, "#{@customer_uid}@testimorder.com", "test", "client", "FR")
      r = @customer.push(@auth)
      assert_equal false, r
      refute_nil @customer.warning
      refute_nil @customer.id
      assert_equal "ExistingCustomer", @customer.warning.code
    end

    should "missing data when create order" do
      @order = ImOrder::Order.new(@order_uid)
      assert_raises(ImOrder::IncompleteOrder) do
        @order.push(@auth)
      end
    end

    should "unknown customer when create order" do
      ol = ImOrder::OrderLine.new("9782824711560", 0, "EUR")
      @order = ImOrder::Order.new(@order_uid, ImOrder::Customer.new(TEST_MISSING_CUSTOMER_UID), [ol])
      assert_raises(ImOrder::UnknownCustomer) do
        @order.push(@auth)
      end
    end

    should "invalid price when create order" do
      ol = ImOrder::OrderLine.new("9782824711560", 1999, "EUR")
      @order = ImOrder::Order.new(@order_uid, ImOrder::Customer.new(@customer_uid), [ol])
      assert_raises(ImOrder::SellInvalidPrice) do
        @order.push(@auth)
      end
    end

    should "create order" do
      ol = ImOrder::OrderLine.new("9782824711560", 0, "EUR")
      @order = ImOrder::Order.new(@order_uid, ImOrder::Customer.new(@customer_uid), [ol])
      r = @order.push(@auth)

      assert_equal true, r
      refute_nil @order.id
      refute_nil @order.amount
      refute_nil @order.tax
      refute_nil @order.download_key
    end

    should "download list from missing order" do
      @order = ImOrder::Order.new(TEST_MISSING_ORDER_UID)
      assert_raises(ImOrder::UnknownOrder) do
        @order.download_list(@auth)
      end
    end

    should "download list from order" do
      @order = ImOrder::Order.new(@order_uid)
      r = @order.download_list(@auth)
      assert_equal true, r
      refute_nil @order.downloads
    end

    should "voidable order" do
      @order = ImOrder::Order.new(@order_uid, ImOrder::Customer.new(@customer_uid))
      r = @order.voidable(@auth)
      assert_equal true, r
    end

    should "void order" do
      @order = ImOrder::Order.new(@order_uid, ImOrder::Customer.new(@customer_uid))
      r = @order.cancel(@auth)
      assert_equal true, r
    end

  end

end
