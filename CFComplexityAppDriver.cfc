<!---
	I handle the back-end of the Complexity Meter user friendly HTML app.
	I scan a ColdFusion application for complexity and pass off reports.

	Special Note for Other Applications:
	If you want to call my methods from your own app, you can, but the CFComplexityMeter component is probably what you actually want.
--->
<cfcomponent output="false">

	<cffunction name="init" access="public" output="false" returntype="CFComplexityAppDriver">
		<cfset variables.separator = createObject("java","java.io.File").separator />
		<cfset variables.complexityMeter = createObject("component","CFComplexityMeter").init() />
		<cfreturn this />
	</cffunction>

	<cffunction name="newComplexityReport" access="private" output="false" returntype="CFComplexityReport">
		<cfreturn createObject("component","CFComplexityReport").init() />
	</cffunction>



	<cffunction name="getDirectoryComplexityReport" access="public" output="false" returntype="CFComplexityReport">
		<cfargument name="directoryPath" type="string" required="true" />
		<cfset var report = newComplexityReport() />
		<cfset report.setDirectoryReport( scanDirectory(arguments.directoryPath) )/>
		<cfreturn report />
	</cffunction>

 	<cffunction name="getFileComplexityReport" access="public" output="false" returntype="CFComplexityReport">
		<cfargument name="filePath" type="string" required="true" />
		<cfset var report = newComplexityReport() />

		<cfset report.setBasicComplexityCount( variables.complexityMeter.getFileBasicComplexityCount(arguments.filePath) )/>
		<cfif filePath does not contain ".cfc">
			<cfset report.setLineByLineDetails( variables.complexityMeter.getFileDetailedComplexity(arguments.filePath) )/>
		</cfif>
		<cfset report.setFunctions( scanFile(arguments.filePath) )/>

		<cfreturn report />
	</cffunction>

	<cffunction name="getFunctionComplexityReport" access="public" output="false" returntype="CFComplexityReport">
		<cfargument name="filePath" type="string" required="true" />
		<cfargument name="functionName" type="string" required="true" />
		<cfset var report = newComplexityReport() />

		<cfset report.setBasicComplexityCount( variables.complexityMeter.getFunctionBasicComplexityCount(arguments.filePath, arguments.functionName) )/>
		<cfset report.setLineByLineDetails( variables.complexityMeter.getFunctionDetailedComplexity(arguments.filePath, arguments.functionName) )/>
		<cfreturn report />
	</cffunction>



	<cffunction name="scanDirectory" access="private" output="false" returntype="Query">
		<cfargument name="directoryPath" type="string" required="true" />

		<cfset var dirList = 0 />
		<!---<cfset var complexityColumn = arrayNew(1) />--->

		<cfdirectory action="list" directory="#arguments.directoryPath#" recurse="true" name="dirList" />

		<cfquery name="dirList" dbtype="query">
			select directory, name, type, size, 0 as complexity, '' as path, '' as relativePath
			from dirList
			where
				   lower(name) like '%.cfm'
				or lower(name) like '%.cfc'
				or lower(name) like '%.js'
				or (
					type = 'Dir'
					and lower(name) != 'cvs'
					and lower(name) not like '.%'
					and lower(directory) not like '%.hg%'
					and lower(directory) not like '%.git%'
					and lower(directory) not like '%.svn%'
				)
				and size > 5
		</cfquery>


		<!--- create additional columns
		<cfset arrayResize(complexityColumn, dirList.recordcount) />
		<cfset queryAddColumn(dirList, "complexity", "integer", complexityColumn) />
		<cfset queryAddColumn(dirList, "path", "varchar", complexityColumn) />
		<cfset queryAddColumn(dirList, "relativePath", "varchar", complexityColumn) />
 		--->

		<cfloop query="dirList">
			<cfset dirList.path[currentrow] = directory & variables.separator & name />
			<cfset dirList.relativePath[currentrow] = replace(path, arguments.directoryPath, "", "ALL") />
			<cfif type EQ "file">
				<cfset dirList.complexity[currentrow] = variables.complexityMeter.getFileBasicComplexityCount(path) />
			</cfif>
		</cfloop>


		<cfquery name="dirList" dbtype="query">
			select *
			from dirList
			where complexity > 1
			or type = 'Dir'
		</cfquery>

		<cfreturn dirList />
	</cffunction>

	<cffunction name="scanFile" access="private" output="false" returntype="query">
		<cfargument name="filePath" type="string" required="true" />

		<cfset var fileFunctions = queryNew("name,lines,complexity","varchar,integer,integer") />
		<cfset var functionsList = variables.complexityMeter.getFunctions(filePath) />
		<cfset var i = "" />

		<cfloop list="#functionsList#" index="i">
			<cfset queryAddRow(fileFunctions) />
			<cfset querySetCell(fileFunctions,"name",i) />
			<cfset querySetCell(fileFunctions,"lines", variables.complexityMeter.getFunctionNumberOfLines(arguments.filePath, i)) />
			<cfset querySetCell(fileFunctions,"complexity", variables.complexityMeter.getFunctionBasicComplexityCount(arguments.filePath, i)) />
		</cfloop>

		<cfif fileFunctions.recordcount>
			<cfquery name="fileFunctions" dbtype="query">
				select *
				from fileFunctions
				where complexity > 1
			</cfquery>
		</cfif>

		<cfreturn fileFunctions />
	</cffunction>

</cfcomponent>