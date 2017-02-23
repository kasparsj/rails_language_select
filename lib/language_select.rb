# encoding: utf-8

require 'sort_alphabetical'

require 'language_select/version'
require 'language_select/tag_helper'

if defined?(ActionView::Helpers::Tags::Base)
  require 'language_select/language_select_helper'
else
  require 'language_select/rails3/language_select_helper'
end
