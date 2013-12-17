function myNode = cca(varargin)
% CCA - CCA-based BCG correction

import meegpipe.node.*;


myPCA = spt.pca('RetainedVar', 99.9);
tpcaFilter = filter.tpca('Order', @(sr) ceil(sr/10), 'PCA', myPCA);

delayFh = @(sr) unique(round(linspace(sr*0.65, sr*1.3, 30)));
myCCA = spt.bss.cca('Delay', delayFh);


ccFilter = filter.cca(...
    'CCA',          myCCA, ...
    'CCFilter',     tpcaFilter, ...
    'MinCorr',      0.20, ...
    'TopCorrFirst', true);

% IMPORTANT: It is almost always a good idea to use the cca filter within a
% pca filter so that we avoid ill-conditioned covariance matrices. 
ccFilter = filter.pca(...
    'PCA', spt.pca('RetainedVar', 99.99), ...
    'PCFilter', ccFilter);

ccFilter = filter.sliding_window(...
    'Filter',             ccFilter, ...
    'WindowLength',       @(sr) sr*20, ...
    'WindowOverlap',      75);

myRegrEstimator = pipeline.new( ...
    copy.new, ...
    filter.new('Filter', ccFilter), ...
    spt.new('SPT', spt.pca('RetainedVar', 99.9)), ...
    'Name', 'regressor-estimator' ...
    );


myRegrFilter = filter.mlag_regr('Order', 5);
myRegrFilter = filter.sliding_window(...
    'Filter',        myRegrFilter, ...
    'WindowLength',  @(sr) sr*10, ...
    'WindowOverlap', 50);

mySel1 = pset.selector.sensor_class('Class', 'EEG');
mySel2 = pset.selector.good_data;
mySel  = pset.selector.cascade(mySel1, mySel2);

myNode = parallel_node_array.new(...
    'DataSelector', mySel, ...    
    'NodeList',     {[], myRegrEstimator}, ...
    'Aggregator',   @(out) filter(myRegrFilter, out{1}, out{2}), ...
    'CopyInput',    false, ...
    varargin{:});
    


end