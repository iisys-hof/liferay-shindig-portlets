<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet" %>
<%@ page import="javax.portlet.PortletPreferences" %>
<%@ taglib uri="http://liferay.com/tld/ui" prefix="liferay-ui"%>
<%@ taglib uri="http://liferay.com/tld/theme" prefix="liferay-theme"%>

<%@include file="/html/init.jsp" %>

<portlet:defineObjects />
<liferay-theme:defineObjects />

<%@ page import="java.util.Map,java.util.HashMap,com.liferay.util.portlet.PortletProps,org.apache.shindig.common.crypto.BasicBlobCrypter,org.apache.shindig.auth.BasicSecurityToken,java.io.File,com.liferay.portal.kernel.util.PortalUtil" %>

<%
PortletPreferences prefs = renderRequest.getPreferences();
String userName = user.getScreenName();

//see AbstractSecurityToken for keys
Map<String, String> token = new HashMap<String, String>();
//application
token.put("i", "shindig-userdirectory-portlet");

//viewer
token.put("v", userName);

String shindigToken = "default:" + new BasicBlobCrypter(new File(PortletProps.get("token_secret")))
		.wrap(token);

HttpServletRequest httpRequest = PortalUtil.getOriginalServletRequest(
	PortalUtil.getHttpServletRequest(renderRequest)); 
String userParam = httpRequest.getParameter("userId");

String searchFieldParam = httpRequest.getParameter("userDirSearchField");
String searchValueParam = httpRequest.getParameter("userDirSearchValue");

//hashTag in Wiki URL detection 
String curURL = themeDisplay.getURLCurrent();
String hashtag = "";
if(curURL.indexOf("_title") != -1)
{
	hashtag = curURL.substring( curURL.indexOf("_title")+7 ).toLowerCase();
	if(hashtag.indexOf("&") != -1)
	{
		hashtag = hashtag.substring(0, hashtag.indexOf("&"));	
	}	
}
else if(curURL.contains("wiki"))
{
	//cut parameters
	if(curURL.indexOf("?") > -1)
	{
		curURL = curURL.substring(0, curURL.indexOf("?"));
	}
	
	//cut trailing slash
	if(curURL.lastIndexOf("/") == curURL.length() - 1)
	{
		curURL = curURL.substring(0, curURL.length() - 1);
	}
	
	hashtag = curURL.substring( curURL.lastIndexOf("/")+1 ).toLowerCase();
}
%>

<style type="text/css">
  #<portlet:namespace/>body {
    height: auto;
    width: 100%;
    overflow: auto;
  }
  #<portlet:namespace/>usersDiv {
    position: relative;
    top: 0px;
    bottom: 2em;
    left: 0px;
    width: 100%;
    overflow: auto;
  }
  #<portlet:namespace/>userTable {
    font-size:100%;
  }
  #<portlet:namespace/>preSearchDiv {
    display: table-cell;
    width: 100;
    text-align: right;
  }
  #<portlet:namespace/>searchDiv {
  	width: 100%;
    display: table;
  }
  #<portlet:namespace/>postSearchDiv {
    display: table-cell;
    text-align: right;
  }
  .<portlet:namespace/>entryLi {
    position: relative;
  	display: inline-block;
  	width: 100%;
  	padding-top: 0.6em;
  	padding-bottom: 0.6em;
  	border-bottom:1px dashed #BBB;
  }
  .<portlet:namespace/>thumbnailDiv {
    position: relative;
    width: 100px;
    height: auto;
    float: left;
  	background-repeat: no-repeat;
  	background-size: contain;
  	background-image: url('<%=request.getContextPath()%>/images/profile_picture_placeholder.png');
  }
  .<portlet:namespace/>thumbnailDiv .sticker-outside {
    right: -7px;
    bottom: -7px;
  }
  .<portlet:namespace/>infoDiv {
    float: left;
    margin-left: 10px;
  }
  .<portlet:namespace/>infoDiv h4 {
    margin-bottom: 0.2em;
  }
  .<portlet:namespace/>infoDiv p {
    margin: 0;
    font-size: 0.9em;
    line-height: 1.7em;
  }
  .<portlet:namespace/>actionsDiv {
    position: absolute;
    right: 1px;
    bottom: 5px;
  }
  .<portlet:namespace/>actionsDiv .btn {
    width: 32px; padding:4px;
    border-radius: 100%;
    box-shadow: 1px 1px 1px #999;
    margin-bottom: 5px;
    font-size: 15px;
  }
  #<portlet:namespace/>controls {
    text-align: center;
    position: relative;
    bottom: 0px;
    left: 0px;
    width: 100%;
    height: 2em;
    visibility: visible;
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



