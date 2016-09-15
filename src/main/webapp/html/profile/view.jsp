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
token.put("i", "shindig-profile-portlet");

//viewer
token.put("v", userName);

String tokenString = new BasicBlobCrypter(new File(PortletProps.get("token_secret"))).wrap(token);
String shindigToken = "default:" + tokenString;

HttpServletRequest httpRequest = PortalUtil.getOriginalServletRequest(
	PortalUtil.getHttpServletRequest(renderRequest)); 
String userParam = httpRequest.getParameter("userId");
%>

<style type="text/css">
  #<portlet:namespace/>debugSel {
    display: flex;
  }
  #<portlet:namespace/>greenStatus {
    background-color: #00FF00;
  }
  #<portlet:namespace/>redStatus {
    background-color: #FF0000;
  }
  #<portlet:namespace/>orangeStatus {
    background-color: #FFA500;
  }
  #<portlet:namespace/>yellowStatus {
    background-color: #FFFF00;
  }
  #<portlet:namespace/>blueStatus {
    background-color: #0000FF;
  }
  #<portlet:namespace/>magentaStatus {
    background-color: #FF00FF;
  }
  #<portlet:namespace/>blackStatus {
    background-color: #000000;
  }
  
  .<portlet:namespace/>leftFloat {
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

  .<portlet:namespace/>statusSpan {
    display: flex;
    text-align: center;
    margin-top: 10px;
  }

  .<portlet:namespace/>skillConfirmButton {
    margin-left: 5px;
    margin-right: 2px;
  }

  .<portlet:namespace/>skillThumbnail {
    height: 28px !important;
    border-radius: 50%;
    overflow: hidden;
    padding: 2px 0;
    margin-left: 3px;
  }
  
  
  .clearfix:after {
    content: ".";
    clear: both;
    display: block;
    visibility: hidden;
    height: 0px;
  }

  .badge {
    padding-top: 4px; padding-bottom: 4px;
  }

  .floating-btn {
    width: 32px;
    padding: 4px;
    border-radius: 100%;
    box-shadow: 1px 1px 2px #999;
    font-size: 15px;
  }
  
  body
  {
	display: flex;
    height: auto;
    width: 100%;
    line-height: 2;
    font-family: arial, sans-serif;
  }

  input, button, select, textarea
  {
	  line-height: normal;
  }

  input, button, ortgroup, select, textarea
  {
	  margin: 5px;
  }

  input[type='button']
  {
	  transform: scale(0.8);
	  size: 80%;
  }

  input[type='radio'].form-control {
    max-height: 28px;
    margin-top: 10px;
  }

  textarea.form-control {
    height: auto; min-height: 3.8em;
  }

  .edit-table tr td { padding-bottom: 1em; }

  td > .form-group { margin: 0; }

  .edit-wiki-linked {
    margin-top: 0.5em;
  }
  .edit-wiki-linked .btn-xs {
    margin: 0 5px;
    padding: 1px 7px;
  }

  .ui-autocomplete
  {
	  background-color: white;
	  border-style: solid;
	  border-width: 1px;
  }

  .<portlet:namespace/>colorStatus
  {
	  float: right;
    width: 19.2px; height: 19.2px;
    margin-top: 5px;
  }

  .<portlet:namespace/>colorStatus div
  {
    height: 19.2px;
    border-radius: 19.2px;
    box-shadow: 1px 1px 1px #333;
  }

  #<portlet:namespace/>profileHeader
  {
	 width: 100%;
  }

  #<portlet:namespace/>profileTitle
  {
	  float: left;
      max-width:380px;
      margin:0px 0px 16px 0px;
  }

  #<portlet:namespace/>profileStatus
  {
     text-align: left;
     width: 250px;
     float: right;
     margin-top: 6px;
     margin-right: 5px;
  }

  #<portlet:namespace/>profilePic
  {
     float: left;
     clear: left;
     width: 24%;
     margin-right:1%;
     margin-bottom: 1em;
  }

  .<portlet:namespace/>profileTable td {
      width: 100%;
  }
  .<portlet:namespace/>profileTable td:nth-child(1) {
      width: auto;
      padding-right: 1em;
  }
  

  #<portlet:namespace/>profile1
  {
	  float: left;
    width: 75%;
  }

  #<portlet:namespace/>profile2, #<portlet:namespace/>skillProfile
  {
      width: 100%;
      clear: both;
      margin-top: 1em;
  }

  #<portlet:namespace/>editDiv
  {
    margin-top: 2em;
    float: right;
  }

  .<portlet:namespace/>skill, .<portlet:namespace/>skillRemoveButton, .<portlet:namespace/>skillAdd
  {
	 margin-left: 5px;
  }
</style>


<div id="<portlet:namespace/>debugSel"> </div>
<div id="<portlet:namespace/>body"> </div>
<div id="<portlet:namespace/>editDiv"> </div>
<div style="clear:both;"></div>
<div id="<portlet:namespace/>successSpan" class="portlet-msg-success" style="display:none;"></div>
<div id="<portlet:namespace/>errorSpan" class="portlet-msg-error" style="display:none;"></div>

<!--script src="<%=request.getContextPath()%>/js/jquery-1.11.3.min.js" type="text/javascript"></script-->
<!--script src="<%=request.getContextPath()%>/js/jquery-ui-1.11.4.min.js" type="text/javascript"></script-->

<script type="text/javascript">
  var <portlet:namespace/>SHINDIG_URL = '<%= PortletProps.get("shindig_url") %>';
  var <portlet:namespace/>SKILL_WIKI_URL = '<%= PortletProps.get("skill_wiki_url") %>';
  var <portlet:namespace/>PEOPLE_FRAG = "social/rest/people/";
  var <portlet:namespace/>ACTIVITY_FRAG = "social/rest/activitystreams/";
  var <portlet:namespace/>SKILLS_FRAG = "social/rest/skills/";
  var <portlet:namespace/>SKILLS_AUTOCOMPLETE_FRAG = "social/rest/autocomplete/skills";

  var <portlet:namespace/>USER_ID = '<%= userName %>';
  var <portlet:namespace/>SHINDIG_TOKEN = '<%= shindigToken %>';
  
  var <portlet:namespace/>BUSINESS = '<liferay-ui:message key="profile-business" />';
  var <portlet:namespace/>PRIVATE = '<liferay-ui:message key="profile-private" />';
  var <portlet:namespace/>GENERAL = '<liferay-ui:message key="profile-general" />';
  var <portlet:namespace/>MOBILE = '<liferay-ui:message key="profile-mobile" />';
  
  var <portlet:namespace/>ENTER_EMAIL = '<liferay-ui:message key="profile-enter-email" />';
  var <portlet:namespace/>ENTER_PHONE = '<liferay-ui:message key="profile-enter-phone" />';
  var <portlet:namespace/>ENTER_LANGUAGE = '<liferay-ui:message key="profile-enter-language" />';
  var <portlet:namespace/>ENTER_COMPETENCE = '<liferay-ui:message key="profile-enter-competence" />';
  var <portlet:namespace/>ENTER_INTEREST = '<liferay-ui:message key="profile-enter-interest" />';
  var <portlet:namespace/>ENTER_TAG = '<liferay-ui:message key="profile-enter-tag" />';
  
  var <portlet:namespace/>fStatusColors = {"ONLINE": "<portlet:namespace/>greenStatus",
	"OFFLINE": "<portlet:namespace/>redStatus", "AWAY": "<portlet:namespace/>yellowStatus",
	"XA": "<portlet:namespace/>orangeStatus", "DND": "<portlet:namespace/>magentaStatus",
  	"CHAT": "<portlet:namespace/>blueStatus"};
  	
  var <portlet:namespace/>fStatusNames = {"ONLINE": "Online", "OFFLINE": "Offline",
  	"AWAY": "Away", "XA": "Extended Away", "DND": "Do Not Disturb",
  	"CHAT": "Chat"};
  	
  var <portlet:namespace/>fTypeIcons = {
    "geschäftlich": "<%=request.getContextPath()%>/images/icon-business_address.png",
  	"allgemein": "<%=request.getContextPath()%>/images/mini_circle.png",
  	"privat": "<%=request.getContextPath()%>/images/toolbar_home.png",
  	"mobil": "<%=request.getContextPath()%>/images/mobile_phone.png"};
  
  var <portlet:namespace/>fTypeLabels = {"geschäftlich": <portlet:namespace/>BUSINESS,
	"allgemein": <portlet:namespace/>GENERAL, "privat": <portlet:namespace/>PRIVATE,
	"mobil": <portlet:namespace/>MOBILE};
  
  var <portlet:namespace/>fDebug = false;
  
  var <portlet:namespace/>fMonthNames = ['<liferay-ui:message key="profile-january" />',
    '<liferay-ui:message key="profile-february" />', '<liferay-ui:message key="profile-march" />',
    '<liferay-ui:message key="profile-april" />', '<liferay-ui:message key="profile-may" />',
    '<liferay-ui:message key="profile-june" />', '<liferay-ui:message key="profile-july" />',
    '<liferay-ui:message key="profile-august" />', '<liferay-ui:message key="profile-september" />',
    '<liferay-ui:message key="profile-october" />' ,'<liferay-ui:message key="profile-november" />',
    '<liferay-ui:message key="profile-december" />'];
    
  var <portlet:namespace/>fIsEditable;
  var <portlet:namespace/>fIsFriend;
  
  var <portlet:namespace/>fLastResult;
  
  var <portlet:namespace/>fPreImg;
  
  var <portlet:namespace/>fMails;
  var <portlet:namespace/>fPhones;
  
  //for generic list editing functions
  var <portlet:namespace/>fCurrentTitle;
  var <portlet:namespace/>fCurrentList;
  
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
			  alert('Shindig Profile Portlet:\n'
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

  function <portlet:namespace/>getProfile()
  {
    //var id = document.getElementById('eid').value;
    
    //var params = {"userId": id, "fields":
    //  "id,name,gender,birthday,displayName,age,emails,phoneNumbers,thumbnailUrl,languagesSpoken,activities,interests,aboutMe,status,networkPresence,tags,organizations"};
    
    //osapi.people.get(params).execute(<portlet:namespace/>update);
    
    var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>PEOPLE_FRAG
    	+ document.getElementById('<portlet:namespace/>eid').value;
    url += '/@self';
    url += '?fields=id,name,gender,birthday,displayName,age,emails,phoneNumbers,'
    		+ 'thumbnailUrl,languagesSpoken,activities,interests,aboutMe,status,'
    		+ 'networkPresence,tags,organizations';
    
    if(<portlet:namespace/>SHINDIG_TOKEN != null)
    {
  	  url += '&st=' + <portlet:namespace/>SHINDIG_TOKEN;
    }
    
  	//send request
    <portlet:namespace/>sendRequest('GET', url, <portlet:namespace/>update);
  }
  
  function <portlet:namespace/>displayDate(time)
  {
    var date = new Date(time);
  
    var display = date.getDate();
    if(display < 10)
    {
      display = '0' + display;
    }
    display += '. ';
    
    display += <portlet:namespace/>fMonthNames[date.getMonth()];
    
    return display;
  }

  function <portlet:namespace/>update(data)
  {
    if(data.entry)
    {
      <portlet:namespace/>fLastResult = data.entry;
      
      if(data.entry.isViewer
        || data.entry.id == <portlet:namespace/>USER_ID)
      {
        <portlet:namespace/>fIsEditable = true;
      
        <portlet:namespace/>getSkills();
      }
      else
      {
        <portlet:namespace/>fIsEditable = false;
        
        //bogus ID set to trigger filtering mechanism in back-end
        //var idSet = new Array();
        //idSet.push(data.id);
        //idSet.push('@me');
        
        //determine if the viewer is already friends with this person
        //var params = {"userId": idSet, "groupId": "@self", "fields":
        //  "id", "sortBy": "id", "sortOrder": "descending", "count": 2,
        //  "filterBy" : "isFriendsWith", "filterValue": "@me"};
        
        //osapi.people.get(params).execute(<portlet:namespace/>checkFriendship);
        
        
      	//create REST URL
        var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>PEOPLE_FRAG
        	+ data.entry.id
        	+ ',' + <portlet:namespace/>USER_ID
        	+ '/@self?fields=id'
            + '&sortBy=id&sortOrder=descending'
        	+ '&count=2'
        	+ '&filterBy=isFriendsWith&filterValue=' + <portlet:namespace/>USER_ID;
        
        if(<portlet:namespace/>SHINDIG_TOKEN != null)
        {
      	  url += '&st=' + <portlet:namespace/>SHINDIG_TOKEN;
        }
        
      	//send request
        <portlet:namespace/>sendRequest('GET', url, <portlet:namespace/>checkFriendship);
      }
    }
    else
    {
      //alert('Shindig Profile Portlet: no data received');

	  document.getElementById('<portlet:namespace/>errorSpan').innerHTML = 'no data received';
	  document.getElementById('<portlet:namespace/>errorSpan').style.display = 'flex';
    }
  }
  
  function <portlet:namespace/>checkFriendship(data)
  {
    if(data)
    {
      //both are returned if they're friends
      if(data.list && data.list.length == 2)
      {
        <portlet:namespace/>fIsFriend = true;
      }
      else
      {
        <portlet:namespace/>fIsFriend = false;
      }
      
      <portlet:namespace/>getSkills();
    }
    else
    {
      //alert('Shindig Profile Portlet: no data received');

	  document.getElementById('<portlet:namespace/>errorSpan').innerHTML = 'no data received';
	  document.getElementById('<portlet:namespace/>errorSpan').style.display = 'flex';
    }
  }
  
  // Requests the skills for the displayed user and calls displayProfile right after skills have been loaded
  function <portlet:namespace/>getSkills()
  {
	  var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>SKILLS_FRAG + 
	    document.getElementById('<portlet:namespace/>eid').value;
	  url += <portlet:namespace/>SHINDIG_TOKEN ? '?st=' + <portlet:namespace/>SHINDIG_TOKEN : '';

	  // Writes the requested skills to the LastResult
    <portlet:namespace/>sendRequest('GET', url, function(data) {
    	<portlet:namespace/>fLastResult.skills = data.list;
    	<portlet:namespace/>displayProfile();
    });
  }
  
  
  function <portlet:namespace/>displayProfile()
  {
    var html = '<div id="<portlet:namespace/>profileDiv" class="clearfix">';
  
//    html += <portlet:namespace/>displayHeader();
    
    html += <portlet:namespace/>displayUpperProfile();

    html += <portlet:namespace/>displayStatusMessage();
    
    html += <portlet:namespace/>displaySkillProfile();
    
    html += <portlet:namespace/>displayLowerProfile();
    
    html += '</div>';

    document.getElementById('<portlet:namespace/>body').innerHTML = html;
    
    // Applies the autocomplete functionality to the skill textbox right after it has been pushed to DOM
    <portlet:namespace/>applySkillAutocomplete();
    
    if(<portlet:namespace/>fIsEditable)
    {
      /*
      html = '<input type="button" value="' + '<liferay-ui:message key="profile-reset" />'
        + '" onclick="<portlet:namespace/>getProfile()"/>';
      html += '<input type="button" value="' + '<liferay-ui:message key="profile-save" />'
        + '" onclick="<portlet:namespace/>save()"/>';
        */
      html = '<button class="btn btn-default" type="button" onclick="<portlet:namespace/>getProfile();">'
            + '<liferay-ui:message key="profile-reset" />'
          + '</button>'
          + '<button class="btn btn-primary" type="button" onclick="<portlet:namespace/>save();">'
            + '<liferay-ui:message key="profile-save" />'
          + '</button>';
      document.getElementById('<portlet:namespace/>editDiv').innerHTML = html;
    }
    else
    {
//      document.getElementById('<portlet:namespace/>editDiv').innerHTML = '';
        $('#'+'<portlet:namespace/>editDiv').empty().css('margin', '0');
    }

    <portlet:namespace/>loadTooltips();
  }

  function <portlet:namespace/>loadTooltips()
  {
    $('[data-toggle="tooltip"]').tooltip();
  }
  
  function <portlet:namespace/>displayHeader()
  {
    var html = '<div id="<portlet:namespace/>profileHeader">';
  
    //name
    if(<portlet:namespace/>fLastResult.displayName)
    {
      html += '<h1 id="<portlet:namespace/>profileTitle">' + <portlet:namespace/>fLastResult.displayName + '</h1>';
    }
    else
    {
      html += '<h1 id="<portlet:namespace/>profileTitle">' + <portlet:namespace/>fLastResult.name.formatted + '</h1>';
    }
    
    //status
    html += '<div id="<portlet:namespace/>profileStatus">';
    if(<portlet:namespace/>fIsEditable)
    {
      var value = 'NULL',
          displayValue = '';
    
      if(<portlet:namespace/>fLastResult.networkPresence)
      {
        value = <portlet:namespace/>fLastResult.networkPresence.value;
        displayValue = <portlet:namespace/>fLastResult.networkPresence.displayValue;
      }
      
      html += <portlet:namespace/>getStatusSelector(value)
      html += <portlet:namespace/>displayStatusColor(value, displayValue);
    }
    else
    {
      if(<portlet:namespace/>fLastResult.networkPresence)
      {
        var value = <portlet:namespace/>fLastResult.networkPresence.value,
            displayValue = <portlet:namespace/>fLastResult.networkPresence.displayValue;
        
//        html += 'Status: ' + <portlet:namespace/>fLastResult.networkPresence.displayValue + ' ';
    
        html += <portlet:namespace/>displayStatusColor(value, displayValue);
      }
      else
      {
//        html += 'Status: Unknown ';
    
        html += <portlet:namespace/>displayStatusColor('NULL', 'Unknown');
      }
    }
    
    html += '</div></div>';
  
    return html;
  }
  
  function <portlet:namespace/>getStatusSelector(value)
  {
    var html = '<liferay-ui:message key="profile-status" />' +': <select id="<portlet:namespace/>netPresField" '
      + 'onChange="<portlet:namespace/>updateNetPres()">';
    
    var selected = false;
    
   	for(var key in <portlet:namespace/>fStatusNames)
   	{
   		if(<portlet:namespace/>fStatusNames.hasOwnProperty(key))
   		{
			html += '<option value="' + key + '"';
			
			//pre-select the right element
			if(key == value)
			{
				selected = true;
				html += ' selected';
			}
			
			html += '>' + <portlet:namespace/>fStatusNames[key] + '</option>';
		}
	}
    
    html += '<option value="NULL"';
    
    if(!selected)
    {
    	html += ' selected';
    }
    
    html += '>Unknown</option></select>';
    
    return html;
  }
  
  function <portlet:namespace/>displayStatusColor(value, displayValue)
  {
    var html = '<div class="<portlet:namespace/>colorStatus" id="<portlet:namespace/>colorFrame"'
        + 'data-toggle="tooltip" data-placement="top" title="Status: ' + displayValue + '">';
    
    value = <portlet:namespace/>fStatusColors[value];
  	
  	if(!value)
  	{
  		value = '<portlet:namespace/>blackStatus';
  	}
  	
    html += '<div id="' + value + '">&nbsp;</div></div>';
    
    return html;
  }
  
  function <portlet:namespace/>displayUpperProfile()
  {
    var html = '';

    //picture below name
    //dummy placeholder image
    html += '<img id="<portlet:namespace/>profilePic" '
      + 'src="<%=request.getContextPath()%>/images/profile_picture_placeholder.png" '
      + 'alt="<liferay-ui:message key="profile-pic" /> (dummy)" />';
    
    //queue asynchronous loading if the user set an actual thumbnail URL
    if(<portlet:namespace/>fLastResult.thumbnailUrl)
    {
      //start loading in background
      <portlet:namespace/>fPreImg = new Image();
      <portlet:namespace/>fPreImg.src = <portlet:namespace/>fLastResult.thumbnailUrl;
      
      //hidden image that will trigger swapping once loaded
      html += '<img src="' + <portlet:namespace/>fLastResult.thumbnailUrl
      + '" onload="<portlet:namespace/>thumbLoaded(\'<portlet:namespace/>profilePic\','
      + '\'' + <portlet:namespace/>fLastResult.thumbnailUrl + '\',\''
      + '<liferay-ui:message key="profile-pic" />\')" style="display: none;" />';
    }

    html += <portlet:namespace/>displayHeader();
    
    // html += '</div>';
    
    //information next to picture
    html += '<div id="<portlet:namespace/>profile1">';
    if(!<portlet:namespace/>fIsEditable)
      html += '<table width="100%" id="<portlet:namespace/>profileTable1" class="<portlet:namespace/>profileTable">';
    
    // Display name (hidden when not editable)
    html += <portlet:namespace/>displaySingleTextValueField(
    			 '<portlet:namespace/>dispNameField',
    			'<liferay-ui:message key="profile-display-name" />',
    			<portlet:namespace/>fLastResult.displayName,
    			'<liferay-ui:message key="profile-enter-display-name" />',
    			true);
    
    if(<portlet:namespace/>fIsEditable) {
      html += '<div class="row">'
          + '<div class="col-sm-6">';
    }

    // First name (hidden when not editable)
    html += <portlet:namespace/>displaySingleTextValueField(
    			'<portlet:namespace/>givNameField',
    			'<liferay-ui:message key="profile-first-name" />',
    			<portlet:namespace/>fLastResult.name && <portlet:namespace/>fLastResult.name.givenName ? 
    					<portlet:namespace/>fLastResult.name.givenName : '',
    			'<liferay-ui:message key="profile-enter-first-name" />',
    			true);

    if(<portlet:namespace/>fIsEditable) {
      html += '</div>'
          + '<div class="col-sm-6">';
    }

    // Family name (hidden when not editable)
    html += <portlet:namespace/>displaySingleTextValueField(
    			'<portlet:namespace/>famNameField',
    			'<liferay-ui:message key="profile-last-name" />',
    			<portlet:namespace/>fLastResult.name && <portlet:namespace/>fLastResult.name.familyName ?
    					<portlet:namespace/>fLastResult.name.familyName : '',
    			'<liferay-ui:message key="profile-enter-last-name" />',
    			true);

    if(<portlet:namespace/>fIsEditable) {
      html += '</div>'
        + '</div>'; // END .row
    }

    if(<portlet:namespace/>fIsEditable)
      html += '</div>'; // #profile1

    //E-Mails
    html += <portlet:namespace/>displayEmails();
    
    //Phone numbers
    html += <portlet:namespace/>displayPhones();

    if(<portlet:namespace/>fIsEditable) {
      html += '<table width="100%" id="<portlet:namespace/>profileTable1" class="<portlet:namespace/>profileTable">';
    }
    
    if(<portlet:namespace/>fLastResult.gender)
    {
      html += '<tr><td><label>' + '<liferay-ui:message key="profile-gender" />' + ':</label></td><td>';
      if(<portlet:namespace/>fLastResult.gender == 'male')
      {
        html += '<liferay-ui:message key="profile-male" />';
      }
      else
      {
        html += '<liferay-ui:message key="profile-female" />';
      }
      html += '</td></tr>';
    }
    
    if(<portlet:namespace/>fLastResult.birthday)
    {
      html += '<tr><td><label>' + '<liferay-ui:message key="profile-birthday" />' + ':</label></td><td>'
        + <portlet:namespace/>displayDate(<portlet:namespace/>fLastResult.birthday) + '</td></tr>';
    }
    if(<portlet:namespace/>fLastResult.age)
    {
      html += '<tr><td><label>' + '<liferay-ui:message key="profile-age" />' + ':</label></td><td>'
        + <portlet:namespace/>fLastResult.age + '</td></tr>';
    }
    html += '<tr><td><label>' + '<liferay-ui:message key="profile-username" />' + ':</label></td><td>'
      + <portlet:namespace/>fLastResult.id + '</td></tr>';
    
    
    //organization(s)
    if(<portlet:namespace/>fLastResult.organizations)
    {
      html += <portlet:namespace/>displayOrganizations();
    }
    
    html += '</table>';

    if(!<portlet:namespace/>fIsEditable)
      html += '</div>'; // #profile1
    
    return html;
  }
  
  function <portlet:namespace/>thumbLoaded(elementId, url, alt)
  {
	  var image = document.getElementById(elementId);
	  image.src = url;
	  image.alt = alt;
  }
  
  // Renders a row to enter/display a single text field value
  function <portlet:namespace/>displaySingleTextValueField(elementId, labelText, fieldValue, placeholderText, hideIfReadOnly)
  {
    var html = '';
    if(<portlet:namespace/>fIsEditable)
    {
      html += '<div class="form-group">'
          + '<label for="' + elementId + '">' + labelText + ':</label>'
          + '<input class="form-control" id="' + elementId + '" type="text" value="' + (fieldValue ? fieldValue : '') + '"'
            + ' placeholder="' + (placeholderText ? placeholderText : '') + '" />'
        + '</div>';
    }
    else if (hideIfReadOnly !== true)
    {
      // The value as read only text
      html += '<tr><td style="padding-right: 1em;">' + labelText + ':</td><td style="width: 100%;">' + fieldValue + '</td></tr>';
    }
    
    return html;
  }
  
  // Renders a row to enter/display a field with multiple text values
  function <portlet:namespace/>displayMultiTextValueField(elementId, labelText, fieldValueArray, placeholderText, 
		  addFunctionName, removeFunctionName, wikiLinked)
  {
    // Renders label
    var html = '<tr><td><label>' + labelText + ':</label></td><td>';
    
    var skillWikiBaseUrl = <portlet:namespace/>SKILL_WIKI_URL;
    skillWikiBaseUrl = skillWikiBaseUrl ? (skillWikiBaseUrl.replace(/\/$/, '') + '/') : null;

    if(fieldValueArray)
    {
      if(!<portlet:namespace/>fIsEditable && fieldValueArray.length < 1)
        return '';


  	  fieldValueArray.forEach(function(entry, index)
      {
  		// Renders input textbox and remove button if profile is editable for simple entries
  		if (<portlet:namespace/>fIsEditable
  			&& (wikiLinked != true || entry == ''))
  	    {
  	 	  // Renders input textbox with current value
  	      html += '<div class="<portlet:namespace/>leftFloat form-group" style="max-width: 15em;">'
                + '<div class="input-group">'
  	             + '<input class="form-control" type="text" size="40" id="' + elementId + index + '" '
  	             + 'value="' + entry + '" placeholder="' + (placeholderText ? placeholderText : '') + '"/>'
                 + '<span class="input-group-btn">'
  	               + '<button class="btn btn-default" type="button" onclick="' + removeFunctionName + '('+ index + ')">'
                    + '<i class="icon-remove"></i>'
                   + '</button>'
                 + '</span>'
                + '</div>'
  	          + '</div>';
        }
  		else if(wikiLinked)
  		{
  		  // renders the entries as clickable wiki links
  	      html += '<div class="<portlet:namespace/>leftFloat';
          if(<portlet:namespace/>fIsEditable)
            html += ' edit-wiki-linked';
          html += '">';
  	      
  	      html += '<a href="' + skillWikiBaseUrl + encodeURIComponent(entry).replace(/%20/g, '+')
  	      	+ '">' + entry + '</a>';
  		  
  		  // button to remove, if editable
  		  if(<portlet:namespace/>fIsEditable)
  		  {
  	  	      html += '<button class="btn btn-default btn-xs" type="button" onclick="' + removeFunctionName + '('+ index + ')"/>'
                    + '<i class="icon-remove"></i>'
                   + '</button>';
  		  }
  		  
  	      html += '&nbsp;&nbsp;</div>';
  		}
	  	// Renders a comma seperated list when the profile is not editable
	  	else
	  	{
	  		html += entry;
	  		if (index < (fieldValueArray.length - 1))
	  	    {
	  			  html += ', ';
	  	    }
  	    }
      });
    } else {
      if(!<portlet:namespace/>fIsEditable)
        return ''; // if no array und profile is not editable, don't show the tr
    }
    
    // Renders add button if the profile is editable
    if (<portlet:namespace/>fIsEditable)
    {
      html += '<div class="<portlet:namespace/>leftFloat">'
//      html += '<input type="button" value="+" onclick="' + addFunctionName + '()"/></div>';
          + '<button class="btn btn-default btn-xs" onclick="' + addFunctionName + '()" style="padding:1px 7px;">'
            + '<i class="icon-plus"></i></button>'
          + '</div>'
    }
    
    html += '</td></tr>';
    return html;
  }
  
  function <portlet:namespace/>displayEmails()
  {
    var html = '';
  
    if(<portlet:namespace/>fIsEditable)
    {
//      html += '<tr><td><label>' + '<liferay-ui:message key="profile-emails" />' + ':</label></td><td>';

      if(<portlet:namespace/>fLastResult.emails)
      {
        var index = 0;
      
        <portlet:namespace/>fLastResult.emails.forEach(function(entry)
        {
          html += '<div class="row" style="clear:both;">'
            + '<div class="col-sm-7"><div class="form-group">'
              + '<label><liferay-ui:message key="profile-emails" /> ' + (index+1) + '</label>'
              + '<div class="input-group">'
                // email input:
                + '<input class="form-control" type="email" placeholder="' + <portlet:namespace/>ENTER_EMAIL + '"'
                  + ' value="' + entry.value + '" id="<portlet:namespace/>emailField' + index + '" />'
                // remove button:
                + '<span class="input-group-btn">'
                  + '<button onclick="<portlet:namespace/>removeMail(' + index + ')" class="btn btn-default">'
                    + '<i class="icon-remove"></i></button>'
                + '</span>'
              + '</div>'
            + '</div></div>' // END .col-sm-7

            + '<div class="col-sm-3">'
              + '<label><liferay-ui:message key="profile-type" /></label>'
              + '<select class="form-control"  id="<portlet:namespace/>emailTypeField' + index + '">';
          // mail type options:
          html += '<option value="geschäftlich"';
          var match = false;
          if(entry.type == 'geschäftlich')
          {
            html += ' selected';
            match = true;
          }
          html += '>' + <portlet:namespace/>BUSINESS + '</option>';
          html += '<option value="allgemein"';
          if(entry.type == 'allgemein')
          {
            html += ' selected';
            match = true;
          }
          html += '>' + <portlet:namespace/>GENERAL + '</option>';
          html += '<option value="privat"';
          if(entry.type == 'privat')
          {
            html += ' selected';
            match = true;
          }
          html += '>' + <portlet:namespace/>PRIVATE + '</option>';
          html += '<option value=""';
          if(!match)
          {
            html += ' selected';
            match = true;
          }
          html += '>-</option></select>'
            + '</div>'; // END .col-sm-3
          
          html += '<div class="col-sm-1">'
              + '<div class="form-group">'
                + '<label><liferay-ui:message key="profile-primary" /></label>'
                + '<input class="form-control" type="radio" name="primaryMail" id="<portlet:namespace/>primaryMail' + index + '"';
                  if(entry.primary)
                  {
                    html += 'checked="checked"';
                  }
                  html += '>'
              + '</div>'
            + '</div>'
          + '</div>'; // END .row
        
          ++index;
        });
      }

      html += '<div class="form-group" id="<portlet:namespace/>newMailDiv">'
          + '<button class="btn btn-default btn-sm" type="button" onclick="<portlet:namespace/>addNewMail()">'
            + '<i class="icon-plus"></i> <i class="icon-envelope-alt"></i>'
          + '</button>'
        + '</div>';
    }
    else if(<portlet:namespace/>fLastResult.emails)
    {
      var length = <portlet:namespace/>fLastResult.emails.length - 1;
      var index = 0;
    
      html += '<tr><td><label>' + '<liferay-ui:message key="profile-emails" />'+ ':</label></td><td>';
      <portlet:namespace/>fLastResult.emails.forEach(function(entry)
      {
        if(entry.primary)
        {
          html += '<b>';
        }
        
        if(entry.type)
        {
          html += <portlet:namespace/>getLabel(entry.type);
        }
      
        html += '<a href="mailto:' + entry.value + '">';
        html += entry.value;
        html += '</a>';
        
        if(entry.primary)
        {
          html += '</b>';
        }
        
        if(index++ < length)
        {
          html += ', ';
        }
      });
      html += '</td></tr>';
    }
    
    return html;
  }
  
  function <portlet:namespace/>displayPhones()
  {
    var html = '';
    
    if(<portlet:namespace/>fIsEditable)
    {
//      html += '<tr><td><label>' + '<liferay-ui:message key="profile-phones" />' + ':</label></td><td>';
      
      if(<portlet:namespace/>fLastResult.phoneNumbers)
      {
        var index = 0;
        
        <portlet:namespace/>fLastResult.phoneNumbers.forEach(function(entry)
        {

          html += '<div class="row">'
            + '<div class="col-sm-7"><div class="form-group">'
              + '<label><liferay-ui:message key="profile-phones" /> ' + (index+1) + '</label>'
              + '<div class="input-group">'
                // email input:
                + '<input class="form-control" type="text" id="<portlet:namespace/>phoneField' + index
                  + '" value="' + entry.value + '" placeholder="' + <portlet:namespace/>ENTER_PHONE + '" />'
                // remove button:
                + '<span class="input-group-btn">'
                  + '<button onclick="<portlet:namespace/>removePhone(' + index + ')" class="btn btn-default">'
                    + '<i class="icon-remove"></i></button>'
                + '</span>'
              + '</div>'
            + '</div></div>' // END .col-sm-7

            + '<div class="col-sm-3">'
              + '<label><liferay-ui:message key="profile-type" /></label>'
              + '<select class="form-control" id="<portlet:namespace/>phoneTypeField' + index + '">';
          // mail type options:
          html += '<option value="geschäftlich"';
          var match = false;
          if(entry.type == 'geschäftlich')
          {
            html += ' selected';
            match = true;
          }
          html += '>' + <portlet:namespace/>BUSINESS + '</option>';
          html += '<option value="allgemein"';
          if(entry.type == 'allgemein')
          {
            html += ' selected';
            match = true;
          }
          html += '>' + <portlet:namespace/>GENERAL + '</option>';
          html += '<option value="privat"';
          if(entry.type == 'privat')
          {
            html += ' selected';
            match = true;
          }
          html += '>' + <portlet:namespace/>PRIVATE + '</option>';
          html += '<option value="mobil"';
          if(entry.type == 'mobil')
          {
            html += ' selected';
            match = true;
          }
          html += '>' + <portlet:namespace/>MOBILE + '</option>';
          html += '<option value=""';
          if(!match)
          {
            html += ' selected';
            match = true;
          }
          html += '>-</option></select>'
            + '</div>'; // END .col-sm-3
          
          html += '<div class="col-sm-1">'
              + '<div class="form-group">'
                + '<label><liferay-ui:message key="profile-primary" /></label>'
                + '<input class="form-control" type="radio" name="primaryPhone" id="<portlet:namespace/>primaryPhone' + index + '"';
                  if(entry.primary)
                  {
                    html += 'checked="checked"';
                  }
                  html += '>'
              + '</div>'
            + '</div>'
          + '</div>'; // END .row
        
          ++index;
        });
      }

      html += '<div class="form-group" id="<portlet:namespace/>newPhoneDiv">'
          + '<button class="btn btn-default btn-sm" type="button" onclick="<portlet:namespace/>addNewPhone()">'
            + '<i class="icon-plus"></i> <i class="icon-phone"></i>'
          + '</button>'
        + '</div>';
    }
    else if(<portlet:namespace/>fLastResult.phoneNumbers)
    {
      var length = <portlet:namespace/>fLastResult.phoneNumbers.length - 1;
      var index = 0;
    
      html += '<tr><td><label>' + '<liferay-ui:message key="profile-phones" />' + ':</label></td><td>';
      <portlet:namespace/>fLastResult.phoneNumbers.forEach(function(entry)
      {
        if(entry.primary)
        {
          html += '<b>';
        }
        
        if(entry.type)
        {
          html += <portlet:namespace/>getLabel(entry.type);
        }
      
        html += entry.value;
        
        if(entry.primary)
        {
          html += '</b>';
        }
        
        if(index++ < length)
        {
          html += ', ';
        }
      });
      html += '</td></tr>';
    }
    
    return html;
  }
  
  function <portlet:namespace/>refreshSkillProfile(message)
  {
	  var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>SKILLS_FRAG + 
	    document.getElementById('<portlet:namespace/>eid').value;
	  url += <portlet:namespace/>SHINDIG_TOKEN ? '?st=' + <portlet:namespace/>SHINDIG_TOKEN : '';

	  // Writes the requested skills to the LastResult
  	  <portlet:namespace/>sendRequest('GET', url, function(data) 
	  {
      	<portlet:namespace/>fLastResult.skills = data.list;

	    // Refreshes the skill area
	    var skillProfileElement = document.getElementById('<portlet:namespace/>skillProfile');
	    skillProfileElement.outerHTML = <portlet:namespace/>displaySkillProfile();
	    
	    // re-add autocompletion
	    <portlet:namespace/>applySkillAutocomplete();
	    
	    //display message if set
	    if(message != null)
	    {
	    	document.getElementById('<portlet:namespace/>successSpan').innerHTML = message;
			document.getElementById('<portlet:namespace/>successSpan').style.display = 'flex';
	    }
	  });
  }
  
  // Renders the row to show and edit the skills of the current user
  function <portlet:namespace/>displaySkillProfile()
  {
    var html = '<div id="<portlet:namespace/>skillProfile"> <h3><liferay-ui:message key="profile-skills" /></h3>'
            + '<div id="<portlet:namespace/>skillProfileTable" class="clearfix">';

    // Ensures a trailing slash in the skill wiki URL 
    var skillWikiBaseUrl = <portlet:namespace/>SKILL_WIKI_URL;
    skillWikiBaseUrl = skillWikiBaseUrl ? (skillWikiBaseUrl.replace(/\/$/, '') + '/') : null;
    
    // Renders currently set skills
    if(<portlet:namespace/>fLastResult.skills)
    {
      <portlet:namespace/>fLastResult.skills.forEach(function(entry, index)
      {
    	  // Builds the URL to the wiki entry for the skill - the spaces are encoded as + by definition
    	  var skillUrl = skillWikiBaseUrl ? skillWikiBaseUrl + encodeURIComponent(entry.name).replace(/%20/g, '+') : '#';
    	  
    	  // Renders the skill link with remove button
  		  html += '<div id="<portlet:namespace/>skill' + index + '" ' + 
  		               'class="<portlet:namespace/>skill <portlet:namespace/>leftFloat badge badge-default">';
  		  html += '<a class="<portlet:namespace/>skillLink" href="' + skillUrl + '">' + entry.name + '</a>';

  		  if(<portlet:namespace/>fIsEditable)
          {
  			  //TODO: confirmation dialog?
  	  		  html += '<img class="<portlet:namespace/>skillRemoveButton" style="cursor: pointer;" ' +
	            'src="<%= request.getContextPath() %>/images/delete_small.png" ' + 
	            'title="<liferay-ui:message key="profile-remove-skill" />" ' +
	            'onclick="<portlet:namespace/>removeSkill(' + index +
	            ', \'<liferay-ui:message key="profile-skill-delete-success" />\')" />';
          }

  		  // TODO: check if the viewer is already among the linkers, show "confirm" otherwise
  		  var confirm = <portlet:namespace/>isAmong('<%= userName %>', entry.people, true);

  		  if(confirm)
  		  {
//  			html += '<img class="<portlet:namespace/>skillConfirmButton" style="cursor: pointer; height: 16px;" ' +
//              'src="<%= request.getContextPath() %>/images/ok.png" ' +
          html += '&nbsp;<i class="icon-ok-sign" style="cursor: pointer; color: #85bd6e; font-size: 1.2em;" ' +
	          'title="<liferay-ui:message key="profile-confirm-skill" />" data-toggle="tooltip" data-placement="top"' +
              ' onclick="<portlet:namespace/>addSkill(\'' + <portlet:namespace/>fLastResult.skills[index].name + '\'' +
            		  ', \'<liferay-ui:message key="profile-skill-confirm-success" />\')"></i>';
  		  }

  		//pictures of linking people if 3 or fewer, number otherwise
  		if(entry.people == null)
  		{
  			html += '&nbsp;(+)';
  		}
  		else if(entry.people.length > 3)
  		{
  			html += '&nbsp;(' + entry.people.length + ')';
  		}
  		else 
  		{
  	  		entry.people.forEach(function(person)
 	  		{
 	  			//valid person's thumbnail or dummy
 	  			var thumbnailUrl = person.thumbnailUrl;
 	  			if(thumbnailUrl == null)
 	  			{
 	  				thumbnailUrl = '<%=request.getContextPath()%>/images/profile_picture_placeholder.png';
 	  			}
 	  			
 	  			html += '<img class="<portlet:namespace/>skillThumbnail" ' +
 	  				'src="' + thumbnailUrl + '" title="' + person.displayName + '" />'
 	  		});
  		}
  		  
  	    html += '</div>';
      });
    }

    // Renders "Add Skill" textbox and button control
    html += '<div id="<portlet:namespace/>skillAdd" style="clear:both; padding-top: 1em;">'
        + '<div class="input-group input-group-sm" style="max-width:15em;">'
          + '<input class="form-control" type="text" id="<portlet:namespace/>skillField"'
            + ' placeholder="<liferay-ui:message key="profile-enter-skill"/>"'
            + ' style="margin:0;" />'
          + '<span class="input-group-btn">'
            + '<button id="<portlet:namespace/>skillAddButton" class="btn btn-default" type="button"'
              + ' onclick="<portlet:namespace/>addNewSkill()"'
              + ' style="margin:0;" />'
                + '<i class="icon-plus"></i>'
            + '</button>'
          + '</span>'
        + '</div>'
      + '</div>';

    html += '</div></div>'; // .clearfix, .skillProfile
    
    return html;
  }
  
  function <portlet:namespace/>isAmong(value, list, invert)
  {
	  var among = false;
	  
	  if(list != null)
      {
		list.forEach(function(entry)
		{
			if(entry.id == value)
			{
				among = true;
			}
		});
		  
		if(invert)
	    {
		  among = !among;
		}
      }
	  
	  return among;
  }

  // Applies the skill autocompletion to the new skill textbox (textbox needs to be pushed to DOM before!)
  function <portlet:namespace/>applySkillAutocomplete()
  {
	  AUI().use('autocomplete-list','aui-base','aui-io-request','autocomplete-filters','autocomplete-highlighters',function (A) {
		   var tempVar;
		   var auto = new A.AutoCompleteList({
		    allowBrowserAutocomplete: false,
		    activateFirstItem: true,
		    inputNode: '#<portlet:namespace/>skillField',
		    minQueryLength: 3,
		    queryDelay: 300,
		    source:function(){
		     var term = A.one("#<portlet:namespace/>skillField").get('value');
		     var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>SKILLS_AUTOCOMPLETE_FRAG + '?fragment=' + term + '&st=' + <portlet:namespace/>SHINDIG_TOKEN;
		     var myAjaxRequest=A.io.request(url,{
		      dataType: 'json',
		      method:'GET',
		      autoLoad:false,
		      sync:true,
		      on: {
		       success:function(){
		        tempVar=this.get('responseData');
		       }
		      }
		     });
		     myAjaxRequest.start();
		     if (tempVar!=null){
		      return tempVar.list;
		     }
		    },
		   });
		   auto.render();
		});
	  
	  
	  //$("#<portlet:namespace/>skillField").autocomplete(
	  //{
	  //  minLength: 3,
	  //  source: function(request, response)
	  //  {
	  //    var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>SKILLS_AUTOCOMPLETE_FRAG + '?fragment=' + request.term;
	  //	url += <portlet:namespace/>SHINDIG_TOKEN ? '&st=' + <portlet:namespace/>SHINDIG_TOKEN : '';
	  //        
	  //    <portlet:namespace/>sendRequest('GET', url, function(data)
	  //	{
	  //	  response(data.list);
	  //    });
	  // }
	  //});
  }


  function <portlet:namespace/>displayStatusMessage() {
    html = '';
    //status message
      if(<portlet:namespace/>fLastResult.status) {
          html += '<div style="clear:both; margin-top: 15px;">'
                  + '<label style="margin-right:1em;"><liferay-ui:message key="profile-status-msg" />:</label>' + <portlet:namespace/>fLastResult.status
                + '</div>';
      }
      if(<portlet:namespace/>fIsEditable) {
        html += '<label for="<portlet:namespace/>statusField">' + '<liferay-ui:message key="profile-set-status-msg" />'
          + ':</label>'
          + '<div class="input-group">'
            + '<input class="form-control" type="text" size="45" id="<portlet:namespace/>statusField" placeholder="'
              + '<liferay-ui:message key="profile-enter-status-msg" />' + '"/>'
            + '<span class="input-group-btn">'
              + '<button class="btn btn-default" onclick="<portlet:namespace/>updateStatus()"><i class="icon-ok"></i></button>'
            + '</span>'
          + '</div>';
      }

    return html;
  }
  
  function <portlet:namespace/>displayLowerProfile()
  {
    var aboutMeString = '<liferay-ui:message key="profile-about-me" />';
    aboutMeString = aboutMeString.charAt(0).toUpperCase() + aboutMeString.slice(1);

    var html = '<div id="<portlet:namespace/>profile2"> <h3>' + aboutMeString + '</h3>';
    
    if(<portlet:namespace/>fIsEditable)
    {


      html += '<table width="100%" id="<portlet:namespace/>profileTable" class="edit-table <portlet:namespace/>profileTable">'
            + <portlet:namespace/>displayEditableLowerProfile()
            + '</table></div>';
    }
    else
    {
      /* moved
      //status message
      if(<portlet:namespace/>fLastResult.status)
      {
//        html += '<tr><td>' + '<liferay-ui:message key="profile-status-msg" />' + ':</td><td>'
//          + <portlet:namespace/>fLastResult.status + '</td></tr>';
          html += '<div class="panel panel-default"><div class="panel-body">'
                + '<label><liferay-ui:message key="profile-status-msg" />:</label> ' + <portlet:namespace/>fLastResult.status
                + '</div></div>';
      }
      */

      html += '<table width="100%" id="<portlet:namespace/>profileTable">';
    		  
      // Spoken languages
      html += <portlet:namespace/>displayMultiTextValueField(
      			'<portlet:namespace/>languageField', 
      			'<liferay-ui:message key="profile-languages"/>', 
      			<portlet:namespace/>fLastResult.languagesSpoken, 
      			'<liferay-ui:message key="profile-enter-language"/>', 
      			'<portlet:namespace/>addNewLanguage', 
      			'<portlet:namespace/>removeLanguage');
      
      // Activities (competences?)
      html += <portlet:namespace/>displayMultiTextValueField(
      			'<portlet:namespace/>activityField', 
      			'<liferay-ui:message key="profile-competences"/>', 
      			<portlet:namespace/>fLastResult.activities, 
      			<portlet:namespace/>ENTER_COMPETENCE, 
      			'<portlet:namespace/>addNewActivity', 
      			'<portlet:namespace/>removeActivity', true);
      
      // Interests
      html += <portlet:namespace/>displayMultiTextValueField(
      			'<portlet:namespace/>interestField', 
      			'<liferay-ui:message key="profile-interests"/>', 
      			<portlet:namespace/>fLastResult.interests, 
      			<portlet:namespace/>ENTER_INTEREST, 
      			'<portlet:namespace/>addNewInterest', 
      			'<portlet:namespace/>removeInterest', true);
      
      // Tags
      html += <portlet:namespace/>displayMultiTextValueField(
      			'<portlet:namespace/>tagField', 
      			'<liferay-ui:message key="profile-tags"/>', 
      			<portlet:namespace/>fLastResult.tags, 
      			<portlet:namespace/>ENTER_TAG, 
      			'<portlet:namespace/>addNewTag', 
      			'<portlet:namespace/>removeTag', true);


      html += '</table></div>';


      //about me
      if(<portlet:namespace/>fLastResult.aboutMe)
      {
        var quoteName = '';
        if(<portlet:namespace/>fLastResult.displayName)
        {
          quoteName = <portlet:namespace/>fLastResult.displayName;
        }
        else
        {
          quoteName = <portlet:namespace/>fLastResult.name.formatted;
        }

        html += '<div class="form-group" style="clear:both">'
            + '<label><liferay-ui:message key="profile-about-me" />:</label>'
            + '<blockquote class="blockquote-sm">'
              + '<p>' + <portlet:namespace/>fLastResult.aboutMe.replace(/\r\n|\n/g,"<br/>") + '</p>'
              + '<small>' + quoteName + '</small>'
            + '</blockquote>'
          + '</div>';
      }

      // actions:      
      html += '<div style="clear:both;">'
          + '<h3><liferay-ui:message key="profile-actions" /></h3>';

      
      if(!<portlet:namespace/>fIsFriend
    		  && <portlet:namespace/>fLastResult.id != <portlet:namespace/>USER_ID)
      {
          html += '<a class="btn btn-primary btn-sm floating-btn" href="#"  onclick="<portlet:namespace/>addFriend(\''
                + <portlet:namespace/>fLastResult.id + '\')" title="' + '<liferay-ui:message key="profile-friend-request" />'
                + '" data-toggle="tooltip" data-placement="top" style="margin-right: 10px;">'
                  + '<i class="icon-link"></i>'
              + '</a>';
      }
      
      if(<portlet:namespace/>fLastResult.id != <portlet:namespace/>USER_ID)
      {
          html += '<a class="btn btn-primary btn-sm floating-btn" href="#"  onclick="" title="' 
                + '<liferay-ui:message key="profile-send-message" />' 
                + '" data-toggle="tooltip" data-placement="top">'
                  + '<i class="icon-comment"></i>'
              + '</a>';
      }
            
//      html += '</td></tr>';
        html += '</div>';
    }
  
    return html;
  }
  
  function <portlet:namespace/>displayOrganizations()
  {
    var html = '';
  
    var primary = false;
  
    <portlet:namespace/>fLastResult.organizations.forEach(function(entry)
    {
      if(entry.primary)
      {
        primary = entry;
      }
    });
    
    //take first if there is no primary organization
    if(!primary && <portlet:namespace/>fLastResult.organizations.length > 0)
    {
      primary = <portlet:namespace/>fLastResult.organizations[0];
    }
    
    if(primary)
    {
      if(primary.title)
      {
        html += '<tr><td><label>' + '<liferay-ui:message key="profile-position" />' + ':</label></td><td>'
          + primary.title + '</td></tr>';
      }
      
      if(primary.department)
      {
        html += '<tr><td><label>' + '<liferay-ui:message key="profile-department" />' + ':</label></td><td>'
          + primary.department + '</td></tr>';
      }
      
      if(primary.managerId)
      {
        var name = primary.managerId;
    	  
    	html += '<tr><td><label>' + '<liferay-ui:message key="profile-manager" />' + ':</label></td><td>'
    	  + '<a id="<portlet:namespace/>managerLink"'
    	  + 'href="/web/guest/profile?userId=' + primary.managerId + '" target="_blank">'
    	  + name + '</a></td></tr>';
    	  
    	//asynchronously retrieve manager's display name
    	<portlet:namespace/>getManagerName(primary.managerId);
      }
    }
    
    return html;
  }
  
  function <portlet:namespace/>getManagerName(id)
  {
	  var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>PEOPLE_FRAG + id;
	  url += '?fields=id,displayName,name';
	  

	  if(<portlet:namespace/>SHINDIG_TOKEN != null)
	  {
	    url += '?st=' + <portlet:namespace/>SHINDIG_TOKEN;
	  }
	  
	  <portlet:namespace/>sendRequest('GET', url, <portlet:namespace/>setManagerName);
  }
  
  function <portlet:namespace/>setManagerName(response)
  {
	  response = response.entry;
	  var name = response.id;
	  if(response.displayName)
	  {
		name = response.displayName;
	  }
	  else if(response.name && response.name.formatted)
	  {
		name = response.name.formatted;
	  }
	  
	  var nameLink = document.getElementById('<portlet:namespace/>managerLink');
	  nameLink.innerHTML = name;
  }
  
  function <portlet:namespace/>displayEditableLowerProfile()
  {
    var html = '<tr><td><label for="<portlet:namespace/>thumbField">' + '<liferay-ui:message key="profile-pic-url" />'
      + ':</label></td><td><div class="input-group">'
        + '<input class="form-control" type="text" size="40" id="<portlet:namespace/>thumbField" value="';
    if(<portlet:namespace/>fLastResult.thumbnailUrl)
    {
      html += <portlet:namespace/>fLastResult.thumbnailUrl;
    }
    html += '" placeholder="' + '<liferay-ui:message key="profile-enter-pic-url" />' + '"/>';
    html += '<span class="input-group-btn">'
        + '<button class="btn btn-default" onclick="<portlet:namespace/>resetPicture()"/><i class="icon-remove"></i>'
        + '</button></td></tr>';
  
    //status message with own div
    /* >>> moved
    html += '<tr><td><label>' + '<liferay-ui:message key="profile-status-msg" />' + ':</label></td>'
    	+'<td><div id="<portlet:namespace/>statusMessage">';
    if(<portlet:namespace/>fLastResult.status)
    {
        html += <portlet:namespace/>fLastResult.status;
    }
    html += '</div></td></tr>'; */
    
    // Spoken languages
    html += <portlet:namespace/>displayMultiTextValueField(
    			'<portlet:namespace/>languageField', 
    			'<liferay-ui:message key="profile-languages"/>', 
    			<portlet:namespace/>fLastResult.languagesSpoken, 
    			'<liferay-ui:message key="profile-enter-language"/>', 
    			'<portlet:namespace/>addNewLanguage', 
    			'<portlet:namespace/>removeLanguage');
    
    // Activities (competences?)
    html += <portlet:namespace/>displayMultiTextValueField(
    			'<portlet:namespace/>activityField', 
    			'<liferay-ui:message key="profile-competences"/>', 
    			<portlet:namespace/>fLastResult.activities, 
    			<portlet:namespace/>ENTER_COMPETENCE, 
    			'<portlet:namespace/>addNewActivity', 
    			'<portlet:namespace/>removeActivity', true);
    
    // Interests
    html += <portlet:namespace/>displayMultiTextValueField(
    			'<portlet:namespace/>interestField', 
    			'<liferay-ui:message key="profile-interests"/>', 
    			<portlet:namespace/>fLastResult.interests, 
    			<portlet:namespace/>ENTER_INTEREST, 
    			'<portlet:namespace/>addNewInterest', 
    			'<portlet:namespace/>removeInterest', true);
    
    // Tags
    html += <portlet:namespace/>displayMultiTextValueField(
    			'<portlet:namespace/>tagField', 
    			'<liferay-ui:message key="profile-tags"/>', 
    			<portlet:namespace/>fLastResult.tags, 
    			<portlet:namespace/>ENTER_TAG, 
    			'<portlet:namespace/>addNewTag', 
    			'<portlet:namespace/>removeTag', true);

    //about me
    html += '<tr><td><label for="<portlet:namespace/>aboutField">' + '<liferay-ui:message key="profile-about-me" />'
      + ':</label> </td><td><textarea class="form-control" cols="45" id="<portlet:namespace/>aboutField" '
      + 'placeholder="' + '<liferay-ui:message key="profile-enter-about-me" />' + '">';
    if(<portlet:namespace/>fLastResult.aboutMe)
    {
      html += <portlet:namespace/>fLastResult.aboutMe;
    }
    html += '</textarea></td></tr>';
    
    //shout box
    /* >>> moved
    html += '<tr><td> </td></tr>';
    html += '<tr><td><label for="<portlet:namespace/>statusField">' + '<liferay-ui:message key="profile-set-status-msg" />'
        + ':</label></td><td><div class="input-group">'
          + '<input class="form-control" type="text" size="45" id="<portlet:namespace/>statusField" placeholder="'
            + '<liferay-ui:message key="profile-enter-status-msg" />' + '"/>'
          + '<span class="input-group-btn">'
            + '<button class="btn btn-default" onclick="<portlet:namespace/>updateStatus()"><i class="icon-ok"></i></button>'
          + '</span>'
          + '</div>'
        + '</td></tr>'; */
    
    html += '<tr><td> </td></tr>';
  
    return html;
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
      	+ '" style="vertical-align: middle;" title="' + name + '" />';
    }
    
    return label + '&nbsp;';
  }
  
  function <portlet:namespace/>updateNetPres()
  {
    //set selected value
    var value = document.getElementById('<portlet:namespace/>netPresField').value;
    
    if(value != 'NULL')
    {
      var person = new Object();
      var netPres = new Object();
      netPres.value = value;
      
      person.id = <portlet:namespace/>fLastResult.id;
      person.networkPresence = netPres;
      
      //store
      //var params = {"userId": <portlet:namespace/>fLastResult.id, "person": person};
  
      //osapi.people.<portlet:namespace/>update(params).execute(<portlet:namespace/>newNetPres);
      
      var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>PEOPLE_FRAG
      	+ person.id + '/@self';
      
      if(<portlet:namespace/>SHINDIG_TOKEN != null)
      {
    	  url += '&st=' + <portlet:namespace/>SHINDIG_TOKEN;
      }
      
      //send request
      <portlet:namespace/>sendRequest('PUT', url, <portlet:namespace/>newNetPres, person);
    }
    else
    {
      //alert('<liferay-ui:message key="profile-status-unknown" />');

	  document.getElementById('<portlet:namespace/>errorSpan').innerHTML = '<liferay-ui:message key="profile-status-unknown" />';
	  document.getElementById('<portlet:namespace/>errorSpan').style.display = 'flex';
	  
      <portlet:namespace/>fLastResult.networkPresence = null;
    }
  }
  
  function <portlet:namespace/>getColorDiv(value)
  {
	value = <portlet:namespace/>fStatusColors[value];
		  	
	if(!value)
	{
	  value = '<portlet:namespace/>blackStatus';
	}
		  	
	return '<div id="' + value + '">&nbsp;</div>';
  }
  
  function <portlet:namespace/>newNetPres(data)
  {
    if(data)
    {
      <portlet:namespace/>fLastResult.networkPresence = data.entry.networkPresence;
      
      var colorDiv = <portlet:namespace/>getColorDiv(data.entry.networkPresence.value);
      
      document.getElementById('<portlet:namespace/>colorFrame').innerHTML = colorDiv;
    }
    else
    {
      //alert('Shindig Profile Portlet: no data received');

	  document.getElementById('<portlet:namespace/>errorSpan').innerHTML = 'no data received';
	  document.getElementById('<portlet:namespace/>errorSpan').style.display = 'flex';
    }
  }
  
  function <portlet:namespace/>updateStatus()
  {
    var status = document.getElementById('<portlet:namespace/>statusField').value;
    
    //status for partial <portlet:namespace/>update
    var person = new Object();
    person.id = <portlet:namespace/>fLastResult.id;
    person.status = status;
  
    //store
    //var params = {"userId": <portlet:namespace/>fLastResult.id, "person": person};
  
    //osapi.people.<portlet:namespace/>update(params).execute(<portlet:namespace/>createStatusActivity);
    
    var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>PEOPLE_FRAG
    	+ person.id + '/@self';
    
    if(<portlet:namespace/>SHINDIG_TOKEN != null)
    {
  	  url += '?st=' + <portlet:namespace/>SHINDIG_TOKEN;
    }
    
    //create status update activity
    //<portlet:namespace/>sendRequest('PUT', url, <portlet:namespace/>createStatusActivity, person);
    //disabled
    <portlet:namespace/>sendRequest('PUT', url, <portlet:namespace/>statusSuccess, person);
  }
  
  function <portlet:namespace/>resetPicture()
  {
    document.getElementById('<portlet:namespace/>thumbField').value =
      '<%=request.getContextPath()%>/images/profile_picture_placeholder.png';
  }

  function <portlet:namespace/>statusSuccess(data)
  {
    if(!data)
    {
      //alert('Shindig Profile Portlet: no data received');

	  document.getElementById('<portlet:namespace/>errorSpan').innerHTML = 'no data received';
	  document.getElementById('<portlet:namespace/>errorSpan').style.display = 'flex';
      return;
    }
    
    //status for next full <portlet:namespace/>update
    document.getElementById('<portlet:namespace/>statusMessage').innerHTML = data.entry.status;
    <portlet:namespace/>fLastResult.status = data.entry.status;
  }
  
  function <portlet:namespace/>createStatusActivity(data)
  {
    if(!data)
    {
      //alert('Shindig Profile Portlet: no data received');

	  document.getElementById('<portlet:namespace/>errorSpan').innerHTML = 'no data received';
	  document.getElementById('<portlet:namespace/>errorSpan').style.display = 'flex';
      return;
    }
    
    //status for next full <portlet:namespace/>update
    document.getElementById('<portlet:namespace/>statusMessage').innerHTML = data.entry.status;
    <portlet:namespace/>fLastResult.status = data.entry.status;
    
    //user is actor
    var actor = new Object();
    actor.id = <portlet:namespace/>fLastResult.id;
    actor.displayName = <portlet:namespace/>fLastResult.displayName;
    actor.objectType = 'person';
    
    //shindig profile portlet (this) is generator
    var generator = new Object();
    generator.id = 'shindig-profile-portlet';
    generator.displayName = 'Shindig Profile Portlet';
    generator.objectType = 'application';
    
    //build activity
    var activity = new Object();
    activity.title = '<liferay-ui:message key="profile-new-status-title" />';
    activity.actor = actor;
    activity.generator = generator;
    activity.verb = 'update';
    
    activity.content = '<liferay-ui:message key="profile-new-status-content" />'
      + ': ' + <portlet:namespace/>fLastResult.status;
    
    //store
    //var params = {"userId": <portlet:namespace/>fLastResult.id, "activity": activity,
    //  "fields": 'id'};
  
    //osapi.activitystreams.create(params).execute(<portlet:namespace/>nopSuccess);
    
	var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>ACTIVITY_FRAG
		+ <portlet:namespace/>fLastResult.id + '/@self';
    
    if(<portlet:namespace/>SHINDIG_TOKEN != null)
    {
  	  url += '?st=' + <portlet:namespace/>SHINDIG_TOKEN;
    }
    
    //send request
    <portlet:namespace/>sendRequest('POST', url, <portlet:namespace/>nopSuccess, activity);
  }
  
  function <portlet:namespace/>nopSuccess(data)
  {
    if(!data)
    {
      //alert('Shindig Profile Portlet: no data received');

	  document.getElementById('<portlet:namespace/>errorSpan').innerHTML = 'no data received';
	  document.getElementById('<portlet:namespace/>errorSpan').style.display = 'flex';
    }
  }
  
  function <portlet:namespace/>addNewMail()
  {
    <portlet:namespace/>copyFields();
    
    mail = new Object();
    mail.value = '';
  
    if(!<portlet:namespace/>fLastResult.emails)
    {
      <portlet:namespace/>fLastResult.emails = new Array();
    }
    
    <portlet:namespace/>fLastResult.emails.push(mail);
    
    <portlet:namespace/>displayProfile();
  }
  
  function <portlet:namespace/>removeMail(index)
  {
    <portlet:namespace/>copyFields();
    
    <portlet:namespace/>fLastResult.emails.splice(index, 1);
    
    <portlet:namespace/>displayProfile();
  }
  
  function <portlet:namespace/>addNewPhone()
  {
    <portlet:namespace/>copyFields();
    
    phone = new Object();
    phone.value = '';
  
    if(!<portlet:namespace/>fLastResult.phoneNumbers)
    {
      <portlet:namespace/>fLastResult.phoneNumbers = new Array();
    }
    
    <portlet:namespace/>fLastResult.phoneNumbers.push(phone);
    
    <portlet:namespace/>displayProfile();
  }
  
  function <portlet:namespace/>removePhone(index)
  {
    <portlet:namespace/>copyFields();
    
    <portlet:namespace/>fLastResult.phoneNumbers.splice(index, 1);
    
    <portlet:namespace/>displayProfile();
  }
  
  // Posts the skill and adds it to the skill list
  function <portlet:namespace/>addNewSkill()
  {
	  var newSkillValue = document.getElementById('<portlet:namespace/>skillField').value;
	  
	  // Blocks if there has no skill value entered
	  if (!newSkillValue)
	  {
		  //alert('<liferay-ui:message key="profile-enter-skill"/>');

		  document.getElementById('<portlet:namespace/>errorSpan').innerHTML = '<liferay-ui:message key="profile-enter-skill"/>';
		  document.getElementById('<portlet:namespace/>errorSpan').style.display = 'flex';
	    return;
	  }
	  
	  <portlet:namespace/>addSkill(newSkillValue, '<liferay-ui:message key="profile-skill-add-success" />');
  }

  // adds a skill to the database, refreshing the local display
  function <portlet:namespace/>addSkill(skill, message)
  {
	var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>SKILLS_FRAG + 
    document.getElementById('<portlet:namespace/>eid').value + '/' + skill;
   	url += <portlet:namespace/>SHINDIG_TOKEN ? '?st=' + <portlet:namespace/>SHINDIG_TOKEN : '';
   	
    // Performes the REST POST operation to write the new skill to database
	<portlet:namespace/>sendRequest('POST', url, function()
	{
	  <portlet:namespace/>refreshSkillProfile(message);
	}, '{}');
  }
  
  // Removes the skill with the specified index
  function <portlet:namespace/>removeSkill(index, message)
  {
    var removeSkillValue = document.getElementById('<portlet:namespace/>skill' + index).innerText;
  
    var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>SKILLS_FRAG + 
     document.getElementById('<portlet:namespace/>eid').value + '/' + removeSkillValue;
    url += <portlet:namespace/>SHINDIG_TOKEN ? '?st=' + <portlet:namespace/>SHINDIG_TOKEN : '';
	  
    // Performes a REST DELETE operation to remove the skill from the database
	<portlet:namespace/>sendRequest('DELETE', url, function()
	{
		<portlet:namespace/>refreshSkillProfile(message);
	});
  }
  
  function <portlet:namespace/>addNewLanguage()
  {
    <portlet:namespace/>copyFields();
    
    language = '';
  
    if(!<portlet:namespace/>fLastResult.languagesSpoken)
    {
      <portlet:namespace/>fLastResult.languagesSpoken = new Array();
    }
    
    <portlet:namespace/>fLastResult.languagesSpoken.push(language);
    
    <portlet:namespace/>displayProfile();
  }
  
  function <portlet:namespace/>removeLanguage(index)
  {
    <portlet:namespace/>copyFields();
    
    <portlet:namespace/>fLastResult.languagesSpoken.splice(index, 1);
    
    <portlet:namespace/>displayProfile();
  }
  
  function <portlet:namespace/>addNewActivity()
  {
    <portlet:namespace/>copyFields();
    
    activity = '';

    if(!<portlet:namespace/>fLastResult.activities)
    {
      <portlet:namespace/>fLastResult.activities = new Array();
    }
    
    <portlet:namespace/>fLastResult.activities.push(activity);
    
    <portlet:namespace/>displayProfile();
  }
  
  function <portlet:namespace/>removeActivity(index)
  {
    <portlet:namespace/>copyFields();
    
    <portlet:namespace/>fLastResult.activities.splice(index, 1);
    
    <portlet:namespace/>displayProfile();
  }
  
  function <portlet:namespace/>addNewInterest()
  {
    <portlet:namespace/>copyFields();
    
    interest = '';

    if(!<portlet:namespace/>fLastResult.interests)
    {
      <portlet:namespace/>fLastResult.interests = new Array();
    }
    
    <portlet:namespace/>fLastResult.interests.push(interest);
    
    <portlet:namespace/>displayProfile();
  }
  
  function <portlet:namespace/>removeInterest(index)
  {
    <portlet:namespace/>copyFields();
    
    <portlet:namespace/>fLastResult.interests.splice(index, 1);
    
    <portlet:namespace/>displayProfile();
  }
  
  function <portlet:namespace/>addNewTag()
  {
    <portlet:namespace/>copyFields();
    
    tag = '';

    if(!<portlet:namespace/>fLastResult.tags)
    {
      <portlet:namespace/>fLastResult.tags = new Array();
    }
    
    <portlet:namespace/>fLastResult.tags.push(tag);
    
    <portlet:namespace/>displayProfile();
  }
  
  function <portlet:namespace/>removeTag(index)
  {
    <portlet:namespace/>copyFields();
    
    <portlet:namespace/>fLastResult.tags.splice(index, 1);
    
    <portlet:namespace/>displayProfile();
  }
  
  function <portlet:namespace/>save()
  {
    //copy all fields to temporary object
    <portlet:namespace/>copyFields();
  
    //store
    var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>PEOPLE_FRAG
    	+ <portlet:namespace/>fLastResult.id + '/@self';
    	
   	if(<portlet:namespace/>SHINDIG_TOKEN != null)
    {
    	url += '?st=' + <portlet:namespace/>SHINDIG_TOKEN;
    }
       
    //send request
    <portlet:namespace/>sendRequest('PUT', url, <portlet:namespace/>updatedActivity,
    	<portlet:namespace/>fLastResult);
  }
  
  function <portlet:namespace/>copyFields()
  {
    //get parameters
    var displayName = document.getElementById('<portlet:namespace/>dispNameField').value;
    var givenName = document.getElementById('<portlet:namespace/>givNameField').value;
    var familyName = document.getElementById('<portlet:namespace/>famNameField').value;
    var aboutMe = document.getElementById('<portlet:namespace/>aboutField').value;
    var thumbnailUrl = document.getElementById('<portlet:namespace/>thumbField').value;
  
    //apply changes to person object
    if(displayName && displayName != '')
    {
      <portlet:namespace/>fLastResult.displayName = displayName;
    }
    
    if(thumbnailUrl && thumbnailUrl != '')
    {
      <portlet:namespace/>fLastResult.thumbnailUrl = thumbnailUrl;
    }
    else
    {
      <portlet:namespace/>fLastResult.thumbnailUrl =
    	  '<%=request.getContextPath()%>/images/profile_picture_placeholder.png';
    }
    
    <portlet:namespace/>fLastResult.givenName = givenName;
    <portlet:namespace/>fLastResult.familyName = familyName;
    <portlet:namespace/>fLastResult.aboutMe = aboutMe;
    
    //set new values for list fields
    <portlet:namespace/>getListFields();
  }
  
  function <portlet:namespace/>getListFields()
  {
    var index = 0;
    
    //E-Mails
    if(<portlet:namespace/>fLastResult.emails)
    {
      <portlet:namespace/>fLastResult.emails.forEach(function(entry)
      {
        entry.type = document.getElementById('<portlet:namespace/>emailTypeField' + index).value;
        entry.value = document.getElementById('<portlet:namespace/>emailField' + index).value;
        entry.primary = document.getElementById('<portlet:namespace/>primaryMail' + index).checked;
        ++index;
      });
    }
    
    //Phone numbers
    if(<portlet:namespace/>fLastResult.phoneNumbers)
    {
      index = 0;
      <portlet:namespace/>fLastResult.phoneNumbers.forEach(function(entry)
      {
        entry.type = document.getElementById('<portlet:namespace/>phoneTypeField' + index).value;
        entry.value = document.getElementById('<portlet:namespace/>phoneField' + index).value;
        entry.primary = document.getElementById('<portlet:namespace/>primaryPhone' + index).checked;
        ++index;
      });
    }
    
    //spoken languages
    if(<portlet:namespace/>fLastResult.languagesSpoken)
    {
      index = 0;
      <portlet:namespace/>fLastResult.languagesSpoken.forEach(function(entry)
      {
        <portlet:namespace/>fLastResult.languagesSpoken[index] = document.getElementById(
          '<portlet:namespace/>languageField' + index).value;
        ++index;
      });
    }
    
    //activities
    if(<portlet:namespace/>fLastResult.activities)
    {
      index = 0;
      <portlet:namespace/>fLastResult.activities.forEach(function(entry)
      {
    	var element = document.getElementById('<portlet:namespace/>activityField' + index);
    	
    	if(element && element.value)
    	{
          <portlet:namespace/>fLastResult.activities[index] = element.value;
    	}
        ++index;
      });
    }
    
    //interests
    if(<portlet:namespace/>fLastResult.interests)
    {
      index = 0;
      <portlet:namespace/>fLastResult.interests.forEach(function(entry)
      {
    	var element = document.getElementById('<portlet:namespace/>interestField' + index)

    	if(element && element.value)
    	{
          <portlet:namespace/>fLastResult.interests[index] = element.value;
    	}
        ++index;
      });
    }
    
    //tags
    if(<portlet:namespace/>fLastResult.tags)
    {
      index = 0;
      <portlet:namespace/>fLastResult.tags.forEach(function(entry)
      {
    	var element = document.getElementById('<portlet:namespace/>tagField' + index);

    	if(element && element.value)
    	{
          <portlet:namespace/>fLastResult.tags[index] = element.value;
    	}
        ++index;
      });
    }
  }
  
  function <portlet:namespace/>updatedActivity(data)
  {
	  if(data)
	  {
		//show confirmation
		//alert('<liferay-ui:message key="profile-updated" />');
		
		document.getElementById('<portlet:namespace/>successSpan').innerHTML = '<liferay-ui:message key="profile-save-success" />';
		document.getElementById('<portlet:namespace/>successSpan').style.display = 'flex';
		
		//refresh display
		<portlet:namespace/>getProfile();
		 
		//deactivated - moved to backend
		/*
	    //user is actor
	    var actor = new Object();
	    actor.id = <portlet:namespace/>fLastResult.id;
	    actor.displayName = <portlet:namespace/>fLastResult.displayName;
	    actor.objectType = 'person';
	    
	    //shindig profile portlet (this) is generator
	    var generator = new Object();
	    generator.id = 'shindig-profile-portlet';
	    generator.displayName = 'Shindig Profile Portlet';
	    generator.objectType = 'application';
	    
	    //build activity
	    var activity = new Object();
	    activity.title = '<liferay-ui:message key="profile-profile-update-title" />';
	    activity.actor = actor;
	    activity.generator = generator;
	    activity.verb = 'update';
	    
	    //TODO: set actual diff as content?
	    
		var url = <portlet:namespace/>SHINDIG_URL + <portlet:namespace/>ACTIVITY_FRAG
			+ <portlet:namespace/>fLastResult.id + '/@self';
	    
	    if(<portlet:namespace/>SHINDIG_TOKEN != null)
	    {
	  	  url += '?st=' + <portlet:namespace/>SHINDIG_TOKEN;
	    }
	    
	    //send request
	    <portlet:namespace/>sendRequest('POST', url, <portlet:namespace/>getCleanCopy, activity);
	    */
	  }
	  else
	  {
	    //alert('Shindig Profile Portlet: no data received');
	    
		document.getElementById('<portlet:namespace/>errorSpan').innerHTML = '<liferay-ui:message key="profile-save-error" />';
		document.getElementById('<portlet:namespace/>errorSpan').style.display = 'flex';
	  }
  }
  
  function <portlet:namespace/>getCleanCopy(data)
  {
    if(data)
    {
  	  <portlet:namespace/>getProfile();
    }
	else
	{
	  //alert('Shindig Profile Portlet: no data received');
	  
	  document.getElementById('<portlet:namespace/>errorSpan').innerHTML = 'no data received';
	  document.getElementById('<portlet:namespace/>errorSpan').style.display = 'flex';
	}
  }
  
  function <portlet:namespace/>addFriend(id)
  {
    var person = {"id": id};
  
    //var params = {"userId": "@me", "groupId": "@friends",
    //  "person": person};
    
    //osapi.people.create(params).execute(<portlet:namespace/>requestSent);
    
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
      //alert('shindig-portlet: no data received');

	  document.getElementById('<portlet:namespace/>errorSpan').innerHTML = 'no data received';
	  document.getElementById('<portlet:namespace/>errorSpan').style.display = 'flex';
    }
    else
    {
      //alert('<liferay-ui:message key="profile-request-sent" />');

	  document.getElementById('<portlet:namespace/>successSpan').innerHTML = '<liferay-ui:message key="profile-request-sent" />';
	  document.getElementById('<portlet:namespace/>successSpan').style.display = 'flex';
    }
  }
  
  function <portlet:namespace/>overrideEdit()
  {
    if(<portlet:namespace/>fLastResult)
    {
      <portlet:namespace/>fLastResult.isViewer = true;
      
      var data = new Object();
      data.entry = <portlet:namespace/>fLastResult;
      <portlet:namespace/>update(data);
    }
  }
  
  function <portlet:namespace/>init()
  {
    var html;
    
    var userParam = '<%= userParam %>';
    
    if(!userParam || userParam.length == 0 || userParam == 'null')
    {
    	userParam = <portlet:namespace/>USER_ID;
    }
      
    if(<portlet:namespace/>fDebug)
    {
      html = 'Profil von ID: <input type="text" size="6"';
      html += 'id="<portlet:namespace/>eid" value="' + userParam + '"/>';
      html += '<input type="button" value="holen" onclick="<portlet:namespace/>getProfile()"/>';
      html += '<input type="button" value="bearbeiten" onclick="<portlet:namespace/>overrideEdit()"/>';
    }
    else
    {
      //TODO: change to owner
      html = '<input type="hidden" id="<portlet:namespace/>eid" value="' + userParam + '"/>';
    }
    
    document.getElementById('<portlet:namespace/>debugSel').innerHTML = html;
    
    <portlet:namespace/>getProfile();
  }
  
  //get <portlet:namespace/>initial data
  <portlet:namespace/>init();
</script>
