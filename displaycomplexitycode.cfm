<cfif thistag.executionMode IS "start">
	<cfparam name="attributes.contentComplexity" type="query" />

	<table class="detailedComplexity">
		<cfoutput query="attributes.contentComplexity">
			<tr class="line" title="Line #line#, Complexity Score: #complexity#" data-complexity-score="#complexity#">
				<td class="lineNo">#line#</td>
				<td class="lineCode">#htmlCodeFormat(reReplace(code,"\t", "    ","ALL"))#</td>
			</tr>
		</cfoutput>
	</table>

	<script type="text/javascript">
		$("tr.line").colorFade(function(){
			return parseInt($(this).data("complexity-score"));
		}, function(){
			return $(this).find("td.lineCode");
		});
	</script>
</cfif>