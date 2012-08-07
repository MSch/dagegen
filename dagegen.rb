#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

class Dagegen
  attr_accessor :username, :password, :url, :current_page, :mechanize

  def initialize(args = {})
    args.each_pair do |key, value|
      send("#{key}=", value)
    end

    @mechanize = Mechanize.new
  end

  def login
    @mechanize.get(@url) do |page|
      @current_page = page.form_with(:class => 'login') do |form|
        form.login = username
        password_field = form.fields.select { |f| f.type == 'password' }.first
        password_field.value = password
        # U MAD?
      end.submit
    end
  end

  def dead_against!
    @current_page = @mechanize.click(@current_page.link_with(:text => /Offene Themen/))
    @current_page = @mechanize.click(@current_page.link_with(:text => /Abstimmung/))
    @current_page = @mechanize.click(@current_page.link_with(:text => /Alle Gliederungen/))
    @current_page = @mechanize.click(@current_page.link_with(:text => /Nicht abgestimmt/))

    open_vote_links = @current_page.links.select { |l| l.text =~ /Jetzt abstimmen/ }
    open_vote_links.each do |link|
      @current_page = @mechanize.click(link)
      vote_forms = @current_page.forms.select { |f| f.action =~ /vote\/update/ }
      vote_form = vote_forms.last
      current_value = vote_form.field_with(:name => 'scoring').value
      vote_form.field_with(:name => 'scoring').value = current_value.gsub!(/:.*$/, ':-1')
      puts "bin dagegen!"
      @current_page = @mechanize.submit(vote_form)
    end
  end
end


dagegen = Dagegen.new(:username => 'herrbert2012', :password => '12345678', :url => 'https://lfpp.de/lf/index/login.html?redirect_view=index&redirect_module=index')
dagegen.login
dagegen.dead_against!

