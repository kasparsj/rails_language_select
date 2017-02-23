# encoding: utf-8

require 'spec_helper'

require 'action_view'
require 'language_select'

describe "LanguageSelect" do
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormOptionsHelper

  before do
    I18n.available_locales = [:en]
    I18n.locale = :en
  end

  class Walrus
    attr_accessor :language_code
  end

  let(:walrus) { Walrus.new }
  let!(:template) { ActionView::Base.new }

  let(:builder) do
    if defined?(ActionView::Helpers::Tags::Base)
      ActionView::Helpers::FormBuilder.new(:walrus, walrus, template, {})
    else
      ActionView::Helpers::FormBuilder.new(:walrus, walrus, template, {}, Proc.new { })
    end
  end

  let(:select_tag) do
    <<-EOS.chomp.strip
      <select id="walrus_language_code" name="walrus[language_code]">
    EOS
  end

  it "selects the value of language_code" do
    tag = options_for_select([['English', 'en']], 'en')

    walrus.language_code = 'en'
    t = builder.language_select(:language_code)
    expect(t).to include(tag)
  end

  it "accepts priority languages" do
    tag = options_for_select(
        [
            ['Latvian','lv'],
            ['English','en'],
            ['Danish', 'da'],
            ['-'*15,'-'*15]
        ],
        selected: 'en',
        disabled: '-'*15
    )

    walrus.language_code = 'en'
    t = builder.language_select(:language_code, priority_languages: ['lv','en','da'])
    expect(t).to include(tag)
  end

  describe "when selected options is not an array" do
    it "selects only the first matching option" do
      tag = options_for_select([["English", "en"],["Uruguay", "UY"]], "en")
      walrus.language_code = 'en'
      t = builder.language_select(:language_code, priority_languages: ['lv','en'])
      expect(t).to_not include(tag)
    end
  end

  describe "when selected options is an array" do
    it "selects all options but only once" do
      walrus.language_code = 'en'
      t = builder.language_select(:language_code, {priority_languages: ['lv','en','es'], selected: ['zu', 'en']}, multiple: true)
      expect(t.scan(options_for_select([["English", "en"]], "en")).length).to be(1)
      expect(t.scan(options_for_select([["Zulu", "zu"]], "zu")).length).to be(1)
    end
  end

  it "displays only the chosen languages" do
    options = [["Danish", "da"],["German", "de"]]
    tag = builder.select(:language_code, options)
    walrus.language_code = 'en'
    t = builder.language_select(:language_code, only: ['da','de'])
    expect(t).to eql(tag)
  end

  it "discards some languages" do
    tag = options_for_select([["English", "en"]])
    walrus.language_code = 'de'
    t = builder.language_select(:language_code, except: ['en'])
    expect(t).to_not include(tag)
  end

  context "using old 1.x syntax" do
    it "accepts priority languages" do
      tag = options_for_select(
          [
              ['Latvian','lv'],
              ['English','en'],
              ['Danish', 'da'],
              ['-'*15,'-'*15]
          ],
          selected: 'en',
          disabled: '-'*15
      )

      walrus.language_code = 'en'
      t = builder.language_select(:language_code, ['lv','en','da'])
      expect(t).to include(tag)
    end

    it "selects only the first matching option" do
      tag = options_for_select([["English", "en"],["Uruguay", "UY"]], "en")
      walrus.language_code = 'en'
      t = builder.language_select(:language_code, ['lv','en'])
      expect(t).to_not include(tag)
    end

    it "supports the language names as provided by default in Formtastic" do
      tag = options_for_select([
                                   ["Dzongkha", "dz"],
                                   ["Spanish; Castilian", "es"],
                                   ["Danish", "da"],
                                   ["English", "en"]
                               ])
      language_names = ["Dzongkha", "Spanish; Castilian", "Danish", "English"]
      t = builder.language_select(:language_code, language_names)
      expect(t).to include(tag)
    end

    it "raises an error when a language code or name is not found" do
      language_names = [
          "English",
          "Elamite",
          "Ekajuk",
          "Spanish; Castilian",
          "Danish",
          "Freedonia"
      ]
      error_msg = "Could not find Language with string 'Freedonia'"

      expect do
        builder.language_select(:language_code, language_names)
      end.to raise_error(LanguageSelect::LanguageNotFoundError, error_msg)
    end

    it "supports the select prompt" do
      tag = '<option value="">Select your language</option>'
      t = builder.language_select(:language_code, prompt: 'Select your language')
      expect(t).to include(tag)
    end

    it "supports the include_blank option" do
      tag = '<option value=""></option>'
      t = builder.language_select(:language_code, include_blank: true)
      expect(t).to include(tag)
    end
  end

  it 'sorts unicode' do
    tag = builder.language_select(:language_code, only: ['bg', 'ca', 'ch', 'zu'])
    order = tag.scan(/value="(\w{2})"/).map { |o| o[0] }
    expect(order).to eq(['bg', 'ca', 'ch', 'zu'])
  end

  describe "custom formats" do
    it "accepts a custom formatter" do
      ::LanguageSelect::FORMATS[:with_alpha2] = lambda do |language|
        "#{language.english_name} (#{language.alpha2})"
      end

      tag = options_for_select([['English (en)', 'en']], 'en')

      walrus.language_code = 'en'
      t = builder.language_select(:language_code, format: :with_alpha2)
      expect(t).to include(tag)
    end

    it "accepts an array for formatter" do
      ::LanguageSelect::FORMATS[:with_alpha3] = lambda do |language|
        [language.english_name, language.alpha3]
      end

      tag = options_for_select([['English', 'eng']], 'eng')
      walrus.language_code = 'eng'
      t = builder.language_select(:language_code, format: :with_alpha3)
      expect(t).to include(tag)
    end

    it "accepts an array for formatter + custom formatter" do
      ::LanguageSelect::FORMATS[:with_alpha3] = lambda do |language|
        ["#{language.english_name} (#{language.alpha2})", language.alpha3]
      end

      tag = options_for_select([['English (en)', 'eng']], 'eng')
      walrus.language_code = 'eng'
      t = builder.language_select(:language_code, format: :with_alpha3)
      expect(t).to include(tag)
    end

    it "marks priority languages as selected only once" do
      ::LanguageSelect::FORMATS[:with_alpha3] = lambda do |language|
        [language.english_name, language.alpha3]
      end

      tag = options_for_select([['English', 'eng']], 'eng')
      walrus.language_code = 'eng'
      t = builder.language_select(:language_code, format: :with_alpha3, priority_languages: ['en'])
      expect(t.scan(Regexp.new(Regexp.escape(tag))).size).to eq 1
    end
  end
end