# Rails Language Select

Helper for displaying a localised `<select>` of languages using the ISO 369 standard or your own custom data source.

If you're using SimpleForm, see: https://github.com/kasparsj/simple_form_language_input

Based on the code of: https://github.com/stefanpenner/country_select

By default uses language data from: https://github.com/grosser/i18n_data

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

Supplying priority languages to be placed at the top of the list:

```ruby
language_select("user", "language", priority_languages: ["EN", "FR", "DE"])
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

### Using a custom data source

You can override the default data source, or define a new custom data source which will receive `code_or_name`
```ruby
# config/initializers/rails_language_select.rb

# example overriding default data source
RailsLanguageSelect::DATA_SOURCE[:default] = lambda do |code_or_name = nil|
  languages = I18nData.languages(I18n.locale.to_s).slice("EN", "FR", "ES")
  if code_or_name.nil?
    languages.keys
  else
    if (language = languages[code_or_name.to_s.upcase])
      code = code_or_name
    elsif (code = I18nData.language_code(code_or_name))
      language = languages[code]
    end
    return language, code
  end
end

# example defining a new custom data source
RailsLanguageSelect::DATA_SOURCE[:custom_data] = lambda do |code_or_name = nil|
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
```

```ruby
language_select("user", "language", data_source: :custom_data)
```

### Using a custom formatter

You can override the default formatter, or define a new custom formatter which will receive `language` (localised language name) and `code`
```ruby
# config/initializers/rails_language_select.rb

# example overriding default formatter
RailsLanguageSelect::FORMATS[:default] = lambda do |language, code|
  [language, code.downcase] # use lower case code instead of upper case
end

# example defining a new custom formatter
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
    RailsLanguageSelect::DATA_SOURCE[:default].call(language_code)
  end

end
```
