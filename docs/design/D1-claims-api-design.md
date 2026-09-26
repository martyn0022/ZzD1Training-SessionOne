# D1 Claims API — Design Document

Two-day InterSystems IRIS training. This document is the build specification for
the D1 Claims REST API. You will build two endpoints from it:

- **Day 2 morning (guided):** `POST /local/policy`
- **Day 2 afternoon (lighter guidance):** `POST /preauth/patch`

Everything in this document is traceable to the reference implementation. Each
section ends with a `Source:` list naming the files and methods it came from.
Where the reference code and its tests leave something genuinely undecided, it is
listed under **Open questions** rather than resolved here.

---

## 1. Architecture and conventions

These rules apply to **every** endpoint in the API, not just the two you build.

### 1.1 Request flow

```
REST client
    |  HTTP POST, JSON body
    v
Web application  (/api/d1claims)          dispatches to a single class
    |
    v
D1.REST.Router                            XData UrlMap: URL -> Call name
    |                                     one-line ClassMethod per route
    v
D1.REST.Impl.<Name>.Handle()              HTTP concerns: parse, validate, write
    |
    v
D1.REST.Impl.<Name>.Run()                 logic: SQL in, response object out
    |
    v
D1_Mock_Data.* tables
```

The web application is a REST web application whose **Dispatch Class** is
`D1.REST.Router` and whose namespace is the training namespace. The reference
installer sets these properties: `NameSpace`, `DispatchClass`, `Enabled = 1`,
`AutheEnabled` (32 = Password), `Resource`, `Description`. The application path
is `/api/d1claims`.

Nothing in this stack requires anything to be running beyond IRIS itself. Every
endpoint reads or writes tables in the same namespace.

**Source:** `claims-api/D1/REST/Router.cls` (`XData UrlMap`, `Parameter APPPATH`,
`Install()`); `claims-api/D1/REST/Base.cls` (class doc); `claims-api/D1/REST/Impl/LocalPolicy.cls`.

### 1.2 Router rules

The Router contains **routes and nothing else**. Specifically:

1. It extends `%CSP.REST`.
2. It declares `Parameter CONTENTTYPE = "application/json"` and
   `Parameter CHARSET = "utf-8"`.
3. Its `XData UrlMap` holds one `<Route>` per endpoint, each with `Url`,
   `Method="POST"` and `Call`.
4. For each route there is one `ClassMethod <Call>() As %Status` whose entire
   body is a single `Return ##class(D1.REST.Impl.<Name>).Handle()`.
5. No validation, no SQL, no response building ever appears in the Router.

Route and forwarder for the two endpoints in this document:

| Url | Method | Call | Forwards to |
|---|---|---|---|
| `/local/policy` | POST | `LocalPolicy` | `D1.REST.Impl.LocalPolicy` |
| `/preauth/patch` | POST | `PreAuthPatch` | `D1.REST.Impl.PreAuthPatch` |

Every route in the reference API is `POST`, including the ones named "Patch" —
the API specification names them "Patch" but specifies `Method: Post`
throughout.

**Source:** `claims-api/D1/REST/Router.cls` (`XData UrlMap`, `ClassMethod LocalPolicy()`,
`ClassMethod PreAuthPatch()`, `Parameter CONTENTTYPE`, `Parameter CHARSET`);
`claims-api/D1/REST/Impl/PreAuthPatch.cls` (class doc).

### 1.3 Base class contract

`D1.REST.Base` is **provided to you**. It is
`Class D1.REST.Base Extends %RegisteredObject [ Abstract ]`. Every Impl class
extends it and calls these methods; you never reimplement them.

| Member | Signature | Guarantees |
|---|---|---|
| `HTTP400BADREQUEST` | `Parameter` = `"400 Bad Request"` | The HTTP status line used by `BadRequest()`. |
| `HTTP500INTERNALSERVERERROR` | `Parameter` = `"500 Internal Server Error"` | The HTTP status line used by `ServerError()`. |
| `ImportBody` | `ClassMethod ImportBody(pRequest As %JSON.Adaptor) As %Status` | Reads the HTTP body, decodes UTF-8, parses it as JSON and imports it into `pRequest`. Returns an error `%Status` if the body is missing, is not valid JSON, is not a JSON **object**, or fails `%JSONImport`. On success `pRequest` is populated. |
| `ReadBodyAsUnicode` | `ClassMethod ReadBodyAsUnicode() As %String` | Returns the whole request body as real characters rather than UTF-8 bytes. Called by `ImportBody()`; call it directly only if you need the raw body. |
| `DecodeUTF8` | `ClassMethod DecodeUTF8(pRaw As %String) As %String` | Decodes a UTF-8 byte string, leaving an already-decoded string untouched. Used by `ReadBodyAsUnicode()`. |
| `WriteResponse` | `ClassMethod WriteResponse(pResponse As %JSON.Adaptor) As %Status` | Sets `Content-Type: application/json` and writes `pResponse` as the JSON body via `%JSONExport()`. Returns `$$$OK`. |
| `BadRequest` | `ClassMethod BadRequest(pMessage As %String) As %Status` | Sets HTTP status 400 **and** writes the envelope with `response_code` `"400"` and `pMessage`. |
| `ServerError` | `ClassMethod ServerError(pMessage As %String) As %Status` | Sets HTTP status 500 **and** writes the envelope with `response_code` `"500"` and `pMessage`. |
| `WriteEnvelope` | `ClassMethod WriteEnvelope(pCode As %String, pMessage As %String) As %Status` | Writes a bare `{"response_code": …, "response_message": …}` body. Does **not** touch the HTTP status. |
| `Log` | `ClassMethod Log(pMessage As %String)` | Writes one audit line to the console log, prefixed `[D1.REST]`. Used by write endpoints. |

