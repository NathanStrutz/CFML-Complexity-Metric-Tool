<!---

	I impliment a version of Thomas McCabe's Measure of Cyclomatic Complexity
		link: http://en.wikipedia.org/wiki/Cyclomatic_complexity
	Further, I impliment a custom line-by-line complexity measure, for effect ;)


mid-day thoughts
On directory list, I would like to see a line count, per file
What if the directory list had colors like the file details?
The cfc methods view, we NEED to have function-by-function complexity
	- and line number counts here, too
	- and colors, like i'm proposing for the dir list


Somewhere, we NEED to display a help on how file complexity is determined.
	You get a point for if/loop/etc
	You get a point for every 100 lines (maybe should be 400 lines for files, 100 lines for functions)
	You get a point for how deeply nested you are

For adding/subtracting line by line, show the addition, add to query, THEN (and only then) remove any scores.




	Implimentation Ideas:

	scan a directory
		provide a list of full file complexity, best candidates for reducing complexity
		drill down to scan a single file
			provide a list of functions with complexity in each
			Add to the file complexity the number of methods, number of lines
			drill down to a single method
				provide a line-by-line complexity meter?
					Is this realistic or possible?
					How will this be possible?
					Complexity will rise as the method moves through, even after decrementing code blocks - need a new algorithm for this
						Do a partial McCabe index - increase slightly after every if, never decreasing
							+ 1 point, etc just like normal
						nestation count
							"if if case loop if", nestation = 5
							decreases as code de-nests
							+5 with each nested level
								This multiplier may be tweaked depending on results
						Follow along
						1	begin function
						1	some code
						2	if
						7	 code	(2 for McCabe, 5 for nesting x 1)
						8	 loop	(3 for McCabe, 5 for nesting x 1)
						13	  code	(3 for McCabe, 10 for nesting x 2)
						8	 /loop	(out of loop, reduce nestation count, same as opening loop)
						8	 code	(no added complexity)
						9	 loop	(4 for McCabe, 5 for nesting x 1)
						14	  code	(4 for McCabe, 10 for nesting x 2)
						9	 /loop	(out of loop, reduce nestation count, same as opening loop)
						9	code	(no added complexity)
						4	/if		(out of overall if, reduce nestaiton)
						4	code	(nothing added, probably a return statement in this case)
						4	end function

						Complexity additives - too many statements on one line
						Complexity subtractives - one statement broken across multiple lines
						Add to the complexity count the number of lines in a method or file
							may need to adjust other counts to balance
							Maybe +1 per each 100 lines



			the file may have no functions, like a plain .cfm file


	The entire file or entire function complexity count is a simple counter
		1 beginning complexity
		+1 for each if and else-if, but not for "else"
		+1 for each switch case
		+1 for each loop
		+1 for iif

		Multiple exit points:
			# of decision points - # of exit points + 2

