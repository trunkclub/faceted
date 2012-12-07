require 'spec_helper'

class Birthplace # Mock AR model
  attr_accessor :id, :city, :state
  def initialize(params={}); params.each{|k,v| self.send("#{k}=",v) if self.respond_to?(k)}; end
  def attributes; {:id => self.id, :city => self.city, :state => self.state}; end
  def reload; self; end
end

module MyApi

  class MyApi::Application < Rails::Application
  end

  class Birthplace
    include Faceted::Presenter
    presents :birthplace
    field :city
    field :state
  end

  class BirthplacesController < ActionController::Base
    include Faceted::Controller
    include Rails.application.routes.url_helpers
    def show
      @birthplace = MyApi::Birthplace.first
      render_response @birthplace
    end

  end

end

describe MyApi::BirthplacesController, :type => :controller  do

  before do
    MyApi::Birthplace.stub(:first) { MyApi::Birthplace.new }
    MyApi::Application.routes.draw do
      namespace :my_api do
        resources :birthplaces
      end
    end
  end

  it 'renders with a 200 when the operation is successful' do
    MyApi::Birthplace.any_instance.stub(:success) { true }
    get :show, :id => 1
    response.code.should == "200"
  end

  it 'renders with a 400 when the operation is unsuccessful' do
    MyApi::Birthplace.any_instance.stub(:success) { false }
    get :show, :id => 1
    response.code.should == "400"
  end

end
