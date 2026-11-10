# Lato Users

Manage application users on Lato projects.

## Features

- Users: list (search, sort, pagination), create, edit, delete and detail page (account, email verification, security with authenticator/passkey state and latest signup/login logs, privacy and terms versions).
- Email verification: resend the verification email, verify or revoke manually.
- Passwords: set on creation (with a client-side generator based on `crypto.getRandomValues`) and "Force password update", which generates a random password, shows it **once** in the response and revokes all the user sessions.
- Permissions: edit the `lato_*_admin` / `lato_*_admin_role` flags of every installed Lato engine from the user form.
- Invitations: create, resend and delete invitations (accepted invitations cannot be deleted).
- Languages: `en` and `it`.

## Installation

Requires Rails 8.1.3.1 or newer in the 8.1 series and Lato 3.25.0 or newer. Existing applications must run `rails lato:install:migrations` (Lato session records) before deployment; previous sessions are invalidated.

Dependencies of the host application:

- A configured Action Mailer (verification and invitation emails).
- A working `Rails.cache` store (email semaphores and verification codes).

Add required dependencies to your application's Gemfile:

```ruby
# Use lato as application panel
gem "lato"
gem "lato_users"
```

Install gem and migrations (adds the `lato_users_admin` column to `lato_users`):

```bash
$ bundle
$ rails lato_users:install:migrations
$ rails db:migrate
```

`rails lato_users:install:application` is a no-op and is not required.

Mount lato users routes on the **config/routes.rb** file:

```ruby
Rails.application.routes.draw do
  mount LatoUsers::Engine => "/lato-users"
  # ....
end
```

Import Lato Users styles on **app/assets/stylesheets/application.scss** file:
```scss
@import 'lato_users/application';

// ....
```

Import Lato Users Js on **app/javascript/application.js** file:
```js
import "lato_users/application";

// ....
```

Add the menu entry (only for admins) in your navbar or sidebar partial; the engine activates `:lato_users` on its pages:

```erb
<% if @session.user&.lato_users_admin %>
  <%= lato_navbar_nav_item :lato_users, lato_users.root_path do %>Users<% end %>
<% end %>
```

Make sure the host filters password parameters from logs (`config.filter_parameters` including `:passw`).

## Routes

Mounted at the chosen path: `/` (redirects to `users`), `users` (+ `resend_verification_email`, `manual_verify_email`, `revoke_email_verification`, `force_update_password`) and `invitations` (+ `resend`).

## Permissions

Access requires a Lato session and `lato_users_admin: true` on `Lato::User`. Grant the first one from seeds or console:

```ruby
Lato::User.find_by!(email: "admin@example.com").update!(lato_users_admin: true)
```

`lato_users_admin` is effectively a **super-admin** flag: it can grant any other engine's admin permission to any user. Protections: an admin cannot remove their own `lato_users_admin` nor delete their own account, and the last users admin can be neither demoted nor deleted. Non-admin requests are redirected to the Lato root (`403` for non-HTML formats).

Permissions of other engines are discovered by column name on `Lato::User`:

- `lato_*_admin`: boolean, rendered as a checkbox (`lato_users_admin`, `lato_settings_admin`, `lato_spaces_admin`, `lato_storage_admin`, ...).
- `lato_*_admin_role`: integer, rendered as a select. The owning engine must expose `Lato::User.<column>_options` returning `[[label, value], ...]` (for example `lato_cms_admin_role_options`); submitted values outside these options are rejected.

Labels come from `activerecord.attributes.lato/user.<column>`; this gem translates the official ones (`en`, `it`).

## Security behaviour

- Users created by an admin are saved with the current privacy policy and terms versions, because `Lato::User` requires them; the admin is not the user's legal consent. Review this against your legal requirements.
- Passwords can only be set on creation. Existing users get a new password only through "Force password update" (shown once, never stored in flash or session; response is `no-store`).
- Changing the email of another user revokes that user's sessions (the admin's own sessions are kept). Lato itself revokes sessions on password change only.
- There is no audit log: admin actions are not recorded (to be handled by the host application).

## Test

```shell
$ bin/rails test
```

Fixtures live in `test/fixtures/lato`; integration tests sign in with `authenticate_user` (`test/test_helper.rb`). Dummy seed login: `admin@mail.com` / `Password1!`.

## Development

Clone repository, install dependencies, run migrations and start:

```shell
$ git clone https://github.com/Lato-GAM/lato_users
$ cd lato_users
$ bundle
$ rails db:migrate
$ rails db:seed
$ foreman start -f Procfile.dev
```

## Publish

```shell
$ ruby ./bin/publish.rb
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

