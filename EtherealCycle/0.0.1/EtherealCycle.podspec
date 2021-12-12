Pod::Spec.new do |spec|
  spec.name         = "EtherealCycle"
  spec.version      = "0.0.1"
  spec.summary      = "A CarouselView"
  spec.description  = <<-DESC
			a mini carouselView Base on UICollectionView
                   DESC
  spec.homepage     = "https://github.com/Bulsh726/EtherealCycle"
  spec.license      = ":type => 'MIT'"
  spec.platform     = :ios, "9.0"
  spec.swift_versions = '5.5'
  spec.author             = { "“Bulsh726”" => "“983392167@qq.com" }
  spec.source       = { :git => "https://github.com/Bulsh726/EtherealCycle.git", :tag => "v#{spec.version}" }
  spec.source_files  = "EtherealCycle/EtherealCycle/CarouselView/*.{swift}"
end