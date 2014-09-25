# coding: utf-8
#require 'helper'

#require 'test/unit'
require 'minitest/autorun'
require 'shoulda'

require 'im_order'
require 'pp'

TEST_API_KEY="xxx"
TEST_RESELLER_ID="xxx"
TEST_RESELLER_GENCOD=nil

TEST_CUSTOMER_UID="IMORDERCUST#{Time.now.to_i}"
TEST_ORDER_UID="IMORDERORD#{Time.now.to_i}"

TEST_MISSING_CUSTOMER_UID="IMORDERCUSTMISSING"
TEST_MISSING_ORDER_UID="IMORDERMISSING"


class TestImOnix < MiniTest::Test
  i_suck_and_my_tests_are_order_dependent!

  context "ordering" do
    setup do
      @auth=ImOrder::Auth.new(TEST_API_KEY,TEST_RESELLER_ID,TEST_RESELLER_GENCOD)
      @customer_uid=TEST_CUSTOMER_UID
      @order_uid=TEST_ORDER_UID
    end

    should "missing data when create customer" do
      @customer=ImOrder::Customer.new(@customer_uid,"#{@customer_uid}@testimorder.com")
      assert_raises(ImOrder::IncompleteCustomer) {
        r=@customer.push(@auth)
      }
    end

    should "create customer" do
      @customer=ImOrder::Customer.new(@customer_uid,"#{@customer_uid}@testimorder.com","test","client","FR")
      r=@customer.push(@auth)
      assert_equal true,r
      refute_nil @customer.id
      refute_nil @customer.password
    end

    should "update customer" do
      @customer=ImOrder::Customer.new(@customer_uid,"#{@customer_uid}@testimorder.com","test","client","FR")
      r=@customer.push(@auth)
      assert_equal false,r
      refute_nil @customer.warning
      refute_nil @customer.id
      assert_equal "ExistingCustomer", @customer.warning.code
    end

    should "missing data when create order" do
      @order=ImOrder::Order.new(@order_uid)
      assert_raises(ImOrder::IncompleteOrder) {
        r=@order.push(@auth)
      }
    end

    should "unknown customer when create order" do
      ol=ImOrder::OrderLine.new("9782824711560",0,"EUR")
      @order=ImOrder::Order.new(@order_uid,ImOrder::Customer.new(TEST_MISSING_CUSTOMER_UID),[ol])
      r=@order.push(@auth)

      assert_equal false, r
      refute_nil @order.error
      assert_equal "UnknownCustomer", @order.error.code
    end

    should "create order" do
      ol=ImOrder::OrderLine.new("9782824711560",0,"EUR")
      @order=ImOrder::Order.new(@order_uid,ImOrder::Customer.new(@customer_uid),[ol])
      r=@order.push(@auth)

      assert_equal true, r
      refute_nil @order.id
      refute_nil @order.amount
      refute_nil @order.tax
      refute_nil @order.download_key
    end

    should "download list from missing order" do
      @order=ImOrder::Order.new(TEST_MISSING_ORDER_UID)
      r=@order.download_list(@auth)
      assert_equal false, r
      refute_nil @order.error
      assert_equal "UnknownOrder", @order.error.code
    end

    should "download list from order" do
      @order=ImOrder::Order.new(@order_uid)
      r=@order.download_list(@auth)
      assert_equal true, r
      refute_nil @order.downloads
    end

  end


end
