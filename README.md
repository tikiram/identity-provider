
# identity-provider

- Set .env file

```bash
cp example.env .env
```

- Set working directory on Xcode

https://docs.vapor.codes/getting-started/xcode/

## Run

```bash
swift run App migrate
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
