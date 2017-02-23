# Rails - Language Select

Provides a simple helper to get an HTML select list of languages using the ISO 369 standard.

Based on the code of https://github.com/stefanpenner/country_select

Uses language data from https://github.com/alphabetum/iso-639

## Installation

Install as a gem using

```shell
gem install language_select
```
Or put the following in your Gemfile

```ruby
gem 'language_select'
```

## Usage

Simple use supplying model and attribute as parameters:

```ruby
country_select("user", "language")
```

Supplying priority countries to be placed at the top of the list:

```ruby
country_select("user", "language", priority_countries: ["en", "fr", "de"])
```

Supplying only certain languages:

```ruby
language_select("user", "language", only: ["en", "fr", "de"])
```

Discarding certain languages:

```ruby
language_select("user", "language", except: ["en", "fr", "de"])
```

Pre-selecting a particular language:

```ruby
language_select("user", "language", selected: "en")
```

Using existing `select` options:
```ruby
language_select("user", "language", include_blank: true)
language_select("user", "language", { include_blank: 'Select a language' }, { class: 'language-select-box' })
```

Supplying additional html options:

```ruby
language_select("user", "language", { priority_languages: ["en", "fr"], selected: "en" }, { class: 'form-control', data: { attribute: "value" } })
```

### Using a custom formatter

You can define a custom formatter which will receive an
[`ISO-369`](https://github.com/alphabetum/iso-639/blob/master/lib/iso-639.rb)
```ruby
# config/initializers/language_select.rb
LanguageSelect::FORMATS[:with_alpha2] = lambda do |language|
  "#{language.name} (#{language.alpha2})"
end
```

```ruby
language_select("user", "language", format: :with_alpha2)
```

#### Getting the Language Name from the iso-389 gem

```ruby
class User < ActiveRecord::Base

  # Assuming language_select is used with User attribute `language_code`
  # This will return the english language name
  def language_name
    language = ISO369.find(language_code)
    language.english_name
  end

end
```
