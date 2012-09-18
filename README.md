faceted
=======

Faceted provides set of tools, patterns, and modules for use in API implementations.

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
      end
    end

That's actually all you have to do. The `presents` method maps your Musician presenter to a root-level class called `Musician`, and the `field` methods map to attributes *or* methods on the associated AR Musician instance.

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

Collectors
----------
Collectors are simply models that collect multiple instances of another model. An example:

    module MyApi
      class Playlist
        include Faceted::Collector
        collects :musicians, :find_by => :genre_id
      end
    end

    l = MyApi::Playlist.new(:genre_id => 3)
    l.musicians.count
    => 14

    l.musicians.first.name
    => "American Music Club"

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

