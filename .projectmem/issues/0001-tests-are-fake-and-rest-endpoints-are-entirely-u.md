# #0001 Tests are fake and REST endpoints are entirely unauthenticated/vulnerable to SQL injection

- 2026-08-30T05:29:59Z `issue`: Tests are fake and REST endpoints are entirely unauthenticated/vulnerable to SQL injection [server/src/server.gleam]
- 2026-08-30T05:30:06Z `fix`: Replaced boilerplate/fake tests with genuine tests in server and cli. Enforced authentication and proper HTTP methods (POST) on REST endpoints to fix security vulnerabilities.
