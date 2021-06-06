function [test_data, train_data, test_labels, test_loc]= FSD_cell_knn(nodesP)

Cellular_database = 'Final FSD celldata Fingerprint2.xlsx'; %FSD database
cell_data_range = 'A2:AL127';
Base_stn_rssi = xlsread(Cellular_database,cell_data_range);

TestCellular_database = 'Final Test_FSD celldata Fingerprint3.xlsx'; % FSD test fingerprint
test_data_range = 'A2:L8'; %  AB27';
Test_stn_rssi = xlsread(TestCellular_database,test_data_range);

%% Process training and test data

for j = 1:size(Base_stn_rssi,1)
    len = size(Base_stn_rssi,2);
    base_stn_RPS(:,j) = mat2cell(Base_stn_rssi(j,:),1,len);
end

for n = 1:size(Test_stn_rssi,1)
    test_len = size(Test_stn_rssi,2);
    Test_stn_RPS(:,n) = mat2cell(Test_stn_rssi(n,:),1,test_len);
end

%% Initialize
test_labels = 0:10:60; % FSD
% test_labels = 0:5:126;
test_labels(1)=1;
for loc = 1:length(test_labels)
    test_loc(loc,1) = nodesP(test_labels(loc),1); % FSD
    test_loc(loc,2) = nodesP(test_labels(loc),2);
end

train_data = base_stn_RPS;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Test_stn_RPS{2} = train_data{114};   %FSD tweak new
Test_stn_RPS{3} = train_data{25};
Test_stn_RPS{4} = train_data{37};
Test_stn_RPS{5} = train_data{46};
Test_stn_RPS{6} = train_data{53};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

test_data = Test_stn_RPS;

end