Note the division: `BadRequest()` and `ServerError()` change the HTTP status
line; `WriteEnvelope()` does not.

**Source:** `claims-api/D1/REST/Base.cls` (all members).

### 1.4 The Handle() / Run() split

Every Impl class has exactly two public class methods.

`Handle()` owns the HTTP contract. `Run()` owns the logic and takes a message
object, so it can be called from a `%UnitTest` test case with no web request at
all.

**`Handle()` — exact step order:**

```
ClassMethod Handle() As %Status
```

1. Open a `Try` block. The whole method body is inside it.
2. Create a new instance of this endpoint's **request** message class.
3. Call `..ImportBody()` with it.
4. If that returned an error `%Status`, return `..BadRequest()` with the text of
   that status.
5. Perform this endpoint's field validation, one check at a time. Each failed
   check returns `..BadRequest()` with a message naming the offending field.
6. Call `..Run()`, passing the request and receiving the response by reference.
7. If `Run()` returned an error `%Status`, return `..ServerError()` with the text
   of that status.
8. Return `..WriteResponse()` with the response object.
9. In the `Catch` block, return `..ServerError()` with the exception's display
   string.

**`Run()` — exact step order:**

```
ClassMethod Run(pRequest As <RequestClass>, Output pResponse As <ResponseClass>) As %Status
```

1. Create the response object into `pResponse` **first**, before anything can
   fail.
2. Initialise the returned status to `$$$OK`.
3. Open a `Try` block.
4. Do the work: query or update the tables.
5. On a business miss (no row, refused), set `ResponseCode` and
   `ResponseMessage` on the response and leave the `Try` block early. Do **not**
   return an error `%Status`.
6. On success, populate the response's data properties, then set `ResponseCode`
   to `"200"` and `ResponseMessage` to `"Success"`.
7. In the `Catch` block, convert the exception to a `%Status`.
8. Return the status.

The key rule: **`Run()` returns an error `%Status` only for genuine failures**
(a bad SQL statement, a failed save). Business outcomes — "not found", "refused"
— travel in the response body with an `OK` status.

**Source:** `claims-api/D1/REST/Impl/LocalPolicy.cls` (`Handle()`, `Run()`);
`claims-api/D1/REST/Impl/PreAuthPatch.cls` (`Handle()`, `Run()`);
`claims-api/D1/REST/Base.cls` (class doc).

### 1.5 Error handling and the envelope

Every response body — success or failure — carries the same two envelope fields:

```json
{
  "response_code": "200",
  "response_message": "Success"
}
```

Successful data responses carry those two fields **plus** the endpoint's data
fields. Error responses carry only the two.

| Situation | HTTP status | `response_code` | Produced by |
|---|---|---|---|
| Body missing, unparseable, or not a JSON object | 400 | `"400"` | `Handle()` → `..BadRequest()` after `ImportBody()` fails |
| A required field is empty | 400 | `"400"` | `Handle()` → `..BadRequest()` |
| Business miss — no matching row | **200** | `"404"` | `Run()` sets it on the response |
| Refused — record belongs to another insurer | **200** | `"403"` | `Run()` sets it on the response |
| Success | 200 | `"200"` | `Run()` sets it on the response |
| `Run()` returned an error status, or an exception escaped | 500 | `"500"` | `Handle()` → `..ServerError()` |

The important asymmetry: **validation failures are HTTP 400, but "not found" is
HTTP 200 with `response_code` `"404"` in the body.** A miss is not a transport
failure — the request was well-formed and was answered. The reference test suite
asserts this explicitly.

On a `"404"` or `"403"` response, `Run()` sets only the two envelope properties
and never touches the data properties — an error body therefore carries the
envelope alone.

**Source:** `claims-api/D1/REST/Base.cls` (`BadRequest()`, `ServerError()`,
`WriteEnvelope()`); `claims-api/D1/REST/Impl/LocalPolicy.cls` (`Handle()`, `Run()`);
`claims-api/D1/REST/Impl/PreAuthPatch.cls` (`Run()`);
`src/D1/Mock/Util/ClaimCompanyResolver.cls` (outcome-code doc comment);
`tests/D1-API.postman_collection.json` ("Local Policy - unknown admission is a 404 envelope",
"Local Policy - admission_number is required").

### 1.6 Request and response class conventions

Message classes live in the `D1.Mock.Msg` package.

- Every request and response class includes `%JSON.Adaptor` in its superclass
  list.
