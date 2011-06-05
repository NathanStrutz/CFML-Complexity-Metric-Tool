<cfparam name="url.directory" default="#expandPath('/')#" />
<cfparam name="url.file" />
<cfparam name="url.function" />

<cfset complexityReport = application.complexity.getFunctionComplexityReport(url.file, url.function) />

<cf_layout title="Function Complexity" directory="#url.directory#" file="#url.file#" function="#url.function#">

<cfoutput>
	<h2>File #url.file#</h2>
	<h3>Function #url.function#</h3>
	<h4>Overall Function Complexity: #complexityReport.getBasicComplexityCount()#</h4>
</cfoutput>

<cfif complexityReport.hasLineByLineDetails()>
	<cf_displaycomplexitycode contentComplexity="#complexityReport.getLineByLineDetails()#" />
</cfif>

</cf_layout>