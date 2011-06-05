<cfcomponent>

	<cfscript>

		this.name = "complexitymeter";

		function onApplicationStart() {
			application.complexity = createObject("component","CFComplexityAppDriver").init();
		}

		function onRequestStart() {
			if (structKeyExists(url, "init")) {
				onApplicationStart();
			}
		}

	</cfscript>

</cfcomponent>