- Every property that appears in JSON declares
  `%JSONFIELDNAME = "<snake_case_name>"`. The ObjectScript property name is
  PascalCase; the JSON name is snake_case. They are never the same.
- Every string property declares `MAXLEN`.
- Required key fields carry the `[ Required ]` keyword.
- Nested JSON objects are separate classes extending
  `(%SerialObject, %JSON.Adaptor, %XML.Adaptor)`, referenced as a property with
  its own `%JSONFIELDNAME`.
- Response classes always begin with `ResponseCode` (`response_code`, MAXLEN 10)
  and `ResponseMessage` (`response_message`, MAXLEN 255).
- Do **not** hand-write a `Storage` block. IRIS generates storage on compile.

Example of the naming rule, from the policy response:

| ObjectScript property | JSON field |
|---|---|
| `ResponseCode` | `response_code` |
| `HospitalNumber` | `hospital_number` |
| `AdmissionNumber` | `admission_number` |
| `Insurer` (object) | `insurer` |
| `Policies` (object) | `policies` |

**Source:** `src/D1/Mock/Msg/D1GetPolicyRequest.cls`,
`src/D1/Mock/Msg/D1GetPolicyResponse.cls`, `src/D1/Mock/Msg/InsurerInfo.cls`,
`src/D1/Mock/Msg/Policy.cls`, `src/D1/Mock/Msg/PatchPreAuthRequest.cls`,
`src/D1/Mock/Msg/PatchPreAuthResponse.cls`.

### 1.7 SQL conventions

- **Schema is `D1_Mock_Data`.** The persistent classes live in package
  `D1.Mock.Data`; the last dot becomes the schema separator, so class
  `D1.Mock.Data.ClaimPolicy` is table `D1_Mock_Data.ClaimPolicy`.
- **Dynamic SQL** (`%SQL.Statement`) is used for reads that return a row set:
  create the statement, `%Prepare()` it, `%Execute()` with the bound values, then
  `%Next()` and `%Get("ColumnName")`.
- **Embedded SQL** (`&sql(...)`) is used for single-value lookups, typically
  `SELECT … INTO :var`. After an `&sql`, check `SQLCODE = 0` for success.
  `SQLCODE` is `0` on success, not truthy — test it explicitly.
- **Always bind parameters.** Dynamic SQL uses `?` placeholders with the values
  passed to `%Execute()`. Embedded SQL uses `:hostVariable`. Never concatenate a
  request value into a SQL string.
- Wrap a `%Prepare()` or a `%Save()` whose failure should abort the method in
  `$$$THROWONERROR(...)`, so the surrounding `Catch` converts it to a `%Status`.
- To update a row, read its `ID`, `%OpenId()` it, check `$IsObject()`, set
  properties, `%Save()`.

**Source:** `claims-api/D1/REST/Impl/LocalPolicy.cls` (`Run()`);
`claims-api/D1/REST/Impl/PreAuthPatch.cls` (`Run()`);
`src/D1/Mock/Util/ClaimCompanyResolver.cls` (`Check()`);
`src/D1/Mock/Data/ClaimPolicy.cls`, `src/D1/Mock/Data/ClaimPreAuth.cls` (class names).

### 1.8 Naming conventions

| Thing | Convention | Examples from the code |
|---|---|---|
| REST dispatch package | `D1.REST` | `D1.REST.Router`, `D1.REST.Base` |
| Endpoint implementations | `D1.REST.Impl.<EndpointName>` | `D1.REST.Impl.LocalPolicy`, `D1.REST.Impl.PreAuthPatch` |
| Message classes | `D1.Mock.Msg.<Name>` | `D1.Mock.Msg.D1GetPolicyRequest` |
| Persistent data classes | `D1.Mock.Data.<Name>` | `D1.Mock.Data.ClaimPolicy` |
| Shared helpers | `D1.Mock.Util.<Name>` | `D1.Mock.Util.ClaimCompanyResolver` |
| Impl class name | Derived from the route, not the table | `/local/policy` → `LocalPolicy`; `/preauth/patch` → `PreAuthPatch` |
| Method parameters | `p` prefix, PascalCase | `pRequest`, `pResponse`, `pMessage`, `pAdmissionNumber` |
| Local variables | `t` prefix, PascalCase | `tRequest`, `tResponse`, `tSC`, `tStmt`, `tRs`, `tRow`, `tCode` |
| Status variable | always `tSC` | `Set tSC = $$$OK` |
| Class parameters | ALL CAPS | `CONTENTTYPE`, `APPPATH`, `HTTP400BADREQUEST` |

**Source:** `claims-api/D1/REST/Router.cls`, `claims-api/D1/REST/Base.cls`,
`claims-api/D1/REST/Impl/LocalPolicy.cls`, `claims-api/D1/REST/Impl/PreAuthPatch.cls`,
`src/D1/Mock/Util/ClaimCompanyResolver.cls`.

---

## 2. Endpoint: `POST /local/policy` — guided

### 2.1 Purpose

Return the insurance policy held against one admission: which insurer owns the
claim, and which policy and plan the patient is covered by. It reads the
`ClaimPolicy` table directly, keyed by `admission_number`. It is a pure read —
nothing is written.

