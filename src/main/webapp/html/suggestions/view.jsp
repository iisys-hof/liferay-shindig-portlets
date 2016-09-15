<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet" %>
<%@ page import="javax.portlet.PortletPreferences" %>
<%@ taglib uri="http://liferay.com/tld/ui" prefix="liferay-ui"%>
<%@ taglib uri="http://liferay.com/tld/theme" prefix="liferay-theme"%>

<portlet:defineObjects />
<liferay-theme:defineObjects />

<%@ page import="java.util.Map,java.util.HashMap,com.liferay.util.portlet.PortletProps,org.apache.shindig.common.crypto.BasicBlobCrypter,org.apache.shindig.auth.BasicSecurityToken,java.io.File,com.liferay.portal.kernel.util.PortalUtil" %>

<%
PortletPreferences prefs = renderRequest.getPreferences();
String userName = user.getScreenName();

//see AbstractSecurityToken for keys
Map<String, String> token = new HashMap<String, String>();
//application
token.put("i", "shindig-suggestions-portlet");

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
	var <portlet:namespace/>USER_FRAG = "social/rest/user/";
	  
	var <portlet:namespace/>ADD_LABEL = '<liferay-ui:message key="suggestions-add" />';
	var <portlet:namespace/>SEND_LABEL = '<liferay-ui:message key="suggestions-send-message" />';
	
	var <portlet:namespace/>USER_ID = '<%= userName %>';
	var <portlet:namespace/>SHINDIG_TOKEN = '<%= shindigToken %>';
	
	//DEBUG
	var <portlet:namespace/>OWNER_ID = <portlet:namespace/>USER_ID;
	
	var <portlet:namespace/>SPLIT_THRESH = 500;
	
	var <portlet:namespace/>fWidth;
	var <portlet:namespace/>fFriends;
	var <portlet:namespace/>fGroups;
	
	var <portlet:namespace/>fImages;
	var <portlet:namespace/>fIndexCounter;
	  
	var <portlet:namespace/>fFirst = 0;
	var <portlet:namespace/>fMax = 10;
	
	/*
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
		      		alert('Shindig Suggestions Portlet:\n'
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
	*/
	  
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
					  //alert(this.get('responseData').status);

					  document.getElementById('<portlet:namespace/>errorSpan').innerHTML = 'Error: ' + this.get('responseData').status;
					  document.getElementById('<portlet:namespace/>errorSpan').style.display = 'flex';
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
					  //alert(this.get('responseData').status);

					  document.getElementById('<portlet:namespace/>errorSpan').innerHTML = 'Error: ' + this.get('responseData').status;
					  document.getElementById('<portlet:namespace/>errorSpan').style.display = 'flex';
					}
				  }
			  });
		  }
		});
	  }
	  
	function <portlet:namespace/>more()
	{
	    <portlet:namespace/>fFirst += <portlet:namespace/>fMax;
	    <portlet:namespace/>getSFriends();
	}
	  
	function <portlet:namespace/>back()
	{
	    <portlet:namespace/>fFirst -= <portlet:namespace/>fMax;
	    if(<portlet:namespace/>fFirst < 0)
	    {
	      <portlet:namespace/>fFirst = 0;
	    }
	    <portlet:namespace/>getSFriends();
	}
	  
	function <portlet:namespace/>reset()
	{
	    if(<portlet:namespace/>fFirst != 0)
	    {
	      <portlet:namespace/>fFirst = 0;
	    }
	    <portlet:namespace/>getSFriends();
	}
	
	function <portlet:namespace/>getSFriends()
	{
		var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>USER_FRAG
	      	+ <portlet:namespace/>OWNER_ID + '/sfriend?fields=id,name,thumbnailUrl';
		url += '&sortBy=name&sortOrder=ascending';
		url += '&startIndex=' + <portlet:namespace/>fFirst;
		url += '&count=' + <portlet:namespace/>fMax;

		if(<portlet:namespace/>SHINDIG_TOKEN != null)
		{
			url += '&st=' + <portlet:namespace/>SHINDIG_TOKEN;
		}
	    
		<portlet:namespace/>sendRequest('GET', url, <portlet:namespace/>callback);
	}
	
	function <portlet:namespace/>callback(friends)
	{
	    if(friends)
	    {
	      //fake list for only one friend result
	      if(!friends.list)
	      {
	        friends.list = new Array();
	        friends.list.push(friends.entry);
	      }
	      
	      //clear old images
	      <portlet:namespace/>fImages = new Array();
	      <portlet:namespace/>fIndexCounter = 0;
	      
	      //generate HTML
	      var html = '<ul id="<portlet:namespace/>friendsDiv">';
	      
	      var index = 0;
	      	
	      //friends
	      while(index < friends.list.length)
	      {
	        html += '<li class="<portlet:namespace/>friendEntry">'
	        	+ <portlet:namespace/>extendedEntry(friends.list[index]) + '</li>';
	        ++index;
	      }
	      html += '</ul>';
	      
	      //<portlet:namespace/>controls
	      html += '</div><div id="<portlet:namespace/>controls">';
	        
	      if(<portlet:namespace/>fFirst > 0)
	      {
	        html += '<input type="button" value="' + '<liferay-ui:message key="suggestions-back" />'
	          + '" onclick="<portlet:namespace/>back()"/>';
	      }
	      
	      html += ' ' + (<portlet:namespace/>fFirst + 1) + ' ' + '<liferay-ui:message key="suggestions-to" />'
	      	+ ' ' + (<portlet:namespace/>fFirst + <portlet:namespace/>fMax) + ' '
	        + '<liferay-ui:message key="suggestions-of" />' + ' ' + friends.totalResults + ' ';
	        
	      if(friends.totalResults > <portlet:namespace/>fFirst + <portlet:namespace/>fMax)
	      {
	        html += '<input type="button" value="' + '<liferay-ui:message key="suggestions-more" />'
	          + '" onclick="<portlet:namespace/>more()"/>';
	      }
	      html += '</div>';
	      
	      document.getElementById('<portlet:namespace/>body').innerHTML = html;
	    }
	    else
	    {
	      //alert('Shindig Suggestions Portlet: no data received');

		  document.getElementById('<portlet:namespace/>errorSpan').innerHTML = 'no data received';
		  document.getElementById('<portlet:namespace/>errorSpan').style.display = 'flex';
	    }
	}

	function <portlet:namespace/>actions(entry)
	{
		html = '<ul class="<portlet:namespace/>actions">';
		
		html += '<li><img width="32" src="<%=request.getContextPath()%>/images/user_male_add.png"'
	        + ' alt="' + <portlet:namespace/>ADD_LABEL + '" onclick="<portlet:namespace/>addFriend(\''
	        + entry.id + '\')" style="vertical-align: middle; cursor: pointer;" '
	        + 'title="' + <portlet:namespace/>ADD_LABEL + '" /></li>';
	    
	    html += '<li><img width="32" src="<%=request.getContextPath()%>/images/send_email.png"'
	        + ' alt="' + <portlet:namespace/>SEND_LABEL + '" style="vertical-align: middle;" '
	        + 'title="' + <portlet:namespace/>SEND_LABEL + '" /></li>';
	    
	    html += '</ul>';
	    
	    return html;
	}
	
	function <portlet:namespace/>simpleEntry(entry)
	{
		html = '<a href="/web/guest/profile?userId=' + entry.id + '" target="_blank">'
			+ entry.name.formatted + '</a>';
		
	    return html;
	}
	  
	function <portlet:namespace/>extendedEntry(entry)
	{
	  	var html = '<div class="<portlet:namespace/>picBlock">'
	  		+ '<a href="/web/guest/profile?userId=' + entry.id + '" target="_blank">';

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
	  	
	  	html += <portlet:namespace/>actions(entry);
	  	
	  	html += '</div><br/>';
	  	
	  	return html + <portlet:namespace/>simpleEntry(entry);
	}
	  
	function <portlet:namespace/>thumbLoaded(elementId, url)
	{
		var image = document.getElementById(elementId);
		image.src = url;
	}
	
	function <portlet:namespace/>addFriend(id)
	{
	    var person = {"id": id};
	  
	    //var params = {"userId": "@me", "groupId": "@friends",
	    //  "person": person};
	    
	    //osapi.people.create(params).execute(requestSent);
	    
	    var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>PEOPLE_FRAG
	    	+ <portlet:namespace/>USER_ID + '/@friends';
	    
	    if(<portlet:namespace/>SHINDIG_TOKEN != null)
	    {
	  	  url += '?st=' + <portlet:namespace/>SHINDIG_TOKEN;
	    }
	    
	    <portlet:namespace/>sendRequest('POST', url, <portlet:namespace/>requestSent, person);
	}
	  
	function <portlet:namespace/>requestSent(data)
	{
		if(data)
	    {
		  //alert('<liferay-ui:message key="suggestions-request-sent" />');

		  document.getElementById('<portlet:namespace/>successSpan').innerHTML = '<liferay-ui:message key="suggestions-request-sent" />';
		  document.getElementById('<portlet:namespace/>successSpan').style.display = 'flex';
		  
	      <portlet:namespace/>getSFriends();
	    }
	    else
	    {
	      //alert('Shindig Suggestions Portlet: no data received');

		  document.getElementById('<portlet:namespace/>errorSpan').innerHTML = 'no data received';
		  document.getElementById('<portlet:namespace/>errorSpan').style.display = 'flex';
	    }
	}
	
	
	<portlet:namespace/>getSFriends();
</script>