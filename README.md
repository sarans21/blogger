# Blogger

My personal static blog engine.

## Installation

Currently, it is not published on any Gem repositories. To install, clone the repo and run:

```
$ bundle install
$ gem build
$ gem install blogger-0.1.0.gem # Local install.
```

## Usage

```
$ blogger init blog  # Create a blog structure in 'blog' directory
$ cd blog
$ blogger serve .    # Serve in http://localhost:8080 with LiveReload
```

All changes will be watched and automatically get re-rendered and reloaded in the browser.

When we're ready to deploy:

```
$ blogger build --scheme https --host sarans.co --port 443 .
```

This creates a static site in `_public` directory, ready to be deployed anywhere.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## LICENSE

&copy; Saran Siriphantnon
