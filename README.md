# liferay-shindig-portlets
Liferay Shindig Portlets using REST calls to an external Shindig server.

Requires the Shindig server's secret token.

Icons not included.

Portlets included:
* ActivityStream
* Friends
* Profile (current user or user in page parameter; with editing support)
* Shortest path (logged in user to user in page parameter)
* Friend suggestions
* User directory

Installation:

1. (optional )Import into Liferay 7 IDE
2. Build using Maven with package goal
3. Put generated war in Liferay's "deploy" folder
4. Restart Liferay (optional)

Configuration file: /src/main/resources/portlet.properties

