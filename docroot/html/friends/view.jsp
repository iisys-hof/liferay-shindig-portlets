<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet" %>
<%@ page import="javax.portlet.PortletPreferences" %>
<%@ taglib uri="http://liferay.com/tld/ui" prefix="liferay-ui"%>
<%@ taglib uri="http://liferay.com/tld/theme" prefix="liferay-theme"%>

<portlet:defineObjects />
<liferay-theme:defineObjects />

<%@ page import="java.util.Map,java.util.HashMap,com.liferay.util.portlet.PortletProps,org.apache.shindig.common.crypto.BasicBlobCrypter,org.apache.shindig.auth.BasicSecurityToken,java.io.File,com.liferay.portal.util.PortalUtil" %>

<%
PortletPreferences prefs = renderRequest.getPreferences();
String userName = user.getScreenName();

//see AbstractSecurityToken for keys
Map<String, String> token = new HashMap<String, String>();
//application
token.put("i", "shindig-friends-portlet");

//viewer
token.put("v", userName);

String shindigToken = "default:" + new BasicBlobCrypter(new File(PortletProps.get("token_secret")))
		.wrap(token);

HttpServletRequest httpRequest = PortalUtil.getOriginalServletRequest(
	PortalUtil.getHttpServletRequest(renderRequest)); 
String userParam = httpRequest.getParameter("userId");
%>

<style type="text/css">
  #<portlet:namespace/>body {
    height: auto;
    width: 100%;
    overflow: auto;
  }
  #<portlet:namespace/>friendsDiv {
    position: relative;
    top: 0px;
    bottom: 2em;
    left: 0px;
    width: 100%;
    overflow: auto;
    list-style: none;
    margin: 0 0 0 0;
  }
  #<portlet:namespace/>controls {
    text-align: center;
    position: relative;
    bottom: 0px;
    left: 0px;
    width: 100%;
    height: 2em;
    visibility: visible;
    overflow: hidden;
  }
  
  .<portlet:namespace/>friendEntry {
    padding: 0.5em 2em 0.5em 2em;
    float: left;
  }
  .<portlet:namespace/>compactHead {
    margin-top: 0;
    margin-bottom: 0.3em;
    clear: both;
  }
  .<portlet:namespace/>noneStyleList {
    list-style-type: none;
    padding-left: 1em;
  }
  .<portlet:namespace/>thumbnail {
  	height: 100px!important;
    float: left;
  }
  .<portlet:namespace/>picBlock {
  	display: inline-block;
  }
  .<portlet:namespace/>actions {
    list-style-type: none;
    padding-left: 1em!important;
    margin: 0 0 0 0!important;
    float: left;
  }
  
  <portlet:namespace/>a:link {
    color: #000000;
    text-decoration: none;
  }

  <portlet:namespace/>a:visited {
    color: #000000;
    text-decoration: none;
  }

  <portlet:namespace/>a:hover {
    color: #0000FF;
    text-decoration: none;
  }

  <portlet:namespace/>a:active {
    color: #0088ff;
    text-decoration: none;
  }
</style>


<div id="<portlet:namespace/>body"> </div>
<br>
<div id="<portlet:namespace/>successSpan" class="portlet-msg-success" style="display:none;"></div>
<div id="<portlet:namespace/>errorSpan" class="portlet-msg-error" style="display:none;"></div>