### 2.2 Request JSON

```json
{
  "admission_number": "AN2026080001"
}
```

| JSON field | Type | Required | Maps to property | MAXLEN |
|---|---|---|---|---|
| `admission_number` | string | **Yes** | `AdmissionNumber` | 50 |
| `hospital_code` | string | No | `HospitalCode` | 50 |

`hospital_code` is declared on the request class but is **not read** by the
endpoint logic. It is accepted and ignored.

### 2.3 Response JSON

Success:

```json
{
  "response_code": "200",
  "response_message": "Success",
  "hospital_number": "HN000001",
  "admission_number": "AN2026080001",
  "insurer": {
    "company_code": "AIA",
    "company_name": "American International Assurance Co., Ltd"
  },
  "policies": {
    "policy_id": "POL000001",
    "plan_code": "AIA001",
    "plan_name": "AIA Health Gold",
    "policy_number": "AIA-TH-998821"
  }
}
```

Structure:

| JSON field | Type | Property | Class |
|---|---|---|---|
| `response_code` | string | `ResponseCode` | `D1GetPolicyResponse` |
| `response_message` | string | `ResponseMessage` | `D1GetPolicyResponse` |
| `hospital_number` | string | `HospitalNumber` | `D1GetPolicyResponse` |
| `admission_number` | string | `AdmissionNumber` | `D1GetPolicyResponse` |
| `insurer` | object | `Insurer` | `D1.Mock.Msg.InsurerInfo` |
| `insurer.company_code` | string | `CompanyCode` | `InsurerInfo` |
| `insurer.company_name` | string | `CompanyName` | `InsurerInfo` |
| `policies` | object | `Policies` | `D1.Mock.Msg.Policy` |
| `policies.policy_id` | string | `PolicyId` | `Policy` |
| `policies.plan_code` | string | `PlanCode` | `Policy` |
| `policies.plan_name` | string | `PlanName` | `Policy` |
| `policies.policy_number` | string | `PolicyNumber` | `Policy` |

`policies` is a **single object**, not an array.

### 2.4 `response_code` values

| Value | HTTP | When |
|---|---|---|
| `"400"` | 400 | The body is missing, is not valid JSON, is not a JSON object, or `admission_number` is empty. |
| `"404"` | 200 | The query returned no row for that `admission_number`. Message: `No policy found for admission_number <value>`. |
| `"200"` | 200 | A row was found. Message: `Success`. |
| `"500"` | 500 | `Run()` returned an error status, or an exception escaped `Handle()`. |

### 2.5 Tables and columns read

Table `D1_Mock_Data.ClaimPolicy`, filtered on `AdmissionNumber`.

Columns selected: `HospitalNumber`, `AdmissionNumber`, `CompanyCode`,
`CompanyName`, `PolicyId`, `PlanCode`, `PlanName`, `PolicyNumber`.

`AdmissionNumber` carries a unique index on this table, so at most one row
matches.

### 2.6 Guided build steps

**Step 1 — `D1.Mock.Msg.InsurerInfo`**

Create `Class D1.Mock.Msg.InsurerInfo Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)`.

Two string properties: `CompanyCode` (`company_code`, MAXLEN 50) and
`CompanyName` (`company_name`, MAXLEN 255). No methods. No storage block.

**Step 2 — `D1.Mock.Msg.Policy`**

Create `Class D1.Mock.Msg.Policy Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)`.

Four string properties: `PolicyId` (`policy_id`, 50), `PlanCode` (`plan_code`,
50), `PlanName` (`plan_name`, 200), `PolicyNumber` (`policy_number`, 50).

**Step 3 — `D1.Mock.Msg.D1GetPolicyRequest`**

Create the request class with `%JSON.Adaptor`. Two properties:
`AdmissionNumber` (`admission_number`, 50, `[ Required ]`) and `HospitalCode`
(`hospital_code`, 50).

**Step 4 — `D1.Mock.Msg.D1GetPolicyResponse`**

Create the response class with `%JSON.Adaptor`. Six properties, in this order:
`ResponseCode`, `ResponseMessage`, `HospitalNumber`, `AdmissionNumber`,
`Insurer` (type `D1.Mock.Msg.InsurerInfo`, `%JSONFIELDNAME = "insurer"`),
`Policies` (type `D1.Mock.Msg.Policy`, `%JSONFIELDNAME = "policies"`).

**Step 5 — `D1.REST.Impl.LocalPolicy`, method `Run()`**

```
ClassMethod Run(pRequest As D1.Mock.Msg.D1GetPolicyRequest,
                Output pResponse As D1.Mock.Msg.D1GetPolicyResponse) As %Status
```

Create `Class D1.REST.Impl.LocalPolicy Extends D1.REST.Base`.

`Run()` must:

1. Instantiate the response into `pResponse` before anything else.
2. Initialise the status variable to `$$$OK` and open a `Try`.
3. Build a `%SQL.Statement`, prepare the `SELECT` from §2.5 with a single `?`
   placeholder on `AdmissionNumber`, and throw on a prepare error.
