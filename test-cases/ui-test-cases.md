# UI Test Cases

## Test Environment

* Operating System: Ubuntu 24.04.4 LTS
* Browser 1: Chrome 149.0.7827.115
* Browser 2: Mozilla Firefox 151.0
* Browser Language: English
* Test Date: 2026-06-16
* Test Application: https://the-internet.herokuapp.com
* Test Type: Manual functional UI testing
* Execution Scope: All test cases were executed in both Chrome and Firefox
* Evidence: Screenshots and Network logs were collected using browser Developer Tools

---

## Scope

The following pages were selected:

* Form Authentication — `/login`
* File Upload — `/upload`
* Dynamic Loading — `/dynamic_loading/1`

These pages represent three different risk areas:

* authentication and session state;
* file handling and input validation;
* asynchronous UI state changes.

---

## Test Design Techniques

### Equivalence Partitioning

Login data was divided into the following equivalence classes:

* valid credentials;
* invalid username;
* invalid password;
* empty credentials.

File upload data was divided into:

* valid non-empty file;
* empty zero-byte file;
* no selected file;
* filename containing spaces and Unicode characters.

This technique reduces the number of required tests by selecting one representative value from each meaningful input class.

### Boundary Value Analysis

The following boundary values were tested:

* empty text fields with a length of zero;
* text fields containing one character;
* a file with a size of zero bytes;
* a filename containing spaces and Unicode characters.

Boundary values were selected because defects frequently occur around minimum values and unusual input formats.

### State Transition Testing

The following state transitions were tested:

Authentication:

```text
Anonymous → Authenticated → Logged out
```

Dynamic loading:

```text
Hidden → Loading → Visible
```

---

## Test Cases

| Test ID       | Title                                   | Priority | Preconditions                                                              | Steps                                                                                                                                          | Expected result                                                                                                                 | Actual result                                                                                                                                                                                                                                                           | Status |
| ------------- | --------------------------------------- | -------: | -------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| TC-LOGIN-001  | Login with valid credentials            |     High | User is on `/login` and is not authenticated                               | 1. Enter `tomsmith` in Username 2. Enter `SuperSecretPassword!` in Password 3. Click Login 4. Verify the URL, message, and Logout button       | The `/secure` page opens, a successful login message is displayed, and the Logout button is available                           | The `/secure` page opened. The message `You logged into a secure area!` and the Logout button were displayed.                                                                                                                                                           | Pass   |
| TC-LOGIN-002  | Login with unknown username             |     High | User is on `/login` and is not authenticated                               | 1. Enter `unknown-user` in Username 2. Enter `SuperSecretPassword!` in Password 3. Click Login 4. Verify the URL and error message             | Login is rejected, the user remains on `/login`, and a username error is displayed                                              | Login was rejected. The user remained on `/login`, and the message `Your username is invalid!` was displayed.                                                                                                                                                           | Pass   |
| TC-LOGIN-003  | Login with incorrect password           |     High | User is on `/login` and is not authenticated                               | 1. Enter `tomsmith` in Username 2. Enter `wrong-password` in Password 3. Click Login 4. Verify the URL and error message                       | Login is rejected, the user remains on `/login`, and a password error is displayed                                              | Login was rejected. The user remained on `/login`, and the message `Your password is invalid!` was displayed.                                                                                                                                                           | Pass   |
| TC-LOGIN-004  | Submit empty login form                 |     High | User is on `/login`; both fields are empty                                 | 1. Leave Username empty 2. Leave Password empty 3. Click Login 4. Verify the application response                                              | Login is rejected, an error message is displayed, and no server error occurs                                                    | Login was rejected. The user remained on `/login`, and the message `Your username is invalid!` was displayed. No server error occurred.                                                                                                                                 | Pass   |
| TC-LOGIN-005  | Submit one-character credentials        |   Medium | User is on `/login`                                                        | 1. Enter `a` in Username 2. Enter `a` in Password 3. Click Login 4. Verify the error message and application stability                         | Login is rejected with a controlled error, and the application continues working                                                | Login was rejected. The message `Your username is invalid!` was displayed, and the application continued working without a server error.                                                                                                                                | Pass   |
| TC-LOGIN-006  | Logout and verify session termination   |     High | User is authenticated and is on `/secure`                                  | 1. Click Logout 2. Verify the login page and logout message 3. Press the browser Back button 4. Open `/secure` directly in the address bar     | The user returns to `/login`, the logout message is displayed, and direct access to `/secure` requires authentication           | The user returned to `/login`, and the message `You logged out of the secure area!` was displayed. Pressing Back displayed a cached copy of `/secure`. However, direct navigation to `/secure` was rejected with the message `You must login to view the secure area!`. | Pass   |
| TC-UPLOAD-001 | Upload a valid text file                |     High | User is on `/upload`; `normal-file.txt` exists                             | 1. Select `normal-file.txt` 2. Click Upload 3. Verify the heading and filename                                                                 | The file is uploaded successfully, and the success heading and filename are displayed                                           | The file was uploaded successfully. The heading `File Uploaded!` and the filename `normal-file.txt` were displayed.                                                                                                                                                     | Pass   |
| TC-UPLOAD-002 | Upload an empty file                    |   Medium | User is on `/upload`; `empty-file.txt` exists and has a size of zero bytes | 1. Select `empty-file.txt` 2. Click Upload 3. Verify the result                                                                                | The request is handled without a 5xx error. The system either uploads the zero-byte file or displays a clear validation message | The zero-byte file was uploaded successfully. The heading `File Uploaded!` and the filename `empty-file.txt` were displayed. No server error occurred.                                                                                                                  | Pass   |
| TC-UPLOAD-003 | Submit without selecting a file         |     High | User is on `/upload`; no file is selected                                  | 1. Do not select a file 2. Click Upload 3. Check the page 4. Check the request in the Network tab                                              | The user receives clear validation feedback, and the server does not return a 5xx response                                      | The `POST /upload` request returned HTTP 500. The page displayed `Internal Server Error`, and no user-friendly validation message was shown.                                                                                                                            | Fail   |
| TC-UPLOAD-004 | Upload filename with spaces and Unicode |   Medium | User is on `/upload`; file `тестовый файл.txt` exists                      | 1. Select `тестовый файл.txt` 2. Click Upload 3. Verify the displayed filename                                                                 | The file is uploaded successfully, and the original filename is displayed correctly                                             | The file was uploaded successfully. Spaces and Unicode characters in the filename were displayed correctly.                                                                                                                                                             | Pass   |
| TC-DYN-001    | Content is hidden before Start          |   Medium | User is on `/dynamic_loading/1`; Start has not been clicked                | 1. Observe the page without clicking Start 2. Check the Start button 3. Check the loading indicator 4. Check `Hello World!`                    | The Start button is visible, while the loading indicator and `Hello World!` are not visible                                     | The loading indicator and `Hello World!` existed in the DOM but were not visible to the user. The Start button was displayed.                                                                                                                                           | Pass   |
| TC-DYN-002    | Content appears after loading           |     High | User is on `/dynamic_loading/1`; Start has not been clicked                | 1. Click Start 2. Observe the loading indicator 3. Wait for loading to finish 4. Verify that the indicator disappears 5. Verify `Hello World!` | The loading indicator appears and then disappears. After loading completes, `Hello World!` becomes visible                      | The loading indicator appeared after clicking Start and disappeared after loading completed. The text `Hello World!` then became visible.                                                                                                                               | Pass   |
| TC-DYN-003    | Reload returns page to initial state    |      Low | Dynamic content is visible after loading                                   | 1. Reload the page 2. Verify the Start button 3. Check the loading indicator 4. Check `Hello World!`                                           | The page returns to its initial state. The Start button is visible, while the loading indicator and `Hello World!` are hidden   | After reloading, the page returned to its initial state. The Start button was displayed, while the loading indicator and `Hello World!` were hidden.                                                                                                                    | Pass   |

