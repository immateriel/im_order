# coding: utf-8

require 'minitest/autorun'
require 'shoulda'

require 'im_order'
require 'pp'

require 'test_constants'

class TestImOrderPnb < MiniTest::Test
  i_suck_and_my_tests_are_order_dependent!

  context "ordering" do
    setup do
      @auth=ImOrder::Auth.new(TEST_API_KEY,TEST_RESELLER_ID,TEST_RESELLER_GENCOD)
      @customer_uid=TEST_CUSTOMER_UID
      @order_uid=TEST_ORDER_UID
      @order_line_uid=TEST_ORDER_UID
      @loan_uid="LOAN#{Time.now.to_i}"
    end

    should "missing data when create order" do
      @order=ImOrder::OrderPnb.new(@order_uid)
      assert_raises(ImOrder::IncompleteOrder) do
        @order.push(@auth)
      end
    end

    should "invalid price when create order" do
      ol=ImOrder::OrderLinePnb.new(@order_line_uid,"9782820520579",100,"EUR")
      @order=ImOrder::OrderPnb.new(@order_uid,[ol])
      assert_raises(ImOrder::SellInvalidPrice) do
        @order.push(@auth)
      end
    end

    should "create order" do
      ol=ImOrder::OrderLinePnb.new(@order_line_uid,"9782820520579",200,"EUR")
      @order=ImOrder::OrderPnb.new(@order_uid,[ol])
      r=@order.push(@auth)

      assert_equal true, r
      refute_nil @order.id
      refute_nil @order.amount
      refute_nil @order.tax
      refute_nil @order.download_key
    end

    should "push loan from missing order line" do
      @order_line=ImOrder::OrderLinePnb.new(TEST_MISSING_ORDER_UID)
      assert_raises(ImOrder::UnknownOrderLine) do
        @order_line.push_loan(@auth,@loan_uid)
      end
    end

    should "push loan" do
      @order_line=ImOrder::OrderLinePnb.new(@order_line_uid)
      r=@order_line.push_loan(@auth,@loan_uid)
      assert_equal true, r
    end

    should "get_status" do
      @order_line=ImOrder::OrderLinePnb.new(@order_line_uid)
      r=@order_line.get_status(@auth)
      assert_equal true, r
      assert_equal 1,@order_line.status[:loan_current]
    end

  end


end
