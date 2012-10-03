require 'spec_helper'

class Musician # Mock AR model
  attr_accessor :id, :name, :rating, :errors, :birthplace_id
  def initialize(params={}); params.each{|k,v| self.send("#{k}=",v) if self.respond_to?(k)}; end
  def attributes; {:id => self.id, :name => self.name, :rating => self.rating}; end
end

class Birthplace # Mock AR model
  attr_accessor :id, :city, :state
  def initialize(params={}); params.each{|k,v| self.send("#{k}=",v) if self.respond_to?(k)}; end
  def attributes; {:id => self.id, :city => self.city, :state => self.state}; end
end

class Song # Mock AR model
  attr_accessor :id, :title, :rating
  def initialize(params={}); params.each{|k,v| self.send("#{k}=",v) if self.respond_to?(k)}; end
  def attributes; {:id => self.id, :title => self.title}; end
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

  class Song
    include Faceted::Presenter
    presents :song
    field :title
    field :rating
  end

  class Band
    include Faceted::Collector
    collects :musicians, :find_by => :birthplace_id
    collects :songs
  end

  describe Band do

    it 'creates an accessor method for its collected objects' do
      Band.new.respond_to?(:musicians).should be_true
      Band.new.respond_to?(:songs).should be_true
    end

    describe 'with associated objects' do

      it 'initializes the associated objects in the correct namespace' do
        band = MyApi::Band.new(:birthplace_id => 1)
        MyApi::Musician.stub(:where) { [MyApi::Musician.new] }
        MyApi::Song.stub(:where) { [MyApi::Song.new] }
        band.musicians.first.class.name.should == "MyApi::Musician"
        band.songs.first.class.name.should == "MyApi::Song"
      end

    end

  end

end
