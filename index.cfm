<cf_layout>

<form method="get" action="directory.cfm">
	<cfoutput>
	Enter a directory or file path<br/>
	<input name="directory" value="#expandPath('/')#" size="60" />
	<br/>
	<input type="submit" value="Check Complexity" />
	</cfoutput>
</form>

</cf_layout>