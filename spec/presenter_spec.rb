require 'spec_helper'

class Musician # pretend that this is an AR model
  attr_accessor :id, :name, :rating, :errors, :birthplace_id, :alive
  def initialize(params={}); params.each{|k,v| self.send("#{k}=",v) if self.respond_to?(k)}; end
  def attributes; {:id => self.id, :name => self.name, :rating => self.rating, :alive => self.alive}; end
  def reload; self; end
end

class Birthplace # another make-believe AR model
  attr_accessor :id, :city, :state
  def initialize(params={}); params.each{|k,v| self.send("#{k}=",v) if self.respond_to?(k)}; end
  def attributes; {:id => self.id, :city => self.city, :state => self.state}; end
  def reload; self; end
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
    field :alive
  end

  describe Musician do

    before do

      @ar_musician = ::Musician.new(:id => 1, :name => 'Johnny Cash', :rating => 'Good', :alive => false)
      ::Musician.stub(:find) { @ar_musician }

      @ar_birthplace = ::Birthplace.new(:id => 1, :city => 'Kingsland', :state => 'Arkansas')
      ::Birthplace.stub(:find) { @ar_birthplace }

    end

    describe 'initialized with a presented object' do

      describe 'inherits values from its AR counterpart' do

        it 'normal values' do
          musician = MyApi::Musician.new(:id => 1)
          musician.name.should == 'Johnny Cash'
        end

        it 'boolean values' do
          musician = MyApi::Musician.new(:id => 1)
          musician.alive.should be_false
          musician.alive.should_not be_nil
        end

      end

      it 'overwrites values from its AR counterpart' do
        musician = MyApi::Musician.new(:id => 1, :rating => 'Great')
        musician.rating.should == 'Great'
      end

      describe 'saves its counterpart' do

        it 'successfully' do
          musician = MyApi::Musician.new(:id => 1)
          @ar_musician.should_receive(:save) { true }
          musician.save.should be_true
        end

        it 'handling failure' do
          musician = MyApi::Musician.new(:id => 1)
          @ar_musician.should_receive(:save) { false }
          musician.save.should be_false
        end

        it 'failing and populating its errors' do
          musician = MyApi::Musician.new(:id => 1)
          @ar_musician.should_receive(:save) { false }
          @ar_musician.stub_chain(:errors, :full_messages) { ["Something went wrong", "Terribly wrong"] }
          musician.save
          musician.errors.count.should == 2
          musician.errors.last.should == "Terribly wrong"
        end

      end

    end

    describe 'with an associated object' do

      it 'initializes the associated object in the correct namespace' do
        musician = MyApi::Musician.new(:id => 1, :birthplace_id => 1)
        musician.birthplace.city.should == 'Kingsland'
      end

    end

  end

end
