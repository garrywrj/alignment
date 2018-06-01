% directory containing the mp3 files
%   dirname = 'Z:\fingerprint\4.5Â¼Òô\¿â';
%   % find all the MP3 files
%   dlist = dir(fullfile(dirname, '*.mp3'));
%   % put their full paths into a cell array
%   tks = []; 
%   for i = 1:length(dlist); ...
%     tks{i} = fullfile(dirname, dlist(i).name); ...
%   end
tks = [];
tks{1} = 'Z:\fingerprint\4.5Â¼Òô\Â¼Òô\ref_query_1_L.mp3';

%Initialize the hash table database array 
clear_hashtable
% Calculate the landmark hashes for each reference track and store
% it in the array (takes a few seconds per track).
add_tracks(tks);
global HashTable HashTableCounts