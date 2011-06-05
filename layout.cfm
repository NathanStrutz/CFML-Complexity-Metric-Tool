<cfif thistag.executionMode IS "start">

	<cfparam name="attributes.title" default="CFML Complexity Metric Tool" />
	<cfparam name="attributes.directory" default="" />
	<cfparam name="attributes.file" default="" />
	<cfparam name="attributes.function" default="" />

<cfcontent reset="true" /><!doctype html>

<html lang="en">
<head>
	<link rel="stylesheet/less" type="text/css" href="complexity.less">
	<script src="less-1.1.3.min.js" type="text/javascript"></script>
	<title><cfoutput>#attributes.title#</cfoutput></title>
	<script type="text/javascript" src="jquery-1.6.1.min.js"></script>
	<script type="text/javascript" src="jquery.colorfade.js"></script>
	<meta charset="utf-8" />
</head>
<body>

<header>
	<h1>CFML Complexity <span class="highlight">Metric Tool</span></h1>
	<h4>You got problems!</h4>
</header>


<nav>
	<a href="index.cfm">Start</a>

	<cfoutput>
	<cfif len(attributes.function)>
		<a href="directory.cfm?directory=#attributes.directory#">Files</a>
		<a href="file.cfm?directory=#attributes.directory#&file=#attributes.file#">#getFileFromPath(attributes.file)#</a>
		<span>#attributes.function#</span>
	<cfelseif len(attributes.file)>
		<a href="directory.cfm?directory=#attributes.directory#">Files</a>
		<span>#getFileFromPath(attributes.file)#</span>
	<cfelseif len(attributes.directory)>
		<span>Files</span>
	</cfif>
	</cfoutput>

</nav>


<section>
<cfelseif thistag.executionMode EQ "end">
</section>



<cfif isDebugMode()>
	<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
</cfif>

</body>
</html></cfif>