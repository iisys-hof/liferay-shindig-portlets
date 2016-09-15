package de.hofuniversity.iisys.liferay.portlet.userdirectory;

import com.liferay.portal.kernel.settings.definition.ConfigurationBeanDeclaration;

public class UserDirectoryPortletServiceConfigurationBeanDeclaration implements ConfigurationBeanDeclaration
{
	@Override
	public Class<?> getConfigurationBeanClass()
	{
		return UserDirectoryPortletInstanceConfiguration.class;
	}
}
