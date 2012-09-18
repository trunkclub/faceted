require 'spec_helper'

class Musician # pretend that this is an AR model
  attr_accessor :id, :name, :rating, :errors, :birthplace_id
  def initialize(params={}); params.each{|k,v| self.send("#{k}=",v) if self.respond_to?(k)}; end
  def attributes; {:id => self.id, :name => self.name, :rating => self.rating}; end
end

class Birthplace # another make-believe AR model
  attr_accessor :id, :city, :state
  def initialize(params={}); params.each{|k,v| self.send("#{k}=",v) if self.respond_to?(k)}; end
  def attributes; {:id => self.id, :city => self.city, :state => self.state}; end
end

module MyApi

  class Birthplace
    include Faceted::Presenter
    presents :birthplace
    field :city
    field :state
  end

  class Musician
    include Faceted::Presenter
    presents :musician
    field :name
    field :rating
    field :birthplace_id
  end

  class Band
    include Faceted::Collector
    collects :musicians, :class_name => 'Musician', :find_by => :birthplace_id
  end

  describe Band do

    before do
    end

    it 'creates an accessor method for its collected objects' do
      Band.new.respond_to?(:musicians).should be_true
    end

    describe 'with associated objects' do

      it 'initializes the associated objects in the correct namespace' do
        band = MyApi::Band.new(:birthplace_id => 1)
        MyApi::Musician.stub(:where) { [MyApi::Musician.new] }
        band.musicians.first.class.name.should == "MyApi::Musician"
      end

    end

  end

end