--->
<cfcomponent output="false">

	<cffunction name="init" access="public" output="false" returntype="CFComplexityMeter">
		<cfset variables.lineByLineComplexityIncrement = 4 />
		<cfset variables.cachedFileName = "" />
		<cfset variables.cachedFileData = "" />
		<cfreturn this />
	</cffunction>


	<!--- FILE-RELATED COMPLEXITY HANDLERS --->
	<cffunction name="getFileBasicComplexityCount" access="public" output="false" returntype="numeric">
		<cfargument name="file" type="string" required="true" />
		<cfset var fileContents = getFileContents(arguments.file) />
		<cfreturn getBasicComplexityCount( trim(fileContents) ) />
	</cffunction>

	<cffunction name="getFileDetailedComplexity" access="public" output="false" returntype="Query">
		<cfargument name="file" type="string" required="true" />
		<cfset var fileContents = getFileContents(arguments.file) />
		<cfset fileContents = stripFunctions(fileContents) />
		<cfreturn getDetailedComplexity( trim(fileContents) ) />
	</cffunction>

	<cffunction name="getFileNumberOfLines" access="public" output="false" returntype="numeric">
		<cfargument name="file" type="string" required="true" />
		<cfreturn getNumberOfLines( getFileContents(arguments.file) ) />
	</cffunction>


	<!--- FUNCTION-RELATED COMPLEXITY HANDLERS --->
	<cffunction name="getFunctions" access="public" output="false" returntype="string" hint="Returns a string list of functions in a file">
		<cfargument name="file" type="string" required="true" />

		<cfscript>
			var fileContents = getFileContents(arguments.file);
			var functions = "";
			var findStart = 0;
			var found = 0;
			var functionName = "";

			var matchExpression = "(<cffunction[^>]*name\s*=\s*['""](\w+)['""]|\sfunction\s+(\w+)\s*\()";

			while (reFindNoCase(matchExpression, fileContents, findStart)) {
				found = reFindNoCase(matchExpression, fileContents, findStart, true);
				if (found.len[3]) {
					functionName = mid(fileContents, found.pos[3], found.len[3]);
				} else {
					functionName = mid(fileContents, found.pos[4], found.len[4]);
				}
				functions = listAppend(functions, functionName);
				findStart = found.pos[1] + found.len[1];
			}

			return functions;
		</cfscript>
	</cffunction>

	<cffunction name="extractFunction" access="public" output="false" returntype="string">
		<cfargument name="file" type="string" required="true" />
		<cfargument name="functionName" type="string" required="true" />

		<cfset var matchExpressionTags_AndLeading = ".*([\t ]+<c"&"ffunction[^>]*name\s*=\s*['""]#functionName#['""].*?</c"&"ffunction>).*" />
		<cfset var matchExpressionTags_NotLeading = ".*([\t ]*<c"&"ffunction[^>]*name\s*=\s*['""]#functionName#['""].*?</c"&"ffunction>).*" />
		<cfset var matchExpressionScript = ".*(function\s+#functionName#.*?)(\sfunction\s|</(cf)?script>).*" />
		<cfset var fileContents = getFileContents(arguments.file) />
		<cfset var functionContents = "" />


		<cfset var combinedRegex = "(#matchExpressionTags_AndLeading#|#matchExpressionTags_NotLeading#|#matchExpressionScript#)">

		<cfset functionContents = reReplaceNoCase(fileContents, combinedRegex, "\2\3\4") />

<!---
		<!--- try first with leading spaces --->
		<cfset functionContents = reReplaceNoCase(fileContents, matchExpressionTags_AndLeading, "\1") />

		<!--- try second with no leading spaces --->
		<cfif functionContents EQ fileContents>
			<cfset functionContents = reReplaceNoCase(fileContents, matchExpressionTags_NotLeading, "\1") />
		</cfif>

		<!--- try third in cfscript --->
		<cfif functionContents EQ fileContents>
			<!--- Must be in CFScript! OH NO! --->
			<cfset functionContents = reReplaceNoCase(fileContents, matchExpressionScript, "\1") >
			<!---<cfset functionContents = reReplaceNoCase(functionContents, "\s*(function|</c"&"fscript)$", "") >--->
		</cfif>
--->

