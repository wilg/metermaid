#!/usr/bin/env rake
require "bundler/gem_tasks"

# Travis!
require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'

desc "Run RSpec"
RSpec::Core::RakeTask.new do |t|
  t.verbose = false
end

task :default => :spec

namespace :db do

  task :import, [:user, :password] => []  do |t, args|
    require 'metermaid'

    store = Metermaid::ActiveRecordStore.new
    store.open!

    result = Metermaid::PGandE::Fetcher.scrape!(
      username: args[:user],
      password: args[:password],
      start_date: 1.month.ago,
      end_date: Time.now,
    )
    result.each do |row|
      Metermaid::DB::MetermaidSample.where(row).first_or_create
    end

    store.close!
  end

end
