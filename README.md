### Overview
This repository is the Web App for Speak Easy. It is hosted on Amazon Web Services
and can be found at justpeakeasy.com. This project manages accounts and
launches online campaigns.
---

### Ruby On Rails
This is the primary language used for this application. For developer help or
more information check out the main website at https://rubyonrails.org/
Please read the requirements and deployment below before install Ruby.
---

### Requirements
* Ruby ~ Version < 2.4 (At the time of writing 2.4 higher cause deployment issues)
* [Composer](https://getcomposer.org/doc/00-intro.md)
* [Phing](https://www.phing.info/)
* Bundler
---

### Deployment
1. Copy the build.properties.dist+

   `cp build.properties.dist build.properties`

2. Run setup if possible

   This will add in any required build tools and files that have not already
   been installed (phing, Bundler).

   `bin/setup`

3. Run configure to get proper config data from PHP
   `bin/phing configure`

4. Install project specific Gems

   `bundle install`

5. Run generator for datetimepicker-rails

   *Without this step the bootstrap-datetimepicker fails*

   `rails generate datetimepicker_rails:install Font-Awesome`

6. Start Server

   `rails server -e :environment`

   Possible environments: production development test

### Troubleshooting
* Possible problems. Make sure that your Ruby version is less than 2.4. Anything
   higher cause a conflict with the Rails version 4.2 which is currently used in
   the project. You will see a deprecated warning for Bignum and Fixum which was
   merged together in Ruby 2.4. The fix is either to upgrade Rails to 5.^ or
   downgrade Ruby.
