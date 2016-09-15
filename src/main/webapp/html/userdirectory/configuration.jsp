<%@include file="/html/init.jsp" %>

<liferay-portlet:actionURL portletConfiguration="true" var="configurationURL" />

<%@ page import="de.hofuniversity.iisys.liferay.portlet.userdirectory.*" %>

<%@ taglib uri="http://liferay.com/tld/aui" prefix="aui" %>

<%
UserDirectoryPortletInstanceConfiguration portletInstanceConfiguration = 
	portletDisplay.getPortletInstanceConfiguration(UserDirectoryPortletInstanceConfiguration.class);

//boolean showSearch_cfg = GetterUtil.getBoolean(portletPreferences.getValue("showSearch", StringPool.TRUE));
//boolean wikiLinkDetection_cfg = GetterUtil.getBoolean(portletPreferences.getValue("wikiLinkDetection", StringPool.FALSE));

boolean showSearch_cfg = portletInstanceConfiguration.showSearch(true);
boolean wikiLinkDetection_cfg = portletInstanceConfiguration.wikiLinkDetection(false);
%>

<aui:form action="<%= configurationURL %>" method="post" name="fm">
    <aui:input name="<%= Constants.CMD %>" type="hidden" value="<%= Constants.UPDATE %>" />

    <aui:input name="preferences--showSearch--" type="checkbox" value="<%= showSearch_cfg %>" />
    <aui:input name="preferences--wikiLinkDetection--" type="checkbox" value="<%= wikiLinkDetection_cfg %>" />

    <aui:button-row>
       <aui:button type="submit" />
    </aui:button-row>
</aui:form>