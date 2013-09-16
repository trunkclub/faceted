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

class Album # and yet another make-believe AR model
  attr_accessor :id, :name
  def initialize(params={}); params.each{|k,v| self.send("#{k}=",v) if self.respond_to?(k)}; end
  def attributes; {:id => self.id, :name => self.name}; end
  def reload; self; end
end

class AlbumTrack
  attr_accessor :id, :title
  def initialize(params={}); params.each{|k,v| self.send("#{k}=",v) if self.respond_to?(k)}; end
  def attributes; {:id => self.id, :title => self.name}; end
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

  class Album
    include Faceted::Presenter
    presents :album, :find_by => :name
    field :name
  end

  class AlbumTrack
    include Faceted::Presenter
    presents :album_track
    field :title
  end

  describe Musician do

    before do

      @ar_musician = ::Musician.new(:id => 1, :name => 'Johnny Cash', :rating => 'Good', :alive => false)
      ::Musician.stub(:where) { [@ar_musician] }

      @ar_birthplace = ::Birthplace.new(:id => 1, :city => 'Kingsland', :state => 'Arkansas')
      ::Birthplace.stub(:where) { [@ar_birthplace] }

    end

    describe 'initialized with an instantiated object' do

      let(:musician_presenter) { MyApi::Musician.from(@ar_musician) }

      it 'accepts an object' do
        musician_presenter.send(:object).should == @ar_musician
      end

      it 'initializes with the attributes of the object' do
        musician_presenter.name.should == 'Johnny Cash'
      end

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

        it 'excludes fields' do
          musician = MyApi::Musician.new(:id => 1, :excludes => [:rating])
          musician.schema_fields.include?(:rating).should be_false
        end

        it 'excludes relations' do
          musician = MyApi::Musician.new(:id => 1, :excludes => [:birthplace])
          musician.schema_fields.include?(:birthplace).should be_false
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

      it 'initializes the associated object finding by a specified key' do
        @ar_album = ::Album.new(:id => 1, :name => 'Greatest Hits')
        ::Album.stub(:where) { [@ar_album] }
        album = MyApi::Album.new(:name => 'Greatest Hits')
        album.id.should == 1
      end

      it 'does not choke on associated objects with underscores in their names' do
        @ar_album_track = ::AlbumTrack.new(:id => 1, :title => 'The Gambler')
        ::AlbumTrack.stub(:where) { [@ar_album_track] }
        track = MyApi::AlbumTrack.new(:id => 1)
        track.album_track.should == @ar_album_track
      end

    end

  end

end
