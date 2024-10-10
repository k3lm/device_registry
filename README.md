# DeviceRegistry

A Ruby on Rails application to manage device assignments to users.
- User can assign the device only to themself. 
- User can't assign the device already assigned to another user.
- Only the user who assigned the device can return it. 
- If the user returned the device in the past, they can't ever re-assign the same device to themself.

## Prerequisites

- **Ruby:** 3.2.3
- **Rails:** 7.1.3.4 or later
- **Bundler:** 2.2.0+
- **SQLite3**

## Setup

1. **Clone the Repository**

   ```bash
   git clone https://github.com/k3lm/device_registry.git
   cd device_registry
   ```
2. **Install dependencies**

   ```bash
   bundle install
   ```
3. **Setup database**

   ```bash
   rails db:create
   rails db:migrate
   rake db:test:prepare
   ```
4. **Run tests**

   ```bash
   bundle exec rspec --format doc
   ```

