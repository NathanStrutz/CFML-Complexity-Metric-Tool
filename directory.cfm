<cfparam name="url.directory" default="#expandPath('/')#" />
<cfsetting requesttimeout="900" />

<cf_layout title="Directory Listing" directory="#url.directory#">

<!--- if it's just a file check, forward to the appropriate place --->
<cfif fileExists(url.directory)>
	<cflocation url="file.cfm?file=#url.directory#" />
</cfif>

<cfset complexityReport = application.complexity.getDirectoryComplexityReport(url.directory) />
<cfset dirReport = complexityReport.getDirectoryReport() />


<cfoutput><h2>Directory #url.directory#</h2></cfoutput>
<table class="dirReport">
	<thead>
		<tr>
			<td>Path</td>
			<td>Complexity</td>
		</tr>
	</thead>
	<tbody>
	<cfoutput query="dirReport">
		<tr>
			<td><cfif type EQ "file"><a href="file.cfm?directory=#url.directory#&file=#path#" class="mono">#relativePath#</a><cfelse>#relativePath#</cfif></td>
			<td align="right"><cfif complexity>#complexity#<cfelse>--</cfif></td>
		</tr>
	</cfoutput>
	</tbody>
</table>


<script type="text/javascript">
	$("table.dirReport tbody tr").colorFade(function(){
		return parseInt($(this).find("td:last").html());
	}, function(){
		return $(this);//.find("td:last");
	});
</script>

</cf_layout>