<!---
		<cfdump var="#arguments#">
		<cfdump var="#functionContents#">
		<br />
		<cfabort>
 --->
		<cfset functionContents = unIndent(functionContents) />

		<cfreturn functionContents />
	</cffunction>


	<cffunction name="getFunctionBasicComplexityCount" access="public" output="false" returntype="numeric">
		<cfargument name="file" type="string" required="true" />
		<cfargument name="functionName" type="string" required="true" />
		<cfreturn getBasicComplexityCount( extractFunction(arguments.file, arguments.functionName) ) />
	</cffunction>

 	<cffunction name="getFunctionDetailedComplexity" access="public" output="false" returntype="query">
		<cfargument name="file" type="string" required="true" />
		<cfargument name="functionName" type="string" required="true" />
		<cfreturn getDetailedComplexity( extractFunction(arguments.file, arguments.functionName) ) />
	</cffunction>

	<cffunction name="getFunctionNumberOfLines" access="public" output="false" returntype="numeric">
		<cfargument name="file" type="string" required="true" />
		<cfargument name="functionName" type="string" required="true" />
		<cfreturn getNumberOfLines( extractFunction(arguments.file, arguments.functionName) ) />
	</cffunction>


	<!---
		COMPLEXITY IMPLEMENTATION METHODS
	--->
	<cffunction name="getBasicComplexityCount" access="private" output="false" returntype="numeric" hint="Counts code complexity of a string">
		<cfargument name="content" type="string" required="true" />
		<cfscript>
			var linesOfCode = arguments.content.split("[\r\n]+");
			var complexity = 1;

			// every 100 lines of code add 1 to the content's complexity
			complexity = complexity + int(arrayLen(linesOfCode) / 100);

			// complexity count for cf tags
			complexity = complexity + arrayLen( arguments.content.split("(<cfif\s|<cfelseif\s|<cfcase\s|<cfloop\s|<cfoutput\s*query|iif\s*\()") ) -1;

			// complexity count for cfscript or javascript
			complexity = complexity + arrayLen( arguments.content.split("(\s(if|for|while|do|foreach)\s*\(|\scase\s+[\w""\s]+:)") ) -1;
		</cfscript>

		<cfreturn complexity />
	</cffunction>

	<cffunction name="getDetailedComplexity" access="private" output="false" returntype="query" hint="Counts code complexity of a string">
		<cfargument name="content" type="string" required="true" />
		<cfscript>

			var q = queryNew("line,code,complexity","integer,varchar,integer");
			var lines = arguments.content.split("[\r\n]+");
			var McCabeComplexity = 1;
			var lineByLineComplexity = 0;
			//var thisLineComplexityChange = 0;
			var thisLineComplexityAdd = 0;
			var thisLineComplexitySubtract = 0;

			var i = "";
			var line = "";

			for(i=1; i lte arrayLen(lines); i=i+1) {

				line = lines[i];

				// SCORE INCREMENTERS
				McCabeComplexity = McCabeComplexity + countRegexOccurrences(line, "(<cfif\s|<cfelseif\s|<cfcase\s|<cfloop\s|<cfoutput\s*query|iif\s*\()");
				McCabeComplexity = McCabeComplexity + countRegexOccurrences(line, "(\b(if|for|while|do|foreach)\s*\(|\scase\s+[\w""\s]+:)");

				thisLineComplexityAdd = countRegexOccurrences(line, "(<cfif\s|<cfelseif\s|<cfcase\s|<cfloop\s|<cfoutput\s*query|\biif\s*\()") * variables.lineByLineComplexityIncrement;
				// TODO: account for script {braces} as well as non-braced if(?)do;else do;
				// The current implimentation just counts any opening and closing braces. That's Cheating (and gives inaccurate readings).
				//thisLineComplexityAdd = thisLineComplexityAdd + (arrayLen( line.split("(\b(if|for|while|do|foreach)\s*\(|\scase\s+[\w""\s]+:)") ) - 1) * variables.lineByLineComplexityIncrement;
				thisLineComplexityAdd = thisLineComplexityAdd + (countRegexOccurrences(line,"\{") * variables.lineByLineComplexityIncrement);


				lineByLineComplexity = lineByLineComplexity + thisLineComplexityAdd;



				queryAddRow(q);
				querySetCell(q,"line",i);
				querySetCell(q,"code",lines[i]);
				querySetCell(q,"complexity", McCabeComplexity + lineByLineComplexity);



				// SCORE DECRMENTERS
				// Assume iif closes itself on the same line it opens
				thisLineComplexitySubtract = (arrayLen( line.split("(</cfif|</cfcase|</cfloop|iif\s*\()") ) - 1) * variables.lineByLineComplexityIncrement;
//				thisLineComplexitySubtract = thisLineComplexitySubtract + (arrayLen( line.split("(\b(if|for|while|do|foreach)\s*\(|\scase\s+[\w""\s]+:)") ) - 1) * variables.lineByLineComplexityIncrement;
				thisLineComplexitySubtract = thisLineComplexitySubtract + (countRegexOccurrences(line,"\}") * variables.lineByLineComplexityIncrement);
				lineByLineComplexity = lineByLineComplexity - thisLineComplexitySubtract;
			}

		</cfscript>

		<cfreturn q />
	</cffunction>

	<cffunction name="getNumberOfLines" access="public" output="false" returntype="numeric">
		<cfargument name="content" type="string" required="true" />
		<cfreturn arrayLen( arguments.content.split("(\r\n|\r|\n)") ) />
	</cffunction>



	<!---
	UTILITY METHODS
	--->
	<cfscript>
		/**
		 * Un-indents strings but preserves formatting
		 *
		 * @param str 	 String to be modified (Required)
		 * @return returns a string
		 * @author Nathan Strutz (strutz@gmail.com)
		 * @version 0, March 7, 2009
		 */
		function unIndent(str) {
			var lines = str.split("\n");
			var i = 0;
			var minSpaceDist = 9999;
			var newStr = "";

			for(i=1; i lte arrayLen(lines); i=i+1) {
				if (len(trim(lines[i]))) {
					minSpaceDist = max( min(minSpaceDist, reFind("[\S]",lines[i])-1), 0);
				}
			}

			for(i=1; i lte arrayLen(lines); i=i+1) {
				if (len(lines[i])) {
					newStr = newStr & removeChars(lines[i], 1, minSpaceDist);
				}
				newStr = newStr & chr(10);
			}
			return newStr;
		}

		function countRegexOccurrences(str,regex) {
			var pattern = createObject("java","java.util.regex.Pattern").compile(regex);
			var matcher = pattern.matcher(str);
			var matches = 0;
			while (matcher.find()) {
				matches = matches + 1;
			}
			return matches;
		}

		function stripFunctions(str) {
			// This totally inaccurately strips functions from files and leaves just the app
			// TODO: make stripFunctions strip scripted functions as well
			var matchExpression = "(<c"&"ffunction[^>]*name\s*=\s*['""](\w+)['""].*?</c"&"ffunction>)";
			return reReplace(str,matchExpression," FUNCTION REMOVED - \2 ","ALL");
		}
	</cfscript>

	<cffunction name="getFileContents" access="private" output="false" returntype="string" hint="Utility method to read a file, or if the contents of a file was passed, just return the contents.">
		<cfargument name="filePathOrContents" type="string" required="true" />
		<cfset var fileContents = "" />

		<cfif fileExists(arguments.filePathOrContents)>

			<!--- Easy, 1 file cache just for the last file opened --->
			<cfif variables.cachedFileName NEQ arguments.filePathOrContents>
				<cfset variables.cachedFileName = arguments.filePathOrContents />
				<cffile action="read" file="#arguments.filePathOrContents#" variable="variables.cachedFileData" />
			</cfif>

			<cfset fileContents = variables.cachedFileData>
		<cfelse>
			<cfset fileContents = arguments.filePathOrContents />
		</cfif>

		<cfreturn fileContents />
	</cffunction>

	<cffunction name="trace"><cfargument name="text"><cftrace text="#arguments.text#" /></cffunction>



