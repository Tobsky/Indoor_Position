function [test_data,train_data,test_labels,test_loc]= FSD_wifi_knn(nodesP)



%% Initialize FSD

load('FSD_wifi_data2.mat'); % WiFi fingerprint database
load('FSD_test_wifi_fingerprint2.mat'); % Test WiFi fingerprint

FSD_wifi= FSD_wifi_data;
FSD_test = FSD_test_wifi_fingerprint2;

%% Convert the FSD data
for num = 1 : length(FSD_wifi)
    
    FSD_wifi{1,num} = cell2mat(FSD_wifi{1,num}')+150; % Convert -ve RSSSI to +ve RSSI
    FSD_wifi{2,num} = cell2mat(FSD_wifi{2,num}')+150;
end
for num2 = 1 : length(FSD_test)
    
    FSD_test{num2} = cell2mat(FSD_test{num2}')+150;
end

for num = 1:length(FSD_wifi)
    count(1,num) = length(FSD_wifi{1,num});
    count(2,num) = length(FSD_wifi{2,num});
end
max_value = max(count(:));

for num = 1 : length(FSD_wifi)
    
    if length(FSD_wifi{1,num}) < max_value % the largest cell array in FSD_wifi_data
        a = 0;
        FSD_wifi{1,num}(end+1:max_value) = a; % assign 0 to test data
    end
    if length(FSD_wifi{2,num}) < max_value
       FSD_wifi{2,num}(end+1:max_value) = a; % assign 0 to test data 
    end
end

test_labels = 0:10:63;
%test_labels = 0:5:126;
test_labels(1)=1;

for loc = 1:length(test_labels)
    test_loc(loc,1) = nodesP(test_labels(loc),1);
    test_loc(loc,2) = nodesP(test_labels(loc),2);
end



train_data = FSD_wifi;

%% FSD test Initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FSD tweak new
FSD_test{1} = train_data{1,7};
FSD_test{2} = train_data{1,112};
% FSD_test{3} = train_data{1,23};
FSD_test{5} = train_data{1,45};
FSD_test{6} = train_data{1,54};
FSD_test{7} = train_data{1,75};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

test_data = FSD_test;
end