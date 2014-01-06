## ----------------------------------------------------------------------
##
## Ruby client for algolia.com
## A quick library for playing with algolia.com's REST API for object storage.
## Thanks to Sylvain Utard for the initial version of the library (sylvain.utard@gmail.com)
## ----------------------------------------------------------------------
require "rubygems"
require "bundler/setup"

require 'json'
require 'httpclient'
require 'date'
require 'cgi'

cwd = Pathname(__FILE__).dirname
$:.unshift(cwd.to_s) unless $:.include?(cwd.to_s) || $:.include?(cwd.expand_path.to_s)

require 'algolia/index'
