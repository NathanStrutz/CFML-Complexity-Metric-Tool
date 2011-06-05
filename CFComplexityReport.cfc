<!---
	I am a report for the complexity app's front-end friendly HTML interface.
	I'm probably not useful in other situations, but if you like me, you can use my methods, I don't care.
--->
<cfcomponent>

	<cffunction name="init" access="public" output="false" returntype="CFComplexityReport">
		<cfset variables.my = structNew() />
		<cfset variables.my.HasDirectoryReport = false />
		<cfset variables.my.HasFunctions = false />
		<cfset variables.my.HasLineByLineDetails = false />

		<cfreturn this />
	</cffunction>


	<cffunction name="getHasDirectoryReport" returntype="boolean" output="false" access="public">
		<cfreturn variables.my.HasDirectoryReport />
	</cffunction>
	<cfset variables.hasDirectoryReport = variables.getHasDirectoryReport />
	<cfset this.hasDirectoryReport = this.getHasDirectoryReport />

	<cffunction name="getDirectoryReport" returntype="query" output="false" access="public">
		<cfreturn variables.my.DirectoryReport />
	</cffunction>
	<cffunction name="setDirectoryReport" output="false" access="public">
		<cfargument  name="_DirectoryReport" type="query" />
		<cfset variables.my.HasDirectoryReport = true />
		<cfset variables.my.DirectoryReport = arguments._DirectoryReport />
	</cffunction>


	<cffunction name="getBasicComplexityCount" returntype="string" output="false" access="public">
		<cfif structKeyExists(variables.my, "BasicComplexityCount")>
			<cfreturn variables.my.BasicComplexityCount />
		<cfelse>
			<cfreturn 0 />
		</cfif>
	</cffunction>
	<cffunction name="setBasicComplexityCount" output="false" access="public">
		<cfargument  name="_BasicComplexityCount" type="string" />
		<cfset variables.my.BasicComplexityCount = arguments._BasicComplexityCount />
	</cffunction>


	<cffunction name="getHasFunctions" returntype="boolean" output="false" access="public">
		<cfreturn variables.my.HasFunctions />
	</cffunction>
	<cfset variables.hasFunctions = variables.getHasFunctions />
	<cfset this.hasFunctions = this.getHasFunctions />

	<cffunction name="getFunctions" returntype="query" output="false" access="public">
		<cfreturn variables.my.Functions />
	</cffunction>
	<cffunction name="setFunctions" output="false" access="public">
		<cfargument  name="_Functions" type="query" />
		<cfif arguments._Functions.recordcount>
			<cfset variables.my.HasFunctions = true />
		</cfif>
		<cfset variables.my.Functions = arguments._Functions />
	</cffunction>


	<cffunction name="getHasLineByLineDetails" returntype="boolean" output="false" access="public">
		<cfreturn variables.my.HasLineByLineDetails />
	</cffunction>
	<cfset variables.hasLineByLineDetails = variables.getHasLineByLineDetails />
	<cfset this.hasLineByLineDetails = this.getHasLineByLineDetails />

	<cffunction name="getLineByLineDetails" returntype="query" output="false" access="public">
		<cfreturn variables.my.LineByLineDetails />
	</cffunction>
	<cffunction name="setLineByLineDetails" output="false" access="public">
		<cfargument  name="_LineByLineDetails" type="query" />
		<cfset variables.my.HasLineByLineDetails = true />
		<cfset variables.my.LineByLineDetails = arguments._LineByLineDetails />
	</cffunction>

</cfcomponent>