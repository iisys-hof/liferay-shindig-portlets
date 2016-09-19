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
token.put("i", "shindig-activities-portlet");

//viewer
token.put("v", userName);

String shindigToken = "default:" + new BasicBlobCrypter(new File(PortletProps.get("token_secret")))
		.wrap(token);

HttpServletRequest httpRequest = PortalUtil.getOriginalServletRequest(
	PortalUtil.getHttpServletRequest(renderRequest)); 
String userParam = httpRequest.getParameter("userId");
%>

<portlet:actionURL var="fSetParamsUrl" name="setParams" />
<portlet:resourceURL var="fGetParamsUrl" id="getParams"/>

<style type="text/css">
  #<portlet:namespace/>body {
    height: auto;
    width: 100%;
    overflow: auto;
  }
  #<portlet:namespace/>streamDiv {
    position: relative;
    top: 0px;
    bottom: 2em;
    left: 0px;
    width: 100%;
    overflow: auto;
  }
  #<portlet:namespace/>streamTable {
    font-family: arial, sans-serif;
    font-size:100%;
  }
  #<portlet:namespace/>controls {
    font-size:80%;
    text-align: center;
    position: relative;
    bottom: 0px;
    left: 0px;
    width: 100%;
    height: 2em;
    visibility: visible;
  }
  
  .<portlet:namespace/>activityEntry {
    min-height: 2.4em;
  }
  .<portlet:namespace/>activityText {
    float: left;
  }
  .<portlet:namespace/>contentDiv {
    font-style: normal;
    font-weight: normal;
    text-align: left;
    padding-bottom: 1.3em;
    margin-top: -0.5em;
    padding-left: 1.3em;
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
  var <portlet:namespace/>ACTIVITY_FRAG = "social/rest/activitystreams/";

  var <portlet:namespace/>MIN_HEIGHT = 100;
  var <portlet:namespace/>MAX_HEIGHT = 4000;
  var <portlet:namespace/>DEFAULT_PAGE_SIZE = 10;
  var <portlet:namespace/>MIN_PAGE_SIZE = 1;
  var <portlet:namespace/>MAX_PAGE_SIZE = 100;
  
  var <portlet:namespace/>MAX_NAME_LENGTH = 50;
  var <portlet:namespace/>NAME_CUTOFF = 25;
  var <portlet:namespace/>NAME_CUTOFF_MARKER = '...';
  
  var <portlet:namespace/>SHOW_LABEL = '<liferay-ui:message key="activitystreams-show-content" />';
  var <portlet:namespace/>HIDE_LABEL = '<liferay-ui:message key="activitystreams-hide-content" />';
  var <portlet:namespace/>DELETE_LABEL = '<liferay-ui:message key="activitystreams-delete-button" />';
  var <portlet:namespace/>BACK_LABEL = '<liferay-ui:message key="activitystreams-back" />';
  var <portlet:namespace/>TO_LABEL = '<liferay-ui:message key="activitystreams-to" />';
  var <portlet:namespace/>OF_LABEL = '<liferay-ui:message key="activitystreams-of" />';
  var <portlet:namespace/>MORE_LABEL = '<liferay-ui:message key="activitystreams-more" />';
  var <portlet:namespace/>NONAME_LABEL = '<liferay-ui:message key="activitystreams-noname" />';
  
  var <portlet:namespace/>POSTED_LABEL = '<liferay-ui:message key="activitystreams-target-posted" />';
  var <portlet:namespace/>GEN_TO_LABEL = '<liferay-ui:message key="activitystreams-target-to" />';
  
  var <portlet:namespace/>USER_ID = '<%= userName %>';
  
  var <portlet:namespace/>SHINDIG_TOKEN = '<%= shindigToken %>';
  var <portlet:namespace/>fLastId = <portlet:namespace/>USER_ID;
  
  var <portlet:namespace/>fToggled;
  var <portlet:namespace/>fLastResult;

  var <portlet:namespace/>fViewerId = "-1";
  var <portlet:namespace/>fGroupId = "@all";
  var <portlet:namespace/>fFirst = 0;
  var <portlet:namespace/>fMax = <portlet:namespace/>DEFAULT_PAGE_SIZE;
  
  function <portlet:namespace/>more()
  {
	<portlet:namespace/>fFirst += <portlet:namespace/>fMax;
    <portlet:namespace/>getActivities();
  }
  
  function <portlet:namespace/>back()
  {
	  <portlet:namespace/>fFirst -= <portlet:namespace/>fMax;
    if(<portlet:namespace/>fFirst < 0)
    {
    	<portlet:namespace/>fFirst = 0;
    }
    <portlet:namespace/>getActivities();
  }
  
  function <portlet:namespace/>reset()
  {
    if(<portlet:namespace/>fFirst != 0)
    {
    	<portlet:namespace/>fFirst = 0;
    }
    <portlet:namespace/>getActivities();
  }
  
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
		      alert('Shindig Activities Portlet:\n'
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

  function <portlet:namespace/>getActivities()
  {
    //start activity retrieval, check who owner and viewer are
    //var idList = '@owner,@viewer';
    //var params = {"userId": idList, "fields":"id"};
    
    //TODO: uncomment once tokens are available
    //<portlet:namespace/>sendRequest('get', <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>PEOPLE_FRAG + idList + '?fields=id',
    //		<portlet:namespace/>checkOwner);
    
    var data = new Object();
    
    //send whether viewer and person to display are the same
    if(<portlet:namespace/>fLastId == '<%= userName %>')
    {
        data.id = <portlet:namespace/>fLastId;
    }
    else
    {
    	data.list = new Array();
    	
    	//TODO: set IDs?
    	data.list.push(new Object());
    	data.list.push(new Object());
    }
    <portlet:namespace/>checkOwner(data);
  }
  
  function <portlet:namespace/>checkOwner(data)
  {
    if (data)
    {
      if(data.list)
      {
        //viewer and owner are not the same person
        <portlet:namespace/>fGroupId = "@self";
      
        data.list.forEach(function(entry)
      	{
      	  if(entry.isViewer)
          {
      		<portlet:namespace/>fViewerId = entry.id;
            
            //failsafe if two people are returned anyway, that are the
            //same person
            if(entry.isOwner)
            {
            	<portlet:namespace/>fGroupId = "@all";
            }
      	  }
      	});
      }
      else
      {
        //only one person returned - owner and viewer
        <portlet:namespace/>fViewerId = data.id;
        <portlet:namespace/>fGroupId = "@all";
      }
      
      //create REST URL
      var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>ACTIVITY_FRAG + <portlet:namespace/>fLastId;
      url += '/' + <portlet:namespace/>fGroupId;
      url += '?fields=id,title,actor,object,target,generator,published,content,verb';
      url += '&sortBy=published&sortOrder=descending';
      url += '&startIndex=' + <portlet:namespace/>fFirst;
      url += '&count=' + <portlet:namespace/>fMax;
      
      if(<portlet:namespace/>SHINDIG_TOKEN != null)
      {
    	  url += '&st=' + <portlet:namespace/>SHINDIG_TOKEN;
      }
      
      //send request
      <portlet:namespace/>sendRequest('GET', url, <portlet:namespace/>update);
    }
    else
    {
      //alert('Shindig Activities Portlet: no data received');

	  document.getElementById('<portlet:namespace/>errorSpan').innerHTML = 'no data received';
	  document.getElementById('<portlet:namespace/>errorSpan').style.display = 'flex';
    }
  }

  function <portlet:namespace/>displayTime(time)
  {
    var date = new Date(time);
  	
    var display = date.getDate();
    if(display < 10)
    {
      display = '0' + display;
    }
    display += '/';
    
    var month = date.getMonth() + 1;
    if(month < 10)
    {
      month = '0' + month;
    }
    display += month + '/';
    
    var year = new String(date.getFullYear());
    year = year.substring(2, 4);
    
    display += year + ' - ';
    
    var hours = date.getHours();
    if(hours < 10)
    {
      display += '0';
    }
    display += hours + ':';
    
    var minutes = date.getMinutes();
    if(minutes < 10)
    {
      display += '0';
    }
    display += minutes;
    
    return display;
  }
  
  function <portlet:namespace/>displayEntry(entry)
  {
	  var html = '';
	  
	  //supporting activity objects
	  var actor = null;
	  var object = null;
	  var target = null;
	  var generator = null;

	  if(entry.actor)
	  {
		  actor = <portlet:namespace/>getDisplay(entry.actor);
	  }
	  
	  if(entry.object)
	  {
		  object = <portlet:namespace/>getDisplay(entry.object);
	  }
	  
	  if(entry.target)
	  {
		  target = <portlet:namespace/>getDisplay(entry.target);
	  }
	  
	  if(entry.generator)
      {
  	      generator = <portlet:namespace/>getDisplay(entry.generator);
      }
	  
	  var title = entry.title;
	  
	  //entries with no verb
	  if(!entry.verb)
	  {
		  title = actor + ' ' + <portlet:namespace/>POSTED_LABEL;
		  
		  if(object != null)
		  {
			  title += ' ' + object;
		  }
		  
		  if(target != null)
		  {
			  title += ' ' + <portlet:namespace/>GEN_TO_LABEL + ' ' + target;
		  }
	  }
	  
	  //determine message through verb
	  else switch(entry.verb)
	  {
	    case 'add':
	    	if(target == null)
	    	{
	    		title = '<liferay-ui:message key="activitystreams-add" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-add-wtarget" />';
	    	}
	    	
	    	//special treatment for certain types
	    	if(entry.object != null
	    		&& entry.object.objectType != null)
	    	{
	    		//voting, i.e. adding ratings/votes
	    		if(entry.object.objectType.indexOf("vote") > -1)
	    		{
		    		//special message for added ratings
		    		if(entry.object.content != null)
		    		{
		    			var ratingString = entry.object.content;
		    			
		    			if(!isNaN(ratingString)
		    			  && parseInt(ratingString) > 1)
		    			{
		    				ratingString += ' <liferay-ui:message key="activitystreams-rate-stars" />';
		    			}
		    			
		    			title = actor + ' <liferay-ui:message key="activitystreams-rate-wrating-frag1" /> '
			    			+ target + ' <liferay-ui:message key="activitystreams-rate-wrating-frag2" /> '
			    			+ ratingString
			    			+ ' <liferay-ui:message key="activitystreams-rate-wrating-frag3" />';
		    		}
		    		else
		    		{
		    			title = '<liferay-ui:message key="activitystreams-rate" />';
		    		}
	    		}
	    		//adding skills to other people -> suggesting them
	    		else if(entry.object.objectType.indexOf("skill") > -1
	    			&& target != null)
	    		{
	    			title = '<liferay-ui:message key="activitystreams-add-skill-wtarget" />'
	    		}
	    	}
	    	
	    	break;

	    case 'access':
	    	if(target == null)
	    	{
	    		title = '<liferay-ui:message key="activitystreams-access" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-access-wtarget" />';
	    	}
	    	break;

	    case 'post':
	    	if(target == null)
	    	{
	    		title = '<liferay-ui:message key="activitystreams-post" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-post-wtarget" />';
	    	}
	    	break;

	    case 'append':
	    	if(target == null)
	    	{
	    		title = '<liferay-ui:message key="activitystreams-append" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-append-wtarget" />';
	    	}
	    	break;

	    case 'attach':
	    	if(target == null)
	    	{
	    		title = '<liferay-ui:message key="activitystreams-attach" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-attach-wtarget" />';
	    	}
	    	break;

	    case 'cancel':
	    	if(target == null)
	    	{
	    		title = '<liferay-ui:message key="activitystreams-cancel" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-cancel-wtarget" />';
	    	}
	    	break;

	    case 'create':
	    	if(object == null && target == null)
	    	{
	    		title = '<liferay-ui:message key="activitystreams-create-self" />';
	    	}
	    	else if(target == null)
	    	{
	    		title = '<liferay-ui:message key="activitystreams-create" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-create-wtarget" />';
	    	}
	    	break;

	    case 'delete':
	    	if(object == null && target == null)
	    	{
	    		title = '<liferay-ui:message key="activitystreams-delete-self" />';
	    	}
	    	else if(target == null)
	    	{
	    		title = '<liferay-ui:message key="activitystreams-delete" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-delete-wtarget" />';
	    	}
	    	break;

	    case 'follow':
	    	if(target == null && object != null
			    || target != null && object == null)
	    	{
	    		title = '<liferay-ui:message key="activitystreams-follow" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-follow-wtarget" />';
	    	}
	    	break;

	    case 'stop-following':
	    	if(target == null && object != null
		    	|| target != null && object == null)
	    	{
	    		title = '<liferay-ui:message key="activitystreams-unfollow" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-unfollow-wtarget" />';
	    	}
	    	break;

	    case 'make-friend':
	    	if(target == null && object != null
	    		|| target != null && object == null)
	    	{
	    		title = '<liferay-ui:message key="activitystreams-make-friend" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-make-friend-wtarget" />';
	    	}
	    	break;

	    case 'open':
	    	if(target == null)
	    	{
	    		title = '<liferay-ui:message key="activitystreams-open" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-open-wtarget" />';
	    	}
	    	break;

	    case 'remove':
	    	if(target == null)
	    	{
	    		title = '<liferay-ui:message key="activitystreams-remove" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-remove-wtarget" />';
	    	}
	    	break;

	    case 'save':
	    	if(target == null)
	    	{
	    		title = '<liferay-ui:message key="activitystreams-save" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-save-wtarget" />';
	    	}
	    	break;

	    case 'share':
	    	if(target == null)
	    	{
	    		title = '<liferay-ui:message key="activitystreams-share" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-share-wtarget" />';
	    	}
	    	break;

	    case 'submit':
	    	if(target == null)
	    	{
	    		title = '<liferay-ui:message key="activitystreams-submit" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-submit-wtarget" />';
	    	}
	    	break;

	    case 'tag':
	    	if(target == null && object != null
		    	|| target != null && object == null)
	    	{
	    		title = '<liferay-ui:message key="activitystreams-tag" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-tag-wtarget" />';
	    	}
	    	break;

	    case 'update':
	    	if(entry.object != null
		    	&& entry.object.objectType == "shindig-status-message"
		    	&& entry.object.content != null)
		    {
	    		//special message for status messages
	    		//TODO: shortening?
	    		title = '<liferay-ui:message key="activitystreams-update" />'
	    			+ ': ' + entry.object.content;
		    }
		    else if(target == null && object != null
	    		|| target != null && object == null)
	    	{
	    		title = '<liferay-ui:message key="activitystreams-update" />';
	    	}
	    	else if(target != null)
	    	{
	    		title = '<liferay-ui:message key="activitystreams-update-wtarget" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-update-self" />';
	    	}
	    	break;

	    case 'invite':
	    	if(target == null)
	    	{
	    		title = '<liferay-ui:message key="activitystreams-invite" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-invite-wtarget" />';
	    	}
        	break;

	    case 'complete':
	    	if(target == null)
	    	{
	    		title = '<liferay-ui:message key="activitystreams-complete" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-complete-wtarget" />';
	    	}
       		break;

	    case 'join':
	    	if(target == null)
	    	{
	    		title = '<liferay-ui:message key="activitystreams-join" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-join-wtarget" />';
	    	}
        	break;

	    case 'leave':
	    	if(target == null)
	    	{
	    		title = '<liferay-ui:message key="activitystreams-leave" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-leave-wtarget-frag1" />';
	    	}
        	break;
      
      	case 'assign':
	    	if(target == null)
	    	{
	    		title = '<liferay-ui:message key="activitystreams-assign" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-assign-wtarget" />';
	    	}
        	break;
      
      	case 'authorize':
	    	if(target == null)
	    	{
	    		title = '<liferay-ui:message key="activitystreams-authorize" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-authorize-wtarget" />';
	    	}
        	break;
      
      	case 'request':
	    	if(target == null)
	    	{
	    		title = '<liferay-ui:message key="activitystreams-request" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-request-wtarget" />';
	    	}
        	break;
        	
      	case 'accept':
      		if(target == null)
	    	{
      			title = '<liferay-ui:message key="activitystreams-accept" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-accept-wtarget" />';
	    	}
      		break;
        	
      	case 'approve':
      		if(target == null)
	    	{
      			title = '<liferay-ui:message key="activitystreams-approve" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-approve-wtarget" />';
	    	}
      		break;
        	
      	case 'deny':
      		if(target == null)
	    	{
      			title = '<liferay-ui:message key="activitystreams-deny" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-deny-wtarget" />';
	    	}
      		break;
        	
      	case 'favorite':
      		if(target == null)
	    	{
      			title = '<liferay-ui:message key="activitystreams-favorite" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-favorite-wtarget" />';
	    	}
      		break;
        	
      	case 'give':
      		if(target == null)
	    	{
      			title = '<liferay-ui:message key="activitystreams-give" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-give-wtarget" />';
	    	}
      		break;
        	
      	case 'ignore':
      		if(target == null)
	    	{
      			title = '<liferay-ui:message key="activitystreams-ignore" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-ignore-wtarget" />';
	    	}
      		break;
        	
      	case 'qualify':
      		if(target == null)
	    	{
      			title = '<liferay-ui:message key="activitystreams-qualify" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-qualify-wtarget" />';
	    	}
      		break;
        	
      	case 'reject':
      		if(target == null)
	    	{
      			title = '<liferay-ui:message key="activitystreams-reject" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-reject-wtarget" /> ';
	    	}
      		break;
        	
      	case 'remove-friend':
      		if(target == null)
	    	{
      			title = '<liferay-ui:message key="activitystreams-remove-friend" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-remove-friend-wtarget" />';
	    	}
      		break;
        	
      	case 'request-friend':
      		if(target == null)
	    	{
      			title = '<liferay-ui:message key="activitystreams-request-friend" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-request-friend-wtarget" />';
	    	}
      		break;
        	
      	case 'retract':
      		if(target == null)
	    	{
      			title = '<liferay-ui:message key="activitystreams-retract" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-retract-wtarget" />';
	    	}
      		break;
        	
      	case 'rsvp-maybe':
      		if(target == null)
	    	{
      			title = '<liferay-ui:message key="activitystreams-rsvp-maybe" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-rsvp-maybe-wtarget" />';
	    	}
      		break;
        	
      	case 'rsvp-no':
      		if(target == null)
	    	{
      			title = '<liferay-ui:message key="activitystreams-rsvp-no" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-rsvp-no-wtarget" />';
	    	}
      		break;
        	
      	case 'rsvp-no':
      		if(target == null)
	    	{
      			title = '<liferay-ui:message key="activitystreams-rsvp-no" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-rsvp-no-wtarget" />';
	    	}
      		break;
        	
      	case 'rsvp-yes':
      		if(target == null)
	    	{
      			title = '<liferay-ui:message key="activitystreams-rsvp-yes" /> ';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-rsvp-yes-wtarget" />';
	    	}
      		break;
        	
      	case 'start':
      		if(target == null)
	    	{
      			title = '<liferay-ui:message key="activitystreams-start" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-start-wtarget" />';
	    	}
      		break;
        	
      	case 'unfavorite':
      		if(target == null)
	    	{
      			title = '<liferay-ui:message key="activitystreams-unfavorite" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-unfavorite-wtarget" />';
	    	}
      		break;
        	
      	case 'unshare':
      		if(target == null)
	    	{
      			title = '<liferay-ui:message key="activitystreams-unshare" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-unshare-wtarget" />';
	    	}
      		break;
      		
      	//unofficial verbs
      	case 'copy':
      		if(target == null)
	    	{
      			title = '<liferay-ui:message key="activitystreams-copy" /> ';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-copy-wtarget" />';
	    	}
      		break;
      		
      	case 'move':
      		if(target == null)
	    	{
      			title = '<liferay-ui:message key="activitystreams-move" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-move-wtarget" />';
	    	}
      		break;
      		
      	case 'restore':
      		if(target == null)
	    	{
      			title = '<liferay-ui:message key="activitystreams-restore" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-restore-wtarget" />';
	    	}
      		break;
      		
      	case 'update-metadata':
      		if(target == null)
	    	{
	    		title = '<liferay-ui:message key="activitystreams-update-metadata" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-update-metadata-wtarget" />';
	    	}
      		break;

      	case 'send':
      		if(target == null)
	    	{
	    		title = '<liferay-ui:message key="activitystreams-send" />';
	    	}
	    	else
	    	{
	    		title = '<liferay-ui:message key="activitystreams-send-wtarget" />';
	    	}
      		break;
	  
	  	//undefined verbs
	  	default:
	  		title = actor + ' ' + entry.verb + 'ed';
		  
		    if(object != null)
		    {
		    	title += ' ' + object;
			}
			  
			if(target != null)
			{
				title += ' ' + <portlet:namespace/>GEN_TO_LABEL + ' ' + target;
			}
	  		break;
	  }
	  
	  //replace variables and set title
	  title = title.replace('$ACTOR', actor);
	  title = title.replace('$OBJECT', object);
	  title = title.replace('$OBJECT', target);
	  title = title.replace('$TARGET', target);
	  html += title;
	  	
	  if(generator != null)
	  {
	  	html += ' (' + generator + ')';
	  }
	  
	  return html;
  }

  function <portlet:namespace/>update(data)
  {
    if (!data.error)
    {
      <portlet:namespace/>fToggled = new Array();
      <portlet:namespace/>fLastResult = data;
    
      var html = '<div id="<portlet:namespace/>streamDiv">';
        
      var index = 0;

      //each entry
      data.list.forEach(function(entry)
      {  
        //normal data
        html += '<div class="<portlet:namespace/>activityEntry">'
          +'<div class="<portlet:namespace/>activityText">';
        html += <portlet:namespace/>displayTime(entry.published)  + ' - ';
        
        //display individual part
    	html += <portlet:namespace/>displayEntry(entry);
        
        //button to show content
        html += '</div>';
        
        if(entry.title || entry.content)
        {
          html += '<div id="<portlet:namespace/>conButton' + index + '" style="float:right;">';
          html += '<img src="<%=request.getContextPath()%>/images/toggle_down_alt.png" '
            + 'alt="' + <portlet:namespace/>SHOW_LABEL
            + '" onclick="<portlet:namespace/>showContent(' + index + ')" '
            + 'title="' + <portlet:namespace/>SHOW_LABEL
            + '" style="cursor: pointer;height:2.4em;" /></div>';
        }
        
        //button to delete entry, only for owner of the activity (actor at the moment)
        if(entry.actor.id == <portlet:namespace/>fViewerId)
        {
          html += '<img width="20" src="<%=request.getContextPath()%>/images/stop.png" '
            + 'alt="' + <portlet:namespace/>DELETE_LABEL
            + '" onclick="<portlet:namespace/>deleteEntry(' + index + ')" '
            + 'title="' + <portlet:namespace/>DELETE_LABEL
            + '" style="cursor: pointer;margin-left: 0.3em;vertical-align:baseline;" '
            + '/></div>';
        }
        
        html += '</div>';
        
        //content div
        if(entry.title || entry.content)
        {
          html += '<div class="<portlet:namespace/>contentDiv" '
            + 'id="<portlet:namespace/>entryContent' + index + '" style="display:none;">';
          
          if(entry.title)
       	  {
        	  html += entry.title;
        	  
        	  if(entry.content)
        	  {
        		  html += '<br/>';
        	  }
          }
          
          if(entry.content)
          {
        	  html += entry.content;
          }
          
          html += '</div>';
        }
        
        ++index;
      });
      
      html += '</div>';
      
      html += '<div id="<portlet:namespace/>controls">';
      if(<portlet:namespace/>fFirst > 0)
      {
        html += '<input type="button" value="' + <portlet:namespace/>BACK_LABEL
          + '" onclick="<portlet:namespace/>back()"/>';
      }
      
      html += ' ' + (<portlet:namespace/>fFirst + 1) + ' ' + <portlet:namespace/>TO_LABEL + ' '
        + (<portlet:namespace/>fFirst + <portlet:namespace/>fMax)
        + ' ' + <portlet:namespace/>OF_LABEL + ' ' + data.totalResults + ' ';
        
      if(data.totalResults > <portlet:namespace/>fFirst + <portlet:namespace/>fMax)
      {
        html += '<input type="button" value="' + <portlet:namespace/>MORE_LABEL
          + '" onclick="<portlet:namespace/>more()"/>';
      }
      html += '</div>';
      
      document.getElementById('<portlet:namespace/>body').innerHTML = html;
      
      <portlet:namespace/>setParams();
    }
    else
    {
      if(data.error.value)
      {
        //alert(data.error.value);

	  	document.getElementById('<portlet:namespace/>errorSpan').innerHTML = 'Error: ' + data.error.value;
	  	document.getElementById('<portlet:namespace/>errorSpan').style.display = 'flex';
      }
      else if(data.error.message)
      {
        //alert(data.error.message);

	  	document.getElementById('<portlet:namespace/>errorSpan').innerHTML = 'Error: ' + data.error.message;
	  	document.getElementById('<portlet:namespace/>errorSpan').style.display = 'flex';
      }
      else
      {
        //alert(data.error);

	  	document.getElementById('<portlet:namespace/>errorSpan').innerHTML = 'Error: ' + data.error;
	  	document.getElementById('<portlet:namespace/>errorSpan').style.display = 'flex';
      }
    }
  }
  
  function <portlet:namespace/>getDisplay(object)
  {
    var display = '';
    
    if(object.objectType == 'person')
    {
      display += '<a href="/web/guest/profile?userId='
          + object.id + '" target="_blank">';
    }
    else if(object.url)
    {
      display += '<a href="' + object.url + '" target="_blank">';
    }
  
    if(object.displayName)
    {
      //shorten overly long names
      if(object.displayName.length <= <portlet:namespace/>MAX_NAME_LENGTH)
      {
    	  display += object.displayName;
      }
      else
      {
    	var shortName = object.displayName.substring(0,
    	    <portlet:namespace/>NAME_CUTOFF);
    	shortName += <portlet:namespace/>NAME_CUTOFF_MARKER;
    	display += shortName;
      }
    }
    else
    {
      display += <portlet:namespace/>NONAME_LABEL;
    }
    
    if(object.url || object.objectType == 'person')
    {
      display += '</a>';
    }
    
    return display;
  }
  
  function <portlet:namespace/>showContent(index)
  {
    if(<portlet:namespace/>fToggled[index])
    {
    	<portlet:namespace/>fToggled[index] = false;
      
        document.getElementById('<portlet:namespace/>entryContent'
        		+ index).style.display = 'none';
      
        document.getElementById('<portlet:namespace/>conButton' + index).innerHTML =
          '<img src="<%=request.getContextPath()%>/images/toggle_down_alt.png" '
          + 'alt="' + <portlet:namespace/>SHOW_LABEL
          + '" onclick="<portlet:namespace/>showContent(' + index + ')" '
          + 'title="' + <portlet:namespace/>SHOW_LABEL
          + '" style="cursor: pointer;height:2.4em;" />';
    }
    else
    {
    	<portlet:namespace/>fToggled[index] = true;

        document.getElementById('<portlet:namespace/>entryContent'
        		+ index).style.display = 'block';
      
        document.getElementById('<portlet:namespace/>conButton' + index).innerHTML =
          '<img src="<%=request.getContextPath()%>/images/toggle_collapse_alt.png" '
          + 'alt="' + <portlet:namespace/>HIDE_LABEL
          + '" onclick="<portlet:namespace/>showContent(' + index + ')" '
          + 'title="' + <portlet:namespace/>HIDE_LABEL
          + '" style="cursor: pointer;height:2.4em;" />';
    }
  }
  
  function <portlet:namespace/>deleteEntry(index)
  {
	if(!confirm('<liferay-ui:message key="activitystreams-confirm-delete" />'))
	{
		return;
	}
	  
    var entry = <portlet:namespace/>fLastResult.list[index];
    
    <portlet:namespace/>sendRequest('DELETE', <portlet:namespace/>SHINDIG_URL
    	+ <portlet:namespace/>ACTIVITY_FRAG + <portlet:namespace/>fLastId
    	+ '/@self?activityId=' + entry.id + '&st=' + <portlet:namespace/>SHINDIG_TOKEN,
    	<portlet:namespace/>deleted);
  }
  
  function <portlet:namespace/>deleted(data)
  {
    if(data)
    {
      <portlet:namespace/>getActivities();
    }
    else
    {
      //alert('Shindig Activities Portlet: no data received');

	  document.getElementById('<portlet:namespace/>errorSpan').innerHTML = 'no data received';
	  document.getElementById('<portlet:namespace/>errorSpan').style.display = 'flex';
    }
  }
  
  function <portlet:namespace/>setParams()
  {
	  <portlet:namespace/>sendRequest('GET', '<%= fSetParamsUrl %>' + '&<portlet:namespace/>first='
			  + <portlet:namespace/>fFirst + '&<portlet:namespace/>max=' + <portlet:namespace/>fMax,
			  <portlet:namespace/>paramsSet);
  }
  
  function <portlet:namespace/>paramsSet(data)
  {
	  //nop
  }
  
  function <portlet:namespace/>init()
  {
	  var initFirst = <%= portletSession.getAttribute("first") %>;
	  if(initFirst != null)
	  {
		  <portlet:namespace/>fFirst = initFirst;
	  }
	  
	  var initMax = <%= portletSession.getAttribute("max") %>;
	  if(initFirst != null)
	  {
		  <portlet:namespace/>fMax = initMax;
	  }
	  
	  //show activities of specified person if available
	  var userParam = '<%= userParam %>';
	  if(userParam != '' && userParam != 'null')
	  {
		  <portlet:namespace/>fLastId = userParam;
	  }
	  
      <portlet:namespace/>getActivities();
  }
  
  <portlet:namespace/>init();
</script>