<div id="<portlet:namespace/>successSpan" class="portlet-msg-success" style="display:none;"></div>
<div id="<portlet:namespace/>errorSpan" class="portlet-msg-error" style="display:none;"></div>
<div id="<portlet:namespace/>preSearchDiv" class="<portlet:namespace/>thumbnailDiv"> </div>
<div id="<portlet:namespace/>searchDiv"> </div>
<div id="<portlet:namespace/>postSearchDiv"> </div>

<div id="<portlet:namespace/>body"> </div>



<script type="text/javascript">
  var <portlet:namespace/>SHINDIG_URL = '<%= PortletProps.get("shindig_url") %>';
  var <portlet:namespace/>PEOPLE_FRAG = "social/rest/people/";
  var <portlet:namespace/>USER_FRAG = "social/rest/user";

  var <portlet:namespace/>USER_ID = '<%= userName %>';
  var <portlet:namespace/>SHINDIG_TOKEN = '<%= shindigToken %>';

  var <portlet:namespace/>ADD_FRIEND = '<liferay-ui:message key="userdirectory-friend-request" />';
  var <portlet:namespace/>SEND_MESSAGE = '<liferay-ui:message key="userdirectory-send-message" />';
  var <portlet:namespace/>PROFILE_PIC = '<liferay-ui:message key="userdirectory-profile-pic" />';
  var <portlet:namespace/>DUMMY_PIC = '<liferay-ui:message key="userdirectory-dummy-pic" />';
  var <portlet:namespace/>EMAILS = '<liferay-ui:message key="userdirectory-emails" />';
  var <portlet:namespace/>EMAIL = '<liferay-ui:message key="userdirectory-email" />';
  var <portlet:namespace/>PHONES = '<liferay-ui:message key="userdirectory-phones" />';
  var <portlet:namespace/>PHONE = '<liferay-ui:message key="userdirectory-phone" />';
  var <portlet:namespace/>BUSINESS = '<liferay-ui:message key="userdirectory-business" />';
  var <portlet:namespace/>PRIVATE = '<liferay-ui:message key="userdirectory-private" />';
  var <portlet:namespace/>GENERAL = '<liferay-ui:message key="userdirectory-friend-request" />';
  var <portlet:namespace/>MOBILE = '<liferay-ui:message key="userdirectory-mobile" />';
  var <portlet:namespace/>POSITION = '<liferay-ui:message key="userdirectory-position" />';
  var <portlet:namespace/>DEPARTMENT = '<liferay-ui:message key="userdirectory-department" />';
  var <portlet:namespace/>NAME = '<liferay-ui:message key="userdirectory-name" />';
  
  var <portlet:namespace/>fTypeIcons = {
	"geschäftlich": "<%=request.getContextPath()%>/images/icon-business_address.png",
  	"allgemein": "<%=request.getContextPath()%>/images/mini_circle.png",
  	"privat": "<%=request.getContextPath()%>/images/toolbar_home.png",
  	"mobil": "<%=request.getContextPath()%>/images/mobile_phone.png"};
  
  var <portlet:namespace/>fTypeLabels = {"geschäftlich": <portlet:namespace/>BUSINESS, "allgemein": <portlet:namespace/>GENERAL,
  	"privat": <portlet:namespace/>PRIVATE, "mobil": <portlet:namespace/>MOBILE};
  
  var <portlet:namespace/>fUsers;
  var <portlet:namespace/>fFriends;
  
  var <portlet:namespace/>fImages;

  var <portlet:namespace/>fLastId = "0";
  var <portlet:namespace/>fFirst = 0;
  var <portlet:namespace/>fMax = 5;
  
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
		      alert('Shindig User Directory Portlet:\n'
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
    <portlet:namespace/>getUsers();
  }
  
  function <portlet:namespace/>back()
  {
    <portlet:namespace/>fFirst -= <portlet:namespace/>fMax;
    if(<portlet:namespace/>fFirst < 0)
    {
      <portlet:namespace/>fFirst = 0;
    }
    <portlet:namespace/>getUsers();
  }
  
  function <portlet:namespace/>reset()
  {
    if(<portlet:namespace/>fFirst != 0)
    {
      <portlet:namespace/>fFirst = 0;
    }
    <portlet:namespace/>getUsers();
  }

  function <portlet:namespace/>getUsers()
  {
	//determine according to parameters what to search for
	
	//TODO
	
    var term = document.getElementById('<portlet:namespace/>searchField').value;
    var type = document.getElementById('<portlet:namespace/>searchSel').value;
    var filter = 'formatted';
    
    if(type == 'TAGS')
    {
      filter = 'tags';
    }
    else if(type == 'ALL')
    {
      filter = '@all';
    }
    else if(type == "SKILLS")
    {
      filter = '@skills';
    }
  
    <portlet:namespace/>fMax = parseInt(document.getElementById('<portlet:namespace/>maxField').value);
  
    //var params = {"fields": "id,name,thumbnailUrl,tags,phoneNumbers,emails,organizations",
    //  "sortBy": "familyName", "sortOrder": "ascending",
    //  "startIndex": <portlet:namespace/>fFirst, "count": <portlet:namespace/>fMax, "filterBy": filter,
    //  "filterOp" : "contains", "filterValue": term};
    
    //osapi.user.getAll(params).execute(getFriends);
    
    var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>USER_FRAG;
    url += '?fields=id,name,thumbnailUrl,tags,phoneNumbers,emails,organizations';
    url += '&sortBy=familyName&sortOrder=ascending';
    url += '&startIndex=' + <portlet:namespace/>fFirst;
    url += '&count=' + <portlet:namespace/>fMax;
    
    if(term && term != '')
    {
      url += '&filterBy=' + encodeURIComponent(filter) + '&filterOp=contains';
      url += '&filterValue=' + term;
    }
    
    if(<portlet:namespace/>SHINDIG_TOKEN != null)
    {
  	  url += '&st=' + <portlet:namespace/>SHINDIG_TOKEN;
    }
    
    <portlet:namespace/>sendRequest('GET', url, <portlet:namespace/>getFriends);
  }
  
  function <portlet:namespace/>getFriends(users)
  {
    if(users)
    {
      //fake list for only one result
      if(!users.list)
      {
        users.list = new Array();
        users.list.push(users);
      }
    
      <portlet:namespace/>fUsers = users;
    
      //determine who among these people the viewer is already friends with
      
    
      //var params = {"userId": idSet, "groupId": "@self", "fields":
      //  "id", "sortBy": "id", "sortOrder": "descending", "count": <portlet:namespace/>fMax,
      //  "filterBy" : "isFriendsWith", "filterValue": "@me"};
      
      //osapi.people.get(params).execute(callback);
      
      var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>PEOPLE_FRAG;
      
      //fake list to trigger filtering
      if(users.list.lenght == 1)
      {
    	  var bogus = new Object();
    	  object.id = <portlet:namespace/>USER_ID;
    	  users.list.push(bogus);
      }
      
      //user IDs
      var count = 0;
      users.list.forEach(function(entry)
      {
    	if(count > 0)
    	{
    		url += ',';
    	}
    	
    	url += entry.id;
    	
    	++count;
      });
      
      //add additional ID - filters don't work for single-person queries
      url += ',anonymous';
      
      url += '?fields=id&sortBy=id&sortOrder=descending';
      url += '&count=' + <portlet:namespace/>fMax;
      url += '&filterBy=isFriendsWith&filterValue=' + <portlet:namespace/>USER_ID;
      
      <portlet:namespace/>sendRequest('GET', url, <portlet:namespace/>callback);
    }
    else
    {
      //alert('Shindig User Directory Portlet: no data received');

	  document.getElementById('<portlet:namespace/>errorSpan').innerHTML = 'no data received';
	  document.getElementById('<portlet:namespace/>errorSpan').style.display = 'flex';
    }
  }

  function <portlet:namespace/>callback(friends)
  {
    var users = <portlet:namespace/>fUsers;
  
    if(friends)
    {
      //fake list for only one friend in the result
      if(!friends.list)
      {
        friends.list = new Array();
        friends.list.push(friends);
      }
      
      <portlet:namespace/>fFriends = new Array();
      friends.list.forEach(function(entry)
      {
        <portlet:namespace/>fFriends[entry.id] = true;
      });
      
      
    
      var html = '<div id="<portlet:namespace/>usersDiv"><ul style="list-style-type: none; padding: 0px;">';
        
      //header
      //html += '<tr><td><b>Bild</b></td><td><b>Beschreibung</b></td>'
      //  + '<td><b>Aktionen</b></td></tr>';
      
      var counter = 0;
      <portlet:namespace/>fImages = new Array();
      var preImg;
      
      users.list.forEach(function(entry)
      {
        html += '<li class="<portlet:namespace/>entryLi">';

        //picture
        html += '<div class="<portlet:namespace/>thumbnailDiv">'
          + '<a href="/web/guest/profile?userId=' + entry.id + '" target="_blank">';
        
        var title = entry.id;
        if(entry.name && entry.name.formatted)
        {
        	title = entry.name.formatted;
        }
        
        //dummy thumbnail
        html += '<img id="<portlet:namespace/>thumbnailImg' + counter + '" width="100%" '
          + 'src="<%=request.getContextPath()%>/images/profile_picture_placeholder.png" '
          + 'alt="' + <portlet:namespace/>DUMMY_PIC + '" title="' + title + '" />';
        
        //queue asynchronous loading if the user set an actual thumbnail URL
        if(entry.thumbnailUrl)
        {
          //start loading in background
          preImg = new Image();
          preImg.src = entry.thumbnailUrl;
          
          //keep in memory
          <portlet:namespace/>fImages.push(preImg);
          
          //hidden image that will trigger swapping once loaded
          html += '<img src="' + entry.thumbnailUrl
          + '" onload="<portlet:namespace/>thumbLoaded(\'<portlet:namespace/>thumbnailImg' + counter + '\','
          + '\'' + entry.thumbnailUrl + '\',\'' + <portlet:namespace/>PROFILE_PIC + '\')" '
          + ' style="display: none;" />';
        }
            
        ++counter;
        
        html += '</a>';

        // isFriend sticker:
        if(entry.id != <portlet:namespace/>USER_ID && <portlet:namespace/>fFriends[entry.id]) {
          html += '<span class="sticker sticker-circle sticker-sm sticker-primary sticker-outside sticker-right sticker-bottom"'
                  + ' title="<liferay-ui:message key="userdirectory-friend" />" data-toggle="tooltip" data-placement="top">'
                    + '<i class="icon-link"></i>'
                + '</span>';
        }

        html += '</div>';
        
        //information div
        html += '<div class="<portlet:namespace/>infoDiv">';
        
        var name = entry.id;
        if(entry.name && entry.name.formatted)
        {
        	name = entry.name.formatted;
        }
        
        //name with profile link
        html += '<h4><strong><a href="/web/guest/profile?userId=' + entry.id + '">' + name + '</a></strong></h4>';
          
        //position in primary organization
        var primary;
        if(entry.organizations)
        {
          entry.organizations.forEach(function(entry)
          {
            if(entry.primary)
            {
              primary = entry;
            }
          });
    
          //take first if there is no primary organization
          if(!primary && entry.organizations.length > 0)
          {
            primary = entry.organizations[0];
          }
        }
        if(primary)
        {
          if(primary.title)
          {
            html += '<p>' + primary.title + '</p>';
          }
      
          if(primary.department) {
//            html += '<p>' + <portlet:namespace/>DEPARTMENT + ': ' + primary.department + '</p>';
              html += '<p>' + primary.department;
              if(primary.site)
                html += ', ' + primary.site;
              html += '</p>';
          } else if(primary.site) {
              html += '<p>' + primary.site + '</p>';
          }
        }
          
        //E-Mails
        if(entry.emails)
        {
          entry.emails.forEach(function(entry)
          {
            html += '<p><i class="icon-envelope"></i> ';

            if(entry.primary)
              html += '<strong>';
      
            html += '<a href="mailto:' + entry.value + '">' + entry.value + '</a>';
        
            if(entry.primary)
              html += '</strong>';

            if(entry.type)
              html += ' (' + entry.type + ')';
          });
        }
        
        //phone numbers
        if(entry.phoneNumbers)
        {
          var length = entry.phoneNumbers.length - 1;
          var index = 0;
          
          html += '<p><i class="icon-phone"></i> ';
          
          entry.phoneNumbers.forEach(function(entry)
          {
            if(entry.primary)
              html += '<strong>';
      
            html += entry.value;
        
            if(entry.primary)
              html += '</strong>';

            if(entry.type)
              html += ' (' + entry.type + ')';
        
            if(index++ < length)
            {
              html += ', ';
            }
          });
          html += '</p>';
        }
        
        /*
        //tags
        if(entry.tags)
        {
          var length = entry.tags.length - 1;
          var index = 0;
        
          html += '<span class="label label-sm label-default">Tags</span>: ';
          entry.tags.forEach(function(tag)
          {
            html += tag;
          
            if(index++ < length)
            {
              html += ', ';
            }
          });
        }
        */
        
        html += '</div>';
        
        //controls
        html += '<div class="<portlet:namespace/>actionsDiv">';
        if(!<portlet:namespace/>fFriends[entry.id])
        {
          html += '<a class="btn btn-primary btn-sm" href="#"  onclick="<portlet:namespace/>addFriend(\''
                + entry.id + '\')" title="' + <portlet:namespace/>ADD_FRIEND + '" data-toggle="tooltip" data-placement="left">'
                  + '<i class="icon-link"></i>'
              + '</a>';
        }
        
        if(entry.id != <portlet:namespace/>USER_ID)
        {
          html += '<br />'
              + '<a class="btn btn-primary btn-sm" href="#"  onclick="" title="' + <portlet:namespace/>SEND_MESSAGE 
                + '">'
                  + '<i class="icon-comment"></i>'
              + '</a>';
        }
        
        html += '</div></li>';
      });
      
      html += '</ul></div>';
      
      html += '<div id="<portlet:namespace/>controls">';
        
      if(<portlet:namespace/>fFirst > 0)
      {
        html += '<input type="button" value="'
          + '<liferay-ui:message key="userdirectory-back" />' + '" onclick="<portlet:namespace/>back()"/>';
      }
      
      var to = <portlet:namespace/>fFirst + <portlet:namespace/>fMax;
      if(to > users.totalResults)
        to = users.totalResults;

      html += ' ' + (<portlet:namespace/>fFirst + 1) + ' ' + '<liferay-ui:message key="userdirectory-to" />'
        + ' ' + to + ' ' + '<liferay-ui:message key="userdirectory-of" />' + ' ' + users.totalResults + ' ';
        
      if(users.totalResults > <portlet:namespace/>fFirst + <portlet:namespace/>fMax)
      {
        html += '<input type="button" value="'
          + '<liferay-ui:message key="userdirectory-more" />' + '" onclick="<portlet:namespace/>more()"/>';
      }
      
      html += '</div>';
      
      document.getElementById('<portlet:namespace/>body').innerHTML = html;

      $('[data-toggle="tooltip"]').tooltip();
    }
    else
    {
      //alert('Shindig User Directory Portlet: no data received');

	  document.getElementById('<portlet:namespace/>errorSpan').innerHTML = 'no data received';
	  document.getElementById('<portlet:namespace/>errorSpan').style.display = 'flex';
    }
  }
  
  function <portlet:namespace/>getLabel(key)
  {
    //TODO: configurable alternative
    var name = <portlet:namespace/>fTypeLabels[key];
    var icon = <portlet:namespace/>fTypeIcons[key];
    
    if(!name)
    {
    	name = key;
    }
    
    var label = '(' + name + ')';
    
    if(icon)
    {
      label = '<img width="16" src="' + icon + '" alt="' + name
      	+ '" style="vertical-align: middle;" title="' + name
      	+ '" />';
    }
    
    return label + '&nbsp;';
  }
  
  function <portlet:namespace/>thumbLoaded(elementId, url, alt)
  {
	  var image = document.getElementById(elementId);
	  image.src = url;
	  image.alt = alt;
  }
  
  function <portlet:namespace/>checkEnter(event)
  {
    if (event.keyCode == 13)
    {
      <portlet:namespace/>reset();
    }
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
    
  	//send request
  	<portlet:namespace/>sendRequest('POST', url, <portlet:namespace/>requestSent, person);
  }
  
  function <portlet:namespace/>requestSent(data)
  {
    if(!data)
    {
      //alert('Shindig User Directory Portlet: no data received');

	  document.getElementById('<portlet:namespace/>errorSpan').innerHTML = 'no data received';
	  document.getElementById('<portlet:namespace/>errorSpan').style.display = 'flex';
    }
    else
    {
      //alert('<liferay-ui:message key="userdirectory-request-sent" />');

	  document.getElementById('<portlet:namespace/>successSpan').innerHTML = '<liferay-ui:message key="userdirectory-request-sent" />';
	  document.getElementById('<portlet:namespace/>successSpan').style.display = 'flex';
    }
  }
  
  function <portlet:namespace/>init()
  {
	var html = '';
    
    //hide controls if parameters are supplied through url parameters
    var searchField = '<%= searchFieldParam %>';
    var searchValue = '<%= searchValueParam %>';
    
    if(searchValue == 'null')
    {
    	searchValue = '';
    }
    if(searchField == 'null')
    {
    	searchField = 'ALL';
    }
    
    var wikiLinkDetection = '<%= GetterUtil.getString(portletPreferences.getValue("wikiLinkDetection", StringPool.FALSE)) %>';
    var showSearch = '<%= GetterUtil.getString(portletPreferences.getValue("showSearch", StringPool.TRUE)) %>';
    var trueVal = '<%= StringPool.TRUE %>';

    //liferay 6 and 7 true/false detection
    if(wikiLinkDetection == trueVal || wikiLinkDetection == 'on')
    {
    	searchField = 'ALL';
    	searchValue = '<%= hashtag %>';
    }

    //liferay 6 and 7 true/false detection
    if(showSearch != trueVal && showSearch != 'on')
    {
        //TODO: maybe only hide controls
        document.getElementById('<portlet:namespace/>searchDiv').style.display = 'none';
    	html += '<input type="hidden" id="<portlet:namespace/>searchField"'
    		+ 'value="' + searchValue + '"/>';
    	html += '<input type="hidden" id="<portlet:namespace/>searchSel"'
    		+ 'value="' + searchField + '"/>';
        html += '<input type="hidden" id="<portlet:namespace/>maxField"'
        	+ 'value="' + <portlet:namespace/>fMax + '"/>';
    }
    else
    {
//         html += '<div id="<portlet:namespace/>preSearchDiv">'
//          + '<liferay-ui:message key="userdirectory-search" />' + ':&nbsp;</div>';

        html += '<div class="row">'
            // search fields:
            + '<div class="col-sm-9">'
              + '<div class="form-group">'
                + '<label><liferay-ui:message key="userdirectory-search-fields" /></label>'
                + '<select class="form-control" id="<portlet:namespace/>searchSel">'
        html += '<option value="ALL" selected>'
          + '<liferay-ui:message key="userdirectory-search-all" />' + '</option>';
        html += '<option value="NAMES">'
          + '<liferay-ui:message key="userdirectory-search-names" />' + '</option>';
        html += '<option value="TAGS">'
          + '<liferay-ui:message key="userdirectory-search-tags" />' + '</option>';
        html += '<option value="SKILLS">'
            + '<liferay-ui:message key="userdirectory-search-skills" />' + '</option>';
        html += '</select>'
              + '</div>' // END .form-group
            + '</div>' // END .col-sm-9
            // per Page:
            + '<div class="col-sm-3">'
              + '<div class="form-group">'
                + '<label><liferay-ui:message key="userdirectory-per-page" /></label>'
                + '<input class="form-control" type="text" id="<portlet:namespace/>maxField" value="'
                  + <portlet:namespace/>fMax + '" style="text-align: right;" />'
              + '</div>'
            + '</div>'
          + '</div>'; // END .row

        html += '<div class="form-group">'
            + '<div class="input-group">'
              + '<input class="form-control" type="text" id="<portlet:namespace/>searchField"'
                + ' onkeypress="<portlet:namespace/>checkEnter(event)" placeholder="'
                + '<liferay-ui:message key="userdirectory-search-term" />' + '" value="' + searchValue + '" />'
              + '<span class="input-group-btn">'
                + '<button type="button" class="btn btn-default" onclick="<portlet:namespace/>reset()" >'
                  + '<i class="icon-search"></i>'
                + '</button>'
              + '</span>'
            + '</div>'
          + '</div>';
    }
    
    document.getElementById('<portlet:namespace/>searchDiv').innerHTML = html;
  
    <portlet:namespace/>getUsers();
  }
  
  <portlet:namespace/>init();
</script>