<script type="text/javascript">
  var <portlet:namespace/>SHINDIG_URL = '<%= PortletProps.get("shindig_url") %>';
  var <portlet:namespace/>PEOPLE_FRAG = "social/rest/people/";
  var <portlet:namespace/>USER_FRAG = "social/rest/user";

  var <portlet:namespace/>USER_ID = '<%= userName %>';
  var <portlet:namespace/>SHINDIG_TOKEN = '<%= shindigToken %>';
  
  //DEBUG
  var <portlet:namespace/>OWNER_ID = <portlet:namespace/>USER_ID;

  var <portlet:namespace/>SPLIT_THRESH = 500;
  
  var <portlet:namespace/>ADD_LABEL = '<liferay-ui:message key="friends-add" />';
  var <portlet:namespace/>DELETE_LABEL = '<liferay-ui:message key="friends-delete" />';
  var <portlet:namespace/>CONFIRM_LABEL = '<liferay-ui:message key="friends-confirm" />';
  var <portlet:namespace/>REJECT_LABEL = '<liferay-ui:message key="friends-reject" />';
  var <portlet:namespace/>SEND_LABEL = '<liferay-ui:message key="friends-send-message" />';
  
  var <portlet:namespace/>fWidth;
  
  var <portlet:namespace/>fRequests;
  var <portlet:namespace/>fFriends;
  var <portlet:namespace/>fOwnerControls;
  var <portlet:namespace/>fViewerFriends;
  
  var <portlet:namespace/>fImages;
  var <portlet:namespace/>fIndexCounter;
  
  var <portlet:namespace/>fFirst = 0;
  var <portlet:namespace/>fMax = 10;
  
  
  function <portlet:namespace/>sendRequest(method, url, callback, payload)
  {
	  var xhr = new XMLHttpRequest();
    
	  xhr.open(method, url, true);
      //xhr.responseType = 'json';
	  
	  xhr.onreadystatechange = function()
	  {
		  if(xhr.readyState == 4)
		  {
		      if(xhr.status == 200)
	    	  {
			      callback(JSON.parse(xhr.response));
	    	  }
		      else
		      {
			      console.log('Shindig Friends Portlet:\n'
					+ 'Error ' + xhr.status + ': ' + xhr.statusText);
		      }
		  }
	  }
	  
	  if(payload)
	  {
		  xhr.setRequestHeader('Content-Type', 'application/json');
		  xhr.send(JSON.stringify(payload));
	  }
	  else
	  {
		  xhr.send();
	  }
  }
  
  /*
  function <portlet:namespace/>sendRequest(method, url, callback, payload)
  {
	AUI().use('aui-io-request', function(A)
	{
	  if(payload)
	  {
		  A.io.request(url, {
			  dataType: 'json',
			  method : method,
			  headers: {
				  'Content-Type': 'application/json; charset=utf-8'
			  },
			  data : JSON.stringify(payload),
			  on: {
				success: function() {
				  callback(this.get('responseData'));
				},
				failure: function() {
				  alert(this.get('responseData').status);
				}
			  }
		  });
	  }
	  else
	  {
		  A.io.request(url, {
			  dataType: 'json',
			  method : method,
			  on: {
				success: function() {
				  callback(this.get('responseData'));
				},
				failure: function() {
				  alert(this.get('responseData').status);
				}
			  }
		  });
	  }
	});
  }
  */
  
  function <portlet:namespace/>more()
  {
    <portlet:namespace/>fFirst += <portlet:namespace/>fMax;
    <portlet:namespace/>getFriends(<portlet:namespace/>fRequests);
  }
  
  function <portlet:namespace/>back()
  {
    <portlet:namespace/>fFirst -= <portlet:namespace/>fMax;
    if(<portlet:namespace/>fFirst < 0)
    {
      <portlet:namespace/>fFirst = 0;
    }
    <portlet:namespace/>getFriends(<portlet:namespace/>fRequests);
  }
  
  function <portlet:namespace/>reset()
  {
    if(<portlet:namespace/>fFirst != 0)
    {
      <portlet:namespace/>fFirst = 0;
    }
    <portlet:namespace/>getFriends(<portlet:namespace/>fRequests);
  }
  
  function <portlet:namespace/>getOwner()
  {
    //var params = {"userId": "@owner", "fields":"id"};
    
    //osapi.people.get(params).execute(getRequests);
    
	//show friends of specified user if set
	var userParam = '<%= userParam %>';
    
    if(userParam == '' || userParam == 'null')
    {
    	var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>PEOPLE_FRAG
	        + <portlet:namespace/>OWNER_ID + '?fields=id';

	    if(<portlet:namespace/>SHINDIG_TOKEN != null)
	    {
	      url += '&st=' + <portlet:namespace/>SHINDIG_TOKEN;
	    }

        <portlet:namespace/>sendRequest('GET', url, <portlet:namespace/>getRequests);
    }
    else
    {
    	var data = new Object();

    	data.entry = new Object();
    	data.entry.isViewer = false;
    	data.entry.id = userParam;

    	<portlet:namespace/>getRequests(data);
    }
  }

  function <portlet:namespace/>getRequests(data)
  {
	if (data)
    {
      if(data.entry.isViewer
        || data.entry.id == <portlet:namespace/>USER_ID)
      {
        //get requests for owner
        <portlet:namespace/>fOwnerControls = true;
        
        //var params = {"userId": "@owner", "groupId": "@friendrequests",
        //  "fields": "id,name,thumbnailUrl", "sortBy": "name",
        //  "sortOrder": "ascending", "startIndex": <portlet:namespace/>fFirst, "count": <portlet:namespace/>fMax};
        
        //osapi.people.get(params).execute(getFriends);
        
        var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>PEOPLE_FRAG
          + <portlet:namespace/>USER_ID + '/@friendrequests?fields=id,name,thumbnailUrl';
        url += '&sortBy=name&sortOrder=ascending';
        url += '&startIndex=' + <portlet:namespace/>fFirst;
        url += '&count=' + <portlet:namespace/>fMax;
        
        if(<portlet:namespace/>SHINDIG_TOKEN != null)
        {
      	  url += '&st=' + <portlet:namespace/>SHINDIG_TOKEN;
        }
        
        <portlet:namespace/>sendRequest('GET', url, <portlet:namespace/>getFriends);
      }
      else
      {
        //don't display requests
        <portlet:namespace/>fOwnerControls = false;
        
        var requests = new Object();
        requests.list = new Array();
        requests.totalResults = 0;
        <portlet:namespace/>getFriends(requests);
      }
    }
    else
    {
      //alert('Shindig Friends Portlet: no data received');

	  document.getElementById('<portlet:namespace/>errorSpan').innerHTML = 'no data received';
	  document.getElementById('<portlet:namespace/>errorSpan').style.display = 'flex';
    }
  }

  function <portlet:namespace/>getFriends(requests)
  {    
	//show friends of specified user if set
	var userParam = '<%= userParam %>';
		
	var userId = <portlet:namespace/>OWNER_ID;
	if(userParam != '' && userParam != 'null')
	{
		userId = userParam;
	}

    if(requests)
    {
      <portlet:namespace/>fRequests = requests;
      
      //var params = {"userId": "@owner", "groupId": "@friends", "fields":
      //  "id,name,thumbnailUrl", "sortBy": "name", "sortOrder": "ascending",
      //  "startIndex": <portlet:namespace/>fFirst, "count": <portlet:namespace/>fMax};
      
      var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>PEOPLE_FRAG
      	+ userId + '/@friends?fields=id,name,thumbnailUrl';
      url += '&sortBy=name&sortOrder=ascending';
      url += '&startIndex=' + <portlet:namespace/>fFirst;
      url += '&count=' + <portlet:namespace/>fMax;
      
      if(<portlet:namespace/>SHINDIG_TOKEN != null)
      {
    	  url += '&st=' + <portlet:namespace/>SHINDIG_TOKEN;
      }
    
      if(<portlet:namespace/>fOwnerControls)
      {
          //directly display friends
          //osapi.people.get(params).execute(callback);
        
    	  <portlet:namespace/>sendRequest('GET', url, <portlet:namespace/>callback);
      }
      else
      {
        //get viewer's friends first
        //osapi.people.get(params).execute(getViewerFriends);
        
    	<portlet:namespace/>sendRequest('GET', url, <portlet:namespace/>getViewerFriends);
      }
    }
    else
    {
      //alert('Shindig Friends Portlet: no data received');

	  document.getElementById('<portlet:namespace/>errorSpan').innerHTML = 'no data received';
	  document.getElementById('<portlet:namespace/>errorSpan').style.display = 'flex';
    }
  }
  
  function <portlet:namespace/>getViewerFriends(friends)
  {
    if(friends)
    {
      <portlet:namespace/>fFriends = friends;
      
      //if there are no friends to check for, go directly to next method
      if((friends.list && friends.list.length == 0)
        || (!friends.list && !friends.entry))
      {
    	  var viewerFriends = new Object();
    	  viewerFriends.list = new Array();
    	  <portlet:namespace/>viewerRelay(viewerFriends);
    	  return;
      }
      
      //fake list for only one result
      if(!friends.list)
      {
        friends.list = new Array();
        friends.list.push(friends.entry);
        
        //add fake entry to trigger filtering
        var extra = new Object();
        extra.id = <portlet:namespace/>USER_ID;
        friends.list.push(extra);
      }
      
      //determine who among these people the viewer is already friends with
      //var idSet = new Array();
      
      //friends.list.forEach(function(entry)
      //{
      //  idSet.push(entry.id);
      //});
    
      //var params = {"userId": idSet, "groupId": "@self", "fields":
      //  "id", "sortBy": "id", "sortOrder": "descending", "count": <portlet:namespace/>fMax,
      //  "filterBy" : "isFriendsWith", "filterValue": "@me"};
        
      //osapi.people.get(params).execute(viewerRelay);
      
      var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>PEOPLE_FRAG;
      
      //add owner's friends' IDs
      var count = 0;
      friends.list.forEach(function(entry)
      {
    	if(count > 0)
    	{
    		url += ',';
    	}
    	
    	url += entry.id;
    	
    	++count;
      });
      
      url += '?fields=id&sortBy=id&sortOrder=descending';
      url += '&count=' + <portlet:namespace/>fMax;
      url += '&filterBy=isFriendsWith';
      url += '&filterValue=' + <portlet:namespace/>USER_ID;
      
      if(<portlet:namespace/>SHINDIG_TOKEN != null)
      {
    	  url += '&st=' + <portlet:namespace/>SHINDIG_TOKEN;
      }
      
      <portlet:namespace/>sendRequest('GET', url, <portlet:namespace/>viewerRelay);
    }
    else
    {
      //alert('Shindig Friends Portlet: no data received');

	  document.getElementById('<portlet:namespace/>errorSpan').innerHTML = 'no data received';
	  document.getElementById('<portlet:namespace/>errorSpan').style.display = 'flex';
    }
  }
  
  function <portlet:namespace/>viewerRelay(viewerFriends)
  {
    if(viewerFriends)
    {
      //fake list for only one friend
      if(!viewerFriends.list)
      {
        viewerFriends.list = new Array();
        viewerFriends.list.push(viewerFriends.entry);
      }
      
      <portlet:namespace/>fViewerFriends = new Array();
      viewerFriends.list.forEach(function(entry)
      {
        <portlet:namespace/>fViewerFriends[entry.id] = true;
      });
      
      <portlet:namespace/>callback(<portlet:namespace/>fFriends);
    }
    else
    {
      //alert('Shindig Friends Portlet: no data received');

	  document.getElementById('<portlet:namespace/>errorSpan').innerHTML = 'no data received';
	  document.getElementById('<portlet:namespace/>errorSpan').style.display = 'flex';
    }
  }

  function <portlet:namespace/>callback(friends)
  {
    var requests = <portlet:namespace/>fRequests;
  
    if (friends)
    {
      //fake list for only one friend result
      if(!friends.list)
      {
        friends.list = new Array();
        friends.list.push(friends.entry);
      }
      //fake list for only one request result
      if(!requests.list)
      {
        requests.list = new Array();
        requests.list.push(requests);
      }
      
      //clear old images
      <portlet:namespace/>fImages = new Array();
      <portlet:namespace/>fIndexCounter = 0;
      
      //generate HTML
      var html = '<ul id="<portlet:namespace/>friendsDiv">';
      
      var total = friends.list.length + requests.list.length;
      
      var index = 0;
      var requestHead = false;
      	
      //friends
      while(index < friends.list.length)
      {
        html += '<li class="<portlet:namespace/>friendEntry">'
         + <portlet:namespace/>extendedEntry(friends.list[index], false) + '</li>';
        ++index;
      }
      
      //requests
      while(index < total)
      {
      	if(!requestHead)
      	{
      	  	html += '<h2 class="<portlet:namespace/>compactHead">'
      	  	  + '<liferay-ui:message key="friends-unconfirmed" />' + '</h2>';
        	requestHead = true;
        }
      	
        var realIndex = index - friends.list.length;
        html += '<li class="<portlet:namespace/>friendEntry">'
        	+ <portlet:namespace/>extendedEntry(requests.list[realIndex], true) + '</li>';
        ++index;
      }
      html += '</ul>';
      
      //<portlet:namespace/>controls
      html += '</div><div id="<portlet:namespace/>controls">';
        
      if(<portlet:namespace/>fFirst > 0)
      {
        html += '<input type="button" value="' + '<liferay-ui:message key="friends-back" />'
          + '" onclick="<portlet:namespace/>back()"/>';
      }
      
      html += ' ' + (<portlet:namespace/>fFirst + 1) + ' ' + '<liferay-ui:message key="friends-to" />'
      	+ ' ' + (<portlet:namespace/>fFirst + <portlet:namespace/>fMax) + ' '
        + '<liferay-ui:message key="friends-of" />' + ' ' + friends.totalResults + ' ';
        
      if(friends.totalResults > <portlet:namespace/>fFirst + <portlet:namespace/>fMax)
      {
        html += '<input type="button" value="' + '<liferay-ui:message key="friends-more" />'
          + '" onclick="<portlet:namespace/>more()"/>';
      }
      html += '</div>';
      
      document.getElementById('<portlet:namespace/>body').innerHTML = html;
    }
    else
    {
      //alert('Shindig Friends Portlet: no data received');

	  document.getElementById('<portlet:namespace/>errorSpan').innerHTML = 'no data received';
	  document.getElementById('<portlet:namespace/>errorSpan').style.display = 'flex';
    }
  }
  
  function <portlet:namespace/>actions(entry, request)
  {
	html = '<ul class="<portlet:namespace/>actions">';
      
	if(<portlet:namespace/>fOwnerControls)
	{
	  var deleteLabel = <portlet:namespace/>DELETE_LABEL;
	  var deleteIcon = 'link-break-icon.png';
	  if(request)
	  {
	  	deleteLabel = <portlet:namespace/>REJECT_LABEL;
	  	deleteIcon = 'stop.png';
	  }
	
	  html += '<li><img width="32" src="<%=request.getContextPath()%>/images/' + deleteIcon + '"'
	    + ' alt="' + deleteLabel + '" onclick="<portlet:namespace/>removeFriend(\''
	    + entry.id + '\', ' + request + ')" style="vertical-align: middle; cursor: pointer;" '
	    + 'title="' + deleteLabel + '" /></li>';
	    
	  if(request)
	  {
	  	html += '<li><img width="32" src="<%=request.getContextPath()%>/images/user_male_add.png"'
	      + ' alt="' + <portlet:namespace/>CONFIRM_LABEL + '" onclick="<portlet:namespace/>confirmFriend(\''
	      + entry.id + '\', true)" style="vertical-align: middle; cursor: pointer;" '
	      + 'title="' + <portlet:namespace/>CONFIRM_LABEL + '" /></li>';
	  }
	}
	else if(!<portlet:namespace/>fViewerFriends[entry.id])
	{
	  html += '<li><img width="32" src="<%=request.getContextPath()%>/images/user_male_add.png"'
	    + ' alt="' + <portlet:namespace/>ADD_LABEL + '" onclick="<portlet:namespace/>confirmFriend(\''
	    + entry.id + '\', ' + request + ')" style="vertical-align: middle; cursor: pointer;" '
	    + 'title="' + <portlet:namespace/>ADD_LABEL + '" /></li>';
	}
	
	if(entry.id != <portlet:namespace/>USER_ID)
	{
	  html += '<li><img width="32" src="<%=request.getContextPath()%>/images/send_email.png"'
	    + ' alt="' + <portlet:namespace/>SEND_LABEL + '" style="vertical-align: middle;" '
	    + 'title="' + <portlet:namespace/>SEND_LABEL + '" /></li>';
	}
	
	html += '</ul>';
	
	return html;
  }
  
  function <portlet:namespace/>simpleEntry(entry, request)
  {
  	html = '<a href="/web/guest/profile?userId=' + entry.id + '" target="_blank">'
  	  + entry.name.formatted + '</a>';
  	
    return html;
  }
  
  function <portlet:namespace/>extendedEntry(entry, request)
  {
  	var html = '<div class="<portlet:namespace/>picBlock">'
  	 + '<a href="/web/guest/profile?userId=' + entry.id + '" target="_blank">';
  	
  	//if(entry.thumbnailUrl)
  	//{
  	//  html += '<img class="<portlet:namespace/>thumbnail" src="' + entry.thumbnailUrl + '" '
  	//  	+ 'title="' + entry.name.formatted + '" />';
  	//}
  	
  	html += '<img class="<portlet:namespace/>thumbnail" '
  	  + 'id="<portlet:namespace/>thumbnailImg' + <portlet:namespace/>fIndexCounter + '" '
  	  + 'src="<%=request.getContextPath()%>/images/profile_picture_placeholder.png" '
  	  + 'title="' + entry.name.formatted + '" />';

  	if(entry.thumbnailUrl)
  	{
  	  //start loading in background
      var preImg = new Image();
      preImg.src = entry.thumbnailUrl;
      
      //keep in memory
      <portlet:namespace/>fImages.push(preImg);
      
      //hidden image that will trigger swapping once loaded
      html += '<img src="' + entry.thumbnailUrl
      + '" onload="<portlet:namespace/>thumbLoaded(\'<portlet:namespace/>thumbnailImg'
      + <portlet:namespace/>fIndexCounter + '\',' + '\'' + entry.thumbnailUrl + '\')" '
      + ' style="display: none;" />';
  	}
  	  
  	<portlet:namespace/>fIndexCounter++;
  	
  	html += '</a>';
  	
  	html += <portlet:namespace/>actions(entry, request);
  	
  	html += '</div><br/>';
  	
  	return html + <portlet:namespace/>simpleEntry(entry, request);
  }
  
  function <portlet:namespace/>thumbLoaded(elementId, url)
  {
	  var image = document.getElementById(elementId);
	  image.src = url;
  }
  
  function <portlet:namespace/>confirmFriend(id, request)
  {
    var person = {"id": id};
  	
    var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>PEOPLE_FRAG
    	+ <portlet:namespace/>USER_ID + '/@friends';
    
    if(<portlet:namespace/>SHINDIG_TOKEN != null)
    {
  	  url += '?st=' + <portlet:namespace/>SHINDIG_TOKEN;
    }
    
    if(request)
    {
        <portlet:namespace/>sendRequest('POST', url,
        	<portlet:namespace/>confirmationSent, person);
    }
    else
    {
        <portlet:namespace/>sendRequest('POST', url,
        	<portlet:namespace/>requestSent, person);
    }
  }
  
  function <portlet:namespace/>removeFriend(id, request)
  {
	var message = '';  
	
	if(request)
    {
		message = '<liferay-ui:message key="friends-confirm-reject" />';
    }
	else
	{
		message = '<liferay-ui:message key="friends-confirm-delete" />';
	}
	
	if(!confirm(message))
	{
		return;
	}
	
    var person = {"id": id};
    
    var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>PEOPLE_FRAG
    	+ <portlet:namespace/>USER_ID + '/@friends';
    
    if(<portlet:namespace/>SHINDIG_TOKEN != null)
    {
  	  url += '?st=' + <portlet:namespace/>SHINDIG_TOKEN;
    }
    
    if(request)
    {
        <portlet:namespace/>sendRequest('DELETE', url,
        	<portlet:namespace/>rejected, person);
    }
    else
    {
        <portlet:namespace/>sendRequest('DELETE', url,
        	<portlet:namespace/>deleted, person);
    }
  }
  
  function <portlet:namespace/>requestSent(data)
  {
    if(data)
    {
	  //alert('<liferay-ui:message key="friends-request-sent" />');

	  document.getElementById('<portlet:namespace/>successSpan').innerHTML = '<liferay-ui:message key="friends-request-sent" />';
	  document.getElementById('<portlet:namespace/>successSpan').style.display = 'flex';
	  
      <portlet:namespace/>getOwner();
    }
    else
    {
      //alert('Shindig Friends Portlet: no data received');
      
	  document.getElementById('<portlet:namespace/>errorSpan').innerHTML = 'no data received';
	  document.getElementById('<portlet:namespace/>errorSpan').style.display = 'flex';
    }
  }
  
  function <portlet:namespace/>confirmationSent(data)
  {
    if(data)
    {
	  //alert('<liferay-ui:message key="friends-confirmation-sent" />');

	  document.getElementById('<portlet:namespace/>successSpan').innerHTML = '<liferay-ui:message key="friends-confirmation-sent" />';
	  document.getElementById('<portlet:namespace/>successSpan').style.display = 'flex';
	  
      <portlet:namespace/>getOwner();
    }
    else
    {
      //alert('Shindig Friends Portlet: no data received');
      
	  document.getElementById('<portlet:namespace/>errorSpan').innerHTML = 'no data received';
	  document.getElementById('<portlet:namespace/>errorSpan').style.display = 'flex';
    }
  }
  
  function <portlet:namespace/>deleted(data)
  {
    if(data)
    {
	  //alert('<liferay-ui:message key="friends-deleted" />');

	  document.getElementById('<portlet:namespace/>successSpan').innerHTML = '<liferay-ui:message key="friends-deleted" />';
	  document.getElementById('<portlet:namespace/>successSpan').style.display = 'flex';
	  
      <portlet:namespace/>getOwner();
    }
    else
    {
      //alert('Shindig Friends Portlet: no data received');
      
	  document.getElementById('<portlet:namespace/>errorSpan').innerHTML = 'no data received';
	  document.getElementById('<portlet:namespace/>errorSpan').style.display = 'flex';
    }
  }
  
  function <portlet:namespace/>rejected(data)
  {
    if(data)
    {
	  //alert('<liferay-ui:message key="friends-rejected" />');

	  document.getElementById('<portlet:namespace/>successSpan').innerHTML = '<liferay-ui:message key="friends-rejected" />';
	  document.getElementById('<portlet:namespace/>successSpan').style.display = 'flex';
	  
      <portlet:namespace/>getOwner();
    }
    else
    {
      //alert('Shindig Friends Portlet: no data received');
      
	  document.getElementById('<portlet:namespace/>errorSpan').innerHTML = 'no data received';
	  document.getElementById('<portlet:namespace/>errorSpan').style.display = 'flex';
    }
  }
  
  <portlet:namespace/>getOwner();
</script>