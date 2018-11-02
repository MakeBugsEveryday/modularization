platform:ios,'8.0'
inhibit_all_warnings!
use_frameworks!

workspace 'Modularization.xcworkspace'

########################################  dependency

# workspace
def workspace_pods
    
    # react
    pod 'RxSwift'
    pod 'RxCocoa'
    
    # orm
    pod 'ObjectMapper', '~> 3.3.0'
    pod 'SwiftyJSON'
end

# main project dependency
def project_only_pods
    
    pod 'SnapKit', '~> 4.0.0'
    pod 'Kingfisher', '~> 4.0'
    pod 'MJRefresh'
    pod 'MJExtension'
    pod 'MD-UITableView+FDTemplateLayoutCell'
    pod 'SVProgressHUD', '2.0.4'
end

# network layer dependency
def network_layer_pods
    
    pod 'Moya/RxSwift', '~> 11.0'
    pod 'Moya', '~> 11.0.2'
    pod 'Alamofire', '~> 4.5'
end

######################################## main project

target 'Modularization' do

    workspace_pods
    project_only_pods
    network_layer_pods

    target 'ModularizationTests' do
        inherit! :search_paths
    end

    target 'ModularizationUITests' do
        inherit! :search_paths
    end
end

######################################## Library

# Service
target 'MADService' do
    project 'MADService/MADService.xcodeproj'
    
    #
    workspace_pods
    network_layer_pods
end

# Base
target 'MADBase' do
    project 'MADBase/MADBase.xcodeproj'
    
    #
    workspace_pods
end

# Core
target 'MADCore' do
    project 'MADCore/MADCore.xcodeproj'
    
    #
    workspace_pods
end
