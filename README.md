# QA Middle Assignment

A practical QA project covering REST API testing, manual UI testing, Playwright E2E automation, SQL and MongoDB data validation, and booking-process documentation.

## Test Targets

| Application                                            | Purpose                   |
| ------------------------------------------------------ | ------------------------- |
| [Restful Booker](https://restful-booker.herokuapp.com) | REST API testing          |
| [The Internet](https://the-internet.herokuapp.com)     | Manual UI and E2E testing |


## Project Structure

```text
.
├── .github/
│   └── workflows/
│       └── qa-tests.yml
├── diagrams/
│   ├── booking-process.md
│   ├── booking-sequence.md
│   └── booking-state-transitions.md
├── nosql/
│   └── mongodb-answer.md
├── postman/
│   ├── collection.json
│   └── environment.json
├── sql/
│   └── queries.sql
├── test-cases/
│   ├── evidence/
│   └── ui-test-cases.md
├── tests/
│   ├── e2e/
│   ├── features/
│   ├── fixtures/
│   └── pages/
├── .dockerignore
├── .gitignore
├── Dockerfile
├── package.json
├── package-lock.json
├── playwright.config.js
└── README.md
```


## Coverage

### REST API Testing

The Postman collection covers the complete booking CRUD workflow:

* `POST /auth` — token generation;
* `GET /booking` — booking filters;
* `GET /booking/:id` — retrieval by ID;
* `POST /booking` — booking creation;
* `PUT /booking/:id` — full update;
* `PATCH /booking/:id` — partial update;
* `DELETE /booking/:id` — deletion.

Additional coverage includes:

* valid and invalid authentication;
* filters by `firstname`, `lastname`, `checkin`, and `checkout`;
* unauthorized access;
* nonexistent booking IDs;
* missing required fields;
* invalid field types;
* past dates;
* checkout earlier than checkin;
* malformed date values;
* verification that unauthorized changes are not applied;
* verification that deleted bookings return HTTP 404.

The collection uses the following environment variables:

* `base_url`
* `token`
* `booking_id`

Authentication tokens, booking IDs, names, and dates are generated dynamically. No manual variable changes are required between requests.

### Verified Newman Result

```text
Requests:   21 executed, 0 failed
Assertions: 116 executed, 0 failed
```

Tests marked `[KNOWN ISSUE]` intentionally assert reproducible defective behaviour. A passing assertion means that the issue was reproduced successfully, not that the API behaviour is considered correct.

### Manual UI Testing

Manual testing covers:

* Form Authentication;
* File Upload;
* Dynamic Loading.

The test suite contains positive, negative, and boundary scenarios.

Applied test-design techniques:

* Equivalence Partitioning;
* Boundary Value Analysis;
* State Transition Testing.

Manual execution result:

```text
Total:   13
Passed:  12
Failed:   1
Blocked:  0
```

See [UI test cases and the detailed UI bug report](test-cases/ui-test-cases.md).

### Playwright E2E Automation

The Playwright suite includes:

* positive and negative authentication tests;
* parameterized login scenarios;
* file upload testing;
* dynamic loading testing;
* Page Object Model architecture;
* data-driven fixtures;
* Gherkin descriptions;
* screenshots, videos, and traces on failure;
* built-in Playwright HTML reporting.

### SQL and MongoDB

The data-testing section contains:

* five PostgreSQL queries for QA data validation;
* overlap detection for bookings;
* aggregation and reporting checks;
* stale booking-state detection;
* a MongoDB booking-document design;
* recommended MongoDB indexes;
* validation approaches using MongoDB Compass and `mongosh`.

See:

* [PostgreSQL QA queries](sql/queries.sql)
* [MongoDB booking-data design](nosql/mongodb-answer.md)

### Documentation and Diagrams

The documentation section contains:

* booking creation and cancellation flow;
* happy path and exception scenarios;
* booking creation sequence between system components;
* booking state transitions;
* invalid transitions that should be rejected.

See:

* [Booking process](diagrams/booking-process.md)
* [Sequence diagram](diagrams/booking-sequence.md)
* [State transition diagram](diagrams/booking-state-transitions.md)

## Prerequisites

* Node.js 18 or newer;
* npm;
* internet access to the public test environments;
* Postman 10+ for opening and editing the collection.

Newman is launched through a pinned `npx` version and does not need to be installed globally.

## Installation

Clone the repository and install dependencies:

```bash
git clone https://github.com/MeirTl/qa-middle-assignment.git
cd qa-middle-assignment
npm ci
```

Install the Playwright Chromium browser:

```bash
npx playwright install chromium
```

On a clean Linux environment, install the browser and its system dependencies:

```bash
npx playwright install --with-deps chromium
```

## Running REST API Tests

Run the Postman collection through Newman:

```bash
npm run test:api
```

Equivalent direct command:

```bash
npx --yes newman@6.2.2 run \
  postman/collection.json \
  -e postman/environment.json \
  --reporters cli
```

The collection must be executed sequentially because later requests use the token and booking ID generated by earlier requests.

The final deletion request intentionally runs last.

## Running Playwright Tests

Run the full E2E suite:

```bash
npm run test:e2e
```

Equivalent direct command:

```bash
npx playwright test
```

Run tests in headed mode:

```bash
npm run test:headed
```

Open the last generated HTML report:

```bash
npm run report
```

Equivalent command:

```bash
npx playwright show-report
```

## Found Bugs

### API-001 — Exact check-in date is excluded from filtered results

**Endpoint:** `GET /booking?checkin={date}`

**Steps to reproduce:**

1. Create a booking with `checkin = 2026-06-22`.
2. Filter bookings using `checkin = 2026-06-22`.
3. Search the response for the created `bookingid`.

**Expected result:**
The created booking is included because its check-in date equals the filter boundary.

**Actual result:**
The created booking is absent from the response.

**Severity:** Medium

**Classification:** Potential defect / boundary-value inconsistency

---

### API-002 — Missing required firstname causes HTTP 500

**Endpoint:** `POST /booking`

**Steps to reproduce:**

1. Prepare an otherwise valid booking payload.
2. Remove the required `firstname` field.
3. Submit the request.
4. Repeat the request to verify reproducibility.

**Expected result:**
The API rejects the request with HTTP 400 or 422 and returns a clear validation error describing the missing required field.

**Actual result:**
The API consistently returns HTTP 500 Internal Server Error.

**Reproducibility:** 3/3 attempts

**Impact:**
Invalid client input is handled as an internal server failure, making it difficult for API consumers to identify and correct the request.

**Severity:** Medium

**Priority:** High

**Classification:** Input validation / error-handling defect

---

### API-003 — API accepts checkout earlier than checkin

**Endpoint:** `POST /booking`

**Steps to reproduce:**

1. Prepare a valid booking payload.
2. Set `checkin` to `2026-07-10`.
3. Set `checkout` to `2026-07-05`.
4. Submit the request.

**Expected result:**
The API rejects the request with HTTP 400 or 422 because checkout must be later than checkin.

**Actual result:**
The API returns HTTP 200 and creates the booking with the invalid date range.

**Impact:**
Logically invalid bookings may affect availability calculations and allow inconsistent booking records.

**Severity:** High

**Classification:** Potential business-validation defect

---

### API-004 — Invalid date input is accepted and stored as a corrupted value

**Endpoint:** `POST /booking`

**Steps to reproduce:**

1. Prepare a valid booking payload.
2. Set `bookingdates.checkin` to `"not-a-date"`.
3. Submit the request.

**Expected result:**
The API rejects the request with HTTP 400 or 422 and returns a clear date-validation error.

**Actual result:**
The API returns HTTP 200, creates the booking, and transforms the invalid input into `"0NaN-aN-aN"`.

**Impact:**
Malformed dates can be stored in the system, potentially breaking filtering, availability calculations, reporting, and downstream integrations.

**Severity:** High

**Classification:** Input validation / data-integrity defect

---

### API-005 — Invalid totalprice type is accepted and converted to null

**Endpoint:** `POST /booking`

**Steps to reproduce:**

1. Prepare a valid booking payload.
2. Set `totalprice` to the string `"four hundred"`.
3. Submit the request.

**Expected result:**
The API rejects the request with HTTP 400 or 422 because `totalprice` must be numeric.

**Actual result:**
The API returns HTTP 200, creates the booking, and stores `totalprice` as `null`.

**Impact:**
Invalid monetary data can be stored, potentially breaking price calculations, reporting, billing, and downstream integrations.

**Severity:** High

**Classification:** Input validation / data-integrity defect

---

### UI-001 — Upload without a selected file returns HTTP 500

**Page:** `/upload`

**Steps to reproduce:**

1. Open the File Upload page.
2. Do not select a file.
3. Click the upload button.

**Expected result:**
The page displays a controlled validation message asking the user to select a file.

**Actual result:**
The server returns HTTP 500 Internal Server Error.

**Severity:** Medium

Detailed evidence and screenshots are available in the [manual UI testing report](test-cases/ui-test-cases.md).

## Observations

### OBS-API-001 — Invalid credentials return HTTP 200

`POST /auth` with invalid credentials returns HTTP 200 and a response body containing `"Bad credentials"` instead of an authentication-related HTTP 4xx status.

Clients must inspect the response body instead of relying only on the HTTP status code.

### OBS-API-002 — Past booking dates are accepted

The API accepts bookings whose check-in and checkout dates are in the past.

This is documented as an observation rather than a confirmed defect because the available business requirements do not explicitly prohibit historical bookings.

## Public Environment Notes

Restful Booker is a shared public testing environment.

As a result:

* data created by other users may appear in filter responses;
* response times may vary;
* test data may periodically be reset;
* booking IDs must not be hardcoded.

The Postman collection creates its own booking data, stores the generated booking ID dynamically, and executes the full CRUD flow in one sequential run.

## What I Would Improve with More Time

* Add reusable JSON Schema validation for API responses.
* Execute Playwright tests across Chromium, Firefox, and WebKit.
* Add API contract testing.
* Add performance baselines for critical endpoints.
* Execute SQL queries against a disposable PostgreSQL test container.
* Add automated MongoDB validation against seeded test data.
* Extend payment, cancellation, refund, and notification scenarios.
* Add accessibility checks for the tested UI pages.
* Replace known-issue assertions after the corresponding defects are fixed.


## Continuous Integration

GitHub Actions automatically runs the Newman API collection and Playwright E2E suite on every push and pull request to `main`.

The Playwright HTML report and test artifacts are uploaded after each workflow run.

## Running Tests with Docker

Build the test image:

```bash
docker build -t qa-middle-assignment:latest .
```

Run the complete API and E2E test suite:

```bash
docker run --rm --init --ipc=host qa-middle-assignment:latest
```

The container installs dependencies from `package-lock.json` and sequentially executes the Newman and Playwright test suites.