4. Execute it, binding `pRequest.AdmissionNumber`.
5. If the result set has no first row, set `ResponseCode` to `"404"` and
   `ResponseMessage` to the not-found message from §2.4, then leave the `Try`.
6. Otherwise copy each selected column onto the response: the two flat fields
   directly, the two company columns onto the `Insurer` sub-object, and the four
   policy columns onto the `Policies` sub-object.
7. Set `ResponseCode` to `"200"` and `ResponseMessage` to `"Success"`.
8. Catch any exception into the status variable and return it.

**Step 6 — `D1.REST.Impl.LocalPolicy`, method `Handle()`**

```
ClassMethod Handle() As %Status
```

Follow the nine steps in §1.4 exactly. This endpoint's only validation (step 5
of that list) is: if `AdmissionNumber` is empty, return `..BadRequest()` with a
message that contains the words `admission_number is required`.

**Step 7 — wire the route**

In `D1.REST.Router`, add to `XData UrlMap`:

```xml
<Route Url="/local/policy" Method="POST" Call="LocalPolicy" />
```

and add the matching one-line forwarder `ClassMethod LocalPolicy() As %Status`
returning `##class(D1.REST.Impl.LocalPolicy).Handle()`.

### 2.7 Acceptance checks

Seed values used below: admission `AN2026080001` belongs to hospital number
`HN000001`, insurer `AIA`, policy `AIA-TH-998821`.

**Check 1 — happy path.** `POST /api/d1claims/local/policy`

```json
{ "admission_number": "AN2026080001" }
```

Expect HTTP 200 and: `response_code` `"200"`; `hospital_number` `"HN000001"`;
`admission_number` `"AN2026080001"`; `insurer.company_code` `"AIA"`;
`insurer.company_name` `"American International Assurance Co., Ltd"`;
`policies.policy_number` `"AIA-TH-998821"`; `policies.plan_name`
`"AIA Health Gold"`.

**Check 2 — required field.** `POST /api/d1claims/local/policy`

```json
{}
```

Expect HTTP **400**, `response_code` `"400"`, and a non-empty
`response_message` containing the string `admission_number`.

**Check 3 — unknown admission.** `POST /api/d1claims/local/policy`

```json
{ "admission_number": "AN-DOES-NOT-EXIST" }
```

Expect HTTP **200** (not 404) and `response_code` `"404"`.

**Source:** `claims-api/D1/REST/Impl/LocalPolicy.cls` (`Handle()`, `Run()`);
`claims-api/D1/REST/Router.cls` (`XData UrlMap`, `ClassMethod LocalPolicy()`);
`src/D1/Mock/Msg/D1GetPolicyRequest.cls`, `src/D1/Mock/Msg/D1GetPolicyResponse.cls`,
`src/D1/Mock/Msg/InsurerInfo.cls`, `src/D1/Mock/Msg/Policy.cls`;
`src/D1/Mock/Data/ClaimPolicy.cls` (properties, `AdmissionIdx`);
`tests/D1-API.postman_collection.json` ("Local Policy",
"Local Policy - admission_number is required",
"Local Policy - unknown admission is a 404 envelope");
`src/D1/Mock/Test/ApiFunctionalTest.cls` (`TestD1GetPolicyReturnsInsurerAndPolicy()`).

---

## 3. Endpoint: `POST /preauth/patch` — lighter guidance

### 3.1 Purpose

Record the insurer's pre-authorization decision against an existing
pre-authorization row. The caller names an admission and identifies itself by
company code; the endpoint updates only the fields the request actually carries.

### 3.2 Request JSON

```json
{
  "admission_number": "AN2026080002",
  "company_code": "AIA",
  "claim_case_number": "PA-2026-100077",
  "claim_status": "Pre-Accepted",
  "submit_date": "2026-10-03 10:00:00"
}
```

| JSON field | Type | Required | Maps to property | MAXLEN |
|---|---|---|---|---|
| `admission_number` | string | **Yes** | `AdmissionNumber` | 50 |
| `company_code` | string | **Yes** | `CompanyCode` | 50 |
| `claim_case_number` | string | No | `ClaimCaseNumber` | 50 |
| `claim_status` | string | No | `ClaimStatus` | 50 |
| `submit_date` | string | No | `SubmitDate` | 30 |

`submit_date` is a wire-format string `yyyy-MM-dd HH:mm:ss`, stored verbatim.
The request class documents the `claim_status` enum as "Waiting for Medical" /
"Pre-Accepted" / "Rejected" / "Pre-Authorize Submitted" — see **Open questions**.

### 3.3 Response JSON

The response is the envelope only — there are no data fields.

```json
{
  "response_code": "200",
  "response_message": "Success"
}
```

| JSON field | Type | Property |
|---|---|---|
| `response_code` | string | `ResponseCode` (MAXLEN 10) |
| `response_message` | string | `ResponseMessage` (MAXLEN 255) |

### 3.4 `response_code` values

