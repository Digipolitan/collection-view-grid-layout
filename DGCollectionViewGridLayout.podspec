Pod::Spec.new do |s|
s.name = "DGCollectionViewGridLayout"
s.version = "1.0.1"
s.summary = "Layout that allows you to display collection of data in grid with only very few lines of codes"
s.homepage = "https://github.com/Digipolitan/collection-view-grid-layout"
s.authors = "Digipolitan"
s.source = { :git => "https://github.com/Digipolitan/collection-view-grid-layout.git", :tag => "v#{s.version}" }
s.license = { :type => "BSD", :file => "LICENSE" }
s.source_files = 'Sources/**/*.{swift,h}'
s.ios.deployment_target = '8.0'
s.requires_arc = true
end
