# Karate API Framework

[![Karate API Tests](https://github.com/samramkumarqa/karate-api-framework/actions/workflows/karate.yml/badge.svg)](https://github.com/samramkumarqa/karate-api-framework/actions/workflows/karate.yml)

BDD-style API test automation with **[Karate](https://karatelabs.io)** against the [DummyJSON](https://dummyjson.com/docs) REST API, plus a **Karate mock server** for offline tests.

Tests are plain `.feature` files. Karate handles HTTP, JSON matching, data-driven outlines and mocking without step-definition code; the only Java is the runner.

## Highlights

| Area | What it shows |
| --- | --- |
| JWT auth | Login once per run with `karate.callSingle`, Bearer tokens, refresh-token flow, cookie checks |
| Contract checks | Reusable fuzzy-match schemas (`#number? _ > 0`, `#regex`, optional `##string`) applied with `match each` |
| Data-driven | `Scenario Outline` with inline `Examples`, JSON cells (`body!`), and a dynamic outline fed from a CSV file |
| Query features | Paging, field `select`, sorting checked for 4 field/order combinations, case-insensitive search |
| Calculations | Cart line totals and grand total verified against prices, cross-checked with the product catalogue |
| Negative cases | 400 / 401 / 404 with exact error messages; invalid query parameters |
| Response time | Server-side `?delay=` used to assert `responseTime` |
| Mock server | Stateful mock written in Karate (`mocks/`): create → read → list → delete, validation errors, simulated outage (503), slow route |
| Config | `karate-config.js` reads `-D` properties, then environment variables, then defaults |
| Parallel | All features run in parallel from one JUnit 5 runner |
| Reporting | Karate HTML report, JUnit XML and Cucumber JSON |
| CI | GitHub Actions runs the mock suite (offline) and the live suite side by side, plus a weekday run |

## API behaviour worth knowing

DummyJSON **simulates writes**: add, update and delete return realistic responses but nothing is saved. The tests make this explicit; for example, a newly added product's id returns 404 on read. That also means the tests leave no data behind.

## Project structure

```
src/test/java/
├── com/qa/ApiTestRunner.java     JUnit 5 parallel runner
├── karate-config.js              base URL, credentials, timeouts
├── features/
│   ├── auth/       login, /auth/me, refresh, login errors
│   ├── products/   list, paging, select, sort, search, categories, writes, CSV-driven adds
│   ├── carts/      totals, catalogue prices, merging, user carts, validation
│   ├── users/      profile vs public record, filtering
│   └── mock/       tests against the mock server
├── mocks/          products-mock.feature (the mock server itself)
├── helpers/        login.feature (shared token), data.js (test data)
├── schemas/        product, review, cart-product match schemas
└── testdata/       new-products.csv
```

## Running

Requires Java 17+ and Maven.

```bash
mvn test                                              # everything, in parallel
mvn test -Dkarate.options="--tags @smoke"             # smoke scenarios
mvn test -Dkarate.options="--tags @mock"              # mock server only, no network
mvn test -Dkarate.options="--tags ~@mock"             # live API only
mvn test -Dkarate.options="classpath:features/carts"  # one folder
```

Report: `target/karate-reports/karate-summary.html`.

## Configuration

| Setting | Default | Override |
| --- | --- | --- |
| `base.url` | `https://dummyjson.com` | `-Dbase.url=…` or `BASE_URL` |
| `api.username` / `api.password` | DummyJSON's published demo user | `API_USERNAME` / `API_PASSWORD` |

Tags: `@smoke`, `@auth`, `@products`, `@carts`, `@users`, `@negative`, `@mock`.
