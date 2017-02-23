# encoding: utf-8

require 'i18n_data'
require 'sort_alphabetical'

require 'rails_language_select/version'
require 'rails_language_select/data_source'
require 'rails_language_select/formats'
require 'rails_language_select/tag_helper'

if defined?(ActionView::Helpers::Tags::Base)
  require 'rails_language_select/language_select_helper'
else
  require 'rails_language_select/rails3/language_select_helper'
end
