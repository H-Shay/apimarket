require 'rspec'
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'apimarket'


class Age9
  def get_age() 9 end
end

class Age19
  def get_age() 19 end
end

class Age99
  def get_age() 99 end
end

describe "making sure the customer is old enough" do
  context "when you're a kid" do
    before(:each) do
      @apimarket = Apimarket.new('/dev/null', Age9.new)
    end

    it "lets you buy cola and canned haggis" do
      lambda { @apimarket.sell_me(:cola)          }.should_not raise_error
      lambda { @apimarket.sell_me(:canned_haggis) }.should_not raise_error
    end

    it "stops you from buying anything age-restricted" do
      lambda { @apimarket.sell_me(:beer)       }.should raise_error(Apimarket::NoSale)
      lambda { @apimarket.sell_me(:whiskey)    }.should raise_error(Apimarket::NoSale)
      lambda { @apimarket.sell_me(:cigarettes) }.should raise_error(Apimarket::NoSale)
    end
  end

  context "when you're a newly-minted adult" do
    before(:each) do
      @apimarket = Apimarket.new('/dev/null', Age19.new)
    end

    it "lets you buy cola, canned haggis, and cigarettes (to hide the taste of the haggis)" do
      lambda { @apimarket.sell_me(:cola)          }.should_not raise_error
      lambda { @apimarket.sell_me(:canned_haggis) }.should_not raise_error
      lambda { @apimarket.sell_me(:cigarettes)    }.should_not raise_error
    end

    it "stops you from buying anything age-restricted" do
      lambda { @apimarket.sell_me(:beer)       }.should raise_error(Apimarket::NoSale)
      lambda { @apimarket.sell_me(:whiskey)    }.should raise_error(Apimarket::NoSale)
    end
  end

  context "when you're an old fogey on Thursday" do
    before(:each) do
      @apimarket = Apimarket.new('/dev/null', Age99.new)
      Time.stub(:now).and_return(Time.local(2010, 8, 12, 12))  # Thursday Aug 12 2010 12:00
    end

    it "lets you buy everything" do
      lambda { @apimarket.sell_me(:cola)          }.should_not raise_error
      lambda { @apimarket.sell_me(:canned_haggis) }.should_not raise_error
      lambda { @apimarket.sell_me(:cigarettes)    }.should_not raise_error
      lambda { @apimarket.sell_me(:beer)          }.should_not raise_error
      lambda { @apimarket.sell_me(:whiskey)       }.should_not raise_error
    end
  end

  context "when you're an old fogey on Sunday" do
    before(:each) do
      @apimarket = Apimarket.new('/dev/null', Age99.new)
      Time.stub(:now).and_return(Time.local(2010, 8, 15, 12))  # Sunday Aug 15 2010 12:00
    end

    it "stops you from buying hard alcohol" do
      lambda { @apimarket.sell_me(:whiskey)       }.should raise_error(Apimarket::NoSale)
    end
  end
end
