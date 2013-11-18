# middleman-api

middleman-api is an extension for the [Middleman](http://middlemanapp.com) static site generator that adds a RESTful API to Middleman's Sitemap Resources.

# Install

In an existing Middleman project:
Add `middleman-api` to your `Gemfile`

```
gem "middleman-api"
```

Then open your `config.rb` and add:

```
# MUST BE LAST ACTIVATION IN CONFIG!!! 
activate :api
```

# **!!!MUST BE ACTIVATED LAST!!!**


# Options

    option :at, '/__api', 'Specify where the API should live'
    option :build, true, 'Whether the API is built to static files'
    option :source_file, false, 'Lookup resources by source file'
    option :include_body, false, 'Include rendered body in output'
    option :include_raw_body, false, 'Include raw body in output'
    option :include_layout, false, 'Include layout in rendered body'
    option :include_metadata, true, 'Include metadata in output'
    option :paginate, false, 'Max resources per page'

## Build Status

[![Gem Version](https://badge.fury.io/rb/middleman-api.png)](https://rubygems.org/gems/middleman-api)
[![Build Status](https://travis-ci.org/middleman/middleman-api.png)](http://travis-ci.org/middleman/middleman-api)

# Community

The official community forum is available at:

  http://forum.middlemanapp.com/

# Bug Reports

GitHub Issues are used for managing bug reports and feature requests. If you run into issues, please search the issues and submit new problems:

https://github.com/middleman/middleman-api/issues

The best way to get quick responses to your issues and swift fixes to your bugs is to submit detailed bug reports, include test cases and respond to developer questions in a timely manner. Even better, if you know Ruby, you can submit Pull Requests containing Cucumber Features which describe how your feature should work or exploit the bug you are submitting.

# Support Us

[![Support via Gittip](https://rawgithub.com/twolfson/gittip-badge/0.1.0/dist/gittip.png)](https://www.gittip.com/tdreyno/)

[Support via Donation](https://spacebox.io/s/4dXbHBorC3)