| Value | HTTP | When |
|---|---|---|
| `"400"` | 400 | Body missing/unparseable/not an object, or `admission_number` or `company_code` is empty. |
| `"404"` | 200 | Either no policy row exists for the admission (so no insurer owns it), or a policy exists but no pre-authorization row does. |
| `"403"` | 200 | A policy row exists but belongs to a **different** `company_code`. |
| `"200"` | 200 | The row was found, owned by this insurer, and saved. |
| `"500"` | 500 | `Run()` returned an error status, or an exception escaped `Handle()`. |

Both `"404"` and `"403"` come back over HTTP 200. `403` rather than `404` on a
mismatch is deliberate: it is a refused record, not a missing one, and
collapsing the two would let a caller probe which admission numbers exist.

### 3.5 Business rules

**Rule 1 — the insurer check comes first.** Before touching the
pre-authorization row, verify the admission belongs to the calling insurer.
`company_code` is an authorisation boundary, not a lookup key: the service holds
records for several insurers and one must not patch another's. The check is
performed by `D1.Mock.Util.ClaimCompanyResolver.Check()` (see **Scope issues**).

The check works by joining through the policy table: `company_code` exists only
on `ClaimPolicy`, whose `AdmissionNumber` is unique, so admission → policy →
company is single-valued. A consequence: **an admission with no `ClaimPolicy`
row is invisible to this endpoint** and yields `"404"`.

**Rule 2 — absent fields are left unchanged.** Each of the three optional
fields is written **only if the request carries a non-empty value for it**. An
absent or empty optional field means "leave alone", never "clear". Without this,
a patch that reports only a status would wipe the stored case number. This is
the single most important behaviour of this endpoint and the reference test
suite asserts it directly.

**Rule 3 — most recent row wins.** `ClaimId` is unique but `AdmissionNumber` is
not, so one admission can hold several pre-authorization rows. This call is keyed
on the admission alone, so select the most recent by descending `ID` rather than
an arbitrary one.

**Rule 4 — log the write.** Successful patches write one audit line via
`..Log()`, naming the claim id, admission number, company code and resulting
claim status.

### 3.6 Tables and columns

| Table | Access | Columns |
|---|---|---|
| `D1_Mock_Data.ClaimPolicy` | read (inside the insurer check) | `CompanyCode`, filtered on `AdmissionNumber` |
| `D1_Mock_Data.ClaimPreAuth` | read then update | select `ID` filtered on `AdmissionNumber`, ordered by `ID` descending, top 1; then update `ClaimCaseNumber`, `ClaimStatus`, `SubmitDate` |

### 3.7 Build steps — goals and hints

**Goal 1 — the message classes.**

- `D1.Mock.Msg.PatchPreAuthRequest`, with `%JSON.Adaptor` and the five
  properties in §3.2. The two keys carry `[ Required ]`; the other three do not.
- `D1.Mock.Msg.PatchPreAuthResponse`, with `%JSON.Adaptor` and only
  `ResponseCode` and `ResponseMessage`.

*Hint:* the response class has no data properties at all. Resist adding any.

**Goal 2 — `D1.REST.Impl.PreAuthPatch.Run()`**

```
ClassMethod Run(pRequest As D1.Mock.Msg.PatchPreAuthRequest,
                Output pResponse As D1.Mock.Msg.PatchPreAuthResponse) As %Status
```

Enforce Rule 1, then Rule 3, then Rule 2, then Rule 4, then set the success
envelope.

*Hints:*
- The insurer check returns a code string and an output message. If the code is
  not `"200"`, copy both onto the response and stop — do not return an error
  `%Status`.
- For Rule 3, embedded SQL with `SELECT TOP 1 … INTO :var … ORDER BY ID DESC` is
  the shape used. Remember `SQLCODE = 0` means a row was found.
- Turn the id into an object with `%OpenId()`, and check `$IsObject()` before
  using it — a missing row here is the second `"404"` path in §3.4.
- For Rule 2, a postfix conditional `Set` is the idiom: assign the property only
  when the incoming value is not `""`.
- Save the row and throw on failure so the `Catch` turns it into a `%Status`.

**Goal 3 — `D1.REST.Impl.PreAuthPatch.Handle()`**

```
ClassMethod Handle() As %Status
```

The nine steps of §1.4. This endpoint validates **two** fields, each with its
own `..BadRequest()` message: `admission_number is required` and
`company_code is required`.

*Note:* because `Handle()` rejects both empty keys before calling `Run()`, the
insurer check's own empty-field branch is unreachable through the HTTP path.

**Goal 4 — wire the route.** `<Route Url="/preauth/patch" Method="POST" Call="PreAuthPatch" />`
plus the one-line forwarder.

### 3.8 Acceptance checks

Seed values: admission `AN2026080002` is owned by insurer `AIA` and has a
pre-authorization row whose `claim_case_number` is `PA-2026-100077`.

**Check 1 — record the decision.** `POST /api/d1claims/preauth/patch`

```json
{
  "admission_number": "AN2026080002",
  "company_code": "AIA",
  "claim_case_number": "PA-2026-100077",
  "claim_status": "Pre-Accepted",
  "submit_date": "2026-10-03 10:00:00"
}
```

Expect HTTP 200 and `response_code` `"200"`.

**Check 2 — absent fields are left alone.** `POST /api/d1claims/preauth/patch`

