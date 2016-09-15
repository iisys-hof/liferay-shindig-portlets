package de.hofuniversity.iisys.liferay.portlet.activities;

import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.Charset;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletException;
import javax.portlet.ResourceRequest;
import javax.portlet.ResourceResponse;
import javax.portlet.ResourceServingPortlet;

import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCPortlet;

public class ActivitiesPortlet extends MVCPortlet implements ResourceServingPortlet
{
	public void setParams(ActionRequest request, ActionResponse response)
			throws IOException, PortletException
    {
		String first = request.getParameter("first");
    	String max = request.getParameter("max");
    	
    	if(first != null)
    	{
    		request.getPortletSession().setAttribute("first", first);
    	}
    	
    	if(max != null)
    	{
    		request.getPortletSession().setAttribute("max", max);
    	}
	}
	
    @Override
    public void serveResource(ResourceRequest request, ResourceResponse response)
    		throws PortletException, IOException
    {
    	final String resource = request.getResourceID();
    	
    	if("getParams".equals(resource))
    	{
    		getParams(request, response);
    	}
    }
    
    private void getParams(ResourceRequest request, ResourceResponse response)
    {
    	JSONObject json = JSONFactoryUtil.createJSONObject();
    	json.put("first", request.getPortletSession().getAttribute("first").toString());
        json.put("max", request.getPortletSession().getAttribute("max").toString());
        
    	byte[] data = json.toString().getBytes(Charset.forName(
    			response.getCharacterEncoding()));

    	response.setContentType("application/json");
    	response.setContentLength(data.length);
        
        try
        {
        	final OutputStream os = response.getPortletOutputStream();
        	
			os.write(data);
			os.flush();
			os.close();
		}
        catch (IOException e)
        {
			e.printStackTrace();
		}
    }
}
