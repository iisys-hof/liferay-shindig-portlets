# liferay-shindig-portlets
Liferay Shindig Portlets using REST calls to an external Shindig server.

Requires the Shindig server's secret token.

Portlets included:
* ActivityStream
* Friends
* Profile (current user or user in page parameter; with editing support)
* Shortest path (logged in user to user in page parameter)
* Friend suggestions
* User directory

Installation:

1. Project has to be placed in a folder called "ShindigPortlet-portlet" in the "portlets" folder of a Liferay SDK.
2. Import in Liferay IDE using "Liferay project from existing source"
3. Right click on project and execute Liferay - SDK - war
4. Put generated war in Liferay's "deploy" folder
5. Restart Liferay (optional)

Configuration file: /docroot/WEB-INF/src/portlet.properties