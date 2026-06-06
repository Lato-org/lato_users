# AGENTS

## Project overview

Lato is ecosystem of Rails engines for building admin panels with authentication, user management, Bootstrap UI, reusable components, operations, settings, storage, spaces, and CMS features.

`lato_users` is extension gem for the base `lato` engine.

## Gem purpose

`lato_users` adds user and invitation management to a Lato admin panel.

Admins can:

- View and create users.
- Edit user identity, password, and available Lato admin permissions.
- Manage email verification actions.
- Generate new passwords for users.
- Create and delete invitations.

## Documentation

- User-facing documentation lives in `test/dummy/app/views/application/documentation.html.erb`.
- Keep that file updated whenever install steps, permissions, configuration, or usage changes.
- Documentation should explain what the gem does, how to install it, and how to use it.
- Avoid internal implementation details such as controller internals, route lists, private models, or database mechanics unless required for usage.

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
