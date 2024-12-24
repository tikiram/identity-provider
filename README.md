
# identity-provider

## Database

```
brew install postgresql@15
```

```sql
CREATE USER postgres SUPERUSER;
```

```sql
create database identity_provider;
```

## Project setup

- Set working directory on Xcode

https://docs.vapor.codes/getting-started/xcode/

- Edit scheme
  - run
    - Options
    - Working directory


## Run

```
swift run App migrate
```

```bash
swift run App serve
```


## General ToDos

- Remove refreshToken from response for Web Apps


- Check Vapor docs and add tests
- Check Oauth 2 protocol standars
- Add password reset flow
  - code generation
  - email notification
- Support passwordless email
