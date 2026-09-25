Include %occStatus

/// Routing table for the production-free D1 API, served under /api/d1claims.
///
/// This package is a STANDALONE parallel implementation. The original demo --
/// D1.Production and D1.Mock.API.D1API at /api/d1 -- is left exactly as it
/// was and still serves all nineteen endpoints through the production; nothing
/// here modifies it. Both stacks run side by side against the same tables.
///
/// What is reimplemented here is the eleven endpoints that never needed a
/// production: service -> operation with nothing in between, answering
/// straight from IRIS's own claim tables. No orchestration, no queueing, no
/// message routing, and nothing that leaves the instance -- so a web
/// application and this dispatch class are the whole runtime.
///
/// Everything else stays in the production. Five of those have a real business
/// process behind them (/patient, /visit, /diagnosis, /preauth, /discharge).
/// The other two, /admission and /billing, are only service -> operation --
/// but they reach the HIS through an operation with a configured HTTP outbound
/// adapter, and lifting them out meant standing up a second HIS client that
/// duplicated the production's paths, identity resolver and credentials. That
/// costs more than the production item it saves, and leaves two places to edit
/// when a HIS path moves. Sharing one HIS client is worth more than dropping a
/// config entry, so they stay put.
///
/// Deliberately nothing but routes: every Call below is one line into a
/// D1.REST.Impl class, which owns the validation and the logic.
///
/// Message, data, util and transform classes are REUSED from D1.Mock.* rather
/// than copied, so both APIs answer from the same tables and one seed loader
/// serves both.
///
/// Create the web application once with:
///   Do ##class(D1.REST.Router).Install()
Class D1.REST.Router Extends %CSP.REST
{

Parameter CONTENTTYPE = "application/json";

Parameter CHARSET = "utf-8";

/// Web application path this router is served from.
Parameter APPPATH = "/api/d1claims";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
  <Route Url="/local/patient" Method="POST" Call="LocalPatient" />
  <Route Url="/local/policy" Method="POST" Call="LocalPolicy" />
  <Route Url="/local/benefit" Method="POST" Call="LocalBenefit" />
  <Route Url="/local/preauth-info" Method="POST" Call="LocalPreAuthInfo" />
  <Route Url="/local/admission" Method="POST" Call="LocalAdmission" />
  <Route Url="/local/discharge-info" Method="POST" Call="LocalDischargeInfo" />
  <Route Url="/files" Method="POST" Call="Files" />
  <Route Url="/preauth/patch" Method="POST" Call="PreAuthPatch" />
  <Route Url="/discharge/patch" Method="POST" Call="DischargePatch" />
  <Route Url="/record-list" Method="POST" Call="RecordList" />
  <Route Url="/document-info" Method="POST" Call="DocumentInfo" />
  <Route Url="/reset" Method="POST" Call="Reset" />
</Routes>
}

ClassMethod LocalPatient() As %Status
{
	Return ##class(D1.REST.Impl.LocalPatient).Handle()
}

ClassMethod LocalPolicy() As %Status
{
	Return ##class(D1.REST.Impl.LocalPolicy).Handle()
}

ClassMethod LocalBenefit() As %Status
{
	Return ##class(D1.REST.Impl.LocalBenefit).Handle()
}

ClassMethod LocalPreAuthInfo() As %Status
{
	Return ##class(D1.REST.Impl.LocalPreAuthInfo).Handle()
}

ClassMethod LocalAdmission() As %Status
{
	Return ##class(D1.REST.Impl.LocalAdmission).Handle()
}

ClassMethod LocalDischargeInfo() As %Status
{
	Return ##class(D1.REST.Impl.LocalDischargeInfo).Handle()
}

ClassMethod Files() As %Status
{
	Return ##class(D1.REST.Impl.Files).Handle()
}

ClassMethod PreAuthPatch() As %Status
{
	Return ##class(D1.REST.Impl.PreAuthPatch).Handle()
}

ClassMethod DischargePatch() As %Status
{
	Return ##class(D1.REST.Impl.DischargePatch).Handle()
}

ClassMethod RecordList() As %Status
{
	Return ##class(D1.REST.Impl.RecordList).Handle()
}

ClassMethod DocumentInfo() As %Status
{
	Return ##class(D1.REST.Impl.DocumentInfo).Handle()
}

ClassMethod Reset() As %Status
{
	Return ##class(D1.REST.Impl.Reset).Handle()
}

/// Allowed authentication methods, as the Security.Applications bitmap.
/// 32 (bit 5) is Password on its own; add 64 (bit 6) for Unauthenticated,
/// 4 (bit 2) for Kerberos. Password-only is the default here: an
/// unauthenticated web application would expose every claim read and every
/// write on this router to anyone who can reach the port.
Parameter AUTHEPASSWORD = 32;

/// Create (or re-point) the web application serving this router.
///
///   Do ##class(D1.REST.Router).Install()
///
/// Re-runnable: an existing application at this path is modified rather than
/// duplicated, so it is safe to call again after changing a setting below.
///
/// pResource names the resource a caller must hold to reach the application;
/// "" leaves it public, which still requires a valid login because
/// authentication is password-only. To mirror whatever the original /api/d1
/// application uses, read it first with:
///   Do ##class(Security.Applications).Get("/api/d1", .p) ZWrite p
ClassMethod Install(pUrl As %String = {..#APPPATH}, pResource As %String = "", pAuthe As %Integer = {..#AUTHEPASSWORD}) As %Status
{
	Set tNamespace = $Namespace
	New $Namespace
	Set $Namespace = "%SYS"
	Set tProps("NameSpace") = tNamespace
	Set tProps("DispatchClass") = "D1.REST.Router"
	Set tProps("Enabled") = 1
	Set tProps("AutheEnabled") = pAuthe
	Set tProps("Resource") = pResource
	Set tProps("Description") = "D1 claim API -- the endpoints that need no production"
	If ##class(Security.Applications).Exists(pUrl) {
		Return ##class(Security.Applications).Modify(pUrl, .tProps)
	}
	Return ##class(Security.Applications).Create(pUrl, .tProps)
}

/// Print what the web application is actually configured as, for checking a
/// deployment without opening the Management Portal.
ClassMethod Show(pUrl As %String = {..#APPPATH})
{
	New $Namespace
	Set $Namespace = "%SYS"
	If '##class(Security.Applications).Exists(pUrl) {
		Write "no web application at ", pUrl, !
		Quit
	}
	Do ##class(Security.Applications).Get(pUrl, .tProps)
	Write pUrl, !
	For tKey = "NameSpace", "DispatchClass", "Enabled", "AutheEnabled", "Resource", "MatchRoles" {
		Write "  ", tKey, " = ", $Get(tProps(tKey)), !
	}
}

}
