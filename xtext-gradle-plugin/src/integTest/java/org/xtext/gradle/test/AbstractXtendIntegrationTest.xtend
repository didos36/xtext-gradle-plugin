package org.xtext.gradle.test

import java.io.File

abstract class AbstractXtendIntegrationTest extends AbstractIntegrationTest {
	
	override setup() {
		super.setup()
		applyXtendPlugin
	}
	
	protected def void applyXtendPlugin() {
		buildFile << xtendPluginSnippet
	}
	
	protected def CharSequence getXtendPluginSnippet() '''
		apply plugin: 'org.xtext.xtend'
		
		dependencies {
			«xtendScope» 'org.eclipse.xtend:org.eclipse.xtend.lib:«XTEXT_VERSION»'
		}
	'''
	
	protected def String getXtendScope() {
		'compile'
	}
	
	protected def File createHelloWorld() {
		createFile('src/main/java/HelloWorld.xtend', '''
			class HelloWorld {
				
				def void helloWorld() {
					#['hello', 'world'].forEach[println(toFirstUpper)]
				}
				
			}
		''')
	}
	
}