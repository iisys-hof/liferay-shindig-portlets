package de.hofuniversity.iisys.liferay.portlet.userdirectory;

import com.liferay.portal.configuration.metatype.annotations.ExtendedObjectClassDefinition;
import aQute.bnd.annotation.metatype.Meta;

@ExtendedObjectClassDefinition(
   category = "Apache Shindig",
   scope = ExtendedObjectClassDefinition.Scope.PORTLET_INSTANCE
)
@Meta.OCD(
   id = "de.hofuniversity.iisys.liferay.portlet.userdirectory.UserDirectoryPortletInstanceConfiguration"
)
public interface UserDirectoryPortletInstanceConfiguration
{
	@Meta.AD(deflt = "true", required = false)
    public boolean showSearch(boolean defaultShowSearch);

    @Meta.AD(deflt = "false", required = false)
    public boolean wikiLinkDetection(boolean defaultWikiLinkDetection);
}