---

# Test Execution Summary

| Metric                  | Value |
| ----------------------- | ----: |
| Total test cases        |    13 |
| Passed                  |    12 |
| Failed                  |     1 |
| Blocked                 |     0 |
| Confirmed defects       |     1 |
| Additional observations |     1 |
| Browsers tested         |     2 |

---

# Found Defects

## BUG-UI-001 — Uploading without selecting a file causes an Internal Server Error

**Severity:** Medium

**Priority:** High

**Status:** Open

### Environment

* Operating System: Ubuntu 24.04.4 LTS
* Browser 1: Chrome 149.0.7827.115
* Browser 2: Mozilla Firefox 151.0
* URL: `https://the-internet.herokuapp.com/upload`
* Reproducibility: Reproduced in both tested browsers

### Preconditions

* The File Upload page is open.
* No file is selected.

### Steps to Reproduce

1. Open `/upload`.
2. Do not select a file.
3. Click the Upload button.
4. Check the displayed page.
5. Open the Network tab in Developer Tools.
6. Inspect the `POST /upload` request.

### Expected Result

The form should not be submitted, or the user should receive a clear validation message explaining that a file must be selected.

The server should not return a 5xx response for invalid user input.

### Actual Result

The `POST /upload` request returned HTTP 500.

The page displayed `Internal Server Error`, and no user-friendly validation message was shown.

### Impact

Invalid user input is handled as an internal server failure.

This may:

* confuse the user;
* prevent the user from correcting the input;
* create unnecessary server-error alerts in monitoring systems;
* hide the actual cause of the failure.

### Evidence

#### Error page

![Internal Server Error after submitting upload without a file](../evidence/BUG-UI-001-page.png)

#### Network response

![POST upload request returned HTTP 500](../evidence/BUG-UI-001-network.png)


---

# Observations

## OBS-UI-001 — Browser Back displays a cached copy of the secure page after logout

### Environment

* Operating System: Ubuntu 24.04.4 LTS
* Browser 1: Chrome 149.0.7827.115
* Browser 2: Mozilla Firefox 151.0
* URL: `https://the-internet.herokuapp.com/secure`

### Description

After successful logout, pressing the browser Back button displayed a previously loaded copy of the `/secure` page.

However, direct navigation to `/secure` was rejected, and the message `You must login to view the secure area!` was displayed.

### Conclusion

The authenticated session was successfully terminated.

The page shown after pressing Back appears to be a browser-cached copy rather than an active authenticated page.

This behavior is not considered a confirmed authentication or authorization defect because direct access to the protected resource requires authentication.

In a production application containing sensitive information, cache-control headers should be reviewed to prevent protected content from remaining visible in browser history after logout.

---

# Cross-Browser Testing Notes

The manual test suite was executed in both Chrome and Firefox.

The confirmed upload defect was reproduced in both tested browsers.

The browser Back behavior after logout was treated as a caching observation because direct access to `/secure` required authentication.

No additional browser-specific functional defects were recorded during this test execution.
