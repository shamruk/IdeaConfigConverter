# IdeaConfigConverter

to make this thing working, plz add file like following to the root of the project

gradleProject.xml

<project>
	<groupId>someid</groupId>
	<artifactId>com.smth</artifactId>
	<version>current</version>
	<gradleFxVersion>1.3.1</gradleFxVersion>
	<flexSdkVersion>4.14.1</flexSdkVersion>
	<airSdkVersion>18.0</airSdkVersion>
	<flashPlayerVersion>18.0</flashPlayerVersion>
	<flashSWFVersion>29</flashSWFVersion>
	<!--skipModules>Other</skipModules-->
	<storepass>*****</storepass>
	<platforms>
		<io>
			<replace from="${source.io.certificate}" to="../../certificates/smth.p12"/>
			<replace from="${source.io.provision}" to="../../certificates/smth.mobileprovision"/>
			<replace from="${source.io.debug.certificate}" to="../../certificates/smth.p12"/>
			<replace from="${source.io.debug.provision}" to="../../certificates/smth.mobileprovision"/>
			<compileOptions>-define+=CONFIG::iOS,true -define+=CONFIG::GooglePlay,false -define+=CONFIG::Amazon,false</compileOptions>
		</io>
		<an>
			<replace from="${source.an.certificate}" to="../../certificates/smth.p12"/>
			<replace from="${source.an.descriptor}" to="../../smth/smth.xml"/>
			<compileOptions>-define+=CONFIG::iOS,false -define+=CONFIG::GooglePlay,true -define+=CONFIG::Amazon,false</compileOptions>
		</an>
		<am>
			<replace from="${source.am.certificate}" to="../../certificates/smth.p12"/>
			<replace from="${source.am.descriptor}" to="../../smth/smth.xml"/>
			<compileOptions>-define+=CONFIG::iOS,false -define+=CONFIG::GooglePlay,false -define+=CONFIG::Amazon,true</compileOptions>
		</am>
		<web>
			<compileOptions>-define+=CONFIG::iOS,false -define+=CONFIG::GooglePlay,false -define+=CONFIG::Amazon,false</compileOptions>
		</web>
	</platforms>
</project>


gradle command e.g.

gradle clean packageMobile --parallel -Pplatform=an -Pdebug=false -PbuildVersion=`git describe | sed 's|[^_]*_[^_]*_||g' | sed 's|-.*||g'`.0
