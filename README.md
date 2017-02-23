# Rails Language Select

Provides a simple helper to get a localised `<select>` of languages using the ISO 369 standard.

Based on the code of https://github.com/stefanpenner/country_select

Uses language data from https://github.com/grosser/i18n_data

## Installation

Install as a gem using

```shell
gem install rails_language_select
```
Or put the following in your Gemfile

```ruby
gem 'rails_language_select'
```

## Usage

Simple use supplying model and attribute as parameters:

```ruby
language_select("user", "language")
```

Supplying priority countries to be placed at the top of the list:

```ruby
language_select("user", "language", priority_countries: ["EN", "FR", "DE"])
```

Supplying only certain languages:

```ruby
language_select("user", "language", only: ["EN", "FR", "DR"])
```

Discarding certain languages:

```ruby
language_select("user", "language", except: ["EN", "FR", "DE"])
```

Pre-selecting a particular language:

```ruby
language_select("user", "language", selected: "EN")
```

Using existing `select` options:
```ruby
language_select("user", "language", include_blank: true)
language_select("user", "language", { include_blank: 'Select a language' }, { class: 'language-select-box' })
```

Supplying additional html options:

```ruby
language_select("user", "language", { priority_languages: ["EN", "FR"], selected: "EN" }, { class: 'form-control', data: { attribute: "value" } })
```

### Using a custom formatter

You can override the default formatter, or define a new custom formatter which will receive `language` (localised language name) and `code`
```ruby
# config/initializers/language_select.rb
RailsLanguageSelect::FORMATS[:default] = lambda do |language, code|
  [language, code.downcase] # use lower case code instead of upper case
end
RailsLanguageSelect::FORMATS[:with_code] = lambda do |language, code|
  "#{language} (#{code})"
end
```

```ruby
language_select("user", "language", format: :with_code)
```

#### Getting the Language Name from the I18nData gem

```ruby
class User < ActiveRecord::Base

  # Assuming language_select is used with User attribute `language_code`
  # This will attempt to translate the language name and use the default
  # (usually English) name if no translation is available
  def language_name
    I18nData.languages(I18n.locale.to_s)[language_code]
  end

end
```
