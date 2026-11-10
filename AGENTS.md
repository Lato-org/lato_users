# AGENTS

## Project overview

Lato is ecosystem of Rails engines for building admin panels with authentication, user management, Bootstrap UI, reusable components, operations, settings, storage, spaces, and CMS features.

`lato_users` is extension gem for the base `lato` engine.

## Gem purpose

`lato_users` adds user and invitation management to a Lato admin panel.

Admins can:

- View and create users.
- Edit user identity and available Lato admin permissions. Passwords are set only on create; later changes go through "Force password update" (shown once, sessions revoked).
- Manage email verification actions.
- Generate new passwords for users.
- Create, resend and delete invitations.

## Permissions

- Every action requires `authenticate_session` plus `lato_users_admin` (`LatoUsers::ApplicationController`).
- `UsersController#load_available_admin_permissions` discovers columns on `Lato::User` by name: `lato_*_admin` (boolean, checkbox) and `lato_*_admin_role` (integer, select with `Lato::User.<column>_options`). New engine flags become mass-assignable for every users admin: `lato_users_admin` is a super-admin flag.
- Guards: no self-removal of `lato_users_admin`, no demoting/deleting the last users admin, role values validated against the options, `password` permitted on create only.
- Labels come from `activerecord.attributes.lato/user.<column>` (add them to `config/locales/*.yml` when adding an engine flag).

## Test conventions

- Fixtures in `test/fixtures/lato`; integration tests sign in with `authenticate_user` (`test/test_helper.rb`).
- The dummy `ApplicationController` inherits `Lato::ApplicationController`, not the engine one: do not use the engine controller as a production pattern for host pages.

## Documentation

- User-facing documentation lives in `test/dummy/app/views/application/documentation.html.erb`.
- Keep that file updated whenever install steps, permissions, configuration, or usage changes.
- Documentation should explain what the gem does, how to install it, and how to use it.
- Keep mount path `/lato-users` consistent across README, dummy docs and dummy routes.
- Avoid internal implementation details such as controller internals, private models, or database mechanics unless required for usage.

## Local setup

- Ruby via `rbenv`.
- Install gems: `bundle`.
- Migrate dummy DB: `rails db:migrate`.
- Seed dummy DB: `rails db:seed`.
- Start dev stack: `foreman start -f Procfile.dev`.

## Main commands

- Run tests: `bin/rails test`.
- Publish gem: `ruby ./bin/publish.rb`.

## Agent notes

- Keep Ruby strings double quoted.
- Keep documentation examples focused on installation, permissions, and common usage.
- Do not touch `.DS_Store` files if present.

## Security release baseline

- Rails 8.1.3.1 or newer in the 8.1 series is required.
- Run `ruby bin/publish.rb` from a named release branch after tests pass. It builds the exact version, commits changes, tags that commit, publishes to RubyGems, and pushes the branch and tag.
- Applications using Active Storage with vips require libvips 8.13 or newer.
