# encoding: utf-8

require 'spec_helper'

require 'action_view'
require 'rails_language_select'

describe "RailsLanguageSelect" do
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
    tag = options_for_select([['English', 'EN']], 'EN')

    walrus.language_code = 'EN'
    t = builder.language_select(:language_code)
    expect(t).to include(tag)
  end

  it "uses the locale specified by I18n.locale" do
    I18n.available_locales = [:en, :es]

    tag = options_for_select([['Inglés', 'EN']], 'EN')

    walrus.language_code = 'EN'
    original_locale = I18n.locale
    begin
      I18n.locale = :es
      t = builder.language_select(:language_code)
      expect(t).to include(tag)
    ensure
      I18n.locale = original_locale
    end
  end

  it "accepts a locale option" do
    I18n.available_locales = [:fr]

    tag = options_for_select([['anglais', 'EN']], 'EN')

    walrus.language_code = 'EN'
    t = builder.language_select(:language_code, locale: :fr)
    expect(t).to include(tag)
  end

  it "accepts priority languages" do
    tag = options_for_select(
        [
            ['Latvian','LV'],
            ['English','EN'],
            ['Danish', 'DA'],
            ['-'*15,'-'*15]
        ],
        selected: 'EN',
        disabled: '-'*15
    )

    walrus.language_code = 'EN'
    t = builder.language_select(:language_code, priority_languages: ['LV','EN','DA'])
    expect(t).to include(tag)
  end

  describe "when selected options is not an array" do
    it "selects only the first matching option" do
      tag = options_for_select([["English", "EN"],["Uruguay", "UY"]], "EN")
      walrus.language_code = 'EN'
      t = builder.language_select(:language_code, priority_languages: ['LV','EN'])
      expect(t).to_not include(tag)
    end
  end

  describe "when selected options is an array" do
    it "selects all options but only once" do
      walrus.language_code = 'en'
      t = builder.language_select(:language_code, {priority_languages: ['LV','EN','ES'], selected: ['ZU', 'EN']}, multiple: true)
      expect(t.scan(options_for_select([["English", "EN"]], "EN")).length).to be(1)
      expect(t.scan(options_for_select([["Zulu", "ZU"]], "ZU")).length).to be(1)
    end
  end

  it "displays only the chosen languages" do
    options = [["Danish", "DA"],["German", "DE"]]
    tag = builder.select(:language_code, options)
    walrus.language_code = 'en'
    t = builder.language_select(:language_code, only: ['DA','DE'])
    expect(t).to eql(tag)
  end

  it "discards some languages" do
    tag = options_for_select([["English", "EN"]])
    walrus.language_code = 'de'
    t = builder.language_select(:language_code, except: ['EN'])
    expect(t).to_not include(tag)
  end

  context "using old 1.x syntax" do
    it "accepts priority languages" do
      tag = options_for_select(
          [
              ['Latvian','LV'],
              ['English','EN'],
              ['Danish', 'DA'],
              ['-'*15,'-'*15]
          ],
          selected: 'EN',
          disabled: '-'*15
      )

      walrus.language_code = 'EN'
      t = builder.language_select(:language_code, ['LV','EN','DA'])
      expect(t).to include(tag)
    end

    it "selects only the first matching option" do
      tag = options_for_select([["English", "EN"],["Uruguay", "UY"]], "EN")
      walrus.language_code = 'EN'
      t = builder.language_select(:language_code, ['LV','EN'])
      expect(t).to_not include(tag)
    end

    it "supports the language names as provided by default in Formtastic" do
      tag = options_for_select([
                                   ["Dzongkha", "DZ"],
                                   ["Spanish; Castilian", "ES"],
                                   ["Danish", "DA"],
                                   ["English", "EN"]
                               ])
      language_names = ["Dzongkha", "Spanish", "Danish", "English"]
      t = builder.language_select(:language_code, language_names)
      expect(t).to include(tag)
    end

    it "raises an error when a language code or name is not found" do
      language_names = [
          "English",
          "Spanish",
          "Danish",
          "Freedonia"
      ]
      error_msg = "Could not find Language with string 'Freedonia'"

      expect do
        builder.language_select(:language_code, language_names)
      end.to raise_error(RailsLanguageSelect::LanguageNotFoundError, error_msg)
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
    tag = builder.language_select(:language_code, only: ['BG', 'CA', 'CH', 'ZU'])
    order = tag.scan(/value="(\w{2})"/).map { |o| o[0] }
    expect(order).to eq(['BG', 'CA', 'CH', 'ZU'])
  end

  describe "custom formats" do
    it "accepts a custom formatter" do
      ::RailsLanguageSelect::FORMATS[:with_code] = lambda do |language, code|
        "#{language} (#{code})"
      end

      tag = options_for_select([['English (EN)', 'EN']], 'EN')

      walrus.language_code = 'EN'
      t = builder.language_select(:language_code, format: :with_code)
      expect(t).to include(tag)
    end
  end

  describe "custom data source" do
    it "accepts a custom data source" do
      ::RailsLanguageSelect::DATA_SOURCE[:custom_data] = lambda do |code_or_name = nil|
        custom_data = {yay: "YAY!", wii: 'Yippii!'}
        if code_or_name.nil?
          custom_data.keys
        else
          if (language = custom_data[code_or_name])
            code = code_or_name
          elsif (code = custom_data.key(code_or_name))
            language = code_or_name
          end
          return language, code
        end
      end

      tag = options_for_select([['YAY!', 'yay'], ['Yippii!', 'wii']], 'wii')
      walrus.language_code = 'wii'
      t = builder.language_select(:language_code, data_source: :custom_data)
      expect(t).to include(tag)
    end
  end
end