<cffunction name="abort" output="false" returnType="void">
	<cfargument name="showError" type="string" required="false">
	<cfif isDefined("showError") and len(showError)>
		<cfthrow message="#showError#">
	</cfif>
	<cfabort>
</cffunction><cffunction name="dump" returnType="string">
	<cfargument name="var" type="any" required="true">
	<cfargument name="expand" type="boolean" required="false" default="true">
	<cfargument name="label" type="string" required="false" default="">
	<cfargument name="top" type="numeric" required="false">

	<!--- var --->
    <cfset var type = "">
    <cfset var tempArray = arrayNew(1)>
    <cfset var temp_x = 1>
    <cfset var tempStruct = structNew()>
	<cfset var orderedKeys = "">
	<cfset var tempQuery = queryNew("")>
	<cfset var col = "">

	<!--- do filtering if top ---->
	<cfif isDefined("top")>

		<cfif isArray(var)>
			<cfset type = "array">
		</cfif>
		<cfif isStruct(var)>
			<cfset type="struct">
		</cfif>
		<cfif isQuery(var)>
			<cfset type="query">
		</cfif>

		<cfswitch expression="#type#">

			<cfcase value="array">
				<cfif arrayLen(var) gt top>
					<cfloop index="temp_x" from=1 to="#Min(arrayLen(var),top)#">
						<cfset tempArray[temp_x] = var[temp_x]>
					</cfloop>
					<cfset var = tempArray>
				</cfif>
			</cfcase>

			<cfcase value="struct">
				<cfif listLen(structKeyList(var)) gt top>
					<cfset orderedKeys = listSort(structKeyList(var),"text")>
					<cfloop index="temp_x" from=1 to="#Min(listLen(orderedKeys),top)#">
						<cfset tempStruct[listGetAt(orderedKeys,temp_x)] = var[listGetAt(orderedKeys,temp_x)]>
					</cfloop>
					<cfset var = tempStruct>
				</cfif>
			</cfcase>

			<cfcase value="query">
				<cfif var.recordCount gt top>
					<cfset tempQuery = queryNew(var.columnList)>
					<cfloop index="temp_x" from=1 to="#min(var.recordCount,top)#">
						<cfset queryAddRow(tempQuery)>
						<cfloop index="col" list="#var.columnList#">
							<cfset querySetCell(tempQuery,col,var[col][temp_x])>
						</cfloop>
					</cfloop>
					<cfset var = tempQuery>
				</cfif>
			</cfcase>

		</cfswitch>

	</cfif>

	<cfdump var="#var#" expand="#expand#" label="#label#">
</cffunction>


</cfcomponent>