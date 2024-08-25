#!/bin/haserl
<%in _common.cgi %>
<% page_title="Diagnostic log" %>
<%
if [ "POST" = "$REQUEST_METHOD" ]; then
	[ "true" = "$POST_iagree" ] || set_error_flag "You must explicitly give your consent."

	if [ -z "$error" ]; then
		result=$(yes yes | thingino-diag | tail -1)
	fi
fi
%>
<%in _header.cgi %>
<div class="row g-4 mb-4">
<div class="col col-12 col-xl-6">
<% if [ -z "$result" ]; then %>
<div class="alert alert-warning">
<p>The button below generates a massive log that needs to be further shared with developers to help them diagnose problems.
That log may contain sensitive or personal information, so be sure to review the result before sharing the link!</p>
<p>We use the termbin.com service to share the log. Please review their <a href="https://www.termbin.com/" target="_blank">acceptable use policy</a>.</p>
<form action="<%= $SCRIPT_NAME %>" method="post">
<% field_checkbox "iagree" "I've read and understood the information above. I want to proceed." %>
<% button_submit "Generate the diagnostic log" %>
</form>
</div>
<% else %>
<% if [ "https://" = "${result:0:8}" ]; then %>
<h3 class="mb-4"><a href="<%= $result %>"><%= $result %></a></h3>
<p>Please review the link and share it with the developers.</p>
<% else %>
<h3 class="text-danger"><%= $result %></h3>
<% fi %>
<% fi %>
</div>
</div>
<%in _footer.cgi %>
