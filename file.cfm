<cfparam name="url.directory" default="#expandPath('/')#" />
<cfparam name="url.file" />

<cf_layout title="File Complexity" directory="#url.directory#" file="#url.file#">

<cfset complexityReport = application.complexity.getFileComplexityReport(url.file) />

<cfoutput>
	<h2>File #url.file#</h2>
	<h3>Overall File Complexity: #complexityReport.getBasicComplexityCount()#</h3>
</cfoutput>

<cfif complexityReport.hasFunctions()>
	<cfset functions = complexityReport.getFunctions() />
	<table class="functions">
		<thead>
			<tr>
				<td>Function Name</td>
				<td>Lines</td>
				<td>Complexity</td>
			</tr>
		</thead>
		<tbody>
		<cfoutput query="functions">
			<tr>
				<td><a href="function.cfm?directory=#url.directory#&file=#url.file#&function=#name#" class="mono b">#name# ()</a></td>
				<td>#Lines#</td>
				<td>#complexity#</td>
			</tr>
		</cfoutput>
		</tbody>
	</table>

	<script type="text/javascript">
		$("table.functions tbody tr").colorFade(function(){
			return parseInt($(this).find("td:last").html());
		}, function(){
			return $(this);//.find("td:last");
		});
	</script>
<cfelse>
	<h5>No Functions</h5>
</cfif>

<cfif complexityReport.hasLineByLineDetails()>
	<cf_displaycomplexitycode contentComplexity="#complexityReport.getLineByLineDetails()#" />
</cfif>

</cf_layout>