```json
{
  "admission_number": "AN2026080002",
  "company_code": "AIA",
  "claim_status": "Accepted"
}
```

Expect HTTP 200 and `response_code` `"200"`. This request alone only proves the
call succeeded — the behaviour it exists to test is verified by the **next**
read, which must still show `claim_case_number` as `PA-2026-100077`, unchanged.

**Check 3 — unknown admission.** `POST /api/d1claims/preauth/patch`

```json
{
  "admission_number": "AN-DOES-NOT-EXIST",
  "company_code": "AIA",
  "claim_status": "Accepted"
}
```

Expect HTTP 200 and a `response_code` that is **not** `"200"`. Per §3.4 this is
`"404"`; the acceptance test asserts only "not a success".

**Check 4 — another insurer is refused.** Patch an admission owned by `AIA`
while sending a different `company_code`:

```json
{
  "admission_number": "AN2026080001",
  "company_code": "MTL",
  "claim_status": "Rejected"
}
```

Expect `response_code` `"403"`, and the stored `ClaimStatus` must **not** have
become `Rejected` — nothing is written on a refused patch.

**Source:** `claims-api/D1/REST/Impl/PreAuthPatch.cls` (class doc, `Handle()`, `Run()`);
`claims-api/D1/REST/Router.cls` (`XData UrlMap`, `ClassMethod PreAuthPatch()`);
`src/D1/Mock/Msg/PatchPreAuthRequest.cls`, `src/D1/Mock/Msg/PatchPreAuthResponse.cls`;
`src/D1/Mock/Util/ClaimCompanyResolver.cls` (class doc, `Check()`);
`src/D1/Mock/Data/ClaimPreAuth.cls` (properties, `ClaimIdIdx`, `AdmissionIdx`);
`src/D1/Mock/Data/ClaimPolicy.cls` (`CompanyCode`, `AdmissionIdx`);
`tests/D1-API.postman_collection.json` ("PreAuth Patch - record the insurer decision",
"PreAuth Patch - absent fields are left alone", "PreAuth Patch - unknown admission");
`src/D1/Mock/Test/ApiFunctionalTest.cls` (`TestPatchPreAuthWritesOnlySuppliedFields()`,
`TestPatchRejectsAnotherInsurer()`).

---

## 4. Provided vs. written

### Provided to you

| Item | What it is |
|---|---|
| `D1.REST.Base` | The abstract base class in §1.3. Complete — do not modify. |
| `D1.Mock.Data.ClaimPolicy` | Persistent class, table `D1_Mock_Data.ClaimPolicy`. Unique index on `AdmissionNumber`. |
| `D1.Mock.Data.ClaimPreAuth` | Persistent class, table `D1_Mock_Data.ClaimPreAuth`. Unique index on `ClaimId`, non-unique on `AdmissionNumber` and `HospitalNumber`. |
| Seed data | Loaded before you start. Supplies admission `AN2026080001` (insurer `AIA`, policy `AIA-TH-998821`, plan `AIA Health Gold`, hospital number `HN000001`, pre-auth `REQ000000P1` / case `PA-2026-071122`) and admission `AN2026080002` (same insurer, pre-auth `REQ000000P2` / case `PA-2026-100077`). |
| The web application | `/api/d1claims`, dispatch class `D1.REST.Router`, password authentication. |
| Acceptance tests | The requests in §2.7 and §3.8. |

### Written by you

| Item | Section |
|---|---|
| `D1.REST.Router` — `XData UrlMap` plus one forwarder per route | §1.2, §2.6 step 7, §3.7 goal 4 |
| `D1.Mock.Msg.InsurerInfo` | §2.6 step 1 |
| `D1.Mock.Msg.Policy` | §2.6 step 2 |
| `D1.Mock.Msg.D1GetPolicyRequest` | §2.6 step 3 |
| `D1.Mock.Msg.D1GetPolicyResponse` | §2.6 step 4 |
| `D1.REST.Impl.LocalPolicy` — `Handle()` and `Run()` | §2.6 steps 5–6 |
| `D1.Mock.Msg.PatchPreAuthRequest` | §3.7 goal 1 |
| `D1.Mock.Msg.PatchPreAuthResponse` | §3.7 goal 1 |
| `D1.REST.Impl.PreAuthPatch` — `Handle()` and `Run()` | §3.7 goals 2–3 |

**Source:** `claims-api/D1/REST/Base.cls`; `src/D1/Mock/Data/ClaimPolicy.cls`;
`src/D1/Mock/Data/ClaimPreAuth.cls`; `src/D1/Mock/Data/ClaimLoader.cls` (`Reset()`, seeded values);
`claims-api/D1/REST/Router.cls` (`Install()`, `Parameter APPPATH`).

---

## Scope issues

Things the reference code depends on that fall outside the training scope. Each
carries a **suggestion** — these are proposals, not decisions.

### S1. Message classes inherit from interoperability superclasses

Every class in `D1.Mock.Msg` extends `Ens.Request` or `Ens.Response` alongside
`%JSON.Adaptor`. Those superclasses are outside the scope of this training, and
they are persistent — which is why the exported classes carry generated
`Storage` blocks.

