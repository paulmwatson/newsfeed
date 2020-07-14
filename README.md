# README

## Database

### Heroku

- `heroku pg:backups:capture`
- `heroku pg:backups:download`
- `pg_restore --verbose --clean --no-acl --no-owner -U paulmwatson -d newsfeed_development latest.dump`
