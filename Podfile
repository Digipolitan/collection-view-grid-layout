workspace 'DGFrameworkTemplate.xcworkspace'

## Frameworks targets
abstract_target 'Frameworks' do
	use_frameworks!
	target 'DGFrameworkTemplate-iOS' do
		platform :ios, '8.0'
	end

	target 'DGFrameworkTemplate-watchOS' do
		platform :watchos, '2.0'
	end

	target 'DGFrameworkTemplate-tvOS' do
		platform :tvos, '9.0'
	end

	target 'DGFrameworkTemplate-OSX' do
		platform :osx, '10.9'
	end
end

## Tests targets
abstract_target 'Tests' do
	use_frameworks!
	target 'DGFrameworkTemplateTests-iOS' do
		platform :ios, '8.0'
	end

	target 'DGFrameworkTemplateTests-tvOS' do
		platform :tvos, '9.0'
	end

	target 'DGFrameworkTemplateTests-OSX' do
		platform :osx, '10.9'
	end
end

## Samples targets
abstract_target 'Samples' do
	use_frameworks!
	target 'DGFrameworkTemplateSample-iOS' do
		project 'Samples/DGFrameworkTemplateSample-iOS/DGFrameworkTemplateSample-iOS'
		platform :ios, '8.0'
	end

	abstract_target 'watchOS' do
		project 'Samples/DGFrameworkTemplateSample-watchOS/DGFrameworkTemplateSample-watchOS'
		target 'DGFrameworkTemplateSample-watchOS' do
			platform :ios, '8.0'
		end

		target 'DGFrameworkTemplateSample-watchOS WatchKit Extension' do
			platform :watchos, '2.0'
		end
	end

	target 'DGFrameworkTemplateSample-tvOS' do
		project 'Samples/DGFrameworkTemplateSample-tvOS/DGFrameworkTemplateSample-tvOS'
		platform :tvos, '9.0'
	end

	target 'DGFrameworkTemplateSample-OSX' do
		project 'Samples/DGFrameworkTemplateSample-OSX/DGFrameworkTemplateSample-OSX'
		platform :osx, '10.9'
	end
end
