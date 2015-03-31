# csm-sync
Automated export of student and alumni data to [Symplicity CSM](http://www.symplicity.com/products/csm.html)

Requirements
------------
- Ruby
- Redis server (for Sidekiq)
- Read access to Biola Banner Oracle database, with custom views

Installation
------------
```bash
git clone git@github.com:biola/csm-sync.git
cd csm-sync
bundle install
cp config/settings.local.yml.example config/settings.local.yml
cp config/blazing.rb.example config/blazing.rb
```

Configuration
-------------
- Edit `config/settings.local.yml` accordingly.
- Edit `config/blazing.rb` accordingly.

Running
-------

```ruby
sidekiq -r ./config/environment.rb
```

Deployment
----------
```bash
blazing setup [target name in blazing.rb]
git push [target name in blazing.rb]

_Note: `blazing setup` only has to be run on your first deploy._
