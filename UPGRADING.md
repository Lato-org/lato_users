# Upgrading Lato Users

Version-specific notes. For the generic upgrade steps see the [README](README.md#upgrading).

## 3.1.0

- An admin can no longer remove their own `lato_users_admin` flag, and the last `lato_users_admin` cannot be demoted or deleted.
- `*_admin_role` values are validated against `Lato::User.<column>_options`.
- `password` is accepted only on create: changing it afterwards goes through the force password action.
- The forced password is rendered once in the response instead of the flash message.
- New `resend` action for invitations; destroying an accepted invitation now fails with an alert.

## Lato 3.25 compatibility

Requires Lato 3.25.0 or newer. Install the Lato session migration before deployment (`rails lato:install:migrations && rails db:migrate`): sessions become revocable database records and existing sessions are invalidated, so every user signs in again.