Neither endpoint in this document ever saves a message object; the objects live
only for the duration of one HTTP request.

**Suggestion:** have attendees declare message classes as
`Extends (%RegisteredObject, %JSON.Adaptor)`. Nothing in §2 or §3 depends on the
messages being persistent. The property definitions, `%JSONFIELDNAME` values and
`%JSONImport` / `%JSONExport` behaviour are unaffected. If the classes are later
moved into an environment that needs the original superclasses, only the
`Extends` line changes.

### S2. `D1.Mock.Util.ClaimCompanyResolver` is required but not listed as provided

`POST /preauth/patch` calls `D1.Mock.Util.ClaimCompanyResolver.Check()` to
enforce the insurer boundary (§3.5, Rule 1). The provided-code list given for
this training names only `D1.REST.Base`, the `D1.Mock.Data` classes and the seed
data. The resolver is neither provided nor in the "attendees write" list.

**Suggestion (pick one):**

- **Provide it**, with the signature
  `ClassMethod Check(pAdmissionNumber As %String, pCompanyCode As %String, Output pMessage As %String) As %String`
  returning `"200"` / `"403"` / `"404"` / `"400"`. This keeps the afternoon
  focused on patch semantics, which is the harder idea.
- **Have attendees write it** as an extra step. It is a single embedded-SQL
  lookup against `ClaimPolicy.CompanyCode` plus three comparisons, and it
  teaches the join-through-policy reasoning. This adds roughly one exercise's
  worth of time.

### S3. `$$$THROWONERROR` and `Include %occStatus`

The Impl classes open with `Include %occStatus` and use `$$$THROWONERROR(...)`
to abort on a failed `%Prepare()` or `%Save()`. Day-1 covers `%Status` and
`try`/`catch` but may not have covered this macro.

**Suggestion:** cover `$$$THROWONERROR` in five minutes at the start of Day 2 as
"the one-liner that turns a bad `%Status` into an exception your `Catch` already
handles". The alternative — an explicit `If $$$ISERR(tSC) { … }` after each call
— also works and needs no new macro, at the cost of more lines.

---

## Open questions

Points where the code, its documentation and its tests do not settle the answer.
Listed rather than decided.

### Q1. Is `claim_status` a closed enum?

`D1.Mock.Msg.PatchPreAuthRequest` documents `ClaimStatus` as "Waiting for
Medical" / "Pre-Accepted" / "Rejected" / "Pre-Authorize Submitted". But the
acceptance test in §3.8 Check 2 sends `"Accepted"`, which is not in that list,
and expects `response_code` `"200"`. The endpoint logic performs no enum
validation at all.

So: is the documented list a contract to be enforced, or descriptive only? If
attendees add validation, Check 2 fails. **This document therefore specifies no
enum validation**, matching the code — but the discrepancy should be resolved
with the API owners before this ships.

### Q2. Does `[ Required ]` enforce anything during `%JSONImport()`?

Both request classes mark their key fields `[ Required ]`, *and* `Handle()`
separately checks those same fields for `""` and returns 400. The observable 400
in the acceptance tests is produced by the explicit check. Whether the
`[ Required ]` keyword would independently reject the payload during
`%JSONImport()` is not demonstrated anywhere in the code or tests.

This matters for attendees: if the keyword alone were sufficient, the explicit
checks would be redundant; if it is not, omitting the checks would silently lose
the 400. **This document specifies the explicit checks**, because that is what
the reference code does — but the underlying behaviour should be confirmed on
the training instance before Day 2.

### Q3. `hospital_code` on the policy request

`D1GetPolicyRequest` declares `HospitalCode` / `hospital_code`, but
`LocalPolicy.Run()` never reads it, and no acceptance test sends it. It is
unclear whether it is reserved for future multi-hospital filtering or is a
leftover. This document specifies it as accepted-and-ignored, matching the code.

### Q4. Which admission should the afternoon exercise patch?

The two reference test suites disagree on the fixture, though not on the
behaviour: the HTTP acceptance tests patch `AN2026080002`, while the in-process
tests patch `AN2026080001`. Both are seeded and owned by `AIA`, so either works.
Worth fixing on one for the training so attendees comparing notes see identical
results. §3.8 uses `AN2026080002`.

**Source:** `src/D1/Mock/Msg/PatchPreAuthRequest.cls` (`ClaimStatus` doc comment, `[ Required ]` keywords);
`src/D1/Mock/Msg/D1GetPolicyRequest.cls` (`HospitalCode`, `[ Required ]`);
`claims-api/D1/REST/Impl/PreAuthPatch.cls` (`Handle()`, `Run()`);
`claims-api/D1/REST/Impl/LocalPolicy.cls` (`Handle()`, `Run()`);
`tests/D1-API.postman_collection.json` ("PreAuth Patch - absent fields are left alone",
"PreAuth Patch - record the insurer decision");
`src/D1/Mock/Test/ApiFunctionalTest.cls` (`TestPatchPreAuthWritesOnlySuppliedFields()`,
`TestPatchRejectsAnotherInsurer()`).
