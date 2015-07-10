package org.xtext.gradle.tasks;

import groovy.lang.Closure
import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors
import org.gradle.api.Action
import org.gradle.api.Named
import org.gradle.api.NamedDomainObjectContainer
import org.gradle.api.Project
import org.gradle.api.internal.file.FileResolver
import org.gradle.api.tasks.Input
import org.gradle.api.tasks.Nested
import org.gradle.api.tasks.Optional
import org.gradle.util.ConfigureUtil
import org.xtext.gradle.protocol.GradleInstallDebugInfoRequest.SourceInstaller
import org.xtext.gradle.protocol.IssueSeverity
import org.xtext.gradle.tasks.internal.DefaultXtextSourceSet

class XtextExtension {
	@Accessors String version = "2.9.0"
	@Accessors val NamedDomainObjectContainer<XtextSourceSet> sourceSets
	@Accessors val NamedDomainObjectContainer<Language> languages;

	Project project

	new(Project project, FileResolver fileResolver) {
		this.project = project
		sourceSets = project.container(XtextSourceSet)[name|new DefaultXtextSourceSet(name, project, fileResolver)]
		languages = project.container(Language)[name|new Language(name, project)]
	}

	def sourceSets(Action<? super NamedDomainObjectContainer<XtextSourceSet>> configureAction) {
		configureAction.execute(sourceSets)
	}

	def languages(Action<? super NamedDomainObjectContainer<Language>> configureAction) {
		configureAction.execute(languages)
	}
}

@Accessors
class Language implements Named {
	@Input val String name
	String qualifiedName
	String fileExtension
	@Input String setup
	@Nested val GeneratorConfig generator
	@Nested val debugger = new DebuggerConfig
	@Nested val validator = new ValidatorConfig
	@Input Map<String, Object> preferences = newHashMap
	
	@Accessors(NONE) val Project project

	new(String name, Project project) {
		this.name = name
		this.project = project
		this.generator = new GeneratorConfig(project, this)
	}

	@Input
	def getQualifiedName() {
		qualifiedName ?: setup.replace("StandaloneSetup", "")
	}
	
	@Input
	def getFileExtension() {
		fileExtension ?: name
	}
	
	def generator(Closure<?> configureClosure) {
		ConfigureUtil.configure(configureClosure, generator)
	}
	
	def debugger(Closure<?> configureClosure) {
		ConfigureUtil.configure(configureClosure, debugger)
	}
	
	def validator(Closure<?> configureClosure) {
		ConfigureUtil.configure(configureClosure, validator)
	}

	def preferences(Map<String, String> preferences) {
		this.preferences.putAll(preferences)
	}
}

@Accessors
class GeneratorConfig {
	@Input boolean suppressWarningsAnnotation = true
	@Input String javaSourceLevel = '1.6'
	@Nested val GeneratedAnnotationOptions generatedAnnotation = new GeneratedAnnotationOptions
	@Nested val NamedDomainObjectContainer<Outlet> outlets
	
	new (Project project,Language language) {
		this.outlets = project.container(Outlet)[outlet| new Outlet(language, outlet)]
	}

	def outlets(Closure<?> configureClosure) {
		ConfigureUtil.configure(configureClosure, outlets)
	}
	
	def outlet() {
		outlets.maybeCreate(Outlet.DEFAULT_OUTLET)
	}
	
	def outlet(Closure<?> configureClosure) {
		ConfigureUtil.configure(configureClosure, outlet)
	}
	
	def generatedAnnotation (Closure<?> configureClosure) {
		ConfigureUtil.configure(configureClosure, generatedAnnotation)
	}
}

@Accessors
class GeneratedAnnotationOptions {
	@Input boolean active
	@Input boolean includeDate
	@Input @Optional String comment
}

@Accessors
class DebuggerConfig {
	@Input SourceInstaller sourceInstaller = SourceInstaller.NONE
	@Input boolean hideSyntheticVariables = true
}

@Accessors
class ValidatorConfig {
	@Input Map<String, IssueSeverity> severities = newHashMap
	
	def void error(String code) {
		severities.put(code, IssueSeverity.ERROR)
	}
	
	def void warning(String code) {
		severities.put(code, IssueSeverity.WARNING)
	}
	
	def void info(String code) {
		severities.put(code, IssueSeverity.INFO)
	}
	
	def void ignore(String code) {
		severities.put(code, IssueSeverity.IGNORE)
	}
}

@Accessors
class Outlet implements Named {
	public static val DEFAULT_OUTLET = "DEFAULT_OUTPUT"

	val Language language
	@Input val String name
	@Input boolean producesJava = false
}