faceted
=======

Faceted provides a set of tools, patterns, and modules for use in API implementations.

It was written and is maintained by Corey Ehmke (@bantik) and Max Thom Stahl (@villainous) at Trunk Club.

Presenters
----------

Let's say that you have an ActiveRecord model called Musician, and you want to expose it through your API using a *Presenter* pattern. Faceted makes it easy. Create a new class namespaced inside of your API like so:



    module MyApi
      class Musician
        include Faceted::Presenter
        presents :musician
        field :name
        field :genre
        field :instrument, :default => 'guitar'
      end
    end

That's actually all you have to do. The `presents` method maps your Musician presenter to a root-level class called `Musician`, and the `field` methods map to attributes *or* methods on the associated AR Musician instance. If a default is set for a field, that default value will be stored when the presenter is used to create a record, unless overridden.

What's that, you say? How is the appropriate AR Musican record associated? Simple. Invoke an instance of the `MyApi::Musician` passing in an `:id` parameter, and it just works:

    m = Musician.create(:name => 'Johnny Cash', :genre => 'Western')
    m.id
    => 13

    presenter = MyApi::Musician.new(:id => 13)
    presenter.name
    => "Johnny Cash"

You can also invoke methods on AR instances using the same syntax. Let's say that your base `Musician` class has a `random_song_title` method that returns one of the musician's popular songs. Simply wire up the method in your presenter:

    field :random_song_title

That's it.

    presenter.random_song_title
    => "Ring of Fire"

Relationships work almost the same way. If `Musician` actually `has_one` birthplace, and includes a `birthplace_id` attribute, wire it up like this:

    field :birthplace_id

Create a presenter for the associated Birthplace model:

    module MyApi
      class Birthplace
        include Faceted::Presenter
        presents :birthplace
        field :city
        field :state
      end
    end

Now your `Musician` presenter responds the way it should:

    presenter.birthplace.city
    => "Kingsland"

It's smart enough to identify that `birthplace_id` indicates a relationship and builds the association for you. If you don't want it to do this, simply pass the `skip_association` flag:

    field :record_label_id, :skip_association => true

You can also explicitly declare the class of the association:

  field :genre_id, :class_name => 'MusicalGenre'

Presenters from Existing Models
----
In your controllers, you will typically be using one of three methods to instantiate a presenter: `new`, `materialize`, or `from`.

### new

This method is used to retrieve and instantiate a persisted model based on an `id`:

	m = Musician.create(:name => 'Bauhaus', :genre => 'Goth')	m.id
    => 213

    presenter = MyApi::Musician.new(:id => 213)
    presenter.name
    => "Bauhaus"

### materialize

Have an array of objects that you need translated into presenters? No problem. Use the `materialize` class method on the presenter class:

		musicians = [
			::Musician.new(:name => 'Love and Rockets'),
			::Musician.new(:name => 'The Pixies')
		]
		presenters = MyApi::Musician.materialize(musicians)
		presenters.first.name
		=> 'Love and Rockets'

### from

If you have an single instance of a persisted model already loaded, or if you're presenting a class that does not get read from a database (e.g. an object from an API response), you can use the `from` class method to materialize a single presenter object:

		musician_from_json_response = ::Musician.new(:name => 'Dust and a Shadow')
		presenter = MyApi::Musician.from(musician_from_json_response)
		presenter.name
		=> 'Dust and a Shadow'

Collectors
----------
Collectors are simply models that collect multiple instances of another model. An example:

    module MyApi
      class Playlist
        include Faceted::Collector
        collects :musicians, :find_by => :genre_id
        collects :deejays #implicit find_by, using 'playlist_id'
      end
    end

    l = MyApi::Playlist.new(:genre_id => 3)
    l.musicians.count
    => 14

    l.musicians.first.name
    => "American Music Club"

Controllers
-----------
Wiring up your controllers is easy. Start with your base controller:

    class MyApi::BaseController < ActionController::Base

      require 'faceted'
      include Faceted::Controller
      before_filter :authenticate_user!
      respond_to :json
      rescue_from Exception, :with => :render_500
      rescue_from ActiveRecord::RecordNotFound, :with => :render_404

    end

Then create the controllers for your API-specific models:

    class MyApi::MusiciansController < MyApi::BaseController

      def show
        @musician = MyApi::Musician.new(params)
        render_response @musician
      end

      def update
        @musician = MyApi::Musician.new(params)
        @musician.save
        render_response @musician
      end

    end

Contributing to faceted
=======================

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

Copyright
=========
Copyright (c) 2012 Trunk Club. See LICENSE.txt for further details.

